Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1596B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 14:09:46 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id j12so34647668ywb.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 11:09:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i129si21737423qkc.23.2016.08.09.11.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 11:09:45 -0700 (PDT)
Date: Tue, 9 Aug 2016 20:09:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability
	and OOM
Message-ID: <20160809180936.GE13840@redhat.com>
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/09, Balbir Singh wrote:
>
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

I can't really review this change... but it looks good to me.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
