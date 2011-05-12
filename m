Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C314590010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:19:54 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4CJJnbU017717
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:19:50 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by wpaz37.hot.corp.google.com with ESMTP id p4CJJhlX019405
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:19:48 -0700
Received: by qyk2 with SMTP id 2so1117868qyk.9
        for <linux-mm@kvack.org>; Thu, 12 May 2011 12:19:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
Date: Thu, 12 May 2011 12:19:45 -0700
Message-ID: <BANLkTimr1sCLTa2JuMUYUFQWGS2D8c9GEA@mail.gmail.com>
Subject: Re: [rfc patch 3/6] mm: memcg-aware global reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa86ecd7904a319120c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--002354470aa86ecd7904a319120c
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> A page charged to a memcg is linked to a lru list specific to that
> memcg.  At the same time, traditional global reclaim is obvlivious to
> memcgs, and all the pages are also linked to a global per-zone list.
>
> This patch changes traditional global reclaim to iterate over all
> existing memcgs, so that it no longer relies on the global list being
> present.
>

This is one step forward in integrating memcg code better into the
> rest of memory management.  It is also a prerequisite to get rid of
> the global per-zone lru lists.
>
> Sorry If i misunderstood something here. I assume this patch has not much
to do with the
global soft_limit reclaim, but only allow the system only scan per-memcg lru
under global
memory pressure.


> RFC:
>
> The algorithm implemented in this patch is very naive.  For each zone
> scanned at each priority level, it iterates over all existing memcgs
> and considers them for scanning.
>
> This is just a prototype and I did not optimize it yet because I am
> unsure about the maximum number of memcgs that still constitute a sane
> configuration in comparison to the machine size.
>

So we also scan memcg which has no page allocated on this zone? I will read
the following
patch in case i missed something here :)

--Ying

>
> It is perfectly fair since all memcgs are scanned at each priority
> level.
>
> On my 4G quadcore laptop with 1000 memcgs, a significant amount of CPU
> time was spent just iterating memcgs during reclaim.  But it can not
> really be claimed that the old code was much better, either: global
> LRU reclaim could mean that a few hundred memcgs would have been
> emptied out completely, while others stayed untouched.
>
> I am open to solutions that trade fairness against CPU-time but don't
> want to have an extreme in either direction.  Maybe break out early if
> a number of memcgs has been successfully reclaimed from and remember
> the last one scanned.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |    7 ++
>  mm/memcontrol.c            |  148
> +++++++++++++++++++++++++++++---------------
>  mm/vmscan.c                |   21 +++++--
>  3 files changed, 120 insertions(+), 56 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5e9840f5..58728c7 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -104,6 +104,7 @@ extern void mem_cgroup_end_migration(struct mem_cgroup
> *mem,
>  /*
>  * For memory reclaim.
>  */
> +void mem_cgroup_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup **);
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>  int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
>  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> @@ -289,6 +290,12 @@ static inline bool mem_cgroup_disabled(void)
>        return true;
>  }
>
> +static inline void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,
> +                                            struct mem_cgroup **iter)
> +{
> +       *iter = start;
> +}
> +
>  static inline int
>  mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bf5ab87..edcd55a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -313,7 +313,7 @@ static bool move_file(void)
>  }
>
>  /*
> - * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
> + * Maximum loops in mem_cgroup_soft_reclaim(), used for soft
>  * limit reclaim to prevent infinite loops, if they ever occur.
>  */
>  #define        MEM_CGROUP_MAX_RECLAIM_LOOPS            (100)
> @@ -339,16 +339,6 @@ enum charge_type {
>  /* Used for OOM nofiier */
>  #define OOM_CONTROL            (0)
>
> -/*
> - * Reclaim flags for mem_cgroup_hierarchical_reclaim
> - */
> -#define MEM_CGROUP_RECLAIM_NOSWAP_BIT  0x0
> -#define MEM_CGROUP_RECLAIM_NOSWAP      (1 <<
> MEM_CGROUP_RECLAIM_NOSWAP_BIT)
> -#define MEM_CGROUP_RECLAIM_SHRINK_BIT  0x1
> -#define MEM_CGROUP_RECLAIM_SHRINK      (1 <<
> MEM_CGROUP_RECLAIM_SHRINK_BIT)
> -#define MEM_CGROUP_RECLAIM_SOFT_BIT    0x2
> -#define MEM_CGROUP_RECLAIM_SOFT                (1 <<
> MEM_CGROUP_RECLAIM_SOFT_BIT)
> -
>  static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
>  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> @@ -1381,6 +1371,86 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
>        return min(limit, memsw);
>  }
>
> +void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,
> +                              struct mem_cgroup **iter)
> +{
> +       struct mem_cgroup *mem = *iter;
> +       int id;
> +
> +       if (!start)
> +               start = root_mem_cgroup;
> +       /*
> +        * Even without hierarchy explicitely enabled in the root
> +        * memcg, it is the ultimate parent of all memcgs.
> +        */
> +       if (!(start == root_mem_cgroup || start->use_hierarchy)) {
> +               *iter = start;
> +               return;
> +       }
> +
> +       if (!mem)
> +               id = css_id(&start->css);
> +       else {
> +               id = css_id(&mem->css);
> +               css_put(&mem->css);
> +               mem = NULL;
> +       }
> +
> +       do {
> +               struct cgroup_subsys_state *css;
> +
> +               rcu_read_lock();
> +               css = css_get_next(&mem_cgroup_subsys, id+1, &start->css,
> &id);
> +               /*
> +                * The caller must already have a reference to the
> +                * starting point of this hierarchy walk, do not grab
> +                * another one.  This way, the loop can be finished
> +                * when the hierarchy root is returned, without any
> +                * further cleanup required.
> +                */
> +               if (css && (css == &start->css || css_tryget(css)))
> +                       mem = container_of(css, struct mem_cgroup, css);
> +               rcu_read_unlock();
> +               if (!css)
> +                       id = 0;
> +       } while (!mem);
> +
> +       if (mem == root_mem_cgroup)
> +               mem = NULL;
> +
> +       *iter = mem;
> +}
> +
> +static unsigned long mem_cgroup_target_reclaim(struct mem_cgroup *mem,
> +                                              gfp_t gfp_mask,
> +                                              bool noswap,
> +                                              bool shrink)
> +{
> +       unsigned long total = 0;
> +       int loop;
> +
> +       if (mem->memsw_is_minimum)
> +               noswap = true;
> +
> +       for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
> +               drain_all_stock_async();
> +               total += try_to_free_mem_cgroup_pages(mem, gfp_mask,
> noswap,
> +                                                     get_swappiness(mem));
> +               if (total && shrink)
> +                       break;
> +               if (mem_cgroup_margin(mem))
> +                       break;
> +               /*
> +                * If we have not been able to reclaim anything after
> +                * two reclaim attempts, there may be no reclaimable
> +                * pages under this hierarchy.
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
> @@ -1427,21 +1497,16 @@ mem_cgroup_select_victim(struct mem_cgroup
> *root_mem)
>  *
>  * We give up and return to the caller when we visit root_mem twice.
>  * (other groups can be removed while we're walking....)
> - *
> - * If shrink==true, for avoiding to free too much, this returns
> immedieately.
>  */
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
>        unsigned long excess;
> +       bool noswap = false;
>
>        excess = res_counter_soft_limit_excess(&root_mem->res) >>
> PAGE_SHIFT;
>
> @@ -1461,7 +1526,7 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
>                                 * anything, it might because there are
>                                 * no reclaimable pages under this hierarchy
>                                 */
> -                               if (!check_soft || !total) {
> +                               if (!total) {
>                                        css_put(&victim->css);
>                                        break;
>                                }
> @@ -1484,25 +1549,11 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
>                        continue;
>                }
>                /* we use swappiness of local cgroup */
> -               if (check_soft)
> -                       ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> +               ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
>                                noswap, get_swappiness(victim), zone);
> -               else
> -                       ret = try_to_free_mem_cgroup_pages(victim,
> gfp_mask,
> -                                               noswap,
> get_swappiness(victim));
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
> @@ -1897,7 +1948,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup
> *mem, gfp_t gfp_mask,
>        unsigned long csize = nr_pages * PAGE_SIZE;
>        struct mem_cgroup *mem_over_limit;
>        struct res_counter *fail_res;
> -       unsigned long flags = 0;
> +       bool noswap = false;
>        int ret;
>
>        ret = res_counter_charge(&mem->res, csize, &fail_res);
> @@ -1911,7 +1962,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup
> *mem, gfp_t gfp_mask,
>
>                res_counter_uncharge(&mem->res, csize);
>                mem_over_limit = mem_cgroup_from_res_counter(fail_res,
> memsw);
> -               flags |= MEM_CGROUP_RECLAIM_NOSWAP;
> +               noswap = true;
>        } else
>                mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
>        /*
> @@ -1927,8 +1978,8 @@ static int mem_cgroup_do_charge(struct mem_cgroup
> *mem, gfp_t gfp_mask,
>        if (!(gfp_mask & __GFP_WAIT))
>                return CHARGE_WOULDBLOCK;
>
> -       ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> -                                             gfp_mask, flags);
> +       ret = mem_cgroup_target_reclaim(mem_over_limit, gfp_mask,
> +                                       noswap, false);
>        if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>                return CHARGE_RETRY;
>        /*
> @@ -3085,7 +3136,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>
>  /*
>  * A call to try to shrink memory usage on charge failure at shmem's
> swapin.
> - * Calling hierarchical_reclaim is not enough because we should update
> + * Calling target_reclaim is not enough because we should update
>  * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global
> OOM.
>  * Moreover considering hierarchy, we should reclaim from the
> mem_over_limit,
>  * not from the memcg which this page would be charged to.
> @@ -3167,7 +3218,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup
> *memcg,
>        int enlarge;
>
>        /*
> -        * For keeping hierarchical_reclaim simple, how long we should
> retry
> +        * For keeping target_reclaim simple, how long we should retry
>         * is depends on callers. We set our retry-count to be function
>         * of # of children which we should visit in this loop.
>         */
> @@ -3210,8 +3261,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup
> *memcg,
>                if (!ret)
>                        break;
>
> -               mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> -                                               MEM_CGROUP_RECLAIM_SHRINK);
> +               mem_cgroup_target_reclaim(memcg, GFP_KERNEL, false, false);
>                curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
>                /* Usage is reduced ? */
>                if (curusage >= oldusage)
> @@ -3269,9 +3319,7 @@ static int mem_cgroup_resize_memsw_limit(struct
> mem_cgroup *memcg,
>                if (!ret)
>                        break;
>
> -               mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> -                                               MEM_CGROUP_RECLAIM_NOSWAP |
> -                                               MEM_CGROUP_RECLAIM_SHRINK);
> +               mem_cgroup_target_reclaim(memcg, GFP_KERNEL, true, false);
>                curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>                /* Usage is reduced ? */
>                if (curusage >= oldusage)
> @@ -3311,9 +3359,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct
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
> index ceeb2a5..e2a3647 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1900,8 +1900,8 @@ static inline bool should_continue_reclaim(struct
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
> @@ -1914,8 +1914,6 @@ restart:
>        nr_scanned = sc->nr_scanned;
>        get_scan_count(zone, sc, nr, priority);
>
> -       sc->current_memcg = sc->memcg;
> -
>        while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>                                        nr[LRU_INACTIVE_FILE]) {
>                for_each_evictable_lru(l) {
> @@ -1954,6 +1952,19 @@ restart:
>                goto restart;
>
>        throttle_vm_writeout(sc->gfp_mask);
> +}
> +
> +static void shrink_zone(int priority, struct zone *zone,
> +                       struct scan_control *sc)
> +{
> +       struct mem_cgroup *root = sc->memcg;
> +       struct mem_cgroup *mem = NULL;
> +
> +       do {
> +               mem_cgroup_hierarchy_walk(root, &mem);
> +               sc->current_memcg = mem;
> +               do_shrink_zone(priority, zone, sc);
> +       } while (mem != root);
>
>        /* For good measure, noone higher up the stack should look at it */
>        sc->current_memcg = NULL;
> @@ -2190,7 +2201,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct
> mem_cgroup *mem,
>         * will pick up pages from other mem cgroup's as well. We hack
>         * the priority and make it zero.
>         */
> -       shrink_zone(0, zone, &sc);
> +       do_shrink_zone(0, zone, &sc);
>
>        trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>
> --
> 1.7.5.1
>
>

--002354470aa86ecd7904a319120c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 12, 2011 at 7:53 AM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
A page charged to a memcg is linked to a lru list specific to that<br>
memcg. =A0At the same time, traditional global reclaim is obvlivious to<br>
memcgs, and all the pages are also linked to a global per-zone list.<br>
<br>
This patch changes traditional global reclaim to iterate over all<br>
existing memcgs, so that it no longer relies on the global list being<br>
present.<br></blockquote><div><br></div><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">Thi=
s is one step forward in integrating memcg code better into the<br>
rest of memory management. =A0It is also a prerequisite to get rid of<br>
the global per-zone lru lists.<br>
<br></blockquote><meta http-equiv=3D"content-type" content=3D"text/html; ch=
arset=3Dutf-8"><div>Sorry If i misunderstood something here. I assume this =
patch has not much to do with the</div><div>global soft_limit reclaim, but =
only allow the system only scan per-memcg lru under global</div>
<div>memory pressure.=A0</div><div>=A0</div><blockquote class=3D"gmail_quot=
e" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;"=
>
RFC:<br>
<br>
The algorithm implemented in this patch is very naive. =A0For each zone<br>
scanned at each priority level, it iterates over all existing memcgs<br>
and considers them for scanning.<br>
<br>
This is just a prototype and I did not optimize it yet because I am<br>
unsure about the maximum number of memcgs that still constitute a sane<br>
configuration in comparison to the machine size.<br></blockquote><div><br><=
/div><div>So we also scan memcg which has no page allocated on this zone? I=
 will read the following</div><div>patch in case i missed something here :)=
</div>
<div><br></div><div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
It is perfectly fair since all memcgs are scanned at each priority<br>
level.<br>
<br>
On my 4G quadcore laptop with 1000 memcgs, a significant amount of CPU<br>
time was spent just iterating memcgs during reclaim. =A0But it can not<br>
really be claimed that the old code was much better, either: global<br>
LRU reclaim could mean that a few hundred memcgs would have been<br>
emptied out completely, while others stayed untouched.<br>
<br>
I am open to solutions that trade fairness against CPU-time but don&#39;t<b=
r>
want to have an extreme in either direction. =A0Maybe break out early if<br=
>
a number of memcgs has been successfully reclaimed from and remember<br>
the last one scanned.<br>
<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">ha=
nnes@cmpxchg.org</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 =A07 ++<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0148 ++++++++++++++++++++++++=
+++++---------------<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 21 +++++--<br>
=A03 files changed, 120 insertions(+), 56 deletions(-)<br>
<br>
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<br>
index 5e9840f5..58728c7 100644<br>
--- a/include/linux/memcontrol.h<br>
+++ b/include/linux/memcontrol.h<br>
@@ -104,6 +104,7 @@ extern void mem_cgroup_end_migration(struct mem_cgroup =
*mem,<br>
=A0/*<br>
 =A0* For memory reclaim.<br>
 =A0*/<br>
+void mem_cgroup_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup **);=
<br>
=A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);<br>
=A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);<br>
=A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,<br>
@@ -289,6 +290,12 @@ static inline bool mem_cgroup_disabled(void)<br>
 =A0 =A0 =A0 =A0return true;<br>
=A0}<br>
<br>
+static inline void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0struct mem_cgroup **iter)<br>
+{<br>
+ =A0 =A0 =A0 *iter =3D start;<br>
+}<br>
+<br>
=A0static inline int<br>
=A0mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)<br>
=A0{<br>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
index bf5ab87..edcd55a 100644<br>
--- a/mm/memcontrol.c<br>
+++ b/mm/memcontrol.c<br>
@@ -313,7 +313,7 @@ static bool move_file(void)<br>
=A0}<br>
<br>
=A0/*<br>
- * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft<br>
+ * Maximum loops in mem_cgroup_soft_reclaim(), used for soft<br>
 =A0* limit reclaim to prevent infinite loops, if they ever occur.<br>
 =A0*/<br>
=A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_RECLAIM_LOOPS =A0 =A0 =A0 =A0 =A0 =
=A0(100)<br>
@@ -339,16 +339,6 @@ enum charge_type {<br>
=A0/* Used for OOM nofiier */<br>
=A0#define OOM_CONTROL =A0 =A0 =A0 =A0 =A0 =A0(0)<br>
<br>
-/*<br>
- * Reclaim flags for mem_cgroup_hierarchical_reclaim<br>
- */<br>
-#define MEM_CGROUP_RECLAIM_NOSWAP_BIT =A00x0<br>
-#define MEM_CGROUP_RECLAIM_NOSWAP =A0 =A0 =A0(1 &lt;&lt; MEM_CGROUP_RECLAI=
M_NOSWAP_BIT)<br>
-#define MEM_CGROUP_RECLAIM_SHRINK_BIT =A00x1<br>
-#define MEM_CGROUP_RECLAIM_SHRINK =A0 =A0 =A0(1 &lt;&lt; MEM_CGROUP_RECLAI=
M_SHRINK_BIT)<br>
-#define MEM_CGROUP_RECLAIM_SOFT_BIT =A0 =A00x2<br>
-#define MEM_CGROUP_RECLAIM_SOFT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 &lt;&lt;=
 MEM_CGROUP_RECLAIM_SOFT_BIT)<br>
-<br>
=A0static void mem_cgroup_get(struct mem_cgroup *mem);<br>
=A0static void mem_cgroup_put(struct mem_cgroup *mem);<br>
=A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);<br>
@@ -1381,6 +1371,86 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)<b=
r>
 =A0 =A0 =A0 =A0return min(limit, memsw);<br>
=A0}<br>
<br>
+void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgr=
oup **iter)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D *iter;<br>
+ =A0 =A0 =A0 int id;<br>
+<br>
+ =A0 =A0 =A0 if (!start)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D root_mem_cgroup;<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Even without hierarchy explicitely enabled in the root<b=
r>
+ =A0 =A0 =A0 =A0* memcg, it is the ultimate parent of all memcgs.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 if (!(start =3D=3D root_mem_cgroup || start-&gt;use_hierarchy=
)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 *iter =3D start;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 if (!mem)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D css_id(&amp;start-&gt;css);<br>
+ =A0 =A0 =A0 else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D css_id(&amp;mem-&gt;css);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&amp;mem-&gt;css);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D NULL;<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys_state *css;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 css =3D css_get_next(&amp;mem_cgroup_subsys, =
id+1, &amp;start-&gt;css, &amp;id);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The caller must already have a reference=
 to the<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* starting point of this hierarchy walk, d=
o not grab<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* another one. =A0This way, the loop can b=
e finished<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* when the hierarchy root is returned, wit=
hout any<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* further cleanup required.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (css &amp;&amp; (css =3D=3D &amp;start-&gt=
;css || css_tryget(css)))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D container_of(css, str=
uct mem_cgroup, css);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!css)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D 0;<br>
+ =A0 =A0 =A0 } while (!mem);<br>
+<br>
+ =A0 =A0 =A0 if (mem =3D=3D root_mem_cgroup)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D NULL;<br>
+<br>
+ =A0 =A0 =A0 *iter =3D mem;<br>
+}<br>
+<br>
+static unsigned long mem_cgroup_target_reclaim(struct mem_cgroup *mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0gfp_t gfp_mask,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0bool noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0bool shrink)<br>
+{<br>
+ =A0 =A0 =A0 unsigned long total =3D 0;<br>
+ =A0 =A0 =A0 int loop;<br>
+<br>
+ =A0 =A0 =A0 if (mem-&gt;memsw_is_minimum)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap =3D true;<br>
+<br>
+ =A0 =A0 =A0 for (loop =3D 0; loop &lt; MEM_CGROUP_MAX_RECLAIM_LOOPS; loop=
++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_stock_async();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D try_to_free_mem_cgroup_pages(mem, =
gfp_mask, noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_swappiness(mem));<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total &amp;&amp; shrink)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_margin(mem))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we have not been able to reclaim anyt=
hing after<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* two reclaim attempts, there may be no re=
claimable<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages under this hierarchy.<br>
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
@@ -1427,21 +1497,16 @@ mem_cgroup_select_victim(struct mem_cgroup *root_me=
m)<br>
 =A0*<br>
 =A0* We give up and return to the caller when we visit root_mem twice.<br>
 =A0* (other groups can be removed while we&#39;re walking....)<br>
- *<br>
- * If shrink=3D=3Dtrue, for avoiding to free too much, this returns immedi=
eately.<br>
 =A0*/<br>
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
 =A0 =A0 =A0 =A0unsigned long excess;<br>
+ =A0 =A0 =A0 bool noswap =3D false;<br>
<br>
 =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&amp;root_mem-&gt;=
res) &gt;&gt; PAGE_SHIFT;<br>
<br>
@@ -1461,7 +1526,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem=
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
@@ -1484,25 +1549,11 @@ static int mem_cgroup_hierarchical_reclaim(struct m=
em_cgroup *root_mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (check_soft)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_shrink_nod=
e_zone(victim, gfp_mask,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_shrink_node_zone(victim, g=
fp_mask,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap, get=
_swappiness(victim), zone);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D try_to_free_mem_cgrou=
p_pages(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 noswap, get_swappiness(victim));<br>
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
@@ -1897,7 +1948,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *me=
m, gfp_t gfp_mask,<br>
 =A0 =A0 =A0 =A0unsigned long csize =3D nr_pages * PAGE_SIZE;<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem_over_limit;<br>
 =A0 =A0 =A0 =A0struct res_counter *fail_res;<br>
- =A0 =A0 =A0 unsigned long flags =3D 0;<br>
+ =A0 =A0 =A0 bool noswap =3D false;<br>
 =A0 =A0 =A0 =A0int ret;<br>
<br>
 =A0 =A0 =A0 =A0ret =3D res_counter_charge(&amp;mem-&gt;res, csize, &amp;fa=
il_res);<br>
@@ -1911,7 +1962,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *me=
m, gfp_t gfp_mask,<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_uncharge(&amp;mem-&gt;res, csiz=
e);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_over_limit =3D mem_cgroup_from_res_coun=
ter(fail_res, memsw);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags |=3D MEM_CGROUP_RECLAIM_NOSWAP;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap =3D true;<br>
 =A0 =A0 =A0 =A0} else<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_over_limit =3D mem_cgroup_from_res_coun=
ter(fail_res, res);<br>
 =A0 =A0 =A0 =A0/*<br>
@@ -1927,8 +1978,8 @@ static int mem_cgroup_do_charge(struct mem_cgroup *me=
m, gfp_t gfp_mask,<br>
 =A0 =A0 =A0 =A0if (!(gfp_mask &amp; __GFP_WAIT))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return CHARGE_WOULDBLOCK;<br>
<br>
- =A0 =A0 =A0 ret =3D mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 gfp_mask, flags);<br>
+ =A0 =A0 =A0 ret =3D mem_cgroup_target_reclaim(mem_over_limit, gfp_mask,<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 noswap, false);<br>
 =A0 =A0 =A0 =A0if (mem_cgroup_margin(mem_over_limit) &gt;=3D nr_pages)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return CHARGE_RETRY;<br>
 =A0 =A0 =A0 =A0/*<br>
@@ -3085,7 +3136,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,=
<br>
<br>
=A0/*<br>
 =A0* A call to try to shrink memory usage on charge failure at shmem&#39;s=
 swapin.<br>
- * Calling hierarchical_reclaim is not enough because we should update<br>
+ * Calling target_reclaim is not enough because we should update<br>
 =A0* last_oom_jiffies to prevent pagefault_out_of_memory from invoking glo=
bal OOM.<br>
 =A0* Moreover considering hierarchy, we should reclaim from the mem_over_l=
imit,<br>
 =A0* not from the memcg which this page would be charged to.<br>
@@ -3167,7 +3218,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup =
*memcg,<br>
 =A0 =A0 =A0 =A0int enlarge;<br>
<br>
 =A0 =A0 =A0 =A0/*<br>
- =A0 =A0 =A0 =A0* For keeping hierarchical_reclaim simple, how long we sho=
uld retry<br>
+ =A0 =A0 =A0 =A0* For keeping target_reclaim simple, how long we should re=
try<br>
 =A0 =A0 =A0 =A0 * is depends on callers. We set our retry-count to be func=
tion<br>
 =A0 =A0 =A0 =A0 * of # of children which we should visit in this loop.<br>
 =A0 =A0 =A0 =A0 */<br>
@@ -3210,8 +3261,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup =
*memcg,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_hierarchical_reclaim(memcg, NULL, =
GFP_KERNEL,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_SHRINK);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_target_reclaim(memcg, GFP_KERNEL, =
false, false);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0curusage =3D res_counter_read_u64(&amp;memc=
g-&gt;res, RES_USAGE);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Usage is reduced ? */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (curusage &gt;=3D oldusage)<br>
@@ -3269,9 +3319,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_c=
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
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_target_reclaim(memcg, GFP_KERNEL, =
true, false);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0curusage =3D res_counter_read_u64(&amp;memc=
g-&gt;memsw, RES_USAGE);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Usage is reduced ? */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (curusage &gt;=3D oldusage)<br>
@@ -3311,9 +3359,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zo=
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
index ceeb2a5..e2a3647 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -1900,8 +1900,8 @@ static inline bool should_continue_reclaim(struct zon=
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
@@ -1914,8 +1914,6 @@ restart:<br>
 =A0 =A0 =A0 =A0nr_scanned =3D sc-&gt;nr_scanned;<br>
 =A0 =A0 =A0 =A0get_scan_count(zone, sc, nr, priority);<br>
<br>
- =A0 =A0 =A0 sc-&gt;current_memcg =3D sc-&gt;memcg;<br>
-<br>
 =A0 =A0 =A0 =A0while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0nr[LRU_INACTIVE_FILE]) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_evictable_lru(l) {<br>
@@ -1954,6 +1952,19 @@ restart:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto restart;<br>
<br>
 =A0 =A0 =A0 =A0throttle_vm_writeout(sc-&gt;gfp_mask);<br>
+}<br>
+<br>
+static void shrink_zone(int priority, struct zone *zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *root =3D sc-&gt;memcg;<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D NULL;<br>
+<br>
+ =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_hierarchy_walk(root, &amp;mem);<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;current_memcg =3D mem;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_shrink_zone(priority, zone, sc);<br>
+ =A0 =A0 =A0 } while (mem !=3D root);<br>
<br>
 =A0 =A0 =A0 =A0/* For good measure, noone higher up the stack should look =
at it */<br>
 =A0 =A0 =A0 =A0sc-&gt;current_memcg =3D NULL;<br>
@@ -2190,7 +2201,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_=
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
<font color=3D"#888888"><br>
--<br>
1.7.5.1<br>
<br>
</font></blockquote></div><br>

--002354470aa86ecd7904a319120c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
