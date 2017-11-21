Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8C06B0273
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 23:56:33 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id p33so5748062uag.4
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 20:56:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor3763923uae.91.2017.11.20.20.56.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 20:56:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171121044947.18479-1-slandden@gmail.com>
References: <20171103063544.13383-1-slandden@gmail.com> <20171121044947.18479-1-slandden@gmail.com>
From: Shawn Landden <slandden@gmail.com>
Date: Mon, 20 Nov 2017 20:56:30 -0800
Message-ID: <CA+49okpmQHvO6kxigj7dVaZSFzAn9ZDCayLy+NCrN-y6-CAuEw@mail.gmail.com>
Subject: Re: [RFC v3] It is common for services to be stateless around their
 main event loop. If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it
 signals to the kernel that epoll_wait() and friends may not complete, and the
 kernel may send SIGKILL if resources get tight.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, willy@infradead.org

On Mon, Nov 20, 2017 at 8:49 PM, Shawn Landden <slandden@gmail.com> wrote:
> See my systemd patch: https://github.com/shawnl/systemd/tree/prctl
>
> Android uses this memory model for all programs, and having it in the
> kernel will enable integration with the page cache (not in this
> series).
>
> v2
> switch to prctl, memcg support
>
> v3
> use <linux/wait.h>
> put OOM after constraint checking
> ---
>  fs/eventpoll.c             | 27 ++++++++++++++++++++
>  fs/proc/array.c            |  7 ++++++
>  include/linux/memcontrol.h |  3 +++
>  include/linux/oom.h        |  4 +++
>  include/linux/sched.h      |  1 +
>  include/uapi/linux/prctl.h |  4 +++
>  kernel/cgroup/cgroup.c     | 61 ++++++++++++++++++++++++++++++++++++++++++++++
>  kernel/exit.c              |  1 +
>  kernel/sys.c               |  9 +++++++
>  mm/memcontrol.c            |  2 ++
>  mm/oom_kill.c              | 47 +++++++++++++++++++++++++++++++++++
>  11 files changed, 166 insertions(+)
>
> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> index 2fabd19cdeea..745662f9a7e1 100644
> --- a/fs/eventpoll.c
> +++ b/fs/eventpoll.c
> @@ -43,6 +43,8 @@
>  #include <linux/compat.h>
>  #include <linux/rculist.h>
>  #include <net/busy_poll.h>
> +#include <linux/memcontrol.h>
> +#include <linux/oom.h>
>
>  /*
>   * LOCKING:
> @@ -1761,6 +1763,19 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
>         u64 slack = 0;
>         wait_queue_entry_t wait;
>         ktime_t expires, *to = NULL;
> +       DEFINE_WAIT_FUNC(oom_target_wait, oom_target_callback);
> +       DEFINE_WAIT_FUNC(oom_target_wait_mcg, oom_target_callback);
> +
> +       if (current->oom_target) {
> +#ifdef CONFIG_MEMCG
> +               struct mem_cgroup *mcg;
> +
> +               mcg = mem_cgroup_from_task(current);
> +               if (mcg)
> +                       add_wait_queue(&mcg->oom_target, &oom_target_wait_mcg);
> +#endif
> +               add_wait_queue(oom_target_get_wait(), &oom_target_wait);
> +       }
>
>         if (timeout > 0) {
>                 struct timespec64 end_time = ep_set_mstimeout(timeout);
> @@ -1850,6 +1865,18 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
>             !(res = ep_send_events(ep, events, maxevents)) && !timed_out)
>                 goto fetch_events;
>
> +       if (current->oom_target) {
> +#ifdef CONFIG_MEMCG
> +               struct mem_cgroup *mcg;
> +
> +               mcg = mem_cgroup_from_task(current);
> +               if (mcg)
> +                       remove_wait_queue(&mcg->oom_target,
> +                                       &oom_target_wait_mcg);
> +#endif
> +               remove_wait_queue(oom_target_get_wait(), &oom_target_wait);
> +       }
> +
>         return res;
>  }
>
> diff --git a/fs/proc/array.c b/fs/proc/array.c
> index 9390032a11e1..1954ae87cb88 100644
> --- a/fs/proc/array.c
> +++ b/fs/proc/array.c
> @@ -350,6 +350,12 @@ static inline void task_seccomp(struct seq_file *m, struct task_struct *p)
>         seq_putc(m, '\n');
>  }
>
> +static inline void task_idle(struct seq_file *m, struct task_struct *p)
> +{
> +       seq_put_decimal_ull(m, "Idle:\t", p->oom_target);
> +       seq_putc(m, '\n');
> +}
> +
>  static inline void task_context_switch_counts(struct seq_file *m,
>                                                 struct task_struct *p)
>  {
> @@ -381,6 +387,7 @@ int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
>         task_sig(m, task);
>         task_cap(m, task);
>         task_seccomp(m, task);
> +       task_idle(m, task);
>         task_cpus_allowed(m, task);
>         cpuset_task_status_allowed(m, task);
>         task_context_switch_counts(m, task);
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 69966c461d1c..02eb92e7eff5 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -30,6 +30,7 @@
>  #include <linux/vmstat.h>
>  #include <linux/writeback.h>
>  #include <linux/page-flags.h>
> +#include <linux/wait.h>
>
>  struct mem_cgroup;
>  struct page;
> @@ -261,6 +262,8 @@ struct mem_cgroup {
>         struct list_head event_list;
>         spinlock_t event_list_lock;
>
> +       wait_queue_head_t       oom_target;
> +
>         struct mem_cgroup_per_node *nodeinfo[0];
>         /* WARNING: nodeinfo must be the last member here */
>  };
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 01c91d874a57..88acea9e0a59 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -102,6 +102,10 @@ extern void oom_killer_enable(void);
>
>  extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>
> +extern void exit_oom_target(void);
> +struct wait_queue_head *oom_target_get_wait(void);
> +int oom_target_callback(wait_queue_entry_t *wait, unsigned mode, int sync, void *key);
> +
>  /* sysctls */
>  extern int sysctl_oom_dump_tasks;
>  extern int sysctl_oom_kill_allocating_task;
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index fdf74f27acf1..51b0e5987e8c 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -652,6 +652,7 @@ struct task_struct {
>         /* disallow userland-initiated cgroup migration */
>         unsigned                        no_cgroup_migration:1;
>  #endif
> +       unsigned                        oom_target:1;
>
>         unsigned long                   atomic_flags; /* Flags requiring atomic access. */
>
> diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
> index b640071421f7..94868317c6f2 100644
> --- a/include/uapi/linux/prctl.h
> +++ b/include/uapi/linux/prctl.h
> @@ -198,4 +198,8 @@ struct prctl_mm_map {
>  # define PR_CAP_AMBIENT_LOWER          3
>  # define PR_CAP_AMBIENT_CLEAR_ALL      4
>
> +#define PR_SET_IDLE            48
> +#define PR_GET_IDLE            49
> +# define PR_IDLE_MODE_KILLME   1
> +
>  #endif /* _LINUX_PRCTL_H */
> diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
> index 44857278eb8a..081bcd84a8d0 100644
> --- a/kernel/cgroup/cgroup.c
> +++ b/kernel/cgroup/cgroup.c
> @@ -55,6 +55,8 @@
>  #include <linux/nsproxy.h>
>  #include <linux/file.h>
>  #include <net/sock.h>
> +#include <linux/oom.h>
> +#include <linux/memcontrol.h>
>
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/cgroup.h>
> @@ -756,6 +758,9 @@ static void css_set_move_task(struct task_struct *task,
>                               struct css_set *from_cset, struct css_set *to_cset,
>                               bool use_mg_tasks)
>  {
> +#ifdef CONFIG_MEMCG
> +       struct mem_cgroup *mcg;
> +#endif
>         lockdep_assert_held(&css_set_lock);
>
>         if (to_cset && !css_set_populated(to_cset))
> @@ -779,6 +784,35 @@ static void css_set_move_task(struct task_struct *task,
>                                 css_task_iter_advance(it);
>
>                 list_del_init(&task->cg_list);
> +#ifdef CONFIG_MEMCG

> +               /* dequeue from memcg->oom_target
Ahh this is all shitty here. Sorry for the noise of this shit.
> +                * TODO: this is O(n), add rb-tree to make it O(logn)
> +                */
> +               mcg = mem_cgroup_from_task(task);
> +               if (mcg) {
> +                       struct wait_queue_entry *wait;
> +
> +                       spin_lock(&mcg->oom_target.lock);
> +                       if (!waitqueue_active(&mcg->oom_target))
> +                               goto empty_from;
> +                       wait = list_first_entry(&mcg->oom_target.head,
> +                                               wait_queue_entry_t, entry);
> +                       do {
> +                               struct list_head *list;
> +
> +                               if (wait->private == task)
> +                                       __remove_wait_queue(&mcg->oom_target,
> +                                                         wait);
> +                               list = wait->entry.next;
> +                               if (list_is_last(list, &mcg->oom_target.head))
> +                                       break;
> +                               wait = list_entry(list,
> +                                       struct wait_queue_entry, entry);
> +                       } while (1);
> +empty_from:
> +                       spin_unlock(&mcg->oom_target.lock);
> +               }
> +#endif
>                 if (!css_set_populated(from_cset))
>                         css_set_update_populated(from_cset, false);
>         } else {
> @@ -797,6 +831,33 @@ static void css_set_move_task(struct task_struct *task,
>                 rcu_assign_pointer(task->cgroups, to_cset);
>                 list_add_tail(&task->cg_list, use_mg_tasks ? &to_cset->mg_tasks :
>                                                              &to_cset->tasks);
> +#ifdef CONFIG_MEMCG
> +               /* dequeue from memcg->oom_target */
> +               mcg = mem_cgroup_from_task(task);
> +               if (mcg) {
> +                       struct wait_queue_entry *wait;
> +
> +                       spin_lock(&mcg->oom_target.lock);
> +                       if (!waitqueue_active(&mcg->oom_target))
> +                               goto empty_to;
> +                       wait = list_first_entry(&mcg->oom_target.head,
> +                                               wait_queue_entry_t, entry);
> +                       do {
> +                               struct list_head *list;
> +
> +                               if (wait->private == task)
> +                                       __add_wait_queue(&mcg->oom_target,
> +                                                         wait);
> +                               list = wait->entry.next;
> +                               if (list_is_last(list, &mcg->oom_target.head))
> +                                       break;
> +                               wait = list_entry(list,
> +                                       struct wait_queue_entry, entry);
> +                       } while (1);
> +empty_to:
> +                       spin_unlock(&mcg->oom_target.lock);
> +               }
> +#endif
>         }
>  }
>
> diff --git a/kernel/exit.c b/kernel/exit.c
> index f6cad39f35df..2788fbdae267 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -62,6 +62,7 @@
>  #include <linux/random.h>
>  #include <linux/rcuwait.h>
>  #include <linux/compat.h>
> +#include <linux/eventpoll.h>
>
>  #include <linux/uaccess.h>
>  #include <asm/unistd.h>
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 524a4cb9bbe2..e1eb049a85e6 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2386,6 +2386,15 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>         case PR_GET_FP_MODE:
>                 error = GET_FP_MODE(me);
>                 break;
> +       case PR_SET_IDLE:
> +               if (!((arg2 == 0) || (arg2 == PR_IDLE_MODE_KILLME)))
> +                       return -EINVAL;
> +               me->oom_target = arg2;
> +               error = 0;
> +               break;
> +       case PR_GET_IDLE:
> +               error = me->oom_target;
> +               break;
>         default:
>                 error = -EINVAL;
>                 break;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 661f046ad318..a4e3b93aeccd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4300,6 +4300,8 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>                         memory_cgrp_subsys.broken_hierarchy = true;
>         }
>
> +       init_waitqueue_head(&memcg->oom_target);
> +
>         /* The following stuff does not apply to the root */
>         if (!parent) {
>                 root_mem_cgroup = memcg;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dee0f75c3013..c5d8f5a716bc 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -41,6 +41,9 @@
>  #include <linux/kthread.h>
>  #include <linux/init.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/eventpoll.h>
> +#include <linux/wait.h>
> +#include <linux/memcontrol.h>
>
>  #include <asm/tlb.h>
>  #include "internal.h"
> @@ -54,6 +57,23 @@ int sysctl_oom_dump_tasks = 1;
>
>  DEFINE_MUTEX(oom_lock);
>
> +static DECLARE_WAIT_QUEUE_HEAD(oom_target);
> +
> +/* Clean up after a EPOLL_KILLME process quits.
> + * Called by kernel/exit.c.
> + */
> +void exit_oom_target(void)
> +{
> +       DECLARE_WAITQUEUE(wait, current);
> +
> +       remove_wait_queue(&oom_target, &wait);
> +}
> +
> +inline struct wait_queue_head *oom_target_get_wait()
> +{
> +       return &oom_target;
> +}
> +
>  #ifdef CONFIG_NUMA
>  /**
>   * has_intersects_mems_allowed() - check task eligiblity for kill
> @@ -994,6 +1014,18 @@ int unregister_oom_notifier(struct notifier_block *nb)
>  }
>  EXPORT_SYMBOL_GPL(unregister_oom_notifier);
>
> +int oom_target_callback(wait_queue_entry_t *wait, unsigned mode, int sync, void *key)
> +{
> +       struct task_struct *ts = wait->private;
> +
> +       /* We use SIGKILL instead of the oom killer
> +        * so as to cleanly interrupt ep_poll()
> +        */
> +       pr_info("Killing pid %u from prctl(PR_SET_IDLE) death row.\n", ts->pid);
> +       send_sig(SIGKILL, ts, 1);
> +       return 0;
> +}
> +
>  /**
>   * out_of_memory - kill the "best" process when we run out of memory
>   * @oc: pointer to struct oom_control
> @@ -1007,6 +1039,7 @@ bool out_of_memory(struct oom_control *oc)
>  {
>         unsigned long freed = 0;
>         enum oom_constraint constraint = CONSTRAINT_NONE;
> +       wait_queue_head_t *w;
>
>         if (oom_killer_disabled)
>                 return false;
> @@ -1056,6 +1089,20 @@ bool out_of_memory(struct oom_control *oc)
>                 return true;
>         }
>
> +       /*
> +        * Check death row for current memcg or global.
> +        */
> +#ifdef CONFIG_MEMCG
> +       if (is_memcg_oom(oc))
> +               w = &oc->memcg->oom_target;
> +       else
> +#endif
> +               w = oom_target_get_wait();
> +       if (waitqueue_active(w)) {
> +               wake_up(w);
> +               return true;
> +       }
> +
>         select_bad_process(oc);
>         /* Found nothing?!?! Either we hang forever, or we panic. */
>         if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
> --
> 2.14.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
