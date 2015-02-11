Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C84906B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 22:22:49 -0500 (EST)
Received: by pdjp10 with SMTP id p10so1365481pdj.3
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 19:22:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p4si29015199pdn.171.2015.02.10.19.22.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 19:22:48 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
	<20141230112158.GA15546@dhcp22.suse.cz>
	<201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
	<201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
	<20150210151934.GA11212@phnom.home.cmpxchg.org>
In-Reply-To: <20150210151934.GA11212@phnom.home.cmpxchg.org>
Message-Id: <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
Date: Wed, 11 Feb 2015 11:23:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

Johannes Weiner wrote:
> On Tue, Feb 10, 2015 at 10:58:46PM +0900, Tetsuo Handa wrote:
> > (Michal is offline, asking Johannes instead.)
> > 
> > Tetsuo Handa wrote:
> > > (A) The order-0 __GFP_WAIT allocation fails immediately upon OOM condition
> > >     despite we didn't remove the
> > > 
> > >         /*
> > >          * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
> > >          * means __GFP_NOFAIL, but that may not be true in other
> > >          * implementations.
> > >          */
> > >         if (order <= PAGE_ALLOC_COSTLY_ORDER)
> > >                 return 1;
> > > 
> > >     check in should_alloc_retry(). Is this what you expected?
> > 
> > This behavior is caused by commit 9879de7373fcfb46 "mm: page_alloc:
> > embed OOM killing naturally into allocation slowpath". Did you apply
> > that commit with agreement to let GFP_NOIO / GFP_NOFS allocations fail
> > upon memory pressure and permit filesystems to take fs error actions?
> > 
> > 	/* The OOM killer does not compensate for light reclaim */
> > 	if (!(gfp_mask & __GFP_FS))
> > 		goto out;
> 
> The model behind the refactored code is to continue retrying the
> allocation as long as the allocator has the ability to free memory,
> i.e. if page reclaim makes progress, or the OOM killer can be used.
> 
> That being said, I missed that GFP_NOFS were able to loop endlessly
> even without page reclaim making progress or the OOM killer working,
> and since it didn't fit the model I dropped it by accident.
> 
> Is this a real workload you are having trouble with or an artificial
> stresstest?  Because I'd certainly be willing to revert that part of
> the patch and make GFP_NOFS looping explicit if it helps you.  But I
> do think the new behavior makes more sense, so I'd prefer to keep it
> if it's merely a stress test you use to test allocator performance.

I'm working for troubleshooting RHEL systems. This is an artificial
stresstest which I developed for trying to reproduce various low memory
troubles occurred on customer's systems.

> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8e20f9c2fa5a..f77c58ebbcfa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		if (high_zoneidx < ZONE_NORMAL)
>  			goto out;
>  		/* The OOM killer does not compensate for light reclaim */
> -		if (!(gfp_mask & __GFP_FS))
> +		if (!(gfp_mask & __GFP_FS)) {
> +			/*
> +			 * XXX: Page reclaim didn't yield anything,
> +			 * and the OOM killer can't be invoked, but
> +			 * keep looping as per should_alloc_retry().
> +			 */
> +			*did_some_progress = 1;
>  			goto out;
> +		}

Why do you omit out_of_memory() call for GFP_NOIO / GFP_NOFS allocations?
Thread2 doing GFP_FS / GFP_KERNEL allocation might be waiting for Thread1
doing GFP_NOIO / GFP_NOFS allocation to call out_of_memory() on behalf of
Thread2, as mutexed by

        /*
         * Acquire the per-zone oom lock for each zone.  If that
         * fails, somebody else is making progress for us.
         */
        if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
                *did_some_progress = 1;
                schedule_timeout_uninterruptible(1);
                return NULL;
        }

lock. If Thread1 calls oom_zonelist_trylock() / oom_zonelist_unlock() without
sleep while Thread2 calls oom_zonelist_trylock() / oom_zonelist_unlock() with
sleep, Thread2 is unlikely able to call out_of_memory() because Thread2 likely
fails at oom_zonelist_trylock().

>  		/*
>  		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
>  		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
> 

Though, more serious behavior with this reproducer is (B) where the system
stalls forever without kernel messages being saved to /var/log/messages .
out_of_memory() does not select victims until the coredump to pipe can make
progress whereas the coredump to pipe can't make progress until memory
allocation succeeds or fails.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
