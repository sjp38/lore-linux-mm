Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 74D646B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:43:57 -0500 (EST)
Received: by wmvv187 with SMTP id v187so230903967wmv.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:43:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id av1si279098wjc.216.2015.12.01.15.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:43:56 -0800 (PST)
Date: Tue, 1 Dec 2015 15:43:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
Message-Id: <20151201154353.87e2200b5cd1a99289ce6653@linux-foundation.org>
In-Reply-To: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <arozansk@redhat.com>
Cc: linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 23 Oct 2015 17:02:30 -0400 Aristeu Rozanski <arozansk@redhat.com> wrote:

> One of the largest chunks of log messages in a OOM is from dump_stack() and in
> some cases it isn't even necessary to figure out what's going on. In
> systems with multiple tenants/containers with limited resources each
> OOMs can be way more frequent and being able to reduce the amount of log
> output for each situation is useful.
> 
> This patch adds a sysctl to allow disabling dump_stack() during an OOM while
> keeping the default to behave the same way it behaves today.

Can you get the same effect by using "dmesg -n <N>"?  Probably not, I
didn't look.

> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -115,6 +115,7 @@ static inline bool task_will_free_mem(struct task_struct *task)
>  
>  /* sysctls */
>  extern int sysctl_oom_dump_tasks;
> +extern int sysctl_oom_dump_stack;
>  extern int sysctl_oom_kill_allocating_task;
>  extern int sysctl_panic_on_oom;
>  #endif /* _INCLUDE_LINUX_OOM_H */
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index e69201d..c812523 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1176,6 +1176,13 @@ static struct ctl_table vm_table[] = {
>  		.proc_handler	= proc_dointvec,
>  	},
>  	{
> +		.procname	= "oom_dump_stack",
> +		.data		= &sysctl_oom_dump_stack,
> +		.maxlen		= sizeof(sysctl_oom_dump_stack),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
>  		.procname	= "overcommit_ratio",
>  		.data		= &sysctl_overcommit_ratio,
>  		.maxlen		= sizeof(sysctl_overcommit_ratio),
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1ecc0bc..bdbf83b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -42,6 +42,7 @@
>  int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
>  int sysctl_oom_dump_tasks = 1;
> +int sysctl_oom_dump_stack = 1;
>  
>  DEFINE_MUTEX(oom_lock);
>  
> @@ -384,7 +385,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p,
>  		current->signal->oom_score_adj);
>  	cpuset_print_task_mems_allowed(current);
>  	task_unlock(current);
> -	dump_stack();
> +	if (sysctl_oom_dump_stack)
> +		dump_stack();
>  	if (memcg)
>  		mem_cgroup_print_oom_info(memcg, p);
>  	else

The patch seems reasonable to me, but it's missing the required update
to Documentation/sysctl/vm.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
