Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3AB46B42FF
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 19:19:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id q29-v6so15593edd.0
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 16:19:34 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t26-v6si464379eda.7.2018.08.27.16.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 16:19:33 -0700 (PDT)
Date: Mon, 27 Aug 2018 16:19:12 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 1/3] mm: rework memcg kernel stack accounting
Message-ID: <20180827231909.GA19820@tower.DHCP.thefacebook.com>
References: <20180827162621.30187-1-guro@fb.com>
 <20180827140143.98b65bc7cb32f50245eb9114@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180827140143.98b65bc7cb32f50245eb9114@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Mon, Aug 27, 2018 at 02:01:43PM -0700, Andrew Morton wrote:
> On Mon, 27 Aug 2018 09:26:19 -0700 Roman Gushchin <guro@fb.com> wrote:
> 
> > If CONFIG_VMAP_STACK is set, kernel stacks are allocated
> > using __vmalloc_node_range() with __GFP_ACCOUNT. So kernel
> > stack pages are charged against corresponding memory cgroups
> > on allocation and uncharged on releasing them.
> > 
> > The problem is that we do cache kernel stacks in small
> > per-cpu caches and do reuse them for new tasks, which can
> > belong to different memory cgroups.
> > 
> > Each stack page still holds a reference to the original cgroup,
> > so the cgroup can't be released until the vmap area is released.
> > 
> > To make this happen we need more than two subsequent exits
> > without forks in between on the current cpu, which makes it
> > very unlikely to happen. As a result, I saw a significant number
> > of dying cgroups (in theory, up to 2 * number_of_cpu +
> > number_of_tasks), which can't be released even by significant
> > memory pressure.
> > 
> > As a cgroup structure can take a significant amount of memory
> > (first of all, per-cpu data like memcg statistics), it leads
> > to a noticeable waste of memory.
> 
> OK, but this doesn't describe how the patch addresses this issue?

Sorry, missed this part. Let's add the following paragraph to the
commit message (the full updated patch is below):

To address the issue, let's charge thread stacks on assigning
them to tasks, and uncharge on releasing them and putting into
the per-cpu cache. So, cached stacks will not be assigned to
any memcg and will not hold any memcg reference.


> 
> >
> > ...
> >
> > @@ -371,6 +382,35 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
> >  	}
> >  }
> >  
> > +static int memcg_charge_kernel_stack(struct task_struct *tsk)
> > +{
> > +#ifdef CONFIG_VMAP_STACK
> > +	struct vm_struct *vm = task_stack_vm_area(tsk);
> > +	int ret;
> > +
> > +	if (vm) {
> > +		int i;
> > +
> > +		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
> 
> Can we ever have THREAD_SIZE < PAGE_SIZE?  64k pages?

Hm, good question!
We can, but I doubt that anyone using 64k pages AND CONFIG_VMAP_STACK,
and I *suspect* that it will trigger the BUG_ON() in account_kernel_stack():

static void account_kernel_stack(struct task_struct *tsk, int account) {
	...

	if (vm) {
		...

		BUG_ON(vm->nr_pages != THREAD_SIZE / PAGE_SIZE);

But I don't see anything that makes such a config illegitimate.
Does it makes any sense to use vmap if THREAD_SIZE < PAGE_SIZE?

> 
> > +			/*
> > +			 * If memcg_kmem_charge() fails, page->mem_cgroup
> > +			 * pointer is NULL, and both memcg_kmem_uncharge()
> > +			 * and mod_memcg_page_state() in free_thread_stack()
> > +			 * will ignore this page. So it's safe.
> > +			 */
> > +			ret = memcg_kmem_charge(vm->pages[i], GFP_KERNEL, 0);
> > +			if (ret)
> > +				return ret;
> > +
> > +			mod_memcg_page_state(vm->pages[i],
> > +					     MEMCG_KERNEL_STACK_KB,
> > +					     PAGE_SIZE / 1024);
> > +		}
> > +	}
> > +#endif
> > +	return 0;
> > +}
> >
> > ...
> >

Thanks!


--
