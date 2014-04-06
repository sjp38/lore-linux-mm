Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id F0A316B0036
	for <linux-mm@kvack.org>; Sun,  6 Apr 2014 11:33:56 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id p9so3929430lbv.18
        for <linux-mm@kvack.org>; Sun, 06 Apr 2014 08:33:56 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g7si10115103lab.61.2014.04.06.08.33.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Apr 2014 08:33:54 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/3] mem-hotplug: turn mem_hotplug_mutex to rwsem
Date: Sun, 6 Apr 2014 19:33:50 +0400
Message-ID: <7c095d71a25d7adc66c11e0ffa6f7f8ad3f559eb.1396779337.git.vdavydov@parallels.com>
In-Reply-To: <cover.1396779337.git.vdavydov@parallels.com>
References: <cover.1396779337.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

{un}lock_memory_hotplug is used to synchronize against memory hotplug.
Currently it is backed by a mutex, which makes it a bit of hammer -
threads that only want to get a stable value of online nodes mask won't
be able to proceed concurrently.

This patch fixes this by turning mem_hotplug_mutex to an rw sempahore so
that lock_memory_hotplug only takes it for reading while the memory
hotplug code locks it for writing. This will allow to invoke code under
{un}lock_memory_hotplug concurrently while still guaranteeing protection
against memory hotplug.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/mmzone.h |    7 +++--
 mm/memory_hotplug.c    |   70 +++++++++++++++++++++---------------------------
 mm/vmscan.c            |    2 +-
 3 files changed, 35 insertions(+), 44 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fac5509c18f0..586cc2d2c25e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -481,9 +481,8 @@ struct zone {
 	 * give them a chance of being in the same cacheline.
 	 *
 	 * Write access to present_pages at runtime should be protected by
-	 * lock_memory_hotplug()/unlock_memory_hotplug().  Any reader who can't
-	 * tolerant drift of present_pages should hold memory hotplug lock to
-	 * get a stable value.
+	 * mem_hotplug_sem. Any reader who can't tolerant drift of
+	 * present_pages should take it for reading to get a stable value.
 	 *
 	 * Read access to managed_pages should be safe because it's unsigned
 	 * long. Write access to zone->managed_pages and totalram_pages are
@@ -766,7 +765,7 @@ typedef struct pglist_data {
 	nodemask_t reclaim_nodes;	/* Nodes allowed to reclaim from */
 	wait_queue_head_t kswapd_wait;
 	wait_queue_head_t pfmemalloc_wait;
-	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
+	struct task_struct *kswapd;	/* Protected by mem_hotplug_sem */
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a650db29606f..052db2e72035 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -31,6 +31,7 @@
 #include <linux/stop_machine.h>
 #include <linux/hugetlb.h>
 #include <linux/memblock.h>
+#include <linux/rwsem.h>
 
 #include <asm/tlbflush.h>
 
@@ -47,16 +48,16 @@ static void generic_online_page(struct page *page);
 
 static online_page_callback_t online_page_callback = generic_online_page;
 
-DEFINE_MUTEX(mem_hotplug_mutex);
+static DECLARE_RWSEM(mem_hotplug_sem);
 
 void lock_memory_hotplug(void)
 {
-	mutex_lock(&mem_hotplug_mutex);
+	down_read(&mem_hotplug_sem);
 }
 
 void unlock_memory_hotplug(void)
 {
-	mutex_unlock(&mem_hotplug_mutex);
+	up_read(&mem_hotplug_sem);
 }
 
 
@@ -727,14 +728,14 @@ int set_online_page_callback(online_page_callback_t callback)
 {
 	int rc = -EINVAL;
 
-	lock_memory_hotplug();
+	down_write(&mem_hotplug_sem);
 
 	if (online_page_callback == generic_online_page) {
 		online_page_callback = callback;
 		rc = 0;
 	}
 
-	unlock_memory_hotplug();
+	up_write(&mem_hotplug_sem);
 
 	return rc;
 }
@@ -744,14 +745,14 @@ int restore_online_page_callback(online_page_callback_t callback)
 {
 	int rc = -EINVAL;
 
-	lock_memory_hotplug();
+	down_write(&mem_hotplug_sem);
 
 	if (online_page_callback == callback) {
 		online_page_callback = generic_online_page;
 		rc = 0;
 	}
 
-	unlock_memory_hotplug();
+	up_write(&mem_hotplug_sem);
 
 	return rc;
 }
@@ -899,7 +900,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int ret;
 	struct memory_notify arg;
 
-	lock_memory_hotplug();
+	down_write(&mem_hotplug_sem);
 	/*
 	 * This doesn't need a lock to do pfn_to_page().
 	 * The section can't be removed here because of the
@@ -907,23 +908,18 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 */
 	zone = page_zone(pfn_to_page(pfn));
 
+	ret = -EINVAL;
 	if ((zone_idx(zone) > ZONE_NORMAL || online_type == ONLINE_MOVABLE) &&
-	    !can_online_high_movable(zone)) {
-		unlock_memory_hotplug();
-		return -EINVAL;
-	}
+	    !can_online_high_movable(zone))
+		goto out;
 
 	if (online_type == ONLINE_KERNEL && zone_idx(zone) == ZONE_MOVABLE) {
-		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages)) {
-			unlock_memory_hotplug();
-			return -EINVAL;
-		}
+		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages))
+			goto out;
 	}
 	if (online_type == ONLINE_MOVABLE && zone_idx(zone) == ZONE_MOVABLE - 1) {
-		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages)) {
-			unlock_memory_hotplug();
-			return -EINVAL;
-		}
+		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages))
+			goto out;
 	}
 
 	/* Previous code may changed the zone of the pfn range */
@@ -939,8 +935,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	ret = notifier_to_errno(ret);
 	if (ret) {
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		unlock_memory_hotplug();
-		return ret;
+		goto out;
 	}
 	/*
 	 * If this zone is not populated, then it is not in zonelist.
@@ -964,8 +959,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		       (((unsigned long long) pfn + nr_pages)
 			    << PAGE_SHIFT) - 1);
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		unlock_memory_hotplug();
-		return ret;
+		goto out;
 	}
 
 	zone->present_pages += onlined_pages;
@@ -995,9 +989,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
-	unlock_memory_hotplug();
-
-	return 0;
+out:
+	up_write(&mem_hotplug_sem);
+	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
@@ -1055,7 +1049,7 @@ int try_online_node(int nid)
 	if (node_online(nid))
 		return 0;
 
-	lock_memory_hotplug();
+	down_write(&mem_hotplug_sem);
 	pgdat = hotadd_new_pgdat(nid, 0);
 	if (!pgdat) {
 		pr_err("Cannot online node %d due to NULL pgdat\n", nid);
@@ -1073,7 +1067,7 @@ int try_online_node(int nid)
 	}
 
 out:
-	unlock_memory_hotplug();
+	up_write(&mem_hotplug_sem);
 	return ret;
 }
 
@@ -1117,7 +1111,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 		new_pgdat = !p;
 	}
 
-	lock_memory_hotplug();
+	down_write(&mem_hotplug_sem);
 
 	new_node = !node_online(nid);
 	if (new_node) {
@@ -1158,7 +1152,7 @@ error:
 	release_memory_resource(res);
 
 out:
-	unlock_memory_hotplug();
+	up_write(&mem_hotplug_sem);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
@@ -1565,7 +1559,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	if (!test_pages_in_a_zone(start_pfn, end_pfn))
 		return -EINVAL;
 
-	lock_memory_hotplug();
+	down_write(&mem_hotplug_sem);
 
 	zone = page_zone(pfn_to_page(start_pfn));
 	node = zone_to_nid(zone);
@@ -1672,7 +1666,7 @@ repeat:
 	writeback_set_ratelimit();
 
 	memory_notify(MEM_OFFLINE, &arg);
-	unlock_memory_hotplug();
+	up_write(&mem_hotplug_sem);
 	return 0;
 
 failed_removal:
@@ -1684,7 +1678,7 @@ failed_removal:
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 
 out:
-	unlock_memory_hotplug();
+	up_write(&mem_hotplug_sem);
 	return ret;
 }
 
@@ -1888,7 +1882,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 
 	BUG_ON(check_hotplug_memory_range(start, size));
 
-	lock_memory_hotplug();
+	down_write(&mem_hotplug_sem);
 
 	/*
 	 * All memory blocks must be offlined before removing memory.  Check
@@ -1897,10 +1891,8 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 	 */
 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
 				check_memblock_offlined_cb);
-	if (ret) {
-		unlock_memory_hotplug();
+	if (ret)
 		BUG();
-	}
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
@@ -1909,7 +1901,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 
 	try_offline_node(nid);
 
-	unlock_memory_hotplug();
+	up_write(&mem_hotplug_sem);
 }
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 06879ead7380..b6fe28a5dcd1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3418,7 +3418,7 @@ int kswapd_run(int nid)
 
 /*
  * Called by memory hotplug when all memory in a node is offlined.  Caller must
- * hold lock_memory_hotplug().
+ * hold mem_hotplug_sem for writing.
  */
 void kswapd_stop(int nid)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
