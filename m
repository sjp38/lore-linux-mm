Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E37FE6B0567
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 12:52:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l3so2966205wrc.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 09:52:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k130si1593558wmf.17.2017.08.01.09.52.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 09:52:47 -0700 (PDT)
Date: Tue, 1 Aug 2017 18:52:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: do not rely on TIF_MEMDIE for memory
 reserves access
Message-ID: <20170801165242.GA15518@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-2-mhocko@kernel.org>
 <201708020030.ACB04683.JLHMFVOSFFOtOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708020030.ACB04683.JLHMFVOSFFOtOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 02-08-17 00:30:33, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > CONFIG_MMU=n doesn't have oom reaper so let's stick to the original
> > ALLOC_NO_WATERMARKS approach but be careful because they still might
> > deplete all the memory reserves so keep the semantic as close to the
> > original implementation as possible and give them access to memory
> > reserves only up to exit_mm (when tsk->mm is cleared) rather than while
> > tsk_is_oom_victim which is until signal struct is gone.
> 
> Currently memory allocations from __mmput() can use memory reserves but
> this patch changes __mmput() not to use memory reserves. You say "keep
> the semantic as close to the original implementation as possible" but
> this change is not guaranteed to be safe.

Yeah it cannot. That's why I've said as close as possible rather than
equivalent. On the other hand I am wondering whether you have anything
specific in mind or this is just a formalistic nitpicking^Wremark.

> > @@ -2943,10 +2943,19 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
> >  	 * the high-atomic reserves. This will over-estimate the size of the
> >  	 * atomic reserve but it avoids a search.
> >  	 */
> > -	if (likely(!alloc_harder))
> > +	if (likely(!alloc_harder)) {
> >  		free_pages -= z->nr_reserved_highatomic;
> > -	else
> > -		min -= min / 4;
> > +	} else {
> > +		/*
> > +		 * OOM victims can try even harder than normal ALLOC_HARDER
> > +		 * users
> > +		 */
> > +		if (alloc_flags & ALLOC_OOM)
> 
> ALLOC_OOM is ALLOC_NO_WATERMARKS if CONFIG_MMU=n.
> I wonder this test makes sense for ALLOC_NO_WATERMARKS.

Yeah, it would be pointless because get_page_from_freelist will then
ignore the result of the watermark check for ALLOC_NO_WATERMARKS. It is
not harmfull though. I didn't find much better way without making the
code harder to read.  Do you have any suggestion?

> > +			min -= min / 2;
> > +		else
> > +			min -= min / 4;
> > +	}
> > +
> >  
> >  #ifdef CONFIG_CMA
> >  	/* If allocation can't use CMA areas don't use free CMA pages */
> > @@ -3603,6 +3612,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  	return alloc_flags;
> >  }
> >  
> > +static bool oom_reserves_allowed(struct task_struct *tsk)
> > +{
> > +	if (!tsk_is_oom_victim(tsk))
> > +		return false;
> > +
> > +	/*
> > +	 * !MMU doesn't have oom reaper so we shouldn't risk the memory reserves
> > +	 * depletion and shouldn't give access to memory reserves passed the
> > +	 * exit_mm
> > +	 */
> > +	if (!IS_ENABLED(CONFIG_MMU) && !tsk->mm)
> > +		return false;
> 
> Branching based on CONFIG_MMU is ugly. I suggest timeout based next OOM
> victim selection if CONFIG_MMU=n.

I suggest we do not argue about nommu without actually optimizing for or
fixing nommu which we are not here. I am even not sure memory reserves
can ever be depleted for that config.

Anyway I will go with the following instead
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5e5911f40014..3510e06b3bf3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3618,11 +3618,10 @@ static bool oom_reserves_allowed(struct task_struct *tsk)
 		return false;
 
 	/*
-	 * !MMU doesn't have oom reaper so we shouldn't risk the memory reserves
-	 * depletion and shouldn't give access to memory reserves passed the
-	 * exit_mm
+	 * !MMU doesn't have oom reaper so give access to memory reserves
+	 * only to the thread with TIF_MEMDIE set
 	 */
-	if (!IS_ENABLED(CONFIG_MMU) && !tsk->mm)
+	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
 		return false;
 
 	return true;

This should preserve the original semantic. Is that acceptable for you?

> > @@ -3875,15 +3901,24 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> >  		wake_all_kswapds(order, ac);
> >  
> > -	if (gfp_pfmemalloc_allowed(gfp_mask))
> > -		alloc_flags = ALLOC_NO_WATERMARKS;
> > +	/*
> > +	 * Distinguish requests which really need access to whole memory
> > +	 * reserves from oom victims which can live with their own reserve
> > +	 */
> > +	reserves = gfp_pfmemalloc_allowed(gfp_mask);
> > +	if (reserves) {
> > +		if (tsk_is_oom_victim(current))
> > +			alloc_flags = ALLOC_OOM;
> 
> If reserves == true due to reasons other than tsk_is_oom_victim(current) == true
> (e.g. __GFP_MEMALLOC), why dare to reduce it?

Well the comment above tries to explain. I assume that the oom victim is
special here. a) it is on the way to die and b) we know that something
will be freeing memory on the background so I assume this is acceptable.
 
> > +		else
> > +			alloc_flags = ALLOC_NO_WATERMARKS;
> > +	}
> 
> If CONFIG_MMU=n, doing this test is silly.
> 
> if (tsk_is_oom_victim(current))
> 	alloc_flags = ALLOC_NO_WATERMARKS;
> else
> 	alloc_flags = ALLOC_NO_WATERMARKS;

I am pretty sure any compiler can see the outcome is the same so the
check would be dropped in that case. I primarily wanted to prevent from
an additional ifdefery. I am open to suggestions for a better layout
though.

> > @@ -3960,7 +3995,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		goto got_pg;
> >  
> >  	/* Avoid allocations with no watermarks from looping endlessly */
> > -	if (test_thread_flag(TIF_MEMDIE) &&
> > +	if (tsk_is_oom_victim(current) &&
> >  	    (alloc_flags == ALLOC_NO_WATERMARKS ||
> >  	     (gfp_mask & __GFP_NOMEMALLOC)))
> >  		goto nopage;
> 
> And you are silently changing to "!costly __GFP_DIRECT_RECLAIM allocations never fail
> (even selected for OOM victims)" (i.e. updating the too small to fail memory allocation
> rule) by doing alloc_flags == ALLOC_NO_WATERMARKS if CONFIG_MMU=y.

Ups that is an oversight during the rebase.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5e5911f40014..6593ff9de1d9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3996,7 +3996,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/* Avoid allocations with no watermarks from looping endlessly */
 	if (tsk_is_oom_victim(current) &&
-	    (alloc_flags == ALLOC_NO_WATERMARKS ||
+	    (alloc_flags == ALLOC_OOM ||
 	     (gfp_mask & __GFP_NOMEMALLOC)))
 		goto nopage;
 
Does this look better?
 
> Applying this change might disturb memory allocation behavior. I don't
> like this patch.

Do you see anything appart from nommu that would be an unfixable road
block?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
