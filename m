Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 197156B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 21:04:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p4so14240213wrf.17
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 18:04:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u86sor2058618wma.28.2018.04.05.18.04.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 18:04:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180323152029.11084-4-aryabinin@virtuozzo.com>
References: <20180323152029.11084-1-aryabinin@virtuozzo.com> <20180323152029.11084-4-aryabinin@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 5 Apr 2018 18:04:50 -0700
Message-ID: <CALvZod6bRRdq4gWbSxWXaT8OSEsp+O5YwrjfLdzMx3gQVZei-Q@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] mm/vmscan: Don't change pgdat state on base of a
 single LRU list state.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>

On Fri, Mar 23, 2018 at 8:20 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> We have separate LRU list for each memory cgroup. Memory reclaim iterates
> over cgroups and calls shrink_inactive_list() every inactive LRU list.
> Based on the state of a single LRU shrink_inactive_list() may flag
> the whole node as dirty,congested or under writeback. This is obviously
> wrong and hurtful. It's especially hurtful when we have possibly
> small congested cgroup in system. Than *all* direct reclaims waste time
> by sleeping in wait_iff_congested(). And the more memcgs in the system
> we have the longer memory allocation stall is, because
> wait_iff_congested() called on each lru-list scan.
>
> Sum reclaim stats across all visited LRUs on node and flag node as dirty,
> congested or under writeback based on that sum. Also call
> congestion_wait(), wait_iff_congested() once per pgdat scan, instead of
> once per lru-list scan.
>
> This only fixes the problem for global reclaim case. Per-cgroup reclaim
> may alter global pgdat flags too, which is wrong. But that is separate
> issue and will be addressed in the next patch.
>
> This change will not have any effect on a systems with all workload
> concentrated in a single cgroup.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Seems reasonable.

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/vmscan.c | 124 +++++++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 73 insertions(+), 51 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 403f59edd53e..2134b3ac8fa0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -116,6 +116,15 @@ struct scan_control {
>
>         /* Number of pages freed so far during a call to shrink_zones() */
>         unsigned long nr_reclaimed;
> +
> +       struct {
> +               unsigned int dirty;
> +               unsigned int unqueued_dirty;
> +               unsigned int congested;
> +               unsigned int writeback;
> +               unsigned int immediate;
> +               unsigned int file_taken;
> +       } nr;
>  };
>
>  #ifdef ARCH_HAS_PREFETCH
> @@ -1754,23 +1763,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>         mem_cgroup_uncharge_list(&page_list);
>         free_unref_page_list(&page_list);
>
> -       /*
> -        * If reclaim is isolating dirty pages under writeback, it implies
> -        * that the long-lived page allocation rate is exceeding the page
> -        * laundering rate. Either the global limits are not being effective
> -        * at throttling processes due to the page distribution throughout
> -        * zones or there is heavy usage of a slow backing device. The
> -        * only option is to throttle from reclaim context which is not ideal
> -        * as there is no guarantee the dirtying process is throttled in the
> -        * same way balance_dirty_pages() manages.
> -        *
> -        * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the number
> -        * of pages under pages flagged for immediate reclaim and stall if any
> -        * are encountered in the nr_immediate check below.
> -        */
> -       if (stat.nr_writeback && stat.nr_writeback == nr_taken)
> -               set_bit(PGDAT_WRITEBACK, &pgdat->flags);
> -
>         /*
>          * If dirty pages are scanned that are not queued for IO, it
>          * implies that flushers are not doing their job. This can
> @@ -1785,40 +1777,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>         if (stat.nr_unqueued_dirty == nr_taken)
>                 wakeup_flusher_threads(WB_REASON_VMSCAN);
>
> -       /*
> -        * Legacy memcg will stall in page writeback so avoid forcibly
> -        * stalling here.
> -        */
> -       if (sane_reclaim(sc)) {
> -               /*
> -                * Tag a node as congested if all the dirty pages scanned were
> -                * backed by a congested BDI and wait_iff_congested will stall.
> -                */
> -               if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
> -                       set_bit(PGDAT_CONGESTED, &pgdat->flags);
> -
> -               /* Allow kswapd to start writing pages during reclaim. */
> -               if (stat.nr_unqueued_dirty == nr_taken)
> -                       set_bit(PGDAT_DIRTY, &pgdat->flags);
> -
> -               /*
> -                * If kswapd scans pages marked marked for immediate
> -                * reclaim and under writeback (nr_immediate), it implies
> -                * that pages are cycling through the LRU faster than
> -                * they are written so also forcibly stall.
> -                */
> -               if (stat.nr_immediate)
> -                       congestion_wait(BLK_RW_ASYNC, HZ/10);
> -       }
> -
> -       /*
> -        * Stall direct reclaim for IO completions if underlying BDIs and node
> -        * is congested. Allow kswapd to continue until it starts encountering
> -        * unqueued dirty pages or cycling through the LRU too quickly.
> -        */
> -       if (!sc->hibernation_mode && !current_is_kswapd() &&
> -           current_may_throttle())
> -               wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
> +       sc->nr.dirty += stat.nr_dirty;
> +       sc->nr.congested += stat.nr_congested;
> +       sc->nr.unqueued_dirty += stat.nr_unqueued_dirty;
> +       sc->nr.writeback += stat.nr_writeback;
> +       sc->nr.immediate += stat.nr_immediate;
> +       if (file)
> +               sc->nr.file_taken += nr_taken;
>
>         trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
>                         nr_scanned, nr_reclaimed,
> @@ -2522,6 +2487,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>                 unsigned long node_lru_pages = 0;
>                 struct mem_cgroup *memcg;
>
> +               memset(&sc->nr, 0, sizeof(sc->nr));
> +
>                 nr_reclaimed = sc->nr_reclaimed;
>                 nr_scanned = sc->nr_scanned;
>
> @@ -2587,6 +2554,61 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>                 if (sc->nr_reclaimed - nr_reclaimed)
>                         reclaimable = true;
>
> +               /*
> +                * If reclaim is isolating dirty pages under writeback, it
> +                * implies that the long-lived page allocation rate is exceeding
> +                * the page laundering rate. Either the global limits are not
> +                * being effective at throttling processes due to the page
> +                * distribution throughout zones or there is heavy usage of a
> +                * slow backing device. The only option is to throttle from
> +                * reclaim context which is not ideal as there is no guarantee
> +                * the dirtying process is throttled in the same way
> +                * balance_dirty_pages() manages.
> +                *
> +                * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the
> +                * number of pages under pages flagged for immediate reclaim and
> +                * stall if any are encountered in the nr_immediate check below.
> +                */
> +               if (sc->nr.writeback && sc->nr.writeback == sc->nr.file_taken)
> +                       set_bit(PGDAT_WRITEBACK, &pgdat->flags);
> +
> +               /*
> +                * Legacy memcg will stall in page writeback so avoid forcibly
> +                * stalling here.
> +                */
> +               if (sane_reclaim(sc)) {
> +                       /*
> +                        * Tag a node as congested if all the dirty pages
> +                        * scanned were backed by a congested BDI and
> +                        * wait_iff_congested will stall.
> +                        */
> +                       if (sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
> +                               set_bit(PGDAT_CONGESTED, &pgdat->flags);
> +
> +                       /* Allow kswapd to start writing pages during reclaim.*/
> +                       if (sc->nr.unqueued_dirty == sc->nr.file_taken)
> +                               set_bit(PGDAT_DIRTY, &pgdat->flags);
> +
> +                       /*
> +                        * If kswapd scans pages marked marked for immediate
> +                        * reclaim and under writeback (nr_immediate), it
> +                        * implies that pages are cycling through the LRU
> +                        * faster than they are written so also forcibly stall.
> +                        */
> +                       if (sc->nr.immediate)
> +                               congestion_wait(BLK_RW_ASYNC, HZ/10);
> +               }
> +
> +               /*
> +                * Stall direct reclaim for IO completions if underlying BDIs
> +                * and node is congested. Allow kswapd to continue until it
> +                * starts encountering unqueued dirty pages or cycling through
> +                * the LRU too quickly.
> +                */
> +               if (!sc->hibernation_mode && !current_is_kswapd() &&
> +                   current_may_throttle())
> +                       wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
> +
>         } while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
>                                          sc->nr_scanned - nr_scanned, sc));
>
> --
> 2.16.1
>
