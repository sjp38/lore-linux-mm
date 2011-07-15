Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C31FF6B007E
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 14:34:20 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p6FIYBcN031971
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 11:34:11 -0700
Received: from yxi19 (yxi19.prod.google.com [10.190.3.19])
	by hpaq3.eem.corp.google.com with ESMTP id p6FIY8qQ006128
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 11:34:09 -0700
Received: by yxi19 with SMTP id 19so814554yxi.34
        for <linux-mm@kvack.org>; Fri, 15 Jul 2011 11:34:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110714090221.1ead26d5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110711193036.5a03858d.kamezawa.hiroyu@jp.fujitsu.com>
	<CAL1qeaFQ2gPYm1LfUMOBm8G0q9UyoeRdYGwCQ9oF42AU8O6q9Q@mail.gmail.com>
	<20110714090221.1ead26d5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 15 Jul 2011 11:34:08 -0700
Message-ID: <CAL1qeaEoH_o4YfwnT5jsz3tyd=ZiGtUqMHQy7BMfLznjKvSZ_g@mail.gmail.com>
Subject: Re: [PATCH v2] memcg: add vmscan_stat
From: Andrew Bresticker <abrestic@google.com>
Content-Type: multipart/alternative; boundary=001636b2b9991f354304a81fe57c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

--001636b2b9991f354304a81fe57c
Content-Type: text/plain; charset=ISO-8859-1

I've extended your patch to track write-back during page reclaim:
---

From: Andrew Bresticker <abrestic@google.com>
Date: Thu, 14 Jul 2011 17:56:48 -0700
Subject: [PATCH] vmscan: Track number of pages written back during page
reclaim.

This tracks pages written out during page reclaim in memory.vmscan_stat
and breaks it down by file vs. anon and context (like "scanned_pages",
"rotated_pages", etc.).

Example output:
$ mkdir /dev/cgroup/memory/1
$ echo 8m > /dev/cgroup/memory/1/memory.limit_in_bytes
$ echo $$ > /dev/cgroup/memory/1/tasks
$ dd if=/dev/urandom of=file_20g bs=4096 count=524288
$ cat /dev/cgroup/memory/1/memory.vmscan_stat
...
written_pages_by_limit 36
written_anon_pages_by_limit 0
written_file_pages_by_limit 36
...
written_pages_by_limit_under_hierarchy 28
written_anon_pages_by_limit_under_hierarchy 0
written_file_pages_by_limit_under_hierarchy 28

Signed-off-by: Andrew Bresticker <abrestic@google.com>
---
 include/linux/memcontrol.h |    1 +
 mm/memcontrol.c            |   12 ++++++++++++
 mm/vmscan.c                |   10 +++++++---
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4b49edf..4be907e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -46,6 +46,7 @@ struct memcg_scanrecord {
  unsigned long nr_scanned[2]; /* the number of scanned pages */
  unsigned long nr_rotated[2]; /* the number of rotated pages */
  unsigned long nr_freed[2]; /* the number of freed pages */
+ unsigned long nr_written[2]; /* the number of pages written back */
  unsigned long elapsed; /* nsec of time elapsed while scanning */
 };

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9bb6e93..5ec2aa3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -221,6 +221,9 @@ enum {
  FREED,
  FREED_ANON,
  FREED_FILE,
+ WRITTEN,
+ WRITTEN_ANON,
+ WRITTEN_FILE,
  ELAPSED,
  NR_SCANSTATS,
 };
@@ -241,6 +244,9 @@ const char *scanstat_string[NR_SCANSTATS] = {
  "freed_pages",
  "freed_anon_pages",
  "freed_file_pages",
+ "written_pages",
+ "written_anon_pages",
+ "written_file_pages",
  "elapsed_ns",
 };
 #define SCANSTAT_WORD_LIMIT    "_by_limit"
@@ -1682,6 +1688,10 @@ static void __mem_cgroup_record_scanstat(unsigned
long *stats,
         stats[FREED_ANON] += rec->nr_freed[0];
         stats[FREED_FILE] += rec->nr_freed[1];

+ stats[WRITTEN] += rec->nr_written[0] + rec->nr_written[1];
+ stats[WRITTEN_ANON] += rec->nr_written[0];
+ stats[WRITTEN_FILE] += rec->nr_written[1];
+
         stats[ELAPSED] += rec->elapsed;
 }

@@ -1794,6 +1804,8 @@ static int mem_cgroup_hierarchical_reclaim(struct
mem_cgroup *root_mem,
                 rec.nr_rotated[1] = 0;
                 rec.nr_freed[0] = 0;
                 rec.nr_freed[1] = 0;
+ rec.nr_written[0] = 0;
+ rec.nr_written[1] = 0;
                 rec.elapsed = 0;
  /* we use swappiness of local cgroup */
  if (check_soft) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8fb1abd..f73b96e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -719,7 +719,7 @@ static noinline_for_stack void free_page_list(struct
list_head *free_pages)
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
       struct zone *zone,
-      struct scan_control *sc)
+      struct scan_control *sc, int file)
 {
  LIST_HEAD(ret_pages);
  LIST_HEAD(free_pages);
@@ -727,6 +727,7 @@ static unsigned long shrink_page_list(struct list_head
*page_list,
  unsigned long nr_dirty = 0;
  unsigned long nr_congested = 0;
  unsigned long nr_reclaimed = 0;
+ unsigned long nr_written = 0;

  cond_resched();

@@ -840,6 +841,7 @@ static unsigned long shrink_page_list(struct list_head
*page_list,
  case PAGE_ACTIVATE:
  goto activate_locked;
  case PAGE_SUCCESS:
+ nr_written++;
  if (PageWriteback(page))
  goto keep_lumpy;
  if (PageDirty(page))
@@ -958,6 +960,8 @@ keep_lumpy:
  free_page_list(&free_pages);

  list_splice(&ret_pages, page_list);
+ if (!scanning_global_lru(sc))
+ sc->memcg_record->nr_written[file] += nr_written;
  count_vm_events(PGACTIVATE, pgactivate);
  return nr_reclaimed;
 }
@@ -1463,7 +1467,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct
zone *zone,

  spin_unlock_irq(&zone->lru_lock);

- nr_reclaimed = shrink_page_list(&page_list, zone, sc);
+ nr_reclaimed = shrink_page_list(&page_list, zone, sc, file);

  if (!scanning_global_lru(sc))
  sc->memcg_record->nr_freed[file] += nr_reclaimed;
@@ -1471,7 +1475,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct
zone *zone,
  /* Check if we should syncronously wait for writeback */
  if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
  set_reclaim_mode(priority, sc, true);
- nr_reclaimed += shrink_page_list(&page_list, zone, sc);
+ nr_reclaimed += shrink_page_list(&page_list, zone, sc, file);
  }

  local_irq_disable();
-- 
1.7.3.1

Thanks,
Andrew

On Wed, Jul 13, 2011 at 5:02 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 12 Jul 2011 16:02:02 -0700
> Andrew Bresticker <abrestic@google.com> wrote:
>
> > On Mon, Jul 11, 2011 at 3:30 AM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > >
> > > This patch is onto mmotm-0710... got bigger than expected ;(
> > > ==
> > > [PATCH] add memory.vmscan_stat
> > >
> > > commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim
> in..."
> > > says it adds scanning stats to memory.stat file. But it doesn't because
> > > we considered we needed to make a concensus for such new APIs.
> > >
> > > This patch is a trial to add memory.scan_stat. This shows
> > >  - the number of scanned pages(total, anon, file)
> > >  - the number of rotated pages(total, anon, file)
> > >  - the number of freed pages(total, anon, file)
> > >  - the number of elaplsed time (including sleep/pause time)
> > >
> > >  for both of direct/soft reclaim.
> > >
> > > The biggest difference with oringinal Ying's one is that this file
> > > can be reset by some write, as
> > >
> > >  # echo 0 ...../memory.scan_stat
> > >
> > > Example of output is here. This is a result after make -j 6 kernel
> > > under 300M limit.
> > >
> > > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> > > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.vmscan_stat
> > > scanned_pages_by_limit 9471864
> > > scanned_anon_pages_by_limit 6640629
> > > scanned_file_pages_by_limit 2831235
> > > rotated_pages_by_limit 4243974
> > > rotated_anon_pages_by_limit 3971968
> > > rotated_file_pages_by_limit 272006
> > > freed_pages_by_limit 2318492
> > > freed_anon_pages_by_limit 962052
> > > freed_file_pages_by_limit 1356440
> > > elapsed_ns_by_limit 351386416101
> > > scanned_pages_by_system 0
> > > scanned_anon_pages_by_system 0
> > > scanned_file_pages_by_system 0
> > > rotated_pages_by_system 0
> > > rotated_anon_pages_by_system 0
> > > rotated_file_pages_by_system 0
> > > freed_pages_by_system 0
> > > freed_anon_pages_by_system 0
> > > freed_file_pages_by_system 0
> > > elapsed_ns_by_system 0
> > > scanned_pages_by_limit_under_hierarchy 9471864
> > > scanned_anon_pages_by_limit_under_hierarchy 6640629
> > > scanned_file_pages_by_limit_under_hierarchy 2831235
> > > rotated_pages_by_limit_under_hierarchy 4243974
> > > rotated_anon_pages_by_limit_under_hierarchy 3971968
> > > rotated_file_pages_by_limit_under_hierarchy 272006
> > > freed_pages_by_limit_under_hierarchy 2318492
> > > freed_anon_pages_by_limit_under_hierarchy 962052
> > > freed_file_pages_by_limit_under_hierarchy 1356440
> > > elapsed_ns_by_limit_under_hierarchy 351386416101
> > > scanned_pages_by_system_under_hierarchy 0
> > > scanned_anon_pages_by_system_under_hierarchy 0
> > > scanned_file_pages_by_system_under_hierarchy 0
> > > rotated_pages_by_system_under_hierarchy 0
> > > rotated_anon_pages_by_system_under_hierarchy 0
> > > rotated_file_pages_by_system_under_hierarchy 0
> > > freed_pages_by_system_under_hierarchy 0
> > > freed_anon_pages_by_system_under_hierarchy 0
> > > freed_file_pages_by_system_under_hierarchy 0
> > > elapsed_ns_by_system_under_hierarchy 0
> > >
> > >
> > > total_xxxx is for hierarchy management.
> > >
> > > This will be useful for further memcg developments and need to be
> > > developped before we do some complicated rework on LRU/softlimit
> > > management.
> > >
> > > This patch adds a new struct memcg_scanrecord into scan_control struct.
> > > sc->nr_scanned at el is not designed for exporting information. For
> > > example,
> > > nr_scanned is reset frequentrly and incremented +2 at scanning mapped
> > > pages.
> > >
> > > For avoiding complexity, I added a new param in scan_control which is
> for
> > > exporting scanning score.
> > >
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > >
> > > Changelog:
> > >  - renamed as vmscan_stat
> > >  - handle file/anon
> > >  - added "rotated"
> > >  - changed names of param in vmscan_stat.
> > > ---
> > >  Documentation/cgroups/memory.txt |   85 +++++++++++++++++++
> > >  include/linux/memcontrol.h       |   19 ++++
> > >  include/linux/swap.h             |    6 -
> > >  mm/memcontrol.c                  |  172
> > > +++++++++++++++++++++++++++++++++++++--
> > >  mm/vmscan.c                      |   39 +++++++-
> > >  5 files changed, 303 insertions(+), 18 deletions(-)
> > >
> > > Index: mmotm-0710/Documentation/cgroups/memory.txt
> > > ===================================================================
> > > --- mmotm-0710.orig/Documentation/cgroups/memory.txt
> > > +++ mmotm-0710/Documentation/cgroups/memory.txt
> > > @@ -380,7 +380,7 @@ will be charged as a new owner of it.
> > >
> > >  5.2 stat file
> > >
> > > -memory.stat file includes following statistics
> > > +5.2.1 memory.stat file includes following statistics
> > >
> > >  # per-memory cgroup local status
> > >  cache          - # of bytes of page cache memory.
> > > @@ -438,6 +438,89 @@ Note:
> > >         file_mapped is accounted only when the memory cgroup is owner
> of
> > > page
> > >         cache.)
> > >
> > > +5.2.2 memory.vmscan_stat
> > > +
> > > +memory.vmscan_stat includes statistics information for memory scanning
> and
> > > +freeing, reclaiming. The statistics shows memory scanning information
> > > since
> > > +memory cgroup creation and can be reset to 0 by writing 0 as
> > > +
> > > + #echo 0 > ../memory.vmscan_stat
> > > +
> > > +This file contains following statistics.
> > > +
> > > +[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]
> > > +[param]_elapsed_ns_by_[reason]_[under_hierarchy]
> > > +
> > > +For example,
> > > +
> > > +  scanned_file_pages_by_limit indicates the number of scanned
> > > +  file pages at vmscan.
> > > +
> > > +Now, 3 parameters are supported
> > > +
> > > +  scanned - the number of pages scanned by vmscan
> > > +  rotated - the number of pages activated at vmscan
> > > +  freed   - the number of pages freed by vmscan
> > > +
> > > +If "rotated" is high against scanned/freed, the memcg seems busy.
> > > +
> > > +Now, 2 reason are supported
> > > +
> > > +  limit - the memory cgroup's limit
> > > +  system - global memory pressure + softlimit
> > > +           (global memory pressure not under softlimit is not handled
> now)
> > > +
> > > +When under_hierarchy is added in the tail, the number indicates the
> > > +total memcg scan of its children and itself.
> > > +
> > > +elapsed_ns is a elapsed time in nanosecond. This may include sleep
> time
> > > +and not indicates CPU usage. So, please take this as just showing
> > > +latency.
> > > +
> > > +Here is an example.
> > > +
> > > +# cat /cgroup/memory/A/memory.vmscan_stat
> > > +scanned_pages_by_limit 9471864
> > > +scanned_anon_pages_by_limit 6640629
> > > +scanned_file_pages_by_limit 2831235
> > > +rotated_pages_by_limit 4243974
> > > +rotated_anon_pages_by_limit 3971968
> > > +rotated_file_pages_by_limit 272006
> > > +freed_pages_by_limit 2318492
> > > +freed_anon_pages_by_limit 962052
> > > +freed_file_pages_by_limit 1356440
> > > +elapsed_ns_by_limit 351386416101
> > > +scanned_pages_by_system 0
> > > +scanned_anon_pages_by_system 0
> > > +scanned_file_pages_by_system 0
> > > +rotated_pages_by_system 0
> > > +rotated_anon_pages_by_system 0
> > > +rotated_file_pages_by_system 0
> > > +freed_pages_by_system 0
> > > +freed_anon_pages_by_system 0
> > > +freed_file_pages_by_system 0
> > > +elapsed_ns_by_system 0
> > > +scanned_pages_by_limit_under_hierarchy 9471864
> > > +scanned_anon_pages_by_limit_under_hierarchy 6640629
> > > +scanned_file_pages_by_limit_under_hierarchy 2831235
> > > +rotated_pages_by_limit_under_hierarchy 4243974
> > > +rotated_anon_pages_by_limit_under_hierarchy 3971968
> > > +rotated_file_pages_by_limit_under_hierarchy 272006
> > > +freed_pages_by_limit_under_hierarchy 2318492
> > > +freed_anon_pages_by_limit_under_hierarchy 962052
> > > +freed_file_pages_by_limit_under_hierarchy 1356440
> > > +elapsed_ns_by_limit_under_hierarchy 351386416101
> > > +scanned_pages_by_system_under_hierarchy 0
> > > +scanned_anon_pages_by_system_under_hierarchy 0
> > > +scanned_file_pages_by_system_under_hierarchy 0
> > > +rotated_pages_by_system_under_hierarchy 0
> > > +rotated_anon_pages_by_system_under_hierarchy 0
> > > +rotated_file_pages_by_system_under_hierarchy 0
> > > +freed_pages_by_system_under_hierarchy 0
> > > +freed_anon_pages_by_system_under_hierarchy 0
> > > +freed_file_pages_by_system_under_hierarchy 0
> > > +elapsed_ns_by_system_under_hierarchy 0
> > > +
> > >  5.3 swappiness
> > >
> > >  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of
> groups
> > > only.
> > > Index: mmotm-0710/include/linux/memcontrol.h
> > > ===================================================================
> > > --- mmotm-0710.orig/include/linux/memcontrol.h
> > > +++ mmotm-0710/include/linux/memcontrol.h
> > > @@ -39,6 +39,16 @@ extern unsigned long mem_cgroup_isolate_
> > >                                        struct mem_cgroup *mem_cont,
> > >                                        int active, int file);
> > >
> > > +struct memcg_scanrecord {
> > > +       struct mem_cgroup *mem; /* scanend memory cgroup */
> > > +       struct mem_cgroup *root; /* scan target hierarchy root */
> > > +       int context;            /* scanning context (see memcontrol.c)
> */
> > > +       unsigned long nr_scanned[2]; /* the number of scanned pages */
> > > +       unsigned long nr_rotated[2]; /* the number of rotated pages */
> > > +       unsigned long nr_freed[2]; /* the number of freed pages */
> > > +       unsigned long elapsed; /* nsec of time elapsed while scanning
> */
> > > +};
> > > +
> > >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > >  /*
> > >  * All "charge" functions with gfp_mask should use GFP_KERNEL or
> > > @@ -117,6 +127,15 @@ mem_cgroup_get_reclaim_stat_from_page(st
> > >  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> > >                                        struct task_struct *p);
> > >
> > > +extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup
> *mem,
> > > +                                                 gfp_t gfp_mask, bool
> > > noswap,
> > > +                                                 struct
> memcg_scanrecord
> > > *rec);
> > > +extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup
> *mem,
> > > +                                               gfp_t gfp_mask, bool
> > > noswap,
> > > +                                               struct zone *zone,
> > > +                                               struct memcg_scanrecord
> > > *rec,
> > > +                                               unsigned long
> *nr_scanned);
> > > +
> > >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > >  extern int do_swap_account;
> > >  #endif
> > > Index: mmotm-0710/include/linux/swap.h
> > > ===================================================================
> > > --- mmotm-0710.orig/include/linux/swap.h
> > > +++ mmotm-0710/include/linux/swap.h
> > > @@ -253,12 +253,6 @@ static inline void lru_cache_add_file(st
> > >  /* linux/mm/vmscan.c */
> > >  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int
> > > order,
> > >                                        gfp_t gfp_mask, nodemask_t
> *mask);
> > > -extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup
> *mem,
> > > -                                                 gfp_t gfp_mask, bool
> > > noswap);
> > > -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup
> *mem,
> > > -                                               gfp_t gfp_mask, bool
> > > noswap,
> > > -                                               struct zone *zone,
> > > -                                               unsigned long
> *nr_scanned);
> > >  extern int __isolate_lru_page(struct page *page, int mode, int file);
> > >  extern unsigned long shrink_all_memory(unsigned long nr_pages);
> > >  extern int vm_swappiness;
> > > Index: mmotm-0710/mm/memcontrol.c
> > > ===================================================================
> > > --- mmotm-0710.orig/mm/memcontrol.c
> > > +++ mmotm-0710/mm/memcontrol.c
> > > @@ -204,6 +204,50 @@ struct mem_cgroup_eventfd_list {
> > >  static void mem_cgroup_threshold(struct mem_cgroup *mem);
> > >  static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
> > >
> > > +enum {
> > > +       SCAN_BY_LIMIT,
> > > +       SCAN_BY_SYSTEM,
> > > +       NR_SCAN_CONTEXT,
> > > +       SCAN_BY_SHRINK, /* not recorded now */
> > > +};
> > > +
> > > +enum {
> > > +       SCAN,
> > > +       SCAN_ANON,
> > > +       SCAN_FILE,
> > > +       ROTATE,
> > > +       ROTATE_ANON,
> > > +       ROTATE_FILE,
> > > +       FREED,
> > > +       FREED_ANON,
> > > +       FREED_FILE,
> > > +       ELAPSED,
> > > +       NR_SCANSTATS,
> > > +};
> > > +
> > > +struct scanstat {
> > > +       spinlock_t      lock;
> > > +       unsigned long   stats[NR_SCAN_CONTEXT][NR_SCANSTATS];
> > > +       unsigned long   rootstats[NR_SCAN_CONTEXT][NR_SCANSTATS];
> > > +};
> > >
> >
> > I'm working on a similar effort with Ying here at Google and so far we've
> > been using per-cpu counters for these statistics instead of spin-lock
> > protected counters.  Clearly the spin-lock protected counters have less
> > memory overhead and make reading the stat file faster, but our concern is
> > that this method is inconsistent with the other memory stat files such
> > /proc/vmstat and /dev/cgroup/memory/.../memory.stat.  Is there any
> > particular reason you chose to use spin-lock protected counters instead
> of
> > per-cpu counters?
> >
>
> In my experience, if we do "batch" enouch, it works always better than
> percpu-counter. percpu counter is effective when batching is difficult.
> This patch's implementation does enough batching and it's much coarse
> grained than percpu counter. Then, this patch is better than percpu.
>
>
> > I've also modified your patch to use per-cpu counters instead of
> spin-lock
> > protected counters.  I tested it by doing streaming I/O from a ramdisk:
> >
> > $ mke2fs /dev/ram1
> > $ mkdir /tmp/swapram
> > $ mkdir /tmp/swapram/ram1
> > $ mount -t ext2 /dev/ram1 /tmp/swapram/ram1
> > $ dd if=/dev/urandom of=/tmp/swapram/ram1/file_16m bs=4096 count=4096
> > $ mkdir /dev/cgroup/memory/1
> > $ echo 8m > /dev/cgroup/memory/1
> > $ ./ramdisk_load.sh 7
> > $ echo $$ > /dev/cgroup/memory/1/tasks
> > $ time for ((z=0; z<=2000; z++)); do cat /tmp/swapram/ram1/file_16m >
> > /dev/zero; done
> >
> > Where ramdisk_load.sh is:
> > for ((i=0; i<=$1; i++))
> > do
> >   echo $$ >/dev/cgroup/memory/1/tasks
> >   for ((z=0; z<=2000; z++)); do cat /tmp/swapram/ram1/file_16m >
> /dev/zero;
> > done &
> > done
> >
> > Surprisingly, the per-cpu counters perform worse than the spin-lock
> > protected counters.  Over 10 runs of the test above, the per-cpu counters
> > were 1.60% slower in both real time and sys time.  I'm wondering if you
> have
> > any insight as to why this is.  I can provide my diff against your patch
> if
> > necessary.
> >
>
> The percpu counte works effectively only when we use +1/-1 at each change
> of
> counters. It uses "batch" to merge the per-cpu value to the counter.
> I think you use default "batch" value but the scan/rotate/free/elapsed
> value
> is always larger than "batch" and you just added memory overhead and "if"
> to pure spinlock counters.
>
> Determining this "batch" threshold for percpu counter is difficult.
>
> Thanks,
> -Kame
>
>
>

--001636b2b9991f354304a81fe57c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I&#39;ve extended your patch to track write-back during page reclaim:<div>-=
--</div><div><br></div><div><div>From: Andrew Bresticker &lt;<a href=3D"mai=
lto:abrestic@google.com">abrestic@google.com</a>&gt;</div><div>Date: Thu, 1=
4 Jul 2011 17:56:48 -0700</div>
<div>Subject: [PATCH] vmscan: Track number of pages written back during pag=
e reclaim.</div><div><br></div><div>This tracks pages written out during pa=
ge reclaim in memory.vmscan_stat</div><div>and breaks it down by file vs. a=
non and context (like &quot;scanned_pages&quot;,</div>
<div>&quot;rotated_pages&quot;, etc.).</div><div><br></div><div>Example out=
put:</div><div>$ mkdir /dev/cgroup/memory/1</div><div>$ echo 8m &gt; /dev/c=
group/memory/1/memory.limit_in_bytes</div><div>$ echo $$ &gt; /dev/cgroup/m=
emory/1/tasks</div>
<div>$ dd if=3D/dev/urandom of=3Dfile_20g bs=3D4096 count=3D524288</div><di=
v>$ cat /dev/cgroup/memory/1/memory.vmscan_stat</div><div>...</div><div>wri=
tten_pages_by_limit 36</div><div>written_anon_pages_by_limit 0</div><div>wr=
itten_file_pages_by_limit 36</div>
<div>...</div><div>written_pages_by_limit_under_hierarchy 28</div><div>writ=
ten_anon_pages_by_limit_under_hierarchy 0</div><div>written_file_pages_by_l=
imit_under_hierarchy 28</div><div><br></div><div>Signed-off-by: Andrew Bres=
ticker &lt;<a href=3D"mailto:abrestic@google.com">abrestic@google.com</a>&g=
t;</div>
<div>---</div><div>=A0include/linux/memcontrol.h | =A0 =A01 +</div><div>=A0=
mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 12 ++++++++++++</div><div>=A0m=
m/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 +++++++---</div><div>=A0=
3 files changed, 20 insertions(+), 3 deletions(-)</div>
<div><br></div><div>diff --git a/include/linux/memcontrol.h b/include/linux=
/memcontrol.h</div><div>index 4b49edf..4be907e 100644</div><div>--- a/inclu=
de/linux/memcontrol.h</div><div>+++ b/include/linux/memcontrol.h</div><div>
@@ -46,6 +46,7 @@ struct memcg_scanrecord {</div><div>=A0<span class=3D"App=
le-tab-span" style=3D"white-space:pre">	</span>unsigned long nr_scanned[2];=
 /* the number of scanned pages */</div><div>=A0<span class=3D"Apple-tab-sp=
an" style=3D"white-space:pre">	</span>unsigned long nr_rotated[2]; /* the n=
umber of rotated pages */</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>un=
signed long nr_freed[2]; /* the number of freed pages */</div><div>+<span c=
lass=3D"Apple-tab-span" style=3D"white-space:pre">	</span>unsigned long nr_=
written[2]; /* the number of pages written back */</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>un=
signed long elapsed; /* nsec of time elapsed while scanning */</div><div>=
=A0};</div><div>=A0</div><div>diff --git a/mm/memcontrol.c b/mm/memcontrol.=
c</div><div>
index 9bb6e93..5ec2aa3 100644</div><div>--- a/mm/memcontrol.c</div><div>+++=
 b/mm/memcontrol.c</div><div>@@ -221,6 +221,9 @@ enum {</div><div>=A0<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>FREED,</div><div=
>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>FREED_=
ANON,</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>FR=
EED_FILE,</div><div>+<span class=3D"Apple-tab-span" style=3D"white-space:pr=
e">	</span>WRITTEN,</div><div>+<span class=3D"Apple-tab-span" style=3D"whit=
e-space:pre">	</span>WRITTEN_ANON,</div>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>WRIT=
TEN_FILE,</div><div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:=
pre">	</span>ELAPSED,</div><div>=A0<span class=3D"Apple-tab-span" style=3D"=
white-space:pre">	</span>NR_SCANSTATS,</div>
<div>=A0};</div><div>@@ -241,6 +244,9 @@ const char *scanstat_string[NR_SCA=
NSTATS] =3D {</div><div>=A0<span class=3D"Apple-tab-span" style=3D"white-sp=
ace:pre">	</span>&quot;freed_pages&quot;,</div><div>=A0<span class=3D"Apple=
-tab-span" style=3D"white-space:pre">	</span>&quot;freed_anon_pages&quot;,<=
/div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>&q=
uot;freed_file_pages&quot;,</div><div>+<span class=3D"Apple-tab-span" style=
=3D"white-space:pre">	</span>&quot;written_pages&quot;,</div><div>+<span cl=
ass=3D"Apple-tab-span" style=3D"white-space:pre">	</span>&quot;written_anon=
_pages&quot;,</div>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>&quo=
t;written_file_pages&quot;,</div><div>=A0<span class=3D"Apple-tab-span" sty=
le=3D"white-space:pre">	</span>&quot;elapsed_ns&quot;,</div><div>=A0};</div=
><div>=A0#define SCANSTAT_WORD_LIMIT =A0 =A0&quot;_by_limit&quot;</div>
<div>@@ -1682,6 +1688,10 @@ static void __mem_cgroup_record_scanstat(unsign=
ed long *stats,</div><div>=A0 =A0 =A0 =A0 =A0stats[FREED_ANON] +=3D rec-&gt=
;nr_freed[0];</div><div>=A0 =A0 =A0 =A0 =A0stats[FREED_FILE] +=3D rec-&gt;n=
r_freed[1];</div><div>
=A0</div><div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</=
span>stats[WRITTEN] +=3D rec-&gt;nr_written[0] + rec-&gt;nr_written[1];</di=
v><div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>st=
ats[WRITTEN_ANON] +=3D rec-&gt;nr_written[0];</div>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>stat=
s[WRITTEN_FILE] +=3D rec-&gt;nr_written[1];</div><div>+</div><div>=A0 =A0 =
=A0 =A0 =A0stats[ELAPSED] +=3D rec-&gt;elapsed;</div><div>=A0}</div><div>=
=A0</div><div>@@ -1794,6 +1804,8 @@ static int mem_cgroup_hierarchical_recl=
aim(struct mem_cgroup *root_mem,</div>
<div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rec.nr_rotated[1] =3D 0;</div><div>=
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rec.nr_freed[0] =3D 0;</div><div>=A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0rec.nr_freed[1] =3D 0;</div><div>+<span class=
=3D"Apple-tab-span" style=3D"white-space:pre">		</span>rec.nr_written[0] =
=3D 0;</div>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">		</span>rec=
.nr_written[1] =3D 0;</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rec.elap=
sed =3D 0;</div><div>=A0<span class=3D"Apple-tab-span" style=3D"white-space=
:pre">		</span>/* we use swappiness of local cgroup */</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">		</span>i=
f (check_soft) {</div><div>diff --git a/mm/vmscan.c b/mm/vmscan.c</div><div=
>index 8fb1abd..f73b96e 100644</div><div>--- a/mm/vmscan.c</div><div>+++ b/=
mm/vmscan.c</div>
<div>@@ -719,7 +719,7 @@ static noinline_for_stack void free_page_list(stru=
ct list_head *free_pages)</div><div>=A0 */</div><div>=A0static unsigned lon=
g shrink_page_list(struct list_head *page_list,</div><div>=A0<span class=3D=
"Apple-tab-span" style=3D"white-space:pre">				</span> =A0 =A0 =A0struct zo=
ne *zone,</div>
<div>-<span class=3D"Apple-tab-span" style=3D"white-space:pre">				</span> =
=A0 =A0 =A0struct scan_control *sc)</div><div>+<span class=3D"Apple-tab-spa=
n" style=3D"white-space:pre">				</span> =A0 =A0 =A0struct scan_control *sc=
, int file)</div>
<div>=A0{</div><div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:=
pre">	</span>LIST_HEAD(ret_pages);</div><div>=A0<span class=3D"Apple-tab-sp=
an" style=3D"white-space:pre">	</span>LIST_HEAD(free_pages);</div><div>@@ -=
727,6 +727,7 @@ static unsigned long shrink_page_list(struct list_head *pag=
e_list,</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>un=
signed long nr_dirty =3D 0;</div><div>=A0<span class=3D"Apple-tab-span" sty=
le=3D"white-space:pre">	</span>unsigned long nr_congested =3D 0;</div><div>=
=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>unsigne=
d long nr_reclaimed =3D 0;</div>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>unsi=
gned long nr_written =3D 0;</div><div>=A0</div><div>=A0<span class=3D"Apple=
-tab-span" style=3D"white-space:pre">	</span>cond_resched();</div><div>=A0<=
/div><div>@@ -840,6 +841,7 @@ static unsigned long shrink_page_list(struct =
list_head *page_list,</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">			</span>=
case PAGE_ACTIVATE:</div><div>=A0<span class=3D"Apple-tab-span" style=3D"wh=
ite-space:pre">				</span>goto activate_locked;</div><div>=A0<span class=3D=
"Apple-tab-span" style=3D"white-space:pre">			</span>case PAGE_SUCCESS:</di=
v>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">				</span>n=
r_written++;</div><div>=A0<span class=3D"Apple-tab-span" style=3D"white-spa=
ce:pre">				</span>if (PageWriteback(page))</div><div>=A0<span class=3D"App=
le-tab-span" style=3D"white-space:pre">					</span>goto keep_lumpy;</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">				</span=
>if (PageDirty(page))</div><div>@@ -958,6 +960,8 @@ keep_lumpy:</div><div>=
=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>free_pa=
ge_list(&amp;free_pages);</div>
<div>=A0</div><div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:p=
re">	</span>list_splice(&amp;ret_pages, page_list);</div><div>+<span class=
=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if (!scanning_global_=
lru(sc))</div>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">		</span>sc-=
&gt;memcg_record-&gt;nr_written[file] +=3D nr_written;</div><div>=A0<span c=
lass=3D"Apple-tab-span" style=3D"white-space:pre">	</span>count_vm_events(P=
GACTIVATE, pgactivate);</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>re=
turn nr_reclaimed;</div><div>=A0}</div><div>@@ -1463,7 +1467,7 @@ shrink_in=
active_list(unsigned long nr_to_scan, struct zone *zone,</div><div>=A0</div=
><div>
=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>spin_un=
lock_irq(&amp;zone-&gt;lru_lock);</div><div>=A0</div><div>-<span class=3D"A=
pple-tab-span" style=3D"white-space:pre">	</span>nr_reclaimed =3D shrink_pa=
ge_list(&amp;page_list, zone, sc);</div>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>nr_r=
eclaimed =3D shrink_page_list(&amp;page_list, zone, sc, file);</div><div>=
=A0</div><div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>if (!scanning_global_lru(sc))</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">		</span>s=
c-&gt;memcg_record-&gt;nr_freed[file] +=3D nr_reclaimed;</div><div>@@ -1471=
,7 +1475,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *z=
one,</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>/*=
 Check if we should syncronously wait for writeback */</div><div>=A0<span c=
lass=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if (should_reclai=
m_stall(nr_taken, nr_reclaimed, priority, sc)) {</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">		</span>s=
et_reclaim_mode(priority, sc, true);</div><div>-<span class=3D"Apple-tab-sp=
an" style=3D"white-space:pre">		</span>nr_reclaimed +=3D shrink_page_list(&=
amp;page_list, zone, sc);</div>
<div>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">		</span>nr_=
reclaimed +=3D shrink_page_list(&amp;page_list, zone, sc, file);</div><div>=
=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>}</div>=
<div>=A0</div>
<div>=A0<span class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>lo=
cal_irq_disable();</div><div>--=A0</div><div>1.7.3.1</div><div><br></div><d=
iv>Thanks,</div><div>Andrew</div><br><div class=3D"gmail_quote">On Wed, Jul=
 13, 2011 at 5:02 PM, KAMEZAWA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;=
</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div><div></div><div class=3D"h5">On Tue, 1=
2 Jul 2011 16:02:02 -0700<br>
Andrew Bresticker &lt;<a href=3D"mailto:abrestic@google.com">abrestic@googl=
e.com</a>&gt; wrote:<br>
<br>
&gt; On Mon, Jul 11, 2011 at 3:30 AM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; This patch is onto mmotm-0710... got bigger than expected ;(<br>
&gt; &gt; =3D=3D<br>
&gt; &gt; [PATCH] add memory.vmscan_stat<br>
&gt; &gt;<br>
&gt; &gt; commit log of commit 0ae5e89 &quot; memcg: count the soft_limit r=
eclaim in...&quot;<br>
&gt; &gt; says it adds scanning stats to memory.stat file. But it doesn&#39=
;t because<br>
&gt; &gt; we considered we needed to make a concensus for such new APIs.<br=
>
&gt; &gt;<br>
&gt; &gt; This patch is a trial to add memory.scan_stat. This shows<br>
&gt; &gt; =A0- the number of scanned pages(total, anon, file)<br>
&gt; &gt; =A0- the number of rotated pages(total, anon, file)<br>
&gt; &gt; =A0- the number of freed pages(total, anon, file)<br>
&gt; &gt; =A0- the number of elaplsed time (including sleep/pause time)<br>
&gt; &gt;<br>
&gt; &gt; =A0for both of direct/soft reclaim.<br>
&gt; &gt;<br>
&gt; &gt; The biggest difference with oringinal Ying&#39;s one is that this=
 file<br>
&gt; &gt; can be reset by some write, as<br>
&gt; &gt;<br>
&gt; &gt; =A0# echo 0 ...../memory.scan_stat<br>
&gt; &gt;<br>
&gt; &gt; Example of output is here. This is a result after make -j 6 kerne=
l<br>
&gt; &gt; under 300M limit.<br>
&gt; &gt;<br>
&gt; &gt; [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat<br>
&gt; &gt; [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.vmscan_stat<br=
>
&gt; &gt; scanned_pages_by_limit 9471864<br>
&gt; &gt; scanned_anon_pages_by_limit 6640629<br>
&gt; &gt; scanned_file_pages_by_limit 2831235<br>
&gt; &gt; rotated_pages_by_limit 4243974<br>
&gt; &gt; rotated_anon_pages_by_limit 3971968<br>
&gt; &gt; rotated_file_pages_by_limit 272006<br>
&gt; &gt; freed_pages_by_limit 2318492<br>
&gt; &gt; freed_anon_pages_by_limit 962052<br>
&gt; &gt; freed_file_pages_by_limit 1356440<br>
&gt; &gt; elapsed_ns_by_limit 351386416101<br>
&gt; &gt; scanned_pages_by_system 0<br>
&gt; &gt; scanned_anon_pages_by_system 0<br>
&gt; &gt; scanned_file_pages_by_system 0<br>
&gt; &gt; rotated_pages_by_system 0<br>
&gt; &gt; rotated_anon_pages_by_system 0<br>
&gt; &gt; rotated_file_pages_by_system 0<br>
&gt; &gt; freed_pages_by_system 0<br>
&gt; &gt; freed_anon_pages_by_system 0<br>
&gt; &gt; freed_file_pages_by_system 0<br>
&gt; &gt; elapsed_ns_by_system 0<br>
&gt; &gt; scanned_pages_by_limit_under_hierarchy 9471864<br>
&gt; &gt; scanned_anon_pages_by_limit_under_hierarchy 6640629<br>
&gt; &gt; scanned_file_pages_by_limit_under_hierarchy 2831235<br>
&gt; &gt; rotated_pages_by_limit_under_hierarchy 4243974<br>
&gt; &gt; rotated_anon_pages_by_limit_under_hierarchy 3971968<br>
&gt; &gt; rotated_file_pages_by_limit_under_hierarchy 272006<br>
&gt; &gt; freed_pages_by_limit_under_hierarchy 2318492<br>
&gt; &gt; freed_anon_pages_by_limit_under_hierarchy 962052<br>
&gt; &gt; freed_file_pages_by_limit_under_hierarchy 1356440<br>
&gt; &gt; elapsed_ns_by_limit_under_hierarchy 351386416101<br>
&gt; &gt; scanned_pages_by_system_under_hierarchy 0<br>
&gt; &gt; scanned_anon_pages_by_system_under_hierarchy 0<br>
&gt; &gt; scanned_file_pages_by_system_under_hierarchy 0<br>
&gt; &gt; rotated_pages_by_system_under_hierarchy 0<br>
&gt; &gt; rotated_anon_pages_by_system_under_hierarchy 0<br>
&gt; &gt; rotated_file_pages_by_system_under_hierarchy 0<br>
&gt; &gt; freed_pages_by_system_under_hierarchy 0<br>
&gt; &gt; freed_anon_pages_by_system_under_hierarchy 0<br>
&gt; &gt; freed_file_pages_by_system_under_hierarchy 0<br>
&gt; &gt; elapsed_ns_by_system_under_hierarchy 0<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; total_xxxx is for hierarchy management.<br>
&gt; &gt;<br>
&gt; &gt; This will be useful for further memcg developments and need to be=
<br>
&gt; &gt; developped before we do some complicated rework on LRU/softlimit<=
br>
&gt; &gt; management.<br>
&gt; &gt;<br>
&gt; &gt; This patch adds a new struct memcg_scanrecord into scan_control s=
truct.<br>
&gt; &gt; sc-&gt;nr_scanned at el is not designed for exporting information=
. For<br>
&gt; &gt; example,<br>
&gt; &gt; nr_scanned is reset frequentrly and incremented +2 at scanning ma=
pped<br>
&gt; &gt; pages.<br>
&gt; &gt;<br>
&gt; &gt; For avoiding complexity, I added a new param in scan_control whic=
h is for<br>
&gt; &gt; exporting scanning score.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.h=
iroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; &gt;<br>
&gt; &gt; Changelog:<br>
&gt; &gt; =A0- renamed as vmscan_stat<br>
&gt; &gt; =A0- handle file/anon<br>
&gt; &gt; =A0- added &quot;rotated&quot;<br>
&gt; &gt; =A0- changed names of param in vmscan_stat.<br>
&gt; &gt; ---<br>
&gt; &gt; =A0Documentation/cgroups/memory.txt | =A0 85 +++++++++++++++++++<=
br>
&gt; &gt; =A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 19 ++++<br>
&gt; &gt; =A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 -<br>
&gt; &gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0172<br=
>
&gt; &gt; +++++++++++++++++++++++++++++++++++++--<br>
&gt; &gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 3=
9 +++++++-<br>
&gt; &gt; =A05 files changed, 303 insertions(+), 18 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; Index: mmotm-0710/Documentation/cgroups/memory.txt<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- mmotm-0710.orig/Documentation/cgroups/memory.txt<br>
&gt; &gt; +++ mmotm-0710/Documentation/cgroups/memory.txt<br>
&gt; &gt; @@ -380,7 +380,7 @@ will be charged as a new owner of it.<br>
&gt; &gt;<br>
&gt; &gt; =A05.2 stat file<br>
&gt; &gt;<br>
&gt; &gt; -memory.stat file includes following statistics<br>
&gt; &gt; +5.2.1 memory.stat file includes following statistics<br>
&gt; &gt;<br>
&gt; &gt; =A0# per-memory cgroup local status<br>
&gt; &gt; =A0cache =A0 =A0 =A0 =A0 =A0- # of bytes of page cache memory.<br=
>
&gt; &gt; @@ -438,6 +438,89 @@ Note:<br>
&gt; &gt; =A0 =A0 =A0 =A0 file_mapped is accounted only when the memory cgr=
oup is owner of<br>
&gt; &gt; page<br>
&gt; &gt; =A0 =A0 =A0 =A0 cache.)<br>
&gt; &gt;<br>
&gt; &gt; +5.2.2 memory.vmscan_stat<br>
&gt; &gt; +<br>
&gt; &gt; +memory.vmscan_stat includes statistics information for memory sc=
anning and<br>
&gt; &gt; +freeing, reclaiming. The statistics shows memory scanning inform=
ation<br>
&gt; &gt; since<br>
&gt; &gt; +memory cgroup creation and can be reset to 0 by writing 0 as<br>
&gt; &gt; +<br>
&gt; &gt; + #echo 0 &gt; ../memory.vmscan_stat<br>
&gt; &gt; +<br>
&gt; &gt; +This file contains following statistics.<br>
&gt; &gt; +<br>
&gt; &gt; +[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]<br>
&gt; &gt; +[param]_elapsed_ns_by_[reason]_[under_hierarchy]<br>
&gt; &gt; +<br>
&gt; &gt; +For example,<br>
&gt; &gt; +<br>
&gt; &gt; + =A0scanned_file_pages_by_limit indicates the number of scanned<=
br>
&gt; &gt; + =A0file pages at vmscan.<br>
&gt; &gt; +<br>
&gt; &gt; +Now, 3 parameters are supported<br>
&gt; &gt; +<br>
&gt; &gt; + =A0scanned - the number of pages scanned by vmscan<br>
&gt; &gt; + =A0rotated - the number of pages activated at vmscan<br>
&gt; &gt; + =A0freed =A0 - the number of pages freed by vmscan<br>
&gt; &gt; +<br>
&gt; &gt; +If &quot;rotated&quot; is high against scanned/freed, the memcg =
seems busy.<br>
&gt; &gt; +<br>
&gt; &gt; +Now, 2 reason are supported<br>
&gt; &gt; +<br>
&gt; &gt; + =A0limit - the memory cgroup&#39;s limit<br>
&gt; &gt; + =A0system - global memory pressure + softlimit<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 (global memory pressure not under softlimit=
 is not handled now)<br>
&gt; &gt; +<br>
&gt; &gt; +When under_hierarchy is added in the tail, the number indicates =
the<br>
&gt; &gt; +total memcg scan of its children and itself.<br>
&gt; &gt; +<br>
&gt; &gt; +elapsed_ns is a elapsed time in nanosecond. This may include sle=
ep time<br>
&gt; &gt; +and not indicates CPU usage. So, please take this as just showin=
g<br>
&gt; &gt; +latency.<br>
&gt; &gt; +<br>
&gt; &gt; +Here is an example.<br>
&gt; &gt; +<br>
&gt; &gt; +# cat /cgroup/memory/A/memory.vmscan_stat<br>
&gt; &gt; +scanned_pages_by_limit 9471864<br>
&gt; &gt; +scanned_anon_pages_by_limit 6640629<br>
&gt; &gt; +scanned_file_pages_by_limit 2831235<br>
&gt; &gt; +rotated_pages_by_limit 4243974<br>
&gt; &gt; +rotated_anon_pages_by_limit 3971968<br>
&gt; &gt; +rotated_file_pages_by_limit 272006<br>
&gt; &gt; +freed_pages_by_limit 2318492<br>
&gt; &gt; +freed_anon_pages_by_limit 962052<br>
&gt; &gt; +freed_file_pages_by_limit 1356440<br>
&gt; &gt; +elapsed_ns_by_limit 351386416101<br>
&gt; &gt; +scanned_pages_by_system 0<br>
&gt; &gt; +scanned_anon_pages_by_system 0<br>
&gt; &gt; +scanned_file_pages_by_system 0<br>
&gt; &gt; +rotated_pages_by_system 0<br>
&gt; &gt; +rotated_anon_pages_by_system 0<br>
&gt; &gt; +rotated_file_pages_by_system 0<br>
&gt; &gt; +freed_pages_by_system 0<br>
&gt; &gt; +freed_anon_pages_by_system 0<br>
&gt; &gt; +freed_file_pages_by_system 0<br>
&gt; &gt; +elapsed_ns_by_system 0<br>
&gt; &gt; +scanned_pages_by_limit_under_hierarchy 9471864<br>
&gt; &gt; +scanned_anon_pages_by_limit_under_hierarchy 6640629<br>
&gt; &gt; +scanned_file_pages_by_limit_under_hierarchy 2831235<br>
&gt; &gt; +rotated_pages_by_limit_under_hierarchy 4243974<br>
&gt; &gt; +rotated_anon_pages_by_limit_under_hierarchy 3971968<br>
&gt; &gt; +rotated_file_pages_by_limit_under_hierarchy 272006<br>
&gt; &gt; +freed_pages_by_limit_under_hierarchy 2318492<br>
&gt; &gt; +freed_anon_pages_by_limit_under_hierarchy 962052<br>
&gt; &gt; +freed_file_pages_by_limit_under_hierarchy 1356440<br>
&gt; &gt; +elapsed_ns_by_limit_under_hierarchy 351386416101<br>
&gt; &gt; +scanned_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +scanned_anon_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +scanned_file_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +rotated_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +rotated_anon_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +rotated_file_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +freed_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +freed_anon_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +freed_file_pages_by_system_under_hierarchy 0<br>
&gt; &gt; +elapsed_ns_by_system_under_hierarchy 0<br>
&gt; &gt; +<br>
&gt; &gt; =A05.3 swappiness<br>
&gt; &gt;<br>
&gt; &gt; =A0Similar to /proc/sys/vm/swappiness, but affecting a hierarchy =
of groups<br>
&gt; &gt; only.<br>
&gt; &gt; Index: mmotm-0710/include/linux/memcontrol.h<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- mmotm-0710.orig/include/linux/memcontrol.h<br>
&gt; &gt; +++ mmotm-0710/include/linux/memcontrol.h<br>
&gt; &gt; @@ -39,6 +39,16 @@ extern unsigned long mem_cgroup_isolate_<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0struct mem_cgroup *mem_cont,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0int active, int file);<br>
&gt; &gt;<br>
&gt; &gt; +struct memcg_scanrecord {<br>
&gt; &gt; + =A0 =A0 =A0 struct mem_cgroup *mem; /* scanend memory cgroup */=
<br>
&gt; &gt; + =A0 =A0 =A0 struct mem_cgroup *root; /* scan target hierarchy r=
oot */<br>
&gt; &gt; + =A0 =A0 =A0 int context; =A0 =A0 =A0 =A0 =A0 =A0/* scanning con=
text (see memcontrol.c) */<br>
&gt; &gt; + =A0 =A0 =A0 unsigned long nr_scanned[2]; /* the number of scann=
ed pages */<br>
&gt; &gt; + =A0 =A0 =A0 unsigned long nr_rotated[2]; /* the number of rotat=
ed pages */<br>
&gt; &gt; + =A0 =A0 =A0 unsigned long nr_freed[2]; /* the number of freed p=
ages */<br>
&gt; &gt; + =A0 =A0 =A0 unsigned long elapsed; /* nsec of time elapsed whil=
e scanning */<br>
&gt; &gt; +};<br>
&gt; &gt; +<br>
&gt; &gt; =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
&gt; &gt; =A0/*<br>
&gt; &gt; =A0* All &quot;charge&quot; functions with gfp_mask should use GF=
P_KERNEL or<br>
&gt; &gt; @@ -117,6 +127,15 @@ mem_cgroup_get_reclaim_stat_from_page(st<br>
&gt; &gt; =A0extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg=
,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0struct task_struct *p);<br>
&gt; &gt;<br>
&gt; &gt; +extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgr=
oup *mem,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool<br>
&gt; &gt; noswap,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct memcg_scanrecord<br>
&gt; &gt; *rec);<br>
&gt; &gt; +extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgro=
up *mem,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool<br>
&gt; &gt; noswap,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct memcg_scanrecord<br>
&gt; &gt; *rec,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned);<br>
&gt; &gt; +<br>
&gt; &gt; =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
&gt; &gt; =A0extern int do_swap_account;<br>
&gt; &gt; =A0#endif<br>
&gt; &gt; Index: mmotm-0710/include/linux/swap.h<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- mmotm-0710.orig/include/linux/swap.h<br>
&gt; &gt; +++ mmotm-0710/include/linux/swap.h<br>
&gt; &gt; @@ -253,12 +253,6 @@ static inline void lru_cache_add_file(st<br>
&gt; &gt; =A0/* linux/mm/vmscan.c */<br>
&gt; &gt; =A0extern unsigned long try_to_free_pages(struct zonelist *zoneli=
st, int<br>
&gt; &gt; order,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0gfp_t gfp_mask, nodemask_t *mask);<br>
&gt; &gt; -extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgr=
oup *mem,<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool<br>
&gt; &gt; noswap);<br>
&gt; &gt; -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgro=
up *mem,<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool<br>
&gt; &gt; noswap,<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone,<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned);<br>
&gt; &gt; =A0extern int __isolate_lru_page(struct page *page, int mode, int=
 file);<br>
&gt; &gt; =A0extern unsigned long shrink_all_memory(unsigned long nr_pages)=
;<br>
&gt; &gt; =A0extern int vm_swappiness;<br>
&gt; &gt; Index: mmotm-0710/mm/memcontrol.c<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- mmotm-0710.orig/mm/memcontrol.c<br>
&gt; &gt; +++ mmotm-0710/mm/memcontrol.c<br>
&gt; &gt; @@ -204,6 +204,50 @@ struct mem_cgroup_eventfd_list {<br>
&gt; &gt; =A0static void mem_cgroup_threshold(struct mem_cgroup *mem);<br>
&gt; &gt; =A0static void mem_cgroup_oom_notify(struct mem_cgroup *mem);<br>
&gt; &gt;<br>
&gt; &gt; +enum {<br>
&gt; &gt; + =A0 =A0 =A0 SCAN_BY_LIMIT,<br>
&gt; &gt; + =A0 =A0 =A0 SCAN_BY_SYSTEM,<br>
&gt; &gt; + =A0 =A0 =A0 NR_SCAN_CONTEXT,<br>
&gt; &gt; + =A0 =A0 =A0 SCAN_BY_SHRINK, /* not recorded now */<br>
&gt; &gt; +};<br>
&gt; &gt; +<br>
&gt; &gt; +enum {<br>
&gt; &gt; + =A0 =A0 =A0 SCAN,<br>
&gt; &gt; + =A0 =A0 =A0 SCAN_ANON,<br>
&gt; &gt; + =A0 =A0 =A0 SCAN_FILE,<br>
&gt; &gt; + =A0 =A0 =A0 ROTATE,<br>
&gt; &gt; + =A0 =A0 =A0 ROTATE_ANON,<br>
&gt; &gt; + =A0 =A0 =A0 ROTATE_FILE,<br>
&gt; &gt; + =A0 =A0 =A0 FREED,<br>
&gt; &gt; + =A0 =A0 =A0 FREED_ANON,<br>
&gt; &gt; + =A0 =A0 =A0 FREED_FILE,<br>
&gt; &gt; + =A0 =A0 =A0 ELAPSED,<br>
&gt; &gt; + =A0 =A0 =A0 NR_SCANSTATS,<br>
&gt; &gt; +};<br>
&gt; &gt; +<br>
&gt; &gt; +struct scanstat {<br>
&gt; &gt; + =A0 =A0 =A0 spinlock_t =A0 =A0 =A0lock;<br>
&gt; &gt; + =A0 =A0 =A0 unsigned long =A0 stats[NR_SCAN_CONTEXT][NR_SCANSTA=
TS];<br>
&gt; &gt; + =A0 =A0 =A0 unsigned long =A0 rootstats[NR_SCAN_CONTEXT][NR_SCA=
NSTATS];<br>
&gt; &gt; +};<br>
&gt; &gt;<br>
&gt;<br>
&gt; I&#39;m working on a similar effort with Ying here at Google and so fa=
r we&#39;ve<br>
&gt; been using per-cpu counters for these statistics instead of spin-lock<=
br>
&gt; protected counters. =A0Clearly the spin-lock protected counters have l=
ess<br>
&gt; memory overhead and make reading the stat file faster, but our concern=
 is<br>
&gt; that this method is inconsistent with the other memory stat files such=
<br>
&gt; /proc/vmstat and /dev/cgroup/memory/.../memory.stat. =A0Is there any<b=
r>
&gt; particular reason you chose to use spin-lock protected counters instea=
d of<br>
&gt; per-cpu counters?<br>
&gt;<br>
<br>
</div></div>In my experience, if we do &quot;batch&quot; enouch, it works a=
lways better than<br>
percpu-counter. percpu counter is effective when batching is difficult.<br>
This patch&#39;s implementation does enough batching and it&#39;s much coar=
se<br>
grained than percpu counter. Then, this patch is better than percpu.<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; I&#39;ve also modified your patch to use per-cpu counters instead of s=
pin-lock<br>
&gt; protected counters. =A0I tested it by doing streaming I/O from a ramdi=
sk:<br>
&gt;<br>
&gt; $ mke2fs /dev/ram1<br>
&gt; $ mkdir /tmp/swapram<br>
&gt; $ mkdir /tmp/swapram/ram1<br>
&gt; $ mount -t ext2 /dev/ram1 /tmp/swapram/ram1<br>
&gt; $ dd if=3D/dev/urandom of=3D/tmp/swapram/ram1/file_16m bs=3D4096 count=
=3D4096<br>
&gt; $ mkdir /dev/cgroup/memory/1<br>
&gt; $ echo 8m &gt; /dev/cgroup/memory/1<br>
&gt; $ ./ramdisk_load.sh 7<br>
&gt; $ echo $$ &gt; /dev/cgroup/memory/1/tasks<br>
&gt; $ time for ((z=3D0; z&lt;=3D2000; z++)); do cat /tmp/swapram/ram1/file=
_16m &gt;<br>
&gt; /dev/zero; done<br>
&gt;<br>
&gt; Where ramdisk_load.sh is:<br>
&gt; for ((i=3D0; i&lt;=3D$1; i++))<br>
&gt; do<br>
&gt; =A0 echo $$ &gt;/dev/cgroup/memory/1/tasks<br>
&gt; =A0 for ((z=3D0; z&lt;=3D2000; z++)); do cat /tmp/swapram/ram1/file_16=
m &gt; /dev/zero;<br>
&gt; done &amp;<br>
&gt; done<br>
&gt;<br>
&gt; Surprisingly, the per-cpu counters perform worse than the spin-lock<br=
>
&gt; protected counters. =A0Over 10 runs of the test above, the per-cpu cou=
nters<br>
&gt; were 1.60% slower in both real time and sys time. =A0I&#39;m wondering=
 if you have<br>
&gt; any insight as to why this is. =A0I can provide my diff against your p=
atch if<br>
&gt; necessary.<br>
&gt;<br>
<br>
</div></div>The percpu counte works effectively only when we use +1/-1 at e=
ach change of<br>
counters. It uses &quot;batch&quot; to merge the per-cpu value to the count=
er.<br>
I think you use default &quot;batch&quot; value but the scan/rotate/free/el=
apsed value<br>
is always larger than &quot;batch&quot; and you just added memory overhead =
and &quot;if&quot;<br>
to pure spinlock counters.<br>
<br>
Determining this &quot;batch&quot; threshold for percpu counter is difficul=
t.<br>
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
</blockquote></div><br></div>

--001636b2b9991f354304a81fe57c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
