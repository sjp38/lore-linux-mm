Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AB45C900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:45:35 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3DMjKBB008578
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 15:45:20 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by wpaz5.hot.corp.google.com with ESMTP id p3DMhmwt025059
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 15:45:18 -0700
Received: by qyk29 with SMTP id 29so2863602qyk.3
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 15:45:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110413175842.36938786.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-6-git-send-email-yinghan@google.com>
	<20110413175842.36938786.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Apr 2011 15:45:14 -0700
Message-ID: <BANLkTikMEYTkRq5Bq2JZh0zibQw66pDzkQ@mail.gmail.com>
Subject: Re: [PATCH V3 5/7] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd082e38ef904a0d48fe6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--000e0cdfd082e38ef904a0d48fe6
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 13, 2011 at 1:58 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 13 Apr 2011 00:03:05 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > This is the main loop of per-memcg background reclaim which is
> implemented in
> > function balance_mem_cgroup_pgdat().
> >
> > The function performs a priority loop similar to global reclaim. During
> each
> > iteration it invokes balance_pgdat_node() for all nodes on the system,
> which
> > is another new function performs background reclaim per node. A fairness
> > mechanism is implemented to remember the last node it was reclaiming from
> and
> > always start at the next one. After reclaiming each node, it checks
> > mem_cgroup_watermark_ok() and breaks the priority loop if it returns
> true. The
> > per-memcg zone will be marked as "unreclaimable" if the scanning rate is
> much
> > greater than the reclaiming rate on the per-memcg LRU. The bit is cleared
> when
> > there is a page charged to the memcg being freed. Kswapd breaks the
> priority
> > loop if all the zones are marked as "unreclaimable".
> >
>
> Hmm, bigger than expected. I'm glad if you can divide this into small
> pieces.
> see below.
>
>
> > changelog v3..v2:
> > 1. change mz->all_unreclaimable to be boolean.
> > 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg
> reclaim.
> > 3. some more clean-up.
> >
> > changelog v2..v1:
> > 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage.
> > 2. shared the kswapd_run/kswapd_stop for per-memcg and global background
> > reclaim.
> > 3. name the per-memcg memcg as "memcg-id" (css->id). And the global
> kswapd
> > keeps the same name.
> > 4. fix a race on kswapd_stop while the per-memcg-per-zone info could be
> accessed
> > after freeing.
> > 5. add the fairness in zonelist where memcg remember the last zone
> reclaimed
> > from.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/memcontrol.h |   33 +++++++
> >  include/linux/swap.h       |    2 +
> >  mm/memcontrol.c            |  136 +++++++++++++++++++++++++++++
> >  mm/vmscan.c                |  208
> ++++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 379 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index f7ffd1f..a8159f5 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup
> *mem,
> >                                 struct kswapd *kswapd_p);
> >  extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
> >  extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup
> *mem);
> > +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
> > +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> > +                                     const nodemask_t *nodes);
> >
> >  static inline
> >  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> > @@ -152,6 +155,12 @@ static inline void mem_cgroup_dec_page_stat(struct
> page *page,
> >  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int
> order,
> >                                               gfp_t gfp_mask);
> >  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> > +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page
> *page);
> > +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int
> zid);
> > +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone
> *zone);
> > +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone
> *zone);
> > +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone*
> zone,
> > +                             unsigned long nr_scanned);
> >
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >  void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
> > @@ -342,6 +351,25 @@ static inline void mem_cgroup_dec_page_stat(struct
> page *page,
> >  {
> >  }
> >
> > +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
> > +                                             struct zone *zone,
> > +                                             unsigned long nr_scanned)
> > +{
> > +}
> > +
> > +static inline void mem_cgroup_clear_unreclaimable(struct page *page,
> > +                                                     struct zone *zone)
> > +{
> > +}
> > +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup
> *mem,
> > +             struct zone *zone)
> > +{
> > +}
> > +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
> > +                                             struct zone *zone)
> > +{
> > +}
> > +
> >  static inline
> >  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int
> order,
> >                                           gfp_t gfp_mask)
> > @@ -360,6 +388,11 @@ static inline void
> mem_cgroup_split_huge_fixup(struct page *head,
> >  {
> >  }
> >
> > +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem,
> int nid,
> > +                                                             int zid)
> > +{
> > +     return false;
> > +}
> >  #endif /* CONFIG_CGROUP_MEM_CONT */
> >
> >  #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 17e0511..319b800 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -160,6 +160,8 @@ enum {
> >       SWP_SCANNING    = (1 << 8),     /* refcount in scan_swap_map */
> >  };
> >
> > +#define ZONE_RECLAIMABLE_RATE 6
> > +
> >  #define SWAP_CLUSTER_MAX 32
> >  #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index acd84a8..efeade3 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -133,7 +133,10 @@ struct mem_cgroup_per_zone {
> >       bool                    on_tree;
> >       struct mem_cgroup       *mem;           /* Back pointer, we cannot
> */
> >                                               /* use container_of
>  */
> > +     unsigned long           pages_scanned;  /* since last reclaim */
> > +     bool                    all_unreclaimable;      /* All pages pinned
> */
> >  };
> > +
> >  /* Macro for accessing counter */
> >  #define MEM_CGROUP_ZSTAT(mz, idx)    ((mz)->count[(idx)])
> >
> > @@ -275,6 +278,11 @@ struct mem_cgroup {
> >
> >       int wmark_ratio;
> >
> > +     /* While doing per cgroup background reclaim, we cache the
> > +      * last node we reclaimed from
> > +      */
> > +     int last_scanned_node;
> > +
> >       wait_queue_head_t *kswapd_wait;
> >  };
> >
> > @@ -1129,6 +1137,96 @@ mem_cgroup_get_reclaim_stat_from_page(struct page
> *page)
> >       return &mz->reclaim_stat;
> >  }
> >
> > +static unsigned long mem_cgroup_zone_reclaimable_pages(
> > +                                     struct mem_cgroup_per_zone *mz)
> > +{
> > +     int nr;
> > +     nr = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +
> > +             MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
> > +
> > +     if (nr_swap_pages > 0)
> > +             nr += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON) +
> > +                     MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
> > +
> > +     return nr;
> > +}
> > +
> > +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone*
> zone,
> > +                                             unsigned long nr_scanned)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +
> > +     if (!mem)
> > +             return;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz)
> > +             mz->pages_scanned += nr_scanned;
> > +}
> > +
> > +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int
> zid)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +
> > +     if (!mem)
> > +             return 0;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz)
> > +             return mz->pages_scanned <
> > +                             mem_cgroup_zone_reclaimable_pages(mz) *
> > +                             ZONE_RECLAIMABLE_RATE;
> > +     return 0;
> > +}
> > +
> > +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone
> *zone)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +
> > +     if (!mem)
> > +             return false;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz)
> > +             return mz->all_unreclaimable;
> > +
> > +     return false;
> > +}
> > +
> > +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone
> *zone)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +
> > +     if (!mem)
> > +             return;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz)
> > +             mz->all_unreclaimable = true;
> > +}
> > +
> > +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page
> *page)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +
> > +     if (!mem)
> > +             return;
> > +
> > +     mz = page_cgroup_zoneinfo(mem, page);
> > +     if (mz) {
> > +             mz->pages_scanned = 0;
> > +             mz->all_unreclaimable = false;
> > +     }
> > +
> > +     return;
> > +}
> > +
> >  unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >                                       struct list_head *dst,
> >                                       unsigned long *scanned, int order,
> > @@ -1545,6 +1643,32 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
> >  }
> >
> >  /*
> > + * Visit the first node after the last_scanned_node of @mem and use that
> to
> > + * reclaim free pages from.
> > + */
> > +int
> > +mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t
> *nodes)
> > +{
> > +     int next_nid;
> > +     int last_scanned;
> > +
> > +     last_scanned = mem->last_scanned_node;
> > +
> > +     /* Initial stage and start from node0 */
> > +     if (last_scanned == -1)
> > +             next_nid = 0;
> > +     else
> > +             next_nid = next_node(last_scanned, *nodes);
> > +
> > +     if (next_nid == MAX_NUMNODES)
> > +             next_nid = first_node(*nodes);
> > +
> > +     mem->last_scanned_node = next_nid;
> > +
> > +     return next_nid;
> > +}
> > +
> > +/*
> >   * Check OOM-Killer is already running under our hierarchy.
> >   * If someone is running, return false.
> >   */
> > @@ -2779,6 +2903,7 @@ __mem_cgroup_uncharge_common(struct page *page,
> enum charge_type ctype)
> >        * special functions.
> >        */
> >
> > +     mem_cgroup_clear_unreclaimable(mem, page);
>
> Hmm, do we this always at uncharge ?
>
> I doubt we really need mz->all_unreclaimable ....
>
> Anyway, I'd like to see this all_unreclaimable logic in an independet
> patch.
> Because direct-relcaim pass should see this, too.
>
> So, could you devide this pieces into
>
> 1. record last node .... I wonder this logic should be used in
> direct-reclaim pass, too.
>
> 2. all_unreclaimable .... direct reclaim will be affected, too.
>
> 3. scanning core.
>

Ok. will make the change for the next post.

>
>
>
> >       unlock_page_cgroup(pc);
> >       /*
> >        * even after unlock, we have mem->res.usage here and this memcg
> > @@ -4501,6 +4626,8 @@ static int alloc_mem_cgroup_per_zone_info(struct
> mem_cgroup *mem, int node)
> >               mz->usage_in_excess = 0;
> >               mz->on_tree = false;
> >               mz->mem = mem;
> > +             mz->pages_scanned = 0;
> > +             mz->all_unreclaimable = false;
> >       }
> >       return 0;
> >  }
> > @@ -4651,6 +4778,14 @@ wait_queue_head_t *mem_cgroup_kswapd_wait(struct
> mem_cgroup *mem)
> >       return mem->kswapd_wait;
> >  }
> >
> > +int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
> > +{
> > +     if (!mem)
> > +             return -1;
> > +
> > +     return mem->last_scanned_node;
> > +}
> > +
> >  static int mem_cgroup_soft_limit_tree_init(void)
> >  {
> >       struct mem_cgroup_tree_per_node *rtpn;
> > @@ -4726,6 +4861,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct
> cgroup *cont)
> >               res_counter_init(&mem->memsw, NULL);
> >       }
> >       mem->last_scanned_child = 0;
> > +     mem->last_scanned_node = -1;
> >       INIT_LIST_HEAD(&mem->oom_notify);
> >
> >       if (parent)
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a1a1211..6571eb8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -47,6 +47,8 @@
> >
> >  #include <linux/swapops.h>
> >
> > +#include <linux/res_counter.h>
> > +
> >  #include "internal.h"
> >
> >  #define CREATE_TRACE_POINTS
> > @@ -111,6 +113,8 @@ struct scan_control {
> >        * are scanned.
> >        */
> >       nodemask_t      *nodemask;
> > +
> > +     int priority;
> >  };
> >
> >  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> > @@ -1410,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
> >                                       ISOLATE_BOTH : ISOLATE_INACTIVE,
> >                       zone, sc->mem_cgroup,
> >                       0, file);
> > +
> > +             mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone,
> nr_scanned);
> > +
> >               /*
> >                * mem_cgroup_isolate_pages() keeps track of
> >                * scanned pages on its own.
> > @@ -1529,6 +1536,7 @@ static void shrink_active_list(unsigned long
> nr_pages, struct zone *zone,
> >                * mem_cgroup_isolate_pages() keeps track of
> >                * scanned pages on its own.
> >                */
> > +             mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone,
> pgscanned);
> >       }
> >
> >       reclaim_stat->recent_scanned[file] += nr_taken;
> > @@ -2632,11 +2640,211 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >       finish_wait(wait_h, &wait);
> >  }
> >
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/*
> > + * The function is used for per-memcg LRU. It scanns all the zones of
> the
> > + * node and returns the nr_scanned and nr_reclaimed.
> > + */
> > +static void balance_pgdat_node(pg_data_t *pgdat, int order,
> > +                                     struct scan_control *sc)
> > +{
> > +     int i, end_zone;
> > +     unsigned long total_scanned;
> > +     struct mem_cgroup *mem_cont = sc->mem_cgroup;
> > +     int priority = sc->priority;
> > +     int nid = pgdat->node_id;
> > +
> > +     /*
> > +      * Scan in the highmem->dma direction for the highest
> > +      * zone which needs scanning
> > +      */
> > +     for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > +             struct zone *zone = pgdat->node_zones + i;
> > +
> > +             if (!populated_zone(zone))
> > +                     continue;
> > +
> > +             if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
> > +                             priority != DEF_PRIORITY)
> > +                     continue;
> > +             /*
> > +              * Do some background aging of the anon list, to give
> > +              * pages a chance to be referenced before reclaiming.
> > +              */
> > +             if (inactive_anon_is_low(zone, sc))
> > +                     shrink_active_list(SWAP_CLUSTER_MAX, zone,
> > +                                                     sc, priority, 0);
> > +
> > +             end_zone = i;
> > +             goto scan;
> > +     }
>
> I don't want to see zone balancing logic in memcg.
> It should be a work of global lru.
>
> IOW, even if we remove global LRU finally, we should
> implement zone balancing logic in _global_ (per node) kswapd.
> (kswapd can pass zone mask to each memcg.)
>
> If you want some clever logic for memcg specail, I think it should be
> deteciting 'which node should be victim' logic rather than round-robin.
> (But yes, starting from easy round robin makes sense.)
>
> So, could you add more simple one ?
>
>  do {
>    select victim node
>    do reclaim
>  } while (need_stop)
>
> zone balancing should be done other than memcg.
>
> what we really need to improve is 'select victim node'.
>

I will separate out the logic in the next post. So it would be easier to
optimize each individual functionality.

--Ying

>
> Thanks,
> -Kame
>
>
> > +     return;
> > +
> > +scan:
> > +     total_scanned = 0;
> > +     /*
> > +      * Now scan the zone in the dma->highmem direction, stopping
> > +      * at the last zone which needs scanning.
> > +      *
> > +      * We do this because the page allocator works in the opposite
> > +      * direction.  This prevents the page allocator from allocating
> > +      * pages behind kswapd's direction of progress, which would
> > +      * cause too much scanning of the lower zones.
> > +      */
> > +     for (i = 0; i <= end_zone; i++) {
> > +             struct zone *zone = pgdat->node_zones + i;
> > +
> > +             if (!populated_zone(zone))
> > +                     continue;
> > +
> > +             if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
> > +                     priority != DEF_PRIORITY)
> > +                     continue;
> > +
> > +             sc->nr_scanned = 0;
> > +             shrink_zone(priority, zone, sc);
> > +             total_scanned += sc->nr_scanned;
> > +
> > +             if (mem_cgroup_mz_unreclaimable(mem_cont, zone))
> > +                     continue;
> > +
> > +             if (!mem_cgroup_zone_reclaimable(mem_cont, nid, i))
> > +                     mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
> > +
> > +             /*
> > +              * If we've done a decent amount of scanning and
> > +              * the reclaim ratio is low, start doing writepage
> > +              * even in laptop mode
> > +              */
> > +             if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> > +                 total_scanned > sc->nr_reclaimed + sc->nr_reclaimed /
> 2) {
> > +                     sc->may_writepage = 1;
> > +             }
> > +     }
> > +
> > +     sc->nr_scanned = total_scanned;
> > +     return;
> > +}
> > +
> > +/*
> > + * Per cgroup background reclaim.
> > + * TODO: Take off the order since memcg always do order 0
> > + */
> > +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> > +                                           int order)
> > +{
> > +     int i, nid;
> > +     int start_node;
> > +     int priority;
> > +     bool wmark_ok;
> > +     int loop;
> > +     pg_data_t *pgdat;
> > +     nodemask_t do_nodes;
> > +     unsigned long total_scanned;
> > +     struct scan_control sc = {
> > +             .gfp_mask = GFP_KERNEL,
> > +             .may_unmap = 1,
> > +             .may_swap = 1,
> > +             .nr_to_reclaim = ULONG_MAX,
> > +             .swappiness = vm_swappiness,
> > +             .order = order,
> > +             .mem_cgroup = mem_cont,
> > +     };
> > +
> > +loop_again:
> > +     do_nodes = NODE_MASK_NONE;
> > +     sc.may_writepage = !laptop_mode;
> > +     sc.nr_reclaimed = 0;
> > +     total_scanned = 0;
> > +
> > +     for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > +             sc.priority = priority;
> > +             wmark_ok = false;
> > +             loop = 0;
> > +
> > +             /* The swap token gets in the way of swapout... */
> > +             if (!priority)
> > +                     disable_swap_token();
> > +
> > +             if (priority == DEF_PRIORITY)
> > +                     do_nodes = node_states[N_ONLINE];
> > +
> > +             while (1) {
> > +                     nid = mem_cgroup_select_victim_node(mem_cont,
> > +                                                     &do_nodes);
> > +
> > +                     /* Indicate we have cycled the nodelist once
> > +                      * TODO: we might add MAX_RECLAIM_LOOP for
> preventing
> > +                      * kswapd burning cpu cycles.
> > +                      */
> > +                     if (loop == 0) {
> > +                             start_node = nid;
> > +                             loop++;
> > +                     } else if (nid == start_node)
> > +                             break;
> > +
> > +                     pgdat = NODE_DATA(nid);
> > +                     balance_pgdat_node(pgdat, order, &sc);
> > +                     total_scanned += sc.nr_scanned;
> > +
> > +                     /* Set the node which has at least
> > +                      * one reclaimable zone
> > +                      */
> > +                     for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > +                             struct zone *zone = pgdat->node_zones + i;
> > +
> > +                             if (!populated_zone(zone))
> > +                                     continue;
> > +
> > +                             if (!mem_cgroup_mz_unreclaimable(mem_cont,
> > +                                                             zone))
> > +                                     break;
> > +                     }
> > +                     if (i < 0)
> > +                             node_clear(nid, do_nodes);
> > +
> > +                     if (mem_cgroup_watermark_ok(mem_cont,
> > +                                                     CHARGE_WMARK_HIGH))
> {
> > +                             wmark_ok = true;
> > +                             goto out;
> > +                     }
> > +
> > +                     if (nodes_empty(do_nodes)) {
> > +                             wmark_ok = true;
> > +                             goto out;
> > +                     }
> > +             }
> > +
> > +             /* All the nodes are unreclaimable, kswapd is done */
> > +             if (nodes_empty(do_nodes)) {
> > +                     wmark_ok = true;
> > +                     goto out;
> > +             }
> > +
> > +             if (total_scanned && priority < DEF_PRIORITY - 2)
> > +                     congestion_wait(WRITE, HZ/10);
> > +
> > +             if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> > +                     break;
> > +     }
> > +out:
> > +     if (!wmark_ok) {
> > +             cond_resched();
> > +
> > +             try_to_freeze();
> > +
> > +             goto loop_again;
> > +     }
> > +
> > +     return sc.nr_reclaimed;
> > +}
> > +#else
> >  static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> >                                                       int order)
> >  {
> >       return 0;
> >  }
> > +#endif
> >
> >  /*
> >   * The background pageout daemon, started as a kernel thread
> > --
> > 1.7.3.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
>
>

--000e0cdfd082e38ef904a0d48fe6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 13, 2011 at 1:58 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Wed, 13 Apr 2011 00:03:05 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; This is the main loop of per-memcg background reclaim which is impleme=
nted in<br>
&gt; function balance_mem_cgroup_pgdat().<br>
&gt;<br>
&gt; The function performs a priority loop similar to global reclaim. Durin=
g each<br>
&gt; iteration it invokes balance_pgdat_node() for all nodes on the system,=
 which<br>
&gt; is another new function performs background reclaim per node. A fairne=
ss<br>
&gt; mechanism is implemented to remember the last node it was reclaiming f=
rom and<br>
&gt; always start at the next one. After reclaiming each node, it checks<br=
>
&gt; mem_cgroup_watermark_ok() and breaks the priority loop if it returns t=
rue. The<br>
&gt; per-memcg zone will be marked as &quot;unreclaimable&quot; if the scan=
ning rate is much<br>
&gt; greater than the reclaiming rate on the per-memcg LRU. The bit is clea=
red when<br>
&gt; there is a page charged to the memcg being freed. Kswapd breaks the pr=
iority<br>
&gt; loop if all the zones are marked as &quot;unreclaimable&quot;.<br>
&gt;<br>
<br>
</div>Hmm, bigger than expected. I&#39;m glad if you can divide this into s=
mall pieces.<br>
see below.<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; changelog v3..v2:<br>
&gt; 1. change mz-&gt;all_unreclaimable to be boolean.<br>
&gt; 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg rec=
laim.<br>
&gt; 3. some more clean-up.<br>
&gt;<br>
&gt; changelog v2..v1:<br>
&gt; 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage=
.<br>
&gt; 2. shared the kswapd_run/kswapd_stop for per-memcg and global backgrou=
nd<br>
&gt; reclaim.<br>
&gt; 3. name the per-memcg memcg as &quot;memcg-id&quot; (css-&gt;id). And =
the global kswapd<br>
&gt; keeps the same name.<br>
&gt; 4. fix a race on kswapd_stop while the per-memcg-per-zone info could b=
e accessed<br>
&gt; after freeing.<br>
&gt; 5. add the fairness in zonelist where memcg remember the last zone rec=
laimed<br>
&gt; from.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h | =A0 33 +++++++<br>
&gt; =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A02 +<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0136 +++++++++++++++++++=
++++++++++<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0208 +++++++++++++++=
+++++++++++++++++++++++++++++<br>
&gt; =A04 files changed, 379 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index f7ffd1f..a8159f5 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup =
*mem,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct=
 kswapd *kswapd_p);<br>
&gt; =A0extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);<br>
&gt; =A0extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup =
*mem);<br>
&gt; +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);<br>
&gt; +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 const nodemask_t *nodes);<br>
&gt;<br>
&gt; =A0static inline<br>
&gt; =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cg=
roup *cgroup)<br>
&gt; @@ -152,6 +155,12 @@ static inline void mem_cgroup_dec_page_stat(struc=
t page *page,<br>
&gt; =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int =
order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask);<br>
&gt; =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);<br>
&gt; +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct pa=
ge *page);<br>
&gt; +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int=
 zid);<br>
&gt; +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone =
*zone);<br>
&gt; +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct z=
one *zone);<br>
&gt; +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone*=
 zone,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lon=
g nr_scanned);<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE<br>
&gt; =A0void mem_cgroup_split_huge_fixup(struct page *head, struct page *ta=
il);<br>
&gt; @@ -342,6 +351,25 @@ static inline void mem_cgroup_dec_page_stat(struc=
t page *page,<br>
&gt; =A0{<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem=
,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned)<br>
&gt; +{<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline void mem_cgroup_clear_unreclaimable(struct page *page,<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; +{<br>
&gt; +}<br>
&gt; +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup =
*mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; +{<br>
&gt; +}<br>
&gt; +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem=
,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; +{<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static inline<br>
&gt; =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int =
order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 gfp_t gfp_mask)<br>
&gt; @@ -360,6 +388,11 @@ static inline void mem_cgroup_split_huge_fixup(st=
ruct page *head,<br>
&gt; =A0{<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem=
, int nid,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int zid)<br>
&gt; +{<br>
&gt; + =A0 =A0 return false;<br>
&gt; +}<br>
&gt; =A0#endif /* CONFIG_CGROUP_MEM_CONT */<br>
&gt;<br>
&gt; =A0#if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_V=
M)<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index 17e0511..319b800 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -160,6 +160,8 @@ enum {<br>
&gt; =A0 =A0 =A0 SWP_SCANNING =A0 =A0=3D (1 &lt;&lt; 8), =A0 =A0 /* refcoun=
t in scan_swap_map */<br>
&gt; =A0};<br>
&gt;<br>
&gt; +#define ZONE_RECLAIMABLE_RATE 6<br>
&gt; +<br>
&gt; =A0#define SWAP_CLUSTER_MAX 32<br>
&gt; =A0#define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index acd84a8..efeade3 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -133,7 +133,10 @@ struct mem_cgroup_per_zone {<br>
&gt; =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0on_tree;<br>
&gt; =A0 =A0 =A0 struct mem_cgroup =A0 =A0 =A0 *mem; =A0 =A0 =A0 =A0 =A0 /*=
 Back pointer, we cannot */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 /* use container_of =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 pages_scanned; =A0/* since=
 last reclaim */<br>
&gt; + =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0all_unreclaimabl=
e; =A0 =A0 =A0/* All pages pinned */<br>
&gt; =A0};<br>
&gt; +<br>
&gt; =A0/* Macro for accessing counter */<br>
&gt; =A0#define MEM_CGROUP_ZSTAT(mz, idx) =A0 =A0((mz)-&gt;count[(idx)])<br=
>
&gt;<br>
&gt; @@ -275,6 +278,11 @@ struct mem_cgroup {<br>
&gt;<br>
&gt; =A0 =A0 =A0 int wmark_ratio;<br>
&gt;<br>
&gt; + =A0 =A0 /* While doing per cgroup background reclaim, we cache the<b=
r>
&gt; + =A0 =A0 =A0* last node we reclaimed from<br>
&gt; + =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 int last_scanned_node;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
&gt; =A0};<br>
&gt;<br>
&gt; @@ -1129,6 +1137,96 @@ mem_cgroup_get_reclaim_stat_from_page(struct pa=
ge *page)<br>
&gt; =A0 =A0 =A0 return &amp;mz-&gt;reclaim_stat;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static unsigned long mem_cgroup_zone_reclaimable_pages(<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct mem_cgroup_per_zone *mz)<br>
&gt; +{<br>
&gt; + =A0 =A0 int nr;<br>
&gt; + =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);<br>
&gt; +<br>
&gt; + =A0 =A0 if (nr_swap_pages &gt; 0)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON=
) +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, LRU_INA=
CTIVE_ANON);<br>
&gt; +<br>
&gt; + =A0 =A0 return nr;<br>
&gt; +}<br>
&gt; +<br>
&gt; +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone*=
 zone,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;pages_scanned +=3D nr_scanned;<br>
&gt; +}<br>
&gt; +<br>
&gt; +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int=
 zid)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return mz-&gt;pages_scanned &lt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_z=
one_reclaimable_pages(mz) *<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ZONE_RECLAIM=
ABLE_RATE;<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone =
*zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return mz-&gt;all_unreclaimable;<br>
&gt; +<br>
&gt; + =A0 =A0 return false;<br>
&gt; +}<br>
&gt; +<br>
&gt; +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct z=
one *zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;all_unreclaimable =3D true;<br>
&gt; +}<br>
&gt; +<br>
&gt; +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct pa=
ge *page)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D page_cgroup_zoneinfo(mem, page);<br>
&gt; + =A0 =A0 if (mz) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;pages_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;all_unreclaimable =3D false;<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 return;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,<br=
>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 struct list_head *dst,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 unsigned long *scanned, int order,<br>
&gt; @@ -1545,6 +1643,32 @@ static int mem_cgroup_hierarchical_reclaim(stru=
ct mem_cgroup *root_mem,<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; + * Visit the first node after the last_scanned_node of @mem and use t=
hat to<br>
&gt; + * reclaim free pages from.<br>
&gt; + */<br>
&gt; +int<br>
&gt; +mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_=
t *nodes)<br>
&gt; +{<br>
&gt; + =A0 =A0 int next_nid;<br>
&gt; + =A0 =A0 int last_scanned;<br>
&gt; +<br>
&gt; + =A0 =A0 last_scanned =3D mem-&gt;last_scanned_node;<br>
&gt; +<br>
&gt; + =A0 =A0 /* Initial stage and start from node0 */<br>
&gt; + =A0 =A0 if (last_scanned =3D=3D -1)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D 0;<br>
&gt; + =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D next_node(last_scanned, *nodes)=
;<br>
&gt; +<br>
&gt; + =A0 =A0 if (next_nid =3D=3D MAX_NUMNODES)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D first_node(*nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 mem-&gt;last_scanned_node =3D next_nid;<br>
&gt; +<br>
&gt; + =A0 =A0 return next_nid;<br>
&gt; +}<br>
&gt; +<br>
&gt; +/*<br>
&gt; =A0 * Check OOM-Killer is already running under our hierarchy.<br>
&gt; =A0 * If someone is running, return false.<br>
&gt; =A0 */<br>
&gt; @@ -2779,6 +2903,7 @@ __mem_cgroup_uncharge_common(struct page *page, =
enum charge_type ctype)<br>
&gt; =A0 =A0 =A0 =A0* special functions.<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt;<br>
&gt; + =A0 =A0 mem_cgroup_clear_unreclaimable(mem, page);<br>
<br>
</div></div>Hmm, do we this always at uncharge ?<br>
<br>
I doubt we really need mz-&gt;all_unreclaimable ....<br>
<br>
Anyway, I&#39;d like to see this all_unreclaimable logic in an independet p=
atch.<br>
Because direct-relcaim pass should see this, too.<br>
<br>
So, could you devide this pieces into<br>
<br>
1. record last node .... I wonder this logic should be used in direct-recla=
im pass, too.<br>
<br>
2. all_unreclaimable .... direct reclaim will be affected, too.<br>
<br>
3. scanning core.<br></blockquote><div><br></div><div>Ok. will make the cha=
nge for the next post.=A0</div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
<br>
<br>
&gt; =A0 =A0 =A0 unlock_page_cgroup(pc);<br>
&gt; =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0* even after unlock, we have mem-&gt;res.usage here and=
 this memcg<br>
&gt; @@ -4501,6 +4626,8 @@ static int alloc_mem_cgroup_per_zone_info(struct=
 mem_cgroup *mem, int node)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;usage_in_excess =3D 0;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;on_tree =3D false;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;mem =3D mem;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;pages_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;all_unreclaimable =3D false;<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt; @@ -4651,6 +4778,14 @@ wait_queue_head_t *mem_cgroup_kswapd_wait(struc=
t mem_cgroup *mem)<br>
&gt; =A0 =A0 =A0 return mem-&gt;kswapd_wait;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -1;<br>
&gt; +<br>
&gt; + =A0 =A0 return mem-&gt;last_scanned_node;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_soft_limit_tree_init(void)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rtpn;<br>
&gt; @@ -4726,6 +4861,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, stru=
ct cgroup *cont)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_init(&amp;mem-&gt;memsw, NULL)=
;<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 mem-&gt;last_scanned_child =3D 0;<br>
&gt; + =A0 =A0 mem-&gt;last_scanned_node =3D -1;<br>
&gt; =A0 =A0 =A0 INIT_LIST_HEAD(&amp;mem-&gt;oom_notify);<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (parent)<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index a1a1211..6571eb8 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -47,6 +47,8 @@<br>
&gt;<br>
&gt; =A0#include &lt;linux/swapops.h&gt;<br>
&gt;<br>
&gt; +#include &lt;linux/res_counter.h&gt;<br>
&gt; +<br>
&gt; =A0#include &quot;internal.h&quot;<br>
&gt;<br>
&gt; =A0#define CREATE_TRACE_POINTS<br>
&gt; @@ -111,6 +113,8 @@ struct scan_control {<br>
&gt; =A0 =A0 =A0 =A0* are scanned.<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 nodemask_t =A0 =A0 =A0*nodemask;<br>
&gt; +<br>
&gt; + =A0 =A0 int priority;<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#define lru_to_page(_head) (list_entry((_head)-&gt;prev, struct pag=
e, lru))<br>
&gt; @@ -1410,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan, s=
truct zone *zone,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 ISOLATE_BOTH : ISOLATE_INACTIVE,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, sc-&gt;mem_cgroup,<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, file);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc-&gt;mem_cgrou=
p, zone, nr_scanned);<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps trac=
k of<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.<br>
&gt; @@ -1529,6 +1536,7 @@ static void shrink_active_list(unsigned long nr_=
pages, struct zone *zone,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps trac=
k of<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc-&gt;mem_cgrou=
p, zone, pgscanned);<br>
&gt; =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 reclaim_stat-&gt;recent_scanned[file] +=3D nr_taken;<br>
&gt; @@ -2632,11 +2640,211 @@ static void kswapd_try_to_sleep(struct kswapd=
 *kswapd_p, int order,<br>
&gt; =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
&gt; +/*<br>
&gt; + * The function is used for per-memcg LRU. It scanns all the zones of=
 the<br>
&gt; + * node and returns the nr_scanned and nr_reclaimed.<br>
&gt; + */<br>
&gt; +static void balance_pgdat_node(pg_data_t *pgdat, int order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc)<br>
&gt; +{<br>
&gt; + =A0 =A0 int i, end_zone;<br>
&gt; + =A0 =A0 unsigned long total_scanned;<br>
&gt; + =A0 =A0 struct mem_cgroup *mem_cont =3D sc-&gt;mem_cgroup;<br>
&gt; + =A0 =A0 int priority =3D sc-&gt;priority;<br>
&gt; + =A0 =A0 int nid =3D pgdat-&gt;node_id;<br>
&gt; +<br>
&gt; + =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0* Scan in the highmem-&gt;dma direction for the highest<b=
r>
&gt; + =A0 =A0 =A0* zone which needs scanning<br>
&gt; + =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 for (i =3D pgdat-&gt;nr_zones - 1; i &gt;=3D 0; i--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat-&gt;node_zones +=
 i;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zo=
ne) &amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority !=
=3D DEF_PRIORITY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do some background aging of the anon li=
st, to give<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages a chance to be referenced before =
reclaiming.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_active_list(SWAP_CLUS=
TER_MAX, zone,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc, priority, 0);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 end_zone =3D i;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 goto scan;<br>
&gt; + =A0 =A0 }<br>
<br>
</div></div>I don&#39;t want to see zone balancing logic in memcg.<br>
It should be a work of global lru.<br>
<br>
IOW, even if we remove global LRU finally, we should<br>
implement zone balancing logic in _global_ (per node) kswapd.<br>
(kswapd can pass zone mask to each memcg.)<br>
<br>
If you want some clever logic for memcg specail, I think it should be<br>
deteciting &#39;which node should be victim&#39; logic rather than round-ro=
bin.<br>
(But yes, starting from easy round robin makes sense.)<br>
<br>
So, could you add more simple one ?<br>
<br>
 =A0do {<br>
 =A0 =A0select victim node<br>
 =A0 =A0do reclaim<br>
 =A0} while (need_stop)<br>
<br>
zone balancing should be done other than memcg.<br>
<br>
what we really need to improve is &#39;select victim node&#39;.<br></blockq=
uote><div><br></div><div>I will=A0separate=A0out the logic in the next post=
. So it would be easier to optimize each individual functionality.</div><di=
v>
<br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
Thanks,<br>
-Kame<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; + =A0 =A0 return;<br>
&gt; +<br>
&gt; +scan:<br>
&gt; + =A0 =A0 total_scanned =3D 0;<br>
&gt; + =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0* Now scan the zone in the dma-&gt;highmem direction, sto=
pping<br>
&gt; + =A0 =A0 =A0* at the last zone which needs scanning.<br>
&gt; + =A0 =A0 =A0*<br>
&gt; + =A0 =A0 =A0* We do this because the page allocator works in the oppo=
site<br>
&gt; + =A0 =A0 =A0* direction. =A0This prevents the page allocator from all=
ocating<br>
&gt; + =A0 =A0 =A0* pages behind kswapd&#39;s direction of progress, which =
would<br>
&gt; + =A0 =A0 =A0* cause too much scanning of the lower zones.<br>
&gt; + =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 for (i =3D 0; i &lt;=3D end_zone; i++) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat-&gt;node_zones +=
 i;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zo=
ne) &amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority !=3D DEF_PRIORITY)<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_scanned;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zo=
ne))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_zone_reclaimable(mem_cont, n=
id, i))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_set_unreclaima=
ble(mem_cont, zone);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we&#39;ve done a decent amount of sc=
anning and<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, start doing w=
ritepage<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; SWAP_CLUSTER_MAX * 2 =
&amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc-&gt;nr_reclaim=
ed + sc-&gt;nr_reclaimed / 2) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepage =3D 1;<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 sc-&gt;nr_scanned =3D total_scanned;<br>
&gt; + =A0 =A0 return;<br>
&gt; +}<br>
&gt; +<br>
&gt; +/*<br>
&gt; + * Per cgroup background reclaim.<br>
&gt; + * TODO: Take off the order since memcg always do order 0<br>
&gt; + */<br>
&gt; +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_=
cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 int order)<br>
&gt; +{<br>
&gt; + =A0 =A0 int i, nid;<br>
&gt; + =A0 =A0 int start_node;<br>
&gt; + =A0 =A0 int priority;<br>
&gt; + =A0 =A0 bool wmark_ok;<br>
&gt; + =A0 =A0 int loop;<br>
&gt; + =A0 =A0 pg_data_t *pgdat;<br>
&gt; + =A0 =A0 nodemask_t do_nodes;<br>
&gt; + =A0 =A0 unsigned long total_scanned;<br>
&gt; + =A0 =A0 struct scan_control sc =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D ULONG_MAX,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,<br>
&gt; + =A0 =A0 };<br>
&gt; +<br>
&gt; +loop_again:<br>
&gt; + =A0 =A0 do_nodes =3D NODE_MASK_NONE;<br>
&gt; + =A0 =A0 sc.may_writepage =3D !laptop_mode;<br>
&gt; + =A0 =A0 sc.nr_reclaimed =3D 0;<br>
&gt; + =A0 =A0 total_scanned =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 for (priority =3D DEF_PRIORITY; priority &gt;=3D 0; priority=
--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D false;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 loop =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way of swapout=
... */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (priority =3D=3D DEF_PRIORITY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_nodes =3D node_states[N_O=
NLINE];<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 while (1) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_vi=
ctim_node(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Indicate we have cycled t=
he nodelist once<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: we might add MAX_=
RECLAIM_LOOP for preventing<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* kswapd burning cpu cycl=
es.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop =3D=3D 0) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_node =
=3D nid;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (nid =3D=3D start_=
node)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid);<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_pgdat_node(pgdat, or=
der, &amp;sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_sca=
nned;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Set the node which has at=
 least<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* one reclaimable zone<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D pgdat-&gt;nr_zone=
s - 1; i &gt;=3D 0; i--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone =
*zone =3D pgdat-&gt;node_zones + i;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populat=
ed_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 continue;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgr=
oup_mz_unreclaimable(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 break;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i &lt; 0)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear(n=
id, do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_watermark_ok(=
mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CHARGE_WMARK_HIGH)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D=
 true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nodes_empty(do_nodes)) {=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D=
 true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* All the nodes are unreclaimable, kswapd i=
s done */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (nodes_empty(do_nodes)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &amp;&amp; priority &lt; D=
EF_PRIORITY - 2)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, HZ/10=
);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_reclaimed &gt;=3D SWAP_CLUSTER_MAX=
)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 }<br>
&gt; +out:<br>
&gt; + =A0 =A0 if (!wmark_ok) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 try_to_freeze();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 goto loop_again;<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 return sc.nr_reclaimed;<br>
&gt; +}<br>
&gt; +#else<br>
&gt; =A0static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *me=
m_cont,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int order)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt; +#endif<br>
&gt;<br>
&gt; =A0/*<br>
&gt; =A0 * The background pageout daemon, started as a kernel thread<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
</div></div>&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Fight unfair telecom internet charges in Canada: sign <a href=3D"http:=
//stopthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
&gt;<br>
<br>
</blockquote></div><br>

--000e0cdfd082e38ef904a0d48fe6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
