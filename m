Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l8PI0cGO030965
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 19:00:39 +0100
Received: from mu-out-0910.google.com (muei10.prod.google.com [10.102.160.10])
	by zps35.corp.google.com with ESMTP id l8PI0SK3024798
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 11:00:37 -0700
Received: by mu-out-0910.google.com with SMTP id i10so3320678mue
        for <linux-mm@kvack.org>; Tue, 25 Sep 2007 11:00:37 -0700 (PDT)
Message-ID: <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
Date: Tue, 25 Sep 2007 11:00:36 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
	 <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It would be nice to be able to do the same thing for cpuset
membership, in the event that cpusets are active and the memory
controller is not.

Paul

On 9/25/07, David Rientjes <rientjes@google.com> wrote:
> If an OOM was triggered as a result a cgroup's memory controller, the
> tasklist shall be filtered to exclude tasks that are not a member of the
> same group.
>
> Creates a helper function to return non-zero if a task is a member of a
> mem_cgroup:
>
>         int task_in_mem_cgroup(const struct task_struct *task,
>                                const struct mem_cgroup *mem);
>
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/memcontrol.h |   16 ++++++++++++++++
>  mm/oom_kill.c              |   25 ++++++++++++++-----------
>  2 files changed, 30 insertions(+), 11 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -52,6 +52,16 @@ static inline void mem_cgroup_uncharge_page(struct page *page)
>         mem_cgroup_uncharge(page_get_page_cgroup(page));
>  }
>
> +/*
> + * Returns non-zero if the task is in the cgroup; otherwise returns zero.
> + * Call with task_lock(task) held.
> + */
> +static inline int task_in_mem_cgroup(const struct task_struct *task,
> +                                    const struct mem_cgroup *mem)
> +{
> +       return mem && task->mm && mm_cgroup(task->mm) == mem;
> +}
> +
>  #else /* CONFIG_CGROUP_MEM_CONT */
>  static inline void mm_init_cgroup(struct mm_struct *mm,
>                                         struct task_struct *p)
> @@ -103,6 +113,12 @@ static inline struct mem_cgroup *mm_cgroup(struct mm_struct *mm)
>         return NULL;
>  }
>
> +static inline int task_in_mem_cgroup(const struct task_struct *task,
> +                                    const struct mem_cgroup *mem)
> +{
> +       return 1;
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -65,13 +65,10 @@ unsigned long badness(struct task_struct *p, unsigned long uptime,
>                 task_unlock(p);
>                 return 0;
>         }
> -
> -#ifdef CONFIG_CGROUP_MEM_CONT
> -       if (mem != NULL && mm->mem_cgroup != mem) {
> +       if (!task_in_mem_cgroup(p, mem)) {
>                 task_unlock(p);
>                 return 0;
>         }
> -#endif
>
>         /*
>          * The memory size of the process is the basis for the badness.
> @@ -274,9 +271,12 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>   * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
>   * score, and name.
>   *
> + * If the actual is non-NULL, only tasks that are a member of the mem_cgroup are
> + * shown.
> + *
>   * Call with tasklist_lock read-locked.
>   */
> -static void dump_tasks(void)
> +static void dump_tasks(const struct mem_cgroup *mem)
>  {
>         struct task_struct *g, *p;
>
> @@ -291,6 +291,8 @@ static void dump_tasks(void)
>                         continue;
>
>                 task_lock(p);
> +               if (!task_in_mem_cgroup(p, mem))
> +                       continue;
>                 printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
>                        p->pid, p->uid, p->tgid, p->mm->total_vm,
>                        get_mm_rss(p->mm), (int)task_cpu(p), p->oomkilladj,
> @@ -376,7 +378,8 @@ static int oom_kill_task(struct task_struct *p)
>  }
>
>  static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> -                           unsigned long points, const char *message)
> +                           unsigned long points, struct mem_cgroup *mem,
> +                           const char *message)
>  {
>         struct task_struct *c;
>
> @@ -387,7 +390,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>                 dump_stack();
>                 show_mem();
>                 if (sysctl_oom_dump_tasks)
> -                       dump_tasks();
> +                       dump_tasks(mem);
>         }
>
>         /*
> @@ -428,7 +431,7 @@ retry:
>         if (!p)
>                 p = current;
>
> -       if (oom_kill_process(p, gfp_mask, 0, points,
> +       if (oom_kill_process(p, gfp_mask, 0, points, mem,
>                                 "Memory cgroup out of memory"))
>                 goto retry;
>  out:
> @@ -534,7 +537,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
>
>         switch (constraint) {
>         case CONSTRAINT_MEMORY_POLICY:
> -               oom_kill_process(current, gfp_mask, order, points,
> +               oom_kill_process(current, gfp_mask, order, points, NULL,
>                                 "No available memory (MPOL_BIND)");
>                 break;
>
> @@ -544,7 +547,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
>                 /* Fall-through */
>         case CONSTRAINT_CPUSET:
>                 if (sysctl_oom_kill_allocating_task) {
> -                       oom_kill_process(current, gfp_mask, order, points,
> +                       oom_kill_process(current, gfp_mask, order, points, NULL,
>                                         "Out of memory (oom_kill_allocating_task)");
>                         break;
>                 }
> @@ -564,7 +567,7 @@ retry:
>                         panic("Out of memory and no killable processes...\n");
>                 }
>
> -               if (oom_kill_process(p, points, gfp_mask, order,
> +               if (oom_kill_process(p, points, gfp_mask, order, NULL,
>                                      "Out of memory"))
>                         goto retry;
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
