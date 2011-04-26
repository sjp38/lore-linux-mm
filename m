Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C9416900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:35:41 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3Q5ZcHh013418
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 22:35:38 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by hpaq1.eem.corp.google.com with ESMTP id p3Q5ZOmp026674
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 22:35:36 -0700
Received: by qyk2 with SMTP id 2so156988qyk.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 22:35:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425184318.07e717ef.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425184318.07e717ef.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 25 Apr 2011 22:35:31 -0700
Message-ID: <BANLkTin6kD_JKcRkmDGbGrk=N7LNW2bvDw@mail.gmail.com>
Subject: Re: [PATCH 8/7] memcg : reclaim statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c4ec63c04a1cbb108
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

--0016360e3f5c4ec63c04a1cbb108
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 25, 2011 at 2:43 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> At tuning memcg background reclaim, cpu usage per memcg's work is an
> interesting information because some amount of shared resource is used.
> (i.e. background reclaim uses workqueue.) And other information as
> pgscan and pgreclaim is important.
>
> This patch shows them via memory.stat with cpu usage for direct reclaim
> and softlimit reclaim and page scan statistics.
>
>
>  # cat /cgroup/memory/A/memory.stat
>  ....
>  direct_elapsed_ns 0
>  soft_elapsed_ns 0
>  wmark_elapsed_ns 103566424
>  direct_scanned 0
>  soft_scanned 0
>  wmark_scanned 29303
>  direct_freed 0
>  soft_freed 0
>  wmark_freed 29290
>
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |   18 +++++++++
>  include/linux/memcontrol.h       |    6 +++
>  include/linux/swap.h             |    7 +++
>  mm/memcontrol.c                  |   77
> +++++++++++++++++++++++++++++++++++++--
>  mm/vmscan.c                      |   15 +++++++
>  5 files changed, 120 insertions(+), 3 deletions(-)
>
> Index: memcg/mm/memcontrol.c
> ===================================================================
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -274,6 +274,17 @@ struct mem_cgroup {
>        bool                    bgreclaim_resched;
>        struct delayed_work     bgreclaim_work;
>        /*
> +        * reclaim statistics (not per zone, node)
> +        */
> +       spinlock_t              elapsed_lock;
> +       u64                     bgreclaim_elapsed;
> +       u64                     direct_elapsed;
> +       u64                     soft_elapsed;
> +
> +       u64                     reclaim_scan[NR_RECLAIM_CONTEXTS];
> +       u64                     reclaim_freed[NR_RECLAIM_CONTEXTS];
> +
> +       /*
>         * Should we move charges of a task when a task is moved into this
>         * mem_cgroup ? And what type of charges should we move ?
>         */
> @@ -1346,6 +1357,18 @@ void mem_cgroup_clear_unreclaimable(stru
>        return;
>  }
>
> +void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem,
> +               int context, unsigned long scanned,
> +               unsigned long freed)
> +{
> +       if (!mem)
> +               return;
> +       spin_lock(&mem->elapsed_lock);
> +       mem->reclaim_scan[context] += scanned;
> +       mem->reclaim_freed[context] += freed;
> +       spin_unlock(&mem->elapsed_lock);
> +}
> +
>  unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>                                        struct list_head *dst,
>                                        unsigned long *scanned, int order,
> @@ -1692,6 +1715,7 @@ static int mem_cgroup_hierarchical_recla
>        bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
>        unsigned long excess;
>        unsigned long nr_scanned;
> +       s64 start, end;
>
>        excess = res_counter_soft_limit_excess(&root_mem->res) >>
> PAGE_SHIFT;
>
> @@ -1735,16 +1759,27 @@ static int mem_cgroup_hierarchical_recla
>                }
>                /* we use swappiness of local cgroup */
>                if (check_soft) {
> +                       start = sched_clock();
>                        ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
>                                noswap, mem_cgroup_swappiness(victim), zone,
>                                &nr_scanned);
>                        *total_scanned += nr_scanned;
> +                       end = sched_clock();
> +                       spin_lock(&victim->elapsed_lock);
> +                       victim->soft_elapsed += end - start;
> +                       spin_unlock(&victim->elapsed_lock);
>                        mem_cgroup_soft_steal(victim, ret);
>                        mem_cgroup_soft_scan(victim, nr_scanned);
> -               } else
> +               } else {
> +                       start = sched_clock();
>                        ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
>                                                noswap,
>
>  mem_cgroup_swappiness(victim));
> +                       end = sched_clock();
> +                       spin_lock(&victim->elapsed_lock);
> +                       victim->direct_elapsed += end - start;
> +                       spin_unlock(&victim->elapsed_lock);
> +               }
>                css_put(&victim->css);
>                /*
>                 * At shrinking usage, we can't check we should stop here or
> @@ -3702,15 +3737,22 @@ static void memcg_bgreclaim(struct work_
>        struct delayed_work *dw = to_delayed_work(work);
>        struct mem_cgroup *mem =
>                container_of(dw, struct mem_cgroup, bgreclaim_work);
> -       int delay = 0;
> +       int delay;
>        unsigned long long required, usage, hiwat;
>
> +       delay = 0;
>        hiwat = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
>        usage = res_counter_read_u64(&mem->res, RES_USAGE);
>        required = usage - hiwat;
>        if (required >= 0)  {
> +               u64 start, end;
>                required = ((usage - hiwat) >> PAGE_SHIFT) + 1;
> +               start = sched_clock();
>                delay = shrink_mem_cgroup(mem, (long)required);
> +               end = sched_clock();
> +               spin_lock(&mem->elapsed_lock);
> +               mem->bgreclaim_elapsed += end - start;
> +               spin_unlock(&mem->elapsed_lock);
>        }
>        if (!mem->bgreclaim_resched  ||
>                mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {
> @@ -4152,6 +4194,15 @@ enum {
>        MCS_INACTIVE_FILE,
>        MCS_ACTIVE_FILE,
>        MCS_UNEVICTABLE,
> +       MCS_DIRECT_ELAPSED,
> +       MCS_SOFT_ELAPSED,
> +       MCS_WMARK_ELAPSED,
> +       MCS_DIRECT_SCANNED,
> +       MCS_SOFT_SCANNED,
> +       MCS_WMARK_SCANNED,
> +       MCS_DIRECT_FREED,
> +       MCS_SOFT_FREED,
> +       MCS_WMARK_FREED,
>        NR_MCS_STAT,
>  };
>
> @@ -4177,7 +4228,16 @@ struct {
>        {"active_anon", "total_active_anon"},
>        {"inactive_file", "total_inactive_file"},
>        {"active_file", "total_active_file"},
> -       {"unevictable", "total_unevictable"}
> +       {"unevictable", "total_unevictable"},
> +       {"direct_elapsed_ns", "total_direct_elapsed_ns"},
> +       {"soft_elapsed_ns", "total_soft_elapsed_ns"},
> +       {"wmark_elapsed_ns", "total_wmark_elapsed_ns"},
> +       {"direct_scanned", "total_direct_scanned"},
> +       {"soft_scanned", "total_soft_scanned"},
> +       {"wmark_scanned", "total_wmark_scanned"},
> +       {"direct_freed", "total_direct_freed"},
> +       {"soft_freed", "total_soft_freed"},
> +       {"wmark_freed", "total_wamrk_freed"}
>  };
>
>
> @@ -4185,6 +4245,7 @@ static void
>  mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat
> *s)
>  {
>        s64 val;
> +       int i;
>
>        /* per cpu stat */
>        val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
> @@ -4221,6 +4282,15 @@ mem_cgroup_get_local_stat(struct mem_cgr
>        s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
>        val = mem_cgroup_get_local_zonestat(mem, LRU_UNEVICTABLE);
>        s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
> +
> +       /* reclaim stats */
> +       s->stat[MCS_DIRECT_ELAPSED] += mem->direct_elapsed;
> +       s->stat[MCS_SOFT_ELAPSED] += mem->soft_elapsed;
> +       s->stat[MCS_WMARK_ELAPSED] += mem->bgreclaim_elapsed;
> +       for (i = 0; i < NR_RECLAIM_CONTEXTS; i++) {
> +               s->stat[i + MCS_DIRECT_SCANNED] += mem->reclaim_scan[i];
> +               s->stat[i + MCS_DIRECT_FREED] += mem->reclaim_freed[i];
> +       }
>  }
>
>  static void
> @@ -4889,6 +4959,7 @@ static struct mem_cgroup *mem_cgroup_all
>                goto out_free;
>        spin_lock_init(&mem->pcp_counter_lock);
>        INIT_DELAYED_WORK(&mem->bgreclaim_work, memcg_bgreclaim);
> +       spin_lock_init(&mem->elapsed_lock);
>        mem->bgreclaim_resched = true;
>        return mem;
>
> Index: memcg/include/linux/memcontrol.h
> ===================================================================
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -90,6 +90,8 @@ extern int mem_cgroup_select_victim_node
>                                        const nodemask_t *nodes);
>
>  int shrink_mem_cgroup(struct mem_cgroup *mem, long required);
> +void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem, int context,
> +                       unsigned long scanned, unsigned long freed);
>
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> @@ -423,6 +425,10 @@ static inline
>  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item
> idx)
>  {
>  }
> +void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem, int context,
> +                               unsigned long scanned, unsigned long freed)
> +{
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>
>  #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
> Index: memcg/include/linux/swap.h
> ===================================================================
> --- memcg.orig/include/linux/swap.h
> +++ memcg/include/linux/swap.h
> @@ -250,6 +250,13 @@ static inline void lru_cache_add_file(st
>  #define ISOLATE_ACTIVE 1       /* Isolate active pages. */
>  #define ISOLATE_BOTH 2         /* Isolate both active and inactive pages.
> */
>
> +/* context for memory reclaim.( comes from memory cgroup.) */
> +enum {
> +       RECLAIM_DIRECT,         /* under direct reclaim */
> +       RECLAIM_KSWAPD,         /* under global kswapd's soft limit */
> +       RECLAIM_WMARK,          /* under background reclaim by watermark */
> +       NR_RECLAIM_CONTEXTS
> +};
>  /* linux/mm/vmscan.c */
>  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int
> order,
>                                        gfp_t gfp_mask, nodemask_t *mask);
> Index: memcg/mm/vmscan.c
> ===================================================================
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -72,6 +72,9 @@ typedef unsigned __bitwise__ reclaim_mod
>  #define RECLAIM_MODE_LUMPYRECLAIM      ((__force reclaim_mode_t)0x08u)
>  #define RECLAIM_MODE_COMPACTION                ((__force
> reclaim_mode_t)0x10u)
>
> +/* 3 reclaim contexts fro memcg statistics. */
> +enum {DIRECT_RECLAIM, KSWAPD_RECLAIM, WMARK_RECLAIM};
> +
>  struct scan_control {
>        /* Incremented by the number of inactive pages that were scanned */
>        unsigned long nr_scanned;
> @@ -107,6 +110,7 @@ struct scan_control {
>
>        /* Which cgroup do we reclaim from */
>        struct mem_cgroup *mem_cgroup;
> +       int     reclaim_context;
>
>        /*
>         * Nodemask of nodes allowed by the caller. If NULL, all nodes
> @@ -2116,6 +2120,10 @@ out:
>        delayacct_freepages_end();
>        put_mems_allowed();
>
> +       if (!scanning_global_lru(sc))
> +               mem_cgroup_reclaim_statistics(sc->mem_cgroup,
> +                       sc->reclaim_context, total_scanned,
> sc->nr_reclaimed);
> +
>        if (sc->nr_reclaimed)
>                return sc->nr_reclaimed;
>
> @@ -2178,6 +2186,7 @@ unsigned long mem_cgroup_shrink_node_zon
>                .swappiness = swappiness,
>                .order = 0,
>                .mem_cgroup = mem,
> +               .reclaim_context = RECLAIM_KSWAPD,
>        };
>
>        sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> @@ -2198,6 +2207,8 @@ unsigned long mem_cgroup_shrink_node_zon
>
>        trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>
> +       mem_cgroup_reclaim_statistics(sc.mem_cgroup,
> +                       sc.reclaim_context, sc.nr_scanned,
> sc.nr_reclaimed);
>        *nr_scanned = sc.nr_scanned;
>        return sc.nr_reclaimed;
>  }
> @@ -2217,6 +2228,7 @@ unsigned long try_to_free_mem_cgroup_pag
>                .swappiness = swappiness,
>                .order = 0,
>                .mem_cgroup = mem_cont,
> +               .reclaim_context = RECLAIM_DIRECT,
>                .nodemask = NULL, /* we don't care the placement */
>        };
>
> @@ -2384,6 +2396,7 @@ int shrink_mem_cgroup(struct mem_cgroup
>                .may_swap = 1,
>                .order = 0,
>                .mem_cgroup = mem,
> +               .reclaim_context = RECLAIM_WMARK,
>        };
>        /* writepage will be set later per zone */
>        sc.may_writepage = 0;
> @@ -2434,6 +2447,8 @@ int shrink_mem_cgroup(struct mem_cgroup
>        if (sc.nr_reclaimed > sc.nr_to_reclaim/2)
>                delay = 0;
>  out:
> +       mem_cgroup_reclaim_statistics(sc.mem_cgroup, sc.reclaim_context,
> +                       total_scanned, sc.nr_reclaimed);
>        current->flags &= ~PF_SWAPWRITE;
>        return delay;
>  }
> Index: memcg/Documentation/cgroups/memory.txt
> ===================================================================
> --- memcg.orig/Documentation/cgroups/memory.txt
> +++ memcg/Documentation/cgroups/memory.txt
> @@ -398,6 +398,15 @@ active_anon        - # of bytes of anonymous an
>  inactive_file  - # of bytes of file-backed memory on inactive LRU list.
>  active_file    - # of bytes of file-backed memory on active LRU list.
>  unevictable    - # of bytes of memory that cannot be reclaimed (mlocked
> etc).
> +direct_elapsed_ns  - # of elapsed cpu time at hard limit reclaim (ns)
> +soft_elapsed_ns  - # of elapsed cpu time at soft limit reclaim (ns)
> +wmark_elapsed_ns  - # of elapsed cpu time at hi/low watermark reclaim (ns)
> +direct_scanned - # of page scans at hard limit reclaim
> +soft_scanned   - # of page scans at soft limit reclaim
> +wmark_scanned  - # of page scans at hi/low watermark reclaim
> +direct_freed   - # of page freeing at hard limit reclaim
> +soft_freed     - # of page freeing at soft limit reclaim
> +wmark_freed    - # of page freeing at hi/low watermark reclaim
>
>  # status considering hierarchy (see memory.use_hierarchy settings)
>
> @@ -421,6 +430,15 @@ total_active_anon  - sum of all children'
>  total_inactive_file    - sum of all children's "inactive_file"
>  total_active_file      - sum of all children's "active_file"
>  total_unevictable      - sum of all children's "unevictable"
> +total_direct_elapsed_ns - sum of all children's "direct_elapsed_ns"
> +total_soft_elapsed_ns  - sum of all children's "soft_elapsed_ns"
> +total_wmark_elapsed_ns - sum of all children's "wmark_elapsed_ns"
> +total_direct_scanned   - sum of all children's "direct_scanned"
> +total_soft_scanned     - sum of all children's "soft_scanned"
> +total_wmark_scanned    - sum of all children's "wmark_scanned"
> +total_direct_freed     - sum of all children's "direct_freed"
> +total_soft_freed       - sum of all children's "soft_freed"
> +total_wamrk_freed      - sum of all children's "wmark_freed"
>
>  # The following additional stats are dependent on CONFIG_DEBUG_VM.
>
> Those stats looks good to me. Thanks

--Ying

--0016360e3f5c4ec63c04a1cbb108
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 25, 2011 at 2:43 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
At tuning memcg background reclaim, cpu usage per memcg&#39;s work is an<br=
>
interesting information because some amount of shared resource is used.<br>
(i.e. background reclaim uses workqueue.) And other information as<br>
pgscan and pgreclaim is important.<br>
<br>
This patch shows them via memory.stat with cpu usage for direct reclaim<br>
and softlimit reclaim and page scan statistics.<br>
<br>
<br>
=A0# cat /cgroup/memory/A/memory.stat<br>
=A0....<br>
=A0direct_elapsed_ns 0<br>
=A0soft_elapsed_ns 0<br>
=A0wmark_elapsed_ns 103566424<br>
=A0direct_scanned 0<br>
=A0soft_scanned 0<br>
=A0wmark_scanned 29303<br>
=A0direct_freed 0<br>
=A0soft_freed 0<br>
=A0wmark_freed 29290<br>
<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0Documentation/cgroups/memory.txt | =A0 18 +++++++++<br>
=A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 =A06 +++<br>
=A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A07 +++<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 77 ++++++++++++=
+++++++++++++++++++++++++--<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 15 +++++++<=
br>
=A05 files changed, 120 insertions(+), 3 deletions(-)<br>
<br>
Index: memcg/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/memcontrol.c<br>
+++ memcg/mm/memcontrol.c<br>
@@ -274,6 +274,17 @@ struct mem_cgroup {<br>
 =A0 =A0 =A0 =A0bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bgreclaim_resch=
ed;<br>
 =A0 =A0 =A0 =A0struct delayed_work =A0 =A0 bgreclaim_work;<br>
 =A0 =A0 =A0 =A0/*<br>
+ =A0 =A0 =A0 =A0* reclaim statistics (not per zone, node)<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0elapsed_lock;<br>
+ =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bgreclaim_elapsed=
;<br>
+ =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 direct_elapsed;<b=
r>
+ =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 soft_elapsed;<br>
+<br>
+ =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_scan[NR_R=
ECLAIM_CONTEXTS];<br>
+ =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_freed[NR_=
RECLAIM_CONTEXTS];<br>
+<br>
+ =A0 =A0 =A0 /*<br>
 =A0 =A0 =A0 =A0 * Should we move charges of a task when a task is moved in=
to this<br>
 =A0 =A0 =A0 =A0 * mem_cgroup ? And what type of charges should we move ?<b=
r>
 =A0 =A0 =A0 =A0 */<br>
@@ -1346,6 +1357,18 @@ void mem_cgroup_clear_unreclaimable(stru<br>
 =A0 =A0 =A0 =A0return;<br>
=A0}<br>
<br>
+void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 int context, unsigned long scanned,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long freed)<br>
+{<br>
+ =A0 =A0 =A0 if (!mem)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 spin_lock(&amp;mem-&gt;elapsed_lock);<br>
+ =A0 =A0 =A0 mem-&gt;reclaim_scan[context] +=3D scanned;<br>
+ =A0 =A0 =A0 mem-&gt;reclaim_freed[context] +=3D freed;<br>
+ =A0 =A0 =A0 spin_unlock(&amp;mem-&gt;elapsed_lock);<br>
+}<br>
+<br>
=A0unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct list_head *dst,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0unsigned long *scanned, int order,<br>
@@ -1692,6 +1715,7 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0bool check_soft =3D reclaim_options &amp; MEM_CGROUP_RECLAI=
M_SOFT;<br>
 =A0 =A0 =A0 =A0unsigned long excess;<br>
 =A0 =A0 =A0 =A0unsigned long nr_scanned;<br>
+ =A0 =A0 =A0 s64 start, end;<br>
<br>
 =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&amp;root_mem-&gt;=
res) &gt;&gt; PAGE_SHIFT;<br>
<br>
@@ -1735,16 +1759,27 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_n=
ode_zone(victim, gfp_mask,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap, mem=
_cgroup_swappiness(victim), zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&amp;nr_sca=
nned);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=3D nr_scan=
ned;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D sched_clock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;victim-&gt;ela=
psed_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim-&gt;soft_elapsed +=3D =
end - start;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;victim-&gt;e=
lapsed_lock);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_steal(victi=
m, ret);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_scan(victim=
, nr_scanned);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cgr=
oup_pages(victim, gfp_mask,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0noswap,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_swappiness(victim));<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D sched_clock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;victim-&gt;ela=
psed_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim-&gt;direct_elapsed +=
=3D end - start;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;victim-&gt;e=
lapsed_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * At shrinking usage, we can&#39;t check w=
e should stop here or<br>
@@ -3702,15 +3737,22 @@ static void memcg_bgreclaim(struct work_<br>
 =A0 =A0 =A0 =A0struct delayed_work *dw =3D to_delayed_work(work);<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem =3D<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0container_of(dw, struct mem_cgroup, bgrecla=
im_work);<br>
- =A0 =A0 =A0 int delay =3D 0;<br>
+ =A0 =A0 =A0 int delay;<br>
 =A0 =A0 =A0 =A0unsigned long long required, usage, hiwat;<br>
<br>
+ =A0 =A0 =A0 delay =3D 0;<br>
 =A0 =A0 =A0 =A0hiwat =3D res_counter_read_u64(&amp;mem-&gt;res, RES_HIGH_W=
MARK_LIMIT);<br>
 =A0 =A0 =A0 =A0usage =3D res_counter_read_u64(&amp;mem-&gt;res, RES_USAGE)=
;<br>
 =A0 =A0 =A0 =A0required =3D usage - hiwat;<br>
 =A0 =A0 =A0 =A0if (required &gt;=3D 0) =A0{<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 start, end;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0required =3D ((usage - hiwat) &gt;&gt; PAGE=
_SHIFT) + 1;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delay =3D shrink_mem_cgroup(mem, (long)requ=
ired);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D sched_clock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;mem-&gt;elapsed_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;bgreclaim_elapsed +=3D end - start;<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;mem-&gt;elapsed_lock);<br>
 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0if (!mem-&gt;bgreclaim_resched =A0||<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_watermark_ok(mem, CHARGE_WMARK_H=
IGH)) {<br>
@@ -4152,6 +4194,15 @@ enum {<br>
 =A0 =A0 =A0 =A0MCS_INACTIVE_FILE,<br>
 =A0 =A0 =A0 =A0MCS_ACTIVE_FILE,<br>
 =A0 =A0 =A0 =A0MCS_UNEVICTABLE,<br>
+ =A0 =A0 =A0 MCS_DIRECT_ELAPSED,<br>
+ =A0 =A0 =A0 MCS_SOFT_ELAPSED,<br>
+ =A0 =A0 =A0 MCS_WMARK_ELAPSED,<br>
+ =A0 =A0 =A0 MCS_DIRECT_SCANNED,<br>
+ =A0 =A0 =A0 MCS_SOFT_SCANNED,<br>
+ =A0 =A0 =A0 MCS_WMARK_SCANNED,<br>
+ =A0 =A0 =A0 MCS_DIRECT_FREED,<br>
+ =A0 =A0 =A0 MCS_SOFT_FREED,<br>
+ =A0 =A0 =A0 MCS_WMARK_FREED,<br>
 =A0 =A0 =A0 =A0NR_MCS_STAT,<br>
=A0};<br>
<br>
@@ -4177,7 +4228,16 @@ struct {<br>
 =A0 =A0 =A0 =A0{&quot;active_anon&quot;, &quot;total_active_anon&quot;},<b=
r>
 =A0 =A0 =A0 =A0{&quot;inactive_file&quot;, &quot;total_inactive_file&quot;=
},<br>
 =A0 =A0 =A0 =A0{&quot;active_file&quot;, &quot;total_active_file&quot;},<b=
r>
- =A0 =A0 =A0 {&quot;unevictable&quot;, &quot;total_unevictable&quot;}<br>
+ =A0 =A0 =A0 {&quot;unevictable&quot;, &quot;total_unevictable&quot;},<br>
+ =A0 =A0 =A0 {&quot;direct_elapsed_ns&quot;, &quot;total_direct_elapsed_ns=
&quot;},<br>
+ =A0 =A0 =A0 {&quot;soft_elapsed_ns&quot;, &quot;total_soft_elapsed_ns&quo=
t;},<br>
+ =A0 =A0 =A0 {&quot;wmark_elapsed_ns&quot;, &quot;total_wmark_elapsed_ns&q=
uot;},<br>
+ =A0 =A0 =A0 {&quot;direct_scanned&quot;, &quot;total_direct_scanned&quot;=
},<br>
+ =A0 =A0 =A0 {&quot;soft_scanned&quot;, &quot;total_soft_scanned&quot;},<b=
r>
+ =A0 =A0 =A0 {&quot;wmark_scanned&quot;, &quot;total_wmark_scanned&quot;},=
<br>
+ =A0 =A0 =A0 {&quot;direct_freed&quot;, &quot;total_direct_freed&quot;},<b=
r>
+ =A0 =A0 =A0 {&quot;soft_freed&quot;, &quot;total_soft_freed&quot;},<br>
+ =A0 =A0 =A0 {&quot;wmark_freed&quot;, &quot;total_wamrk_freed&quot;}<br>
=A0};<br>
<br>
<br>
@@ -4185,6 +4245,7 @@ static void<br>
=A0mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat =
*s)<br>
=A0{<br>
 =A0 =A0 =A0 =A0s64 val;<br>
+ =A0 =A0 =A0 int i;<br>
<br>
 =A0 =A0 =A0 =A0/* per cpu stat */<br>
 =A0 =A0 =A0 =A0val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);<b=
r>
@@ -4221,6 +4282,15 @@ mem_cgroup_get_local_stat(struct mem_cgr<br>
 =A0 =A0 =A0 =A0s-&gt;stat[MCS_ACTIVE_FILE] +=3D val * PAGE_SIZE;<br>
 =A0 =A0 =A0 =A0val =3D mem_cgroup_get_local_zonestat(mem, LRU_UNEVICTABLE)=
;<br>
 =A0 =A0 =A0 =A0s-&gt;stat[MCS_UNEVICTABLE] +=3D val * PAGE_SIZE;<br>
+<br>
+ =A0 =A0 =A0 /* reclaim stats */<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_DIRECT_ELAPSED] +=3D mem-&gt;direct_elapsed;<b=
r>
+ =A0 =A0 =A0 s-&gt;stat[MCS_SOFT_ELAPSED] +=3D mem-&gt;soft_elapsed;<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_WMARK_ELAPSED] +=3D mem-&gt;bgreclaim_elapsed;=
<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; NR_RECLAIM_CONTEXTS; i++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;stat[i + MCS_DIRECT_SCANNED] +=3D mem-&=
gt;reclaim_scan[i];<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;stat[i + MCS_DIRECT_FREED] +=3D mem-&gt=
;reclaim_freed[i];<br>
+ =A0 =A0 =A0 }<br>
=A0}<br>
<br>
=A0static void<br>
@@ -4889,6 +4959,7 @@ static struct mem_cgroup *mem_cgroup_all<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free;<br>
 =A0 =A0 =A0 =A0spin_lock_init(&amp;mem-&gt;pcp_counter_lock);<br>
 =A0 =A0 =A0 =A0INIT_DELAYED_WORK(&amp;mem-&gt;bgreclaim_work, memcg_bgrecl=
aim);<br>
+ =A0 =A0 =A0 spin_lock_init(&amp;mem-&gt;elapsed_lock);<br>
 =A0 =A0 =A0 =A0mem-&gt;bgreclaim_resched =3D true;<br>
 =A0 =A0 =A0 =A0return mem;<br>
<br>
Index: memcg/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/include/linux/memcontrol.h<br>
+++ memcg/include/linux/memcontrol.h<br>
@@ -90,6 +90,8 @@ extern int mem_cgroup_select_victim_node<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0const nodemask_t *nodes);<br>
<br>
=A0int shrink_mem_cgroup(struct mem_cgroup *mem, long required);<br>
+void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem, int context,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scanned, unsign=
ed long freed);<br>
<br>
=A0static inline<br>
=A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup =
*cgroup)<br>
@@ -423,6 +425,10 @@ static inline<br>
=A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item =
idx)<br>
=A0{<br>
=A0}<br>
+void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem, int context,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 scanned, unsigned long freed)<br>
+{<br>
+}<br>
=A0#endif /* CONFIG_CGROUP_MEM_CONT */<br>
<br>
=A0#if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)<br=
>
Index: memcg/include/linux/swap.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/include/linux/swap.h<br>
+++ memcg/include/linux/swap.h<br>
@@ -250,6 +250,13 @@ static inline void lru_cache_add_file(st<br>
=A0#define ISOLATE_ACTIVE 1 =A0 =A0 =A0 /* Isolate active pages. */<br>
=A0#define ISOLATE_BOTH 2 =A0 =A0 =A0 =A0 /* Isolate both active and inacti=
ve pages. */<br>
<br>
+/* context for memory reclaim.( comes from memory cgroup.) */<br>
+enum {<br>
+ =A0 =A0 =A0 RECLAIM_DIRECT, =A0 =A0 =A0 =A0 /* under direct reclaim */<br=
>
+ =A0 =A0 =A0 RECLAIM_KSWAPD, =A0 =A0 =A0 =A0 /* under global kswapd&#39;s =
soft limit */<br>
+ =A0 =A0 =A0 RECLAIM_WMARK, =A0 =A0 =A0 =A0 =A0/* under background reclaim=
 by watermark */<br>
+ =A0 =A0 =A0 NR_RECLAIM_CONTEXTS<br>
+};<br>
=A0/* linux/mm/vmscan.c */<br>
=A0extern unsigned long try_to_free_pages(struct zonelist *zonelist, int or=
der,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask, nodemask_t *mask);<br>
Index: memcg/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/vmscan.c<br>
+++ memcg/mm/vmscan.c<br>
@@ -72,6 +72,9 @@ typedef unsigned __bitwise__ reclaim_mod<br>
=A0#define RECLAIM_MODE_LUMPYRECLAIM =A0 =A0 =A0((__force reclaim_mode_t)0x=
08u)<br>
=A0#define RECLAIM_MODE_COMPACTION =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((__force=
 reclaim_mode_t)0x10u)<br>
<br>
+/* 3 reclaim contexts fro memcg statistics. */<br>
+enum {DIRECT_RECLAIM, KSWAPD_RECLAIM, WMARK_RECLAIM};<br>
+<br>
=A0struct scan_control {<br>
 =A0 =A0 =A0 =A0/* Incremented by the number of inactive pages that were sc=
anned */<br>
 =A0 =A0 =A0 =A0unsigned long nr_scanned;<br>
@@ -107,6 +110,7 @@ struct scan_control {<br>
<br>
 =A0 =A0 =A0 =A0/* Which cgroup do we reclaim from */<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem_cgroup;<br>
+ =A0 =A0 =A0 int =A0 =A0 reclaim_context;<br>
<br>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * Nodemask of nodes allowed by the caller. If NULL, all no=
des<br>
@@ -2116,6 +2120,10 @@ out:<br>
 =A0 =A0 =A0 =A0delayacct_freepages_end();<br>
 =A0 =A0 =A0 =A0put_mems_allowed();<br>
<br>
+ =A0 =A0 =A0 if (!scanning_global_lru(sc))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_reclaim_statistics(sc-&gt;mem_cgro=
up,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;reclaim_context, total=
_scanned, sc-&gt;nr_reclaimed);<br>
+<br>
 =A0 =A0 =A0 =A0if (sc-&gt;nr_reclaimed)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return sc-&gt;nr_reclaimed;<br>
<br>
@@ -2178,6 +2186,7 @@ unsigned long mem_cgroup_shrink_node_zon<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.swappiness =3D swappiness,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reclaim_context =3D RECLAIM_KSWAPD,<br>
 =A0 =A0 =A0 =A0};<br>
<br>
 =A0 =A0 =A0 =A0sc.gfp_mask =3D (gfp_mask &amp; GFP_RECLAIM_MASK) |<br>
@@ -2198,6 +2207,8 @@ unsigned long mem_cgroup_shrink_node_zon<br>
<br>
 =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed=
);<br>
<br>
+ =A0 =A0 =A0 mem_cgroup_reclaim_statistics(sc.mem_cgroup,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.reclaim_context, sc.nr_sca=
nned, sc.nr_reclaimed);<br>
 =A0 =A0 =A0 =A0*nr_scanned =3D sc.nr_scanned;<br>
 =A0 =A0 =A0 =A0return sc.nr_reclaimed;<br>
=A0}<br>
@@ -2217,6 +2228,7 @@ unsigned long try_to_free_mem_cgroup_pag<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.swappiness =3D swappiness,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem_cont,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reclaim_context =3D RECLAIM_DIRECT,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nodemask =3D NULL, /* we don&#39;t care th=
e placement */<br>
 =A0 =A0 =A0 =A0};<br>
<br>
@@ -2384,6 +2396,7 @@ int shrink_mem_cgroup(struct mem_cgroup<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_swap =3D 1,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reclaim_context =3D RECLAIM_WMARK,<br>
 =A0 =A0 =A0 =A0};<br>
 =A0 =A0 =A0 =A0/* writepage will be set later per zone */<br>
 =A0 =A0 =A0 =A0sc.may_writepage =3D 0;<br>
@@ -2434,6 +2447,8 @@ int shrink_mem_cgroup(struct mem_cgroup<br>
 =A0 =A0 =A0 =A0if (sc.nr_reclaimed &gt; sc.nr_to_reclaim/2)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delay =3D 0;<br>
=A0out:<br>
+ =A0 =A0 =A0 mem_cgroup_reclaim_statistics(sc.mem_cgroup, sc.reclaim_conte=
xt,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned, sc.nr_reclaime=
d);<br>
 =A0 =A0 =A0 =A0current-&gt;flags &amp;=3D ~PF_SWAPWRITE;<br>
 =A0 =A0 =A0 =A0return delay;<br>
=A0}<br>
Index: memcg/Documentation/cgroups/memory.txt<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/Documentation/cgroups/memory.txt<br>
+++ memcg/Documentation/cgroups/memory.txt<br>
@@ -398,6 +398,15 @@ active_anon =A0 =A0 =A0 =A0- # of bytes of anonymous a=
n<br>
=A0inactive_file =A0- # of bytes of file-backed memory on inactive LRU list=
.<br>
=A0active_file =A0 =A0- # of bytes of file-backed memory on active LRU list=
.<br>
=A0unevictable =A0 =A0- # of bytes of memory that cannot be reclaimed (mloc=
ked etc).<br>
+direct_elapsed_ns =A0- # of elapsed cpu time at hard limit reclaim (ns)<br=
>
+soft_elapsed_ns =A0- # of elapsed cpu time at soft limit reclaim (ns)<br>
+wmark_elapsed_ns =A0- # of elapsed cpu time at hi/low watermark reclaim (n=
s)<br>
+direct_scanned - # of page scans at hard limit reclaim<br>
+soft_scanned =A0 - # of page scans at soft limit reclaim<br>
+wmark_scanned =A0- # of page scans at hi/low watermark reclaim<br>
+direct_freed =A0 - # of page freeing at hard limit reclaim<br>
+soft_freed =A0 =A0 - # of page freeing at soft limit reclaim<br>
+wmark_freed =A0 =A0- # of page freeing at hi/low watermark reclaim<br>
<br>
=A0# status considering hierarchy (see memory.use_hierarchy settings)<br>
<br>
@@ -421,6 +430,15 @@ total_active_anon =A0- sum of all children&#39;<br>
=A0total_inactive_file =A0 =A0- sum of all children&#39;s &quot;inactive_fi=
le&quot;<br>
=A0total_active_file =A0 =A0 =A0- sum of all children&#39;s &quot;active_fi=
le&quot;<br>
=A0total_unevictable =A0 =A0 =A0- sum of all children&#39;s &quot;unevictab=
le&quot;<br>
+total_direct_elapsed_ns - sum of all children&#39;s &quot;direct_elapsed_n=
s&quot;<br>
+total_soft_elapsed_ns =A0- sum of all children&#39;s &quot;soft_elapsed_ns=
&quot;<br>
+total_wmark_elapsed_ns - sum of all children&#39;s &quot;wmark_elapsed_ns&=
quot;<br>
+total_direct_scanned =A0 - sum of all children&#39;s &quot;direct_scanned&=
quot;<br>
+total_soft_scanned =A0 =A0 - sum of all children&#39;s &quot;soft_scanned&=
quot;<br>
+total_wmark_scanned =A0 =A0- sum of all children&#39;s &quot;wmark_scanned=
&quot;<br>
+total_direct_freed =A0 =A0 - sum of all children&#39;s &quot;direct_freed&=
quot;<br>
+total_soft_freed =A0 =A0 =A0 - sum of all children&#39;s &quot;soft_freed&=
quot;<br>
+total_wamrk_freed =A0 =A0 =A0- sum of all children&#39;s &quot;wmark_freed=
&quot;<br>
<br>
=A0# The following additional stats are dependent on CONFIG_DEBUG_VM.<br>
<br></blockquote><div>Those stats looks good to me. Thanks</div><div><br></=
div><div>--Ying=A0</div></div><br>

--0016360e3f5c4ec63c04a1cbb108--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
