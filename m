Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B03F56B02F4
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:01:25 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x3so15742977oia.8
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:01:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z8si295598oig.314.2017.07.27.07.01.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 07:01:21 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170727090357.3205-1-mhocko@kernel.org>
	<20170727090357.3205-3-mhocko@kernel.org>
In-Reply-To: <20170727090357.3205-3-mhocko@kernel.org>
Message-Id: <201707272301.EII82876.tOOJOFLMHFQSFV@I-love.SAKURA.ne.jp>
Date: Thu, 27 Jul 2017 23:01:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 544d47e5cbbd..86a48affb938 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1896,7 +1896,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * bypass the last charges so that they can exit quickly and
>  	 * free their memory.
>  	 */
> -	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
> +	if (unlikely(tsk_is_oom_victim(current) ||
>  		     fatal_signal_pending(current) ||
>  		     current->flags & PF_EXITING))
>  		goto force;

Did we check http://lkml.kernel.org/r/20160909140508.GO4844@dhcp22.suse.cz ?

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index c9f3569a76c7..65cc2f9aaa05 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -483,7 +483,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	 *				[...]
>  	 *				out_of_memory
>  	 *				  select_bad_process
> -	 *				    # no TIF_MEMDIE task selects new victim
> +	 *				    # no TIF_MEMDIE, selects new victim
>  	 *  unmap_page_range # frees some memory
>  	 */
>  	mutex_lock(&oom_lock);

This comment is wrong. No MMF_OOM_SKIP mm selects new victim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
