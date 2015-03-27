Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7F92D6B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 10:02:13 -0400 (EDT)
Received: by pdcp1 with SMTP id p1so5889544pdc.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 07:02:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ok14si3021303pdb.2.2015.03.27.07.02.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 07:02:12 -0700 (PDT)
Subject: Re: [patch 08/12] mm: page_alloc: wait for OOM killer progressbefore retrying
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201503252315.FBJ09847.FSOtOJQFOMLFVH@I-love.SAKURA.ne.jp>
	<20150326112445.GC18560@cmpxchg.org>
	<20150326143223.GM15257@dhcp22.suse.cz>
	<20150326152343.GE23973@cmpxchg.org>
	<20150326153847.GP15257@dhcp22.suse.cz>
In-Reply-To: <20150326153847.GP15257@dhcp22.suse.cz>
Message-Id: <201503272301.ICE86424.SFtMJLOFQHOVFO@I-love.SAKURA.ne.jp>
Date: Fri, 27 Mar 2015 23:01:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, ying.huang@intel.com, aarcange@redhat.com, david@fromorbit.com, tytso@mit.edu

Michal Hocko wrote:
> On Thu 26-03-15 11:23:43, Johannes Weiner wrote:
> > On Thu, Mar 26, 2015 at 03:32:23PM +0100, Michal Hocko wrote:
> > > On Thu 26-03-15 07:24:45, Johannes Weiner wrote:
> > > > On Wed, Mar 25, 2015 at 11:15:48PM +0900, Tetsuo Handa wrote:
> > > > > Johannes Weiner wrote:
> > > [...]
> > > > > >  	/*
> > > > > > -	 * Acquire the oom lock.  If that fails, somebody else is
> > > > > > -	 * making progress for us.
> > > > > > +	 * This allocating task can become the OOM victim itself at
> > > > > > +	 * any point before acquiring the lock.  In that case, exit
> > > > > > +	 * quickly and don't block on the lock held by another task
> > > > > > +	 * waiting for us to exit.
> > > > > >  	 */
> > > > > > -	if (!mutex_trylock(&oom_lock)) {
> > > > > > -		*did_some_progress = 1;
> > > > > > -		schedule_timeout_uninterruptible(1);
> > > > > > -		return NULL;
> > > > > > +	if (test_thread_flag(TIF_MEMDIE) || mutex_lock_killable(&oom_lock)) {
> > > > > > +		alloc_flags |= ALLOC_NO_WATERMARKS;
> > > > > > +		goto alloc;
> > > > > >  	}
> > > > > 
> > > > > When a thread group has 1000 threads and most of them are doing memory allocation
> > > > > request, all of them will get fatal_signal_pending() == true when one of them are
> > > > > chosen by OOM killer.
> > > > > This code will allow most of them to access memory reserves, won't it?
> > > > 
> > > > Ah, good point!  Only TIF_MEMDIE should get reserve access, not just
> > > > any dying thread.  Thanks, I'll fix it in v2.
> > > 
> > > Do you plan to post this v2 here for review?
> > 
> > Yeah, I was going to wait for feedback to settle before updating the
> > code.  But I was thinking something like this?
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9ce9c4c083a0..106793a75461 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2344,7 +2344,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> >  	 * waiting for us to exit.
> >  	 */
> >  	if (test_thread_flag(TIF_MEMDIE) || mutex_lock_killable(&oom_lock)) {
> > -		alloc_flags |= ALLOC_NO_WATERMARKS;
> > +		if (test_thread_flag(TIF_MEMDIE))
> > +			alloc_flags |= ALLOC_NO_WATERMARKS;
> >  		goto alloc;
> >  	}
> 
> OK, I have expected something like this. I understand why you want to
> retry inside this function. But I would prefer if gfp_to_alloc_flags was
> used here so that we do not have that TIF_MEMDIE logic duplicated at two
> places.

I thought we expected something like

-	if (!mutex_trylock(&oom_lock)) {
+	if (mutex_lock_killable(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
-		return NULL;
+		if (test_thread_flag(TIF_MEMDIE))
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else
+			schedule_timeout_uninterruptible(1);
+		goto alloc;
 	}

or

 	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
+		if (test_thread_flag(TIF_MEMDIE)) {
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+			goto alloc;
+		}
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}

because jumping to

  return get_page_from_freelist(gfp_mask, order, alloc_flags, ac);

without modifying alloc_flags and without setting *did_some_progress to 1
will lead to immediate allocation failures for !TIF_MEMDIE threads.

I don't like allowing only TIF_MEMDIE to get reserve access, for it can be
one of !TIF_MEMDIE threads which really need memory to safely terminate without
failing allocations from do_exit(). Rather, why not to discontinue TIF_MEMDIE
handling and allow getting access to private memory reserves for all
fatal_signal_pending() threads (i.e. replacing WMARK_OOM with WMARK_KILLED
in "[patch 09/12] mm: page_alloc: private memory reserves for OOM-killing
allocations") ?

> > > @@ -2383,12 +2382,20 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > >  		if (gfp_mask & __GFP_THISNODE)
> > >  			goto out;
> > >  	}
> > > -	/* Exhausted what can be done so it's blamo time */
> > > -	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
> > > -			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> > > +
> > > +	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)) {
> > >  		*did_some_progress = 1;
> > > +	} else {
> > > +		/* Oops, these shouldn't happen with the OOM killer disabled */
> > > +		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> > > +			*did_some_progress = 1;
> > > +	}
> > 
> > I think GFP_NOFAIL allocations need to involve OOM killer than
> > pretending as if forward progress is made. If all of in-flight
> > allocation requests are GFP_NOFAIL, the system will lock up.
> 
> Hm?  They do involve the OOM killer, but once userspace is frozen for
> suspend/hibernate we shouldn't kill and thaw random tasks anymore as
> that might corrupt the memory snapshot, so nofail allocations are a
> bug at this point.
> 

Aren't there still kernel threads which might do GFP_NOFAIL allocations?
I think corrupting the memory snapshot by involving the OOM killer is the
correct behavior than a bug.

> > After all, if we wait for OOM killer progress before retrying, I think
> > we should involve OOM killer after some bounded timeout regardless of
> > gfp flags, and let OOM killer kill more threads after another bounded
> > timeout. Otherwise, the corner cases will lock up the system.
> 
> Giving nofail allocations access to emergency reserves targets this
> problem, but I agree with you that it's still possible for the system
> to lock up if they have been consumed and still no task made enough
> forward progress to release memory.  It is unlikely but possible.
> 
> I will probably come back to the OOM victim timeout patch some time in
> the future as that seems more robust.  It would also drastically
> simplify memcg OOM handling.  But that patch was controversial in the
> past and seemed beyond the scope of this patch set.
> 

A timeout for recovering from WMARK_KILLED to WMARK_MIN could be used for
detecting whether we need to trigger additinal OOM-killing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
