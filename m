Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 522FA6B006C
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 08:49:27 -0400 (EDT)
Received: by wgin8 with SMTP id n8so79398149wgi.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 05:49:26 -0700 (PDT)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id i7si4772550wib.26.2015.04.13.05.49.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Apr 2015 05:49:26 -0700 (PDT)
Received: by wgyo15 with SMTP id o15so79596379wgy.2
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 05:49:25 -0700 (PDT)
Date: Mon, 13 Apr 2015 14:49:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150413124924.GB21790@dhcp22.suse.cz>
References: <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
 <20150401151920.GB23824@dhcp22.suse.cz>
 <20150407141822.GA3262@cmpxchg.org>
 <201504111629.FIB81218.QStJFFVFOLOMHO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201504111629.FIB81218.QStJFFVFOLOMHO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, david@fromorbit.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, ying.huang@intel.com, aarcange@redhat.com, tytso@mit.edu

On Sat 11-04-15 16:29:26, Tetsuo Handa wrote:
> Johannes Weiner wrote:
> > The argument here was always that NOFS allocations are very limited in
> > their reclaim powers and will trigger OOM prematurely.  However, the
> > way we limit dirty memory these days forces most cache to be clean at
> > all times, and direct reclaim in general hasn't been allowed to issue
> > page writeback for quite some time.  So these days, NOFS reclaim isn't
> > really weaker than regular direct reclaim.  The only exception is that
> > it might block writeback, so we'd go OOM if the only reclaimables left
> > were dirty pages against that filesystem.  That should be acceptable.
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 47981c5e54c3..fe3cb2b0b85b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2367,16 +2367,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> >  		/* The OOM killer does not needlessly kill tasks for lowmem */
> >  		if (ac->high_zoneidx < ZONE_NORMAL)
> >  			goto out;
> > -		/* The OOM killer does not compensate for IO-less reclaim */
> > -		if (!(gfp_mask & __GFP_FS)) {
> > -			/*
> > -			 * XXX: Page reclaim didn't yield anything,
> > -			 * and the OOM killer can't be invoked, but
> > -			 * keep looping as per tradition.
> > -			 */
> > -			*did_some_progress = 1;
> > -			goto out;
> > -		}
> >  		if (pm_suspended_storage())
> >  			goto out;
> >  		/* The OOM killer may not free memory on a specific node */
> > 
> 
> I think this change will allow calling out_of_memory() which results in
> "oom_kill_process() is trivially called via pagefault_out_of_memory()"
> problem described in https://lkml.org/lkml/2015/3/18/219 .
> 
> I myself think that we should trigger OOM killer for !__GFP_FS allocation
> in order to make forward progress in case the OOM victim is blocked.
> So, my question about this change is whether we can accept involving OOM
> killer from page fault, no matter how trivially OOM killer will kill some
> process?

We trigger OOM killer from the page fault path for ages. In fact the memcg
will trigger memcg OOM killer _only_ from the page fault path because
this context is safe as we do not sit on any locks at the time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
