Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9D43600803
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:13:12 -0400 (EDT)
Date: Mon, 23 Aug 2010 16:13:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/3 v3] oom: add per-mm oom disable count
Message-Id: <20100823161302.e4378ca0.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 15:41:48 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> From: Ying Han <yinghan@google.com>
> 
> It's pointless to kill a task if another thread sharing its mm cannot be
> killed to allow future memory freeing.  A subsequent patch will prevent
> kills in such cases, but first it's necessary to have a way to flag a
> task that shares memory with an OOM_DISABLE task that doesn't incur an
> additional tasklist scan, which would make select_bad_process() an O(n^2)
> function.
> 
> This patch adds an atomic counter to struct mm_struct that follows how
> many threads attached to it have an oom_score_adj of OOM_SCORE_ADJ_MIN.
> They cannot be killed by the kernel, so their memory cannot be freed in
> oom conditions.
> 
> This only requires task_lock() on the task that we're operating on, it
> does not require mm->mmap_sem since task_lock() pins the mm and the
> operation is atomic.
> 
>
> ...
>
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1047,6 +1047,21 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
>  		return -EACCES;
>  	}
>  
> +	task_lock(task);
> +	if (!task->mm) {
> +		task_unlock(task);
> +		unlock_task_sighand(task, &flags);
> +		put_task_struct(task);
> +		return -EINVAL;
> +	}
> +
> +	if (oom_adjust != task->signal->oom_adj) {
> +		if (oom_adjust == OOM_DISABLE)
> +			atomic_inc(&task->mm->oom_disable_count);
> +		if (task->signal->oom_adj == OOM_DISABLE)
> +			atomic_dec(&task->mm->oom_disable_count);
> +	}

scary function.  Wanna try converting oom_adjust_write() to the
single-exit-with-goto model sometime, see if the result looks more
maintainable?

>
> ...
>
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -65,6 +65,7 @@
>  #include <linux/perf_event.h>
>  #include <linux/posix-timers.h>
>  #include <linux/user-return-notifier.h>
> +#include <linux/oom.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/pgalloc.h>
> @@ -485,6 +486,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
>  	mm->cached_hole_size = ~0UL;
>  	mm_init_aio(mm);
>  	mm_init_owner(mm, p);
> +	atomic_set(&mm->oom_disable_count, 0);

So in fork() we zap this if !CLONE_VM?  Was the CLONE_VM case tested
nicely?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
