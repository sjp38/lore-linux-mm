Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6996B20B2
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 18:11:34 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id y137-v6so17737ywy.0
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 15:11:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d83-v6sor3031163ywh.175.2018.08.21.15.11.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 15:11:33 -0700 (PDT)
MIME-Version: 1.0
References: <20180821213559.14694-1-guro@fb.com>
In-Reply-To: <20180821213559.14694-1-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 21 Aug 2018 15:10:52 -0700
Message-ID: <CALvZod4HAf+iPXQx1v+dwJkTph3ySAiYo4kn4d2jRFNQS59Tgg@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm: rework memcg kernel stack accounting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, luto@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Tue, Aug 21, 2018 at 2:36 PM Roman Gushchin <guro@fb.com> wrote:
>
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

Reviewed-by: Shakeel Butt <shakeelb@google.com>

BTW this makes a very good use-case for optimizing kmem uncharging
similar to what you did for skmem uncharging.

> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Shakeel Butt <shakeelb@google.com>
> ---
>  include/linux/memcontrol.h | 13 +++++++++-
>  kernel/fork.c              | 51 +++++++++++++++++++++++++++++++++-----
>  2 files changed, 57 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 0e6c515fb698..b12a553048e2 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1250,10 +1250,11 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
>  void memcg_kmem_put_cache(struct kmem_cache *cachep);
>  int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
>                             struct mem_cgroup *memcg);
> +
> +#ifdef CONFIG_MEMCG_KMEM
>  int memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
>  void memcg_kmem_uncharge(struct page *page, int order);
>
> -#ifdef CONFIG_MEMCG_KMEM
>  extern struct static_key_false memcg_kmem_enabled_key;
>  extern struct workqueue_struct *memcg_kmem_cache_wq;
>
> @@ -1289,6 +1290,16 @@ extern int memcg_expand_shrinker_maps(int new_id);
>  extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
>                                    int nid, int shrinker_id);
>  #else
> +
> +static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
> +{
> +       return 0;
> +}
> +
> +static inline void memcg_kmem_uncharge(struct page *page, int order)
> +{
> +}
> +
>  #define for_each_memcg_cache_index(_idx)       \
>         for (; NULL; )
>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 5ee74c113381..09b5b9a40166 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -223,9 +223,14 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>                 return s->addr;
>         }
>
> +       /*
> +        * Allocated stacks are cached and later reused by new threads,
> +        * so memcg accounting is performed manually on assigning/releasing
> +        * stacks to tasks. Drop __GFP_ACCOUNT.
> +        */
>         stack = __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
>                                      VMALLOC_START, VMALLOC_END,
> -                                    THREADINFO_GFP,
> +                                    THREADINFO_GFP & ~__GFP_ACCOUNT,
>                                      PAGE_KERNEL,
>                                      0, node, __builtin_return_address(0));
>
> @@ -248,9 +253,20 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>  static inline void free_thread_stack(struct task_struct *tsk)
>  {
>  #ifdef CONFIG_VMAP_STACK
> -       if (task_stack_vm_area(tsk)) {
> +       struct vm_struct *vm = task_stack_vm_area(tsk);
> +
> +       if (vm) {
>                 int i;
>
> +               for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
> +                       mod_memcg_page_state(vm->pages[i],
> +                                            MEMCG_KERNEL_STACK_KB,
> +                                            -(int)(PAGE_SIZE / 1024));
> +
> +                       memcg_kmem_uncharge(vm->pages[i],
> +                                           compound_order(vm->pages[i]));
> +               }
> +
>                 for (i = 0; i < NR_CACHED_STACKS; i++) {
>                         if (this_cpu_cmpxchg(cached_stacks[i],
>                                         NULL, tsk->stack_vm_area) != NULL)
> @@ -350,10 +366,6 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
>                                             NR_KERNEL_STACK_KB,
>                                             PAGE_SIZE / 1024 * account);
>                 }
> -
> -               /* All stack pages belong to the same memcg. */
> -               mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
> -                                    account * (THREAD_SIZE / 1024));
>         } else {
>                 /*
>                  * All stack pages are in the same zone and belong to the
> @@ -369,6 +381,30 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
>         }
>  }
>
> +static int memcg_charge_kernel_stack(struct task_struct *tsk)
> +{
> +#ifdef CONFIG_VMAP_STACK
> +       struct vm_struct *vm = task_stack_vm_area(tsk);
> +       int ret;
> +
> +       if (vm) {
> +               int i;
> +
> +               for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
> +                       ret = memcg_kmem_charge(vm->pages[i], GFP_KERNEL,
> +                                               compound_order(vm->pages[i]));
> +                       if (ret)
> +                               return ret;
> +
> +                       mod_memcg_page_state(vm->pages[i],
> +                                            MEMCG_KERNEL_STACK_KB,
> +                                            PAGE_SIZE / 1024);
> +               }
> +       }
> +#endif
> +       return 0;
> +}
> +
>  static void release_task_stack(struct task_struct *tsk)
>  {
>         if (WARN_ON(tsk->state != TASK_DEAD))
> @@ -807,6 +843,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
>         if (!stack)
>                 goto free_tsk;
>
> +       if (memcg_charge_kernel_stack(tsk))
> +               goto free_stack;
> +
>         stack_vm_area = task_stack_vm_area(tsk);
>
>         err = arch_dup_task_struct(tsk, orig);
> --
> 2.17.1
>
