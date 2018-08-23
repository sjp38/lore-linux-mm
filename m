Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 001D26B2AF7
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 12:24:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g5-v6so2529944edp.1
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:24:09 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p1-v6si10230edq.94.2018.08.23.09.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 09:24:08 -0700 (PDT)
Date: Thu, 23 Aug 2018 09:23:50 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 1/3] mm: rework memcg kernel stack accounting
Message-ID: <20180823162347.GA22650@tower.DHCP.thefacebook.com>
References: <20180821213559.14694-1-guro@fb.com>
 <20180822141213.GO29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180822141213.GO29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>, Shakeel Butt <shakeelb@google.com>

On Wed, Aug 22, 2018 at 04:12:13PM +0200, Michal Hocko wrote:
> On Tue 21-08-18 14:35:57, Roman Gushchin wrote:
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
> > 
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Andy Lutomirski <luto@kernel.org>
> > Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Shakeel Butt <shakeelb@google.com>
> 
> Looks good to me. Two nits below.
> 
> I am not sure stable tree backport is really needed but it would be nice
> to put
> Fixes: ac496bf48d97 ("fork: Optimize task creation by caching two thread stacks per CPU if CONFIG_VMAP_STACK=y")
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Will add, thanks!

> 
> > @@ -248,9 +253,20 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
> >  static inline void free_thread_stack(struct task_struct *tsk)
> >  {
> >  #ifdef CONFIG_VMAP_STACK
> > -	if (task_stack_vm_area(tsk)) {
> > +	struct vm_struct *vm = task_stack_vm_area(tsk);
> > +
> > +	if (vm) {
> >  		int i;
> >  
> > +		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
> > +			mod_memcg_page_state(vm->pages[i],
> > +					     MEMCG_KERNEL_STACK_KB,
> > +					     -(int)(PAGE_SIZE / 1024));
> > +
> > +			memcg_kmem_uncharge(vm->pages[i],
> > +					    compound_order(vm->pages[i]));
> 
> when do we have order > 0 here?

I guess, it's not possible, but hard-coded 1 looked a bit crappy.
Do you think it's better?

> Also I was wondering how come this
> doesn't blow up on partially charged stacks but both
> mod_memcg_page_state and memcg_kmem_uncharge check for page->mem_cgroup
> so this is safe. Maybe a comment would save people from scratching their
> heads.

Ok, will add.

Thank you!
