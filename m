Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A76C96B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 10:17:37 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so30486832pab.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 07:17:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r4si3938554pdf.25.2015.03.25.07.17.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 07:17:36 -0700 (PDT)
Subject: Re: [patch 08/12] mm: page_alloc: wait for OOM killer progress before retrying
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
	<1427264236-17249-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1427264236-17249-9-git-send-email-hannes@cmpxchg.org>
Message-Id: <201503252315.FBJ09847.FSOtOJQFOMLFVH@I-love.SAKURA.ne.jp>
Date: Wed, 25 Mar 2015 23:15:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, ying.huang@intel.com, aarcange@redhat.com, david@fromorbit.com, mhocko@suse.cz, tytso@mit.edu

Johannes Weiner wrote:
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5cfda39b3268..e066ac7353a4 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -711,12 +711,15 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		killed = 1;
>  	}
>  out:
> +	if (test_thread_flag(TIF_MEMDIE))
> +		return true;
>  	/*
> -	 * Give the killed threads a good chance of exiting before trying to
> -	 * allocate memory again.
> +	 * Wait for any outstanding OOM victims to die.  In rare cases
> +	 * victims can get stuck behind the allocating tasks, so the
> +	 * wait needs to be bounded.  It's crude alright, but cheaper
> +	 * than keeping a global dependency tree between all tasks.
>  	 */
> -	if (killed)
> -		schedule_timeout_killable(1);
> +	wait_event_timeout(oom_victims_wait, !atomic_read(&oom_victims), HZ);
>  
>  	return true;
>  }

out_of_memory() returning true with bounded wait effectively means that
wait forever without choosing subsequent OOM victims when first OOM victim
failed to die. The system will lock up, won't it?

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c1224ba45548..9ce9c4c083a0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2330,30 +2330,29 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
>  }
>  
>  static inline struct page *
> -__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> +__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  	const struct alloc_context *ac, unsigned long *did_some_progress)
>  {
> -	struct page *page;
> +	struct page *page = NULL;
>  
>  	*did_some_progress = 0;
>  
>  	/*
> -	 * Acquire the oom lock.  If that fails, somebody else is
> -	 * making progress for us.
> +	 * This allocating task can become the OOM victim itself at
> +	 * any point before acquiring the lock.  In that case, exit
> +	 * quickly and don't block on the lock held by another task
> +	 * waiting for us to exit.
>  	 */
> -	if (!mutex_trylock(&oom_lock)) {
> -		*did_some_progress = 1;
> -		schedule_timeout_uninterruptible(1);
> -		return NULL;
> +	if (test_thread_flag(TIF_MEMDIE) || mutex_lock_killable(&oom_lock)) {
> +		alloc_flags |= ALLOC_NO_WATERMARKS;
> +		goto alloc;
>  	}

When a thread group has 1000 threads and most of them are doing memory allocation
request, all of them will get fatal_signal_pending() == true when one of them are
chosen by OOM killer.
This code will allow most of them to access memory reserves, won't it?

> @@ -2383,12 +2382,20 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		if (gfp_mask & __GFP_THISNODE)
>  			goto out;
>  	}
> -	/* Exhausted what can be done so it's blamo time */
> -	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
> -			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> +
> +	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)) {
>  		*did_some_progress = 1;
> +	} else {
> +		/* Oops, these shouldn't happen with the OOM killer disabled */
> +		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> +			*did_some_progress = 1;
> +	}

I think GFP_NOFAIL allocations need to involve OOM killer than
pretending as if forward progress is made. If all of in-flight
allocation requests are GFP_NOFAIL, the system will lock up.

After all, if we wait for OOM killer progress before retrying, I think
we should involve OOM killer after some bounded timeout regardless of
gfp flags, and let OOM killer kill more threads after another bounded
timeout. Otherwise, the corner cases will lock up the system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
