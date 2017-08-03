Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 960E46B0647
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 20:04:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g32so719752wrd.8
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 17:04:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p15si327899wma.123.2017.08.02.17.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 17:04:11 -0700 (PDT)
Date: Wed, 2 Aug 2017 17:04:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, oom: task_will_free_mem(current) should ignore
 MMF_OOM_SKIP for once.
Message-Id: <20170802170409.caaaab2a866cf8ac210291cc@linux-foundation.org>
In-Reply-To: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Manish Jaggi <mjaggi@caviumnetworks.com>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@virtuozzo.com>

On Thu,  3 Aug 2017 08:55:04 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> count causes random kernel panics when an OOM victim which consumed memory
> in a way the OOM reaper does not help was selected by the OOM killer.
> 
> ...
>
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -652,6 +652,7 @@ struct task_struct {
>  	/* disallow userland-initiated cgroup migration */
>  	unsigned			no_cgroup_migration:1;
>  #endif
> +	unsigned			oom_kill_free_check_raced:1;
>  
>  	unsigned long			atomic_flags; /* Flags requiring atomic access. */
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9e8b4f0..a1ae78d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -780,11 +780,19 @@ static bool task_will_free_mem(struct task_struct *task)
>  		return false;
>  
>  	/*
> -	 * This task has already been drained by the oom reaper so there are
> -	 * only small chances it will free some more
> +	 * It is possible that current thread fails to try allocation from
> +	 * memory reserves if the OOM reaper set MMF_OOM_SKIP on this mm before
> +	 * current thread calls out_of_memory() in order to get TIF_MEMDIE.
> +	 * In that case, allow current thread to try TIF_MEMDIE allocation
> +	 * before start selecting next OOM victims.
>  	 */
> -	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> +	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
> +		if (task == current && !task->oom_kill_free_check_raced) {
> +			task->oom_kill_free_check_raced = true;

OK, caller's task_lock() prevents races here.

nit: task->oom_kill_free_check_raced is `unsigned', so " = 1" would be
more truthful here...


> +			return true;
> +		}
>  		return false;
> +	}
>  
>  	if (atomic_read(&mm->mm_users) <= 1)
>  		return true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
