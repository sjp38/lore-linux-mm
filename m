Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 18F2E6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 14:44:19 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so1537396pdj.31
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:44:18 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so1528653pdj.6
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:44:15 -0700 (PDT)
Date: Thu, 26 Sep 2013 11:44:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V1] oom: avoid selecting threads sharing mm with init
In-Reply-To: <1380182957-3231-1-git-send-email-ming.liu@windriver.com>
Message-ID: <alpine.DEB.2.02.1309261143160.10904@chino.kir.corp.google.com>
References: <1380182957-3231-1-git-send-email-ming.liu@windriver.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Liu <ming.liu@windriver.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 26 Sep 2013, Ming Liu wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 314e9d2..7e50a95 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -113,11 +113,22 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
>  static bool oom_unkillable_task(struct task_struct *p,
>  		const struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
> +	struct task_struct *init_tsk;
> +
>  	if (is_global_init(p))
>  		return true;
>  	if (p->flags & PF_KTHREAD)
>  		return true;
>  
> +	/* It won't help free memory if p is sharing mm with init */
> +	rcu_read_lock();
> +	init_tsk = find_task_by_pid_ns(1, &init_pid_ns);
> +	if(p->mm == init_tsk->mm) {
> +		rcu_read_unlock();
> +		return true;
> +	}
> +	rcu_read_unlock();
> +
>  	/* When mem_cgroup_out_of_memory() and p is not member of the group */
>  	if (memcg && !task_in_mem_cgroup(p, memcg))
>  		return true;

You're aware of init_mm?

Can you post the kernel log when one of these "extreme cases" happens?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
