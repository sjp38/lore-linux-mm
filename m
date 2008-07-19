Message-Id: <20080719133200.238194190@jp.fujitsu.com>
References: <20080719132959.550229715@jp.fujitsu.com>
Date: Sat, 19 Jul 2008 22:30:02 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [PATCH 3/3] add throttle to shrink_zone()
Content-Disposition: inline; filename=03-reclaim-throttle.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

changelog
========================================
  v7 -> v8
     o merge sysctl parameter patch.
     o remove Kconfig parameter.

  v6 -> v7
     o mark vm_max_nr_task_per_zone __read_mostly.
     o add check __GFP_FS, __GFP_IO for avoid deadlock.

  v5 -> v6
     o use PGFREE statics instead wall time.

  v3 -> v4:
     o fixed recursive shrink_zone problem.

  v2 -> v3:
     o use wake_up() instead wake_up_all()
     o max reclaimers can be changed Kconfig option and sysctl.

  v1 -> v2:
     o make per zone throttle 


benefit
=======================================
current VM implementation doesn't has limit of number of parallel reclaim.
when heavy workload, it bring to 2 bad things
  - heavy lock contention
  - unnecessary swap out

after this, reduce above two bad thing.
Then we get >800% performance improvement on stress load.



FAQ
===================================
- When throttled?

  1. Kswapd's reclaim processing is throttled.
     because kswapd is not related to interactive performance.

  2. Other direct reclaim can throttle.
     sc->may_cut_off parameter distinguish between direct reclaim and other.

     but few exception exist.

     - A task can't wait on recursive reclaim.
       because it already grab reclaim throttle ticket.
       Then, PF_RECLAIMING is introduced.

     - A task can't wait on I/O processing.
       if swapout is prevened, memory is never freed.
       Then __GFP_IO and/or __GFP_FS checking is necessary.


- Why is free memory checked every "(required pages + zone->pages_high) x 4" pages freed ?

  Basically, if system free memory has over "required pages + zone->pages_high",
  We can get required page and kswapd can stop reclaim.
  IOW, We can stop direct reclaim without any side effect.

  In addition, on heavy workload,
  many task allocate page freqently and many other task reclaim pages frequently.
  Then, number of self reclaimed pages is not proposional system free memory.

  So, watching of system free memory is good idea.

  Unfortunately, zone_water_mark_ok() is costly functiion.
  thus, if it is frequently called, performance degression happend.
  Then rarely calling is better.
  x4 is nice balanced value that cost and gain.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 Documentation/filesystems/proc.txt |    8 ++++
 include/linux/mmzone.h             |    2 +
 include/linux/sched.h              |    1 
 include/linux/swap.h               |    2 +
 kernel/sysctl.c                    |    9 +++++
 mm/page_alloc.c                    |    3 +
 mm/vmscan.c                        |   66 ++++++++++++++++++++++++++++++++++++-
 7 files changed, 90 insertions(+), 1 deletion(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -405,6 +405,8 @@ struct zone {
 	unsigned long		spanned_pages;	/* total size, including holes */
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
+	atomic_t		nr_reclaimers;
+	wait_queue_head_t	reclaim_throttle_waitq;
 	/*
 	 * rarely used fields:
 	 */
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3576,6 +3576,9 @@ static void __paginginit free_area_init_
 		zone->recent_scanned[1] = 0;
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
+		atomic_set(&zone->nr_reclaimers, 0);
+		init_waitqueue_head(&zone->reclaim_throttle_waitq);
+
 		if (!size)
 			continue;
 
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -76,6 +76,11 @@ struct scan_control {
 
 	int order;
 
+	/* Can shrink be cutted off if other task freeded enough page. */
+	int may_cut_off;
+
+	unsigned long was_freed;
+
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
 
@@ -124,6 +129,7 @@ long vm_total_pages;	/* The total number
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
+int vm_max_reclaiming_task_per_zone __read_mostly = 3;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 #define scan_global_lru(sc)	(!(sc)->mem_cgroup)
@@ -1451,6 +1457,55 @@ static int shrink_zone(int priority, str
 	unsigned long nr_reclaimed = 0;
 	unsigned long percent[2];	/* anon @ 0; file @ 1 */
 	enum lru_list l;
+	int ret = 0;
+	int throttle_on = 0;
+	unsigned long freed;
+	unsigned long threshold;
+	int mask = __GFP_IO | __GFP_FS;
+
+	/* !__GFP_IO and/or !__GFP_FS indicate this task may grab some locks.
+	   thus, if the task wait on, it may cause deadlock. */
+	if ((sc->gfp_mask & mask) != mask)
+		goto shrinking;
+
+	/* avoid recursing wait_evnet for avoid deadlock. */
+	if (current->flags & PF_RECLAIMING)
+		goto shrinking;
+
+	throttle_on = 1;
+	current->flags |= PF_RECLAIMING;
+	wait_event(zone->reclaim_throttle_waitq,
+		   atomic_add_unless(&zone->nr_reclaimers, 1,
+				     vm_max_reclaiming_task_per_zone));
+
+
+	/* in some situation (e.g. hibernation), shrink processing shouldn't be
+	   cut off even though large memory is already freeded.  */
+	if (!sc->may_cut_off)
+		goto shrinking;
+
+	/* kswapd isn't related to latency. */
+	if (current->flags & PF_KSWAPD)
+		goto shrinking;
+
+	/* zone_water_mark_ok() is costly functiion.
+	   thus, if it is frequently called, performance degression happend.
+	   x4 is nice balanced value that cost and gain. */
+	threshold = ((1 << sc->order) + zone->pages_high) * 4;
+	freed = get_vm_event(PGFREE);
+
+	/* reclaim still necessary? */
+	if (scan_global_lru(sc) &&
+	    freed - sc->was_freed >= threshold) {
+		if (zone_watermark_ok(zone, sc->order, zone->pages_high,
+				      gfp_zone(sc->gfp_mask), 0)) {
+			ret = -EAGAIN;
+			goto out;
+		}
+		sc->was_freed = freed;
+	}
+
+shrinking:
 
 	get_scan_ratio(zone, sc, percent);
 
@@ -1505,9 +1560,16 @@ static int shrink_zone(int priority, str
 	if (scan_global_lru(sc) && inactive_anon_is_low(zone))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
+out:
+	if (throttle_on) {
+		current->flags &= ~PF_RECLAIMING;
+		atomic_dec(&zone->nr_reclaimers);
+		wake_up(&zone->reclaim_throttle_waitq);
+	}
+
 	sc->nr_reclaimed += nr_reclaimed;
 	throttle_vm_writeout(sc->gfp_mask);
-	return 0;
+	return ret;
 }
 
 /*
@@ -1708,6 +1770,8 @@ unsigned long try_to_free_pages(struct z
 		.order = order,
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
+		.may_cut_off = 1,
+		.was_freed = get_vm_event(PGFREE),
 	};
 
 	return do_try_to_free_pages(zonelist, &sc);
Index: b/include/linux/sched.h
===================================================================
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1480,6 +1480,7 @@ static inline void put_task_struct(struc
 #define PF_EXITPIDONE	0x00000008	/* pi exit done on shut down */
 #define PF_VCPU		0x00000010	/* I'm a virtual CPU */
 #define PF_FORKNOEXEC	0x00000040	/* forked but didn't exec */
+#define PF_RECLAIMING   0x00000080      /* task have page reclaim throttling ticket */
 #define PF_SUPERPRIV	0x00000100	/* used super-user privileges */
 #define PF_DUMPCORE	0x00000200	/* dumped core */
 #define PF_SIGNALED	0x00000400	/* killed by a signal */
Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -263,6 +263,8 @@ static inline void scan_unevictable_unre
 
 extern int kswapd_run(int nid);
 
+extern int vm_max_reclaiming_task_per_zone;
+
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
Index: b/kernel/sysctl.c
===================================================================
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1184,6 +1184,15 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= &scan_unevictable_handler,
 	},
 #endif
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "max_reclaiming_tasks_per_zone",
+		.data           = &vm_max_reclaiming_task_per_zone,
+		.maxlen         = sizeof(vm_max_reclaiming_task_per_zone),
+		.mode           = 0644,
+		.proc_handler   = &proc_dointvec,
+		.strategy       = &sysctl_intvec,
+	},
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
Index: b/Documentation/filesystems/proc.txt
===================================================================
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1613,6 +1613,14 @@ To free pagecache, dentries and inodes:
 As this is a non-destructive operation and dirty objects are not freeable, the
 user should run `sync' first.
 
+max_reclaiming_tasks_per_zone
+-----------------------------
+
+This file contains the number of threads which can do page reclaim
+in a zone simultaneously.
+If this is too big, performance under heavy memory pressure will decrease.
+
+
 
 2.5 /proc/sys/dev - Device specific parameters
 ----------------------------------------------

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
