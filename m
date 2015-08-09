Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id E80BB6B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 11:39:18 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so51441551qkd.3
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 08:39:18 -0700 (PDT)
Received: from nm11-vm1.bullet.mail.bf1.yahoo.com (nm11-vm1.bullet.mail.bf1.yahoo.com. [98.139.213.152])
        by mx.google.com with ESMTPS id d92si29266366qge.71.2015.08.09.08.39.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 09 Aug 2015 08:39:17 -0700 (PDT)
Date: Sun, 9 Aug 2015 15:37:59 +0000 (UTC)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Message-ID: <1086308416.1472237.1439134679684.JavaMail.yahoo@mail.yahoo.com>
In-Reply-To: <1438619141-22215-1-git-send-email-vbabka@suse.cz>
References: <1438619141-22215-1-git-send-email-vbabka@suse.cz>
Subject: Re: [RFC v3 1/2] mm, compaction: introduce kcompactd
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pintu Kumar <pintu.k@samsung.com>

Hi,



----- Original Message -----
> From: Vlastimil Babka <vbabka@suse.cz>
> To: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org; Andrew Morton <akpm@linux-foundation.org>; Hugh Dickins <hughd@google.com>; Andrea Arcangeli <aarcange@redhat.com>; Kirill A. Shutemov <kirill.shutemov@linux.intel.com>; Rik van Riel <riel@redhat.com>; Mel Gorman <mgorman@suse.de>; David Rientjes <rientjes@google.com>; Joonsoo Kim <iamjoonsoo.kim@lge.com>; Vlastimil Babka <vbabka@suse.cz>
> Sent: Monday, 3 August 2015 9:55 PM
> Subject: [RFC v3 1/2] mm, compaction: introduce kcompactd
> 
> v3: drop all changes to hugepages, just focus on kcompactd. Reworked
>     interactions with kswapd, no more periodic wakeups. Use
>     sysctl_extfrag_threshold for now. Loosely based on suggestions from Mel
>     Gorman and David Rientjes. Thanks.
>     Based on v4.2-rc4, only compile-tested. Will run some benchmarks, posting
>     now to keep discussions going and focus on kcompactd only.
> 
> Memory compaction can be currently performed in several contexts:
> 
> - kswapd balancing a zone after a high-order allocation failure
> - direct compaction to satisfy a high-order allocation, including THP page
>   fault attemps
> - khugepaged trying to collapse a hugepage
> - manually from /proc
> 
> The purpose of compaction is two-fold. The obvious purpose is to satisfy a
> (pending or future) high-order allocation, and is easy to evaluate. The other
> purpose is to keep overal memory fragmentation low and help the
> anti-fragmentation mechanism. The success wrt the latter purpose is more
> difficult to evaluate though.
> 
> The current situation wrt the purposes has a few drawbacks:
> 
> - compaction is invoked only when a high-order page or hugepage is not
>   available (or manually). This might be too late for the purposes of keeping
>   memory fragmentation low.
> - direct compaction increases latency of allocations. Again, it would be
>   better if compaction was performed asynchronously to keep fragmentation low,
>   before the allocation itself comes.
> - (a special case of the previous) the cost of compaction during THP page
>   faults can easily offset the benefits of THP.
> 
> To improve the situation, we should benefit from an equivalent of kswapd, but
> for compaction - i.e. a background thread which responds to fragmentation and
> the need for high-order allocations (including hugepages) somewhat proactively.
> 
> One possibility is to extend the responsibilities of kswapd, which could
> however complicate its design too much. It should be better to let kswapd
> handle reclaim, as order-0 allocations are often more critical than high-order
> ones.
> 
> Another possibility is to extend khugepaged, but this kthread is a single
> instance and tied to THP configs.
> 
> This patch goes with the option of a new set of per-node kthreads called
> kcompactd, and lays the foundations, without introducing any new tunables.
> The lifecycle mimics kswapd kthreads, including the memory hotplug hooks.
> 
> Waking up of the kcompactd threads is also tied to kswapd activity and follows
> these rules:
> - we don't want to affect any fastpaths, so wake up kcompactd only from the
>   slowpath, as it's done for kswapd
> - if kswapd is doing reclaim, it's more important than compaction, so 
> don't
>   invoke kcompactd until kswapd goes to sleep
> - the target order used for kswapd is passed to kcompactd
> 
> The kswapd compact/reclaim loop for high-order pages is left alone for now
> and precedes kcompactd wakeup, but this might be revisited later.

> 


kcompactd, will be really nice thing to have, but I oppose calling it from kswapd.
Because, just after kswapd, we already have direct_compact.
So it may end up in doing compaction 2 times.
Or, is it like, with kcompactd, we dont need direct_compact?

In embedded world situation is really worse.
As per my experience in embedded world, just compaction does not help always in longer run.

As I know there are already some Android model in market, that already run background compaction (from user space).
But still there are sluggishness issues due to bad memory state in the long run. 

In embedded world, the major problems are related to camera and browser use cases that requires almost order-8 allocations.
Also, for low RAM configurations (less than 512M, 256M etc.), the rate of failure of compaction is much higher than the rate of success.

How can we guarantee that kcompactd is suitable for all situations?

In an case, we need large amount of testing to cover all scenarios.
It should be called at the right time.
I dont have any data to present right now.
May be I will try to capture some data, and present here.

> In this patch, kcompactd uses the standard compaction_suitable() and
> compact_finished() criteria, which means it will most likely have nothing left
> to do after kswapd is finished. This is changed to rely on
> sysctl_extfrag_threshold by the next patch for review and dicussion purposes.
> 
> Other possible future uses for kcompactd include the ability to wake up
> kcompactd on demand in special situations, such as when hugepages are not
> available (currently not done due to __GFP_NO_KSWAPD) or when a fragmentation
> event (i.e. __rmqueue_fallback()). It's also possible to perform periodic
> compaction with kcompactd.
> 
> Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
> include/linux/compaction.h |  16 ++++
> include/linux/mmzone.h     |   7 +-
> mm/compaction.c            | 183 +++++++++++++++++++++++++++++++++++++++++++++
> mm/memory_hotplug.c        |  15 ++--
> mm/page_alloc.c            |   7 +-
> mm/vmscan.c                |  25 +++++--
> 6 files changed, 241 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index aa8f61c..8cd1fb5 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -51,6 +51,10 @@ extern void compaction_defer_reset(struct zone *zone, int 
> order,
>                 bool alloc_success);
> extern bool compaction_restarting(struct zone *zone, int order);
> 
> +extern int kcompactd_run(int nid);
> +extern void kcompactd_stop(int nid);
> +extern void wakeup_kcompactd(pg_data_t *pgdat, int order);
> +
> #else
> static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
>             unsigned int order, int alloc_flags,
> @@ -83,6 +87,18 @@ static inline bool compaction_deferred(struct zone *zone, int 
> order)
>     return true;
> }
> 
> +static int kcompactd_run(int nid)
> +{
> +    return 0;
> +}
> +static void kcompactd_stop(int nid)
> +{
> +}
> +
> +static void wakeup_kcompactd(pg_data_t *pgdat, int order)
> +{
> +}
> +
> #endif /* CONFIG_COMPACTION */
> 
> #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && 
> defined(CONFIG_NUMA)
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 754c259..423e88e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -752,6 +752,11 @@ typedef struct pglist_data {
>                        mem_hotplug_begin/end() */
>     int kswapd_max_order;
>     enum zone_type classzone_idx;
> +#ifdef CONFIG_COMPACTION
> +    int kcompactd_max_order;
> +    wait_queue_head_t kcompactd_wait;
> +    struct task_struct *kcompactd;
> +#endif
> #ifdef CONFIG_NUMA_BALANCING
>     /* Lock serializing the migrate rate limiting window */
>     spinlock_t numabalancing_migrate_lock;
> @@ -798,7 +803,7 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
> 
> extern struct mutex zonelists_mutex;
> void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
> -void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
> +bool wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
> bool zone_watermark_ok(struct zone *z, unsigned int order,
>         unsigned long mark, int classzone_idx, int alloc_flags);
> bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 018f08d..b051412 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -17,6 +17,9 @@
> #include <linux/balloon_compaction.h>
> #include <linux/page-isolation.h>
> #include <linux/kasan.h>
> +#include <linux/kthread.h>
> +#include <linux/freezer.h>
> +#include <linux/module.h>
> #include "internal.h"
> 
> #ifdef CONFIG_COMPACTION
> @@ -29,6 +32,7 @@ static inline void count_compact_events(enum vm_event_item 
> item, long delta)
> {
>     count_vm_events(item, delta);
> }
> +
> #else
> #define count_compact_event(item) do { } while (0)
> #define count_compact_events(item, delta) do { } while (0)
> @@ -1714,4 +1718,183 @@ void compaction_unregister_node(struct node *node)
> }
> #endif /* CONFIG_SYSFS && CONFIG_NUMA */
> 
> +static bool kcompactd_work_requested(pg_data_t *pgdat)
> +{
> +    return pgdat->kcompactd_max_order > 0;
> +}
> +
> +static bool kcompactd_node_suitable(pg_data_t *pgdat, int order)
> +{
> +    int zoneid;
> +    struct zone *zone;
> +
> +    for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> +        zone = &pgdat->node_zones[zoneid];
> +
> +        if (compaction_suitable(zone, order, 0, zoneid) ==
> +                        COMPACT_CONTINUE)
> +            return true;
> +    }
> +
> +    return false;
> +}
> +
> +static void kcompactd_do_work(pg_data_t *pgdat)
> +{
> +    /*
> +     * With no special task, compact all zones so that a page of requested
> +     * order is allocatable.
> +     */
> +    int zoneid;
> +    struct zone *zone;
> +    struct compact_control cc = {
> +        .order = pgdat->kcompactd_max_order,
> +        .mode = MIGRATE_SYNC_LIGHT,
> +        //TODO: do this or not?
> +        .ignore_skip_hint = true,
> +    };
> +
> +    for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> +
> +        zone = &pgdat->node_zones[zoneid];
> +        if (!populated_zone(zone))
> +            continue;
> +
> +        if (compaction_suitable(zone, cc.order, 0, zoneid) !=
> +                            COMPACT_CONTINUE)
> +            continue;
> +
> +        cc.nr_freepages = 0;
> +        cc.nr_migratepages = 0;
> +        cc.zone = zone;
> +        INIT_LIST_HEAD(&cc.freepages);
> +        INIT_LIST_HEAD(&cc.migratepages);
> +
> +        compact_zone(zone, &cc);
> +
> +        if (zone_watermark_ok(zone, cc.order,
> +                        low_wmark_pages(zone), 0, 0))
> +            compaction_defer_reset(zone, cc.order, false);
> +
> +        VM_BUG_ON(!list_empty(&cc.freepages));
> +        VM_BUG_ON(!list_empty(&cc.migratepages));
> +    }
> +
> +    /* Regardless of success, we are done until woken up next */
> +    pgdat->kcompactd_max_order = 0;
> +}
> +
> +void wakeup_kcompactd(pg_data_t *pgdat, int order)
> +{
> +    if (pgdat->kcompactd_max_order < order)
> +        pgdat->kcompactd_max_order = order;
> +
> +    if (!waitqueue_active(&pgdat->kcompactd_wait))
> +        return;
> +
> +    if (!kcompactd_node_suitable(pgdat, order))
> +        return;
> +
> +    wake_up_interruptible(&pgdat->kcompactd_wait);
> +}
> +
> +/*
> + * The background compaction daemon, started as a kernel thread
> + * from the init process.
> + */
> +static int kcompactd(void *p)
> +{
> +    pg_data_t *pgdat = (pg_data_t*)p;
> +    struct task_struct *tsk = current;
> +
> +    const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> +
> +    if (!cpumask_empty(cpumask))
> +        set_cpus_allowed_ptr(tsk, cpumask);
> +
> +    set_freezable();
> +
> +    while (!kthread_should_stop()) {
> +        wait_event_freezable(pgdat->kcompactd_wait,
> +                kcompactd_work_requested(pgdat));
> +
> +        kcompactd_do_work(pgdat);
> +    }
> +
> +    return 0;
> +}
> +
> +/*
> + * This kcompactd start function will be called by init and node-hot-add.
> + * On node-hot-add, kcompactd will moved to proper cpus if cpus are hot-added.
> + */
> +int kcompactd_run(int nid)
> +{
> +    pg_data_t *pgdat = NODE_DATA(nid);
> +    int ret = 0;
> +
> +    if (pgdat->kcompactd)
> +        return 0;
> +
> +    pgdat->kcompactd = kthread_run(kcompactd, pgdat, 
> "kcompactd%d", nid);
> +    if (IS_ERR(pgdat->kcompactd)) {
> +        pr_err("Failed to start kcompactd on node %d\n", nid);
> +        ret = PTR_ERR(pgdat->kcompactd);
> +        pgdat->kcompactd = NULL;
> +    }
> +    return ret;
> +}
> +
> +/*
> + * Called by memory hotplug when all memory in a node is offlined. Caller must
> + * hold mem_hotplug_begin/end().
> + */
> +void kcompactd_stop(int nid)
> +{
> +    struct task_struct *kcompactd = NODE_DATA(nid)->kcompactd;
> +
> +    if (kcompactd) {
> +        kthread_stop(kcompactd);
> +        NODE_DATA(nid)->kcompactd = NULL;
> +    }
> +}
> +
> +/*
> + * It's optimal to keep kcompactd on the same CPUs as their memory, but
> + * not required for correctness. So if the last cpu in a node goes
> + * away, we get changed to run anywhere: as the first one comes back,
> + * restore their cpu bindings.
> + */
> +static int cpu_callback(struct notifier_block *nfb, unsigned long action,
> +            void *hcpu)
> +{
> +    int nid;
> +
> +    if (action == CPU_ONLINE || action == CPU_ONLINE_FROZEN) {
> +        for_each_node_state(nid, N_MEMORY) {
> +            pg_data_t *pgdat = NODE_DATA(nid);
> +            const struct cpumask *mask;
> +
> +            mask = cpumask_of_node(pgdat->node_id);
> +
> +            if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
> +                /* One of our CPUs online: restore mask */
> +                set_cpus_allowed_ptr(pgdat->kcompactd, mask);
> +        }
> +    }
> +    return NOTIFY_OK;
> +}
> +
> +static int __init kcompactd_init(void)
> +{
> +    int nid;
> +
> +    for_each_node_state(nid, N_MEMORY)
> +        kcompactd_run(nid);
> +    hotcpu_notifier(cpu_callback, 0);
> +    return 0;
> +}
> +
> +module_init(kcompactd_init)
> +
> #endif /* CONFIG_COMPACTION */
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 26fbba7..b2c695d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -32,6 +32,7 @@
> #include <linux/hugetlb.h>
> #include <linux/memblock.h>
> #include <linux/bootmem.h>
> +#include <linux/compaction.h>
> 
> #include <asm/tlbflush.h>
> 
> @@ -1001,7 +1002,7 @@ int __ref online_pages(unsigned long pfn, unsigned long 
> nr_pages, int online_typ
>     arg.nr_pages = nr_pages;
>     node_states_check_changes_online(nr_pages, zone, &arg);
> 
> -    nid = pfn_to_nid(pfn);
> +    nid = zone_to_nid(zone);
> 
>     ret = memory_notify(MEM_GOING_ONLINE, &arg);
>     ret = notifier_to_errno(ret);
> @@ -1041,7 +1042,7 @@ int __ref online_pages(unsigned long pfn, unsigned long 
> nr_pages, int online_typ
>     pgdat_resize_unlock(zone->zone_pgdat, &flags);
> 
>     if (onlined_pages) {
> -        node_states_set_node(zone_to_nid(zone), &arg);
> +        node_states_set_node(nid, &arg);
>         if (need_zonelists_rebuild)
>             build_all_zonelists(NULL, NULL);
>         else
> @@ -1052,8 +1053,10 @@ int __ref online_pages(unsigned long pfn, unsigned long 
> nr_pages, int online_typ
> 
>     init_per_zone_wmark_min();
> 
> -    if (onlined_pages)
> -        kswapd_run(zone_to_nid(zone));
> +    if (onlined_pages) {
> +        kswapd_run(nid);
> +        kcompactd_run(nid);
> +    }
> 
>     vm_total_pages = nr_free_pagecache_pages();
> 
> @@ -1783,8 +1786,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
>         zone_pcp_update(zone);
> 
>     node_states_clear_node(node, &arg);
> -    if (arg.status_change_nid >= 0)
> +    if (arg.status_change_nid >= 0) {
>         kswapd_stop(node);
> +        kcompactd_stop(node);
> +    }
> 
>     vm_total_pages = nr_free_pagecache_pages();
>     writeback_set_ratelimit();
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ef19f22..ae3e795 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1,4 +1,5 @@
> /*
> + *
>   *  linux/mm/page_alloc.c
>   *
>   *  Manages the free list, the system allocates free pages here.
> @@ -2894,7 +2895,8 @@ static void wake_all_kswapds(unsigned int order, const 
> struct alloc_context *ac)
> 
>     for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
>                         ac->high_zoneidx, ac->nodemask)
> -        wakeup_kswapd(zone, order, zone_idx(ac->preferred_zone));
> +        if (!wakeup_kswapd(zone, order, zone_idx(ac->preferred_zone)))
> +            wakeup_kcompactd(zone->zone_pgdat, order);
> }
> 
> static inline int
> @@ -5293,6 +5295,9 @@ static void __paginginit free_area_init_core(struct 
> pglist_data *pgdat,
> #endif
>     init_waitqueue_head(&pgdat->kswapd_wait);
>     init_waitqueue_head(&pgdat->pfmemalloc_wait);
> +#ifdef CONFIG_COMPACTION
> +    init_waitqueue_head(&pgdat->kcompactd_wait);
> +#endif
>     pgdat_page_ext_init(pgdat);
> 
>     for (j = 0; j < MAX_NR_ZONES; j++) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e61445d..075f53c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3360,6 +3360,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int 
> order, int classzone_idx)
>          */
>         reset_isolation_suitable(pgdat);
> 
> +        /*
> +         * We have balanced the zone, but kcompactd might want to
> +         * further reduce the fragmentation.
> +         */
> +        wakeup_kcompactd(pgdat, order);
> +
>         if (!kthread_should_stop())
>             schedule();
> 
> @@ -3484,28 +3490,37 @@ static int kswapd(void *p)
> 
> /*
>   * A zone is low on free memory, so wake its kswapd task to service it.
> + *
> + * Returns false when wakeup was skipped because zone was already balanced.
> + * Returns true when wakeup was either done or skipped for other reasons.
> + *
> + * This is to decide when to try waking up kcompactd, which should be done
> + * only when kswapd is not running. Kcompactd may decide to perform more work
> + * than what satisfies zone_balanced().
>   */
> -void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
> +bool wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
> {
>     pg_data_t *pgdat;
> 
>     if (!populated_zone(zone))
> -        return;
> +        return true;
> 
>     if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
> -        return;
> +        return true;
>     pgdat = zone->zone_pgdat;
>     if (pgdat->kswapd_max_order < order) {
>         pgdat->kswapd_max_order = order;
>         pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
>     }
>     if (!waitqueue_active(&pgdat->kswapd_wait))
> -        return;
> +        return true;
>     if (zone_balanced(zone, order, 0, 0))
> -        return;
> +        return false;
> 
>     trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
>     wake_up_interruptible(&pgdat->kswapd_wait);
> +
> +    return true;
> }
> 
> #ifdef CONFIG_HIBERNATION
> -- 
> 2.4.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> 
> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
