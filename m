Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C59286B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 14:17:12 -0400 (EDT)
Received: by wixm2 with SMTP id m2so17659876wix.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:17:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ck3si2629249wib.101.2015.03.26.11.17.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 11:17:11 -0700 (PDT)
Date: Thu, 26 Mar 2015 14:17:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 08/12] mm: page_alloc: wait for OOM killer progress
 before retrying
Message-ID: <20150326181700.GA16898@phnom.home.cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-9-git-send-email-hannes@cmpxchg.org>
 <201503252315.FBJ09847.FSOtOJQFOMLFVH@I-love.SAKURA.ne.jp>
 <20150326112445.GC18560@cmpxchg.org>
 <20150326143223.GM15257@dhcp22.suse.cz>
 <20150326152343.GE23973@cmpxchg.org>
 <20150326153847.GP15257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326153847.GP15257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, ying.huang@intel.com, aarcange@redhat.com, david@fromorbit.com, tytso@mit.edu

On Thu, Mar 26, 2015 at 04:38:47PM +0100, Michal Hocko wrote:
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

I don't think that's a good idea.  gfp_to_alloc_flags() reinitializes
the entire allocation context from the gfp flags and the task state,
but the only thing we care about, which can actually change here, is
TIF_MEMDIE.  This is perfectly obvious and expected in the OOM kill
allocation function, which makes my code self-documenting, whereas if
you use gfp_to_alloc_flags() you have to explain why it is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
