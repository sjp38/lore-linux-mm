Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 53673900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 09:36:08 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so7832443pdb.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 06:36:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id gb5si1073055pbb.25.2015.06.03.06.36.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 06:36:06 -0700 (PDT)
Subject: Re: [RFC 0/2] mapping_gfp_mask from the page fault path
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
	<20150602132241.26fbbc98be71920da8485b73@linux-foundation.org>
In-Reply-To: <20150602132241.26fbbc98be71920da8485b73@linux-foundation.org>
Message-Id: <201506032204.GAI56216.OOSVJHFLOQtMFF@I-love.SAKURA.ne.jp>
Date: Wed, 3 Jun 2015 22:04:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz
Cc: linux-mm@kvack.org, david@fromorbit.com, neilb@suse.de, hannes@cmpxchg.org, viro@zeniv.linux.org.uk, mgorman@suse.de, riel@redhat.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Andrew Morton wrote:
> On Mon,  1 Jun 2015 15:00:01 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > I somehow forgot about these patches. The previous version was
> > posted here: http://marc.info/?l=linux-mm&m=142668784122763&w=2. The
> > first attempt was broken but even when fixed it seems like ignoring
> > mapping_gfp_mask in page_cache_read is too fragile because
> > filesystems might use locks in their filemap_fault handlers
> > which could trigger recursion problems as pointed out by Dave
> > http://marc.info/?l=linux-mm&m=142682332032293&w=2.
> > 
> > The first patch should be straightforward fix to obey mapping_gfp_mask
> > when allocating for mapping. It can be applied even without the second
> > one.
> 
> I'm not so sure about that.  If only [1/2] is applied then those
> filesystems which are setting mapping_gfp_mask to GFP_NOFS will now
> actually start using GFP_NOFS from within page_cache_read() etc.  The
> weaker allocation mode might cause problems.

If [1/2] is applied, the OOM killer will be disabled until [2/2] is also
applied because !__GFP_FS allocations does not invoke the OOM killer.
But both __GFP_FS allocations (e.g. GFP_KERNEL) and !__GFP_FS allocations
(e.g. GFP_NOFS) apply "loop forever unless order > PAGE_ALLOC_COSTLY_ORDER
or GFP_NORETRY is given or chosen as an OOM victim" rule. And the problem
which silently hang up the system unless we choose an OOM victim is outside
of these patches' scope.

By the way,

Michal Hocko wrote:
> Initialize the default to (mapping_gfp_mask | GFP_IOFS) because this
> should be safe from the page fault path normally. Why do we care
> about mapping_gfp_mask at all then? Because this doesn't hold only
> reclaim protection flags but it also might contain zone and movability
> restrictions (GFP_DMA32, __GFP_MOVABLE and others) so we have to respect
> those.

[2/2] says that mapping_gfp_mask(mapping) might contain bits which are not
in !GFP_KERNEL. If we do

  GFP_KERNEL & mapping_gfp_mask(mapping)

we will drop such bits and will cause problems. Thus, "GFP_KERNEL"
in patch [1/1] should be replaced with "mapping_gfp_mask(mapping)" than
"GFP_KERNEL & mapping_gfp_mask(mapping)" ?

Well, maybe we should define GFP_NOIO, GFP_NOFS, GFP_KERNEL like

  #define __GFP_NOWAIT      ((__force gfp_t)___GFP_NOWAIT)    /* Can not wait and reschedule */
  #define __GFP_NOIO        ((__force gfp_t)___GFP_NOIO)      /* Can not start physical IO */
  #define __GFP_NOFS        ((__force gfp_t)___GFP_NOFS)      /* Can not call down to low-level FS */
  #define GFP_NOIO          (__GFP_NOFS | __GFP_NOIO)
  #define GFP_NOFS          (__GFP_NOFS)
  #define GFP_KERNEL        (0)

so that __GFP_* bits represent requirements than permissions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
