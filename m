Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD876B026D
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 16:09:09 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id i88so34392115pfk.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 13:09:09 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 75si35260400pfv.196.2016.12.09.13.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 13:09:08 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v4 7/9] mm/swap: Add cache for swap slots allocation
Date: Fri,  9 Dec 2016 13:09:20 -0800
Message-Id: <59bb4a6ad8a527691d92b8c4044653122453c519.1481317367.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1481317367.git.tim.c.chen@linux.intel.com>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1481317367.git.tim.c.chen@linux.intel.com>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

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
Co-developed-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h       |   4 +
 include/linux/swap_slots.h |  28 ++++
 mm/Makefile                |   2 +-
 mm/swap_slots.c            | 364 +++++++++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c            |   1 +
 mm/swapfile.c              |  26 ++--
 6 files changed, 413 insertions(+), 12 deletions(-)
 create mode 100644 include/linux/swap_slots.h
 create mode 100644 mm/swap_slots.c

diff --git a/include/linux/swap.h b/include/linux/swap.h
index f2bb6ac..e82593a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -398,6 +398,7 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 /* linux/mm/swapfile.c */
 extern atomic_long_t nr_swap_pages;
 extern long total_swap_pages;
+extern bool has_usable_swap(void);
 
 /* Swap 50% full? Release swapcache more aggressively.. */
 static inline bool vm_swap_full(void)
@@ -436,6 +437,9 @@ struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
 
+extern int get_swap_slots(int n, swp_entry_t *slots);
+extern void swapcache_free_batch(swp_entry_t *entries, int n);
+
 #else /* CONFIG_SWAP */
 
 #define swap_address_space(entry)		(NULL)
diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
new file mode 100644
index 0000000..a59e6e2
--- /dev/null
+++ b/include/linux/swap_slots.h
@@ -0,0 +1,28 @@
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
+	bool		lock_initialized;
+	struct mutex	alloc_lock;
+	swp_entry_t	*slots;
+	int		nr;
+	int		cur;
+	spinlock_t	free_lock;
+	swp_entry_t	*slots_ret;
+	int		n_ret;
+};
+
+void disable_swap_slots_cache_lock(void);
+void reenable_swap_slots_cache_unlock(void);
+int enable_swap_slots_cache(void);
+int free_swap_slot(swp_entry_t entry);
+
+#endif /* _LINUX_SWAP_SLOTS_H */
diff --git a/mm/Makefile b/mm/Makefile
index 295bd7a..433eaf9 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -35,7 +35,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o vmacache.o \
+			   compaction.o vmacache.o swap_slots.o \
 			   interval_tree.o list_lru.o workingset.o \
 			   debug.o $(mmu-y)
 
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
new file mode 100644
index 0000000..8da25df
--- /dev/null
+++ b/mm/swap_slots.c
@@ -0,0 +1,364 @@
+/*
+ * Manage cache of swap slots to be used for and returned from
+ * swap.
+ *
+ * Copyright(c) 2016 Intel Corporation.
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
+static DEFINE_PER_CPU(struct swap_slots_cache, swp_slots);
+static bool	swap_slot_cache_active;
+static bool	swap_slot_cache_enabled;
+static bool	swap_slot_cache_initialized;
+DEFINE_MUTEX(swap_slots_cache_mutex);
+/* Serialize swap slots cache enable/disable operations */
+DEFINE_MUTEX(swap_slots_cache_enable_mutex);
+
+static void __drain_swap_slots_cache(unsigned int type);
+static void deactivate_swap_slots_cache(void);
+static void reactivate_swap_slots_cache(void);
+
+#define use_swap_slot_cache (swap_slot_cache_active && \
+		swap_slot_cache_enabled && swap_slot_cache_initialized)
+#define SLOTS_CACHE 0x1
+#define SLOTS_CACHE_RET 0x2
+
+static void deactivate_swap_slots_cache(void)
+{
+	mutex_lock(&swap_slots_cache_mutex);
+	swap_slot_cache_active = false;
+	__drain_swap_slots_cache(SLOTS_CACHE|SLOTS_CACHE_RET);
+	mutex_unlock(&swap_slots_cache_mutex);
+}
+
+static void reactivate_swap_slots_cache(void)
+{
+	mutex_lock(&swap_slots_cache_mutex);
+	swap_slot_cache_active = true;
+	mutex_unlock(&swap_slots_cache_mutex);
+}
+
+/* Must not be called with cpu hot plug lock */
+void disable_swap_slots_cache_lock(void)
+{
+	mutex_lock(&swap_slots_cache_enable_mutex);
+	swap_slot_cache_enabled = false;
+	if (swap_slot_cache_initialized) {
+		/* serialize with cpu hotplug operations */
+		get_online_cpus();
+		__drain_swap_slots_cache(SLOTS_CACHE|SLOTS_CACHE_RET);
+		put_online_cpus();
+	}
+}
+
+static void __reenable_swap_slots_cache(void)
+{
+	swap_slot_cache_enabled = has_usable_swap();
+}
+
+void reenable_swap_slots_cache_unlock(void)
+{
+	__reenable_swap_slots_cache();
+	mutex_unlock(&swap_slots_cache_enable_mutex);
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
+		    THRESHOLD_ACTIVATE_SWAP_SLOTS_CACHE)
+			reactivate_swap_slots_cache();
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
+	swp_entry_t *slots, *slots_ret;
+
+	/*
+	 * Do allocation outside swap_slots_cache_mutex
+	 * as vzalloc could trigger reclaim and get_swap_page,
+	 * which can lock swap_slots_cache_mutex.
+	 */
+	slots = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
+	if (!slots) {
+		return -ENOMEM;
+	}
+	slots_ret = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
+	if (!slots_ret) {
+		vfree(slots);
+		return -ENOMEM;
+	}
+
+	mutex_lock(&swap_slots_cache_mutex);
+	cache = &per_cpu(swp_slots, cpu);
+	if (cache->slots || cache->slots_ret)
+		/* cache already allocated */
+		goto out;
+	if (!cache->lock_initialized) {
+		mutex_init(&cache->alloc_lock);
+		spin_lock_init(&cache->free_lock);
+		cache->lock_initialized = true;
+	}
+	cache->nr = 0;
+	cache->cur = 0;
+	cache->n_ret = 0;
+	cache->slots = slots;
+	slots = NULL;
+	cache->slots_ret = slots_ret;
+	slots_ret = NULL;
+out:
+	mutex_unlock(&swap_slots_cache_mutex);
+	if (slots)
+		vfree(slots);
+	if (slots_ret)
+		vfree(slots_ret);
+	return 0;
+}
+
+static void drain_slots_cache_cpu(int cpu, unsigned int type, bool free_slots)
+{
+	struct swap_slots_cache *cache;
+	swp_entry_t *slots = NULL;
+
+	cache = &per_cpu(swp_slots, cpu);
+	if ((type & SLOTS_CACHE) && cache->slots) {
+		mutex_lock(&cache->alloc_lock);
+		swapcache_free_entries(cache->slots + cache->cur, cache->nr);
+		cache->cur = 0;
+		cache->nr = 0;
+		if (free_slots && cache->slots) {
+			vfree(cache->slots);
+			cache->slots = NULL;
+		}
+		mutex_unlock(&cache->alloc_lock);
+	}
+	if ((type & SLOTS_CACHE_RET) && cache->slots_ret) {
+		spin_lock_irq(&cache->free_lock);
+		swapcache_free_entries(cache->slots_ret, cache->n_ret);
+		cache->n_ret = 0;
+		if (free_slots && cache->slots_ret) {
+			slots = cache->slots_ret;
+			cache->slots_ret = NULL;
+		}
+		spin_unlock_irq(&cache->free_lock);
+		if (slots)
+			vfree(slots);
+	}
+}
+
+static void __drain_swap_slots_cache(unsigned int type)
+{
+	int cpu;
+
+	/*
+	 * This function is called during
+	 * 	1) swapoff, when we have to make sure no
+	 * 	   left over slots are in cache when we remove
+	 * 	   a swap device;
+	 *      2) disabling of swap slot cache, when we run low
+	 *         on swap slots when allocating memory and need
+	 *         to return swap slots to global pool.
+	 *
+	 * We cannot acquire cpu hot plug lock here as
+	 * this function can be invoked in the cpu
+	 * hot plug path:
+	 * cpu_up -> lock cpu_hotplug -> smpboot_create_threads
+	 *   -> kmem_cache_alloc -> direct reclaim -> get_swap_page
+	 *   -> drain_swap_slots_cache
+	 *
+	 * Hence the loop over current online cpu below could miss cpu that
+	 * is being brought online but not yet marked as online.
+	 * That is okay as we do not schedule and run anything on a
+	 * cpu before it has been marked online. Hence, we will not
+	 * fill any swap slots in slots cache of such cpu.
+	 * There are no slots on such cpu that need to be drained.
+	 */
+	for_each_online_cpu(cpu)
+		drain_slots_cache_cpu(cpu, type, false);
+}
+
+static void free_slot_cache(int cpu)
+{
+	mutex_lock(&swap_slots_cache_mutex);
+	drain_slots_cache_cpu(cpu, SLOTS_CACHE | SLOTS_CACHE_RET, true);
+	mutex_unlock(&swap_slots_cache_mutex);
+}
+
+static int swap_cache_callback(struct notifier_block *nfb,
+			unsigned long action, void *hcpu)
+{
+	int cpu = (long)hcpu;
+
+	switch (action) {
+	case CPU_DOWN_PREPARE:
+			free_slot_cache(cpu);
+			break;
+	case CPU_DOWN_FAILED:
+	case CPU_ONLINE:
+			alloc_swap_slot_cache(cpu);
+			break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block swap_cache_notifier = {
+	.notifier_call = swap_cache_callback,
+};
+
+int enable_swap_slots_cache(void)
+{
+	int	i, j;
+
+	mutex_lock(&swap_slots_cache_enable_mutex);
+	if (swap_slot_cache_initialized) {
+		__reenable_swap_slots_cache();
+		goto out_unlock;
+	}
+
+	cpu_notifier_register_begin();
+	for_each_online_cpu(i) {
+		if (alloc_swap_slot_cache(i))
+			goto fail;
+	}
+	swap_slot_cache_initialized = true;
+	__reenable_swap_slots_cache();
+	__register_hotcpu_notifier(&swap_cache_notifier);
+	cpu_notifier_register_done();
+out_unlock:
+	mutex_unlock(&swap_slots_cache_enable_mutex);
+	return 0;
+fail:
+	for_each_online_cpu(j) {
+		if (j == i)
+			break;
+		free_slot_cache(j);
+	}
+	cpu_notifier_register_done();
+	swap_slot_cache_initialized = false;
+	mutex_unlock(&swap_slots_cache_enable_mutex);
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
+		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, cache->slots);
+
+	return cache->nr;
+}
+
+int free_swap_slot(swp_entry_t entry)
+{
+	struct swap_slots_cache *cache;
+
+	BUG_ON(!swap_slot_cache_initialized);
+
+	cache = &get_cpu_var(swp_slots);
+	if (use_swap_slot_cache && cache->slots_ret) {
+		spin_lock_irq(&cache->free_lock);
+		/* Swap slots cache may be deactivated before acquiring lock */
+		if (!use_swap_slot_cache) {
+			spin_unlock_irq(&cache->free_lock);
+			goto direct_free;
+		}
+		if (cache->n_ret >= SWAP_SLOTS_CACHE_SIZE) {
+			/*
+			 * Return slots to global pool.
+			 * The current swap_map value is SWAP_HAS_CACHE.
+			 * Set it to 0 to indicate it is available for
+			 * allocation in global pool
+			 */
+			swapcache_free_entries(cache->slots_ret, cache->n_ret);
+			cache->n_ret = 0;
+		}
+		cache->slots_ret[cache->n_ret++] = entry;
+		spin_unlock_irq(&cache->free_lock);
+	} else
+direct_free:
+		swapcache_free_entries(&entry, 1);
+	put_cpu_var(swp_slots);
+
+	return 0;
+}
+
+swp_entry_t get_swap_page(void)
+{
+	swp_entry_t entry, *pentry;
+	struct swap_slots_cache *cache;
+
+	cache = this_cpu_ptr(&swp_slots);
+
+	if (check_cache_active()) {
+		entry.val = 0;
+		mutex_lock(&cache->alloc_lock);
+		if (cache->slots) {
+repeat:
+			if (cache->nr) {
+				pentry = &cache->slots[cache->cur++];
+				entry = *pentry;
+				pentry->val = 0;
+				cache->nr--;
+			} else {
+				if (refill_swap_slots_cache(cache))
+					goto repeat;
+			}
+		}
+		mutex_unlock(&cache->alloc_lock);
+		if (entry.val)
+			return entry;
+	}
+
+	get_swap_pages(1, &entry);
+
+	return entry;
+}
+
+#endif /* CONFIG_SWAP */
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3d76d80..e1f07ca 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -18,6 +18,7 @@
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
 #include <linux/vmalloc.h>
+#include <linux/swap_slots.h>
 
 #include <asm/pgtable.h>
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 172fd36..3a6cad1 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -34,6 +34,7 @@
 #include <linux/frontswap.h>
 #include <linux/swapfile.h>
 #include <linux/export.h>
+#include <linux/swap_slots.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -861,14 +862,6 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
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
@@ -1059,7 +1052,7 @@ void swap_free(swp_entry_t entry)
 	p = _swap_info_get(entry);
 	if (p) {
 		if (!__swap_entry_free(p, entry, 1))
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot(entry);
 	}
 }
 
@@ -1073,7 +1066,7 @@ void swapcache_free(swp_entry_t entry)
 	p = _swap_info_get(entry);
 	if (p) {
 		if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot(entry);
 	}
 }
 
@@ -1281,7 +1274,7 @@ int free_swap_and_cache(swp_entry_t entry)
 				page = NULL;
 			}
 		} else if (!count)
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot(entry);
 	}
 	if (page) {
 		/*
@@ -2110,6 +2103,17 @@ static void reinsert_swap_info(struct swap_info_struct *p)
 	spin_unlock(&swap_lock);
 }
 
+bool has_usable_swap(void)
+{
+	bool ret = true;
+
+	spin_lock(&swap_lock);
+	if (plist_head_empty(&swap_active_head))
+		ret = false;
+	spin_unlock(&swap_lock);
+	return ret;
+}
+
 SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 {
 	struct swap_info_struct *p = NULL;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
