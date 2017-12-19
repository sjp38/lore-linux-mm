Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B89D6B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:55:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r63so1247970wmb.9
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:55:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 143si1328517wmn.117.2017.12.19.06.55.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 06:55:10 -0800 (PST)
Date: Tue, 19 Dec 2017 15:55:08 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second
 allocation
Message-ID: <20171219145508.GZ2787@dhcp22.suse.cz>
References: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171211115723.GC4779@dhcp22.suse.cz>
 <201712132006.DDE78145.FMFJSOOHVFQtOL@I-love.SAKURA.ne.jp>
 <201712192336.GHG30208.MLFSVJQOHOFtOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712192336.GHG30208.MLFSVJQOHOFtOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

On Tue 19-12-17 23:36:02, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > Therefore, this patch allows OOM victims to use ALLOC_OOM watermark for
> > > > last second allocation attempt.
> > > 
> > > This changelog doesn't explain the problem, nor does it say why it
> > > should help. I would even argue that mentioning the LTP test is more
> > > confusing than helpful (also considering it a fix for 696453e66630ad45)
> > > because granting access to memory reserves will only help partially.
> > 
> > I know granting access to memory reserves will only help partially.
> > The intent of granting access to memory reserves is to reduce needlessly
> > OOM killing more victims.
> > 
> > > Anyway, the patch makes some sense to me but I am not going to ack it
> > > with a misleading changelog.
> > > 
> > 
> > Apart from how the changelog will look like, below is an updated patch
> > which to some degree recovers
> > 
> > 	 * That thread will now get access to memory reserves since it has a
> > 	 * pending fatal signal.
> > 
> > comment. It is pity that we will need to run more instructions in the fastpath
> > of __alloc_pages_slowpath() compared to "current->oom_kill_free_check_raced"
> > at out_of_memory(). Is this direction acceptable?
> 
> If http://lkml.kernel.org/r/20171219114012.GK2787@dhcp22.suse.cz ,
> is direction below acceptable?

The same applies here. You are touching the way how the memory reserves
are access in non-trivial way. You better have a very good reason for
that. So far you keep playing with different corner cases while you keep
showing that you do not really want to understand a bigger picture. This
can end up in regressions easily. Let me repeat something I've said a
long ago. We do not optimize for corner cases. We want to survive but if
an alternative is to kill another task then we can live with that.
 
> > ---
> >  mm/page_alloc.c | 53 ++++++++++++++++++++++++++++++++++++++++-------------
> >  1 file changed, 40 insertions(+), 13 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 31c1a61..f7bd969 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3334,6 +3334,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> >  	return page;
> >  }
> >  
> > +static struct page *alloc_pages_before_oomkill(gfp_t gfp_mask,
> > +					       unsigned int order,
> > +					       const struct alloc_context *ac);
> > +
> >  static inline struct page *
> >  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  	const struct alloc_context *ac, unsigned long *did_some_progress)
> > @@ -3359,16 +3363,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> >  		return NULL;
> >  	}
> >  
> > -	/*
> > -	 * Go through the zonelist yet one more time, keep very high watermark
> > -	 * here, this is only to catch a parallel oom killing, we must fail if
> > -	 * we're still under heavy pressure. But make sure that this reclaim
> > -	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> > -	 * allocation which will never fail due to oom_lock already held.
> > -	 */
> > -	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
> > -				      ~__GFP_DIRECT_RECLAIM, order,
> > -				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
> > +	page = alloc_pages_before_oomkill(gfp_mask, order, ac);
> >  	if (page)
> >  		goto out;
> >  
> > @@ -3734,9 +3729,17 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
> >  	return alloc_flags;
> >  }
> >  
> > -static bool oom_reserves_allowed(struct task_struct *tsk)
> > +static bool oom_reserves_allowed(void)
> >  {
> > -	if (!tsk_is_oom_victim(tsk))
> > +	struct mm_struct *mm = current->mm;
> > +
> > +	if (!mm)
> > +		mm = current->signal->oom_mm;
> > +	/* MMF_OOM_VICTIM not set on mm means that I am not an OOM victim. */
> > +	if (!mm || !test_bit(MMF_OOM_VICTIM, &mm->flags))
> > +		return false;
> > +	/* MMF_OOM_VICTIM can be set on mm used by the global init process. */
> > +	if (!fatal_signal_pending(current) && !(current->flags & PF_EXITING))
> >  		return false;
> >  
> >  	/*
> > @@ -3764,7 +3767,7 @@ static inline int __gfp_pfmemalloc_flags(gfp_t gfp_mask)
> >  	if (!in_interrupt()) {
> >  		if (current->flags & PF_MEMALLOC)
> >  			return ALLOC_NO_WATERMARKS;
> > -		else if (oom_reserves_allowed(current))
> > +		else if (oom_reserves_allowed())
> >  			return ALLOC_OOM;
> >  	}
> >  
> > @@ -3776,6 +3779,30 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> >  	return !!__gfp_pfmemalloc_flags(gfp_mask);
> >  }
> >  
> > +static struct page *alloc_pages_before_oomkill(gfp_t gfp_mask,
> > +					       unsigned int order,
> > +					       const struct alloc_context *ac)
> > +{
> > +	/*
> > +	 * Go through the zonelist yet one more time, keep very high watermark
> > +	 * here, this is only to catch a parallel oom killing, we must fail if
> > +	 * we're still under heavy pressure. But make sure that this reclaim
> > +	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> > +	 * allocation which will never fail due to oom_lock already held.
> > +	 * Also, make sure that OOM victims can try ALLOC_OOM watermark
> > +	 * in case they haven't tried ALLOC_OOM watermark.
> > +	 */
> > +	int alloc_flags = ALLOC_CPUSET | ALLOC_WMARK_HIGH;
> > +	int reserve_flags;
> > +
> > +	gfp_mask |= __GFP_HARDWALL;
> > +	gfp_mask &= ~__GFP_DIRECT_RECLAIM;
> > +	reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
> > +	if (reserve_flags)
> > +		alloc_flags = reserve_flags;
> > +	return get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
> > +}
> > +
> >  /*
> >   * Checks whether it makes sense to retry the reclaim to make a forward progress
> >   * for the given allocation request.
> > -- 
> > 1.8.3.1
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
