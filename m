Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 334C36B012B
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 02:50:05 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p5L6nvQM012173
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 23:49:57 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by kpbe13.cbf.corp.google.com with ESMTP id p5L6ntgM001151
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 23:49:55 -0700
Received: by qyk29 with SMTP id 29so2208115qyk.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 23:49:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 20 Jun 2011 23:49:54 -0700
Message-ID: <BANLkTim-r6ejJK601rWq7smY37FC9um7mg@mail.gmail.com>
Subject: Re: [PATCH 3/7] memcg: add memory.scan_stat
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00163649971d6f1b5504a6334269
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

--00163649971d6f1b5504a6334269
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Jun 15, 2011 at 8:53 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From e08990dd9ada13cf236bec1ef44b207436434b8e Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 15 Jun 2011 14:11:01 +0900
> Subject: [PATCH 3/7] memcg: add memory.scan_stat
>
> commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim in..."
> says it adds scanning stats to memory.stat file. But it doesn't because
> we considered we needed to make a concensus for such new APIs.
>
> This patch is a trial to add memory.scan_stat. This shows
>  - the number of scanned pages
>  - the number of recleimed pages
>  - the number of elaplsed time (including sleep/pause time)
>  for both of direct/soft reclaim and shrinking caused by changing limit
>  or force_empty.
>
> The biggest difference with oringinal Ying's one is that this file
> can be reset by some write, as
>
>  # echo 0 ...../memory.scan_stat
>
> [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> scanned_pages_by_limit 358470
> freed_pages_by_limit 180795
> elapsed_ns_by_limit 21629927
> scanned_pages_by_system 0
> freed_pages_by_system 0
> elapsed_ns_by_system 0
> scanned_pages_by_shrink 76646
> freed_pages_by_shrink 38355
> elappsed_ns_by_shrink 31990670
>

elapsed?


> total_scanned_pages_by_limit 358470
> total_freed_pages_by_limit 180795
> total_elapsed_ns_by_hierarchical 216299275
> total_scanned_pages_by_system 0
> total_freed_pages_by_system 0
> total_elapsed_ns_by_system 0
> total_scanned_pages_by_shrink 76646
> total_freed_pages_by_shrink 38355
> total_elapsed_ns_by_shrink 31990670
>
> total_xxxx is for hierarchy management.
>

For some reason, i feel the opposite where the local stat (like
"scanned_pages_by_limit") are reclaimed under hierarchical reclaim. The
total_xxx stats are only incremented for root_mem which is the cgroup
triggers the hierarchical reclaim. So:

total_scanned_pages_by_limit: number of pages being scanned while the memcg
hits its limit
scanned_pages_by_limit: number of pages being scanned while one of the
memcg's ancestor hits its limit

am i missing something?


>
> This will be useful for further memcg developments and need to be
> developped before we do some complicated rework on LRU/softlimit
> management.
>
> Now, scan/free/elapsed_by_system is incomplete but future works of
> Johannes at el. will fill remaining information and then, we can
> look into problems of isolation between memcgs.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |   33 +++++++++
>  include/linux/memcontrol.h       |   16 ++++
>  include/linux/swap.h             |    6 -
>  mm/memcontrol.c                  |  135
> +++++++++++++++++++++++++++++++++++++--
>  mm/vmscan.c                      |   27 ++++++-
>  5 files changed, 199 insertions(+), 18 deletions(-)
>
> Index: mmotm-0615/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-0615.orig/Documentation/cgroups/memory.txt
> +++ mmotm-0615/Documentation/cgroups/memory.txt
> @@ -380,7 +380,7 @@ will be charged as a new owner of it.
>
>  5.2 stat file
>
> -memory.stat file includes following statistics
> +5.2.1 memory.stat file includes following statistics
>
>  # per-memory cgroup local status
>  cache          - # of bytes of page cache memory.
> @@ -438,6 +438,37 @@ Note:
>         file_mapped is accounted only when the memory cgroup is owner of
> page
>         cache.)
>
> +5.2.2 memory.scan_stat
> +
> +memory.scan_stat includes statistics information for memory scanning and
> +freeing, reclaiming. The statistics shows memory scanning information
> since
> +memory cgroup creation and can be reset to 0 by writing 0 as
> +
> + #echo 0 > ../memory.scan_stat
> +
> +This file contains following statistics.
> +
> +scanned_pages_by_limit - # of scanned pages at hitting limit.
> +freed_pages_by_limit   - # of freed pages at hitting limit.
> +elapsed_ns_by_limit    - nano sec of elappsed time at LRU scan at
> +                                  hitting limit.(this includes sleep
> time.)
>
elapsed?

> +
> +scanned_pages_by_system        - # of scanned pages by the kernel.
> +                         (Now, this value means global memory reclaim
> +                           caused by system memory shortage with a hint
> +                          of softlimit. "No soft limit" case will be
> +                          supported in future.)
> +freed_pages_by_system  - # of freed pages by the kernel.
> +elapsed_ns_by_system   - nano sec of elappsed time by kernel.
> +
> +scanned_pages_by_shrink        - # of scanned pages by shrinking.
> +                                 (i.e. changes of limit, force_empty,
> etc.)
> +freed_pages_by_shrink  - # of freed pages by shirkining.
> +elappsed_ns_by_shrink  - nano sec of elappsed time at shrinking.
>
elapsed?

> +
> +total_xxx includes the statistics of children scanning caused by the
> cgroup.
>

based on the code inspection, the total_xxx also includes the cgroup's scan
stat as well.

+
> +
>  5.3 swappiness
>
>  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups
> only.
> Index: mmotm-0615/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-0615.orig/include/linux/memcontrol.h
> +++ mmotm-0615/include/linux/memcontrol.h
> @@ -120,6 +120,22 @@ struct zone_reclaim_stat*
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
>  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>                                        struct task_struct *p);
> +struct memcg_scanrecord {
> +       struct mem_cgroup *mem; /* scanend memory cgroup */
> +       struct mem_cgroup *root; /* scan target hierarchy root */
> +       int context;            /* scanning context (see memcontrol.c) */
> +       unsigned long nr_scanned; /* the number of scanned pages */
> +       unsigned long nr_freed; /* the number of freed pages */
> +       unsigned long elappsed; /* nsec of time elapsed while scanning */
>
elapsed?

> +};
> +
> +extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
> +                                                 gfp_t gfp_mask, bool
> noswap,
> +                                                 struct memcg_scanrecord
> *rec);
> +extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> +                                               gfp_t gfp_mask, bool
> noswap,
> +                                               struct zone *zone,
> +                                               struct memcg_scanrecord
> *rec);
>
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern int do_swap_account;
> Index: mmotm-0615/include/linux/swap.h
> ===================================================================
> --- mmotm-0615.orig/include/linux/swap.h
> +++ mmotm-0615/include/linux/swap.h
> @@ -253,12 +253,6 @@ static inline void lru_cache_add_file(st
>  /* linux/mm/vmscan.c */
>  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int
> order,
>                                        gfp_t gfp_mask, nodemask_t *mask);
> -extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
> -                                                 gfp_t gfp_mask, bool
> noswap);
> -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> -                                               gfp_t gfp_mask, bool
> noswap,
> -                                               struct zone *zone,
> -                                               unsigned long *nr_scanned);
>  extern int __isolate_lru_page(struct page *page, int mode, int file);
>  extern unsigned long shrink_all_memory(unsigned long nr_pages);
>  extern int vm_swappiness;
> Index: mmotm-0615/mm/memcontrol.c
> ===================================================================
> --- mmotm-0615.orig/mm/memcontrol.c
> +++ mmotm-0615/mm/memcontrol.c
> @@ -203,6 +203,57 @@ struct mem_cgroup_eventfd_list {
>  static void mem_cgroup_threshold(struct mem_cgroup *mem);
>  static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
>
> +enum {
> +       SCAN_BY_LIMIT,
> +       FREED_BY_LIMIT,
> +       ELAPSED_BY_LIMIT,
> +
> +       SCAN_BY_SYSTEM,
> +       FREED_BY_SYSTEM,
> +       ELAPSED_BY_SYSTEM,
> +
> +       SCAN_BY_SHRINK,
> +       FREED_BY_SHRINK,
> +       ELAPSED_BY_SHRINK,
> +       NR_SCANSTATS,
> +};
> +#define __FREED                (1)
> +#define        __ELAPSED       (2)
>

/tab/space/


> +
> +struct scanstat {
> +       spinlock_t      lock;
> +       unsigned long   stats[NR_SCANSTATS];    /* local statistics */
> +       unsigned long   totalstats[NR_SCANSTATS];   /* hierarchical */
> +};
> +
> +const char *scanstat_string[NR_SCANSTATS] = {
> +       "scanned_pages_by_limit",
> +       "freed_pages_by_limit",
> +       "elapsed_ns_by_limit",
> +
> +       "scanned_pages_by_system",
> +       "freed_pages_by_system",
> +       "elapsed_ns_by_system",
> +
> +       "scanned_pages_by_shrink",
> +       "freed_pages_by_shrink",
> +       "elappsed_ns_by_shrink",
>
elapsed?

> +};
> +
> +const char *total_scanstat_string[NR_SCANSTATS] = {
> +       "total_scanned_pages_by_limit",
> +       "total_freed_pages_by_limit",
> +       "total_elapsed_ns_by_hierarchical",
>

typo?


> +
> +       "total_scanned_pages_by_system",
> +       "total_freed_pages_by_system",
> +       "total_elapsed_ns_by_system",
> +
> +       "total_scanned_pages_by_shrink",
> +       "total_freed_pages_by_shrink",
> +       "total_elapsed_ns_by_shrink",
> +};
> +
>  /*
>  * The memory controller data structure. The memory controller controls
> both
>  * page cache and RSS per cgroup. We would eventually like to provide
> @@ -264,7 +315,8 @@ struct mem_cgroup {
>
>        /* For oom notifier event fd */
>        struct list_head oom_notify;
> -
> +       /* For recording LRU-scan statistics */
> +       struct scanstat scanstat;
>        /*
>         * Should we move charges of a task when a task is moved into this
>         * mem_cgroup ? And what type of charges should we move ?
> @@ -1634,6 +1686,28 @@ int mem_cgroup_select_victim_node(struct
>  }
>  #endif
>
> +
> +
> +static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
> +{
> +       struct mem_cgroup *mem;
> +       int context = rec->context;
> +
> +       mem = rec->mem;
> +       spin_lock(&mem->scanstat.lock);
> +       mem->scanstat.stats[context] += rec->nr_scanned;
> +       mem->scanstat.stats[context + __FREED] += rec->nr_freed;
> +       mem->scanstat.stats[context + __ELAPSED] += rec->elappsed;
>
elapsed?


+       spin_unlock(&mem->scanstat.lock);
> +
> +       mem = rec->root;
> +       spin_lock(&mem->scanstat.lock);
> +       mem->scanstat.totalstats[context] += rec->nr_scanned;
> +       mem->scanstat.totalstats[context + __FREED] += rec->nr_freed;
> +       mem->scanstat.totalstats[context + __ELAPSED] += rec->elappsed;
>

elapsed?

> +       spin_unlock(&mem->scanstat.lock);
> +}
> +
>  /*
>  * Scan the hierarchy if needed to reclaim memory. We remember the last
> child
>  * we reclaimed from, so that we don't end up penalizing one child
> extensively
> @@ -1659,8 +1733,8 @@ static int mem_cgroup_hierarchical_recla
>        bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
>        bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
>        unsigned long excess;
> -       unsigned long nr_scanned;
>        int visit;
> +       struct memcg_scanrecord rec;
>
>        excess = res_counter_soft_limit_excess(&root_mem->res) >>
> PAGE_SHIFT;
>
> @@ -1668,6 +1742,15 @@ static int mem_cgroup_hierarchical_recla
>        if (!check_soft && root_mem->memsw_is_minimum)
>                noswap = true;
>
> +       if (shrink)
> +               rec.context = SCAN_BY_SHRINK;
> +       else if (check_soft)
> +               rec.context = SCAN_BY_SYSTEM;
> +       else
> +               rec.context = SCAN_BY_LIMIT;
> +
> +       rec.root = root_mem;
>



> +
>  again:
>        if (!shrink) {
>                visit = 0;
> @@ -1695,14 +1778,19 @@ again:
>                        css_put(&victim->css);
>                        continue;
>                }
> +               rec.mem = victim;
> +               rec.nr_scanned = 0;
> +               rec.nr_freed = 0;
> +               rec.elappsed = 0;
>
elapsed?

>                /* we use swappiness of local cgroup */
>                if (check_soft) {
>                        ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> -                               noswap, zone, &nr_scanned);
> -                       *total_scanned += nr_scanned;
> +                               noswap, zone, &rec);
> +                       *total_scanned += rec.nr_scanned;
>                } else
>                        ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> -                                               noswap);
> +                                               noswap, &rec);
> +               mem_cgroup_record_scanstat(&rec);
>                css_put(&victim->css);
>
>                total += ret;
> @@ -3757,7 +3845,8 @@ try_to_free:
>                        ret = -EINTR;
>                        goto out;
>                }
> -               progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> false);
> +               progress = try_to_free_mem_cgroup_pages(mem,
> +                               GFP_KERNEL, false, NULL);
>

So we don't record the stat for force_empty case?


>                if (!progress) {
>                        nr_retries--;
>                        /* maybe some writeback is necessary */
> @@ -4599,6 +4688,34 @@ static int mem_control_numa_stat_open(st
>  }
>  #endif /* CONFIG_NUMA */
>
> +static int mem_cgroup_scan_stat_read(struct cgroup *cgrp,
> +                               struct cftype *cft,
> +                               struct cgroup_map_cb *cb)
> +{
> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +       int i;
> +
> +       for (i = 0; i < NR_SCANSTATS; i++)
> +               cb->fill(cb, scanstat_string[i], mem->scanstat.stats[i]);
> +       for (i = 0; i < NR_SCANSTATS; i++)
> +               cb->fill(cb, total_scanstat_string[i],
> +                       mem->scanstat.totalstats[i]);
> +       return 0;
> +}
> +
> +static int mem_cgroup_reset_scan_stat(struct cgroup *cgrp,
> +                               unsigned int event)
> +{
> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +
> +       spin_lock(&mem->scanstat.lock);
> +       memset(&mem->scanstat.stats, 0, sizeof(mem->scanstat.stats));
> +       memset(&mem->scanstat.totalstats, 0,
> sizeof(mem->scanstat.totalstats));
> +       spin_unlock(&mem->scanstat.lock);
> +       return 0;
> +}
> +
> +
>  static struct cftype mem_cgroup_files[] = {
>        {
>                .name = "usage_in_bytes",
> @@ -4669,6 +4786,11 @@ static struct cftype mem_cgroup_files[]
>                .mode = S_IRUGO,
>        },
>  #endif
> +       {
> +               .name = "scan_stat",
> +               .read_map = mem_cgroup_scan_stat_read,
> +               .trigger = mem_cgroup_reset_scan_stat,
> +       },
>  };
>
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -4932,6 +5054,7 @@ mem_cgroup_create(struct cgroup_subsys *
>        atomic_set(&mem->refcnt, 1);
>        mem->move_charge_at_immigrate = 0;
>        mutex_init(&mem->thresholds_lock);
> +       spin_lock_init(&mem->scanstat.lock);
>        return &mem->css;
>  free_out:
>        __mem_cgroup_free(mem);
> Index: mmotm-0615/mm/vmscan.c
> ===================================================================
> --- mmotm-0615.orig/mm/vmscan.c
> +++ mmotm-0615/mm/vmscan.c
> @@ -2199,9 +2199,9 @@ unsigned long try_to_free_pages(struct z
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>
>  unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> -                                               gfp_t gfp_mask, bool
> noswap,
> -                                               struct zone *zone,
> -                                               unsigned long *nr_scanned)
> +                                       gfp_t gfp_mask, bool noswap,
> +                                       struct zone *zone,
> +                                       struct memcg_scanrecord *rec)
>  {
>        struct scan_control sc = {
>                .nr_scanned = 0,
> @@ -2213,6 +2213,7 @@ unsigned long mem_cgroup_shrink_node_zon
>                .order = 0,
>                .mem_cgroup = mem,
>        };
> +       unsigned long start, end;
>
>        sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>                        (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> @@ -2221,6 +2222,7 @@ unsigned long mem_cgroup_shrink_node_zon
>                                                      sc.may_writepage,
>                                                      sc.gfp_mask);
>
> +       start = sched_clock();
>        /*
>         * NOTE: Although we can get the priority field, using it
>         * here is not a good idea, since it limits the pages we can scan.
> @@ -2229,19 +2231,27 @@ unsigned long mem_cgroup_shrink_node_zon
>         * the priority and make it zero.
>         */
>        shrink_zone(0, zone, &sc);
> +       end = sched_clock();
> +
> +       if (rec) {
> +               rec->nr_scanned += sc.nr_scanned;
>



> +               rec->nr_freed += sc.nr_reclaimed;
> +               rec->elappsed += end - start;
>
elapsed?

> +       }
>
>        trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>
> -       *nr_scanned = sc.nr_scanned;
>        return sc.nr_reclaimed;
>  }
>
>  unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>                                           gfp_t gfp_mask,
> -                                          bool noswap)
> +                                          bool noswap,
> +                                          struct memcg_scanrecord *rec)
>  {
>        struct zonelist *zonelist;
>        unsigned long nr_reclaimed;
> +       unsigned long start, end;
>        int nid;
>        struct scan_control sc = {
>                .may_writepage = !laptop_mode,
> @@ -2259,6 +2269,7 @@ unsigned long try_to_free_mem_cgroup_pag
>                .gfp_mask = sc.gfp_mask,
>        };
>
> +       start = sched_clock();
>        /*
>         * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
>         * take care of from where we get pages. So the node where we start
> the
> @@ -2273,6 +2284,12 @@ unsigned long try_to_free_mem_cgroup_pag
>                                            sc.gfp_mask);
>
>        nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
> +       end = sched_clock();
> +       if (rec) {
> +               rec->nr_scanned += sc.nr_scanned;
>

sc.nr_scanned only contains the nr_scanned of last
priority do_try_to_free_pages(). we need to reset it to total_scanned before
return. I am looking at v3.0-rc3 .


> +               rec->nr_freed += sc.nr_reclaimed;
> +               rec->elappsed += end - start;
>
elapsed?

> +       }
>
>        trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
>
>
> --Ying

--00163649971d6f1b5504a6334269
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Jun 15, 2011 at 8:53 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
>From e08990dd9ada13cf236bec1ef44b207436434b8e Mon Sep 17 00:00:00 2001<br>
From: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.co=
m">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
Date: Wed, 15 Jun 2011 14:11:01 +0900<br>
Subject: [PATCH 3/7] memcg: add memory.scan_stat<br>
<br>
commit log of commit 0ae5e89 &quot; memcg: count the soft_limit reclaim in.=
..&quot;<br>
says it adds scanning stats to memory.stat file. But it doesn&#39;t because=
<br>
we considered we needed to make a concensus for such new APIs.<br>
<br>
This patch is a trial to add memory.scan_stat. This shows<br>
 =A0- the number of scanned pages<br>
 =A0- the number of recleimed pages<br>
 =A0- the number of elaplsed time (including sleep/pause time)<br>
 =A0for both of direct/soft reclaim and shrinking caused by changing limit<=
br>
 =A0or force_empty.<br>
<br>
The biggest difference with oringinal Ying&#39;s one is that this file<br>
can be reset by some write, as<br>
<br>
 =A0# echo 0 ...../memory.scan_stat<br>
<br>
[kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat<br>
scanned_pages_by_limit 358470<br>
freed_pages_by_limit 180795<br>
elapsed_ns_by_limit 21629927<br>
scanned_pages_by_system 0<br>
freed_pages_by_system 0<br>
elapsed_ns_by_system 0<br>
scanned_pages_by_shrink 76646<br>
freed_pages_by_shrink 38355<br>
elappsed_ns_by_shrink 31990670<br></blockquote><div><br></div><div>elapsed?=
</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
total_scanned_pages_by_limit 358470<br>
total_freed_pages_by_limit 180795<br>
total_elapsed_ns_by_hierarchical 216299275<br>
total_scanned_pages_by_system 0<br>
total_freed_pages_by_system 0<br>
total_elapsed_ns_by_system 0<br>
total_scanned_pages_by_shrink 76646<br>
total_freed_pages_by_shrink 38355<br>
total_elapsed_ns_by_shrink 31990670<br>
<br>
total_xxxx is for hierarchy management.<br></blockquote><div><br></div><div=
>For some reason, i feel the=A0opposite where the local stat (like &quot;sc=
anned_pages_by_limit&quot;) are reclaimed under hierarchical reclaim. The t=
otal_xxx stats are only incremented for root_mem which is the cgroup trigge=
rs the hierarchical reclaim. So:</div>
<div><br></div><div>total_scanned_pages_by_limit: number of pages being sca=
nned while the memcg hits its limit</div><div><meta charset=3D"utf-8">scann=
ed_pages_by_limit: number of pages being scanned while one of the memcg&#39=
;s=A0ancestor hits its limit</div>
<div><br></div><div>am i missing something?=A0</div><div>=A0=A0=A0</div><me=
ta charset=3D"utf-8"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
This will be useful for further memcg developments and need to be<br>
developped before we do some complicated rework on LRU/softlimit<br>
management.<br>
<br>
Now, scan/free/elapsed_by_system is incomplete but future works of<br>
Johannes at el. will fill remaining information and then, we can<br>
look into problems of isolation between memcgs.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0Documentation/cgroups/memory.txt | =A0 33 +++++++++<br>
=A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 16 ++++<br>
=A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 -<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0135 ++++++++++++=
+++++++++++++++++++++++++--<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 27 ++++++-<=
br>
=A05 files changed, 199 insertions(+), 18 deletions(-)<br>
<br>
Index: mmotm-0615/Documentation/cgroups/memory.txt<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0615.orig/Documentation/cgroups/memory.txt<br>
+++ mmotm-0615/Documentation/cgroups/memory.txt<br>
@@ -380,7 +380,7 @@ will be charged as a new owner of it.<br>
<br>
=A05.2 stat file<br>
<br>
-memory.stat file includes following statistics<br>
+5.2.1 memory.stat file includes following statistics<br>
<br>
=A0# per-memory cgroup local status<br>
=A0cache =A0 =A0 =A0 =A0 =A0- # of bytes of page cache memory.<br>
@@ -438,6 +438,37 @@ Note:<br>
 =A0 =A0 =A0 =A0 file_mapped is accounted only when the memory cgroup is ow=
ner of page<br>
 =A0 =A0 =A0 =A0 cache.)<br>
<br>
+5.2.2 memory.scan_stat<br>
+<br>
+memory.scan_stat includes statistics information for memory scanning and<b=
r>
+freeing, reclaiming. The statistics shows memory scanning information sinc=
e<br>
+memory cgroup creation and can be reset to 0 by writing 0 as<br>
+<br>
+ #echo 0 &gt; ../memory.scan_stat<br>
+<br>
+This file contains following statistics.<br>
+<br>
+scanned_pages_by_limit - # of scanned pages at hitting limit.<br>
+freed_pages_by_limit =A0 - # of freed pages at hitting limit.<br>
+elapsed_ns_by_limit =A0 =A0- nano sec of elappsed time at LRU scan at<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hittin=
g limit.(this includes sleep time.)<br></blockquote><meta charset=3D"utf-8"=
><div>elapsed?=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 =
0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

+<br>
+scanned_pages_by_system =A0 =A0 =A0 =A0- # of scanned pages by the kernel.=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (Now, this value means gl=
obal memory reclaim<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 caused by system memo=
ry shortage with a hint<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0of softlimit. &quot;No=
 soft limit&quot; case will be<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0supported in future.)<=
br>
+freed_pages_by_system =A0- # of freed pages by the kernel.<br>
+elapsed_ns_by_system =A0 - nano sec of elappsed time by kernel.<br>
+<br>
+scanned_pages_by_shrink =A0 =A0 =A0 =A0- # of scanned pages by shrinking.<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (i.e. cha=
nges of limit, force_empty, etc.)<br>
+freed_pages_by_shrink =A0- # of freed pages by shirkining.<br>
+elappsed_ns_by_shrink =A0- nano sec of elappsed time at shrinking.<br></bl=
ockquote><meta charset=3D"utf-8"><div>elapsed?=A0</div><blockquote class=3D=
"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding=
-left:1ex;">

+<br>
+total_xxx includes the statistics of children scanning caused by the cgrou=
p.<br></blockquote><div><br></div><div>based on the code inspection, the to=
tal_xxx also includes the cgroup&#39;s scan stat as well.</div><div><br>
</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex;">
+<br>
+<br>
=A05.3 swappiness<br>
<br>
=A0Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups =
only.<br>
Index: mmotm-0615/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0615.orig/include/linux/memcontrol.h<br>
+++ mmotm-0615/include/linux/memcontrol.h<br>
@@ -120,6 +120,22 @@ struct zone_reclaim_stat*<br>
=A0mem_cgroup_get_reclaim_stat_from_page(struct page *page);<br>
=A0extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct task_struct *p);<br>
+struct memcg_scanrecord {<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem; /* scanend memory cgroup */<br>
+ =A0 =A0 =A0 struct mem_cgroup *root; /* scan target hierarchy root */<br>
+ =A0 =A0 =A0 int context; =A0 =A0 =A0 =A0 =A0 =A0/* scanning context (see =
memcontrol.c) */<br>
+ =A0 =A0 =A0 unsigned long nr_scanned; /* the number of scanned pages */<b=
r>
+ =A0 =A0 =A0 unsigned long nr_freed; /* the number of freed pages */<br>
+ =A0 =A0 =A0 unsigned long elappsed; /* nsec of time elapsed while scannin=
g */<br></blockquote><meta charset=3D"utf-8"><div>elapsed?=A0</div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex;">

+};<br>
+<br>
+extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct memcg_scanrecord *rec);<br>
+extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct memcg_scanrecord *rec);<br>
<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
=A0extern int do_swap_account;<br>
Index: mmotm-0615/include/linux/swap.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0615.orig/include/linux/swap.h<br>
+++ mmotm-0615/include/linux/swap.h<br>
@@ -253,12 +253,6 @@ static inline void lru_cache_add_file(st<br>
=A0/* linux/mm/vmscan.c */<br>
=A0extern unsigned long try_to_free_pages(struct zonelist *zonelist, int or=
der,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask, nodemask_t *mask);<br>
-extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,<=
br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap);<br>
-extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,<b=
r>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned);<br>
=A0extern int __isolate_lru_page(struct page *page, int mode, int file);<br=
>
=A0extern unsigned long shrink_all_memory(unsigned long nr_pages);<br>
=A0extern int vm_swappiness;<br>
Index: mmotm-0615/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0615.orig/mm/memcontrol.c<br>
+++ mmotm-0615/mm/memcontrol.c<br>
@@ -203,6 +203,57 @@ struct mem_cgroup_eventfd_list {<br>
=A0static void mem_cgroup_threshold(struct mem_cgroup *mem);<br>
=A0static void mem_cgroup_oom_notify(struct mem_cgroup *mem);<br>
<br>
+enum {<br>
+ =A0 =A0 =A0 SCAN_BY_LIMIT,<br>
+ =A0 =A0 =A0 FREED_BY_LIMIT,<br>
+ =A0 =A0 =A0 ELAPSED_BY_LIMIT,<br>
+<br>
+ =A0 =A0 =A0 SCAN_BY_SYSTEM,<br>
+ =A0 =A0 =A0 FREED_BY_SYSTEM,<br>
+ =A0 =A0 =A0 ELAPSED_BY_SYSTEM,<br>
+<br>
+ =A0 =A0 =A0 SCAN_BY_SHRINK,<br>
+ =A0 =A0 =A0 FREED_BY_SHRINK,<br>
+ =A0 =A0 =A0 ELAPSED_BY_SHRINK,<br>
+ =A0 =A0 =A0 NR_SCANSTATS,<br>
+};<br>
+#define __FREED =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1)<br>
+#define =A0 =A0 =A0 =A0__ELAPSED =A0 =A0 =A0 (2)<br></blockquote><div><br>=
</div><div>/tab/space/</div><div>=A0</div><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
+<br>
+struct scanstat {<br>
+ =A0 =A0 =A0 spinlock_t =A0 =A0 =A0lock;<br>
+ =A0 =A0 =A0 unsigned long =A0 stats[NR_SCANSTATS]; =A0 =A0/* local statis=
tics */<br>
+ =A0 =A0 =A0 unsigned long =A0 totalstats[NR_SCANSTATS]; =A0 /* hierarchic=
al */<br>
+};<br>
+<br>
+const char *scanstat_string[NR_SCANSTATS] =3D {<br>
+ =A0 =A0 =A0 &quot;scanned_pages_by_limit&quot;,<br>
+ =A0 =A0 =A0 &quot;freed_pages_by_limit&quot;,<br>
+ =A0 =A0 =A0 &quot;elapsed_ns_by_limit&quot;,<br>
+<br>
+ =A0 =A0 =A0 &quot;scanned_pages_by_system&quot;,<br>
+ =A0 =A0 =A0 &quot;freed_pages_by_system&quot;,<br>
+ =A0 =A0 =A0 &quot;elapsed_ns_by_system&quot;,<br>
+<br>
+ =A0 =A0 =A0 &quot;scanned_pages_by_shrink&quot;,<br>
+ =A0 =A0 =A0 &quot;freed_pages_by_shrink&quot;,<br>
+ =A0 =A0 =A0 &quot;elappsed_ns_by_shrink&quot;,<br></blockquote><meta char=
set=3D"utf-8"><div>elapsed?=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
+};<br>
+<br>
+const char *total_scanstat_string[NR_SCANSTATS] =3D {<br>
+ =A0 =A0 =A0 &quot;total_scanned_pages_by_limit&quot;,<br>
+ =A0 =A0 =A0 &quot;total_freed_pages_by_limit&quot;,<br>
+ =A0 =A0 =A0 &quot;total_elapsed_ns_by_hierarchical&quot;,<br></blockquote=
><div><br></div><div>typo?</div><div>=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">
+<br>
+ =A0 =A0 =A0 &quot;total_scanned_pages_by_system&quot;,<br>
+ =A0 =A0 =A0 &quot;total_freed_pages_by_system&quot;,<br>
+ =A0 =A0 =A0 &quot;total_elapsed_ns_by_system&quot;,<br>
+<br>
+ =A0 =A0 =A0 &quot;total_scanned_pages_by_shrink&quot;,<br>
+ =A0 =A0 =A0 &quot;total_freed_pages_by_shrink&quot;,<br>
+ =A0 =A0 =A0 &quot;total_elapsed_ns_by_shrink&quot;,<br>
+};<br>
+<br>
=A0/*<br>
 =A0* The memory controller data structure. The memory controller controls =
both<br>
 =A0* page cache and RSS per cgroup. We would eventually like to provide<br=
>
@@ -264,7 +315,8 @@ struct mem_cgroup {<br>
<br>
 =A0 =A0 =A0 =A0/* For oom notifier event fd */<br>
 =A0 =A0 =A0 =A0struct list_head oom_notify;<br>
-<br>
+ =A0 =A0 =A0 /* For recording LRU-scan statistics */<br>
+ =A0 =A0 =A0 struct scanstat scanstat;<br>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * Should we move charges of a task when a task is moved in=
to this<br>
 =A0 =A0 =A0 =A0 * mem_cgroup ? And what type of charges should we move ?<b=
r>
@@ -1634,6 +1686,28 @@ int mem_cgroup_select_victim_node(struct<br>
=A0}<br>
=A0#endif<br>
<br>
+<br>
+<br>
+static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem;<br>
+ =A0 =A0 =A0 int context =3D rec-&gt;context;<br>
+<br>
+ =A0 =A0 =A0 mem =3D rec-&gt;mem;<br>
+ =A0 =A0 =A0 spin_lock(&amp;mem-&gt;scanstat.lock);<br>
+ =A0 =A0 =A0 mem-&gt;scanstat.stats[context] +=3D rec-&gt;nr_scanned;<br>
+ =A0 =A0 =A0 mem-&gt;scanstat.stats[context + __FREED] +=3D rec-&gt;nr_fre=
ed;<br>
+ =A0 =A0 =A0 mem-&gt;scanstat.stats[context + __ELAPSED] +=3D rec-&gt;elap=
psed;<br></blockquote><meta charset=3D"utf-8"><div>elapsed?=A0</div><div><b=
r></div><div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 =
0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

+ =A0 =A0 =A0 spin_unlock(&amp;mem-&gt;scanstat.lock);<br>
+<br>
+ =A0 =A0 =A0 mem =3D rec-&gt;root;<br>
+ =A0 =A0 =A0 spin_lock(&amp;mem-&gt;scanstat.lock);<br>
+ =A0 =A0 =A0 mem-&gt;scanstat.totalstats[context] +=3D rec-&gt;nr_scanned;=
<br>
+ =A0 =A0 =A0 mem-&gt;scanstat.totalstats[context + __FREED] +=3D rec-&gt;n=
r_freed;<br>
+ =A0 =A0 =A0 mem-&gt;scanstat.totalstats[context + __ELAPSED] +=3D rec-&gt=
;elappsed;<br></blockquote><div><br></div><meta charset=3D"utf-8"><div>elap=
sed?=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;b=
order-left:1px #ccc solid;padding-left:1ex;">

+ =A0 =A0 =A0 spin_unlock(&amp;mem-&gt;scanstat.lock);<br>
+}<br>
+<br>
=A0/*<br>
 =A0* Scan the hierarchy if needed to reclaim memory. We remember the last =
child<br>
 =A0* we reclaimed from, so that we don&#39;t end up penalizing one child e=
xtensively<br>
@@ -1659,8 +1733,8 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0bool shrink =3D reclaim_options &amp; MEM_CGROUP_RECLAIM_SH=
RINK;<br>
 =A0 =A0 =A0 =A0bool check_soft =3D reclaim_options &amp; MEM_CGROUP_RECLAI=
M_SOFT;<br>
 =A0 =A0 =A0 =A0unsigned long excess;<br>
- =A0 =A0 =A0 unsigned long nr_scanned;<br>
 =A0 =A0 =A0 =A0int visit;<br>
+ =A0 =A0 =A0 struct memcg_scanrecord rec;<br>
<br>
 =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&amp;root_mem-&gt;=
res) &gt;&gt; PAGE_SHIFT;<br>
<br>
@@ -1668,6 +1742,15 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0if (!check_soft &amp;&amp; root_mem-&gt;memsw_is_minimum)<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap =3D true;<br>
<br>
+ =A0 =A0 =A0 if (shrink)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.context =3D SCAN_BY_SHRINK;<br>
+ =A0 =A0 =A0 else if (check_soft)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.context =3D SCAN_BY_SYSTEM;<br>
+ =A0 =A0 =A0 else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.context =3D SCAN_BY_LIMIT;<br>
+<br>
+ =A0 =A0 =A0 rec.root =3D root_mem;<br></blockquote><div>=A0</div><div>=A0=
</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex;">
+<br>
=A0again:<br>
 =A0 =A0 =A0 =A0if (!shrink) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0visit =3D 0;<br>
@@ -1695,14 +1778,19 @@ again:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css=
);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.mem =3D victim;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_scanned =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_freed =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.elappsed =3D 0;<br></blockquote><meta cha=
rset=3D"utf-8"><div>elapsed?=A0</div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_n=
ode_zone(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, zone,=
 &amp;nr_scanned);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scanne=
d;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, zone,=
 &amp;rec);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D rec.nr_sc=
anned;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cgr=
oup_pages(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 noswap);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 noswap, &amp;rec);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_record_scanstat(&amp;rec);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total +=3D ret;<br>
@@ -3757,7 +3845,8 @@ try_to_free:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EINTR;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 progress =3D try_to_free_mem_cgroup_pages(mem=
, GFP_KERNEL, false);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 progress =3D try_to_free_mem_cgroup_pages(mem=
,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL, f=
alse, NULL);<br></blockquote><div><br></div><div>So we don&#39;t record the=
 stat for force_empty case?</div><div>=A0</div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x;">

 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!progress) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_retries--;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writeback is =
necessary */<br>
@@ -4599,6 +4688,34 @@ static int mem_control_numa_stat_open(st<br>
=A0}<br>
=A0#endif /* CONFIG_NUMA */<br>
<br>
+static int mem_cgroup_scan_stat_read(struct cgroup *cgrp,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cftype=
 *cft,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup=
_map_cb *cb)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);<br>
+ =A0 =A0 =A0 int i;<br>
+<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; NR_SCANSTATS; i++)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb-&gt;fill(cb, scanstat_string[i], mem-&gt;s=
canstat.stats[i]);<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; NR_SCANSTATS; i++)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb-&gt;fill(cb, total_scanstat_string[i],<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;scanstat.totalstats[i=
]);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+static int mem_cgroup_reset_scan_stat(struct cgroup *cgrp,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int =
event)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);<br>
+<br>
+ =A0 =A0 =A0 spin_lock(&amp;mem-&gt;scanstat.lock);<br>
+ =A0 =A0 =A0 memset(&amp;mem-&gt;scanstat.stats, 0, sizeof(mem-&gt;scansta=
t.stats));<br>
+ =A0 =A0 =A0 memset(&amp;mem-&gt;scanstat.totalstats, 0, sizeof(mem-&gt;sc=
anstat.totalstats));<br>
+ =A0 =A0 =A0 spin_unlock(&amp;mem-&gt;scanstat.lock);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+<br>
=A0static struct cftype mem_cgroup_files[] =3D {<br>
 =A0 =A0 =A0 =A0{<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D &quot;usage_in_bytes&quot;,<br>
@@ -4669,6 +4786,11 @@ static struct cftype mem_cgroup_files[]<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =3D S_IRUGO,<br>
 =A0 =A0 =A0 =A0},<br>
=A0#endif<br>
+ =A0 =A0 =A0 {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;scan_stat&quot;,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_scan_stat_read,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .trigger =3D mem_cgroup_reset_scan_stat,<br>
+ =A0 =A0 =A0 },<br>
=A0};<br>
<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
@@ -4932,6 +5054,7 @@ mem_cgroup_create(struct cgroup_subsys *<br>
 =A0 =A0 =A0 =A0atomic_set(&amp;mem-&gt;refcnt, 1);<br>
 =A0 =A0 =A0 =A0mem-&gt;move_charge_at_immigrate =3D 0;<br>
 =A0 =A0 =A0 =A0mutex_init(&amp;mem-&gt;thresholds_lock);<br>
+ =A0 =A0 =A0 spin_lock_init(&amp;mem-&gt;scanstat.lock);<br>
 =A0 =A0 =A0 =A0return &amp;mem-&gt;css;<br>
=A0free_out:<br>
 =A0 =A0 =A0 =A0__mem_cgroup_free(mem);<br>
Index: mmotm-0615/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0615.orig/mm/vmscan.c<br>
+++ mmotm-0615/mm/vmscan.c<br>
@@ -2199,9 +2199,9 @@ unsigned long try_to_free_pages(struct z<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
<br>
=A0unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 gfp_t gfp_mask, bool noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct memcg_scanrecord *rec)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct scan_control sc =3D {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_scanned =3D 0,<br>
@@ -2213,6 +2213,7 @@ unsigned long mem_cgroup_shrink_node_zon<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,<br>
 =A0 =A0 =A0 =A0};<br>
+ =A0 =A0 =A0 unsigned long start, end;<br>
<br>
 =A0 =A0 =A0 =A0sc.gfp_mask =3D (gfp_mask &amp; GFP_RECLAIM_MASK) |<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(GFP_HIGHUSER_MOVABLE &amp;=
 ~GFP_RECLAIM_MASK);<br>
@@ -2221,6 +2222,7 @@ unsigned long mem_cgroup_shrink_node_zon<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.may_writepage,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.gfp_mask);<br>
<br>
+ =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * NOTE: Although we can get the priority field, using it<b=
r>
 =A0 =A0 =A0 =A0 * here is not a good idea, since it limits the pages we ca=
n scan.<br>
@@ -2229,19 +2231,27 @@ unsigned long mem_cgroup_shrink_node_zon<br>
 =A0 =A0 =A0 =A0 * the priority and make it zero.<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0shrink_zone(0, zone, &amp;sc);<br>
+ =A0 =A0 =A0 end =3D sched_clock();<br>
+<br>
+ =A0 =A0 =A0 if (rec) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec-&gt;nr_scanned +=3D sc.nr_scanned;<br></b=
lockquote><div><br></div><div>=A0</div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec-&gt;nr_freed +=3D sc.nr_reclaimed;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec-&gt;elappsed +=3D end - start;<br></block=
quote><meta charset=3D"utf-8"><div>elapsed?=A0</div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex;">
+ =A0 =A0 =A0 }<br>
<br>
 =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed=
);<br>
<br>
- =A0 =A0 =A0 *nr_scanned =3D sc.nr_scanned;<br>
 =A0 =A0 =A0 =A0return sc.nr_reclaimed;<br>
=A0}<br>
<br>
=A0unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,<=
br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 gfp_t gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0bool noswap)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0bool noswap,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0struct memcg_scanrecord *rec)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct zonelist *zonelist;<br>
 =A0 =A0 =A0 =A0unsigned long nr_reclaimed;<br>
+ =A0 =A0 =A0 unsigned long start, end;<br>
 =A0 =A0 =A0 =A0int nid;<br>
 =A0 =A0 =A0 =A0struct scan_control sc =3D {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_writepage =3D !laptop_mode,<br>
@@ -2259,6 +2269,7 @@ unsigned long try_to_free_mem_cgroup_pag<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.gfp_mask =3D sc.gfp_mask,<br>
 =A0 =A0 =A0 =A0};<br>
<br>
+ =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * Unlike direct reclaim via alloc_pages(), memcg&#39;s rec=
laim doesn&#39;t<br>
 =A0 =A0 =A0 =A0 * take care of from where we get pages. So the node where =
we start the<br>
@@ -2273,6 +2284,12 @@ unsigned long try_to_free_mem_cgroup_pag<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0sc.gfp_mask);<br>
<br>
 =A0 =A0 =A0 =A0nr_reclaimed =3D do_try_to_free_pages(zonelist, &amp;sc, &a=
mp;shrink);<br>
+ =A0 =A0 =A0 end =3D sched_clock();<br>
+ =A0 =A0 =A0 if (rec) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec-&gt;nr_scanned +=3D sc.nr_scanned;<br>
</blockquote><div><br></div><meta charset=3D"utf-8"><div>sc.nr_scanned only=
 contains the nr_scanned of last priority=A0do_try_to_free_pages(). we need=
 to reset it to total_scanned before return. I am looking at=A0v3.0-rc3 .</=
div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">+ =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 rec-&gt;nr_freed +=3D sc.nr_reclaimed;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec-&gt;elappsed +=3D end - start;<br></block=
quote><meta charset=3D"utf-8"><div>elapsed?=A0</div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex;">
+ =A0 =A0 =A0 }<br>
<br>
 =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);<br>
<br>
<br></blockquote><div>--Ying=A0</div></div><br>

--00163649971d6f1b5504a6334269--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
