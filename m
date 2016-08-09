Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDEC06B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 05:03:55 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j124so27023023ith.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 02:03:55 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id f7si781217otb.123.2016.08.09.02.02.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 02:03:55 -0700 (PDT)
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability and
 OOM
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
From: Zefan Li <lizefan@huawei.com>
Message-ID: <57A99BCB.6070905@huawei.com>
Date: Tue, 9 Aug 2016 17:00:59 +0800
MIME-Version: 1.0
In-Reply-To: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> This almost stalls the system, this patch moves the threadgroup_change_begin
> from before cgroup_fork() to just before cgroup_canfork(). Ideally we shouldn't
> have to worry about threadgroup changes till the task is actually added to
> the threadgroup. This avoids having to call reclaim with cgroup_threadgroup_rwsem
> held.
> 
> There are other theoretical issues with this semaphore
> 
> systemd can do
> 
> 1. cgroup_mutex (cgroup_kn_lock_live)
> 2. cgroup_threadgroup_rwsem (W) (__cgroup_procs_write)
> 
> and other threads can go
> 
> 1. cgroup_threadgroup_rwsem (R) (copy_process)
> 2. mem_cgroup_iter (as a part of reclaim) (cgroup_mutex -- rcu lock or cgroup_mutex)
> 
> However, I've not examined them in too much detail or looked at lockdep
> wait chains for those paths.
> 
> I am sure there is a good reason for placing cgroup_threadgroup_rwsem
> where it is today and I might be missing something. I am also surprised
> no-one else has run into it so far.
> 
> Comments?
> 

We used to use cgroup_threadgroup_rwsem for syncronization between threads
in the same threadgroup, but now it has evolved to ensure atomic operations
across multi processes.

For example, I'm trying to fix a race. See https://lkml.org/lkml/2016/8/8/900

And the fix kind of relies on the fact that cgroup_post_fork() is placed
inside the read section of cgroup_threadgroup_rwsem, so that cpuset_fork()
won't race with cgroup migration.

> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> 
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>
> ---
>  kernel/fork.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 5c2c355..0474fa8 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1406,7 +1406,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	p->real_start_time = ktime_get_boot_ns();
>  	p->io_context = NULL;
>  	p->audit_context = NULL;
> -	threadgroup_change_begin(current);
>  	cgroup_fork(p);
>  #ifdef CONFIG_NUMA
>  	p->mempolicy = mpol_dup(p->mempolicy);
> @@ -1558,6 +1557,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	INIT_LIST_HEAD(&p->thread_group);
>  	p->task_works = NULL;
>  
> +	threadgroup_change_begin(current);
>  	/*
>  	 * Ensure that the cgroup subsystem policies allow the new process to be
>  	 * forked. It should be noted the the new process's css_set can be changed
> @@ -1658,6 +1658,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  bad_fork_cancel_cgroup:
>  	cgroup_cancel_fork(p);
>  bad_fork_free_pid:
> +	threadgroup_change_end(current);
>  	if (pid != &init_struct_pid)
>  		free_pid(pid);
>  bad_fork_cleanup_thread:
> @@ -1690,7 +1691,6 @@ bad_fork_cleanup_policy:
>  	mpol_put(p->mempolicy);
>  bad_fork_cleanup_threadgroup_lock:
>  #endif
> -	threadgroup_change_end(current);
>  	delayacct_tsk_free(p);
>  bad_fork_cleanup_count:
>  	atomic_dec(&p->cred->user->processes);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
