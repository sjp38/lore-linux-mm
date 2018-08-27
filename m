Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C78156B41FE
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 17:01:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h65-v6so186340pfk.18
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 14:01:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p126-v6si296659pfb.77.2018.08.27.14.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 14:01:45 -0700 (PDT)
Date: Mon, 27 Aug 2018 14:01:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/3] mm: rework memcg kernel stack accounting
Message-Id: <20180827140143.98b65bc7cb32f50245eb9114@linux-foundation.org>
In-Reply-To: <20180827162621.30187-1-guro@fb.com>
References: <20180827162621.30187-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Mon, 27 Aug 2018 09:26:19 -0700 Roman Gushchin <guro@fb.com> wrote:

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

OK, but this doesn't describe how the patch addresses this issue?

>
> ...
>
> @@ -371,6 +382,35 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
>  	}
>  }
>  
> +static int memcg_charge_kernel_stack(struct task_struct *tsk)
> +{
> +#ifdef CONFIG_VMAP_STACK
> +	struct vm_struct *vm = task_stack_vm_area(tsk);
> +	int ret;
> +
> +	if (vm) {
> +		int i;
> +
> +		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {

Can we ever have THREAD_SIZE < PAGE_SIZE?  64k pages?

> +			/*
> +			 * If memcg_kmem_charge() fails, page->mem_cgroup
> +			 * pointer is NULL, and both memcg_kmem_uncharge()
> +			 * and mod_memcg_page_state() in free_thread_stack()
> +			 * will ignore this page. So it's safe.
> +			 */
> +			ret = memcg_kmem_charge(vm->pages[i], GFP_KERNEL, 0);
> +			if (ret)
> +				return ret;
> +
> +			mod_memcg_page_state(vm->pages[i],
> +					     MEMCG_KERNEL_STACK_KB,
> +					     PAGE_SIZE / 1024);
> +		}
> +	}
> +#endif
> +	return 0;
> +}
>
> ...
>
