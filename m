Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A734A6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:57:03 -0500 (EST)
Received: by yw-out-1718.google.com with SMTP id 9so520916ywk.26
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 02:57:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090210184055.6FCB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090210184055.6FCB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Tue, 10 Feb 2009 19:57:01 +0900
Message-ID: <28c262360902100257o6a8e2374v42f1ae906c53bcec@mail.gmail.com>
Subject: Re: [PATCH] mm: remove zone->prev_prioriy
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Kosaki-san.

As you know, prev_priority is used as a measure of how much stress page reclaim.
But now we doesn't need it due to split-lru's way.

I think it would be better to remain why prev_priority isn't needed any more
and how split-lru can replace prev_priority's role in changelog.

In future, it help mm newbies understand change history, I think.

On Tue, Feb 10, 2009 at 6:42 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> KAMEZAWA Hiroyuki sugessted to remove zone->prev_priority.
> it's because Split-LRU VM doesn't use this parameter at all.
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |   27 -------------------------
>  include/linux/mmzone.h     |   15 --------------
>  mm/memcontrol.c            |   31 -----------------------------
>  mm/page_alloc.c            |    2 -
>  mm/vmscan.c                |   48 ++-------------------------------------------
>  mm/vmstat.c                |    2 -
>  6 files changed, 3 insertions(+), 122 deletions(-)
>
> Index: b/mm/memcontrol.c
> ===================================================================
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -150,8 +150,6 @@ struct mem_cgroup {
>        */
>        spinlock_t reclaim_param_lock;
>
> -       int     prev_priority;  /* for recording reclaim priority */
> -
>        /*
>         * While reclaiming in a hiearchy, we cache the last child we
>         * reclaimed from. Protected by hierarchy_mutex
> @@ -464,35 +462,6 @@ int mem_cgroup_calc_mapped_ratio(struct
>        return (int)((rss * 100L) / total);
>  }
>
> -/*
> - * prev_priority control...this will be used in memory reclaim path.
> - */
> -int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
> -{
> -       int prev_priority;
> -
> -       spin_lock(&mem->reclaim_param_lock);
> -       prev_priority = mem->prev_priority;
> -       spin_unlock(&mem->reclaim_param_lock);
> -
> -       return prev_priority;
> -}
> -
> -void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem, int priority)
> -{
> -       spin_lock(&mem->reclaim_param_lock);
> -       if (priority < mem->prev_priority)
> -               mem->prev_priority = priority;
> -       spin_unlock(&mem->reclaim_param_lock);
> -}
> -
> -void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem, int priority)
> -{
> -       spin_lock(&mem->reclaim_param_lock);
> -       mem->prev_priority = priority;
> -       spin_unlock(&mem->reclaim_param_lock);
> -}
> -
>  static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
>  {
>        unsigned long active;
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1174,20 +1174,6 @@ done:
>  }
>
>  /*
> - * We are about to scan this zone at a certain priority level.  If that priority
> - * level is smaller (ie: more urgent) than the previous priority, then note
> - * that priority level within the zone.  This is done so that when the next
> - * process comes in to scan this zone, it will immediately start out at this
> - * priority level rather than having to build up its own scanning priority.
> - * Here, this priority affects only the reclaim-mapped threshold.
> - */
> -static inline void note_zone_scanning_priority(struct zone *zone, int priority)
> -{
> -       if (priority < zone->prev_priority)
> -               zone->prev_priority = priority;
> -}
> -
> -/*
>  * This moves pages from the active list to the inactive list.
>  *
>  * We move them the other way if the page is referenced by one or more
> @@ -1553,22 +1539,18 @@ static void shrink_zones(int priority, s
>                if (scanning_global_lru(sc)) {
>                        if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>                                continue;
> -                       note_zone_scanning_priority(zone, priority);
>
>                        if (zone_is_all_unreclaimable(zone) &&
>                                                priority != DEF_PRIORITY)
>                                continue;       /* Let kswapd poll it */
> -                       sc->all_unreclaimable = 0;
> +
>                } else {
>                        /*
>                         * Ignore cpuset limitation here. We just want to reduce
>                         * # of used pages by us regardless of memory shortage.
>                         */
> -                       sc->all_unreclaimable = 0;
> -                       mem_cgroup_note_reclaim_priority(sc->mem_cgroup,
> -                                                       priority);
>                }
> -
> +               sc->all_unreclaimable = 0;
>                shrink_zone(priority, zone, sc);
>        }
>  }
> @@ -1676,11 +1658,8 @@ out:
>
>                        if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>                                continue;
> -
> -                       zone->prev_priority = priority;
>                }
> -       } else
> -               mem_cgroup_record_reclaim_priority(sc->mem_cgroup, priority);
> +       }
>
>        delayacct_freepages_end();
>
> @@ -1769,11 +1748,6 @@ static unsigned long balance_pgdat(pg_da
>                .mem_cgroup = NULL,
>                .isolate_pages = isolate_pages_global,
>        };
> -       /*
> -        * temp_priority is used to remember the scanning priority at which
> -        * this zone was successfully refilled to free_pages == pages_high.
> -        */
> -       int temp_priority[MAX_NR_ZONES];
>
>  loop_again:
>        total_scanned = 0;
> @@ -1781,9 +1755,6 @@ loop_again:
>        sc.may_writepage = !laptop_mode;
>        count_vm_event(PAGEOUTRUN);
>
> -       for (i = 0; i < pgdat->nr_zones; i++)
> -               temp_priority[i] = DEF_PRIORITY;
> -
>        for (priority = DEF_PRIORITY; priority >= 0; priority--) {
>                int end_zone = 0;       /* Inclusive.  0 = ZONE_DMA */
>                unsigned long lru_pages = 0;
> @@ -1854,9 +1825,7 @@ loop_again:
>                        if (!zone_watermark_ok(zone, order, zone->pages_high,
>                                               end_zone, 0))
>                                all_zones_ok = 0;
> -                       temp_priority[i] = priority;
>                        sc.nr_scanned = 0;
> -                       note_zone_scanning_priority(zone, priority);
>                        /*
>                         * We put equal pressure on every zone, unless one
>                         * zone has way too many pages free already.
> @@ -1903,16 +1872,6 @@ loop_again:
>                        break;
>        }
>  out:
> -       /*
> -        * Note within each zone the priority level at which this zone was
> -        * brought into a happy state.  So that the next thread which scans this
> -        * zone will start out at that priority level.
> -        */
> -       for (i = 0; i < pgdat->nr_zones; i++) {
> -               struct zone *zone = pgdat->node_zones + i;
> -
> -               zone->prev_priority = temp_priority[i];
> -       }
>        if (!all_zones_ok) {
>                cond_resched();
>
> @@ -2321,7 +2280,6 @@ static int __zone_reclaim(struct zone *z
>                 */
>                priority = ZONE_RECLAIM_PRIORITY;
>                do {
> -                       note_zone_scanning_priority(zone, priority);
>                        shrink_zone(priority, zone, &sc);
>                        priority--;
>                } while (priority >= 0 && sc.nr_reclaimed < nr_pages);
> Index: b/include/linux/mmzone.h
> ===================================================================
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -337,21 +337,6 @@ struct zone {
>        atomic_long_t           vm_stat[NR_VM_ZONE_STAT_ITEMS];
>
>        /*
> -        * prev_priority holds the scanning priority for this zone.  It is
> -        * defined as the scanning priority at which we achieved our reclaim
> -        * target at the previous try_to_free_pages() or balance_pgdat()
> -        * invokation.
> -        *
> -        * We use prev_priority as a measure of how much stress page reclaim is
> -        * under - it drives the swappiness decision: whether to unmap mapped
> -        * pages.
> -        *
> -        * Access to both this field is quite racy even on uniprocessor.  But
> -        * it is expected to average out OK.
> -        */
> -       int prev_priority;
> -
> -       /*
>         * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
>         * this zone's LRU.  Maintained by the pageout code.
>         */
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3516,8 +3516,6 @@ static void __paginginit free_area_init_
>                zone_seqlock_init(zone);
>                zone->zone_pgdat = pgdat;
>
> -               zone->prev_priority = DEF_PRIORITY;
> -
>                zone_pcp_init(zone);
>                for_each_lru(l) {
>                        INIT_LIST_HEAD(&zone->lru[l].list);
> Index: b/mm/vmstat.c
> ===================================================================
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -775,11 +775,9 @@ static void zoneinfo_show_print(struct s
>        }
>        seq_printf(m,
>                   "\n  all_unreclaimable: %u"
> -                  "\n  prev_priority:     %i"
>                   "\n  start_pfn:         %lu"
>                   "\n  inactive_ratio:    %u",
>                           zone_is_all_unreclaimable(zone),
> -                  zone->prev_priority,
>                   zone->zone_start_pfn,
>                   zone->inactive_ratio);
>        seq_putc(m, '\n');
> Index: b/include/linux/memcontrol.h
> ===================================================================
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -88,14 +88,7 @@ extern void mem_cgroup_end_migration(str
>  /*
>  * For memory reclaim.
>  */
> -extern int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem);
>  extern long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem);
> -
> -extern int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem);
> -extern void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
> -                                                       int priority);
> -extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
> -                                                       int priority);
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>                                       struct zone *zone,
> @@ -209,31 +202,11 @@ static inline void mem_cgroup_end_migrat
>  {
>  }
>
> -static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
> -{
> -       return 0;
> -}
> -
>  static inline int mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem)
>  {
>        return 0;
>  }
>
> -static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
> -{
> -       return 0;
> -}
> -
> -static inline void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
> -                                               int priority)
> -{
> -}
> -
> -static inline void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
> -                                               int priority)
> -{
> -}
> -
>  static inline bool mem_cgroup_disabled(void)
>  {
>        return true;
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
