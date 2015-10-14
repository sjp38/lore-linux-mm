Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 994576B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 10:59:45 -0400 (EDT)
Received: by wiyb4 with SMTP id b4so1607027wiy.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 07:59:45 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id s12si11995081wik.40.2015.10.14.07.59.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 07:59:44 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so133463879wic.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 07:59:43 -0700 (PDT)
Date: Wed, 14 Oct 2015 16:59:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silent hang up caused by pages being not scanned?
Message-ID: <20151014145938.GI28333@dhcp22.suse.cz>
References: <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
 <20151013133225.GA31034@dhcp22.suse.cz>
 <201510140119.FGC17641.FSOHMtQOFLJOVF@I-love.SAKURA.ne.jp>
 <20151014132248.GH28333@dhcp22.suse.cz>
 <201510142338.IEE21387.LFHSQVtMOFOFJO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510142338.IEE21387.LFHSQVtMOFOFJO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Wed 14-10-15 23:38:00, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Why hasn't balance_dirty_pages throttled writers and allowed them to
> > make the whole LRU dirty? What is your dirty{_background}_{ratio,bytes}
> > configuration on that system.
> 
> All values are defaults of plain CentOS 7 installation.

So this is 3.10 kernel, right?

> # sysctl -a | grep ^vm.
> vm.dirty_background_ratio = 10
> vm.dirty_bytes = 0
> vm.dirty_expire_centisecs = 3000
> vm.dirty_ratio = 30
[...]

OK, this is nothing unusual. And I _suspect_ that the throttling simply
didn't cope with the writer speed and a large anon memory consumer.
Dirtyable memory was quite high until your anon hammer bumped in
and reduced dirtyable memory down so the file LRU is full of dirty pages
when we get under serious memory pressure. Anonymous pages are not
reclaimable so the whole memory pressure goes to file LRUs and bang.

> > Also why throttle_vm_writeout haven't slown the reclaim down?
> 
> Too difficult question for me.
> 
> > 
> > Anyway this is exactly the case where zone_reclaimable helps us to
> > prevent OOM because we are looping over the remaining LRU pages without
> > making progress... This just shows how subtle all this is :/
> > 
> > I have to think about this much more..
> 
> I'm suspicious about tweaking current reclaim logic.
> Could you please respond to Linus's comments?

Yes I plan to I just didn't get to finish my email yet.
 
> There are more moles than kernel developers can find. I think that
> what we can do for short term is to prepare for moles that kernel
> developers could not find, and for long term is to reform page
> allocator for preventing moles from living.

This is much easier said than done :/ The current code is full of
heuristics grown over time based on very different requirements from
different kernel subsystems. There is no simple solution for this
problem I am afraid.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
