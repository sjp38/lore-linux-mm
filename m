Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 461396B0101
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 17:00:42 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p6IL0awe027251
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 14:00:36 -0700
Received: from gyd12 (gyd12.prod.google.com [10.243.49.204])
	by kpbe13.cbf.corp.google.com with ESMTP id p6IKxinq006003
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 14:00:35 -0700
Received: by gyd12 with SMTP id 12so1681633gyd.20
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 14:00:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110711193036.5a03858d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110711193036.5a03858d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 18 Jul 2011 14:00:32 -0700
Message-ID: <CAL1qeaGC51POaL7PW9LK7Ke6CZt-hE8qJ3QSHu+2jaermCjuKQ@mail.gmail.com>
Subject: Re: [PATCH v2] memcg: add vmscan_stat
From: Andrew Bresticker <abrestic@google.com>
Content-Type: multipart/alternative; boundary=001636b2b08233a65604a85e4ab6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

--001636b2b08233a65604a85e4ab6
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Jul 11, 2011 at 3:30 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> This patch is onto mmotm-0710... got bigger than expected ;(
> ==
> [PATCH] add memory.vmscan_stat
>
> commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim in..."
> says it adds scanning stats to memory.stat file. But it doesn't because
> we considered we needed to make a concensus for such new APIs.
>
> This patch is a trial to add memory.scan_stat. This shows
>  - the number of scanned pages(total, anon, file)
>  - the number of rotated pages(total, anon, file)
>  - the number of freed pages(total, anon, file)
>  - the number of elaplsed time (including sleep/pause time)
>
>  for both of direct/soft reclaim.
>
> The biggest difference with oringinal Ying's one is that this file
> can be reset by some write, as
>
>  # echo 0 ...../memory.scan_stat
>
> Example of output is here. This is a result after make -j 6 kernel
> under 300M limit.
>
> [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.vmscan_stat
> scanned_pages_by_limit 9471864
> scanned_anon_pages_by_limit 6640629
> scanned_file_pages_by_limit 2831235
> rotated_pages_by_limit 4243974
> rotated_anon_pages_by_limit 3971968
> rotated_file_pages_by_limit 272006
> freed_pages_by_limit 2318492
> freed_anon_pages_by_limit 962052
> freed_file_pages_by_limit 1356440
> elapsed_ns_by_limit 351386416101
> scanned_pages_by_system 0
> scanned_anon_pages_by_system 0
> scanned_file_pages_by_system 0
> rotated_pages_by_system 0
> rotated_anon_pages_by_system 0
> rotated_file_pages_by_system 0
> freed_pages_by_system 0
> freed_anon_pages_by_system 0
> freed_file_pages_by_system 0
> elapsed_ns_by_system 0
> scanned_pages_by_limit_under_hierarchy 9471864
> scanned_anon_pages_by_limit_under_hierarchy 6640629
> scanned_file_pages_by_limit_under_hierarchy 2831235
> rotated_pages_by_limit_under_hierarchy 4243974
> rotated_anon_pages_by_limit_under_hierarchy 3971968
> rotated_file_pages_by_limit_under_hierarchy 272006
> freed_pages_by_limit_under_hierarchy 2318492
> freed_anon_pages_by_limit_under_hierarchy 962052
> freed_file_pages_by_limit_under_hierarchy 1356440
> elapsed_ns_by_limit_under_hierarchy 351386416101
> scanned_pages_by_system_under_hierarchy 0
> scanned_anon_pages_by_system_under_hierarchy 0
> scanned_file_pages_by_system_under_hierarchy 0
> rotated_pages_by_system_under_hierarchy 0
> rotated_anon_pages_by_system_under_hierarchy 0
> rotated_file_pages_by_system_under_hierarchy 0
> freed_pages_by_system_under_hierarchy 0
> freed_anon_pages_by_system_under_hierarchy 0
> freed_file_pages_by_system_under_hierarchy 0
> elapsed_ns_by_system_under_hierarchy 0
>
>
> total_xxxx is for hierarchy management.
>
> This will be useful for further memcg developments and need to be
> developped before we do some complicated rework on LRU/softlimit
> management.
>
> This patch adds a new struct memcg_scanrecord into scan_control struct.
> sc->nr_scanned at el is not designed for exporting information. For
> example,
> nr_scanned is reset frequentrly and incremented +2 at scanning mapped
> pages.
>
> For avoiding complexity, I added a new param in scan_control which is for
> exporting scanning score.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Changelog:
>  - renamed as vmscan_stat
>  - handle file/anon
>  - added "rotated"
>  - changed names of param in vmscan_stat.
> ---
>  Documentation/cgroups/memory.txt |   85 +++++++++++++++++++
>  include/linux/memcontrol.h       |   19 ++++
>  include/linux/swap.h             |    6 -
>  mm/memcontrol.c                  |  172
> +++++++++++++++++++++++++++++++++++++--
>  mm/vmscan.c                      |   39 +++++++-
>  5 files changed, 303 insertions(+), 18 deletions(-)
>
> Index: mmotm-0710/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-0710.orig/Documentation/cgroups/memory.txt
> +++ mmotm-0710/Documentation/cgroups/memory.txt
> @@ -380,7 +380,7 @@ will be charged as a new owner of it.
>
>  5.2 stat file
>
> -memory.stat file includes following statistics
> +5.2.1 memory.stat file includes following statistics
>
>  # per-memory cgroup local status
>  cache          - # of bytes of page cache memory.
> @@ -438,6 +438,89 @@ Note:
>         file_mapped is accounted only when the memory cgroup is owner of
> page
>         cache.)
>
> +5.2.2 memory.vmscan_stat
> +
> +memory.vmscan_stat includes statistics information for memory scanning and
> +freeing, reclaiming. The statistics shows memory scanning information
> since
> +memory cgroup creation and can be reset to 0 by writing 0 as
> +
> + #echo 0 > ../memory.vmscan_stat
> +
> +This file contains following statistics.
> +
> +[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]
> +[param]_elapsed_ns_by_[reason]_[under_hierarchy]
> +
> +For example,
> +
> +  scanned_file_pages_by_limit indicates the number of scanned
> +  file pages at vmscan.
> +
> +Now, 3 parameters are supported
> +
> +  scanned - the number of pages scanned by vmscan
> +  rotated - the number of pages activated at vmscan
> +  freed   - the number of pages freed by vmscan
> +
> +If "rotated" is high against scanned/freed, the memcg seems busy.
> +
> +Now, 2 reason are supported
> +
> +  limit - the memory cgroup's limit
> +  system - global memory pressure + softlimit
> +           (global memory pressure not under softlimit is not handled now)
> +
> +When under_hierarchy is added in the tail, the number indicates the
> +total memcg scan of its children and itself.
> +
> +elapsed_ns is a elapsed time in nanosecond. This may include sleep time
> +and not indicates CPU usage. So, please take this as just showing
> +latency.
> +
> +Here is an example.
> +
> +# cat /cgroup/memory/A/memory.vmscan_stat
> +scanned_pages_by_limit 9471864
> +scanned_anon_pages_by_limit 6640629
> +scanned_file_pages_by_limit 2831235
> +rotated_pages_by_limit 4243974
> +rotated_anon_pages_by_limit 3971968
> +rotated_file_pages_by_limit 272006
> +freed_pages_by_limit 2318492
> +freed_anon_pages_by_limit 962052
> +freed_file_pages_by_limit 1356440
> +elapsed_ns_by_limit 351386416101
> +scanned_pages_by_system 0
> +scanned_anon_pages_by_system 0
> +scanned_file_pages_by_system 0
> +rotated_pages_by_system 0
> +rotated_anon_pages_by_system 0
> +rotated_file_pages_by_system 0
> +freed_pages_by_system 0
> +freed_anon_pages_by_system 0
> +freed_file_pages_by_system 0
> +elapsed_ns_by_system 0
> +scanned_pages_by_limit_under_hierarchy 9471864
> +scanned_anon_pages_by_limit_under_hierarchy 6640629
> +scanned_file_pages_by_limit_under_hierarchy 2831235
> +rotated_pages_by_limit_under_hierarchy 4243974
> +rotated_anon_pages_by_limit_under_hierarchy 3971968
> +rotated_file_pages_by_limit_under_hierarchy 272006
> +freed_pages_by_limit_under_hierarchy 2318492
> +freed_anon_pages_by_limit_under_hierarchy 962052
> +freed_file_pages_by_limit_under_hierarchy 1356440
> +elapsed_ns_by_limit_under_hierarchy 351386416101
> +scanned_pages_by_system_under_hierarchy 0
> +scanned_anon_pages_by_system_under_hierarchy 0
> +scanned_file_pages_by_system_under_hierarchy 0
> +rotated_pages_by_system_under_hierarchy 0
> +rotated_anon_pages_by_system_under_hierarchy 0
> +rotated_file_pages_by_system_under_hierarchy 0
> +freed_pages_by_system_under_hierarchy 0
> +freed_anon_pages_by_system_under_hierarchy 0
> +freed_file_pages_by_system_under_hierarchy 0
> +elapsed_ns_by_system_under_hierarchy 0
> +
>  5.3 swappiness
>
>  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups
> only.
> Index: mmotm-0710/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-0710.orig/include/linux/memcontrol.h
> +++ mmotm-0710/include/linux/memcontrol.h
> @@ -39,6 +39,16 @@ extern unsigned long mem_cgroup_isolate_
>                                        struct mem_cgroup *mem_cont,
>                                        int active, int file);
>
> +struct memcg_scanrecord {
> +       struct mem_cgroup *mem; /* scanend memory cgroup */
> +       struct mem_cgroup *root; /* scan target hierarchy root */
> +       int context;            /* scanning context (see memcontrol.c) */
> +       unsigned long nr_scanned[2]; /* the number of scanned pages */
> +       unsigned long nr_rotated[2]; /* the number of rotated pages */
> +       unsigned long nr_freed[2]; /* the number of freed pages */
> +       unsigned long elapsed; /* nsec of time elapsed while scanning */
> +};
> +
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  /*
>  * All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -117,6 +127,15 @@ mem_cgroup_get_reclaim_stat_from_page(st
>  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>                                        struct task_struct *p);
>
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
> *rec,
> +                                               unsigned long *nr_scanned);
> +
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern int do_swap_account;
>  #endif
> Index: mmotm-0710/include/linux/swap.h
> ===================================================================
> --- mmotm-0710.orig/include/linux/swap.h
> +++ mmotm-0710/include/linux/swap.h
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
> Index: mmotm-0710/mm/memcontrol.c
> ===================================================================
> --- mmotm-0710.orig/mm/memcontrol.c
> +++ mmotm-0710/mm/memcontrol.c
> @@ -204,6 +204,50 @@ struct mem_cgroup_eventfd_list {
>  static void mem_cgroup_threshold(struct mem_cgroup *mem);
>  static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
>
> +enum {
> +       SCAN_BY_LIMIT,
> +       SCAN_BY_SYSTEM,
> +       NR_SCAN_CONTEXT,
> +       SCAN_BY_SHRINK, /* not recorded now */
> +};
> +
> +enum {
> +       SCAN,
> +       SCAN_ANON,
> +       SCAN_FILE,
> +       ROTATE,
> +       ROTATE_ANON,
> +       ROTATE_FILE,
> +       FREED,
> +       FREED_ANON,
> +       FREED_FILE,
> +       ELAPSED,
> +       NR_SCANSTATS,
> +};
> +
> +struct scanstat {
> +       spinlock_t      lock;
> +       unsigned long   stats[NR_SCAN_CONTEXT][NR_SCANSTATS];
> +       unsigned long   rootstats[NR_SCAN_CONTEXT][NR_SCANSTATS];
> +};
> +
> +const char *scanstat_string[NR_SCANSTATS] = {
> +       "scanned_pages",
> +       "scanned_anon_pages",
> +       "scanned_file_pages",
> +       "rotated_pages",
> +       "rotated_anon_pages",
> +       "rotated_file_pages",
> +       "freed_pages",
> +       "freed_anon_pages",
> +       "freed_file_pages",
> +       "elapsed_ns",
> +};
> +#define SCANSTAT_WORD_LIMIT    "_by_limit"
> +#define SCANSTAT_WORD_SYSTEM   "_by_system"
> +#define SCANSTAT_WORD_HIERARCHY        "_under_hierarchy"
> +
> +
>  /*
>  * The memory controller data structure. The memory controller controls
> both
>  * page cache and RSS per cgroup. We would eventually like to provide
> @@ -266,7 +310,8 @@ struct mem_cgroup {
>
>        /* For oom notifier event fd */
>        struct list_head oom_notify;
> -
> +       /* For recording LRU-scan statistics */
> +       struct scanstat scanstat;
>        /*
>         * Should we move charges of a task when a task is moved into this
>         * mem_cgroup ? And what type of charges should we move ?
> @@ -1619,6 +1664,44 @@ bool mem_cgroup_reclaimable(struct mem_c
>  }
>  #endif
>
> +static void __mem_cgroup_record_scanstat(unsigned long *stats,
> +                          struct memcg_scanrecord *rec)
> +{
> +
> +       stats[SCAN] += rec->nr_scanned[0] + rec->nr_scanned[1];
> +       stats[SCAN_ANON] += rec->nr_scanned[0];
> +       stats[SCAN_FILE] += rec->nr_scanned[1];
> +
> +       stats[ROTATE] += rec->nr_rotated[0] + rec->nr_rotated[1];
> +       stats[ROTATE_ANON] += rec->nr_rotated[0];
> +       stats[ROTATE_FILE] += rec->nr_rotated[1];
> +
> +       stats[FREED] += rec->nr_freed[0] + rec->nr_freed[1];
> +       stats[FREED_ANON] += rec->nr_freed[0];
> +       stats[FREED_FILE] += rec->nr_freed[1];
> +
> +       stats[ELAPSED] += rec->elapsed;
> +}
> +
> +static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
> +{
> +       struct mem_cgroup *mem;
> +       int context = rec->context;
> +
> +       if (context >= NR_SCAN_CONTEXT)
> +               return;
> +
> +       mem = rec->mem;
> +       spin_lock(&mem->scanstat.lock);
> +       __mem_cgroup_record_scanstat(mem->scanstat.stats[context], rec);
> +       spin_unlock(&mem->scanstat.lock);
> +
> +       mem = rec->root;
> +       spin_lock(&mem->scanstat.lock);
> +       __mem_cgroup_record_scanstat(mem->scanstat.rootstats[context],
> rec);
> +       spin_unlock(&mem->scanstat.lock);
> +}
> +
>  /*
>  * Scan the hierarchy if needed to reclaim memory. We remember the last
> child
>  * we reclaimed from, so that we don't end up penalizing one child
> extensively
> @@ -1643,8 +1726,9 @@ static int mem_cgroup_hierarchical_recla
>        bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
>        bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
>        bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
> +       struct memcg_scanrecord rec;
>        unsigned long excess;
> -       unsigned long nr_scanned;
> +       unsigned long scanned;
>
>        excess = res_counter_soft_limit_excess(&root_mem->res) >>
> PAGE_SHIFT;
>
> @@ -1652,6 +1736,15 @@ static int mem_cgroup_hierarchical_recla
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
> +
>        while (1) {
>                victim = mem_cgroup_select_victim(root_mem);
>                if (victim == root_mem) {
> @@ -1692,14 +1785,23 @@ static int mem_cgroup_hierarchical_recla
>                        css_put(&victim->css);
>                        continue;
>                }
> +               rec.mem = victim;
> +               rec.nr_scanned[0] = 0;
> +               rec.nr_scanned[1] = 0;
> +               rec.nr_rotated[0] = 0;
> +               rec.nr_rotated[1] = 0;
> +               rec.nr_freed[0] = 0;
> +               rec.nr_freed[1] = 0;
> +               rec.elapsed = 0;
>                /* we use swappiness of local cgroup */
>                if (check_soft) {
>                        ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> -                               noswap, zone, &nr_scanned);
> -                       *total_scanned += nr_scanned;
> +                               noswap, zone, &rec, &scanned);
> +                       *total_scanned += scanned;
>                } else
>                        ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> -                                               noswap);
> +                                               noswap, &rec);
> +               mem_cgroup_record_scanstat(&rec);
>                css_put(&victim->css);
>                /*
>                 * At shrinking usage, we can't check we should stop here or
> @@ -3688,14 +3790,18 @@ try_to_free:
>        /* try to free all pages in this cgroup */
>        shrink = 1;
>        while (nr_retries && mem->res.usage > 0) {
> +               struct memcg_scanrecord rec;
>                int progress;
>
>                if (signal_pending(current)) {
>                        ret = -EINTR;
>                        goto out;
>                }
> +               rec.context = SCAN_BY_SHRINK;
> +               rec.mem = mem;
> +               rec.root = mem;
>                progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> -                                               false);
> +                                               false, &rec);
>                if (!progress) {
>                        nr_retries--;
>                        /* maybe some writeback is necessary */
> @@ -4539,6 +4645,54 @@ static int mem_control_numa_stat_open(st
>  }
>  #endif /* CONFIG_NUMA */
>
> +static int mem_cgroup_vmscan_stat_read(struct cgroup *cgrp,
> +                               struct cftype *cft,
> +                               struct cgroup_map_cb *cb)
> +{
> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +       char string[64];
> +       int i;
> +
> +       for (i = 0; i < NR_SCANSTATS; i++) {
> +               strcpy(string, scanstat_string[i]);
> +               strcat(string, SCANSTAT_WORD_LIMIT);
> +               cb->fill(cb, string,
>  mem->scanstat.stats[SCAN_BY_LIMIT][i]);
> +       }
> +
> +       for (i = 0; i < NR_SCANSTATS; i++) {
> +               strcpy(string, scanstat_string[i]);
> +               strcat(string, SCANSTAT_WORD_SYSTEM);
> +               cb->fill(cb, string,
>  mem->scanstat.stats[SCAN_BY_SYSTEM][i]);
> +       }
> +
> +       for (i = 0; i < NR_SCANSTATS; i++) {
> +               strcpy(string, scanstat_string[i]);
> +               strcat(string, SCANSTAT_WORD_LIMIT);
> +               strcat(string, SCANSTAT_WORD_HIERARCHY);
> +               cb->fill(cb, string,
>  mem->scanstat.rootstats[SCAN_BY_LIMIT][i]);
> +       }
> +       for (i = 0; i < NR_SCANSTATS; i++) {
> +               strcpy(string, scanstat_string[i]);
> +               strcat(string, SCANSTAT_WORD_SYSTEM);
> +               strcat(string, SCANSTAT_WORD_HIERARCHY);
> +               cb->fill(cb, string,
>  mem->scanstat.rootstats[SCAN_BY_SYSTEM][i]);
> +       }
> +       return 0;
> +}
> +
> +static int mem_cgroup_reset_vmscan_stat(struct cgroup *cgrp,
> +                               unsigned int event)
> +{
> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +
> +       spin_lock(&mem->scanstat.lock);
> +       memset(&mem->scanstat.stats, 0, sizeof(mem->scanstat.stats));
> +       memset(&mem->scanstat.rootstats, 0,
> sizeof(mem->scanstat.rootstats));
> +       spin_unlock(&mem->scanstat.lock);
> +       return 0;
> +}
> +
> +
>  static struct cftype mem_cgroup_files[] = {
>        {
>                .name = "usage_in_bytes",
> @@ -4609,6 +4763,11 @@ static struct cftype mem_cgroup_files[]
>                .mode = S_IRUGO,
>        },
>  #endif
> +       {
> +               .name = "vmscan_stat",
> +               .read_map = mem_cgroup_vmscan_stat_read,
> +               .trigger = mem_cgroup_reset_vmscan_stat,
> +       },
>  };
>
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -4872,6 +5031,7 @@ mem_cgroup_create(struct cgroup_subsys *
>        atomic_set(&mem->refcnt, 1);
>        mem->move_charge_at_immigrate = 0;
>        mutex_init(&mem->thresholds_lock);
> +       spin_lock_init(&mem->scanstat.lock);
>        return &mem->css;
>  free_out:
>        __mem_cgroup_free(mem);
> Index: mmotm-0710/mm/vmscan.c
> ===================================================================
> --- mmotm-0710.orig/mm/vmscan.c
> +++ mmotm-0710/mm/vmscan.c
> @@ -105,6 +105,7 @@ struct scan_control {
>
>        /* Which cgroup do we reclaim from */
>        struct mem_cgroup *mem_cgroup;
> +       struct memcg_scanrecord *memcg_record;
>
>        /*
>         * Nodemask of nodes allowed by the caller. If NULL, all nodes
> @@ -1307,6 +1308,8 @@ putback_lru_pages(struct zone *zone, str
>                        int file = is_file_lru(lru);
>                        int numpages = hpage_nr_pages(page);
>                        reclaim_stat->recent_rotated[file] += numpages;
> +                       if (!scanning_global_lru(sc))
> +                               sc->memcg_record->nr_rotated[file] +=
> numpages;
>                }
>                if (!pagevec_add(&pvec, page)) {
>                        spin_unlock_irq(&zone->lru_lock);
> @@ -1350,6 +1353,10 @@ static noinline_for_stack void update_is
>
>        reclaim_stat->recent_scanned[0] += *nr_anon;
>        reclaim_stat->recent_scanned[1] += *nr_file;
> +       if (!scanning_global_lru(sc)) {
> +               sc->memcg_record->nr_scanned[0] += *nr_anon;
> +               sc->memcg_record->nr_scanned[1] += *nr_file;
> +       }
>  }
>
>  /*
> @@ -1457,6 +1464,9 @@ shrink_inactive_list(unsigned long nr_to
>
>        nr_reclaimed = shrink_page_list(&page_list, zone, sc);
>
> +       if (!scanning_global_lru(sc))
> +               sc->memcg_record->nr_freed[file] += nr_reclaimed;
> +
>

Can't we stall for writeback?  If so, we may call shrink_page_list() again
below.  The accounting should probably go after that instead.


>        /* Check if we should syncronously wait for writeback */
>        if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
>                set_reclaim_mode(priority, sc, true);
> @@ -1562,6 +1572,8 @@ static void shrink_active_list(unsigned
>        }
>
>        reclaim_stat->recent_scanned[file] += nr_taken;
> +       if (!scanning_global_lru(sc))
> +               sc->memcg_record->nr_scanned[file] += nr_taken;
>
>        __count_zone_vm_events(PGREFILL, zone, pgscanned);
>        if (file)
> @@ -1613,6 +1625,8 @@ static void shrink_active_list(unsigned
>         * get_scan_ratio.
>         */
>        reclaim_stat->recent_rotated[file] += nr_rotated;
> +       if (!scanning_global_lru(sc))
> +               sc->memcg_record->nr_rotated[file] += nr_rotated;
>
>        move_active_pages_to_lru(zone, &l_active,
>                                                LRU_ACTIVE + file *
> LRU_FILE);
> @@ -2207,9 +2221,10 @@ unsigned long try_to_free_pages(struct z
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>
>  unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> -                                               gfp_t gfp_mask, bool
> noswap,
> -                                               struct zone *zone,
> -                                               unsigned long *nr_scanned)
> +                                       gfp_t gfp_mask, bool noswap,
> +                                       struct zone *zone,
> +                                       struct memcg_scanrecord *rec,
> +                                       unsigned long *scanned)
>  {
>        struct scan_control sc = {
>                .nr_scanned = 0,
> @@ -2219,7 +2234,9 @@ unsigned long mem_cgroup_shrink_node_zon
>                .may_swap = !noswap,
>                .order = 0,
>                .mem_cgroup = mem,
> +               .memcg_record = rec,
>        };
> +       unsigned long start, end;
>
>        sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>                        (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> @@ -2228,6 +2245,7 @@ unsigned long mem_cgroup_shrink_node_zon
>                                                      sc.may_writepage,
>                                                      sc.gfp_mask);
>
> +       start = sched_clock();
>        /*
>         * NOTE: Although we can get the priority field, using it
>         * here is not a good idea, since it limits the pages we can scan.
> @@ -2236,19 +2254,25 @@ unsigned long mem_cgroup_shrink_node_zon
>         * the priority and make it zero.
>         */
>        shrink_zone(0, zone, &sc);
> +       end = sched_clock();
> +
> +       if (rec)
> +               rec->elapsed += end - start;
> +       *scanned = sc.nr_scanned;
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
> @@ -2257,6 +2281,7 @@ unsigned long try_to_free_mem_cgroup_pag
>                .nr_to_reclaim = SWAP_CLUSTER_MAX,
>                .order = 0,
>                .mem_cgroup = mem_cont,
> +               .memcg_record = rec,
>                .nodemask = NULL, /* we don't care the placement */
>                .gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>                                (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
> @@ -2265,6 +2290,7 @@ unsigned long try_to_free_mem_cgroup_pag
>                .gfp_mask = sc.gfp_mask,
>        };
>
> +       start = sched_clock();
>        /*
>         * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
>         * take care of from where we get pages. So the node where we start
> the
> @@ -2279,6 +2305,9 @@ unsigned long try_to_free_mem_cgroup_pag
>                                            sc.gfp_mask);
>
>        nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
> +       end = sched_clock();
> +       if (rec)
> +               rec->elapsed += end - start;
>
>        trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--001636b2b08233a65604a85e4ab6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Mon, Jul 11, 2011 at 3:30 AM, KAMEZAWA Hiroyu=
ki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">=
kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">
<br>
This patch is onto mmotm-0710... got bigger than expected ;(<br>
=3D=3D<br>
[PATCH] add memory.vmscan_stat<br>
<br>
commit log of commit 0ae5e89 &quot; memcg: count the soft_limit reclaim in.=
..&quot;<br>
says it adds scanning stats to memory.stat file. But it doesn&#39;t because=
<br>
we considered we needed to make a concensus for such new APIs.<br>
<br>
This patch is a trial to add memory.scan_stat. This shows<br>
 =A0- the number of scanned pages(total, anon, file)<br>
 =A0- the number of rotated pages(total, anon, file)<br>
 =A0- the number of freed pages(total, anon, file)<br>
 =A0- the number of elaplsed time (including sleep/pause time)<br>
<br>
 =A0for both of direct/soft reclaim.<br>
<br>
The biggest difference with oringinal Ying&#39;s one is that this file<br>
can be reset by some write, as<br>
<br>
 =A0# echo 0 ...../memory.scan_stat<br>
<br>
Example of output is here. This is a result after make -j 6 kernel<br>
under 300M limit.<br>
<br>
[kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat<br>
[kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.vmscan_stat<br>
scanned_pages_by_limit 9471864<br>
scanned_anon_pages_by_limit 6640629<br>
scanned_file_pages_by_limit 2831235<br>
rotated_pages_by_limit 4243974<br>
rotated_anon_pages_by_limit 3971968<br>
rotated_file_pages_by_limit 272006<br>
freed_pages_by_limit 2318492<br>
freed_anon_pages_by_limit 962052<br>
freed_file_pages_by_limit 1356440<br>
elapsed_ns_by_limit 351386416101<br>
scanned_pages_by_system 0<br>
scanned_anon_pages_by_system 0<br>
scanned_file_pages_by_system 0<br>
rotated_pages_by_system 0<br>
rotated_anon_pages_by_system 0<br>
rotated_file_pages_by_system 0<br>
freed_pages_by_system 0<br>
freed_anon_pages_by_system 0<br>
freed_file_pages_by_system 0<br>
elapsed_ns_by_system 0<br>
scanned_pages_by_limit_under_hierarchy 9471864<br>
scanned_anon_pages_by_limit_under_hierarchy 6640629<br>
scanned_file_pages_by_limit_under_hierarchy 2831235<br>
rotated_pages_by_limit_under_hierarchy 4243974<br>
rotated_anon_pages_by_limit_under_hierarchy 3971968<br>
rotated_file_pages_by_limit_under_hierarchy 272006<br>
freed_pages_by_limit_under_hierarchy 2318492<br>
freed_anon_pages_by_limit_under_hierarchy 962052<br>
freed_file_pages_by_limit_under_hierarchy 1356440<br>
elapsed_ns_by_limit_under_hierarchy 351386416101<br>
scanned_pages_by_system_under_hierarchy 0<br>
scanned_anon_pages_by_system_under_hierarchy 0<br>
scanned_file_pages_by_system_under_hierarchy 0<br>
rotated_pages_by_system_under_hierarchy 0<br>
rotated_anon_pages_by_system_under_hierarchy 0<br>
rotated_file_pages_by_system_under_hierarchy 0<br>
freed_pages_by_system_under_hierarchy 0<br>
freed_anon_pages_by_system_under_hierarchy 0<br>
freed_file_pages_by_system_under_hierarchy 0<br>
elapsed_ns_by_system_under_hierarchy 0<br>
<br>
<br>
total_xxxx is for hierarchy management.<br>
<br>
This will be useful for further memcg developments and need to be<br>
developped before we do some complicated rework on LRU/softlimit<br>
management.<br>
<br>
This patch adds a new struct memcg_scanrecord into scan_control struct.<br>
sc-&gt;nr_scanned at el is not designed for exporting information. For exam=
ple,<br>
nr_scanned is reset frequentrly and incremented +2 at scanning mapped pages=
.<br>
<br>
For avoiding complexity, I added a new param in scan_control which is for<b=
r>
exporting scanning score.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
<br>
Changelog:<br>
 =A0- renamed as vmscan_stat<br>
 =A0- handle file/anon<br>
 =A0- added &quot;rotated&quot;<br>
 =A0- changed names of param in vmscan_stat.<br>
---<br>
=A0Documentation/cgroups/memory.txt | =A0 85 +++++++++++++++++++<br>
=A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 19 ++++<br>
=A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 -<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0172 ++++++++++++=
+++++++++++++++++++++++++--<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 39 +++++++-=
<br>
=A05 files changed, 303 insertions(+), 18 deletions(-)<br>
<br>
Index: mmotm-0710/Documentation/cgroups/memory.txt<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0710.orig/Documentation/cgroups/memory.txt<br>
+++ mmotm-0710/Documentation/cgroups/memory.txt<br>
@@ -380,7 +380,7 @@ will be charged as a new owner of it.<br>
<br>
=A05.2 stat file<br>
<br>
-memory.stat file includes following statistics<br>
+5.2.1 memory.stat file includes following statistics<br>
<br>
=A0# per-memory cgroup local status<br>
=A0cache =A0 =A0 =A0 =A0 =A0- # of bytes of page cache memory.<br>
@@ -438,6 +438,89 @@ Note:<br>
 =A0 =A0 =A0 =A0 file_mapped is accounted only when the memory cgroup is ow=
ner of page<br>
 =A0 =A0 =A0 =A0 cache.)<br>
<br>
+5.2.2 memory.vmscan_stat<br>
+<br>
+memory.vmscan_stat includes statistics information for memory scanning and=
<br>
+freeing, reclaiming. The statistics shows memory scanning information sinc=
e<br>
+memory cgroup creation and can be reset to 0 by writing 0 as<br>
+<br>
+ #echo 0 &gt; ../memory.vmscan_stat<br>
+<br>
+This file contains following statistics.<br>
+<br>
+[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]<br>
+[param]_elapsed_ns_by_[reason]_[under_hierarchy]<br>
+<br>
+For example,<br>
+<br>
+ =A0scanned_file_pages_by_limit indicates the number of scanned<br>
+ =A0file pages at vmscan.<br>
+<br>
+Now, 3 parameters are supported<br>
+<br>
+ =A0scanned - the number of pages scanned by vmscan<br>
+ =A0rotated - the number of pages activated at vmscan<br>
+ =A0freed =A0 - the number of pages freed by vmscan<br>
+<br>
+If &quot;rotated&quot; is high against scanned/freed, the memcg seems busy=
.<br>
+<br>
+Now, 2 reason are supported<br>
+<br>
+ =A0limit - the memory cgroup&#39;s limit<br>
+ =A0system - global memory pressure + softlimit<br>
+ =A0 =A0 =A0 =A0 =A0 (global memory pressure not under softlimit is not ha=
ndled now)<br>
+<br>
+When under_hierarchy is added in the tail, the number indicates the<br>
+total memcg scan of its children and itself.<br>
+<br>
+elapsed_ns is a elapsed time in nanosecond. This may include sleep time<br=
>
+and not indicates CPU usage. So, please take this as just showing<br>
+latency.<br>
+<br>
+Here is an example.<br>
+<br>
+# cat /cgroup/memory/A/memory.vmscan_stat<br>
+scanned_pages_by_limit 9471864<br>
+scanned_anon_pages_by_limit 6640629<br>
+scanned_file_pages_by_limit 2831235<br>
+rotated_pages_by_limit 4243974<br>
+rotated_anon_pages_by_limit 3971968<br>
+rotated_file_pages_by_limit 272006<br>
+freed_pages_by_limit 2318492<br>
+freed_anon_pages_by_limit 962052<br>
+freed_file_pages_by_limit 1356440<br>
+elapsed_ns_by_limit 351386416101<br>
+scanned_pages_by_system 0<br>
+scanned_anon_pages_by_system 0<br>
+scanned_file_pages_by_system 0<br>
+rotated_pages_by_system 0<br>
+rotated_anon_pages_by_system 0<br>
+rotated_file_pages_by_system 0<br>
+freed_pages_by_system 0<br>
+freed_anon_pages_by_system 0<br>
+freed_file_pages_by_system 0<br>
+elapsed_ns_by_system 0<br>
+scanned_pages_by_limit_under_hierarchy 9471864<br>
+scanned_anon_pages_by_limit_under_hierarchy 6640629<br>
+scanned_file_pages_by_limit_under_hierarchy 2831235<br>
+rotated_pages_by_limit_under_hierarchy 4243974<br>
+rotated_anon_pages_by_limit_under_hierarchy 3971968<br>
+rotated_file_pages_by_limit_under_hierarchy 272006<br>
+freed_pages_by_limit_under_hierarchy 2318492<br>
+freed_anon_pages_by_limit_under_hierarchy 962052<br>
+freed_file_pages_by_limit_under_hierarchy 1356440<br>
+elapsed_ns_by_limit_under_hierarchy 351386416101<br>
+scanned_pages_by_system_under_hierarchy 0<br>
+scanned_anon_pages_by_system_under_hierarchy 0<br>
+scanned_file_pages_by_system_under_hierarchy 0<br>
+rotated_pages_by_system_under_hierarchy 0<br>
+rotated_anon_pages_by_system_under_hierarchy 0<br>
+rotated_file_pages_by_system_under_hierarchy 0<br>
+freed_pages_by_system_under_hierarchy 0<br>
+freed_anon_pages_by_system_under_hierarchy 0<br>
+freed_file_pages_by_system_under_hierarchy 0<br>
+elapsed_ns_by_system_under_hierarchy 0<br>
+<br>
=A05.3 swappiness<br>
<br>
=A0Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups =
only.<br>
Index: mmotm-0710/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0710.orig/include/linux/memcontrol.h<br>
+++ mmotm-0710/include/linux/memcontrol.h<br>
@@ -39,6 +39,16 @@ extern unsigned long mem_cgroup_isolate_<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct mem_cgroup *mem_cont,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0int active, int file);<br>
<br>
+struct memcg_scanrecord {<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem; /* scanend memory cgroup */<br>
+ =A0 =A0 =A0 struct mem_cgroup *root; /* scan target hierarchy root */<br>
+ =A0 =A0 =A0 int context; =A0 =A0 =A0 =A0 =A0 =A0/* scanning context (see =
memcontrol.c) */<br>
+ =A0 =A0 =A0 unsigned long nr_scanned[2]; /* the number of scanned pages *=
/<br>
+ =A0 =A0 =A0 unsigned long nr_rotated[2]; /* the number of rotated pages *=
/<br>
+ =A0 =A0 =A0 unsigned long nr_freed[2]; /* the number of freed pages */<br=
>
+ =A0 =A0 =A0 unsigned long elapsed; /* nsec of time elapsed while scanning=
 */<br>
+};<br>
+<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
=A0/*<br>
 =A0* All &quot;charge&quot; functions with gfp_mask should use GFP_KERNEL =
or<br>
@@ -117,6 +127,15 @@ mem_cgroup_get_reclaim_stat_from_page(st<br>
=A0extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct task_struct *p);<br>
<br>
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
=A0 =A0 =A0 =A0 =A0 struct memcg_scanrecord *rec,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned);<br>
+<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
=A0extern int do_swap_account;<br>
=A0#endif<br>
Index: mmotm-0710/include/linux/swap.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0710.orig/include/linux/swap.h<br>
+++ mmotm-0710/include/linux/swap.h<br>
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
Index: mmotm-0710/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0710.orig/mm/memcontrol.c<br>
+++ mmotm-0710/mm/memcontrol.c<br>
@@ -204,6 +204,50 @@ struct mem_cgroup_eventfd_list {<br>
=A0static void mem_cgroup_threshold(struct mem_cgroup *mem);<br>
=A0static void mem_cgroup_oom_notify(struct mem_cgroup *mem);<br>
<br>
+enum {<br>
+ =A0 =A0 =A0 SCAN_BY_LIMIT,<br>
+ =A0 =A0 =A0 SCAN_BY_SYSTEM,<br>
+ =A0 =A0 =A0 NR_SCAN_CONTEXT,<br>
+ =A0 =A0 =A0 SCAN_BY_SHRINK, /* not recorded now */<br>
+};<br>
+<br>
+enum {<br>
+ =A0 =A0 =A0 SCAN,<br>
+ =A0 =A0 =A0 SCAN_ANON,<br>
+ =A0 =A0 =A0 SCAN_FILE,<br>
+ =A0 =A0 =A0 ROTATE,<br>
+ =A0 =A0 =A0 ROTATE_ANON,<br>
+ =A0 =A0 =A0 ROTATE_FILE,<br>
+ =A0 =A0 =A0 FREED,<br>
+ =A0 =A0 =A0 FREED_ANON,<br>
+ =A0 =A0 =A0 FREED_FILE,<br>
+ =A0 =A0 =A0 ELAPSED,<br>
+ =A0 =A0 =A0 NR_SCANSTATS,<br>
+};<br>
+<br>
+struct scanstat {<br>
+ =A0 =A0 =A0 spinlock_t =A0 =A0 =A0lock;<br>
+ =A0 =A0 =A0 unsigned long =A0 stats[NR_SCAN_CONTEXT][NR_SCANSTATS];<br>
+ =A0 =A0 =A0 unsigned long =A0 rootstats[NR_SCAN_CONTEXT][NR_SCANSTATS];<b=
r>
+};<br>
+<br>
+const char *scanstat_string[NR_SCANSTATS] =3D {<br>
+ =A0 =A0 =A0 &quot;scanned_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;scanned_anon_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;scanned_file_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;rotated_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;rotated_anon_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;rotated_file_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;freed_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;freed_anon_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;freed_file_pages&quot;,<br>
+ =A0 =A0 =A0 &quot;elapsed_ns&quot;,<br>
+};<br>
+#define SCANSTAT_WORD_LIMIT =A0 =A0&quot;_by_limit&quot;<br>
+#define SCANSTAT_WORD_SYSTEM =A0 &quot;_by_system&quot;<br>
+#define SCANSTAT_WORD_HIERARCHY =A0 =A0 =A0 =A0&quot;_under_hierarchy&quot=
;<br>
+<br>
+<br>
=A0/*<br>
 =A0* The memory controller data structure. The memory controller controls =
both<br>
 =A0* page cache and RSS per cgroup. We would eventually like to provide<br=
>
@@ -266,7 +310,8 @@ struct mem_cgroup {<br>
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
@@ -1619,6 +1664,44 @@ bool mem_cgroup_reclaimable(struct mem_c<br>
=A0}<br>
=A0#endif<br>
<br>
+static void __mem_cgroup_record_scanstat(unsigned long *stats,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct memcg_scanrecor=
d *rec)<br>
+{<br>
+<br>
+ =A0 =A0 =A0 stats[SCAN] +=3D rec-&gt;nr_scanned[0] + rec-&gt;nr_scanned[1=
];<br>
+ =A0 =A0 =A0 stats[SCAN_ANON] +=3D rec-&gt;nr_scanned[0];<br>
+ =A0 =A0 =A0 stats[SCAN_FILE] +=3D rec-&gt;nr_scanned[1];<br>
+<br>
+ =A0 =A0 =A0 stats[ROTATE] +=3D rec-&gt;nr_rotated[0] + rec-&gt;nr_rotated=
[1];<br>
+ =A0 =A0 =A0 stats[ROTATE_ANON] +=3D rec-&gt;nr_rotated[0];<br>
+ =A0 =A0 =A0 stats[ROTATE_FILE] +=3D rec-&gt;nr_rotated[1];<br>
+<br>
+ =A0 =A0 =A0 stats[FREED] +=3D rec-&gt;nr_freed[0] + rec-&gt;nr_freed[1];<=
br>
+ =A0 =A0 =A0 stats[FREED_ANON] +=3D rec-&gt;nr_freed[0];<br>
+ =A0 =A0 =A0 stats[FREED_FILE] +=3D rec-&gt;nr_freed[1];<br>
+<br>
+ =A0 =A0 =A0 stats[ELAPSED] +=3D rec-&gt;elapsed;<br>
+}<br>
+<br>
+static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem;<br>
+ =A0 =A0 =A0 int context =3D rec-&gt;context;<br>
+<br>
+ =A0 =A0 =A0 if (context &gt;=3D NR_SCAN_CONTEXT)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+<br>
+ =A0 =A0 =A0 mem =3D rec-&gt;mem;<br>
+ =A0 =A0 =A0 spin_lock(&amp;mem-&gt;scanstat.lock);<br>
+ =A0 =A0 =A0 __mem_cgroup_record_scanstat(mem-&gt;scanstat.stats[context],=
 rec);<br>
+ =A0 =A0 =A0 spin_unlock(&amp;mem-&gt;scanstat.lock);<br>
+<br>
+ =A0 =A0 =A0 mem =3D rec-&gt;root;<br>
+ =A0 =A0 =A0 spin_lock(&amp;mem-&gt;scanstat.lock);<br>
+ =A0 =A0 =A0 __mem_cgroup_record_scanstat(mem-&gt;scanstat.rootstats[conte=
xt], rec);<br>
+ =A0 =A0 =A0 spin_unlock(&amp;mem-&gt;scanstat.lock);<br>
+}<br>
+<br>
=A0/*<br>
 =A0* Scan the hierarchy if needed to reclaim memory. We remember the last =
child<br>
 =A0* we reclaimed from, so that we don&#39;t end up penalizing one child e=
xtensively<br>
@@ -1643,8 +1726,9 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0bool noswap =3D reclaim_options &amp; MEM_CGROUP_RECLAIM_NO=
SWAP;<br>
 =A0 =A0 =A0 =A0bool shrink =3D reclaim_options &amp; MEM_CGROUP_RECLAIM_SH=
RINK;<br>
 =A0 =A0 =A0 =A0bool check_soft =3D reclaim_options &amp; MEM_CGROUP_RECLAI=
M_SOFT;<br>
+ =A0 =A0 =A0 struct memcg_scanrecord rec;<br>
 =A0 =A0 =A0 =A0unsigned long excess;<br>
- =A0 =A0 =A0 unsigned long nr_scanned;<br>
+ =A0 =A0 =A0 unsigned long scanned;<br>
<br>
 =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&amp;root_mem-&gt;=
res) &gt;&gt; PAGE_SHIFT;<br>
<br>
@@ -1652,6 +1736,15 @@ static int mem_cgroup_hierarchical_recla<br>
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
+ =A0 =A0 =A0 rec.root =3D root_mem;<br>
+<br>
 =A0 =A0 =A0 =A0while (1) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0victim =3D mem_cgroup_select_victim(root_me=
m);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (victim =3D=3D root_mem) {<br>
@@ -1692,14 +1785,23 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css=
);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.mem =3D victim;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_scanned[0] =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_scanned[1] =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_rotated[0] =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_rotated[1] =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_freed[0] =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.nr_freed[1] =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.elapsed =3D 0;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_n=
ode_zone(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, zone,=
 &amp;nr_scanned);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scanne=
d;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, zone,=
 &amp;rec, &amp;scanned);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D scanned;<=
br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cgr=
oup_pages(victim, gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 noswap);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 noswap, &amp;rec);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_record_scanstat(&amp;rec);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * At shrinking usage, we can&#39;t check w=
e should stop here or<br>
@@ -3688,14 +3790,18 @@ try_to_free:<br>
 =A0 =A0 =A0 =A0/* try to free all pages in this cgroup */<br>
 =A0 =A0 =A0 =A0shrink =3D 1;<br>
 =A0 =A0 =A0 =A0while (nr_retries &amp;&amp; mem-&gt;res.usage &gt; 0) {<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct memcg_scanrecord rec;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int progress;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (signal_pending(current)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EINTR;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.context =3D SCAN_BY_SHRINK;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.mem =3D mem;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec.root =3D mem;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0progress =3D try_to_free_mem_cgroup_pages(m=
em, GFP_KERNEL,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 false);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 false, &amp;rec);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!progress) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_retries--;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writeback is =
necessary */<br>
@@ -4539,6 +4645,54 @@ static int mem_control_numa_stat_open(st<br>
=A0}<br>
=A0#endif /* CONFIG_NUMA */<br>
<br>
+static int mem_cgroup_vmscan_stat_read(struct cgroup *cgrp,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cftype=
 *cft,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup=
_map_cb *cb)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);<br>
+ =A0 =A0 =A0 char string[64];<br>
+ =A0 =A0 =A0 int i;<br>
+<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; NR_SCANSTATS; i++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcpy(string, scanstat_string[i]);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcat(string, SCANSTAT_WORD_LIMIT);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb-&gt;fill(cb, string, =A0mem-&gt;scanstat.s=
tats[SCAN_BY_LIMIT][i]);<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; NR_SCANSTATS; i++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcpy(string, scanstat_string[i]);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcat(string, SCANSTAT_WORD_SYSTEM);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb-&gt;fill(cb, string, =A0mem-&gt;scanstat.s=
tats[SCAN_BY_SYSTEM][i]);<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; NR_SCANSTATS; i++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcpy(string, scanstat_string[i]);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcat(string, SCANSTAT_WORD_LIMIT);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcat(string, SCANSTAT_WORD_HIERARCHY);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb-&gt;fill(cb, string, =A0mem-&gt;scanstat.r=
ootstats[SCAN_BY_LIMIT][i]);<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; NR_SCANSTATS; i++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcpy(string, scanstat_string[i]);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcat(string, SCANSTAT_WORD_SYSTEM);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcat(string, SCANSTAT_WORD_HIERARCHY);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb-&gt;fill(cb, string, =A0mem-&gt;scanstat.r=
ootstats[SCAN_BY_SYSTEM][i]);<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+static int mem_cgroup_reset_vmscan_stat(struct cgroup *cgrp,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int =
event)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);<br>
+<br>
+ =A0 =A0 =A0 spin_lock(&amp;mem-&gt;scanstat.lock);<br>
+ =A0 =A0 =A0 memset(&amp;mem-&gt;scanstat.stats, 0, sizeof(mem-&gt;scansta=
t.stats));<br>
+ =A0 =A0 =A0 memset(&amp;mem-&gt;scanstat.rootstats, 0, sizeof(mem-&gt;sca=
nstat.rootstats));<br>
+ =A0 =A0 =A0 spin_unlock(&amp;mem-&gt;scanstat.lock);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+<br>
=A0static struct cftype mem_cgroup_files[] =3D {<br>
 =A0 =A0 =A0 =A0{<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D &quot;usage_in_bytes&quot;,<br>
@@ -4609,6 +4763,11 @@ static struct cftype mem_cgroup_files[]<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =3D S_IRUGO,<br>
 =A0 =A0 =A0 =A0},<br>
=A0#endif<br>
+ =A0 =A0 =A0 {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;vmscan_stat&quot;,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_vmscan_stat_read,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .trigger =3D mem_cgroup_reset_vmscan_stat,<br=
>
+ =A0 =A0 =A0 },<br>
=A0};<br>
<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
@@ -4872,6 +5031,7 @@ mem_cgroup_create(struct cgroup_subsys *<br>
 =A0 =A0 =A0 =A0atomic_set(&amp;mem-&gt;refcnt, 1);<br>
 =A0 =A0 =A0 =A0mem-&gt;move_charge_at_immigrate =3D 0;<br>
 =A0 =A0 =A0 =A0mutex_init(&amp;mem-&gt;thresholds_lock);<br>
+ =A0 =A0 =A0 spin_lock_init(&amp;mem-&gt;scanstat.lock);<br>
 =A0 =A0 =A0 =A0return &amp;mem-&gt;css;<br>
=A0free_out:<br>
 =A0 =A0 =A0 =A0__mem_cgroup_free(mem);<br>
Index: mmotm-0710/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-0710.orig/mm/vmscan.c<br>
+++ mmotm-0710/mm/vmscan.c<br>
@@ -105,6 +105,7 @@ struct scan_control {<br>
<br>
 =A0 =A0 =A0 =A0/* Which cgroup do we reclaim from */<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem_cgroup;<br>
+ =A0 =A0 =A0 struct memcg_scanrecord *memcg_record;<br>
<br>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * Nodemask of nodes allowed by the caller. If NULL, all no=
des<br>
@@ -1307,6 +1308,8 @@ putback_lru_pages(struct zone *zone, str<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int file =3D is_file_lru(lr=
u);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int numpages =3D hpage_nr_p=
ages(page);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reclaim_stat-&gt;recent_rot=
ated[file] +=3D numpages;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!scanning_global_lru(sc))=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;memcg_=
record-&gt;nr_rotated[file] +=3D numpages;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!pagevec_add(&amp;pvec, page)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irq(&amp;zone-&=
gt;lru_lock);<br>
@@ -1350,6 +1353,10 @@ static noinline_for_stack void update_is<br>
<br>
 =A0 =A0 =A0 =A0reclaim_stat-&gt;recent_scanned[0] +=3D *nr_anon;<br>
 =A0 =A0 =A0 =A0reclaim_stat-&gt;recent_scanned[1] +=3D *nr_file;<br>
+ =A0 =A0 =A0 if (!scanning_global_lru(sc)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;memcg_record-&gt;nr_scanned[0] +=3D *n=
r_anon;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;memcg_record-&gt;nr_scanned[1] +=3D *n=
r_file;<br>
+ =A0 =A0 =A0 }<br>
=A0}<br>
<br>
=A0/*<br>
@@ -1457,6 +1464,9 @@ shrink_inactive_list(unsigned long nr_to<br>
<br>
 =A0 =A0 =A0 =A0nr_reclaimed =3D shrink_page_list(&amp;page_list, zone, sc)=
;<br>
<br>
+ =A0 =A0 =A0 if (!scanning_global_lru(sc))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;memcg_record-&gt;nr_freed[file] +=3D n=
r_reclaimed;<br>
+<br></blockquote><div><br></div><div>Can&#39;t we stall for writeback? =A0=
If so, we may call shrink_page_list() again below. =A0The accounting should=
 probably go after that instead.</div><div>=A0</div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex;">

 =A0 =A0 =A0 =A0/* Check if we should syncronously wait for writeback */<br=
>
 =A0 =A0 =A0 =A0if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, =
sc)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_reclaim_mode(priority, sc, true);<br>
@@ -1562,6 +1572,8 @@ static void shrink_active_list(unsigned<br>
 =A0 =A0 =A0 =A0}<br>
<br>
 =A0 =A0 =A0 =A0reclaim_stat-&gt;recent_scanned[file] +=3D nr_taken;<br>
+ =A0 =A0 =A0 if (!scanning_global_lru(sc))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;memcg_record-&gt;nr_scanned[file] +=3D=
 nr_taken;<br>
<br>
 =A0 =A0 =A0 =A0__count_zone_vm_events(PGREFILL, zone, pgscanned);<br>
 =A0 =A0 =A0 =A0if (file)<br>
@@ -1613,6 +1625,8 @@ static void shrink_active_list(unsigned<br>
 =A0 =A0 =A0 =A0 * get_scan_ratio.<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0reclaim_stat-&gt;recent_rotated[file] +=3D nr_rotated;<br>
+ =A0 =A0 =A0 if (!scanning_global_lru(sc))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;memcg_record-&gt;nr_rotated[file] +=3D=
 nr_rotated;<br>
<br>
 =A0 =A0 =A0 =A0move_active_pages_to_lru(zone, &amp;l_active,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0LRU_ACTIVE + file * LRU_FILE);<br>
@@ -2207,9 +2221,10 @@ unsigned long try_to_free_pages(struct z<br>
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
=A0 struct memcg_scanrecord *rec,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long *scanned)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct scan_control sc =3D {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_scanned =3D 0,<br>
@@ -2219,7 +2234,9 @@ unsigned long mem_cgroup_shrink_node_zon<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_swap =3D !noswap,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .memcg_record =3D rec,<br>
 =A0 =A0 =A0 =A0};<br>
+ =A0 =A0 =A0 unsigned long start, end;<br>
<br>
 =A0 =A0 =A0 =A0sc.gfp_mask =3D (gfp_mask &amp; GFP_RECLAIM_MASK) |<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(GFP_HIGHUSER_MOVABLE &amp;=
 ~GFP_RECLAIM_MASK);<br>
@@ -2228,6 +2245,7 @@ unsigned long mem_cgroup_shrink_node_zon<br>
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
@@ -2236,19 +2254,25 @@ unsigned long mem_cgroup_shrink_node_zon<br>
 =A0 =A0 =A0 =A0 * the priority and make it zero.<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0shrink_zone(0, zone, &amp;sc);<br>
+ =A0 =A0 =A0 end =3D sched_clock();<br>
+<br>
+ =A0 =A0 =A0 if (rec)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec-&gt;elapsed +=3D end - start;<br>
+ =A0 =A0 =A0 *scanned =3D sc.nr_scanned;<br>
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
@@ -2257,6 +2281,7 @@ unsigned long try_to_free_mem_cgroup_pag<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_to_reclaim =3D SWAP_CLUSTER_MAX,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem_cont,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .memcg_record =3D rec,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nodemask =3D NULL, /* we don&#39;t care th=
e placement */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.gfp_mask =3D (gfp_mask &amp; GFP_RECLAIM_M=
ASK) |<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(GFP_HIGHUS=
ER_MOVABLE &amp; ~GFP_RECLAIM_MASK),<br>
@@ -2265,6 +2290,7 @@ unsigned long try_to_free_mem_cgroup_pag<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.gfp_mask =3D sc.gfp_mask,<br>
 =A0 =A0 =A0 =A0};<br>
<br>
+ =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * Unlike direct reclaim via alloc_pages(), memcg&#39;s rec=
laim doesn&#39;t<br>
 =A0 =A0 =A0 =A0 * take care of from where we get pages. So the node where =
we start the<br>
@@ -2279,6 +2305,9 @@ unsigned long try_to_free_mem_cgroup_pag<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0sc.gfp_mask);<br>
<br>
 =A0 =A0 =A0 =A0nr_reclaimed =3D do_try_to_free_pages(zonelist, &amp;sc, &a=
mp;shrink);<br>
+ =A0 =A0 =A0 end =3D sched_clock();<br>
+ =A0 =A0 =A0 if (rec)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec-&gt;elapsed +=3D end - start;<br>
<br>
 =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);<br>
<font color=3D"#888888"><br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Fight unfair telecom internet charges in Canada: sign <a href=3D"http://sto=
pthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></blockquote></div><br>

--001636b2b08233a65604a85e4ab6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
