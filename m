Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA09B900154
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:27:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F1AEF3EE0C0
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:27:30 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4D0645DE93
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:27:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BC3C245DE91
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:27:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB1D61DB804B
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:27:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 65F181DB804A
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:27:30 +0900 (JST)
Date: Wed, 22 Jun 2011 09:20:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] memcg: add memory.scan_stat
Message-Id: <20110622092031.e4be1846.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTim-r6ejJK601rWq7smY37FC9um7mg@mail.gmail.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim-r6ejJK601rWq7smY37FC9um7mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Mon, 20 Jun 2011 23:49:54 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Jun 15, 2011 at 8:53 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > From e08990dd9ada13cf236bec1ef44b207436434b8e Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Wed, 15 Jun 2011 14:11:01 +0900
> > Subject: [PATCH 3/7] memcg: add memory.scan_stat
> >
> > commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim in..."
> > says it adds scanning stats to memory.stat file. But it doesn't because
> > we considered we needed to make a concensus for such new APIs.
> >
> > This patch is a trial to add memory.scan_stat. This shows
> >  - the number of scanned pages
> >  - the number of recleimed pages
> >  - the number of elaplsed time (including sleep/pause time)
> >  for both of direct/soft reclaim and shrinking caused by changing limit
> >  or force_empty.
> >
> > The biggest difference with oringinal Ying's one is that this file
> > can be reset by some write, as
> >
> >  # echo 0 ...../memory.scan_stat
> >
> > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> > scanned_pages_by_limit 358470
> > freed_pages_by_limit 180795
> > elapsed_ns_by_limit 21629927
> > scanned_pages_by_system 0
> > freed_pages_by_system 0
> > elapsed_ns_by_system 0
> > scanned_pages_by_shrink 76646
> > freed_pages_by_shrink 38355
> > elappsed_ns_by_shrink 31990670
> >
> 
> elapsed?
> 

you'r right.

> 
> > total_scanned_pages_by_limit 358470
> > total_freed_pages_by_limit 180795
> > total_elapsed_ns_by_hierarchical 216299275
> > total_scanned_pages_by_system 0
> > total_freed_pages_by_system 0
> > total_elapsed_ns_by_system 0
> > total_scanned_pages_by_shrink 76646
> > total_freed_pages_by_shrink 38355
> > total_elapsed_ns_by_shrink 31990670
> >
> > total_xxxx is for hierarchy management.
> >
> 
> For some reason, i feel the opposite where the local stat (like
> "scanned_pages_by_limit") are reclaimed under hierarchical reclaim. The
> total_xxx stats are only incremented for root_mem which is the cgroup
> triggers the hierarchical reclaim. So:
> 
> total_scanned_pages_by_limit: number of pages being scanned while the memcg
> hits its limit
> scanned_pages_by_limit: number of pages being scanned while one of the
> memcg's ancestor hits its limit
> 
> am i missing something?
> 

scanned_pages_by_limit: one of ancestors and itself's limit.




> 
> >
> > This will be useful for further memcg developments and need to be
> > developped before we do some complicated rework on LRU/softlimit
> > management.
> >
> > Now, scan/free/elapsed_by_system is incomplete but future works of
> > Johannes at el. will fill remaining information and then, we can
> > look into problems of isolation between memcgs.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  Documentation/cgroups/memory.txt |   33 +++++++++
> >  include/linux/memcontrol.h       |   16 ++++
> >  include/linux/swap.h             |    6 -
> >  mm/memcontrol.c                  |  135
> > +++++++++++++++++++++++++++++++++++++--
> >  mm/vmscan.c                      |   27 ++++++-
> >  5 files changed, 199 insertions(+), 18 deletions(-)
> >
> > Index: mmotm-0615/Documentation/cgroups/memory.txt
> > ===================================================================
> > --- mmotm-0615.orig/Documentation/cgroups/memory.txt
> > +++ mmotm-0615/Documentation/cgroups/memory.txt
> > @@ -380,7 +380,7 @@ will be charged as a new owner of it.
> >
> >  5.2 stat file
> >
> > -memory.stat file includes following statistics
> > +5.2.1 memory.stat file includes following statistics
> >
> >  # per-memory cgroup local status
> >  cache          - # of bytes of page cache memory.
> > @@ -438,6 +438,37 @@ Note:
> >         file_mapped is accounted only when the memory cgroup is owner of
> > page
> >         cache.)
> >
> > +5.2.2 memory.scan_stat
> > +
> > +memory.scan_stat includes statistics information for memory scanning and
> > +freeing, reclaiming. The statistics shows memory scanning information
> > since
> > +memory cgroup creation and can be reset to 0 by writing 0 as
> > +
> > + #echo 0 > ../memory.scan_stat
> > +
> > +This file contains following statistics.
> > +
> > +scanned_pages_by_limit - # of scanned pages at hitting limit.
> > +freed_pages_by_limit   - # of freed pages at hitting limit.
> > +elapsed_ns_by_limit    - nano sec of elappsed time at LRU scan at
> > +                                  hitting limit.(this includes sleep
> > time.)
> >
> elapsed?
> 
> > +
> > +scanned_pages_by_system        - # of scanned pages by the kernel.
> > +                         (Now, this value means global memory reclaim
> > +                           caused by system memory shortage with a hint
> > +                          of softlimit. "No soft limit" case will be
> > +                          supported in future.)
> > +freed_pages_by_system  - # of freed pages by the kernel.
> > +elapsed_ns_by_system   - nano sec of elappsed time by kernel.
> > +
> > +scanned_pages_by_shrink        - # of scanned pages by shrinking.
> > +                                 (i.e. changes of limit, force_empty,
> > etc.)
> > +freed_pages_by_shrink  - # of freed pages by shirkining.
> > +elappsed_ns_by_shrink  - nano sec of elappsed time at shrinking.
> >
> elapsed?
> 
> > +
> > +total_xxx includes the statistics of children scanning caused by the
> > cgroup.
> >
> 
> based on the code inspection, the total_xxx also includes the cgroup's scan
> stat as well.
> 

yes.


> +
> > +
> >  5.3 swappiness
> >
> >  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups
> > only.
> > Index: mmotm-0615/include/linux/memcontrol.h
> > ===================================================================
> > --- mmotm-0615.orig/include/linux/memcontrol.h
> > +++ mmotm-0615/include/linux/memcontrol.h
> > @@ -120,6 +120,22 @@ struct zone_reclaim_stat*
> >  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> >  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> >                                        struct task_struct *p);
> > +struct memcg_scanrecord {
> > +       struct mem_cgroup *mem; /* scanend memory cgroup */
> > +       struct mem_cgroup *root; /* scan target hierarchy root */
> > +       int context;            /* scanning context (see memcontrol.c) */
> > +       unsigned long nr_scanned; /* the number of scanned pages */
> > +       unsigned long nr_freed; /* the number of freed pages */
> > +       unsigned long elappsed; /* nsec of time elapsed while scanning */
> >
> elapsed?
> 
> > +};
> > +
> > +extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
> > +                                                 gfp_t gfp_mask, bool
> > noswap,
> > +                                                 struct memcg_scanrecord
> > *rec);
> > +extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> > +                                               gfp_t gfp_mask, bool
> > noswap,
> > +                                               struct zone *zone,
> > +                                               struct memcg_scanrecord
> > *rec);
> >
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  extern int do_swap_account;
> > Index: mmotm-0615/include/linux/swap.h
> > ===================================================================
> > --- mmotm-0615.orig/include/linux/swap.h
> > +++ mmotm-0615/include/linux/swap.h
> > @@ -253,12 +253,6 @@ static inline void lru_cache_add_file(st
> >  /* linux/mm/vmscan.c */
> >  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int
> > order,
> >                                        gfp_t gfp_mask, nodemask_t *mask);
> > -extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
> > -                                                 gfp_t gfp_mask, bool
> > noswap);
> > -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> > -                                               gfp_t gfp_mask, bool
> > noswap,
> > -                                               struct zone *zone,
> > -                                               unsigned long *nr_scanned);
> >  extern int __isolate_lru_page(struct page *page, int mode, int file);
> >  extern unsigned long shrink_all_memory(unsigned long nr_pages);
> >  extern int vm_swappiness;
> > Index: mmotm-0615/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0615.orig/mm/memcontrol.c
> > +++ mmotm-0615/mm/memcontrol.c
> > @@ -203,6 +203,57 @@ struct mem_cgroup_eventfd_list {
> >  static void mem_cgroup_threshold(struct mem_cgroup *mem);
> >  static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
> >
> > +enum {
> > +       SCAN_BY_LIMIT,
> > +       FREED_BY_LIMIT,
> > +       ELAPSED_BY_LIMIT,
> > +
> > +       SCAN_BY_SYSTEM,
> > +       FREED_BY_SYSTEM,
> > +       ELAPSED_BY_SYSTEM,
> > +
> > +       SCAN_BY_SHRINK,
> > +       FREED_BY_SHRINK,
> > +       ELAPSED_BY_SHRINK,
> > +       NR_SCANSTATS,
> > +};
> > +#define __FREED                (1)
> > +#define        __ELAPSED       (2)
> >
> 
> /tab/space/
> 
> 
> > +
> > +struct scanstat {
> > +       spinlock_t      lock;
> > +       unsigned long   stats[NR_SCANSTATS];    /* local statistics */
> > +       unsigned long   totalstats[NR_SCANSTATS];   /* hierarchical */
> > +};
> > +
> > +const char *scanstat_string[NR_SCANSTATS] = {
> > +       "scanned_pages_by_limit",
> > +       "freed_pages_by_limit",
> > +       "elapsed_ns_by_limit",
> > +
> > +       "scanned_pages_by_system",
> > +       "freed_pages_by_system",
> > +       "elapsed_ns_by_system",
> > +
> > +       "scanned_pages_by_shrink",
> > +       "freed_pages_by_shrink",
> > +       "elappsed_ns_by_shrink",
> >
> elapsed?
> 
> > +};
> > +
> > +const char *total_scanstat_string[NR_SCANSTATS] = {
> > +       "total_scanned_pages_by_limit",
> > +       "total_freed_pages_by_limit",
> > +       "total_elapsed_ns_by_hierarchical",
> >
> 
> typo?
> 
> 
> > +
> > +       "total_scanned_pages_by_system",
> > +       "total_freed_pages_by_system",
> > +       "total_elapsed_ns_by_system",
> > +
> > +       "total_scanned_pages_by_shrink",
> > +       "total_freed_pages_by_shrink",
> > +       "total_elapsed_ns_by_shrink",
> > +};
> > +
> >  /*
> >  * The memory controller data structure. The memory controller controls
> > both
> >  * page cache and RSS per cgroup. We would eventually like to provide
> > @@ -264,7 +315,8 @@ struct mem_cgroup {
> >
> >        /* For oom notifier event fd */
> >        struct list_head oom_notify;
> > -
> > +       /* For recording LRU-scan statistics */
> > +       struct scanstat scanstat;
> >        /*
> >         * Should we move charges of a task when a task is moved into this
> >         * mem_cgroup ? And what type of charges should we move ?
> > @@ -1634,6 +1686,28 @@ int mem_cgroup_select_victim_node(struct
> >  }
> >  #endif
> >
> > +
> > +
> > +static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
> > +{
> > +       struct mem_cgroup *mem;
> > +       int context = rec->context;
> > +
> > +       mem = rec->mem;
> > +       spin_lock(&mem->scanstat.lock);
> > +       mem->scanstat.stats[context] += rec->nr_scanned;
> > +       mem->scanstat.stats[context + __FREED] += rec->nr_freed;
> > +       mem->scanstat.stats[context + __ELAPSED] += rec->elappsed;
> >
> elapsed?
> 
> 
> +       spin_unlock(&mem->scanstat.lock);
> > +
> > +       mem = rec->root;
> > +       spin_lock(&mem->scanstat.lock);
> > +       mem->scanstat.totalstats[context] += rec->nr_scanned;
> > +       mem->scanstat.totalstats[context + __FREED] += rec->nr_freed;
> > +       mem->scanstat.totalstats[context + __ELAPSED] += rec->elappsed;
> >
> 
> elapsed?
> 
> > +       spin_unlock(&mem->scanstat.lock);
> > +}
> > +
> >  /*
> >  * Scan the hierarchy if needed to reclaim memory. We remember the last
> > child
> >  * we reclaimed from, so that we don't end up penalizing one child
> > extensively
> > @@ -1659,8 +1733,8 @@ static int mem_cgroup_hierarchical_recla
> >        bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
> >        bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
> >        unsigned long excess;
> > -       unsigned long nr_scanned;
> >        int visit;
> > +       struct memcg_scanrecord rec;
> >
> >        excess = res_counter_soft_limit_excess(&root_mem->res) >>
> > PAGE_SHIFT;
> >
> > @@ -1668,6 +1742,15 @@ static int mem_cgroup_hierarchical_recla
> >        if (!check_soft && root_mem->memsw_is_minimum)
> >                noswap = true;
> >
> > +       if (shrink)
> > +               rec.context = SCAN_BY_SHRINK;
> > +       else if (check_soft)
> > +               rec.context = SCAN_BY_SYSTEM;
> > +       else
> > +               rec.context = SCAN_BY_LIMIT;
> > +
> > +       rec.root = root_mem;
> >
> 
> 
> 
> > +
> >  again:
> >        if (!shrink) {
> >                visit = 0;
> > @@ -1695,14 +1778,19 @@ again:
> >                        css_put(&victim->css);
> >                        continue;
> >                }
> > +               rec.mem = victim;
> > +               rec.nr_scanned = 0;
> > +               rec.nr_freed = 0;
> > +               rec.elappsed = 0;
> >
> elapsed?
> 
> >                /* we use swappiness of local cgroup */
> >                if (check_soft) {
> >                        ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> > -                               noswap, zone, &nr_scanned);
> > -                       *total_scanned += nr_scanned;
> > +                               noswap, zone, &rec);
> > +                       *total_scanned += rec.nr_scanned;
> >                } else
> >                        ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> > -                                               noswap);
> > +                                               noswap, &rec);
> > +               mem_cgroup_record_scanstat(&rec);
> >                css_put(&victim->css);
> >
> >                total += ret;
> > @@ -3757,7 +3845,8 @@ try_to_free:
> >                        ret = -EINTR;
> >                        goto out;
> >                }
> > -               progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> > false);
> > +               progress = try_to_free_mem_cgroup_pages(mem,
> > +                               GFP_KERNEL, false, NULL);
> >
> 
> So we don't record the stat for force_empty case?
> 

yes, now. force_empty is used only for rmdir(). I don't think log is
necessary for cgroup disappearing.


> 
> >                if (!progress) {
> >                        nr_retries--;
> >                        /* maybe some writeback is necessary */
> > @@ -4599,6 +4688,34 @@ static int mem_control_numa_stat_open(st
> >  }
> >  #endif /* CONFIG_NUMA */
> >
> > +static int mem_cgroup_scan_stat_read(struct cgroup *cgrp,
> > +                               struct cftype *cft,
> > +                               struct cgroup_map_cb *cb)
> > +{
> > +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> > +       int i;
> > +
> > +       for (i = 0; i < NR_SCANSTATS; i++)
> > +               cb->fill(cb, scanstat_string[i], mem->scanstat.stats[i]);
> > +       for (i = 0; i < NR_SCANSTATS; i++)
> > +               cb->fill(cb, total_scanstat_string[i],
> > +                       mem->scanstat.totalstats[i]);
> > +       return 0;
> > +}
> > +
> > +static int mem_cgroup_reset_scan_stat(struct cgroup *cgrp,
> > +                               unsigned int event)
> > +{
> > +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> > +
> > +       spin_lock(&mem->scanstat.lock);
> > +       memset(&mem->scanstat.stats, 0, sizeof(mem->scanstat.stats));
> > +       memset(&mem->scanstat.totalstats, 0,
> > sizeof(mem->scanstat.totalstats));
> > +       spin_unlock(&mem->scanstat.lock);
> > +       return 0;
> > +}
> > +
> > +
> >  static struct cftype mem_cgroup_files[] = {
> >        {
> >                .name = "usage_in_bytes",
> > @@ -4669,6 +4786,11 @@ static struct cftype mem_cgroup_files[]
> >                .mode = S_IRUGO,
> >        },
> >  #endif
> > +       {
> > +               .name = "scan_stat",
> > +               .read_map = mem_cgroup_scan_stat_read,
> > +               .trigger = mem_cgroup_reset_scan_stat,
> > +       },
> >  };
> >
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > @@ -4932,6 +5054,7 @@ mem_cgroup_create(struct cgroup_subsys *
> >        atomic_set(&mem->refcnt, 1);
> >        mem->move_charge_at_immigrate = 0;
> >        mutex_init(&mem->thresholds_lock);
> > +       spin_lock_init(&mem->scanstat.lock);
> >        return &mem->css;
> >  free_out:
> >        __mem_cgroup_free(mem);
> > Index: mmotm-0615/mm/vmscan.c
> > ===================================================================
> > --- mmotm-0615.orig/mm/vmscan.c
> > +++ mmotm-0615/mm/vmscan.c
> > @@ -2199,9 +2199,9 @@ unsigned long try_to_free_pages(struct z
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >
> >  unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> > -                                               gfp_t gfp_mask, bool
> > noswap,
> > -                                               struct zone *zone,
> > -                                               unsigned long *nr_scanned)
> > +                                       gfp_t gfp_mask, bool noswap,
> > +                                       struct zone *zone,
> > +                                       struct memcg_scanrecord *rec)
> >  {
> >        struct scan_control sc = {
> >                .nr_scanned = 0,
> > @@ -2213,6 +2213,7 @@ unsigned long mem_cgroup_shrink_node_zon
> >                .order = 0,
> >                .mem_cgroup = mem,
> >        };
> > +       unsigned long start, end;
> >
> >        sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> >                        (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> > @@ -2221,6 +2222,7 @@ unsigned long mem_cgroup_shrink_node_zon
> >                                                      sc.may_writepage,
> >                                                      sc.gfp_mask);
> >
> > +       start = sched_clock();
> >        /*
> >         * NOTE: Although we can get the priority field, using it
> >         * here is not a good idea, since it limits the pages we can scan.
> > @@ -2229,19 +2231,27 @@ unsigned long mem_cgroup_shrink_node_zon
> >         * the priority and make it zero.
> >         */
> >        shrink_zone(0, zone, &sc);
> > +       end = sched_clock();
> > +
> > +       if (rec) {
> > +               rec->nr_scanned += sc.nr_scanned;
> >
> 
> 
> 
> > +               rec->nr_freed += sc.nr_reclaimed;
> > +               rec->elappsed += end - start;
> >
> elapsed?
> 
> > +       }
> >
> >        trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
> >
> > -       *nr_scanned = sc.nr_scanned;
> >        return sc.nr_reclaimed;
> >  }
> >
> >  unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> >                                           gfp_t gfp_mask,
> > -                                          bool noswap)
> > +                                          bool noswap,
> > +                                          struct memcg_scanrecord *rec)
> >  {
> >        struct zonelist *zonelist;
> >        unsigned long nr_reclaimed;
> > +       unsigned long start, end;
> >        int nid;
> >        struct scan_control sc = {
> >                .may_writepage = !laptop_mode,
> > @@ -2259,6 +2269,7 @@ unsigned long try_to_free_mem_cgroup_pag
> >                .gfp_mask = sc.gfp_mask,
> >        };
> >
> > +       start = sched_clock();
> >        /*
> >         * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
> >         * take care of from where we get pages. So the node where we start
> > the
> > @@ -2273,6 +2284,12 @@ unsigned long try_to_free_mem_cgroup_pag
> >                                            sc.gfp_mask);
> >
> >        nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
> > +       end = sched_clock();
> > +       if (rec) {
> > +               rec->nr_scanned += sc.nr_scanned;
> >
> 
> sc.nr_scanned only contains the nr_scanned of last
> priority do_try_to_free_pages(). we need to reset it to total_scanned before
> return. I am looking at v3.0-rc3 .
> 

Hm. ok, then, total_reclaimed in softlimit is buggy, too.
I'll check.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
