Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AC085900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 14:45:05 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3IIitTm017696
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:44:55 -0700
Received: from qwe5 (qwe5.prod.google.com [10.241.194.5])
	by hpaq1.eem.corp.google.com with ESMTP id p3IIhAua026573
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:44:53 -0700
Received: by qwe5 with SMTP id 5so3816845qwe.23
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:44:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikEumBS7aA=tJaVzv0O8j0bsSXpCw@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-5-git-send-email-yinghan@google.com>
	<BANLkTikEumBS7aA=tJaVzv0O8j0bsSXpCw@mail.gmail.com>
Date: Mon, 18 Apr 2011 11:44:53 -0700
Message-ID: <BANLkTi=31xdufaepTnhRiaTNscU09XyNRw@mail.gmail.com>
Subject: Re: [PATCH V5 04/10] Infrastructure to support per-memcg reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee086f94504a135c93d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cd68ee086f94504a135c93d
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Apr 17, 2011 at 7:11 PM, Minchan Kim <minchan.kim@gmail.com> wrote:

> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> > Add the kswapd_mem field in kswapd descriptor which links the kswapd
> > kernel thread to a memcg. The per-memcg kswapd is sleeping in the wait
> > queue headed at kswapd_wait field of the kswapd descriptor.
> >
> > The kswapd() function is now shared between global and per-memcg kswapd.
> It
> > is passed in with the kswapd descriptor which contains the information of
> > either node or memcg. Then the new function balance_mem_cgroup_pgdat is
> > invoked if it is per-mem kswapd thread, and the implementation of the
> function
> > is on the following patch.
> >
> > changelog v4..v3:
> > 1. fix up the kswapd_run and kswapd_stop for online_pages() and
> offline_pages.
> > 2. drop the PF_MEMALLOC flag for memcg kswapd for now per KAMAZAWA's
> request.
> >
> > changelog v3..v2:
> > 1. split off from the initial patch which includes all changes of the
> following
> > three patches.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/memcontrol.h |    5 ++
> >  include/linux/swap.h       |    5 +-
> >  mm/memcontrol.c            |   29 ++++++++
> >  mm/memory_hotplug.c        |    4 +-
> >  mm/vmscan.c                |  156
> ++++++++++++++++++++++++++++++--------------
> >  5 files changed, 147 insertions(+), 52 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 3ece36d..f7ffd1f 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -24,6 +24,7 @@ struct mem_cgroup;
> >  struct page_cgroup;
> >  struct page;
> >  struct mm_struct;
> > +struct kswapd;
> >
> >  /* Stats that can be updated by kernel. */
> >  enum mem_cgroup_page_stat_item {
> > @@ -83,6 +84,10 @@ int task_in_mem_cgroup(struct task_struct *task, const
> struct mem_cgroup *mem);
> >  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page
> *page);
> >  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> >  extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int
> charge_flags);
> > +extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
> > +                                 struct kswapd *kswapd_p);
> > +extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
> > +extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup
> *mem);
> >
> >  static inline
> >  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index f43d406..17e0511 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -30,6 +30,7 @@ struct kswapd {
> >        struct task_struct *kswapd_task;
> >        wait_queue_head_t kswapd_wait;
> >        pg_data_t *kswapd_pgdat;
> > +       struct mem_cgroup *kswapd_mem;
> >  };
> >
> >  int kswapd(void *p);
> > @@ -303,8 +304,8 @@ static inline void
> scan_unevictable_unregister_node(struct node *node)
> >  }
> >  #endif
> >
> > -extern int kswapd_run(int nid);
> > -extern void kswapd_stop(int nid);
> > +extern int kswapd_run(int nid, struct mem_cgroup *mem);
> > +extern void kswapd_stop(int nid, struct mem_cgroup *mem);
> >
> >  #ifdef CONFIG_MMU
> >  /* linux/mm/shmem.c */
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 76ad009..8761a6f 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -278,6 +278,8 @@ struct mem_cgroup {
> >         */
> >        u64 high_wmark_distance;
> >        u64 low_wmark_distance;
> > +
> > +       wait_queue_head_t *kswapd_wait;
>
>
> Like I mentioned in [1/10], personally, I like including kswapd
> instead of kswapd_wait. Just personal opinion. Feel free to ignore.
>

thank you for your comments.

If that makes more sense, I am ok to make the change. But I would like to
keep this as the current version and do a separate change after the basic
stuff in. Hope that works.

>
> >  };
> >
> >  /* Stuffs for move charges at task migration. */
> > @@ -4670,6 +4672,33 @@ int mem_cgroup_watermark_ok(struct mem_cgroup
> *mem,
> >        return ret;
> >  }
> >
> > +int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd
> *kswapd_p)
> > +{
> > +       if (!mem || !kswapd_p)
> > +               return 0;
> > +
> > +       mem->kswapd_wait = &kswapd_p->kswapd_wait;
> > +       kswapd_p->kswapd_mem = mem;
> > +
> > +       return css_id(&mem->css);
> > +}
> > +
> > +void mem_cgroup_clear_kswapd(struct mem_cgroup *mem)
> > +{
> > +       if (mem)
> > +               mem->kswapd_wait = NULL;
> > +
> > +       return;
> > +}
> > +
> > +wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
> > +{
> > +       if (!mem)
> > +               return NULL;
> > +
> > +       return mem->kswapd_wait;
> > +}
> > +
> >  static int mem_cgroup_soft_limit_tree_init(void)
> >  {
> >        struct mem_cgroup_tree_per_node *rtpn;
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 321fc74..2f78ff6 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -462,7 +462,7 @@ int online_pages(unsigned long pfn, unsigned long
> nr_pages)
> >        setup_per_zone_wmarks();
> >        calculate_zone_inactive_ratio(zone);
> >        if (onlined_pages) {
> > -               kswapd_run(zone_to_nid(zone));
> > +               kswapd_run(zone_to_nid(zone), NULL);
> >                node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> >        }
> >
> > @@ -897,7 +897,7 @@ repeat:
> >        calculate_zone_inactive_ratio(zone);
> >        if (!node_present_pages(node)) {
> >                node_clear_state(node, N_HIGH_MEMORY);
> > -               kswapd_stop(node);
> > +               kswapd_stop(node, NULL);
> >        }
> >
> >        vm_total_pages = nr_free_pagecache_pages();
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 61fb96e..06036d2 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2241,6 +2241,8 @@ static bool pgdat_balanced(pg_data_t *pgdat,
> unsigned long balanced_pages,
> >        return balanced_pages > (present_pages >> 2);
> >  }
> >
> > +#define is_node_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
>
> In memcg, we already have a similar thing "scanning_global_lru".
> How about using "global" term?
>

hmm. ok.


>
> > +
> >  /* is kswapd sleeping prematurely? */
> >  static int sleeping_prematurely(struct kswapd *kswapd, int order,
> >                                long remaining, int classzone_idx)
> > @@ -2249,11 +2251,16 @@ static int sleeping_prematurely(struct kswapd
> *kswapd, int order,
> >        unsigned long balanced = 0;
> >        bool all_zones_ok = true;
> >        pg_data_t *pgdat = kswapd->kswapd_pgdat;
> > +       struct mem_cgroup *mem = kswapd->kswapd_mem;
> >
> >        /* If a direct reclaimer woke kswapd within HZ/10, it's premature
> */
> >        if (remaining)
> >                return true;
> >
> > +       /* Doesn't support for per-memcg reclaim */
> > +       if (mem)
> > +               return false;
> > +
>
> How about is_global_kswapd instead of checking wheterh mem field is NULL or
> not?
>

make sense. will change.


>
> >        /* Check the watermark levels */
> >        for (i = 0; i < pgdat->nr_zones; i++) {
> >                struct zone *zone = pgdat->node_zones + i;
> > @@ -2596,19 +2603,25 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >         * go fully to sleep until explicitly woken up.
> >         */
> >        if (!sleeping_prematurely(kswapd_p, order, remaining,
> classzone_idx)) {
> > -               trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > +               if (is_node_kswapd(kswapd_p)) {
> > +                       trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> >
> > -               /*
> > -                * vmstat counters are not perfectly accurate and the
> estimated
> > -                * value for counters such as NR_FREE_PAGES can deviate
> from the
> > -                * true value by nr_online_cpus * threshold. To avoid the
> zone
> > -                * watermarks being breached while under pressure, we
> reduce the
> > -                * per-cpu vmstat threshold while kswapd is awake and
> restore
> > -                * them before going back to sleep.
> > -                */
> > -               set_pgdat_percpu_threshold(pgdat,
> calculate_normal_threshold);
> > -               schedule();
> > -               set_pgdat_percpu_threshold(pgdat,
> calculate_pressure_threshold);
> > +                       /*
> > +                        * vmstat counters are not perfectly accurate and
> the
> > +                        * estimated value for counters such as
> NR_FREE_PAGES
> > +                        * can deviate from the true value by
> nr_online_cpus *
> > +                        * threshold. To avoid the zone watermarks being
> > +                        * breached while under pressure, we reduce the
> per-cpu
> > +                        * vmstat threshold while kswapd is awake and
> restore
> > +                        * them before going back to sleep.
> > +                        */
> > +                       set_pgdat_percpu_threshold(pgdat,
> > +
>  calculate_normal_threshold);
> > +                       schedule();
> > +                       set_pgdat_percpu_threshold(pgdat,
> > +
> calculate_pressure_threshold);
> > +               } else
> > +                       schedule();
> >        } else {
> >                if (remaining)
> >                        count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> > @@ -2618,6 +2631,12 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >        finish_wait(wait_h, &wait);
> >  }
> >
> > +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> > +                                                       int order)
> > +{
> > +       return 0;
> > +}
> > +
> >  /*
> >  * The background pageout daemon, started as a kernel thread
> >  * from the init process.
> > @@ -2637,6 +2656,7 @@ int kswapd(void *p)
> >        int classzone_idx;
> >        struct kswapd *kswapd_p = (struct kswapd *)p;
> >        pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> > +       struct mem_cgroup *mem = kswapd_p->kswapd_mem;
> >        wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
> >        struct task_struct *tsk = current;
> >
> > @@ -2647,10 +2667,12 @@ int kswapd(void *p)
> >
> >        lockdep_set_current_reclaim_state(GFP_KERNEL);
> >
> > -       BUG_ON(pgdat->kswapd_wait != wait_h);
> > -       cpumask = cpumask_of_node(pgdat->node_id);
> > -       if (!cpumask_empty(cpumask))
> > -               set_cpus_allowed_ptr(tsk, cpumask);
> > +       if (is_node_kswapd(kswapd_p)) {
> > +               BUG_ON(pgdat->kswapd_wait != wait_h);
> > +               cpumask = cpumask_of_node(pgdat->node_id);
> > +               if (!cpumask_empty(cpumask))
> > +                       set_cpus_allowed_ptr(tsk, cpumask);
> > +       }
> >        current->reclaim_state = &reclaim_state;
> >
> >        /*
> > @@ -2665,7 +2687,10 @@ int kswapd(void *p)
> >         * us from recursively trying to free more memory as we're
> >         * trying to free the first piece of memory in the first place).
> >         */
> > -       tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> > +       if (is_node_kswapd(kswapd_p))
> > +               tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> > +       else
> > +               tsk->flags |= PF_SWAPWRITE | PF_KSWAPD;
> >        set_freezable();
> >
> >        order = 0;
> > @@ -2675,24 +2700,29 @@ int kswapd(void *p)
> >                int new_classzone_idx;
> >                int ret;
> >
> > -               new_order = pgdat->kswapd_max_order;
> > -               new_classzone_idx = pgdat->classzone_idx;
> > -               pgdat->kswapd_max_order = 0;
> > -               pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > -               if (order < new_order || classzone_idx >
> new_classzone_idx) {
> > -                       /*
> > -                        * Don't sleep if someone wants a larger 'order'
> > -                        * allocation or has tigher zone constraints
> > -                        */
> > -                       order = new_order;
> > -                       classzone_idx = new_classzone_idx;
> > -               } else {
> > -                       kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> > -                       order = pgdat->kswapd_max_order;
> > -                       classzone_idx = pgdat->classzone_idx;
> > +               if (is_node_kswapd(kswapd_p)) {
> > +                       new_order = pgdat->kswapd_max_order;
> > +                       new_classzone_idx = pgdat->classzone_idx;
> >                        pgdat->kswapd_max_order = 0;
> >                        pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > -               }
> > +                       if (order < new_order ||
> > +                                       classzone_idx >
> new_classzone_idx) {
> > +                               /*
> > +                                * Don't sleep if someone wants a larger
> 'order'
> > +                                * allocation or has tigher zone
> constraints
> > +                                */
> > +                               order = new_order;
> > +                               classzone_idx = new_classzone_idx;
> > +                       } else {
> > +                               kswapd_try_to_sleep(kswapd_p, order,
> > +                                                   classzone_idx);
> > +                               order = pgdat->kswapd_max_order;
> > +                               classzone_idx = pgdat->classzone_idx;
> > +                               pgdat->kswapd_max_order = 0;
> > +                               pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > +                       }
> > +               } else
> > +                       kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> >
> >                ret = try_to_freeze();
> >                if (kthread_should_stop())
> > @@ -2703,8 +2733,13 @@ int kswapd(void *p)
> >                 * after returning from the refrigerator
> >                 */
> >                if (!ret) {
> > -                       trace_mm_vmscan_kswapd_wake(pgdat->node_id,
> order);
> > -                       order = balance_pgdat(pgdat, order,
> &classzone_idx);
> > +                       if (is_node_kswapd(kswapd_p)) {
> > +
> trace_mm_vmscan_kswapd_wake(pgdat->node_id,
> > +                                                               order);
> > +                               order = balance_pgdat(pgdat, order,
> > +                                                       &classzone_idx);
> > +                       } else
> > +                               balance_mem_cgroup_pgdat(mem, order);
> >                }
> >        }
> >        return 0;
> > @@ -2849,30 +2884,53 @@ static int __devinit cpu_callback(struct
> notifier_block *nfb,
> >  * This kswapd start function will be called by init and node-hot-add.
> >  * On node-hot-add, kswapd will moved to proper cpus if cpus are
> hot-added.
> >  */
> > -int kswapd_run(int nid)
> > +int kswapd_run(int nid, struct mem_cgroup *mem)
> >  {
> > -       pg_data_t *pgdat = NODE_DATA(nid);
> >        struct task_struct *kswapd_thr;
> > +       pg_data_t *pgdat = NULL;
> >        struct kswapd *kswapd_p;
> > +       static char name[TASK_COMM_LEN];
> > +       int memcg_id;
> >        int ret = 0;
> >
> > -       if (pgdat->kswapd_wait)
> > -               return 0;
> > +       if (!mem) {
> > +               pgdat = NODE_DATA(nid);
> > +               if (pgdat->kswapd_wait)
> > +                       return ret;
> > +       }
> >
> >        kswapd_p = kzalloc(sizeof(struct kswapd), GFP_KERNEL);
> >        if (!kswapd_p)
> >                return -ENOMEM;
> >
> >        init_waitqueue_head(&kswapd_p->kswapd_wait);
> > -       pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
> > -       kswapd_p->kswapd_pgdat = pgdat;
> >
> > -       kswapd_thr = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
> > +       if (!mem) {
> > +               pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
> > +               kswapd_p->kswapd_pgdat = pgdat;
> > +               snprintf(name, TASK_COMM_LEN, "kswapd_%d", nid);
> > +       } else {
> > +               memcg_id = mem_cgroup_init_kswapd(mem, kswapd_p);
> > +               if (!memcg_id) {
> > +                       kfree(kswapd_p);
> > +                       return ret;
> > +               }
> > +               snprintf(name, TASK_COMM_LEN, "memcg_%d", memcg_id);
> > +       }
> > +
> > +       kswapd_thr = kthread_run(kswapd, kswapd_p, name);
> >        if (IS_ERR(kswapd_thr)) {
> >                /* failure at boot is fatal */
> >                BUG_ON(system_state == SYSTEM_BOOTING);
> > -               printk("Failed to start kswapd on node %d\n",nid);
> > -               pgdat->kswapd_wait = NULL;
> > +               if (!mem) {
> > +                       printk(KERN_ERR "Failed to start kswapd on node
> %d\n",
> > +                                                               nid);
> > +                       pgdat->kswapd_wait = NULL;
> > +               } else {
> > +                       printk(KERN_ERR "Failed to start kswapd on memcg
> %d\n",
> > +
> memcg_id);
> > +                       mem_cgroup_clear_kswapd(mem);
> > +               }
> >                kfree(kswapd_p);
> >                ret = -1;
> >        } else
> > @@ -2883,15 +2941,17 @@ int kswapd_run(int nid)
> >  /*
> >  * Called by memory hotplug when all memory in a node is offlined.
> >  */
> > -void kswapd_stop(int nid)
> > +void kswapd_stop(int nid, struct mem_cgroup *mem)
> >  {
> >        struct task_struct *kswapd_thr = NULL;
> >        struct kswapd *kswapd_p = NULL;
> >        wait_queue_head_t *wait;
> >
> > -       pg_data_t *pgdat = NODE_DATA(nid);
> > +       if (!mem)
> > +               wait = NODE_DATA(nid)->kswapd_wait;
> > +       else
> > +               wait = mem_cgroup_kswapd_wait(mem);
> >
> > -       wait = pgdat->kswapd_wait;
> >        if (wait) {
> >                kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> >                kswapd_thr = kswapd_p->kswapd_task;
> > @@ -2910,7 +2970,7 @@ static int __init kswapd_init(void)
> >
> >        swap_setup();
> >        for_each_node_state(nid, N_HIGH_MEMORY)
> > -               kswapd_run(nid);
> > +               kswapd_run(nid, NULL);
> >        hotcpu_notifier(cpu_callback, 0);
> >        return 0;
> >  }
> > --
> > 1.7.3.1
> >
> >
>
> Let me ask a question.
>
> What's the effect of kswapd_try_to_sleep in memcg?
>
> As I look code, sleeping_prematurely always return false in case of
> memcg.

that is right.


> So kswapd_try_to_sleep can sleep short time and then sleep
> until next wakeup. It means it doesn't have any related to
> kswapd_try_to_sleep's goal. So I hope you remove hack of memcg in
> kswapd_try_to_sleep and just calling schedule in kswapd function for
> sleeping memcg_kswapd.
>

 But I don't look at further patches in series so I may miss something.

No, you are not missing something. The memcg kswapd doesn't have the
sleeping_prematurely logic in this patch. I was thinking to add similar
check on zone->all_unreclaimable but instead check all the zones per-memcg.
That sounds like much overhead to me, so I simply put the schedule() for
memcg in this patch but changed the APIs kswapd_try_to_sleep, and
sleeping_prematurely only.

I might be able to revert those two API changes from this patch, and add
them later as part of the real memcg sleeping_prematurely patch.

--Ying


> --
> Kind regards,
> Minchan Kim
>

--000e0cd68ee086f94504a135c93d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, Apr 17, 2011 at 7:11 PM, Minchan=
 Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan=
.kim@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Sat, Apr 16, 2011 at 8:23 AM, Ying Han=
 &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&gt; wrote=
:<br>
&gt; Add the kswapd_mem field in kswapd descriptor which links the kswapd<b=
r>
&gt; kernel thread to a memcg. The per-memcg kswapd is sleeping in the wait=
<br>
&gt; queue headed at kswapd_wait field of the kswapd descriptor.<br>
&gt;<br>
&gt; The kswapd() function is now shared between global and per-memcg kswap=
d. It<br>
&gt; is passed in with the kswapd descriptor which contains the information=
 of<br>
&gt; either node or memcg. Then the new function balance_mem_cgroup_pgdat i=
s<br>
&gt; invoked if it is per-mem kswapd thread, and the implementation of the =
function<br>
&gt; is on the following patch.<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. fix up the kswapd_run and kswapd_stop for online_pages() and offlin=
e_pages.<br>
&gt; 2. drop the PF_MEMALLOC flag for memcg kswapd for now per KAMAZAWA&#39=
;s request.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. split off from the initial patch which includes all changes of the =
following<br>
&gt; three patches.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h | =A0 =A05 ++<br>
&gt; =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A05 +-<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 29 ++++++++<br>
&gt; =A0mm/memory_hotplug.c =A0 =A0 =A0 =A0| =A0 =A04 +-<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0156 +++++++++++++++=
+++++++++++++++--------------<br>
&gt; =A05 files changed, 147 insertions(+), 52 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index 3ece36d..f7ffd1f 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -24,6 +24,7 @@ struct mem_cgroup;<br>
&gt; =A0struct page_cgroup;<br>
&gt; =A0struct page;<br>
&gt; =A0struct mm_struct;<br>
&gt; +struct kswapd;<br>
&gt;<br>
&gt; =A0/* Stats that can be updated by kernel. */<br>
&gt; =A0enum mem_cgroup_page_stat_item {<br>
&gt; @@ -83,6 +84,10 @@ int task_in_mem_cgroup(struct task_struct *task, co=
nst struct mem_cgroup *mem);<br>
&gt; =A0extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page =
*page);<br>
&gt; =A0extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *=
p);<br>
&gt; =A0extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int char=
ge_flags);<br>
&gt; +extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stru=
ct kswapd *kswapd_p);<br>
&gt; +extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);<br>
&gt; +extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *m=
em);<br>
&gt;<br>
&gt; =A0static inline<br>
&gt; =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cg=
roup *cgroup)<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index f43d406..17e0511 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -30,6 +30,7 @@ struct kswapd {<br>
&gt; =A0 =A0 =A0 =A0struct task_struct *kswapd_task;<br>
&gt; =A0 =A0 =A0 =A0wait_queue_head_t kswapd_wait;<br>
&gt; =A0 =A0 =A0 =A0pg_data_t *kswapd_pgdat;<br>
&gt; + =A0 =A0 =A0 struct mem_cgroup *kswapd_mem;<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0int kswapd(void *p);<br>
&gt; @@ -303,8 +304,8 @@ static inline void scan_unevictable_unregister_nod=
e(struct node *node)<br>
&gt; =A0}<br>
&gt; =A0#endif<br>
&gt;<br>
&gt; -extern int kswapd_run(int nid);<br>
&gt; -extern void kswapd_stop(int nid);<br>
&gt; +extern int kswapd_run(int nid, struct mem_cgroup *mem);<br>
&gt; +extern void kswapd_stop(int nid, struct mem_cgroup *mem);<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_MMU<br>
&gt; =A0/* linux/mm/shmem.c */<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 76ad009..8761a6f 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -278,6 +278,8 @@ struct mem_cgroup {<br>
&gt; =A0 =A0 =A0 =A0 */<br>
&gt; =A0 =A0 =A0 =A0u64 high_wmark_distance;<br>
&gt; =A0 =A0 =A0 =A0u64 low_wmark_distance;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
<br>
<br>
</div></div>Like I mentioned in [1/10], personally, I like including kswapd=
<br>
instead of kswapd_wait. Just personal opinion. Feel free to ignore.<br></bl=
ockquote><div><br></div><div>thank you for your comments.</div><div><br></d=
iv><div>If that makes more sense, I am ok to make the change. But I would l=
ike to keep this as the current version and do a=A0separate=A0change after =
the basic stuff in. Hope that works.</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0/* Stuffs for move charges at task migration. */<br>
&gt; @@ -4670,6 +4672,33 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *=
mem,<br>
&gt; =A0 =A0 =A0 =A0return ret;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd *ksw=
apd_p)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 if (!mem || !kswapd_p)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 mem-&gt;kswapd_wait =3D &amp;kswapd_p-&gt;kswapd_wait;<b=
r>
&gt; + =A0 =A0 =A0 kswapd_p-&gt;kswapd_mem =3D mem;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return css_id(&amp;mem-&gt;css);<br>
&gt; +}<br>
&gt; +<br>
&gt; +void mem_cgroup_clear_kswapd(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 if (mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;kswapd_wait =3D NULL;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return;<br>
&gt; +}<br>
&gt; +<br>
&gt; +wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return mem-&gt;kswapd_wait;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_soft_limit_tree_init(void)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0struct mem_cgroup_tree_per_node *rtpn;<br>
&gt; diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c<br>
&gt; index 321fc74..2f78ff6 100644<br>
&gt; --- a/mm/memory_hotplug.c<br>
&gt; +++ b/mm/memory_hotplug.c<br>
&gt; @@ -462,7 +462,7 @@ int online_pages(unsigned long pfn, unsigned long =
nr_pages)<br>
&gt; =A0 =A0 =A0 =A0setup_per_zone_wmarks();<br>
&gt; =A0 =A0 =A0 =A0calculate_zone_inactive_ratio(zone);<br>
&gt; =A0 =A0 =A0 =A0if (onlined_pages) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(zone_to_nid(zone));<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(zone_to_nid(zone), NULL);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0node_set_state(zone_to_nid(zone), N_HIG=
H_MEMORY);<br>
&gt; =A0 =A0 =A0 =A0}<br>
&gt;<br>
&gt; @@ -897,7 +897,7 @@ repeat:<br>
&gt; =A0 =A0 =A0 =A0calculate_zone_inactive_ratio(zone);<br>
&gt; =A0 =A0 =A0 =A0if (!node_present_pages(node)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0node_clear_state(node, N_HIGH_MEMORY);<=
br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_stop(node);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_stop(node, NULL);<br>
&gt; =A0 =A0 =A0 =A0}<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0vm_total_pages =3D nr_free_pagecache_pages();<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 61fb96e..06036d2 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -2241,6 +2241,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, uns=
igned long balanced_pages,<br>
&gt; =A0 =A0 =A0 =A0return balanced_pages &gt; (present_pages &gt;&gt; 2);<=
br>
&gt; =A0}<br>
&gt;<br>
&gt; +#define is_node_kswapd(kswapd_p) (!(kswapd_p)-&gt;kswapd_mem)<br>
<br>
</div></div>In memcg, we already have a similar thing &quot;scanning_global=
_lru&quot;.<br>
How about using &quot;global&quot; term?<br></blockquote><div><br></div><di=
v>hmm. ok. =A0</div><div>=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; +<br>
&gt; =A0/* is kswapd sleeping prematurely? */<br>
&gt; =A0static int sleeping_prematurely(struct kswapd *kswapd, int order,<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0long re=
maining, int classzone_idx)<br>
&gt; @@ -2249,11 +2251,16 @@ static int sleeping_prematurely(struct kswapd =
*kswapd, int order,<br>
&gt; =A0 =A0 =A0 =A0unsigned long balanced =3D 0;<br>
&gt; =A0 =A0 =A0 =A0bool all_zones_ok =3D true;<br>
&gt; =A0 =A0 =A0 =A0pg_data_t *pgdat =3D kswapd-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 =A0 struct mem_cgroup *mem =3D kswapd-&gt;kswapd_mem;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0/* If a direct reclaimer woke kswapd within HZ/10, it&#=
39;s premature */<br>
&gt; =A0 =A0 =A0 =A0if (remaining)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 /* Doesn&#39;t support for per-memcg reclaim */<br>
&gt; + =A0 =A0 =A0 if (mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; +<br>
<br>
</div>How about is_global_kswapd instead of checking wheterh mem field is N=
ULL or not?<br></blockquote><div><br></div><div>make sense. will change.</d=
iv><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex;">

<div><div></div><div class=3D"h5"><br>
&gt; =A0 =A0 =A0 =A0/* Check the watermark levels */<br>
&gt; =A0 =A0 =A0 =A0for (i =3D 0; i &lt; pgdat-&gt;nr_zones; i++) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone =3D pgdat-&gt;node_zo=
nes + i;<br>
&gt; @@ -2596,19 +2603,25 @@ static void kswapd_try_to_sleep(struct kswapd =
*kswapd_p, int order,<br>
&gt; =A0 =A0 =A0 =A0 * go fully to sleep until explicitly woken up.<br>
&gt; =A0 =A0 =A0 =A0 */<br>
&gt; =A0 =A0 =A0 =A0if (!sleeping_prematurely(kswapd_p, order, remaining, c=
lasszone_idx)) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_sleep(pgdat-&gt;n=
ode_id);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_node_kswapd(kswapd_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_s=
leep(pgdat-&gt;node_id);<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat counters are not perfectly a=
ccurate and the estimated<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* value for counters such as NR_FREE_=
PAGES can deviate from the<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* true value by nr_online_cpus * thre=
shold. To avoid the zone<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* watermarks being breached while und=
er pressure, we reduce the<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* per-cpu vmstat threshold while kswa=
pd is awake and restore<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* them before going back to sleep.<br=
>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pgdat, calcul=
ate_normal_threshold);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pgdat, calcul=
ate_pressure_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat counters are=
 not perfectly accurate and the<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* estimated value for=
 counters such as NR_FREE_PAGES<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* can deviate from th=
e true value by nr_online_cpus *<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* threshold. To avoid=
 the zone watermarks being<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* breached while unde=
r pressure, we reduce the per-cpu<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat threshold wh=
ile kswapd is awake and restore<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* them before going b=
ack to sleep.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_thresho=
ld(pgdat,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0calculate_normal_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_thresho=
ld(pgdat,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 calculate_pressure_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; =A0 =A0 =A0 =A0} else {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (remaining)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count_vm_event(KSWAPD_L=
OW_WMARK_HIT_QUICKLY);<br>
&gt; @@ -2618,6 +2631,12 @@ static void kswapd_try_to_sleep(struct kswapd *=
kswapd_p, int order,<br>
&gt; =A0 =A0 =A0 =A0finish_wait(wait_h, &amp;wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_=
cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int order)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0/*<br>
&gt; =A0* The background pageout daemon, started as a kernel thread<br>
&gt; =A0* from the init process.<br>
&gt; @@ -2637,6 +2656,7 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0int classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0struct kswapd *kswapd_p =3D (struct kswapd *)p;<br>
&gt; =A0 =A0 =A0 =A0pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 =A0 struct mem_cgroup *mem =3D kswapd_p-&gt;kswapd_mem;<br>
&gt; =A0 =A0 =A0 =A0wait_queue_head_t *wait_h =3D &amp;kswapd_p-&gt;kswapd_=
wait;<br>
&gt; =A0 =A0 =A0 =A0struct task_struct *tsk =3D current;<br>
&gt;<br>
&gt; @@ -2647,10 +2667,12 @@ int kswapd(void *p)<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0lockdep_set_current_reclaim_state(GFP_KERNEL);<br>
&gt;<br>
&gt; - =A0 =A0 =A0 BUG_ON(pgdat-&gt;kswapd_wait !=3D wait_h);<br>
&gt; - =A0 =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;node_id);<br>
&gt; - =A0 =A0 =A0 if (!cpumask_empty(cpumask))<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk, cpumask);<br>
&gt; + =A0 =A0 =A0 if (is_node_kswapd(kswapd_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(pgdat-&gt;kswapd_wait !=3D wait_h=
);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;no=
de_id);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cpumask_empty(cpumask))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk=
, cpumask);<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 =A0current-&gt;reclaim_state =3D &amp;reclaim_state;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0/*<br>
&gt; @@ -2665,7 +2687,10 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 * us from recursively trying to free more memory as we=
&#39;re<br>
&gt; =A0 =A0 =A0 =A0 * trying to free the first piece of memory in the firs=
t place).<br>
&gt; =A0 =A0 =A0 =A0 */<br>
&gt; - =A0 =A0 =A0 tsk-&gt;flags |=3D PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAP=
D;<br>
&gt; + =A0 =A0 =A0 if (is_node_kswapd(kswapd_p))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk-&gt;flags |=3D PF_MEMALLOC | PF_SWAP=
WRITE | PF_KSWAPD;<br>
&gt; + =A0 =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk-&gt;flags |=3D PF_SWAPWRITE | PF_KSW=
APD;<br>
&gt; =A0 =A0 =A0 =A0set_freezable();<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0order =3D 0;<br>
&gt; @@ -2675,24 +2700,29 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int new_classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int ret;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D pgdat-&gt;kswapd_max_order=
;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_classzone_idx =3D pgdat-&gt;classzon=
e_idx;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_max_order =3D 0;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;classzone_idx =3D MAX_NR_ZONES=
 - 1;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (order &lt; new_order || classzone_id=
x &gt; new_classzone_idx) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don&#39;t sleep if =
someone wants a larger &#39;order&#39;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* allocation or has t=
igher zone constraints<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D new_order;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D new_cl=
asszone_idx;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswa=
pd_p, order, classzone_idx);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat-&gt;kswa=
pd_max_order;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D pgdat-=
&gt;classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_node_kswapd(kswapd_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D pgdat-&gt;=
kswapd_max_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_classzone_idx =3D pg=
dat-&gt;classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;kswapd_max_or=
der =3D 0;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;classzone_idx=
 =3D MAX_NR_ZONES - 1;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (order &lt; new_order=
 ||<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 classzone_idx &gt; new_classzone_idx) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don=
&#39;t sleep if someone wants a larger &#39;order&#39;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* all=
ocation or has tigher zone constraints<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =
=3D new_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzon=
e_idx =3D new_classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_t=
ry_to_sleep(kswapd_p, order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =
=3D pgdat-&gt;kswapd_max_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzon=
e_idx =3D pgdat-&gt;classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&g=
t;kswapd_max_order =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&g=
t;classzone_idx =3D MAX_NR_ZONES - 1;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswa=
pd_p, order, classzone_idx);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_freeze();<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (kthread_should_stop())<br>
&gt; @@ -2703,8 +2733,13 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * after returning from the refrigerato=
r<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_w=
ake(pgdat-&gt;node_id, order);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D balance_pgdat(=
pgdat, order, &amp;classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_node_kswapd(kswap=
d_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm=
_vmscan_kswapd_wake(pgdat-&gt;node_id,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =
=3D balance_pgdat(pgdat, order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_=
mem_cgroup_pgdat(mem, order);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
&gt; =A0 =A0 =A0 =A0}<br>
&gt; =A0 =A0 =A0 =A0return 0;<br>
&gt; @@ -2849,30 +2884,53 @@ static int __devinit cpu_callback(struct notif=
ier_block *nfb,<br>
&gt; =A0* This kswapd start function will be called by init and node-hot-ad=
d.<br>
&gt; =A0* On node-hot-add, kswapd will moved to proper cpus if cpus are hot=
-added.<br>
&gt; =A0*/<br>
&gt; -int kswapd_run(int nid)<br>
&gt; +int kswapd_run(int nid, struct mem_cgroup *mem)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; =A0 =A0 =A0 =A0struct task_struct *kswapd_thr;<br>
&gt; + =A0 =A0 =A0 pg_data_t *pgdat =3D NULL;<br>
&gt; =A0 =A0 =A0 =A0struct kswapd *kswapd_p;<br>
&gt; + =A0 =A0 =A0 static char name[TASK_COMM_LEN];<br>
&gt; + =A0 =A0 =A0 int memcg_id;<br>
&gt; =A0 =A0 =A0 =A0int ret =3D 0;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 if (pgdat-&gt;kswapd_wait)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; + =A0 =A0 =A0 if (!mem) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pgdat-&gt;kswapd_wait)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
&gt; + =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0kswapd_p =3D kzalloc(sizeof(struct kswapd), GFP_KERNEL)=
;<br>
&gt; =A0 =A0 =A0 =A0if (!kswapd_p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0init_waitqueue_head(&amp;kswapd_p-&gt;kswapd_wait);<br>
&gt; - =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D &amp;kswapd_p-&gt;kswapd_wait;=
<br>
&gt; - =A0 =A0 =A0 kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 kswapd_thr =3D kthread_run(kswapd, kswapd_p, &quot;kswap=
d%d&quot;, nid);<br>
&gt; + =A0 =A0 =A0 if (!mem) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D &amp;kswapd_p-=
&gt;kswapd_wait;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, TASK_COMM_LEN, &quot;kswa=
pd_%d&quot;, nid);<br>
&gt; + =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_id =3D mem_cgroup_init_kswapd(mem,=
 kswapd_p);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcg_id) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(kswapd_p);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, TASK_COMM_LEN, &quot;memc=
g_%d&quot;, memcg_id);<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 kswapd_thr =3D kthread_run(kswapd, kswapd_p, name);<br>
&gt; =A0 =A0 =A0 =A0if (IS_ERR(kswapd_thr)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* failure at boot is fatal */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(system_state =3D=3D SYSTEM_BOOTI=
NG);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(&quot;Failed to start kswapd on n=
ode %d\n&quot;,nid);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D NULL;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR &quot;Fa=
iled to start kswapd on node %d\n&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =
=3D NULL;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR &quot;Fa=
iled to start kswapd on memcg %d\n&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_id);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_clear_kswapd(=
mem);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(kswapd_p);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -1;<br>
&gt; =A0 =A0 =A0 =A0} else<br>
&gt; @@ -2883,15 +2941,17 @@ int kswapd_run(int nid)<br>
&gt; =A0/*<br>
&gt; =A0* Called by memory hotplug when all memory in a node is offlined.<b=
r>
&gt; =A0*/<br>
&gt; -void kswapd_stop(int nid)<br>
&gt; +void kswapd_stop(int nid, struct mem_cgroup *mem)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0struct task_struct *kswapd_thr =3D NULL;<br>
&gt; =A0 =A0 =A0 =A0struct kswapd *kswapd_p =3D NULL;<br>
&gt; =A0 =A0 =A0 =A0wait_queue_head_t *wait;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; + =A0 =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D NODE_DATA(nid)-&gt;kswapd_wait;=
<br>
&gt; + =A0 =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D mem_cgroup_kswapd_wait(mem);<br=
>
&gt;<br>
&gt; - =A0 =A0 =A0 wait =3D pgdat-&gt;kswapd_wait;<br>
&gt; =A0 =A0 =A0 =A0if (wait) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_p =3D container_of(wait, struct =
kswapd, kswapd_wait);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_thr =3D kswapd_p-&gt;kswapd_task=
;<br>
&gt; @@ -2910,7 +2970,7 @@ static int __init kswapd_init(void)<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0swap_setup();<br>
&gt; =A0 =A0 =A0 =A0for_each_node_state(nid, N_HIGH_MEMORY)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(nid, NULL);<br>
&gt; =A0 =A0 =A0 =A0hotcpu_notifier(cpu_callback, 0);<br>
&gt; =A0 =A0 =A0 =A0return 0;<br>
&gt; =A0}<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
&gt;<br>
<br>
</div></div>Let me ask a question.<br>
<br>
What&#39;s the effect of kswapd_try_to_sleep in memcg?<br>
<br>
As I look code, sleeping_prematurely always return false in case of<br>
memcg. </blockquote><div>that is right.</div><div>=A0</div><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex;">So kswapd_try_to_sleep can sleep short time and then sleep<=
br>

until next wakeup. It means it doesn&#39;t have any related to<br>
kswapd_try_to_sleep&#39;s goal. So I hope you remove hack of memcg in<br>
kswapd_try_to_sleep and just calling schedule in kswapd function for<br>
sleeping memcg_kswapd.<br></blockquote><div><br></div><div>=A0But I don&#39=
;t look at further patches in series so I may miss something.</div><div><br=
></div><div>No, you are not missing something. The memcg kswapd doesn&#39;t=
 have the sleeping_prematurely logic in this patch. I was thinking to add s=
imilar check on zone-&gt;all_unreclaimable but instead check all the zones =
per-memcg. That sounds like much overhead to me, so I simply put the schedu=
le() for memcg in this patch but changed the APIs kswapd_try_to_sleep, and =
sleeping_prematurely only.</div>
<div><br></div><div>I might be able to revert those two API changes from th=
is patch, and add them later as part of the real memcg sleeping_prematurely=
 patch.</div><div><br></div><div>--Ying</div><div><br></div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex;">

<br>
--<br>
Kind regards,<br>
<font color=3D"#888888">Minchan Kim<br>
</font></blockquote></div><br>

--000e0cd68ee086f94504a135c93d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
