Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D092728024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:19:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so40284963pfb.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:19:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j8si3506972pao.105.2016.09.27.10.18.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 10:19:00 -0700 (PDT)
Date: Tue, 27 Sep 2016 10:18:59 -0700
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 7/8] mm/swap: Add cache for swap slots allocation
Message-ID: <20160927171858.GA17943@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

We add per cpu caches for swap slots that can be allocated and freed
quickly without the need to touch the swap info lock.

Two separate caches are maintained for swap slots allocated and
swap slots returned.  This is to allow the swap slots to be returned
to the global pool in a batch so they will have a chance to be
coaelesced with other slots in a cluster.  We do not reuse the slots
that are returned right away, as it may increase fragmentation
of the slots.

The swap allocation cache is protected by a mutex as we may sleep
when searching for empty slots in cache.  The swap free cache
is protected by a spin lock as we cannot sleep in the free path.

We refill the swap slots cache when we run out of slots, and we
disable the swap slots cache and drain the slots if the global
number of slots fall below a low watermark threshold.  We re-enable the cache
agian when the slots available are above a high watermark.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h       |   3 +
 include/linux/swap_slots.h |  37 ++++++
 mm/Makefile                |   2 +-
 mm/swap_slots.c            | 305 +++++++++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c            |   1 +
 mm/swapfile.c              |  15 +--
 6 files changed, 351 insertions(+), 12 deletions(-)
 create mode 100644 include/linux/swap_slots.h
 create mode 100644 mm/swap_slots.c

diff --git a/include/linux/swap.h b/include/linux/swap.h
index e95a08e..599dd4b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -434,6 +434,9 @@ struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
 
+extern int get_swap_slots(int n, swp_entry_t *slots);
+extern void swapcache_free_batch(swp_entry_t *entries, int n);
+
 #else /* CONFIG_SWAP */
 
 #define swap_address_space(entry)		(NULL)
diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
new file mode 100644
index 0000000..3245170
--- /dev/null
+++ b/include/linux/swap_slots.h
@@ -0,0 +1,37 @@
+#ifndef _LINUX_SWAP_SLOTS_H
+#define _LINUX_SWAP_SLOTS_H
+
+#include <linux/swap.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+
+#define SWAP_SLOTS_CACHE_SIZE			SWAP_BATCH
+#define THRESHOLD_ACTIVATE_SWAP_SLOTS_CACHE	(5*SWAP_SLOTS_CACHE_SIZE)
+#define THRESHOLD_DEACTIVATE_SWAP_SLOTS_CACHE	(2*SWAP_SLOTS_CACHE_SIZE)
+
+struct swap_slots_cache {
+	struct mutex	alloc_lock;
+	swp_entry_t	*slots;
+	int		nr;
+	int		cur;
+	spinlock_t	free_lock;
+	swp_entry_t	*slots_ret;
+	int		n_ret;
+};
+
+DECLARE_PER_CPU(struct swap_slots_cache, swp_slots);
+extern bool    swap_slot_cache_enabled;
+
+void drain_swap_slots_cache(unsigned int type);
+void deactivate_swap_slots_cache(void);
+void disable_swap_slots_cache(void);
+void reenable_swap_slots_cache(void);
+void reactivate_swap_slots_cache(void);
+
+int free_swap_slot_to_cache(swp_entry_t entry);
+swp_entry_t get_swap_slot(void);
+int get_swap_slots(int n, swp_entry_t *entries);
+void free_swap_slot_cache(int cpu);
+int init_swap_slot_caches(void);
+
+#endif /* _LINUX_SWAP_SLOTS_H */
diff --git a/mm/Makefile b/mm/Makefile
index 2ca1faf..9d51267 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -38,7 +38,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o vmacache.o \
+			   compaction.o vmacache.o swap_slots.o \
 			   interval_tree.o list_lru.o workingset.o \
 			   debug.o $(mmu-y)
 
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
new file mode 100644
index 0000000..95fb82e
--- /dev/null
+++ b/mm/swap_slots.c
@@ -0,0 +1,305 @@
+/*
+ * Manage cache of swap slots to be used for and returned from
+ * swap.
+ *
+ * Copyright(c) 2014 Intel Corporation.
+ *
+ * Author: Tim Chen <tim.c.chen@linux.intel.com>
+ *
+ * We allocate the swap slots from the global pool and put
+ * it into local per cpu caches.  This has the advantage
+ * of no needing to acquire the swap_info lock every time
+ * we need a new slot.
+ *
+ * There is also opportunity to simply return the slot
+ * to local caches without needing to acquire swap_info
+ * lock.  We do not reuse the returned slots directly but
+ * move them back to the global pool in a batch.  This
+ * allows the slots to coaellesce and reduce fragmentation.
+ *
+ * The swap entry allocated is marked with SWAP_HAS_CACHE
+ * flag in map_count that prevents it from being allocated
+ * again from the global pool.
+ *
+ * The swap slots cache is protected by a mutex instead of
+ * a spin lock as when we search for slots with scan_swap_map,
+ * we can possibly sleep.
+ */
+
+#include <linux/swap_slots.h>
+#include <linux/cpu.h>
+#include <linux/cpumask.h>
+#include <linux/vmalloc.h>
+#include <linux/mutex.h>
+
+#ifdef CONFIG_SWAP
+
+DEFINE_PER_CPU(struct swap_slots_cache, swp_slots);
+static bool	swap_slot_cache_active;
+bool	swap_slot_cache_enabled;
+static bool	swap_slot_cache_initialized;
+DEFINE_MUTEX(swap_slots_cache_mutex);
+
+#define use_swap_slot_cache (swap_slot_cache_active && \
+		swap_slot_cache_enabled && swap_slot_cache_initialized)
+#define SLOTS_CACHE 0x1
+#define SLOTS_CACHE_RET 0x2
+
+void deactivate_swap_slots_cache(void)
+{
+	mutex_lock(&swap_slots_cache_mutex);
+	swap_slot_cache_active = false;
+	drain_swap_slots_cache(SLOTS_CACHE|SLOTS_CACHE_RET);
+	mutex_unlock(&swap_slots_cache_mutex);
+}
+
+void disable_swap_slots_cache(void)
+{
+	mutex_lock(&swap_slots_cache_mutex);
+	swap_slot_cache_active = false;
+	swap_slot_cache_enabled = false;
+	drain_swap_slots_cache(SLOTS_CACHE|SLOTS_CACHE_RET);
+	mutex_unlock(&swap_slots_cache_mutex);
+}
+
+void reenable_swap_slots_cache(void)
+{
+	mutex_lock(&swap_slots_cache_mutex);
+	swap_slot_cache_enabled = true;
+	mutex_unlock(&swap_slots_cache_mutex);
+}
+
+void reactivate_swap_slots_cache(void)
+{
+	mutex_lock(&swap_slots_cache_mutex);
+	swap_slot_cache_active = true;
+	mutex_unlock(&swap_slots_cache_mutex);
+}
+
+static bool check_cache_active(void)
+{
+	long pages;
+
+	if (!swap_slot_cache_enabled || !swap_slot_cache_initialized)
+		return false;
+
+	pages = get_nr_swap_pages();
+	if (!swap_slot_cache_active) {
+		if (pages > num_online_cpus() *
+				THRESHOLD_ACTIVATE_SWAP_SLOTS_CACHE) {
+			drain_swap_slots_cache(SLOTS_CACHE_RET);
+			reactivate_swap_slots_cache();
+		}
+		goto out;
+	}
+
+	/* if global pool of slot caches too low, deactivate cache */
+	if (pages < num_online_cpus() * THRESHOLD_DEACTIVATE_SWAP_SLOTS_CACHE)
+		deactivate_swap_slots_cache();
+out:
+	return swap_slot_cache_active;
+}
+
+static int alloc_swap_slot_cache(int cpu)
+{
+	struct swap_slots_cache *cache;
+
+	cache = &per_cpu(swp_slots, cpu);
+	mutex_init(&cache->alloc_lock);
+	spin_lock_init(&cache->free_lock);
+	cache->nr = 0;
+	cache->cur = 0;
+	cache->n_ret = 0;
+	cache->slots = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
+	if (!cache->slots) {
+		swap_slot_cache_enabled = false;
+		return -ENOMEM;
+	}
+	cache->slots_ret = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
+	if (!cache->slots_ret) {
+		vfree(cache->slots);
+		swap_slot_cache_enabled = false;
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static void drain_slots_cache_cpu(int cpu, unsigned int type)
+{
+	int i, n;
+	swp_entry_t entry;
+	struct swap_slots_cache *cache;
+
+	cache = &per_cpu(swp_slots, cpu);
+	if (type & SLOTS_CACHE) {
+		mutex_lock(&cache->alloc_lock);
+		for (n = 0; n < cache->nr; ++n) {
+			i = (cache->cur + n) % SWAP_SLOTS_CACHE_SIZE;
+			/*
+			 * locking swap info is unnecessary,
+			 * nobody else will claim this map slot
+			 * and use it if its value is SWAP_HAS_CACHE
+			 */
+			entry = cache->slots[i];
+			swapcache_free_entries(&entry, 1);
+		}
+		cache->cur = 0;
+		cache->nr = 0;
+		mutex_unlock(&cache->alloc_lock);
+	}
+	if (type & SLOTS_CACHE_RET) {
+		spin_lock_irq(&cache->free_lock);
+		swapcache_free_entries(cache->slots_ret, cache->n_ret);
+		cache->n_ret = 0;
+		spin_unlock_irq(&cache->free_lock);
+	}
+}
+
+void drain_swap_slots_cache(unsigned int type)
+{
+	int cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu)
+		drain_slots_cache_cpu(cpu, type);
+	put_online_cpus();
+}
+
+static void free_slot_cache(int cpu)
+{
+	struct swap_slots_cache *cache;
+
+	mutex_lock(&swap_slots_cache_mutex);
+	drain_slots_cache_cpu(cpu, SLOTS_CACHE | SLOTS_CACHE_RET);
+	cache = &per_cpu(swp_slots, cpu);
+	cache->nr = 0;
+	cache->cur = 0;
+	cache->n_ret = 0;
+	vfree(cache->slots);
+	mutex_unlock(&swap_slots_cache_mutex);
+}
+
+static int swap_cache_callback(struct notifier_block *nfb,
+			unsigned long action, void *hcpu)
+{
+	int cpu = (long)hcpu;
+
+	switch (action) {
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+			free_slot_cache(cpu);
+			break;
+	case CPU_ONLINE:
+			alloc_swap_slot_cache(cpu);
+			break;
+	}
+	return NOTIFY_OK;
+}
+
+int init_swap_slot_caches(void)
+{
+	int	i, j;
+
+	if (swap_slot_cache_initialized) {
+		if (!swap_slot_cache_enabled)
+			reenable_swap_slots_cache();
+		return 0;
+	}
+
+	get_online_cpus();
+	for_each_online_cpu(i) {
+		if (alloc_swap_slot_cache(i))
+			goto fail;
+	}
+	swap_slot_cache_initialized = true;
+	swap_slot_cache_enabled = true;
+	put_online_cpus();
+	hotcpu_notifier(swap_cache_callback, 0);
+	mutex_init(&swap_slots_cache_mutex);
+	return 0;
+fail:
+	for_each_online_cpu(j) {
+		if (j == i)
+			break;
+		free_slot_cache(j);
+	}
+	put_online_cpus();
+	swap_slot_cache_initialized = false;
+	return -ENOMEM;
+}
+
+/* called with swap slot cache's alloc lock held */
+static int refill_swap_slots_cache(struct swap_slots_cache *cache)
+{
+	if (!use_swap_slot_cache || cache->nr)
+		return 0;
+
+	cache->cur = 0;
+	if (swap_slot_cache_active)
+		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE,
+					&cache->slots[cache->cur]);
+
+	return cache->nr;
+}
+
+int free_swap_slot_to_cache(swp_entry_t entry)
+{
+	struct swap_slots_cache *cache;
+	int idx;
+
+	BUG_ON(!swap_slot_cache_initialized);
+
+	cache = this_cpu_ptr(&swp_slots);
+
+	if (use_swap_slot_cache) {
+		spin_lock_irq(&cache->free_lock);
+		if (cache->n_ret >= SWAP_SLOTS_CACHE_SIZE) {
+			/*
+			 * return slots to global pool
+			 * note swap_map value should be SWAP_HAS_CACHE
+			 * set it to 0 to indicate it is available for
+			 * allocation in global pool
+			 */
+			swapcache_free_entries(cache->slots_ret, cache->n_ret);
+			cache->n_ret = 0;
+		}
+		/* return to local cache at tail */
+		idx = cache->n_ret % SWAP_SLOTS_CACHE_SIZE;
+		cache->slots_ret[idx] = entry;
+		cache->n_ret++;
+		spin_unlock_irq(&cache->free_lock);
+	} else
+		swapcache_free_entries(&entry, 1);
+
+	return 0;
+}
+
+swp_entry_t get_swap_page(void)
+{
+	swp_entry_t	entry;
+	struct swap_slots_cache *cache;
+
+	cache = this_cpu_ptr(&swp_slots);
+
+	if (check_cache_active()) {
+		mutex_lock(&cache->alloc_lock);
+repeat:
+		if (cache->nr) {
+			entry = cache->slots[cache->cur];
+			cache->slots[cache->cur].val = 0;
+			cache->cur = (cache->cur + 1) % SWAP_SLOTS_CACHE_SIZE;
+			--cache->nr;
+		} else {
+			if (refill_swap_slots_cache(cache))
+				goto repeat;
+		}
+		mutex_unlock(&cache->alloc_lock);
+		return entry;
+	}
+
+	get_swap_pages(1, &entry);
+
+	return entry;
+}
+
+#endif /* CONFIG_SWAP */
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 579807d..2ae607e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -18,6 +18,7 @@
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
 #include <linux/vmalloc.h>
+#include <linux/swap_slots.h>
 
 #include <asm/pgtable.h>
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index c38c201..fa6935f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -34,6 +34,7 @@
 #include <linux/frontswap.h>
 #include <linux/swapfile.h>
 #include <linux/export.h>
+#include <linux/swap_slots.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -880,14 +881,6 @@ noswap:
 	return n_ret;
 }
 
-swp_entry_t get_swap_page(void)
-{
-	swp_entry_t entry;
-
-	get_swap_pages(1, &entry);
-	return entry;
-}
-
 /* The only caller of this function is now suspend routine */
 swp_entry_t get_swap_page_of_type(int type)
 {
@@ -1078,7 +1071,7 @@ void swap_free(swp_entry_t entry)
 	p = _swap_info_get(entry);
 	if (p) {
 		if (!__swap_entry_free(p, entry, 1))
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot_to_cache(entry);
 	}
 }
 
@@ -1092,7 +1085,7 @@ void swapcache_free(swp_entry_t entry)
 	p = _swap_info_get(entry);
 	if (p) {
 		if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot_to_cache(entry);
 	}
 }
 
@@ -1300,7 +1293,7 @@ int free_swap_and_cache(swp_entry_t entry)
 				page = NULL;
 			}
 		} else if (!count)
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot_to_cache(entry);
 	}
 	if (page) {
 		/*
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
