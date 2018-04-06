Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA4476B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 22:13:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v189so3245786wmf.4
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 19:13:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4sor988478wrh.72.2018.04.05.19.13.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 19:13:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180323152029.11084-5-aryabinin@virtuozzo.com>
References: <20180323152029.11084-1-aryabinin@virtuozzo.com> <20180323152029.11084-5-aryabinin@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 5 Apr 2018 19:13:10 -0700
Message-ID: <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] mm/vmscan: Don't mess with pgdat->flags in memcg reclaim.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>

On Fri, Mar 23, 2018 at 8:20 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> memcg reclaim may alter pgdat->flags based on the state of LRU lists
> in cgroup and its children. PGDAT_WRITEBACK may force kswapd to sleep
> congested_wait(), PGDAT_DIRTY may force kswapd to writeback filesystem
> pages. But the worst here is PGDAT_CONGESTED, since it may force all
> direct reclaims to stall in wait_iff_congested(). Note that only kswapd
> have powers to clear any of these bits. This might just never happen if
> cgroup limits configured that way. So all direct reclaims will stall
> as long as we have some congested bdi in the system.
>
> Leave all pgdat->flags manipulations to kswapd. kswapd scans the whole
> pgdat, only kswapd can clear pgdat->flags once node is balance, thus
> it's reasonable to leave all decisions about node state to kswapd.

What about global reclaimers? Is the assumption that when global
reclaimers hit such condition, kswapd will be running and correctly
set PGDAT_CONGESTED?

>
> Moving pgdat->flags manipulation to kswapd, means that cgroup2 recalim
> now loses its congestion throttling mechanism. Add per-cgroup congestion
> state and throttle cgroup2 reclaimers if memcg is in congestion state.
>
> Currently there is no need in per-cgroup PGDAT_WRITEBACK and PGDAT_DIRTY
> bits since they alter only kswapd behavior.
>
> The problem could be easily demonstrated by creating heavy congestion
> in one cgroup:
>
>     echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control
>     mkdir -p /sys/fs/cgroup/congester
>     echo 512M > /sys/fs/cgroup/congester/memory.max
>     echo $$ > /sys/fs/cgroup/congester/cgroup.procs
>     /* generate a lot of diry data on slow HDD */
>     while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
>     ....
>     while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
>
> and some job in another cgroup:
>
>     mkdir /sys/fs/cgroup/victim
>     echo 128M > /sys/fs/cgroup/victim/memory.max
>
>     # time cat /dev/sda > /dev/null
>     real    10m15.054s
>     user    0m0.487s
>     sys     1m8.505s
>
> According to the tracepoint in wait_iff_congested(), the 'cat' spent 50%
> of the time sleeping there.
>
> With the patch, cat don't waste time anymore:
>
>     # time cat /dev/sda > /dev/null
>     real    5m32.911s
>     user    0m0.411s
>     sys     0m56.664s
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  include/linux/backing-dev.h |  2 +-
>  include/linux/memcontrol.h  |  2 ++
>  mm/backing-dev.c            | 19 ++++------
>  mm/vmscan.c                 | 86 ++++++++++++++++++++++++++++++++-------------
>  4 files changed, 71 insertions(+), 38 deletions(-)
>
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index f8894dbc0b19..539a5cf94fe2 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -175,7 +175,7 @@ static inline int wb_congested(struct bdi_writeback *wb, int cong_bits)
>  }
>
>  long congestion_wait(int sync, long timeout);
> -long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout);
> +long wait_iff_congested(int sync, long timeout);
>
>  static inline bool bdi_cap_synchronous_io(struct backing_dev_info *bdi)
>  {
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 4525b4404a9e..44422e1d3def 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -190,6 +190,8 @@ struct mem_cgroup {
>         /* vmpressure notifications */
>         struct vmpressure vmpressure;
>
> +       unsigned long flags;
> +

nit(you can ignore it): The name 'flags' is too general IMO. Something
more specific would be helpful.

Question: Does this 'flags' has any hierarchical meaning? Does
congested parent means all descendents are congested?
Question: Should this 'flags' be per-node? Is it ok for a congested
memcg to call wait_iff_congested for all nodes?

>         /*
>          * Should the accounting and control be hierarchical, per subtree?
>          */
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 2eba1f54b1d3..2fc3f38e4c4f 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -1055,23 +1055,18 @@ EXPORT_SYMBOL(congestion_wait);
>
>  /**
>   * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a pgdat to complete writes
> - * @pgdat: A pgdat to check if it is heavily congested
>   * @sync: SYNC or ASYNC IO
>   * @timeout: timeout in jiffies
>   *
> - * In the event of a congested backing_dev (any backing_dev) and the given
> - * @pgdat has experienced recent congestion, this waits for up to @timeout
> - * jiffies for either a BDI to exit congestion of the given @sync queue
> - * or a write to complete.
> - *
> - * In the absence of pgdat congestion, cond_resched() is called to yield
> - * the processor if necessary but otherwise does not sleep.
> + * In the event of a congested backing_dev (any backing_dev) this waits
> + * for up to @timeout jiffies for either a BDI to exit congestion of the
> + * given @sync queue or a write to complete.
>   *
>   * The return value is 0 if the sleep is for the full timeout. Otherwise,
>   * it is the number of jiffies that were still remaining when the function
>   * returned. return_value == timeout implies the function did not sleep.
>   */
> -long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout)
> +long wait_iff_congested(int sync, long timeout)
>  {
>         long ret;
>         unsigned long start = jiffies;
> @@ -1079,12 +1074,10 @@ long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout)
>         wait_queue_head_t *wqh = &congestion_wqh[sync];
>
>         /*
> -        * If there is no congestion, or heavy congestion is not being
> -        * encountered in the current pgdat, yield if necessary instead
> +        * If there is no congestion, yield if necessary instead
>          * of sleeping on the congestion queue
>          */
> -       if (atomic_read(&nr_wb_congested[sync]) == 0 ||
> -           !test_bit(PGDAT_CONGESTED, &pgdat->flags)) {
> +       if (atomic_read(&nr_wb_congested[sync]) == 0) {
>                 cond_resched();
>
>                 /* In case we scheduled, work out time remaining */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2134b3ac8fa0..1e6e047e10fd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -199,6 +199,18 @@ static bool sane_reclaim(struct scan_control *sc)
>  #endif
>         return false;
>  }
> +
> +static void set_memcg_bit(enum pgdat_flags flag,
> +                       struct mem_cgroup *memcg)
> +{
> +       set_bit(flag, &memcg->flags);
> +}
> +
> +static int test_memcg_bit(enum pgdat_flags flag,
> +                       struct mem_cgroup *memcg)
> +{
> +       return test_bit(flag, &memcg->flags);
> +}
>  #else
>  static bool global_reclaim(struct scan_control *sc)
>  {
> @@ -209,6 +221,17 @@ static bool sane_reclaim(struct scan_control *sc)
>  {
>         return true;
>  }
> +
> +static inline void set_memcg_bit(enum pgdat_flags flag,
> +                               struct mem_cgroup *memcg)
> +{
> +}
> +
> +static inline int test_memcg_bit(enum pgdat_flags flag,
> +                               struct mem_cgroup *memcg)
> +{
> +       return 0;
> +}
>  #endif
>
>  /*
> @@ -2472,6 +2495,12 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>         return true;
>  }
>
> +static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
> +{
> +       return test_bit(PGDAT_CONGESTED, &pgdat->flags) ||
> +               (memcg && test_memcg_bit(PGDAT_CONGESTED, memcg));
> +}
> +
>  static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  {
>         struct reclaim_state *reclaim_state = current->reclaim_state;
> @@ -2554,29 +2583,28 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>                 if (sc->nr_reclaimed - nr_reclaimed)
>                         reclaimable = true;
>
> -               /*
> -                * If reclaim is isolating dirty pages under writeback, it
> -                * implies that the long-lived page allocation rate is exceeding
> -                * the page laundering rate. Either the global limits are not
> -                * being effective at throttling processes due to the page
> -                * distribution throughout zones or there is heavy usage of a
> -                * slow backing device. The only option is to throttle from
> -                * reclaim context which is not ideal as there is no guarantee
> -                * the dirtying process is throttled in the same way
> -                * balance_dirty_pages() manages.
> -                *
> -                * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the
> -                * number of pages under pages flagged for immediate reclaim and
> -                * stall if any are encountered in the nr_immediate check below.
> -                */
> -               if (sc->nr.writeback && sc->nr.writeback == sc->nr.file_taken)
> -                       set_bit(PGDAT_WRITEBACK, &pgdat->flags);
> +               if (current_is_kswapd()) {
> +                       /*
> +                        * If reclaim is isolating dirty pages under writeback,
> +                        * it implies that the long-lived page allocation rate
> +                        * is exceeding the page laundering rate. Either the
> +                        * global limits are not being effective at throttling
> +                        * processes due to the page distribution throughout
> +                        * zones or there is heavy usage of a slow backing
> +                        * device. The only option is to throttle from reclaim
> +                        * context which is not ideal as there is no guarantee
> +                        * the dirtying process is throttled in the same way
> +                        * balance_dirty_pages() manages.
> +                        *
> +                        * Once a node is flagged PGDAT_WRITEBACK, kswapd will
> +                        * count the number of pages under pages flagged for
> +                        * immediate reclaim and stall if any are encountered
> +                        * in the nr_immediate check below.
> +                        */
> +                       if (sc->nr.writeback &&
> +                           sc->nr.writeback == sc->nr.file_taken)
> +                               set_bit(PGDAT_WRITEBACK, &pgdat->flags);
>
> -               /*
> -                * Legacy memcg will stall in page writeback so avoid forcibly
> -                * stalling here.
> -                */
> -               if (sane_reclaim(sc)) {
>                         /*
>                          * Tag a node as congested if all the dirty pages
>                          * scanned were backed by a congested BDI and
> @@ -2599,6 +2627,14 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>                                 congestion_wait(BLK_RW_ASYNC, HZ/10);
>                 }
>
> +               /*
> +                * Legacy memcg will stall in page writeback so avoid forcibly
> +                * stalling in wait_iff_congested().
> +                */
> +               if (!global_reclaim(sc) && sane_reclaim(sc) &&
> +                   sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
> +                       set_memcg_bit(PGDAT_CONGESTED, root);
> +
>                 /*
>                  * Stall direct reclaim for IO completions if underlying BDIs
>                  * and node is congested. Allow kswapd to continue until it
> @@ -2606,8 +2642,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>                  * the LRU too quickly.
>                  */
>                 if (!sc->hibernation_mode && !current_is_kswapd() &&
> -                   current_may_throttle())
> -                       wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
> +                  current_may_throttle() && pgdat_memcg_congested(pgdat, root))
> +                       wait_iff_congested(BLK_RW_ASYNC, HZ/10);
>
>         } while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
>                                          sc->nr_scanned - nr_scanned, sc));
> @@ -3047,6 +3083,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
>          * the priority and make it zero.
>          */
>         shrink_node_memcg(pgdat, memcg, &sc, &lru_pages);
> +       clear_bit(PGDAT_CONGESTED, &memcg->flags);
>
>         trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>
> @@ -3092,6 +3129,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>         noreclaim_flag = memalloc_noreclaim_save();
>         nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
>         memalloc_noreclaim_restore(noreclaim_flag);
> +       clear_bit(PGDAT_CONGESTED, &memcg->flags);
>
>         trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
>
> --
> 2.16.1
>
