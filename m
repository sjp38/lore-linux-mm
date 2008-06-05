Message-Id: <20080605021505.306358710@jp.fujitsu.com>
References: <20080605021211.871673550@jp.fujitsu.com>
Date: Thu, 05 Jun 2008 11:12:15 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [PATCH 4/5] add throttle to shrink_zone()
Content-Disposition: inline; filename=04-reclaim-throttle-v7.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

add throttle to shrink_zone() for performance improvement and prevent incorrect oom.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/mmzone.h |    2 +
 include/linux/sched.h  |    1 
 mm/Kconfig             |   10 +++++++
 mm/page_alloc.c        |    3 ++
 mm/vmscan.c            |   62 ++++++++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 77 insertions(+), 1 deletion(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -328,6 +328,8 @@ struct zone {
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
@@ -3500,6 +3500,9 @@ static void __paginginit free_area_init_
 		zone->nr_scan_inactive = 0;
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
@@ -74,6 +74,11 @@ struct scan_control {
 
 	int order;
 
+	/* Can shrink be cutted off if other task freeded enough page. */
+	int may_cut_off;
+
+	unsigned long was_freed;
+
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
 
@@ -120,6 +125,7 @@ struct scan_control {
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
+#define MAX_RECLAIM_TASKS CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
@@ -1187,7 +1193,52 @@ static int shrink_zone(int priority, str
 	unsigned long nr_inactive;
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
+	int ret = 0;
+	int throttle_on = 0;
+	unsigned long freed;
+	unsigned long threshold;
+
+	/* !__GFP_IO and/or !__GFP_FS task may grab some locks.
+	   thus, if these tasks wait on other, it may cause deadlock. */
+	if ((sc->gfp_mask & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS))
+		goto shrinking;
+
+	/* avoid recursing wait_evnet for avoid deadlock. */
+	if (current->flags & PF_RECLAIMING)
+		goto shrinking;
+
+	throttle_on = 1;
+	current->flags |= PF_RECLAIMING;
+	wait_event(zone->reclaim_throttle_waitq,
+		 atomic_add_unless(&zone->nr_reclaimers, 1, MAX_RECLAIM_TASKS));
+
+
+	/* in some situation (e.g. hibernation), shrink processing shouldn't be
+	   cut off even though large memory freeded.  */
+	if (!sc->may_cut_off)
+		goto shrinking;
+
+	/* kswapd is no related for user latency experience. */
+	if (current->flags & PF_KSWAPD)
+		goto shrinking;
+
+	/* x4 ratio mean we want rarely check.
+	   because frequently check decrease performance. */
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
 
+shrinking:
 	if (scan_global_lru(sc)) {
 		/*
 		 * Add one to nr_to_scan just to make sure that the kernel
@@ -1239,9 +1290,16 @@ static int shrink_zone(int priority, str
 		}
 	}
 
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
@@ -1439,6 +1497,8 @@ unsigned long try_to_free_pages(struct z
 		.order = order,
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
+		.may_cut_off = 1,
+		.was_freed = get_vm_event(PGFREE),
 	};
 
 	return do_try_to_free_pages(zonelist, &sc);
Index: b/mm/Kconfig
===================================================================
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -205,3 +205,13 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config NR_MAX_RECLAIM_TASKS_PER_ZONE
+	int "maximum number of reclaiming tasks at the same time"
+	default 3
+	help
+	  This value determines the number of threads which can do page reclaim
+	  in a zone simultaneously. If this is too big, performance under heavy memory
+	  pressure will decrease.
+	  If unsure, use default.
+
Index: b/include/linux/sched.h
===================================================================
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1510,6 +1510,7 @@ static inline void put_task_struct(struc
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezeable */
+#define PF_RECLAIMING   0x80000000      /* The task have page reclaim throttling ticket */
 
 /*
  * Only the _current_ task can read/write to tsk->flags, but other

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
