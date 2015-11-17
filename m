Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 736646B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 05:58:23 -0500 (EST)
Received: by ioc74 with SMTP id 74so14413793ioc.2
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 02:58:23 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t10si28886883igr.54.2015.11.17.02.58.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Nov 2015 02:58:22 -0800 (PST)
Subject: Re: [PATCH 2/2] mm: do not loop over ALLOC_NO_WATERMARKS without
 triggering reclaim
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
 <1447680139-16484-3-git-send-email-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <564B0841.6030409@I-love.SAKURA.ne.jp>
Date: Tue, 17 Nov 2015 19:58:09 +0900
MIME-Version: 1.0
In-Reply-To: <1447680139-16484-3-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Michal Hocko wrote:
> __alloc_pages_slowpath is looping over ALLOC_NO_WATERMARKS requests if
> __GFP_NOFAIL is requested. This is fragile because we are basically
> relying on somebody else to make the reclaim (be it the direct reclaim
> or OOM killer) for us. The caller might be holding resources (e.g.
> locks) which block other other reclaimers from making any progress for
> example. Remove the retry loop and rely on __alloc_pages_slowpath to
> invoke all allowed reclaim steps and retry logic.

This implies invoking OOM killer, doesn't it?

>   	/* Avoid recursion of direct reclaim */
> -	if (current->flags & PF_MEMALLOC)
> +	if (current->flags & PF_MEMALLOC) {
> +		/*
> +		 * __GFP_NOFAIL request from this context is rather bizarre
> +		 * because we cannot reclaim anything and only can loop waiting
> +		 * for somebody to do a work for us.
> +		 */
> +		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> +			cond_resched();
> +			goto retry;

I think that this "goto retry;" omits call to out_of_memory() which is allowed
for __GFP_NOFAIL allocations. Even if this is what you meant, current thread
can be a workqueue, which currently need a short sleep (as with
wait_iff_congested() changes), can't it?

> +		}
>   		goto nopage;
> +	}
>   
>   	/* Avoid allocations with no watermarks from looping endlessly */
>   	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> 

Well, is it cond_resched() which should include

  if (current->flags & PF_WQ_WORKER)
  	schedule_timeout(1);

than wait_iff_congested() because not all yield calls use wait_iff_congested()
and giving pending workqueue jobs a chance to be processed is anyway preferable?

  int __sched _cond_resched(void)
  {
  	if (should_resched(0)) {
  		if ((current->flags & PF_WQ_WORKER) && workqueue_has_pending_jobs())
  			schedule_timeout(1);
  		else
  			preempt_schedule_common();
  		return 1;
  	}
  	return 0;
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
