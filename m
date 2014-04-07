Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id BF8476B0038
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 05:45:40 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id c6so4599203lan.3
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 02:45:39 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h4si11770310lae.25.2014.04.07.02.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Apr 2014 02:45:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 1/2] mem-hotplug: implement get/put_online_mems
Date: Mon, 7 Apr 2014 13:45:34 +0400
Message-ID: <b65ff63d5805c86fa288bc09db4f378492c6c543.1396857765.git.vdavydov@parallels.com>
In-Reply-To: <cover.1396857765.git.vdavydov@parallels.com>
References: <cover.1396857765.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

{un}lock_memory_hotplug, which is used to synchronize against memory
hotplug, is currently backed by a mutex, which makes it a bit of a
hammer - threads that only want to get a stable value of online nodes
mask won't be able to proceed concurrently. Also, it imposes some strong
locking ordering rules on it, which narrows down the set of its usage
scenarios.

This patch introduces get/put_online_mems, which are the same as
get/put_online_cpus, but for memory hotplug, i.e. executing a code
inside a get/put_online_mems section will guarantee a stable value of
online nodes, present pages, etc.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memory_hotplug.h |   14 ++--
 include/linux/mmzone.h         |    8 +--
 mm/kmemleak.c                  |    4 +-
 mm/memory-failure.c            |    8 +--
 mm/memory_hotplug.c            |  142 ++++++++++++++++++++++++++++------------
 mm/slub.c                      |    4 +-
 mm/vmscan.c                    |    2 +-
 7 files changed, 116 insertions(+), 66 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 4ca3d951fe91..010d125bffbf 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -187,14 +187,8 @@ extern void put_page_bootmem(struct page *page);
 extern void get_page_bootmem(unsigned long ingo, struct page *page,
 			     unsigned long type);
 
-/*
- * Lock for memory hotplug guarantees 1) all callbacks for memory hotplug
- * notifier will be called under this. 2) offline/online/add/remove memory
- * will not run simultaneously.
- */
-
-void lock_memory_hotplug(void);
-void unlock_memory_hotplug(void);
+void get_online_mems(void);
+void put_online_mems(void);
 
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
@@ -232,8 +226,8 @@ static inline int try_online_node(int nid)
 	return 0;
 }
 
-static inline void lock_memory_hotplug(void) {}
-static inline void unlock_memory_hotplug(void) {}
+static inline void get_online_mems(void) {}
+static inline void put_online_mems(void) {}
 
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fac5509c18f0..78b141bb3e6b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -481,9 +481,8 @@ struct zone {
 	 * give them a chance of being in the same cacheline.
 	 *
 	 * Write access to present_pages at runtime should be protected by
-	 * lock_memory_hotplug()/unlock_memory_hotplug().  Any reader who can't
-	 * tolerant drift of present_pages should hold memory hotplug lock to
-	 * get a stable value.
+	 * mem_hotplug_begin/end(). Any reader who can't tolerant drift of
+	 * present_pages should get_online_mems() to get a stable value.
 	 *
 	 * Read access to managed_pages should be safe because it's unsigned
 	 * long. Write access to zone->managed_pages and totalram_pages are
@@ -766,7 +765,8 @@ typedef struct pglist_data {
 	nodemask_t reclaim_nodes;	/* Nodes allowed to reclaim from */
 	wait_queue_head_t kswapd_wait;
 	wait_queue_head_t pfmemalloc_wait;
-	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
+	struct task_struct *kswapd;	/* Protected by
+					   mem_hotplug_begin/end() */
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index c352c63e8de3..044f72d73bd4 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1299,7 +1299,7 @@ static void kmemleak_scan(void)
 	/*
 	 * Struct page scanning for each node.
 	 */
-	lock_memory_hotplug();
+	get_online_mems();
 	for_each_online_node(i) {
 		unsigned long start_pfn = node_start_pfn(i);
 		unsigned long end_pfn = node_end_pfn(i);
@@ -1317,7 +1317,7 @@ static void kmemleak_scan(void)
 			scan_block(page, page + 1, NULL, 1);
 		}
 	}
-	unlock_memory_hotplug();
+	put_online_mems();
 
 	/*
 	 * Scanning the task stacks (may introduce false negatives).
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 12ac5df4d49a..efb55b364ac1 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1661,11 +1661,7 @@ int soft_offline_page(struct page *page, int flags)
 		}
 	}
 
-	/*
-	 * The lock_memory_hotplug prevents a race with memory hotplug.
-	 * This is a big hammer, a better would be nicer.
-	 */
-	lock_memory_hotplug();
+	get_online_mems();
 
 	/*
 	 * Isolate the page, so that it doesn't get reallocated if it
@@ -1676,7 +1672,7 @@ int soft_offline_page(struct page *page, int flags)
 		set_migratetype_isolate(page, true);
 
 	ret = get_any_page(page, pfn, flags);
-	unlock_memory_hotplug();
+	put_online_mems();
 	if (ret > 0) { /* for in-use pages */
 		if (PageHuge(page))
 			ret = soft_offline_huge_page(page, flags);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a650db29606f..2906873a1502 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -46,19 +46,84 @@
 static void generic_online_page(struct page *page);
 
 static online_page_callback_t online_page_callback = generic_online_page;
+static DEFINE_MUTEX(online_page_callback_lock);
 
-DEFINE_MUTEX(mem_hotplug_mutex);
+/* The same as the cpu_hotplug lock, but for memory hotplug. */
+static struct {
+	struct task_struct *active_writer;
+	struct mutex lock; /* Synchronizes accesses to refcount, */
+	/*
+	 * Also blocks the new readers during
+	 * an ongoing mem hotplug operation.
+	 */
+	int refcount;
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lockdep_map dep_map;
+#endif
+} mem_hotplug = {
+	.active_writer = NULL,
+	.lock = __MUTEX_INITIALIZER(mem_hotplug.lock),
+	.refcount = 0,
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	.dep_map = {.name = "mem_hotplug.lock" },
+#endif
+};
+
+/* Lockdep annotations for get/put_online_mems() and mem_hotplug_begin/end() */
+#define memhp_lock_acquire_read() lock_map_acquire_read(&mem_hotplug.dep_map)
+#define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
+#define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
+
+void get_online_mems(void)
+{
+	might_sleep();
+	if (mem_hotplug.active_writer == current)
+		return;
+	memhp_lock_acquire_read();
+	mutex_lock(&mem_hotplug.lock);
+	mem_hotplug.refcount++;
+	mutex_unlock(&mem_hotplug.lock);
+
+}
 
-void lock_memory_hotplug(void)
+void put_online_mems(void)
 {
-	mutex_lock(&mem_hotplug_mutex);
+	if (mem_hotplug.active_writer == current)
+		return;
+	mutex_lock(&mem_hotplug.lock);
+
+	if (WARN_ON(!mem_hotplug.refcount))
+		mem_hotplug.refcount++; /* try to fix things up */
+
+	if (!--mem_hotplug.refcount && unlikely(mem_hotplug.active_writer))
+		wake_up_process(mem_hotplug.active_writer);
+	mutex_unlock(&mem_hotplug.lock);
+	memhp_lock_release();
+
 }
 
-void unlock_memory_hotplug(void)
+static void mem_hotplug_begin(void)
 {
-	mutex_unlock(&mem_hotplug_mutex);
+	mem_hotplug.active_writer = current;
+
+	memhp_lock_acquire();
+	for (;;) {
+		mutex_lock(&mem_hotplug.lock);
+		if (likely(!mem_hotplug.refcount))
+			break;
+		__set_current_state(TASK_UNINTERRUPTIBLE);
+		mutex_unlock(&mem_hotplug.lock);
+		schedule();
+	}
 }
 
+static void mem_hotplug_done(void)
+{
+	mem_hotplug.active_writer = NULL;
+	mutex_unlock(&mem_hotplug.lock);
+	memhp_lock_release();
+}
 
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
@@ -727,14 +792,16 @@ int set_online_page_callback(online_page_callback_t callback)
 {
 	int rc = -EINVAL;
 
-	lock_memory_hotplug();
+	get_online_mems();
+	mutex_lock(&online_page_callback_lock);
 
 	if (online_page_callback == generic_online_page) {
 		online_page_callback = callback;
 		rc = 0;
 	}
 
-	unlock_memory_hotplug();
+	mutex_unlock(&online_page_callback_lock);
+	put_online_mems();
 
 	return rc;
 }
@@ -744,14 +811,16 @@ int restore_online_page_callback(online_page_callback_t callback)
 {
 	int rc = -EINVAL;
 
-	lock_memory_hotplug();
+	get_online_mems();
+	mutex_lock(&online_page_callback_lock);
 
 	if (online_page_callback == callback) {
 		online_page_callback = generic_online_page;
 		rc = 0;
 	}
 
-	unlock_memory_hotplug();
+	mutex_unlock(&online_page_callback_lock);
+	put_online_mems();
 
 	return rc;
 }
@@ -899,7 +968,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int ret;
 	struct memory_notify arg;
 
-	lock_memory_hotplug();
+	mem_hotplug_begin();
 	/*
 	 * This doesn't need a lock to do pfn_to_page().
 	 * The section can't be removed here because of the
@@ -907,23 +976,18 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
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
@@ -939,8 +1003,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	ret = notifier_to_errno(ret);
 	if (ret) {
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		unlock_memory_hotplug();
-		return ret;
+		goto out;
 	}
 	/*
 	 * If this zone is not populated, then it is not in zonelist.
@@ -964,8 +1027,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		       (((unsigned long long) pfn + nr_pages)
 			    << PAGE_SHIFT) - 1);
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		unlock_memory_hotplug();
-		return ret;
+		goto out;
 	}
 
 	zone->present_pages += onlined_pages;
@@ -995,9 +1057,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
-	unlock_memory_hotplug();
-
-	return 0;
+out:
+	mem_hotplug_done();
+	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
@@ -1055,7 +1117,7 @@ int try_online_node(int nid)
 	if (node_online(nid))
 		return 0;
 
-	lock_memory_hotplug();
+	mem_hotplug_begin();
 	pgdat = hotadd_new_pgdat(nid, 0);
 	if (!pgdat) {
 		pr_err("Cannot online node %d due to NULL pgdat\n", nid);
@@ -1073,7 +1135,7 @@ int try_online_node(int nid)
 	}
 
 out:
-	unlock_memory_hotplug();
+	mem_hotplug_done();
 	return ret;
 }
 
@@ -1117,7 +1179,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 		new_pgdat = !p;
 	}
 
-	lock_memory_hotplug();
+	mem_hotplug_begin();
 
 	new_node = !node_online(nid);
 	if (new_node) {
@@ -1158,7 +1220,7 @@ error:
 	release_memory_resource(res);
 
 out:
-	unlock_memory_hotplug();
+	mem_hotplug_done();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
@@ -1565,7 +1627,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	if (!test_pages_in_a_zone(start_pfn, end_pfn))
 		return -EINVAL;
 
-	lock_memory_hotplug();
+	mem_hotplug_begin();
 
 	zone = page_zone(pfn_to_page(start_pfn));
 	node = zone_to_nid(zone);
@@ -1672,7 +1734,7 @@ repeat:
 	writeback_set_ratelimit();
 
 	memory_notify(MEM_OFFLINE, &arg);
-	unlock_memory_hotplug();
+	mem_hotplug_done();
 	return 0;
 
 failed_removal:
@@ -1684,7 +1746,7 @@ failed_removal:
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 
 out:
-	unlock_memory_hotplug();
+	mem_hotplug_done();
 	return ret;
 }
 
@@ -1888,7 +1950,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 
 	BUG_ON(check_hotplug_memory_range(start, size));
 
-	lock_memory_hotplug();
+	mem_hotplug_begin();
 
 	/*
 	 * All memory blocks must be offlined before removing memory.  Check
@@ -1897,10 +1959,8 @@ void __ref remove_memory(int nid, u64 start, u64 size)
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
@@ -1909,7 +1969,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 
 	try_offline_node(nid);
 
-	unlock_memory_hotplug();
+	mem_hotplug_done();
 }
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
diff --git a/mm/slub.c b/mm/slub.c
index 5e234f1f8853..d72d69e25012 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4352,7 +4352,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 		}
 	}
 
-	lock_memory_hotplug();
+	get_online_mems();
 #ifdef CONFIG_SLUB_DEBUG
 	if (flags & SO_ALL) {
 		for_each_node_state(node, N_NORMAL_MEMORY) {
@@ -4392,7 +4392,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);
 #endif
-	unlock_memory_hotplug();
+	put_online_mems();
 	kfree(nodes);
 	return x + sprintf(buf + x, "\n");
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 06879ead7380..e1ee4d041a16 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3418,7 +3418,7 @@ int kswapd_run(int nid)
 
 /*
  * Called by memory hotplug when all memory in a node is offlined.  Caller must
- * hold lock_memory_hotplug().
+ * hold mem_hotplug_begin/end().
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
