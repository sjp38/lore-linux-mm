Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA9086B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 18:30:08 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id o4so104887373ywd.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 15:30:08 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j65sor4949266ywe.76.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Mar 2017 15:30:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170228214007.5621-2-hannes@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-2-hannes@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 2 Mar 2017 15:30:06 -0800
Message-ID: <CALvZod7NzuG7MRhPY4cVD1wXPu0yo1y=ELOpq6nCWSJ_fbk1Gg@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable nodes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Tue, Feb 28, 2017 at 1:39 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Jia He reports a problem with kswapd spinning at 100% CPU when
> requesting more hugepages than memory available in the system:
>
> $ echo 4000 >/proc/sys/vm/nr_hugepages
>
> top - 13:42:59 up  3:37,  1 user,  load average: 1.09, 1.03, 1.01
> Tasks:   1 total,   1 running,   0 sleeping,   0 stopped,   0 zombie
> %Cpu(s):  0.0 us, 12.5 sy,  0.0 ni, 85.5 id,  2.0 wa,  0.0 hi,  0.0 si,  0.0 st
> KiB Mem:  31371520 total, 30915136 used,   456384 free,      320 buffers
> KiB Swap:  6284224 total,   115712 used,  6168512 free.    48192 cached Mem
>
>   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
>    76 root      20   0       0      0      0 R 100.0 0.000 217:17.29 kswapd3
>
> At that time, there are no reclaimable pages left in the node, but as
> kswapd fails to restore the high watermarks it refuses to go to sleep.
>
> Kswapd needs to back away from nodes that fail to balance. Up until
> 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> kswapd had such a mechanism. It considered zones whose theoretically
> reclaimable pages it had reclaimed six times over as unreclaimable and
> backed away from them. This guard was erroneously removed as the patch
> changed the definition of a balanced node.
>
> However, simply restoring this code wouldn't help in the case reported
> here: there *are* no reclaimable pages that could be scanned until the
> threshold is met. Kswapd would stay awake anyway.
>
> Introduce a new and much simpler way of backing off. If kswapd runs
> through MAX_RECLAIM_RETRIES (16) cycles without reclaiming a single
> page, make it back off from the node. This is the same number of shots
> direct reclaim takes before declaring OOM. Kswapd will go to sleep on
> that node until a direct reclaimer manages to reclaim some pages, thus
> proving the node reclaimable again.
>

Should the condition of wait_event_killable in throttle_direct_reclaim
be changed to (pfmemalloc_watermark_ok(pgdat) ||
pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)?

> v2: move MAX_RECLAIM_RETRIES to mm/internal.h (Michal)
>
> Reported-by: Jia He <hejianet@gmail.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Tested-by: Jia He <hejianet@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/mmzone.h |  2 ++
>  mm/internal.h          |  6 ++++++
>  mm/page_alloc.c        |  9 ++-------
>  mm/vmscan.c            | 27 ++++++++++++++++++++-------
>  mm/vmstat.c            |  2 +-
>  5 files changed, 31 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 8e02b3750fe0..d2c50ab6ae40 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -630,6 +630,8 @@ typedef struct pglist_data {
>         int kswapd_order;
>         enum zone_type kswapd_classzone_idx;
>
> +       int kswapd_failures;            /* Number of 'reclaimed == 0' runs */
> +
>  #ifdef CONFIG_COMPACTION
>         int kcompactd_max_order;
>         enum zone_type kcompactd_classzone_idx;
> diff --git a/mm/internal.h b/mm/internal.h
> index ccfc2a2969f4..aae93e3fd984 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -81,6 +81,12 @@ static inline void set_page_refcounted(struct page *page)
>  extern unsigned long highest_memmap_pfn;
>
>  /*
> + * Maximum number of reclaim retries without progress before the OOM
> + * killer is consider the only way forward.
> + */
> +#define MAX_RECLAIM_RETRIES 16
> +
> +/*
>   * in mm/vmscan.c:
>   */
>  extern int isolate_lru_page(struct page *page);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 614cd0397ce3..f50e36e7b024 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3516,12 +3516,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  }
>
>  /*
> - * Maximum number of reclaim retries without any progress before OOM killer
> - * is consider as the only way to move forward.
> - */
> -#define MAX_RECLAIM_RETRIES 16
> -
> -/*
>   * Checks whether it makes sense to retry the reclaim to make a forward progress
>   * for the given allocation request.
>   * The reclaim feedback represented by did_some_progress (any progress during
> @@ -4527,7 +4521,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>                         K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
>                         K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
>                         node_page_state(pgdat, NR_PAGES_SCANNED),
> -                       !pgdat_reclaimable(pgdat) ? "yes" : "no");
> +                       pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
> +                               "yes" : "no");
>         }
>
>         for_each_populated_zone(zone) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 26c3b405ef34..407b27831ff7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2626,6 +2626,15 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>         } while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
>                                          sc->nr_scanned - nr_scanned, sc));
>
> +       /*
> +        * Kswapd gives up on balancing particular nodes after too
> +        * many failures to reclaim anything from them and goes to
> +        * sleep. On reclaim progress, reset the failure counter. A
> +        * successful direct reclaim run will revive a dormant kswapd.
> +        */
> +       if (reclaimable)
> +               pgdat->kswapd_failures = 0;
> +
>         return reclaimable;
>  }
>
> @@ -2700,10 +2709,6 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>                                                  GFP_KERNEL | __GFP_HARDWALL))
>                                 continue;
>
> -                       if (sc->priority != DEF_PRIORITY &&
> -                           !pgdat_reclaimable(zone->zone_pgdat))
> -                               continue;       /* Let kswapd poll it */
> -
>                         /*
>                          * If we already have plenty of memory free for
>                          * compaction in this zone, don't free any more.
> @@ -3134,6 +3139,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>         if (waitqueue_active(&pgdat->pfmemalloc_wait))
>                 wake_up_all(&pgdat->pfmemalloc_wait);
>
> +       /* Hopeless node, leave it to direct reclaim */
> +       if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
> +               return true;
> +
>         for (i = 0; i <= classzone_idx; i++) {
>                 struct zone *zone = pgdat->node_zones + i;
>
> @@ -3316,6 +3325,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>                         sc.priority--;
>         } while (sc.priority >= 1);
>
> +       if (!sc.nr_reclaimed)
> +               pgdat->kswapd_failures++;
> +
>  out:
>         /*
>          * Return the order kswapd stopped reclaiming at as
> @@ -3515,6 +3527,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>         if (!waitqueue_active(&pgdat->kswapd_wait))
>                 return;
>
> +       /* Hopeless node, leave it to direct reclaim */
> +       if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
> +               return;
> +
>         /* Only wake kswapd if all zones are unbalanced */
>         for (z = 0; z <= classzone_idx; z++) {
>                 zone = pgdat->node_zones + z;
> @@ -3785,9 +3801,6 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
>             sum_zone_node_page_state(pgdat->node_id, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
>                 return NODE_RECLAIM_FULL;
>
> -       if (!pgdat_reclaimable(pgdat))
> -               return NODE_RECLAIM_FULL;
> -
>         /*
>          * Do not scan if the allocation should not be delayed.
>          */
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 69f9aff39a2e..ff16cdc15df2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1422,7 +1422,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>                    "\n  node_unreclaimable:  %u"
>                    "\n  start_pfn:           %lu"
>                    "\n  node_inactive_ratio: %u",
> -                  !pgdat_reclaimable(zone->zone_pgdat),
> +                  pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES,
>                    zone->zone_start_pfn,
>                    zone->zone_pgdat->inactive_ratio);
>         seq_putc(m, '\n');
> --
> 2.11.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
