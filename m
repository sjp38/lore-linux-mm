Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0D98D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 03:09:22 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p3L79Gdo020518
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:09:16 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by kpbe18.cbf.corp.google.com with ESMTP id p3L79E8D022466
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:09:14 -0700
Received: by qwh5 with SMTP id 5so814485qwh.20
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:09:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421124357.c94a03a5.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124357.c94a03a5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 00:09:13 -0700
Message-ID: <BANLkTin+Hghwx6L-jy_3n7ySPunECEiA3g@mail.gmail.com>
Subject: Re: [PATCH 1/3] memcg kswapd thread pool (Was Re: [PATCH V6 00/10]
 memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c2fa2a004a1686bfe
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5c2fa2a004a1686bfe
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 8:43 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Ying, please take this just a hint, you don't need to implement this as is.
>

Thank you for the patch.


> ==
> Now, memcg-kswapd is created per a cgroup. Considering there are users
> who creates hundreds on cgroup on a system, it consumes too much
> resources, memory, cputime.
>
> This patch creates a thread pool for memcg-kswapd. All memcg which
> needs background recalim are linked to a list and memcg-kswapd
> picks up a memcg from the list and run reclaim. This reclaimes
> SWAP_CLUSTER_MAX of pages and putback the memcg to the lail of
> list. memcg-kswapd will visit memcgs in round-robin manner and
> reduce usages.
>
> This patch does
>
>  - adds memcg-kswapd thread pool, the number of threads is now
>   sqrt(num_of_cpus) + 1.
>  - use unified kswapd_waitq for all memcgs.
>

So I looked through the patch, it implements an alternative threading model
using thread-pool. Also it includes some changes on calculating how much
pages to reclaim per memcg. Other than that, all the existing implementation
of per-memcg-kswapd seems not being impacted.

I tried to apply the patch but get some conflicts on vmscan.c/ I will try
some manual work tomorrow. Meantime, after applying the patch, I will try to
test it w/ the same test suite i used on original patch. AFAIK, the only
difference of the two threading model is the amount of resources we consume
on the kswapd kernel thread, which shouldn't have run-time performance
differences.


>  - refine memcg shrink codes in vmscan.c
>

Those seems to be the comments from V6 and I already have them changed in V7
( haven't posted yet)

 --Ying


> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    5
>  include/linux/swap.h       |    7 -
>  mm/memcontrol.c            |  174 +++++++++++++++++++++++----------
>  mm/memory_hotplug.c        |    4
>  mm/page_alloc.c            |    1
>  mm/vmscan.c                |  237
> ++++++++++++++++++---------------------------
>  6 files changed, 232 insertions(+), 196 deletions(-)
>
> Index: mmotm-Apr14/mm/memcontrol.c
> ===================================================================
> --- mmotm-Apr14.orig/mm/memcontrol.c
> +++ mmotm-Apr14/mm/memcontrol.c
> @@ -49,6 +49,8 @@
>  #include <linux/cpu.h>
>  #include <linux/oom.h>
>  #include "internal.h"
> +#include <linux/kthread.h>
> +#include <linux/freezer.h>
>
>  #include <asm/uaccess.h>
>
> @@ -274,6 +276,12 @@ struct mem_cgroup {
>         */
>        unsigned long   move_charge_at_immigrate;
>        /*
> +        * memcg kswapd control stuff.
> +        */
> +       atomic_t                kswapd_running; /* !=0 if a kswapd runs */
> +       wait_queue_head_t       memcg_kswapd_end; /* for waiting the end*/
> +       struct list_head        memcg_kswapd_wait_list;/* for shceduling */
> +       /*
>         * percpu counter.
>         */
>        struct mem_cgroup_stat_cpu *stat;
> @@ -296,7 +304,6 @@ struct mem_cgroup {
>         */
>        int last_scanned_node;
>
> -       wait_queue_head_t *kswapd_wait;
>  };
>
>  /* Stuffs for move charges at task migration. */
> @@ -380,6 +387,7 @@ static struct mem_cgroup *parent_mem_cgr
>  static void drain_all_stock_async(void);
>
>  static void wake_memcg_kswapd(struct mem_cgroup *mem);
> +static void memcg_kswapd_stop(struct mem_cgroup *mem);
>
>  static struct mem_cgroup_per_zone *
>  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> @@ -916,9 +924,6 @@ static void setup_per_memcg_wmarks(struc
>
>                res_counter_set_low_wmark_limit(&mem->res, low_wmark);
>                res_counter_set_high_wmark_limit(&mem->res, high_wmark);
> -
> -               if (!mem_cgroup_is_root(mem) && !mem->kswapd_wait)
> -                       kswapd_run(0, mem);
>        }
>  }
>
> @@ -3729,6 +3734,7 @@ move_account:
>                ret = -EBUSY;
>                if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
>                        goto out;
> +               memcg_kswapd_stop(mem);
>                ret = -EINTR;
>                if (signal_pending(current))
>                        goto out;
> @@ -4655,6 +4661,120 @@ static int mem_cgroup_oom_control_write(
>        return 0;
>  }
>
> +/*
> + * Controls for background memory reclam stuff.
> + */
> +struct memcg_kswapd_work
> +{
> +       spinlock_t              lock;  /* lock for list */
> +       struct list_head        list;  /* list of works. */
> +       wait_queue_head_t       waitq;
> +};
> +
> +struct memcg_kswapd_work       memcg_kswapd_control;
> +
> +static void wake_memcg_kswapd(struct mem_cgroup *mem)
> +{
> +       if (atomic_read(&mem->kswapd_running)) /* already running */
> +               return;
> +
> +       spin_lock(&memcg_kswapd_control.lock);
> +       if (list_empty(&mem->memcg_kswapd_wait_list))
> +               list_add_tail(&mem->memcg_kswapd_wait_list,
> +                               &memcg_kswapd_control.list);
> +       spin_unlock(&memcg_kswapd_control.lock);
> +       wake_up(&memcg_kswapd_control.waitq);
> +       return;
> +}
> +
> +static void memcg_kswapd_wait_end(struct mem_cgroup *mem)
> +{
> +       DEFINE_WAIT(wait);
> +
> +       prepare_to_wait(&mem->memcg_kswapd_end, &wait, TASK_INTERRUPTIBLE);
> +       if (atomic_read(&mem->kswapd_running))
> +               schedule();
> +       finish_wait(&mem->memcg_kswapd_end, &wait);
> +}
> +
> +/* called at pre_destroy */
> +static void memcg_kswapd_stop(struct mem_cgroup *mem)
> +{
> +       spin_lock(&memcg_kswapd_control.lock);
> +       if (!list_empty(&mem->memcg_kswapd_wait_list))
> +               list_del(&mem->memcg_kswapd_wait_list);
> +       spin_unlock(&memcg_kswapd_control.lock);
> +
> +       memcg_kswapd_wait_end(mem);
> +}
> +
> +struct mem_cgroup *mem_cgroup_get_shrink_target(void)
> +{
> +       struct mem_cgroup *mem;
> +
> +       spin_lock(&memcg_kswapd_control.lock);
> +       rcu_read_lock();
> +       do {
> +               mem = NULL;
> +               if (!list_empty(&memcg_kswapd_control.list)) {
> +                       mem = list_entry(memcg_kswapd_control.list.next,
> +                                       struct mem_cgroup,
> +                                       memcg_kswapd_wait_list);
> +                       list_del_init(&mem->memcg_kswapd_wait_list);
> +               }
> +       } while (mem && !css_tryget(&mem->css));
> +       if (mem)
> +               atomic_inc(&mem->kswapd_running);
> +       rcu_read_unlock();
> +       spin_unlock(&memcg_kswapd_control.lock);
> +       return mem;
> +}
> +
> +void mem_cgroup_put_shrink_target(struct mem_cgroup *mem)
> +{
> +       if (!mem)
> +               return;
> +       atomic_dec(&mem->kswapd_running);
> +       if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {
> +               spin_lock(&memcg_kswapd_control.lock);
> +               if (list_empty(&mem->memcg_kswapd_wait_list)) {
> +                       list_add_tail(&mem->memcg_kswapd_wait_list,
> +                                       &memcg_kswapd_control.list);
> +               }
> +               spin_unlock(&memcg_kswapd_control.lock);
> +       }
> +       wake_up_all(&mem->memcg_kswapd_end);
> +       cgroup_release_and_wakeup_rmdir(&mem->css);
> +}
> +
> +bool mem_cgroup_kswapd_can_sleep(void)
> +{
> +       return list_empty(&memcg_kswapd_control.list);
> +}
> +
> +wait_queue_head_t *mem_cgroup_kswapd_waitq(void)
> +{
> +       return &memcg_kswapd_control.waitq;
> +}
> +
> +static int __init memcg_kswapd_init(void)
> +{
> +
> +       int i, nr_threads;
> +
> +       spin_lock_init(&memcg_kswapd_control.lock);
> +       INIT_LIST_HEAD(&memcg_kswapd_control.list);
> +       init_waitqueue_head(&memcg_kswapd_control.waitq);
> +
> +       nr_threads = int_sqrt(num_possible_cpus()) + 1;
> +       for (i = 0; i < nr_threads; i++)
> +               if (kswapd_run(0, i + 1) == -1)
> +                       break;
> +       return 0;
> +}
> +module_init(memcg_kswapd_init);
> +
> +
>  static struct cftype mem_cgroup_files[] = {
>        {
>                .name = "usage_in_bytes",
> @@ -4935,33 +5055,6 @@ int mem_cgroup_watermark_ok(struct mem_c
>        return ret;
>  }
>
> -int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd
> *kswapd_p)
> -{
> -       if (!mem || !kswapd_p)
> -               return 0;
> -
> -       mem->kswapd_wait = &kswapd_p->kswapd_wait;
> -       kswapd_p->kswapd_mem = mem;
> -
> -       return css_id(&mem->css);
> -}
> -
> -void mem_cgroup_clear_kswapd(struct mem_cgroup *mem)
> -{
> -       if (mem)
> -               mem->kswapd_wait = NULL;
> -
> -       return;
> -}
> -
> -wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
> -{
> -       if (!mem)
> -               return NULL;
> -
> -       return mem->kswapd_wait;
> -}
> -
>  int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
>  {
>        if (!mem)
> @@ -4970,22 +5063,6 @@ int mem_cgroup_last_scanned_node(struct
>        return mem->last_scanned_node;
>  }
>
> -static inline
> -void wake_memcg_kswapd(struct mem_cgroup *mem)
> -{
> -       wait_queue_head_t *wait;
> -
> -       if (!mem || !mem->high_wmark_distance)
> -               return;
> -
> -       wait = mem->kswapd_wait;
> -
> -       if (!wait || !waitqueue_active(wait))
> -               return;
> -
> -       wake_up_interruptible(wait);
> -}
> -
>  static int mem_cgroup_soft_limit_tree_init(void)
>  {
>        struct mem_cgroup_tree_per_node *rtpn;
> @@ -5069,6 +5146,8 @@ mem_cgroup_create(struct cgroup_subsys *
>        atomic_set(&mem->refcnt, 1);
>        mem->move_charge_at_immigrate = 0;
>        mutex_init(&mem->thresholds_lock);
> +       init_waitqueue_head(&mem->memcg_kswapd_end);
> +       INIT_LIST_HEAD(&mem->memcg_kswapd_wait_list);
>        return &mem->css;
>  free_out:
>        __mem_cgroup_free(mem);
> @@ -5089,7 +5168,6 @@ static void mem_cgroup_destroy(struct cg
>  {
>        struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
>
> -       kswapd_stop(0, mem);
>        mem_cgroup_put(mem);
>  }
>
> Index: mmotm-Apr14/include/linux/swap.h
> ===================================================================
> --- mmotm-Apr14.orig/include/linux/swap.h
> +++ mmotm-Apr14/include/linux/swap.h
> @@ -28,9 +28,8 @@ static inline int current_is_kswapd(void
>
>  struct kswapd {
>        struct task_struct *kswapd_task;
> -       wait_queue_head_t kswapd_wait;
> +       wait_queue_head_t *kswapd_wait;
>        pg_data_t *kswapd_pgdat;
> -       struct mem_cgroup *kswapd_mem;
>  };
>
>  int kswapd(void *p);
> @@ -307,8 +306,8 @@ static inline void scan_unevictable_unre
>  }
>  #endif
>
> -extern int kswapd_run(int nid, struct mem_cgroup *mem);
> -extern void kswapd_stop(int nid, struct mem_cgroup *mem);
> +extern int kswapd_run(int nid, int id);
> +extern void kswapd_stop(int nid);
>
>  #ifdef CONFIG_MMU
>  /* linux/mm/shmem.c */
> Index: mmotm-Apr14/mm/page_alloc.c
> ===================================================================
> --- mmotm-Apr14.orig/mm/page_alloc.c
> +++ mmotm-Apr14/mm/page_alloc.c
> @@ -4199,6 +4199,7 @@ static void __paginginit free_area_init_
>
>        pgdat_resize_init(pgdat);
>        pgdat->nr_zones = 0;
> +       init_waitqueue_head(&pgdat->kswapd_wait);
>        pgdat->kswapd_max_order = 0;
>        pgdat_page_cgroup_init(pgdat);
>
> Index: mmotm-Apr14/mm/vmscan.c
> ===================================================================
> --- mmotm-Apr14.orig/mm/vmscan.c
> +++ mmotm-Apr14/mm/vmscan.c
> @@ -2256,7 +2256,7 @@ static bool pgdat_balanced(pg_data_t *pg
>        return balanced_pages > (present_pages >> 2);
>  }
>
> -#define is_global_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
> +#define is_global_kswapd(kswapd_p) ((kswapd_p)->kswapd_pgdat)
>
>  /* is kswapd sleeping prematurely? */
>  static bool sleeping_prematurely(pg_data_t *pgdat, int order, long
> remaining,
> @@ -2599,50 +2599,56 @@ static void kswapd_try_to_sleep(struct k
>        long remaining = 0;
>        DEFINE_WAIT(wait);
>        pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> -       wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
> +       wait_queue_head_t *wait_h = kswapd_p->kswapd_wait;
>
>        if (freezing(current) || kthread_should_stop())
>                return;
>
>        prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
>
> -       if (!is_global_kswapd(kswapd_p)) {
> -               schedule();
> -               goto out;
> -       }
> -
> -       /* Try to sleep for a short interval */
> -       if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx))
> {
> -               remaining = schedule_timeout(HZ/10);
> -               finish_wait(wait_h, &wait);
> -               prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> -       }
> -
> -       /*
> -        * After a short sleep, check if it was a premature sleep. If not,
> then
> -        * go fully to sleep until explicitly woken up.
> -        */
> -       if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx))
> {
> -               trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> +       if (is_global_kswapd(kswapd_p)) {
> +               /* Try to sleep for a short interval */
> +               if (!sleeping_prematurely(pgdat, order,
> +                               remaining, classzone_idx)) {
> +                       remaining = schedule_timeout(HZ/10);
> +                       finish_wait(wait_h, &wait);
> +                       prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> +               }
>
>                /*
> -                * vmstat counters are not perfectly accurate and the
> estimated
> -                * value for counters such as NR_FREE_PAGES can deviate
> from the
> -                * true value by nr_online_cpus * threshold. To avoid the
> zone
> -                * watermarks being breached while under pressure, we
> reduce the
> -                * per-cpu vmstat threshold while kswapd is awake and
> restore
> -                * them before going back to sleep.
> -                */
> -               set_pgdat_percpu_threshold(pgdat,
> calculate_normal_threshold);
> -               schedule();
> -               set_pgdat_percpu_threshold(pgdat,
> calculate_pressure_threshold);
> +                * After a short sleep, check if it was a premature sleep.
> +                * If not, then go fully to sleep until explicitly woken
> up.
> +                */
> +               if (!sleeping_prematurely(pgdat, order,
> +                                       remaining, classzone_idx)) {
> +                       trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> +                       /*
> +                        * vmstat counters are not perfectly accurate and
> +                        * the estimated value for counters such as
> +                        * NR_FREE_PAGES  can deviate from the true value
> for
> +                        * counters such as NR_FREE_PAGES can deviate from
> the
> +                        *  true value by nr_online_cpus * threshold. To
> avoid
> +                        *  the zonewatermarks being breached while under
> +                        *  pressure, we reduce the per-cpu vmstat
> threshold
> +                        *  while kswapd is awake and restore them before
> +                        *  going back to sleep.
> +                        */
> +                       set_pgdat_percpu_threshold(pgdat,
> +                                       calculate_normal_threshold);
> +                       schedule();
> +                       set_pgdat_percpu_threshold(pgdat,
> +                                       calculate_pressure_threshold);
> +               } else {
> +                       if (remaining)
> +
> count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> +                       else
> +
> count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> +               }
>        } else {
> -               if (remaining)
> -                       count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> -               else
> -                       count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> +               /* For now, we just check the remaining works.*/
> +               if (mem_cgroup_kswapd_can_sleep())
> +                       schedule();
>        }
> -out:
>        finish_wait(wait_h, &wait);
>  }
>
> @@ -2651,8 +2657,8 @@ out:
>  * The function is used for per-memcg LRU. It scanns all the zones of the
>  * node and returns the nr_scanned and nr_reclaimed.
>  */
> -static void balance_pgdat_node(pg_data_t *pgdat, int order,
> -                                       struct scan_control *sc)
> +static void shrink_memcg_node(pg_data_t *pgdat, int order,
> +                               struct scan_control *sc)
>  {
>        int i;
>        unsigned long total_scanned = 0;
> @@ -2705,14 +2711,9 @@ static void balance_pgdat_node(pg_data_t
>  * Per cgroup background reclaim.
>  * TODO: Take off the order since memcg always do order 0
>  */
> -static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
> -                                             int order)
> +static int shrink_mem_cgroup(struct mem_cgroup *mem_cont, int order)
>  {
> -       int i, nid;
> -       int start_node;
> -       int priority;
> -       bool wmark_ok;
> -       int loop;
> +       int i, nid, priority, loop;
>        pg_data_t *pgdat;
>        nodemask_t do_nodes;
>        unsigned long total_scanned;
> @@ -2726,43 +2727,34 @@ static unsigned long balance_mem_cgroup_
>                .mem_cgroup = mem_cont,
>        };
>
> -loop_again:
>        do_nodes = NODE_MASK_NONE;
>        sc.may_writepage = !laptop_mode;
>        sc.nr_reclaimed = 0;
>        total_scanned = 0;
>
> -       for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> -               sc.priority = priority;
> -               wmark_ok = false;
> -               loop = 0;
> +       do_nodes = node_states[N_ONLINE];
>
> +       for (priority = DEF_PRIORITY;
> +               (priority >= 0) && (sc.nr_to_reclaim > sc.nr_reclaimed);
> +               priority--) {
> +
> +               sc.priority = priority;
>                /* The swap token gets in the way of swapout... */
>                if (!priority)
>                        disable_swap_token();
> +               /*
> +                * We'll scan a node given by memcg's logic. For avoiding
> +                * burning cpu, we have a limit of this loop.
> +                */
> +               for (loop = num_online_nodes();
> +                       (loop > 0) && !nodes_empty(do_nodes);
> +                       loop--) {
>
> -               if (priority == DEF_PRIORITY)
> -                       do_nodes = node_states[N_ONLINE];
> -
> -               while (1) {
>                        nid = mem_cgroup_select_victim_node(mem_cont,
>                                                        &do_nodes);
> -
> -                       /*
> -                        * Indicate we have cycled the nodelist once
> -                        * TODO: we might add MAX_RECLAIM_LOOP for
> preventing
> -                        * kswapd burning cpu cycles.
> -                        */
> -                       if (loop == 0) {
> -                               start_node = nid;
> -                               loop++;
> -                       } else if (nid == start_node)
> -                               break;
> -
>                        pgdat = NODE_DATA(nid);
> -                       balance_pgdat_node(pgdat, order, &sc);
> +                       shrink_memcg_node(pgdat, order, &sc);
>                        total_scanned += sc.nr_scanned;
> -
>                        /*
>                         * Set the node which has at least one reclaimable
>                         * zone
> @@ -2770,10 +2762,8 @@ loop_again:
>                        for (i = pgdat->nr_zones - 1; i >= 0; i--) {
>                                struct zone *zone = pgdat->node_zones + i;
>
> -                               if (!populated_zone(zone))
> -                                       continue;
> -
> -                               if (!mem_cgroup_mz_unreclaimable(mem_cont,
> +                               if (populated_zone(zone) &&
> +                                   !mem_cgroup_mz_unreclaimable(mem_cont,
>                                                                zone))
>                                        break;
>                        }
> @@ -2781,36 +2771,18 @@ loop_again:
>                                node_clear(nid, do_nodes);
>
>                        if (mem_cgroup_watermark_ok(mem_cont,
> -                                                       CHARGE_WMARK_HIGH))
> {
> -                               wmark_ok = true;
> -                               goto out;
> -                       }
> -
> -                       if (nodes_empty(do_nodes)) {
> -                               wmark_ok = true;
> +                                               CHARGE_WMARK_HIGH))
>                                goto out;
> -                       }
>                }
>
>                if (total_scanned && priority < DEF_PRIORITY - 2)
>                        congestion_wait(WRITE, HZ/10);
> -
> -               if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> -                       break;
>        }
>  out:
> -       if (!wmark_ok) {
> -               cond_resched();
> -
> -               try_to_freeze();
> -
> -               goto loop_again;
> -       }
> -
>        return sc.nr_reclaimed;
>  }
>  #else
> -static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
> +static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont,
>                                                        int order)
>  {
>        return 0;
> @@ -2836,8 +2808,7 @@ int kswapd(void *p)
>        int classzone_idx;
>        struct kswapd *kswapd_p = (struct kswapd *)p;
>        pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> -       struct mem_cgroup *mem = kswapd_p->kswapd_mem;
> -       wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
> +       struct mem_cgroup *mem;
>        struct task_struct *tsk = current;
>
>        struct reclaim_state reclaim_state = {
> @@ -2848,7 +2819,6 @@ int kswapd(void *p)
>        lockdep_set_current_reclaim_state(GFP_KERNEL);
>
>        if (is_global_kswapd(kswapd_p)) {
> -               BUG_ON(pgdat->kswapd_wait != wait_h);
>                cpumask = cpumask_of_node(pgdat->node_id);
>                if (!cpumask_empty(cpumask))
>                        set_cpus_allowed_ptr(tsk, cpumask);
> @@ -2908,18 +2878,20 @@ int kswapd(void *p)
>                if (kthread_should_stop())
>                        break;
>
> +               if (ret)
> +                       continue;
>                /*
>                 * We can speed up thawing tasks if we don't call
> balance_pgdat
>                 * after returning from the refrigerator
>                 */
> -               if (!ret) {
> -                       if (is_global_kswapd(kswapd_p)) {
> -                               trace_mm_vmscan_kswapd_wake(pgdat->node_id,
> -                                                               order);
> -                               order = balance_pgdat(pgdat, order,
> -                                                       &classzone_idx);
> -                       } else
> -                               balance_mem_cgroup_pgdat(mem, order);
> +               if (is_global_kswapd(kswapd_p)) {
> +                       trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> +                       order = balance_pgdat(pgdat, order,
> &classzone_idx);
> +               } else {
> +                       mem = mem_cgroup_get_shrink_target();
> +                       if (mem)
> +                               shrink_mem_cgroup(mem, order);
> +                       mem_cgroup_put_shrink_target(mem);
>                }
>        }
>        return 0;
> @@ -2942,13 +2914,13 @@ void wakeup_kswapd(struct zone *zone, in
>                pgdat->kswapd_max_order = order;
>                pgdat->classzone_idx = min(pgdat->classzone_idx,
> classzone_idx);
>        }
> -       if (!waitqueue_active(pgdat->kswapd_wait))
> +       if (!waitqueue_active(&pgdat->kswapd_wait))
>                return;
>        if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0,
> 0))
>                return;
>
>        trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone),
> order);
> -       wake_up_interruptible(pgdat->kswapd_wait);
> +       wake_up_interruptible(&pgdat->kswapd_wait);
>  }
>
>  /*
> @@ -3046,9 +3018,8 @@ static int __devinit cpu_callback(struct
>
>                        mask = cpumask_of_node(pgdat->node_id);
>
> -                       wait = pgdat->kswapd_wait;
> -                       kswapd_p = container_of(wait, struct kswapd,
> -                                               kswapd_wait);
> +                       wait = &pgdat->kswapd_wait;
> +                       kswapd_p = pgdat->kswapd;
>                        kswapd_tsk = kswapd_p->kswapd_task;
>
>                        if (cpumask_any_and(cpu_online_mask, mask) <
> nr_cpu_ids)
> @@ -3064,18 +3035,17 @@ static int __devinit cpu_callback(struct
>  * This kswapd start function will be called by init and node-hot-add.
>  * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
>  */
> -int kswapd_run(int nid, struct mem_cgroup *mem)
> +int kswapd_run(int nid, int memcgid)
>  {
>        struct task_struct *kswapd_tsk;
>        pg_data_t *pgdat = NULL;
>        struct kswapd *kswapd_p;
>        static char name[TASK_COMM_LEN];
> -       int memcg_id = -1;
>        int ret = 0;
>
> -       if (!mem) {
> +       if (!memcgid) {
>                pgdat = NODE_DATA(nid);
> -               if (pgdat->kswapd_wait)
> +               if (pgdat->kswapd)
>                        return ret;
>        }
>
> @@ -3083,34 +3053,26 @@ int kswapd_run(int nid, struct mem_cgrou
>        if (!kswapd_p)
>                return -ENOMEM;
>
> -       init_waitqueue_head(&kswapd_p->kswapd_wait);
> -
> -       if (!mem) {
> -               pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
> +       if (!memcgid) {
> +               pgdat->kswapd = kswapd_p;
> +               kswapd_p->kswapd_wait = &pgdat->kswapd_wait;
>                kswapd_p->kswapd_pgdat = pgdat;
>                snprintf(name, TASK_COMM_LEN, "kswapd_%d", nid);
>        } else {
> -               memcg_id = mem_cgroup_init_kswapd(mem, kswapd_p);
> -               if (!memcg_id) {
> -                       kfree(kswapd_p);
> -                       return ret;
> -               }
> -               snprintf(name, TASK_COMM_LEN, "memcg_%d", memcg_id);
> +               kswapd_p->kswapd_wait = mem_cgroup_kswapd_waitq();
> +               snprintf(name, TASK_COMM_LEN, "memcg_%d", memcgid);
>        }
>
>        kswapd_tsk = kthread_run(kswapd, kswapd_p, name);
>        if (IS_ERR(kswapd_tsk)) {
>                /* failure at boot is fatal */
>                BUG_ON(system_state == SYSTEM_BOOTING);
> -               if (!mem) {
> +               if (!memcgid) {
>                        printk(KERN_ERR "Failed to start kswapd on node
> %d\n",
>                                                                nid);
> -                       pgdat->kswapd_wait = NULL;
> -               } else {
> -                       printk(KERN_ERR "Failed to start kswapd on memcg
> %d\n",
> -                                                               memcg_id);
> -                       mem_cgroup_clear_kswapd(mem);
> -               }
> +                       pgdat->kswapd = NULL;
> +               } else
> +                       printk(KERN_ERR "Failed to start kswapd on
> memcg\n");
>                kfree(kswapd_p);
>                ret = -1;
>        } else
> @@ -3121,23 +3083,14 @@ int kswapd_run(int nid, struct mem_cgrou
>  /*
>  * Called by memory hotplug when all memory in a node is offlined.
>  */
> -void kswapd_stop(int nid, struct mem_cgroup *mem)
> +void kswapd_stop(int nid)
>  {
>        struct task_struct *kswapd_tsk = NULL;
>        struct kswapd *kswapd_p = NULL;
> -       wait_queue_head_t *wait;
> -
> -       if (!mem)
> -               wait = NODE_DATA(nid)->kswapd_wait;
> -       else
> -               wait = mem_cgroup_kswapd_wait(mem);
> -
> -       if (wait) {
> -               kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> -               kswapd_tsk = kswapd_p->kswapd_task;
> -               kswapd_p->kswapd_task = NULL;
> -       }
>
> +       kswapd_p = NODE_DATA(nid)->kswapd;
> +       kswapd_tsk = kswapd_p->kswapd_task;
> +       kswapd_p->kswapd_task = NULL;
>        if (kswapd_tsk)
>                kthread_stop(kswapd_tsk);
>
> @@ -3150,7 +3103,7 @@ static int __init kswapd_init(void)
>
>        swap_setup();
>        for_each_node_state(nid, N_HIGH_MEMORY)
> -               kswapd_run(nid, NULL);
> +               kswapd_run(nid, 0);
>        hotcpu_notifier(cpu_callback, 0);
>        return 0;
>  }
> Index: mmotm-Apr14/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-Apr14.orig/include/linux/memcontrol.h
> +++ mmotm-Apr14/include/linux/memcontrol.h
> @@ -94,6 +94,11 @@ extern int mem_cgroup_last_scanned_node(
>  extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
>                                        const nodemask_t *nodes);
>
> +extern bool mem_cgroup_kswapd_can_sleep(void);
> +extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);
> +extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
> +extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
> +
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
>  {
> Index: mmotm-Apr14/mm/memory_hotplug.c
> ===================================================================
> --- mmotm-Apr14.orig/mm/memory_hotplug.c
> +++ mmotm-Apr14/mm/memory_hotplug.c
> @@ -463,7 +463,7 @@ int __ref online_pages(unsigned long pfn
>        init_per_zone_wmark_min();
>
>        if (onlined_pages) {
> -               kswapd_run(zone_to_nid(zone), NULL);
> +               kswapd_run(zone_to_nid(zone), 0);
>                node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
>        }
>
> @@ -898,7 +898,7 @@ repeat:
>
>        if (!node_present_pages(node)) {
>                node_clear_state(node, N_HIGH_MEMORY);
> -               kswapd_stop(node, NULL);
> +               kswapd_stop(node);
>        }
>
>        vm_total_pages = nr_free_pagecache_pages();
>
>

--0016360e3f5c2fa2a004a1686bfe
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 8:43 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
Ying, please take this just a hint, you don&#39;t need to implement this as=
 is.<br></blockquote><div><br></div><div>Thank you for the patch.</div><div=
>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bord=
er-left:1px #ccc solid;padding-left:1ex;">

=3D=3D<br>
Now, memcg-kswapd is created per a cgroup. Considering there are users<br>
who creates hundreds on cgroup on a system, it consumes too much<br>
resources, memory, cputime.<br>
<br>
This patch creates a thread pool for memcg-kswapd. All memcg which<br>
needs background recalim are linked to a list and memcg-kswapd<br>
picks up a memcg from the list and run reclaim. This reclaimes<br>
SWAP_CLUSTER_MAX of pages and putback the memcg to the lail of<br>
list. memcg-kswapd will visit memcgs in round-robin manner and<br>
reduce usages.<br>
<br></blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex;">This patch does<br>
<br>
=A0- adds memcg-kswapd thread pool, the number of threads is now<br>
 =A0 sqrt(num_of_cpus) + 1.<br>
=A0- use unified kswapd_waitq for all memcgs.<br></blockquote><div><br></di=
v><div>So I looked through the patch, it implements an alternative threadin=
g model using thread-pool. Also it includes some changes on calculating how=
 much pages to reclaim per memcg. Other than that, all the existing impleme=
ntation of per-memcg-kswapd seems not being impacted.</div>
<div><br></div><div>I tried to apply the patch but get some conflicts on vm=
scan.c/ I will try some manual work tomorrow. Meantime, after applying the =
patch, I will try to test it w/ the same test suite i used on original patc=
h. AFAIK, the only difference of the two threading model is the amount of r=
esources we consume on the kswapd kernel thread, which shouldn&#39;t have r=
un-time performance differences.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
=A0- refine memcg shrink codes in vmscan.c<br></blockquote><div><br></div><=
div>Those seems to be the comments from V6 and I already have them changed =
in V7 ( haven&#39;t posted yet)=A0</div><div><br></div><div>=A0--Ying</div>=
<div>
<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bord=
er-left:1px #ccc solid;padding-left:1ex;">
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 =A05<br>
=A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A07 -<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0174 +++++++++++++++++++++++-=
---------<br>
=A0mm/memory_hotplug.c =A0 =A0 =A0 =A0| =A0 =A04<br>
=A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0237 ++++++++++++++++++--=
-------------------------<br>
=A06 files changed, 232 insertions(+), 196 deletions(-)<br>
<br>
Index: mmotm-Apr14/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/mm/memcontrol.c<br>
+++ mmotm-Apr14/mm/memcontrol.c<br>
@@ -49,6 +49,8 @@<br>
=A0#include &lt;linux/cpu.h&gt;<br>
=A0#include &lt;linux/oom.h&gt;<br>
=A0#include &quot;internal.h&quot;<br>
+#include &lt;linux/kthread.h&gt;<br>
+#include &lt;linux/freezer.h&gt;<br>
<br>
=A0#include &lt;asm/uaccess.h&gt;<br>
<br>
@@ -274,6 +276,12 @@ struct mem_cgroup {<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0unsigned long =A0 move_charge_at_immigrate;<br>
 =A0 =A0 =A0 =A0/*<br>
+ =A0 =A0 =A0 =A0* memcg kswapd control stuff.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 atomic_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_running; /* !=
=3D0 if a kswapd runs */<br>
+ =A0 =A0 =A0 wait_queue_head_t =A0 =A0 =A0 memcg_kswapd_end; /* for waitin=
g the end*/<br>
+ =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0memcg_kswapd_wait_list;/* for=
 shceduling */<br>
+ =A0 =A0 =A0 /*<br>
 =A0 =A0 =A0 =A0 * percpu counter.<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0struct mem_cgroup_stat_cpu *stat;<br>
@@ -296,7 +304,6 @@ struct mem_cgroup {<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0int last_scanned_node;<br>
<br>
- =A0 =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
=A0};<br>
<br>
=A0/* Stuffs for move charges at task migration. */<br>
@@ -380,6 +387,7 @@ static struct mem_cgroup *parent_mem_cgr<br>
=A0static void drain_all_stock_async(void);<br>
<br>
=A0static void wake_memcg_kswapd(struct mem_cgroup *mem);<br>
+static void memcg_kswapd_stop(struct mem_cgroup *mem);<br>
<br>
=A0static struct mem_cgroup_per_zone *<br>
=A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)<br>
@@ -916,9 +924,6 @@ static void setup_per_memcg_wmarks(struc<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_set_low_wmark_limit(&amp;mem-&g=
t;res, low_wmark);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_set_high_wmark_limit(&amp;mem-&=
gt;res, high_wmark);<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_is_root(mem) &amp;&amp; !mem-=
&gt;kswapd_wait)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(0, mem);<br>
 =A0 =A0 =A0 =A0}<br>
=A0}<br>
<br>
@@ -3729,6 +3734,7 @@ move_account:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EBUSY;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cgroup_task_count(cgrp) || !list_empty(=
&amp;cgrp-&gt;children))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_kswapd_stop(mem);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EINTR;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (signal_pending(current))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
@@ -4655,6 +4661,120 @@ static int mem_cgroup_oom_control_write(<br>
 =A0 =A0 =A0 =A0return 0;<br>
=A0}<br>
<br>
+/*<br>
+ * Controls for background memory reclam stuff.<br>
+ */<br>
+struct memcg_kswapd_work<br>
+{<br>
+ =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lock; =A0/* lock for li=
st */<br>
+ =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0list; =A0/* list of works. */=
<br>
+ =A0 =A0 =A0 wait_queue_head_t =A0 =A0 =A0 waitq;<br>
+};<br>
+<br>
+struct memcg_kswapd_work =A0 =A0 =A0 memcg_kswapd_control;<br>
+<br>
+static void wake_memcg_kswapd(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 if (atomic_read(&amp;mem-&gt;kswapd_running)) /* already runn=
ing */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+<br>
+ =A0 =A0 =A0 spin_lock(&amp;memcg_kswapd_control.lock);<br>
+ =A0 =A0 =A0 if (list_empty(&amp;mem-&gt;memcg_kswapd_wait_list))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&amp;mem-&gt;memcg_kswapd_wait_=
list,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;memcg_ks=
wapd_control.list);<br>
+ =A0 =A0 =A0 spin_unlock(&amp;memcg_kswapd_control.lock);<br>
+ =A0 =A0 =A0 wake_up(&amp;memcg_kswapd_control.waitq);<br>
+ =A0 =A0 =A0 return;<br>
+}<br>
+<br>
+static void memcg_kswapd_wait_end(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 DEFINE_WAIT(wait);<br>
+<br>
+ =A0 =A0 =A0 prepare_to_wait(&amp;mem-&gt;memcg_kswapd_end, &amp;wait, TAS=
K_INTERRUPTIBLE);<br>
+ =A0 =A0 =A0 if (atomic_read(&amp;mem-&gt;kswapd_running))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
+ =A0 =A0 =A0 finish_wait(&amp;mem-&gt;memcg_kswapd_end, &amp;wait);<br>
+}<br>
+<br>
+/* called at pre_destroy */<br>
+static void memcg_kswapd_stop(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 spin_lock(&amp;memcg_kswapd_control.lock);<br>
+ =A0 =A0 =A0 if (!list_empty(&amp;mem-&gt;memcg_kswapd_wait_list))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&amp;mem-&gt;memcg_kswapd_wait_list)=
;<br>
+ =A0 =A0 =A0 spin_unlock(&amp;memcg_kswapd_control.lock);<br>
+<br>
+ =A0 =A0 =A0 memcg_kswapd_wait_end(mem);<br>
+}<br>
+<br>
+struct mem_cgroup *mem_cgroup_get_shrink_target(void)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem;<br>
+<br>
+ =A0 =A0 =A0 spin_lock(&amp;memcg_kswapd_control.lock);<br>
+ =A0 =A0 =A0 rcu_read_lock();<br>
+ =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D NULL;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!list_empty(&amp;memcg_kswapd_control.lis=
t)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D list_entry(memcg_kswa=
pd_control.list.next,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct mem_cgroup,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 memcg_kswapd_wait_list);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_init(&amp;mem-&gt;me=
mcg_kswapd_wait_list);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 } while (mem &amp;&amp; !css_tryget(&amp;mem-&gt;css));<br>
+ =A0 =A0 =A0 if (mem)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_inc(&amp;mem-&gt;kswapd_running);<br>
+ =A0 =A0 =A0 rcu_read_unlock();<br>
+ =A0 =A0 =A0 spin_unlock(&amp;memcg_kswapd_control.lock);<br>
+ =A0 =A0 =A0 return mem;<br>
+}<br>
+<br>
+void mem_cgroup_put_shrink_target(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 if (!mem)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 atomic_dec(&amp;mem-&gt;kswapd_running);<br>
+ =A0 =A0 =A0 if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;memcg_kswapd_control.lock);<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (list_empty(&amp;mem-&gt;memcg_kswapd_wait=
_list)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&amp;mem-&gt;me=
mcg_kswapd_wait_list,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 &amp;memcg_kswapd_control.list);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;memcg_kswapd_control.lock);<=
br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 wake_up_all(&amp;mem-&gt;memcg_kswapd_end);<br>
+ =A0 =A0 =A0 cgroup_release_and_wakeup_rmdir(&amp;mem-&gt;css);<br>
+}<br>
+<br>
+bool mem_cgroup_kswapd_can_sleep(void)<br>
+{<br>
+ =A0 =A0 =A0 return list_empty(&amp;memcg_kswapd_control.list);<br>
+}<br>
+<br>
+wait_queue_head_t *mem_cgroup_kswapd_waitq(void)<br>
+{<br>
+ =A0 =A0 =A0 return &amp;memcg_kswapd_control.waitq;<br>
+}<br>
+<br>
+static int __init memcg_kswapd_init(void)<br>
+{<br>
+<br>
+ =A0 =A0 =A0 int i, nr_threads;<br>
+<br>
+ =A0 =A0 =A0 spin_lock_init(&amp;memcg_kswapd_control.lock);<br>
+ =A0 =A0 =A0 INIT_LIST_HEAD(&amp;memcg_kswapd_control.list);<br>
+ =A0 =A0 =A0 init_waitqueue_head(&amp;memcg_kswapd_control.waitq);<br>
+<br>
+ =A0 =A0 =A0 nr_threads =3D int_sqrt(num_possible_cpus()) + 1;<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; nr_threads; i++)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kswapd_run(0, i + 1) =3D=3D -1)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+module_init(memcg_kswapd_init);<br>
+<br>
+<br>
=A0static struct cftype mem_cgroup_files[] =3D {<br>
 =A0 =A0 =A0 =A0{<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D &quot;usage_in_bytes&quot;,<br>
@@ -4935,33 +5055,6 @@ int mem_cgroup_watermark_ok(struct mem_c<br>
 =A0 =A0 =A0 =A0return ret;<br>
=A0}<br>
<br>
-int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd *kswapd_p=
)<br>
-{<br>
- =A0 =A0 =A0 if (!mem || !kswapd_p)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
-<br>
- =A0 =A0 =A0 mem-&gt;kswapd_wait =3D &amp;kswapd_p-&gt;kswapd_wait;<br>
- =A0 =A0 =A0 kswapd_p-&gt;kswapd_mem =3D mem;<br>
-<br>
- =A0 =A0 =A0 return css_id(&amp;mem-&gt;css);<br>
-}<br>
-<br>
-void mem_cgroup_clear_kswapd(struct mem_cgroup *mem)<br>
-{<br>
- =A0 =A0 =A0 if (mem)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;kswapd_wait =3D NULL;<br>
-<br>
- =A0 =A0 =A0 return;<br>
-}<br>
-<br>
-wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)<br>
-{<br>
- =A0 =A0 =A0 if (!mem)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
-<br>
- =A0 =A0 =A0 return mem-&gt;kswapd_wait;<br>
-}<br>
-<br>
=A0int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)<br>
=A0{<br>
 =A0 =A0 =A0 =A0if (!mem)<br>
@@ -4970,22 +5063,6 @@ int mem_cgroup_last_scanned_node(struct<br>
 =A0 =A0 =A0 =A0return mem-&gt;last_scanned_node;<br>
=A0}<br>
<br>
-static inline<br>
-void wake_memcg_kswapd(struct mem_cgroup *mem)<br>
-{<br>
- =A0 =A0 =A0 wait_queue_head_t *wait;<br>
-<br>
- =A0 =A0 =A0 if (!mem || !mem-&gt;high_wmark_distance)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
-<br>
- =A0 =A0 =A0 wait =3D mem-&gt;kswapd_wait;<br>
-<br>
- =A0 =A0 =A0 if (!wait || !waitqueue_active(wait))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
-<br>
- =A0 =A0 =A0 wake_up_interruptible(wait);<br>
-}<br>
-<br>
=A0static int mem_cgroup_soft_limit_tree_init(void)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct mem_cgroup_tree_per_node *rtpn;<br>
@@ -5069,6 +5146,8 @@ mem_cgroup_create(struct cgroup_subsys *<br>
 =A0 =A0 =A0 =A0atomic_set(&amp;mem-&gt;refcnt, 1);<br>
 =A0 =A0 =A0 =A0mem-&gt;move_charge_at_immigrate =3D 0;<br>
 =A0 =A0 =A0 =A0mutex_init(&amp;mem-&gt;thresholds_lock);<br>
+ =A0 =A0 =A0 init_waitqueue_head(&amp;mem-&gt;memcg_kswapd_end);<br>
+ =A0 =A0 =A0 INIT_LIST_HEAD(&amp;mem-&gt;memcg_kswapd_wait_list);<br>
 =A0 =A0 =A0 =A0return &amp;mem-&gt;css;<br>
=A0free_out:<br>
 =A0 =A0 =A0 =A0__mem_cgroup_free(mem);<br>
@@ -5089,7 +5168,6 @@ static void mem_cgroup_destroy(struct cg<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem =3D mem_cgroup_from_cont(cont);<br>
<br>
- =A0 =A0 =A0 kswapd_stop(0, mem);<br>
 =A0 =A0 =A0 =A0mem_cgroup_put(mem);<br>
=A0}<br>
<br>
Index: mmotm-Apr14/include/linux/swap.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/include/linux/swap.h<br>
+++ mmotm-Apr14/include/linux/swap.h<br>
@@ -28,9 +28,8 @@ static inline int current_is_kswapd(void<br>
<br>
=A0struct kswapd {<br>
 =A0 =A0 =A0 =A0struct task_struct *kswapd_task;<br>
- =A0 =A0 =A0 wait_queue_head_t kswapd_wait;<br>
+ =A0 =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
 =A0 =A0 =A0 =A0pg_data_t *kswapd_pgdat;<br>
- =A0 =A0 =A0 struct mem_cgroup *kswapd_mem;<br>
=A0};<br>
<br>
=A0int kswapd(void *p);<br>
@@ -307,8 +306,8 @@ static inline void scan_unevictable_unre<br>
=A0}<br>
=A0#endif<br>
<br>
-extern int kswapd_run(int nid, struct mem_cgroup *mem);<br>
-extern void kswapd_stop(int nid, struct mem_cgroup *mem);<br>
+extern int kswapd_run(int nid, int id);<br>
+extern void kswapd_stop(int nid);<br>
<br>
=A0#ifdef CONFIG_MMU<br>
=A0/* linux/mm/shmem.c */<br>
Index: mmotm-Apr14/mm/page_alloc.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/mm/page_alloc.c<br>
+++ mmotm-Apr14/mm/page_alloc.c<br>
@@ -4199,6 +4199,7 @@ static void __paginginit free_area_init_<br>
<br>
 =A0 =A0 =A0 =A0pgdat_resize_init(pgdat);<br>
 =A0 =A0 =A0 =A0pgdat-&gt;nr_zones =3D 0;<br>
+ =A0 =A0 =A0 init_waitqueue_head(&amp;pgdat-&gt;kswapd_wait);<br>
 =A0 =A0 =A0 =A0pgdat-&gt;kswapd_max_order =3D 0;<br>
 =A0 =A0 =A0 =A0pgdat_page_cgroup_init(pgdat);<br>
<br>
Index: mmotm-Apr14/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/mm/vmscan.c<br>
+++ mmotm-Apr14/mm/vmscan.c<br>
@@ -2256,7 +2256,7 @@ static bool pgdat_balanced(pg_data_t *pg<br>
 =A0 =A0 =A0 =A0return balanced_pages &gt; (present_pages &gt;&gt; 2);<br>
=A0}<br>
<br>
-#define is_global_kswapd(kswapd_p) (!(kswapd_p)-&gt;kswapd_mem)<br>
+#define is_global_kswapd(kswapd_p) ((kswapd_p)-&gt;kswapd_pgdat)<br>
<br>
=A0/* is kswapd sleeping prematurely? */<br>
=A0static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remai=
ning,<br>
@@ -2599,50 +2599,56 @@ static void kswapd_try_to_sleep(struct k<br>
 =A0 =A0 =A0 =A0long remaining =3D 0;<br>
 =A0 =A0 =A0 =A0DEFINE_WAIT(wait);<br>
 =A0 =A0 =A0 =A0pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
- =A0 =A0 =A0 wait_queue_head_t *wait_h =3D &amp;kswapd_p-&gt;kswapd_wait;<=
br>
+ =A0 =A0 =A0 wait_queue_head_t *wait_h =3D kswapd_p-&gt;kswapd_wait;<br>
<br>
 =A0 =A0 =A0 =A0if (freezing(current) || kthread_should_stop())<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
<br>
 =A0 =A0 =A0 =A0prepare_to_wait(wait_h, &amp;wait, TASK_INTERRUPTIBLE);<br>
<br>
- =A0 =A0 =A0 if (!is_global_kswapd(kswapd_p)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
- =A0 =A0 =A0 }<br>
-<br>
- =A0 =A0 =A0 /* Try to sleep for a short interval */<br>
- =A0 =A0 =A0 if (!sleeping_prematurely(pgdat, order, remaining, classzone_=
idx)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 remaining =3D schedule_timeout(HZ/10);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(wait_h, &amp;wait, TASK_INTER=
RUPTIBLE);<br>
- =A0 =A0 =A0 }<br>
-<br>
- =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0* After a short sleep, check if it was a premature sleep. =
If not, then<br>
- =A0 =A0 =A0 =A0* go fully to sleep until explicitly woken up.<br>
- =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 if (!sleeping_prematurely(pgdat, order, remaining, classzone_=
idx)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_sleep(pgdat-&gt;node_i=
d);<br>
+ =A0 =A0 =A0 if (is_global_kswapd(kswapd_p)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Try to sleep for a short interval */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_prematurely(pgdat, order,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 remaining, cl=
asszone_idx)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 remaining =3D schedule_timeou=
t(HZ/10);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(wait_h, &amp;wait=
);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(wait_h, &amp;=
wait, TASK_INTERRUPTIBLE);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat counters are not perfectly accura=
te and the estimated<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* value for counters such as NR_FREE_PAGES=
 can deviate from the<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* true value by nr_online_cpus * threshold=
. To avoid the zone<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* watermarks being breached while under pr=
essure, we reduce the<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* per-cpu vmstat threshold while kswapd is=
 awake and restore<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* them before going back to sleep.<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pgdat, calculate_n=
ormal_threshold);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pgdat, calculate_p=
ressure_threshold);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* After a short sleep, check if it was a p=
remature sleep.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If not, then go fully to sleep until exp=
licitly woken up.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_prematurely(pgdat, order,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 remaining, classzone_idx)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_sleep(=
pgdat-&gt;node_id);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat counters are not =
perfectly accurate and<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the estimated value for =
counters such as<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* NR_FREE_PAGES =A0can dev=
iate from the true value for<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* counters such as NR_FREE=
_PAGES can deviate from the<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0true value by nr_onli=
ne_cpus * threshold. To avoid<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0the zonewatermarks be=
ing breached while under<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0pressure, we reduce t=
he per-cpu vmstat threshold<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0while kswapd is awake=
 and restore them before<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0going back to sleep.<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pg=
dat,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 calculate_normal_threshold);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pg=
dat,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 calculate_pressure_threshold);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (remaining)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_even=
t(KSWAPD_LOW_WMARK_HIT_QUICKLY);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_even=
t(KSWAPD_HIGH_WMARK_HIT_QUICKLY);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
 =A0 =A0 =A0 =A0} else {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (remaining)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(KSWAPD_LOW_WMA=
RK_HIT_QUICKLY);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(KSWAPD_HIGH_WM=
ARK_HIT_QUICKLY);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* For now, we just check the remaining works=
.*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_kswapd_can_sleep())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
 =A0 =A0 =A0 =A0}<br>
-out:<br>
 =A0 =A0 =A0 =A0finish_wait(wait_h, &amp;wait);<br>
=A0}<br>
<br>
@@ -2651,8 +2657,8 @@ out:<br>
 =A0* The function is used for per-memcg LRU. It scanns all the zones of th=
e<br>
 =A0* node and returns the nr_scanned and nr_reclaimed.<br>
 =A0*/<br>
-static void balance_pgdat_node(pg_data_t *pgdat, int order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc)<br>
+static void shrink_memcg_node(pg_data_t *pgdat, int order,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_c=
ontrol *sc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0int i;<br>
 =A0 =A0 =A0 =A0unsigned long total_scanned =3D 0;<br>
@@ -2705,14 +2711,9 @@ static void balance_pgdat_node(pg_data_t<br>
 =A0* Per cgroup background reclaim.<br>
 =A0* TODO: Take off the order since memcg always do order 0<br>
 =A0*/<br>
-static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 int order)<br>
+static int shrink_mem_cgroup(struct mem_cgroup *mem_cont, int order)<br>
=A0{<br>
- =A0 =A0 =A0 int i, nid;<br>
- =A0 =A0 =A0 int start_node;<br>
- =A0 =A0 =A0 int priority;<br>
- =A0 =A0 =A0 bool wmark_ok;<br>
- =A0 =A0 =A0 int loop;<br>
+ =A0 =A0 =A0 int i, nid, priority, loop;<br>
 =A0 =A0 =A0 =A0pg_data_t *pgdat;<br>
 =A0 =A0 =A0 =A0nodemask_t do_nodes;<br>
 =A0 =A0 =A0 =A0unsigned long total_scanned;<br>
@@ -2726,43 +2727,34 @@ static unsigned long balance_mem_cgroup_<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem_cont,<br>
 =A0 =A0 =A0 =A0};<br>
<br>
-loop_again:<br>
 =A0 =A0 =A0 =A0do_nodes =3D NODE_MASK_NONE;<br>
 =A0 =A0 =A0 =A0sc.may_writepage =3D !laptop_mode;<br>
 =A0 =A0 =A0 =A0sc.nr_reclaimed =3D 0;<br>
 =A0 =A0 =A0 =A0total_scanned =3D 0;<br>
<br>
- =A0 =A0 =A0 for (priority =3D DEF_PRIORITY; priority &gt;=3D 0; priority-=
-) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D false;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop =3D 0;<br>
+ =A0 =A0 =A0 do_nodes =3D node_states[N_ONLINE];<br>
<br>
+ =A0 =A0 =A0 for (priority =3D DEF_PRIORITY;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 (priority &gt;=3D 0) &amp;&amp; (sc.nr_to_rec=
laim &gt; sc.nr_reclaimed);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority--) {<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* The swap token gets in the way of swapou=
t... */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!priority)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0disable_swap_token();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We&#39;ll scan a node given by memcg&#39=
;s logic. For avoiding<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* burning cpu, we have a limit of this loo=
p.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (loop =3D num_online_nodes();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (loop &gt; 0) &amp;&amp; !nod=
es_empty(do_nodes);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop--) {<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priority =3D=3D DEF_PRIORITY)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_nodes =3D node_states[N_ON=
LINE];<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (1) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nid =3D mem_cgroup_select_v=
ictim_node(mem_cont,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&amp;do_nodes);<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Indicate we have cycled =
the nodelist once<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: we might add MAX_R=
ECLAIM_LOOP for preventing<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* kswapd burning cpu cycle=
s.<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop =3D=3D 0) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_node =
=3D nid;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (nid =3D=3D start_n=
ode)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
-<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat =3D NODE_DATA(nid);<b=
r>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_pgdat_node(pgdat, ord=
er, &amp;sc);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_memcg_node(pgdat, orde=
r, &amp;sc);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scanned +=3D sc.nr_sc=
anned;<br>
-<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Set the node which has a=
t least one reclaimable<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * zone<br>
@@ -2770,10 +2762,8 @@ loop_again:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D pgdat-&gt;nr_zon=
es - 1; i &gt;=3D 0; i--) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone=
 *zone =3D pgdat-&gt;node_zones + i;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populate=
d_zone(zone))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 continue;<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgro=
up_mz_unreclaimable(mem_cont,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (populated=
_zone(zone) &amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !mem_=
cgroup_mz_unreclaimable(mem_cont,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0break;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
@@ -2781,36 +2771,18 @@ loop_again:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0node_clear(=
nid, do_nodes);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (mem_cgroup_watermark_ok=
(mem_cont,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CHARGE_WMARK_HIGH)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D =
true;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nodes_empty(do_nodes)) {<=
br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D =
true;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 CHARGE_WMARK_HIGH))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<b=
r>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (total_scanned &amp;&amp; priority &lt; =
DEF_PRIORITY - 2)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0congestion_wait(WRITE, HZ/1=
0);<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_reclaimed &gt;=3D SWAP_CLUSTER_MAX)=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
 =A0 =A0 =A0 =A0}<br>
=A0out:<br>
- =A0 =A0 =A0 if (!wmark_ok) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_freeze();<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto loop_again;<br>
- =A0 =A0 =A0 }<br>
-<br>
 =A0 =A0 =A0 =A0return sc.nr_reclaimed;<br>
=A0}<br>
=A0#else<br>
-static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,=
<br>
+static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int order)<br>
=A0{<br>
 =A0 =A0 =A0 =A0return 0;<br>
@@ -2836,8 +2808,7 @@ int kswapd(void *p)<br>
 =A0 =A0 =A0 =A0int classzone_idx;<br>
 =A0 =A0 =A0 =A0struct kswapd *kswapd_p =3D (struct kswapd *)p;<br>
 =A0 =A0 =A0 =A0pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
- =A0 =A0 =A0 struct mem_cgroup *mem =3D kswapd_p-&gt;kswapd_mem;<br>
- =A0 =A0 =A0 wait_queue_head_t *wait_h =3D &amp;kswapd_p-&gt;kswapd_wait;<=
br>
+ =A0 =A0 =A0 struct mem_cgroup *mem;<br>
 =A0 =A0 =A0 =A0struct task_struct *tsk =3D current;<br>
<br>
 =A0 =A0 =A0 =A0struct reclaim_state reclaim_state =3D {<br>
@@ -2848,7 +2819,6 @@ int kswapd(void *p)<br>
 =A0 =A0 =A0 =A0lockdep_set_current_reclaim_state(GFP_KERNEL);<br>
<br>
 =A0 =A0 =A0 =A0if (is_global_kswapd(kswapd_p)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(pgdat-&gt;kswapd_wait !=3D wait_h);<br=
>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cpumask =3D cpumask_of_node(pgdat-&gt;node_=
id);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!cpumask_empty(cpumask))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_cpus_allowed_ptr(tsk, c=
pumask);<br>
@@ -2908,18 +2878,20 @@ int kswapd(void *p)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (kthread_should_stop())<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We can speed up thawing tasks if we don&=
#39;t call balance_pgdat<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * after returning from the refrigerator<br=
>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_global_kswapd(kswapd_p=
)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmsc=
an_kswapd_wake(pgdat-&gt;node_id,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D bal=
ance_pgdat(pgdat, order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;classzone_idx);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_mem_c=
group_pgdat(mem, order);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_global_kswapd(kswapd_p)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_wake(p=
gdat-&gt;node_id, order);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D balance_pgdat(pgdat=
, order, &amp;classzone_idx);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_get_shrink=
_target();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cg=
roup(mem, order);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_put_shrink_target(=
mem);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0return 0;<br>
@@ -2942,13 +2914,13 @@ void wakeup_kswapd(struct zone *zone, in<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;kswapd_max_order =3D order;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;classzone_idx =3D min(pgdat-&gt;c=
lasszone_idx, classzone_idx);<br>
 =A0 =A0 =A0 =A0}<br>
- =A0 =A0 =A0 if (!waitqueue_active(pgdat-&gt;kswapd_wait))<br>
+ =A0 =A0 =A0 if (!waitqueue_active(&amp;pgdat-&gt;kswapd_wait))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
 =A0 =A0 =A0 =A0if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zon=
e), 0, 0))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
<br>
 =A0 =A0 =A0 =A0trace_mm_vmscan_wakeup_kswapd(pgdat-&gt;node_id, zone_idx(z=
one), order);<br>
- =A0 =A0 =A0 wake_up_interruptible(pgdat-&gt;kswapd_wait);<br>
+ =A0 =A0 =A0 wake_up_interruptible(&amp;pgdat-&gt;kswapd_wait);<br>
=A0}<br>
<br>
=A0/*<br>
@@ -3046,9 +3018,8 @@ static int __devinit cpu_callback(struct<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mask =3D cpumask_of_node(pg=
dat-&gt;node_id);<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D pgdat-&gt;kswapd_wai=
t;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D container_of(wai=
t, struct kswapd,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 kswapd_wait);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D &amp;pgdat-&gt;kswap=
d_wait;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D pgdat-&gt;kswapd=
;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_tsk =3D kswapd_p-&gt=
;kswapd_task;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cpumask_any_and(cpu_onl=
ine_mask, mask) &lt; nr_cpu_ids)<br>
@@ -3064,18 +3035,17 @@ static int __devinit cpu_callback(struct<br>
 =A0* This kswapd start function will be called by init and node-hot-add.<b=
r>
 =A0* On node-hot-add, kswapd will moved to proper cpus if cpus are hot-add=
ed.<br>
 =A0*/<br>
-int kswapd_run(int nid, struct mem_cgroup *mem)<br>
+int kswapd_run(int nid, int memcgid)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct task_struct *kswapd_tsk;<br>
 =A0 =A0 =A0 =A0pg_data_t *pgdat =3D NULL;<br>
 =A0 =A0 =A0 =A0struct kswapd *kswapd_p;<br>
 =A0 =A0 =A0 =A0static char name[TASK_COMM_LEN];<br>
- =A0 =A0 =A0 int memcg_id =3D -1;<br>
 =A0 =A0 =A0 =A0int ret =3D 0;<br>
<br>
- =A0 =A0 =A0 if (!mem) {<br>
+ =A0 =A0 =A0 if (!memcgid) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat =3D NODE_DATA(nid);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pgdat-&gt;kswapd_wait)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pgdat-&gt;kswapd)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;<br>
 =A0 =A0 =A0 =A0}<br>
<br>
@@ -3083,34 +3053,26 @@ int kswapd_run(int nid, struct mem_cgrou<br>
 =A0 =A0 =A0 =A0if (!kswapd_p)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;<br>
<br>
- =A0 =A0 =A0 init_waitqueue_head(&amp;kswapd_p-&gt;kswapd_wait);<br>
-<br>
- =A0 =A0 =A0 if (!mem) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D &amp;kswapd_p-&gt;k=
swapd_wait;<br>
+ =A0 =A0 =A0 if (!memcgid) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd =3D kswapd_p;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_wait =3D &amp;pgdat-&gt;k=
swapd_wait;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0snprintf(name, TASK_COMM_LEN, &quot;kswapd_=
%d&quot;, nid);<br>
 =A0 =A0 =A0 =A0} else {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_id =3D mem_cgroup_init_kswapd(mem, kswa=
pd_p);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcg_id) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(kswapd_p);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, TASK_COMM_LEN, &quot;memcg_%d&=
quot;, memcg_id);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_wait =3D mem_cgroup_kswap=
d_waitq();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, TASK_COMM_LEN, &quot;memcg_%d&=
quot;, memcgid);<br>
 =A0 =A0 =A0 =A0}<br>
<br>
 =A0 =A0 =A0 =A0kswapd_tsk =3D kthread_run(kswapd, kswapd_p, name);<br>
 =A0 =A0 =A0 =A0if (IS_ERR(kswapd_tsk)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* failure at boot is fatal */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(system_state =3D=3D SYSTEM_BOOTING);=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcgid) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR &quot;Faile=
d to start kswapd on node %d\n&quot;,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nid);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D NUL=
L;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR &quot;Failed =
to start kswapd on memcg %d\n&quot;,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_id);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_clear_kswapd(mem);=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd =3D NULL;<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR &quot;Failed =
to start kswapd on memcg\n&quot;);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(kswapd_p);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -1;<br>
 =A0 =A0 =A0 =A0} else<br>
@@ -3121,23 +3083,14 @@ int kswapd_run(int nid, struct mem_cgrou<br>
=A0/*<br>
 =A0* Called by memory hotplug when all memory in a node is offlined.<br>
 =A0*/<br>
-void kswapd_stop(int nid, struct mem_cgroup *mem)<br>
+void kswapd_stop(int nid)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct task_struct *kswapd_tsk =3D NULL;<br>
 =A0 =A0 =A0 =A0struct kswapd *kswapd_p =3D NULL;<br>
- =A0 =A0 =A0 wait_queue_head_t *wait;<br>
-<br>
- =A0 =A0 =A0 if (!mem)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D NODE_DATA(nid)-&gt;kswapd_wait;<br>
- =A0 =A0 =A0 else<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D mem_cgroup_kswapd_wait(mem);<br>
-<br>
- =A0 =A0 =A0 if (wait) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D container_of(wait, struct kswapd=
, kswapd_wait);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_tsk =3D kswapd_p-&gt;kswapd_task;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_task =3D NULL;<br>
- =A0 =A0 =A0 }<br>
<br>
+ =A0 =A0 =A0 kswapd_p =3D NODE_DATA(nid)-&gt;kswapd;<br>
+ =A0 =A0 =A0 kswapd_tsk =3D kswapd_p-&gt;kswapd_task;<br>
+ =A0 =A0 =A0 kswapd_p-&gt;kswapd_task =3D NULL;<br>
 =A0 =A0 =A0 =A0if (kswapd_tsk)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kthread_stop(kswapd_tsk);<br>
<br>
@@ -3150,7 +3103,7 @@ static int __init kswapd_init(void)<br>
<br>
 =A0 =A0 =A0 =A0swap_setup();<br>
 =A0 =A0 =A0 =A0for_each_node_state(nid, N_HIGH_MEMORY)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(nid, NULL);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(nid, 0);<br>
 =A0 =A0 =A0 =A0hotcpu_notifier(cpu_callback, 0);<br>
 =A0 =A0 =A0 =A0return 0;<br>
=A0}<br>
Index: mmotm-Apr14/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/include/linux/memcontrol.h<br>
+++ mmotm-Apr14/include/linux/memcontrol.h<br>
@@ -94,6 +94,11 @@ extern int mem_cgroup_last_scanned_node(<br>
=A0extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0const nodemask_t *nodes);<br>
<br>
+extern bool mem_cgroup_kswapd_can_sleep(void);<br>
+extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);<br>
+extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);<br>
+extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);<br>
+<br>
=A0static inline<br>
=A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup =
*cgroup)<br>
=A0{<br>
Index: mmotm-Apr14/mm/memory_hotplug.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/mm/memory_hotplug.c<br>
+++ mmotm-Apr14/mm/memory_hotplug.c<br>
@@ -463,7 +463,7 @@ int __ref online_pages(unsigned long pfn<br>
 =A0 =A0 =A0 =A0init_per_zone_wmark_min();<br>
<br>
 =A0 =A0 =A0 =A0if (onlined_pages) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(zone_to_nid(zone), NULL);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(zone_to_nid(zone), 0);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0node_set_state(zone_to_nid(zone), N_HIGH_ME=
MORY);<br>
 =A0 =A0 =A0 =A0}<br>
<br>
@@ -898,7 +898,7 @@ repeat:<br>
<br>
 =A0 =A0 =A0 =A0if (!node_present_pages(node)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0node_clear_state(node, N_HIGH_MEMORY);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_stop(node, NULL);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_stop(node);<br>
 =A0 =A0 =A0 =A0}<br>
<br>
 =A0 =A0 =A0 =A0vm_total_pages =3D nr_free_pagecache_pages();<br>
<br>
</blockquote></div><br>

--0016360e3f5c2fa2a004a1686bfe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
