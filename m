Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D18876B0003
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 03:11:00 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i26-v6so261899edr.4
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 00:11:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n38-v6si683918edn.443.2018.08.15.00.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 00:10:59 -0700 (PDT)
Date: Wed, 15 Aug 2018 09:10:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm: rework memcg kernel stack accounting
Message-ID: <20180815071058.GL32645@dhcp22.suse.cz>
References: <20180815003620.15678-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815003620.15678-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Tue 14-08-18 17:36:19, Roman Gushchin wrote:
> If CONFIG_VMAP_STACK is set, kernel stacks are allocated
> using __vmalloc_node_range() with __GFP_ACCOUNT. So kernel
> stack pages are charged against corresponding memory cgroups
> on allocation and uncharged on releasing them.
> 
> The problem is that we do cache kernel stacks in small
> per-cpu caches and do reuse them for new tasks, which can
> belong to different memory cgroups.
> 
> Each stack page still holds a reference to the original cgroup,
> so the cgroup can't be released until the vmap area is released.
> 
> To make this happen we need more than two subsequent exits
> without forks in between on the current cpu, which makes it
> very unlikely to happen. As a result, I saw a significant number
> of dying cgroups (in theory, up to 2 * number_of_cpu +
> number_of_tasks), which can't be released even by significant
> memory pressure.
> 
> As a cgroup structure can take a significant amount of memory
> (first of all, per-cpu data like memcg statistics), it leads
> to a noticeable waste of memory.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Fixes: ac496bf48d97 ("fork: Optimize task creation by caching two thread stacks per CPU if CONFIG_VMAP_STACK=y")
AFAICS

> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>

Yes this is the right way to do accounting here.
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  kernel/fork.c | 44 ++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 38 insertions(+), 6 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 69b6fea5a181..91872b2b37bd 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -224,9 +224,14 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>  		return s->addr;
>  	}
>  
> +	/*
> +	 * Allocated stacks are cached and later reused by new threads,
> +	 * so memcg accounting is performed manually on assigning/releasing
> +	 * stacks to tasks. Drop __GFP_ACCOUNT.
> +	 */
>  	stack = __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
>  				     VMALLOC_START, VMALLOC_END,
> -				     THREADINFO_GFP,
> +				     THREADINFO_GFP & ~__GFP_ACCOUNT,
>  				     PAGE_KERNEL,
>  				     0, node, __builtin_return_address(0));
>  
> @@ -246,12 +251,41 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>  #endif
>  }
>  
> +static void memcg_charge_kernel_stack(struct task_struct *tsk)
> +{
> +#ifdef CONFIG_VMAP_STACK
> +	struct vm_struct *vm = task_stack_vm_area(tsk);
> +
> +	if (vm) {
> +		int i;
> +
> +		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++)
> +			memcg_kmem_charge(vm->pages[i], __GFP_NOFAIL,
> +					  compound_order(vm->pages[i]));
> +
> +		/* All stack pages belong to the same memcg. */
> +		mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
> +				     THREAD_SIZE / 1024);
> +	}
> +#endif
> +}
> +
>  static inline void free_thread_stack(struct task_struct *tsk)
>  {
>  #ifdef CONFIG_VMAP_STACK
> -	if (task_stack_vm_area(tsk)) {
> +	struct vm_struct *vm = task_stack_vm_area(tsk);
> +
> +	if (vm) {
>  		int i;
>  
> +		/* All stack pages belong to the same memcg. */
> +		mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
> +				     -(int)(THREAD_SIZE / 1024));
> +
> +		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++)
> +			memcg_kmem_uncharge(vm->pages[i],
> +					  compound_order(vm->pages[i]));
> +
>  		for (i = 0; i < NR_CACHED_STACKS; i++) {
>  			if (this_cpu_cmpxchg(cached_stacks[i],
>  					NULL, tsk->stack_vm_area) != NULL)
> @@ -352,10 +386,6 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
>  					    NR_KERNEL_STACK_KB,
>  					    PAGE_SIZE / 1024 * account);
>  		}
> -
> -		/* All stack pages belong to the same memcg. */
> -		mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
> -				     account * (THREAD_SIZE / 1024));
>  	} else {
>  		/*
>  		 * All stack pages are in the same zone and belong to the
> @@ -809,6 +839,8 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
>  	if (!stack)
>  		goto free_tsk;
>  
> +	memcg_charge_kernel_stack(tsk);
> +
>  	stack_vm_area = task_stack_vm_area(tsk);
>  
>  	err = arch_dup_task_struct(tsk, orig);
> -- 
> 2.14.4

-- 
Michal Hocko
SUSE Labs
