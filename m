Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5B2900137
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 16:39:53 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p7BKdmSU020236
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 13:39:48 -0700
Received: from qwc23 (qwc23.prod.google.com [10.241.193.151])
	by wpaz5.hot.corp.google.com with ESMTP id p7BKaNSp028780
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 13:39:47 -0700
Received: by qwc23 with SMTP id 23so1634886qwc.31
        for <linux-mm@kvack.org>; Thu, 11 Aug 2011 13:39:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
Date: Thu, 11 Aug 2011 13:39:45 -0700
Message-ID: <CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016368321161db04904aa40cc96
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--0016368321161db04904aa40cc96
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.org>wrote:

> When a memcg hits its hard limit, hierarchical target reclaim is
> invoked, which goes through all contributing memcgs in the hierarchy
> below the offending memcg and reclaims from the respective per-memcg
> lru lists.  This distributes pressure fairly among all involved
> memcgs, and pages are aged with respect to their list buddies.
>
> When global memory pressure arises, however, all this is dropped
> overboard.  Pages are reclaimed based on global lru lists that have
> nothing to do with container-internal age, and some memcgs may be
> reclaimed from much more than others.
>
> This patch makes traditional global reclaim consider container
> boundaries and no longer scan the global lru lists.  For each zone
> scanned, the memcg hierarchy is walked and pages are reclaimed from
> the per-memcg lru lists of the respective zone.  For now, the
> hierarchy walk is bounded to one full round-trip through the
> hierarchy, or if the number of reclaimed pages reach the overall
> reclaim target, whichever comes first.
>
> Conceptually, global memory pressure is then treated as if the root
> memcg had hit its limit.  Since all existing memcgs contribute to the
> usage of the root memcg, global reclaim is nothing more than target
> reclaim starting from the root memcg.  The code is mostly the same for
> both cases, except for a few heuristics and statistics that do not
> always apply.  They are distinguished by a newly introduced
> global_reclaim() primitive.
>
> One implication of this change is that pages have to be linked to the
> lru lists of the root memcg again, which could be optimized away with
> the old scheme.  The costs are not measurable, though, even with
> worst-case microbenchmarks.
>
> As global reclaim no longer relies on global lru lists, this change is
> also in preparation to remove those completely.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |   15 ++++
>  mm/memcontrol.c            |  176
> ++++++++++++++++++++++++++++----------------
>  mm/vmscan.c                |  121 ++++++++++++++++++++++--------
>  3 files changed, 218 insertions(+), 94 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5e9840f5..332b0a6 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -101,6 +101,10 @@ mem_cgroup_prepare_migration(struct page *page,
>  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
>        struct page *oldpage, struct page *newpage, bool migration_ok);
>
> +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *,
> +                                            struct mem_cgroup *);
> +void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup
> *);
> +
>  /*
>  * For memory reclaim.
>  */
> @@ -321,6 +325,17 @@ mem_cgroup_get_reclaim_stat_from_page(struct page
> *page)
>        return NULL;
>  }
>
> +static inline struct mem_cgroup *mem_cgroup_hierarchy_walk(struct
> mem_cgroup *r,
> +                                                          struct
> mem_cgroup *m)
> +{
> +       return NULL;
> +}
> +
> +static inline void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *r,
> +                                                 struct mem_cgroup *m)
> +{
> +}
> +
>  static inline void
>  mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bf5ab87..850176e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -313,8 +313,8 @@ static bool move_file(void)
>  }
>
>  /*
> - * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
> - * limit reclaim to prevent infinite loops, if they ever occur.
> + * Maximum loops in reclaim, used for soft limit reclaim to prevent
> + * infinite loops, if they ever occur.
>  */
>  #define        MEM_CGROUP_MAX_RECLAIM_LOOPS            (100)
>  #define        MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS (2)
> @@ -340,7 +340,7 @@ enum charge_type {
>  #define OOM_CONTROL            (0)
>
>  /*
> - * Reclaim flags for mem_cgroup_hierarchical_reclaim
> + * Reclaim flags
>  */
>  #define MEM_CGROUP_RECLAIM_NOSWAP_BIT  0x0
>  #define MEM_CGROUP_RECLAIM_NOSWAP      (1 <<
> MEM_CGROUP_RECLAIM_NOSWAP_BIT)
> @@ -846,8 +846,6 @@ void mem_cgroup_del_lru_list(struct page *page, enum
> lru_list lru)
>        mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>        /* huge page split is done under lru_lock. so, we have no races. */
>        MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> -       if (mem_cgroup_is_root(pc->mem_cgroup))
> -               return;
>        VM_BUG_ON(list_empty(&pc->lru));
>        list_del_init(&pc->lru);
>  }
> @@ -872,13 +870,11 @@ void mem_cgroup_rotate_reclaimable_page(struct page
> *page)
>                return;
>
>        pc = lookup_page_cgroup(page);
> -       /* unused or root page is not rotated. */
> +       /* unused page is not rotated. */
>        if (!PageCgroupUsed(pc))
>                return;
>        /* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
>        smp_rmb();
> -       if (mem_cgroup_is_root(pc->mem_cgroup))
> -               return;
>        mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>        list_move_tail(&pc->lru, &mz->lists[lru]);
>  }
> @@ -892,13 +888,11 @@ void mem_cgroup_rotate_lru_list(struct page *page,
> enum lru_list lru)
>                return;
>
>        pc = lookup_page_cgroup(page);
> -       /* unused or root page is not rotated. */
> +       /* unused page is not rotated. */
>        if (!PageCgroupUsed(pc))
>                return;
>        /* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
>        smp_rmb();
> -       if (mem_cgroup_is_root(pc->mem_cgroup))
> -               return;
>        mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>        list_move(&pc->lru, &mz->lists[lru]);
>  }
> @@ -920,8 +914,6 @@ void mem_cgroup_add_lru_list(struct page *page, enum
> lru_list lru)
>        /* huge page split is done under lru_lock. so, we have no races. */
>        MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
>        SetPageCgroupAcctLRU(pc);
> -       if (mem_cgroup_is_root(pc->mem_cgroup))
> -               return;
>        list_add(&pc->lru, &mz->lists[lru]);
>  }
>
> @@ -1381,6 +1373,97 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
>        return min(limit, memsw);
>  }
>
> +/**
> + * mem_cgroup_hierarchy_walk - iterate over a memcg hierarchy
> + * @root: starting point of the hierarchy
> + * @prev: previous position or NULL
> + *
> + * Caller must hold a reference to @root.  While this function will
> + * return @root as part of the walk, it will never increase its
> + * reference count.
> + *
> + * Caller must clean up with mem_cgroup_stop_hierarchy_walk() when it
> + * stops the walk potentially before the full round trip.
> + */
> +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> +                                            struct mem_cgroup *prev)
> +{
> +       struct mem_cgroup *mem;
> +
> +       if (mem_cgroup_disabled())
> +               return NULL;
> +
> +       if (!root)
> +               root = root_mem_cgroup;
> +       /*
> +        * Even without hierarchy explicitely enabled in the root
> +        * memcg, it is the ultimate parent of all memcgs.
> +        */
> +       if (!(root == root_mem_cgroup || root->use_hierarchy))
> +               return root;
> +       if (prev && prev != root)
> +               css_put(&prev->css);
> +       do {
> +               int id = root->last_scanned_child;
> +               struct cgroup_subsys_state *css;
> +
> +               rcu_read_lock();
> +               css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css,
> &id);
> +               if (css && (css == &root->css || css_tryget(css)))
> +                       mem = container_of(css, struct mem_cgroup, css);
> +               rcu_read_unlock();
> +               if (!css)
> +                       id = 0;
> +               root->last_scanned_child = id;
> +       } while (!mem);
> +       return mem;
> +}
> +
> +/**
> + * mem_cgroup_stop_hierarchy_walk - clean up after partial hierarchy walk
> + * @root: starting point in the hierarchy
> + * @mem: last position during the walk
> + */
> +void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *root,
> +                                   struct mem_cgroup *mem)
> +{
> +       if (mem && mem != root)
> +               css_put(&mem->css);
> +}
> +
> +static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
> +                                       gfp_t gfp_mask,
> +                                       unsigned long flags)
> +{
> +       unsigned long total = 0;
> +       bool noswap = false;
> +       int loop;
> +
> +       if ((flags & MEM_CGROUP_RECLAIM_NOSWAP) || mem->memsw_is_minimum)
> +               noswap = true;
> +       for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
> +               drain_all_stock_async();
> +               total += try_to_free_mem_cgroup_pages(mem, gfp_mask,
> noswap,
> +                                                     get_swappiness(mem));
> +               /*
> +                * Avoid freeing too much when shrinking to resize the
> +                * limit.  XXX: Shouldn't the margin check be enough?
> +                */
> +               if (total && (flags & MEM_CGROUP_RECLAIM_SHRINK))
> +                       break;
> +               if (mem_cgroup_margin(mem))
> +                       break;
> +               /*
> +                * If we have not been able to reclaim anything after
> +                * two reclaim attempts, there may be no reclaimable
> +                * pages in this hierarchy.
> +                */
> +               if (loop && !total)
> +                       break;
> +       }
> +       return total;
> +}
> +
>  /*
>  * Visit the first child (need not be the first child as per the ordering
>  * of the cgroup list, since we track last_scanned_child) of @mem and use
> @@ -1418,29 +1501,14 @@ mem_cgroup_select_victim(struct mem_cgroup
> *root_mem)
>        return ret;
>  }
>
> -/*
> - * Scan the hierarchy if needed to reclaim memory. We remember the last
> child
> - * we reclaimed from, so that we don't end up penalizing one child
> extensively
> - * based on its position in the children list.
> - *
> - * root_mem is the original ancestor that we've been reclaim from.
> - *
> - * We give up and return to the caller when we visit root_mem twice.
> - * (other groups can be removed while we're walking....)
> - *
> - * If shrink==true, for avoiding to free too much, this returns
> immedieately.
> - */
> -static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> -                                               struct zone *zone,
> -                                               gfp_t gfp_mask,
> -                                               unsigned long
> reclaim_options)
> +static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
> +                                  struct zone *zone,
> +                                  gfp_t gfp_mask)
>  {
>        struct mem_cgroup *victim;
>        int ret, total = 0;
>        int loop = 0;
> -       bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
> -       bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
> -       bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
> +       bool noswap = false;
>        unsigned long excess;
>
>        excess = res_counter_soft_limit_excess(&root_mem->res) >>
> PAGE_SHIFT;
> @@ -1461,7 +1529,7 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
>                                 * anything, it might because there are
>                                 * no reclaimable pages under this hierarchy
>                                 */
> -                               if (!check_soft || !total) {
> +                               if (!total) {
>                                        css_put(&victim->css);
>                                        break;
>                                }
> @@ -1483,26 +1551,11 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
>                        css_put(&victim->css);
>                        continue;
>                }
> -               /* we use swappiness of local cgroup */
> -               if (check_soft)
> -                       ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> -                               noswap, get_swappiness(victim), zone);
> -               else
> -                       ret = try_to_free_mem_cgroup_pages(victim,
> gfp_mask,
> -                                               noswap,
> get_swappiness(victim));
> +               ret = mem_cgroup_shrink_node_zone(victim, gfp_mask, noswap,
> +                                                 get_swappiness(victim),
> zone);
>                css_put(&victim->css);
> -               /*
> -                * At shrinking usage, we can't check we should stop here
> or
> -                * reclaim more. It's depends on callers.
> last_scanned_child
> -                * will work enough for keeping fairness under tree.
> -                */
> -               if (shrink)
> -                       return ret;
>                total += ret;
> -               if (check_soft) {
> -                       if (!res_counter_soft_limit_excess(&root_mem->res))
> -                               return total;
> -               } else if (mem_cgroup_margin(root_mem))
> +               if (!res_counter_soft_limit_excess(&root_mem->res))
>                        return total;
>        }
>        return total;
> @@ -1927,8 +1980,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup
> *mem, gfp_t gfp_mask,
>        if (!(gfp_mask & __GFP_WAIT))
>                return CHARGE_WOULDBLOCK;
>
> -       ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> -                                             gfp_mask, flags);
> +       ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
>        if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>                return CHARGE_RETRY;
>        /*
> @@ -3085,7 +3137,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>
>  /*
>  * A call to try to shrink memory usage on charge failure at shmem's
> swapin.
> - * Calling hierarchical_reclaim is not enough because we should update
> + * Calling reclaim is not enough because we should update
>  * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global
> OOM.
>  * Moreover considering hierarchy, we should reclaim from the
> mem_over_limit,
>  * not from the memcg which this page would be charged to.
> @@ -3167,7 +3219,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup
> *memcg,
>        int enlarge;
>
>        /*
> -        * For keeping hierarchical_reclaim simple, how long we should
> retry
> +        * For keeping reclaim simple, how long we should retry
>         * is depends on callers. We set our retry-count to be function
>         * of # of children which we should visit in this loop.
>         */
> @@ -3210,8 +3262,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup
> *memcg,
>                if (!ret)
>                        break;
>
> -               mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> -                                               MEM_CGROUP_RECLAIM_SHRINK);
> +               mem_cgroup_reclaim(memcg, GFP_KERNEL,
> +                                  MEM_CGROUP_RECLAIM_SHRINK);
>                curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
>                /* Usage is reduced ? */
>                if (curusage >= oldusage)
> @@ -3269,9 +3321,9 @@ static int mem_cgroup_resize_memsw_limit(struct
> mem_cgroup *memcg,
>                if (!ret)
>                        break;
>
> -               mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> -                                               MEM_CGROUP_RECLAIM_NOSWAP |
> -                                               MEM_CGROUP_RECLAIM_SHRINK);
> +               mem_cgroup_reclaim(memcg, GFP_KERNEL,
> +                                  MEM_CGROUP_RECLAIM_NOSWAP |
> +                                  MEM_CGROUP_RECLAIM_SHRINK);
>                curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>                /* Usage is reduced ? */
>                if (curusage >= oldusage)
> @@ -3311,9 +3363,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct
> zone *zone, int order,
>                if (!mz)
>                        break;
>
> -               reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
> -                                               gfp_mask,
> -                                               MEM_CGROUP_RECLAIM_SOFT);
> +               reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone,
> gfp_mask);
>                nr_reclaimed += reclaimed;
>                spin_lock(&mctz->lock);
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8bfd450..7e9bfca 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -104,7 +104,16 @@ struct scan_control {
>         */
>        reclaim_mode_t reclaim_mode;
>
> -       /* Which cgroup do we reclaim from */
> +       /*
> +        * The memory cgroup that hit its hard limit and is the
> +        * primary target of this reclaim invocation.
> +        */
> +       struct mem_cgroup *target_mem_cgroup;
> +
> +       /*
> +        * The memory cgroup that is currently being scanned as a
> +        * child and contributor to the usage of target_mem_cgroup.
> +        */
>        struct mem_cgroup *mem_cgroup;
>
>        /*
> @@ -154,9 +163,36 @@ static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -#define scanning_global_lru(sc)        (!(sc)->mem_cgroup)
> +/**
> + * global_reclaim - whether reclaim is global or due to memcg hard limit
> + * @sc: scan control of this reclaim invocation
> + */
> +static bool global_reclaim(struct scan_control *sc)
> +{
> +       return !sc->target_mem_cgroup;
> +}
> +/**
> + * scanning_global_lru - whether scanning global lrus or per-memcg lrus
> + * @sc: scan control of this reclaim invocation
> + */
> +static bool scanning_global_lru(struct scan_control *sc)
> +{
> +       /*
> +        * Unless memory cgroups are disabled on boot, the traditional
> +        * global lru lists are never scanned and reclaim will always
> +        * operate on the per-memcg lru lists.
> +        */
> +       return mem_cgroup_disabled();
> +}
>  #else
> -#define scanning_global_lru(sc)        (1)
> +static bool global_reclaim(struct scan_control *sc)
> +{
> +       return true;
> +}
> +static bool scanning_global_lru(struct scan_control *sc)
> +{
> +       return true;
> +}
>  #endif
>
>  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> @@ -1228,7 +1264,7 @@ static int too_many_isolated(struct zone *zone, int
> file,
>        if (current_is_kswapd())
>                return 0;
>
> -       if (!scanning_global_lru(sc))
> +       if (!global_reclaim(sc))
>                return 0;
>
>        if (file) {
> @@ -1397,13 +1433,6 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
>                        sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
>                                        ISOLATE_BOTH : ISOLATE_INACTIVE,
>                        zone, 0, file);
> -               zone->pages_scanned += nr_scanned;
> -               if (current_is_kswapd())
> -                       __count_zone_vm_events(PGSCAN_KSWAPD, zone,
> -                                              nr_scanned);
> -               else
> -                       __count_zone_vm_events(PGSCAN_DIRECT, zone,
> -                                              nr_scanned);
>        } else {
>                nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
>                        &page_list, &nr_scanned, sc->order,
> @@ -1411,10 +1440,16 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
>                                        ISOLATE_BOTH : ISOLATE_INACTIVE,
>                        zone, sc->mem_cgroup,
>                        0, file);
> -               /*
> -                * mem_cgroup_isolate_pages() keeps track of
> -                * scanned pages on its own.
> -                */
> +       }
> +
> +       if (global_reclaim(sc)) {
> +               zone->pages_scanned += nr_scanned;
> +               if (current_is_kswapd())
> +                       __count_zone_vm_events(PGSCAN_KSWAPD, zone,
> +                                              nr_scanned);
> +               else
> +                       __count_zone_vm_events(PGSCAN_DIRECT, zone,
> +                                              nr_scanned);
>        }
>
>        if (nr_taken == 0) {
> @@ -1520,18 +1555,16 @@ static void shrink_active_list(unsigned long
> nr_pages, struct zone *zone,
>                                                &pgscanned, sc->order,
>                                                ISOLATE_ACTIVE, zone,
>                                                1, file);
> -               zone->pages_scanned += pgscanned;
>        } else {
>                nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
>                                                &pgscanned, sc->order,
>                                                ISOLATE_ACTIVE, zone,
>                                                sc->mem_cgroup, 1, file);
> -               /*
> -                * mem_cgroup_isolate_pages() keeps track of
> -                * scanned pages on its own.
> -                */
>        }
>
> +       if (global_reclaim(sc))
> +               zone->pages_scanned += pgscanned;
> +
>        reclaim_stat->recent_scanned[file] += nr_taken;
>
>        __count_zone_vm_events(PGREFILL, zone, pgscanned);
> @@ -1752,7 +1785,7 @@ static void get_scan_count(struct zone *zone, struct
> scan_control *sc,
>        file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
>                zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
>
> -       if (scanning_global_lru(sc)) {
> +       if (global_reclaim(sc)) {
>                free  = zone_page_state(zone, NR_FREE_PAGES);
>                /* If we have very few page cache pages,
>                   force-scan anon pages. */
> @@ -1889,8 +1922,8 @@ static inline bool should_continue_reclaim(struct
> zone *zone,
>  /*
>  * This is a basic per-zone page freer.  Used by both kswapd and direct
> reclaim.
>  */
> -static void shrink_zone(int priority, struct zone *zone,
> -                               struct scan_control *sc)
> +static void do_shrink_zone(int priority, struct zone *zone,
> +                          struct scan_control *sc)
>  {
>        unsigned long nr[NR_LRU_LISTS];
>        unsigned long nr_to_scan;
> @@ -1943,6 +1976,31 @@ restart:
>        throttle_vm_writeout(sc->gfp_mask);
>  }
>
> +static void shrink_zone(int priority, struct zone *zone,
> +                       struct scan_control *sc)
> +{
> +       unsigned long nr_reclaimed_before = sc->nr_reclaimed;
> +       struct mem_cgroup *root = sc->target_mem_cgroup;
> +       struct mem_cgroup *first, *mem = NULL;
> +
> +       first = mem = mem_cgroup_hierarchy_walk(root, mem);
> +       for (;;) {
> +               unsigned long nr_reclaimed;
> +
> +               sc->mem_cgroup = mem;
> +               do_shrink_zone(priority, zone, sc);
> +
> +               nr_reclaimed = sc->nr_reclaimed - nr_reclaimed_before;
> +               if (nr_reclaimed >= sc->nr_to_reclaim)
> +                       break;
> +
> +               mem = mem_cgroup_hierarchy_walk(root, mem);
> +               if (mem == first)
> +                       break;
> +       }
> +       mem_cgroup_stop_hierarchy_walk(root, mem);
> +}
> +
>  /*
>  * This is the direct reclaim path, for page-allocating processes.  We only
>  * try to reclaim pages from zones which will satisfy the caller's
> allocation
> @@ -1973,7 +2031,7 @@ static void shrink_zones(int priority, struct
> zonelist *zonelist,
>                 * Take care memory controller reclaiming has small
> influence
>                 * to global LRU.
>                 */
> -               if (scanning_global_lru(sc)) {
> +               if (global_reclaim(sc)) {
>                        if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>                                continue;
>                        if (zone->all_unreclaimable && priority !=
> DEF_PRIORITY)
> @@ -2038,7 +2096,7 @@ static unsigned long do_try_to_free_pages(struct
> zonelist *zonelist,
>        get_mems_allowed();
>        delayacct_freepages_start();
>
> -       if (scanning_global_lru(sc))
> +       if (global_reclaim(sc))
>                count_vm_event(ALLOCSTALL);
>
>        for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> @@ -2050,7 +2108,7 @@ static unsigned long do_try_to_free_pages(struct
> zonelist *zonelist,
>                 * Don't shrink slabs when reclaiming memory from
>                 * over limit cgroups
>                 */
> -               if (scanning_global_lru(sc)) {
> +               if (global_reclaim(sc)) {
>                        unsigned long lru_pages = 0;
>                        for_each_zone_zonelist(zone, z, zonelist,
>                                        gfp_zone(sc->gfp_mask)) {
> @@ -2111,7 +2169,7 @@ out:
>                return 0;
>
>        /* top priority shrink_zones still had more to do? don't OOM, then
> */
> -       if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
> +       if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
>                return 1;
>
>        return 0;
> @@ -2129,7 +2187,7 @@ unsigned long try_to_free_pages(struct zonelist
> *zonelist, int order,
>                .may_swap = 1,
>                .swappiness = vm_swappiness,
>                .order = order,
> -               .mem_cgroup = NULL,
> +               .target_mem_cgroup = NULL,
>                .nodemask = nodemask,
>        };
>
> @@ -2158,6 +2216,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct
> mem_cgroup *mem,
>                .may_swap = !noswap,
>                .swappiness = swappiness,
>                .order = 0,
> +               .target_mem_cgroup = mem,
>                .mem_cgroup = mem,
>        };
>        sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> @@ -2174,7 +2233,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct
> mem_cgroup *mem,
>         * will pick up pages from other mem cgroup's as well. We hack
>         * the priority and make it zero.
>         */
> -       shrink_zone(0, zone, &sc);
> +       do_shrink_zone(0, zone, &sc);
>
>        trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>
> @@ -2195,7 +2254,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct
> mem_cgroup *mem_cont,
>                .nr_to_reclaim = SWAP_CLUSTER_MAX,
>                .swappiness = swappiness,
>                .order = 0,
> -               .mem_cgroup = mem_cont,
> +               .target_mem_cgroup = mem_cont,
>                .nodemask = NULL, /* we don't care the placement */
>        };
>
> @@ -2333,7 +2392,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat,
> int order,
>                .nr_to_reclaim = ULONG_MAX,
>                .swappiness = vm_swappiness,
>                .order = order,
> -               .mem_cgroup = NULL,
> +               .target_mem_cgroup = NULL,
>        };
>  loop_again:
>        total_scanned = 0;
>

Please consider including the following patch for the next post. It causes
crash on some of the tests where sc->mem_cgroup is NULL (global kswapd).

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b72a844..12ab25d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2768,7 +2768,8 @@ loop_again:
                         * Do some background aging of the anon list, to
give
                         * pages a chance to be referenced before
reclaiming.
                         */
-                       if (inactive_anon_is_low(zone, &sc))
+                       if (scanning_global_lru(&sc) &&
+                                       inactive_anon_is_low(zone, &sc))
                                shrink_active_list(SWAP_CLUSTER_MAX, zone,
                                                        &sc, priority, 0);

--Ying

> --
> 1.7.5.2
>
>

--0016368321161db04904aa40cc96
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 31, 2011 at 11:25 PM, Johann=
es Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hanne=
s@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
When a memcg hits its hard limit, hierarchical target reclaim is<br>
invoked, which goes through all contributing memcgs in the hierarchy<br>
below the offending memcg and reclaims from the respective per-memcg<br>
lru lists. =A0This distributes pressure fairly among all involved<br>
memcgs, and pages are aged with respect to their list buddies.<br>
<br>
When global memory pressure arises, however, all this is dropped<br>
overboard. =A0Pages are reclaimed based on global lru lists that have<br>
nothing to do with container-internal age, and some memcgs may be<br>
reclaimed from much more than others.<br>
<br>
This patch makes traditional global reclaim consider container<br>
boundaries and no longer scan the global lru lists. =A0For each zone<br>
scanned, the memcg hierarchy is walked and pages are reclaimed from<br>
the per-memcg lru lists of the respective zone. =A0For now, the<br>
hierarchy walk is bounded to one full round-trip through the<br>
hierarchy, or if the number of reclaimed pages reach the overall<br>
reclaim target, whichever comes first.<br>
<br>
Conceptually, global memory pressure is then treated as if the root<br>
memcg had hit its limit. =A0Since all existing memcgs contribute to the<br>
usage of the root memcg, global reclaim is nothing more than target<br>
reclaim starting from the root memcg. =A0The code is mostly the same for<br=
>
both cases, except for a few heuristics and statistics that do not<br>
always apply. =A0They are distinguished by a newly introduced<br>
global_reclaim() primitive.<br>
<br>
One implication of this change is that pages have to be linked to the<br>
lru lists of the root memcg again, which could be optimized away with<br>
the old scheme. =A0The costs are not measurable, though, even with<br>
worst-case microbenchmarks.<br>
<br>
As global reclaim no longer relies on global lru lists, this change is<br>
also in preparation to remove those completely.<br>
<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">ha=
nnes@cmpxchg.org</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 15 ++++<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0176 ++++++++++++++++++++++++=
++++----------------<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0121 ++++++++++++++++++++=
++--------<br>
=A03 files changed, 218 insertions(+), 94 deletions(-)<br>
<br>
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<br>
index 5e9840f5..332b0a6 100644<br>
--- a/include/linux/memcontrol.h<br>
+++ b/include/linux/memcontrol.h<br>
@@ -101,6 +101,10 @@ mem_cgroup_prepare_migration(struct page *page,<br>
=A0extern void mem_cgroup_end_migration(struct mem_cgroup *mem,<br>
 =A0 =A0 =A0 =A0struct page *oldpage, struct page *newpage, bool migration_=
ok);<br>
<br>
+struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0struct mem_cgroup *);<br>
+void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup=
 *);<br>
+<br>
=A0/*<br>
 =A0* For memory reclaim.<br>
 =A0*/<br>
@@ -321,6 +325,17 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *pag=
e)<br>
 =A0 =A0 =A0 =A0return NULL;<br>
=A0}<br>
<br>
+static inline struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgro=
up *r,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup *m)<br>
+{<br>
+ =A0 =A0 =A0 return NULL;<br>
+}<br>
+<br>
+static inline void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *r,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *m)<br>
+{<br>
+}<br>
+<br>
=A0static inline void<br>
=A0mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *=
p)<br>
=A0{<br>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
index bf5ab87..850176e 100644<br>
--- a/mm/memcontrol.c<br>
+++ b/mm/memcontrol.c<br>
@@ -313,8 +313,8 @@ static bool move_file(void)<br>
=A0}<br>
<br>
=A0/*<br>
- * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft<br>
- * limit reclaim to prevent infinite loops, if they ever occur.<br>
+ * Maximum loops in reclaim, used for soft limit reclaim to prevent<br>
+ * infinite loops, if they ever occur.<br>
 =A0*/<br>
=A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_RECLAIM_LOOPS =A0 =A0 =A0 =A0 =A0 =
=A0(100)<br>
=A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS (2)<br>
@@ -340,7 +340,7 @@ enum charge_type {<br>
=A0#define OOM_CONTROL =A0 =A0 =A0 =A0 =A0 =A0(0)<br>
<br>
=A0/*<br>
- * Reclaim flags for mem_cgroup_hierarchical_reclaim<br>
+ * Reclaim flags<br>
 =A0*/<br>
=A0#define MEM_CGROUP_RECLAIM_NOSWAP_BIT =A00x0<br>
=A0#define MEM_CGROUP_RECLAIM_NOSWAP =A0 =A0 =A0(1 &lt;&lt; MEM_CGROUP_RECL=
AIM_NOSWAP_BIT)<br>
@@ -846,8 +846,6 @@ void mem_cgroup_del_lru_list(struct page *page, enum lr=
u_list lru)<br>
 =A0 =A0 =A0 =A0mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
 =A0 =A0 =A0 =A0/* huge page split is done under lru_lock. so, we have no r=
aces. */<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 &lt;&lt; compound_order(pa=
ge);<br>
- =A0 =A0 =A0 if (mem_cgroup_is_root(pc-&gt;mem_cgroup))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
 =A0 =A0 =A0 =A0VM_BUG_ON(list_empty(&amp;pc-&gt;lru));<br>
 =A0 =A0 =A0 =A0list_del_init(&amp;pc-&gt;lru);<br>
=A0}<br>
@@ -872,13 +870,11 @@ void mem_cgroup_rotate_reclaimable_page(struct page *=
page)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
<br>
 =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);<br>
- =A0 =A0 =A0 /* unused or root page is not rotated. */<br>
+ =A0 =A0 =A0 /* unused page is not rotated. */<br>
 =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
 =A0 =A0 =A0 =A0/* Ensure pc-&gt;mem_cgroup is visible after reading PCG_US=
ED. */<br>
 =A0 =A0 =A0 =A0smp_rmb();<br>
- =A0 =A0 =A0 if (mem_cgroup_is_root(pc-&gt;mem_cgroup))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
 =A0 =A0 =A0 =A0mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
 =A0 =A0 =A0 =A0list_move_tail(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br=
>
=A0}<br>
@@ -892,13 +888,11 @@ void mem_cgroup_rotate_lru_list(struct page *page, en=
um lru_list lru)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
<br>
 =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);<br>
- =A0 =A0 =A0 /* unused or root page is not rotated. */<br>
+ =A0 =A0 =A0 /* unused page is not rotated. */<br>
 =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
 =A0 =A0 =A0 =A0/* Ensure pc-&gt;mem_cgroup is visible after reading PCG_US=
ED. */<br>
 =A0 =A0 =A0 =A0smp_rmb();<br>
- =A0 =A0 =A0 if (mem_cgroup_is_root(pc-&gt;mem_cgroup))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
 =A0 =A0 =A0 =A0mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
 =A0 =A0 =A0 =A0list_move(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
=A0}<br>
@@ -920,8 +914,6 @@ void mem_cgroup_add_lru_list(struct page *page, enum lr=
u_list lru)<br>
 =A0 =A0 =A0 =A0/* huge page split is done under lru_lock. so, we have no r=
aces. */<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, lru) +=3D 1 &lt;&lt; compound_order(pa=
ge);<br>
 =A0 =A0 =A0 =A0SetPageCgroupAcctLRU(pc);<br>
- =A0 =A0 =A0 if (mem_cgroup_is_root(pc-&gt;mem_cgroup))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
 =A0 =A0 =A0 =A0list_add(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
=A0}<br>
<br>
@@ -1381,6 +1373,97 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)<b=
r>
 =A0 =A0 =A0 =A0return min(limit, memsw);<br>
=A0}<br>
<br>
+/**<br>
+ * mem_cgroup_hierarchy_walk - iterate over a memcg hierarchy<br>
+ * @root: starting point of the hierarchy<br>
+ * @prev: previous position or NULL<br>
+ *<br>
+ * Caller must hold a reference to @root. =A0While this function will<br>
+ * return @root as part of the walk, it will never increase its<br>
+ * reference count.<br>
+ *<br>
+ * Caller must clean up with mem_cgroup_stop_hierarchy_walk() when it<br>
+ * stops the walk potentially before the full round trip.<br>
+ */<br>
+struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0struct mem_cgroup *prev)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem;<br>
+<br>
+ =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
+<br>
+ =A0 =A0 =A0 if (!root)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 root =3D root_mem_cgroup;<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Even without hierarchy explicitely enabled in the root<b=
r>
+ =A0 =A0 =A0 =A0* memcg, it is the ultimate parent of all memcgs.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 if (!(root =3D=3D root_mem_cgroup || root-&gt;use_hierarchy))=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return root;<br>
+ =A0 =A0 =A0 if (prev &amp;&amp; prev !=3D root)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&amp;prev-&gt;css);<br>
+ =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 int id =3D root-&gt;last_scanned_child;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys_state *css;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 css =3D css_get_next(&amp;mem_cgroup_subsys, =
id + 1, &amp;root-&gt;css, &amp;id);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (css &amp;&amp; (css =3D=3D &amp;root-&gt;=
css || css_tryget(css)))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D container_of(css, str=
uct mem_cgroup, css);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!css)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 root-&gt;last_scanned_child =3D id;<br>
+ =A0 =A0 =A0 } while (!mem);<br>
+ =A0 =A0 =A0 return mem;<br>
+}<br>
+<br>
+/**<br>
+ * mem_cgroup_stop_hierarchy_walk - clean up after partial hierarchy walk<=
br>
+ * @root: starting point in the hierarchy<br>
+ * @mem: last position during the walk<br>
+ */<br>
+void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *root,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struc=
t mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 if (mem &amp;&amp; mem !=3D root)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&amp;mem-&gt;css);<br>
+}<br>
+<br>
+static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 gfp_t gfp_mask,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long flags)<br>
+{<br>
+ =A0 =A0 =A0 unsigned long total =3D 0;<br>
+ =A0 =A0 =A0 bool noswap =3D false;<br>
+ =A0 =A0 =A0 int loop;<br>
+<br>
+ =A0 =A0 =A0 if ((flags &amp; MEM_CGROUP_RECLAIM_NOSWAP) || mem-&gt;memsw_=
is_minimum)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap =3D true;<br>
+ =A0 =A0 =A0 for (loop =3D 0; loop &lt; MEM_CGROUP_MAX_RECLAIM_LOOPS; loop=
++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_stock_async();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D try_to_free_mem_cgroup_pages(mem, =
gfp_mask, noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_swappiness(mem));<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Avoid freeing too much when shrinking to=
 resize the<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* limit. =A0XXX: Shouldn&#39;t the margin =
check be enough?<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total &amp;&amp; (flags &amp; MEM_CGROUP_=
RECLAIM_SHRINK))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_margin(mem))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we have not been able to reclaim anyt=
hing after<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* two reclaim attempts, there may be no re=
claimable<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages in this hierarchy.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop &amp;&amp; !total)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 return total;<br>
+}<br>
+<br>
=A0/*<br>
 =A0* Visit the first child (need not be the first child as per the orderin=
g<br>
 =A0* of the cgroup list, since we track last_scanned_child) of @mem and us=
e<br>
@@ -1418,29 +1501,14 @@ mem_cgroup_select_victim(struct mem_cgroup *root_me=
m)<br>
 =A0 =A0 =A0 =A0return ret;<br>
=A0}<br>
<br>
-/*<br>
- * Scan the hierarchy if needed to reclaim memory. We remember the last ch=
ild<br>
- * we reclaimed from, so that we don&#39;t end up penalizing one child ext=
ensively<br>
- * based on its position in the children list.<br>
- *<br>
- * root_mem is the original ancestor that we&#39;ve been reclaim from.<br>
- *<br>
- * We give up and return to the caller when we visit root_mem twice.<br>
- * (other groups can be removed while we&#39;re walking....)<br>
- *<br>
- * If shrink=3D=3Dtrue, for avoiding to free too much, this returns immedi=
eately.<br>
- */<br>
-static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,<br=
>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long reclaim_options)<br>
+static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 zone *zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t =
gfp_mask)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *victim;<br>
 =A0 =A0 =A0 =A0int ret, total =3D 0;<br>
 =A0 =A0 =A0 =A0int loop =3D 0;<br>
- =A0 =A0 =A0 bool noswap =3D reclaim_options &amp; MEM_CGROUP_RECLAIM_NOSW=
AP;<br>
- =A0 =A0 =A0 bool shrink =3D reclaim_options &amp; MEM_CGROUP_RECLAIM_SHRI=
NK;<br>
- =A0 =A0 =A0 bool check_soft =3D reclaim_options &amp; MEM_CGROUP_RECLAIM_=
SOFT;<br>
+ =A0 =A0 =A0 bool noswap =3D false;<br>
 =A0 =A0 =A0 =A0unsigned long excess;<br>
<br>
 =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&amp;root_mem-&gt;=
res) &gt;&gt; PAGE_SHIFT;<br>
@@ -1461,7 +1529,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem=
_cgroup *root_mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * anything=
, it might because there are<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * no recla=
imable pages under this hierarchy<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!check_so=
ft || !total) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!total) {=
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0css_put(&amp;victim-&gt;css);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0break;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
@@ -1483,26 +1551,11 @@ static int mem_cgroup_hierarchical_reclaim(struct m=
em_cgroup *root_mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css=
);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we use swappiness of local cgroup */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (check_soft)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_shrink_nod=
e_zone(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, get_s=
wappiness(victim), zone);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D try_to_free_mem_cgrou=
p_pages(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 noswap, get_swappiness(victim));<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_shrink_node_zone(victim, g=
fp_mask, noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 get_swappiness(victim), zone);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* At shrinking usage, we can&#39;t check w=
e should stop here or<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* reclaim more. It&#39;s depends on caller=
s. last_scanned_child<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* will work enough for keeping fairness un=
der tree.<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (shrink)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total +=3D ret;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (check_soft) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res_counter_soft_limit_e=
xcess(&amp;root_mem-&gt;res))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return total;=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (mem_cgroup_margin(root_mem))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res_counter_soft_limit_excess(&amp;root_=
mem-&gt;res))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return total;<br>
 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0return total;<br>
@@ -1927,8 +1980,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *me=
m, gfp_t gfp_mask,<br>
 =A0 =A0 =A0 =A0if (!(gfp_mask &amp; __GFP_WAIT))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return CHARGE_WOULDBLOCK;<br>
<br>
- =A0 =A0 =A0 ret =3D mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 gfp_mask, flags);<br>
+ =A0 =A0 =A0 ret =3D mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);<=
br>
 =A0 =A0 =A0 =A0if (mem_cgroup_margin(mem_over_limit) &gt;=3D nr_pages)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return CHARGE_RETRY;<br>
 =A0 =A0 =A0 =A0/*<br>
@@ -3085,7 +3137,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,=
<br>
<br>
=A0/*<br>
 =A0* A call to try to shrink memory usage on charge failure at shmem&#39;s=
 swapin.<br>
- * Calling hierarchical_reclaim is not enough because we should update<br>
+ * Calling reclaim is not enough because we should update<br>
 =A0* last_oom_jiffies to prevent pagefault_out_of_memory from invoking glo=
bal OOM.<br>
 =A0* Moreover considering hierarchy, we should reclaim from the mem_over_l=
imit,<br>
 =A0* not from the memcg which this page would be charged to.<br>
@@ -3167,7 +3219,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup =
*memcg,<br>
 =A0 =A0 =A0 =A0int enlarge;<br>
<br>
 =A0 =A0 =A0 =A0/*<br>
- =A0 =A0 =A0 =A0* For keeping hierarchical_reclaim simple, how long we sho=
uld retry<br>
+ =A0 =A0 =A0 =A0* For keeping reclaim simple, how long we should retry<br>
 =A0 =A0 =A0 =A0 * is depends on callers. We set our retry-count to be func=
tion<br>
 =A0 =A0 =A0 =A0 * of # of children which we should visit in this loop.<br>
 =A0 =A0 =A0 =A0 */<br>
@@ -3210,8 +3262,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup =
*memcg,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_hierarchical_reclaim(memcg, NULL, =
GFP_KERNEL,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_SHRINK);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_reclaim(memcg, GFP_KERNEL,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_CG=
ROUP_RECLAIM_SHRINK);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0curusage =3D res_counter_read_u64(&amp;memc=
g-&gt;res, RES_USAGE);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Usage is reduced ? */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (curusage &gt;=3D oldusage)<br>
@@ -3269,9 +3321,9 @@ static int mem_cgroup_resize_memsw_limit(struct mem_c=
group *memcg,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_hierarchical_reclaim(memcg, NULL, =
GFP_KERNEL,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_NOSWAP |<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_SHRINK);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_reclaim(memcg, GFP_KERNEL,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_CG=
ROUP_RECLAIM_NOSWAP |<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_CG=
ROUP_RECLAIM_SHRINK);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0curusage =3D res_counter_read_u64(&amp;memc=
g-&gt;memsw, RES_USAGE);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Usage is reduced ? */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (curusage &gt;=3D oldusage)<br>
@@ -3311,9 +3363,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zo=
ne *zone, int order,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!mz)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaimed =3D mem_cgroup_hierarchical_reclaim=
(mz-&gt;mem, zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_SOFT);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaimed =3D mem_cgroup_soft_reclaim(mz-&gt;=
mem, zone, gfp_mask);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_reclaimed +=3D reclaimed;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&amp;mctz-&gt;lock);<br>
<br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
index 8bfd450..7e9bfca 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -104,7 +104,16 @@ struct scan_control {<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0reclaim_mode_t reclaim_mode;<br>
<br>
- =A0 =A0 =A0 /* Which cgroup do we reclaim from */<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* The memory cgroup that hit its hard limit and is the<br>
+ =A0 =A0 =A0 =A0* primary target of this reclaim invocation.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 struct mem_cgroup *target_mem_cgroup;<br>
+<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* The memory cgroup that is currently being scanned as a<b=
r>
+ =A0 =A0 =A0 =A0* child and contributor to the usage of target_mem_cgroup.=
<br>
+ =A0 =A0 =A0 =A0*/<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem_cgroup;<br>
<br>
 =A0 =A0 =A0 =A0/*<br>
@@ -154,9 +163,36 @@ static LIST_HEAD(shrinker_list);<br>
=A0static DECLARE_RWSEM(shrinker_rwsem);<br>
<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
-#define scanning_global_lru(sc) =A0 =A0 =A0 =A0(!(sc)-&gt;mem_cgroup)<br>
+/**<br>
+ * global_reclaim - whether reclaim is global or due to memcg hard limit<b=
r>
+ * @sc: scan control of this reclaim invocation<br>
+ */<br>
+static bool global_reclaim(struct scan_control *sc)<br>
+{<br>
+ =A0 =A0 =A0 return !sc-&gt;target_mem_cgroup;<br>
+}<br>
+/**<br>
+ * scanning_global_lru - whether scanning global lrus or per-memcg lrus<br=
>
+ * @sc: scan control of this reclaim invocation<br>
+ */<br>
+static bool scanning_global_lru(struct scan_control *sc)<br>
+{<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Unless memory cgroups are disabled on boot, the traditio=
nal<br>
+ =A0 =A0 =A0 =A0* global lru lists are never scanned and reclaim will alwa=
ys<br>
+ =A0 =A0 =A0 =A0* operate on the per-memcg lru lists.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 return mem_cgroup_disabled();<br>
+}<br>
=A0#else<br>
-#define scanning_global_lru(sc) =A0 =A0 =A0 =A0(1)<br>
+static bool global_reclaim(struct scan_control *sc)<br>
+{<br>
+ =A0 =A0 =A0 return true;<br>
+}<br>
+static bool scanning_global_lru(struct scan_control *sc)<br>
+{<br>
+ =A0 =A0 =A0 return true;<br>
+}<br>
=A0#endif<br>
<br>
=A0static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,<br>
@@ -1228,7 +1264,7 @@ static int too_many_isolated(struct zone *zone, int f=
ile,<br>
 =A0 =A0 =A0 =A0if (current_is_kswapd())<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;<br>
<br>
- =A0 =A0 =A0 if (!scanning_global_lru(sc))<br>
+ =A0 =A0 =A0 if (!global_reclaim(sc))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;<br>
<br>
 =A0 =A0 =A0 =A0if (file) {<br>
@@ -1397,13 +1433,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struc=
t zone *zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc-&gt;reclaim_mode &amp; R=
ECLAIM_MODE_LUMPYRECLAIM ?<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0ISOLATE_BOTH : ISOLATE_INACTIVE,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, 0, file);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone-&gt;pages_scanned +=3D nr_scanned;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSCAN=
_KSWAPD, zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0nr_scanned);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSCAN=
_DIRECT, zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0nr_scanned);<br>
 =A0 =A0 =A0 =A0} else {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken =3D mem_cgroup_isolate_pages(nr_to=
_scan,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&amp;page_list, &amp;nr_sca=
nned, sc-&gt;order,<br>
@@ -1411,10 +1440,16 @@ shrink_inactive_list(unsigned long nr_to_scan, stru=
ct zone *zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0ISOLATE_BOTH : ISOLATE_INACTIVE,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, sc-&gt;mem_cgroup,<br=
>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00, file);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track o=
f<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 if (global_reclaim(sc)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone-&gt;pages_scanned +=3D nr_scanned;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSCAN=
_KSWAPD, zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0nr_scanned);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSCAN=
_DIRECT, zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0nr_scanned);<br>
 =A0 =A0 =A0 =A0}<br>
<br>
 =A0 =A0 =A0 =A0if (nr_taken =3D=3D 0) {<br>
@@ -1520,18 +1555,16 @@ static void shrink_active_list(unsigned long nr_pag=
es, struct zone *zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0&amp;pgscanned, sc-&gt;order,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0ISOLATE_ACTIVE, zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A01, file);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone-&gt;pages_scanned +=3D pgscanned;<br>
 =A0 =A0 =A0 =A0} else {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken =3D mem_cgroup_isolate_pages(nr_pa=
ges, &amp;l_hold,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0&amp;pgscanned, sc-&gt;order,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0ISOLATE_ACTIVE, zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0sc-&gt;mem_cgroup, 1, file);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track o=
f<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
 =A0 =A0 =A0 =A0}<br>
<br>
+ =A0 =A0 =A0 if (global_reclaim(sc))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone-&gt;pages_scanned +=3D pgscanned;<br>
+<br>
 =A0 =A0 =A0 =A0reclaim_stat-&gt;recent_scanned[file] +=3D nr_taken;<br>
<br>
 =A0 =A0 =A0 =A0__count_zone_vm_events(PGREFILL, zone, pgscanned);<br>
@@ -1752,7 +1785,7 @@ static void get_scan_count(struct zone *zone, struct =
scan_control *sc,<br>
 =A0 =A0 =A0 =A0file =A0=3D zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +<=
br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FI=
LE);<br>
<br>
- =A0 =A0 =A0 if (scanning_global_lru(sc)) {<br>
+ =A0 =A0 =A0 if (global_reclaim(sc)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free =A0=3D zone_page_state(zone, NR_FREE_P=
AGES);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* If we have very few page cache pages,<br=
>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 force-scan anon pages. */<br>
@@ -1889,8 +1922,8 @@ static inline bool should_continue_reclaim(struct zon=
e *zone,<br>
=A0/*<br>
 =A0* This is a basic per-zone page freer. =A0Used by both kswapd and direc=
t reclaim.<br>
 =A0*/<br>
-static void shrink_zone(int priority, struct zone *zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_c=
ontrol *sc)<br>
+static void do_shrink_zone(int priority, struct zone *zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct scan_control *s=
c)<br>
=A0{<br>
 =A0 =A0 =A0 =A0unsigned long nr[NR_LRU_LISTS];<br>
 =A0 =A0 =A0 =A0unsigned long nr_to_scan;<br>
@@ -1943,6 +1976,31 @@ restart:<br>
 =A0 =A0 =A0 =A0throttle_vm_writeout(sc-&gt;gfp_mask);<br>
=A0}<br>
<br>
+static void shrink_zone(int priority, struct zone *zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)<br>
+{<br>
+ =A0 =A0 =A0 unsigned long nr_reclaimed_before =3D sc-&gt;nr_reclaimed;<br=
>
+ =A0 =A0 =A0 struct mem_cgroup *root =3D sc-&gt;target_mem_cgroup;<br>
+ =A0 =A0 =A0 struct mem_cgroup *first, *mem =3D NULL;<br>
+<br>
+ =A0 =A0 =A0 first =3D mem =3D mem_cgroup_hierarchy_walk(root, mem);<br>
+ =A0 =A0 =A0 for (;;) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;mem_cgroup =3D mem;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_shrink_zone(priority, zone, sc);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed =3D sc-&gt;nr_reclaimed - nr_rec=
laimed_before;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimed &gt;=3D sc-&gt;nr_to_reclaim=
)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_hierarchy_walk(root, mem);=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem =3D=3D first)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 mem_cgroup_stop_hierarchy_walk(root, mem);<br>
+}<br>
+<br>
=A0/*<br>
 =A0* This is the direct reclaim path, for page-allocating processes. =A0We=
 only<br>
 =A0* try to reclaim pages from zones which will satisfy the caller&#39;s a=
llocation<br>
@@ -1973,7 +2031,7 @@ static void shrink_zones(int priority, struct zonelis=
t *zonelist,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Take care memory controller reclaiming h=
as small influence<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * to global LRU.<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scanning_global_lru(sc)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (global_reclaim(sc)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!cpuset_zone_allowed_ha=
rdwall(zone, GFP_KERNEL))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (zone-&gt;all_unreclaima=
ble &amp;&amp; priority !=3D DEF_PRIORITY)<br>
@@ -2038,7 +2096,7 @@ static unsigned long do_try_to_free_pages(struct zone=
list *zonelist,<br>
 =A0 =A0 =A0 =A0get_mems_allowed();<br>
 =A0 =A0 =A0 =A0delayacct_freepages_start();<br>
<br>
- =A0 =A0 =A0 if (scanning_global_lru(sc))<br>
+ =A0 =A0 =A0 if (global_reclaim(sc))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count_vm_event(ALLOCSTALL);<br>
<br>
 =A0 =A0 =A0 =A0for (priority =3D DEF_PRIORITY; priority &gt;=3D 0; priorit=
y--) {<br>
@@ -2050,7 +2108,7 @@ static unsigned long do_try_to_free_pages(struct zone=
list *zonelist,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Don&#39;t shrink slabs when reclaiming m=
emory from<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * over limit cgroups<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scanning_global_lru(sc)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (global_reclaim(sc)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long lru_pages =3D=
 0;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_zone_zonelist(zone=
, z, zonelist,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_zone(sc-&gt;gfp_mask)) {<br>
@@ -2111,7 +2169,7 @@ out:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;<br>
<br>
 =A0 =A0 =A0 =A0/* top priority shrink_zones still had more to do? don&#39;=
t OOM, then */<br>
- =A0 =A0 =A0 if (scanning_global_lru(sc) &amp;&amp; !all_unreclaimable(zon=
elist, sc))<br>
+ =A0 =A0 =A0 if (global_reclaim(sc) &amp;&amp; !all_unreclaimable(zonelist=
, sc))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;<br>
<br>
 =A0 =A0 =A0 =A0return 0;<br>
@@ -2129,7 +2187,7 @@ unsigned long try_to_free_pages(struct zonelist *zone=
list, int order,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_swap =3D 1,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.swappiness =3D vm_swappiness,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D NULL,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .target_mem_cgroup =3D NULL,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nodemask =3D nodemask,<br>
 =A0 =A0 =A0 =A0};<br>
<br>
@@ -2158,6 +2216,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_=
cgroup *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_swap =3D !noswap,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.swappiness =3D swappiness,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .target_mem_cgroup =3D mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,<br>
 =A0 =A0 =A0 =A0};<br>
 =A0 =A0 =A0 =A0sc.gfp_mask =3D (gfp_mask &amp; GFP_RECLAIM_MASK) |<br>
@@ -2174,7 +2233,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_=
cgroup *mem,<br>
 =A0 =A0 =A0 =A0 * will pick up pages from other mem cgroup&#39;s as well. =
We hack<br>
 =A0 =A0 =A0 =A0 * the priority and make it zero.<br>
 =A0 =A0 =A0 =A0 */<br>
- =A0 =A0 =A0 shrink_zone(0, zone, &amp;sc);<br>
+ =A0 =A0 =A0 do_shrink_zone(0, zone, &amp;sc);<br>
<br>
 =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed=
);<br>
<br>
@@ -2195,7 +2254,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem=
_cgroup *mem_cont,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_to_reclaim =3D SWAP_CLUSTER_MAX,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.swappiness =3D swappiness,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .target_mem_cgroup =3D mem_cont,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nodemask =3D NULL, /* we don&#39;t care th=
e placement */<br>
 =A0 =A0 =A0 =A0};<br>
<br>
@@ -2333,7 +2392,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, =
int order,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_to_reclaim =3D ULONG_MAX,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.swappiness =3D vm_swappiness,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D NULL,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .target_mem_cgroup =3D NULL,<br>
 =A0 =A0 =A0 =A0};<br>
=A0loop_again:<br>
 =A0 =A0 =A0 =A0total_scanned =3D 0;<br></blockquote><div><br></div><div>Pl=
ease consider including the following patch for the next post. It causes cr=
ash on some of the tests where sc-&gt;mem_cgroup is NULL (global kswapd).</=
div><div>
<br></div><div><div>diff --git a/mm/vmscan.c b/mm/vmscan.c</div><div>index =
b72a844..12ab25d 100644</div><div>--- a/mm/vmscan.c</div><div>+++ b/mm/vmsc=
an.c</div><div>@@ -2768,7 +2768,8 @@ loop_again:</div><div>=A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do some background aging of the anon l=
ist, to give</div>
<div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages a chance to=
 be referenced before reclaiming.</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0*/</div><div>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 if (inactive_anon_is_low(zone, &amp;sc))</div><div>+ =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scanning_global_lru(&amp;sc) &amp;&amp;</di=
v>
<div>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 inactive_anon_is_low(zone, &amp;sc))</div><div>=A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_active_list(SWAP_CLUSTER=
_MAX, zone,</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;sc, priori=
ty, 0);</div>
</div><div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<font color=3D"#888888">--<br>
1.7.5.2<br>
<br>
</font></blockquote></div><br>

--0016368321161db04904aa40cc96--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
