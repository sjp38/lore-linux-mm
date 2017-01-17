Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94F6B6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 21:55:54 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so274499246pfy.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 18:55:54 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id k30si23364841pgn.247.2017.01.16.18.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 18:55:53 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: [Update][PATCH v5 7/9] mm/swap: Add cache for swap slots allocation
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
	<35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
Date: Tue, 17 Jan 2017 10:55:47 +0800
In-Reply-To: <35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
	(Tim Chen's message of "Wed, 11 Jan 2017 09:55:17 -0800")
Message-ID: <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim C Chen <tim.c.chen@intel.com>

Hi, Andrew,

This update patch is to fix the preemption warning raised by Michal
Hocko.  raw_cpu_ptr() is used to replace this_cpu_ptr() and comments are
added for why it is used.

Best Regards,
Huang, Ying

---------------------------------------------->
From: Tim Chen <tim.c.chen@linux.intel.com>

We add per cpu caches for swap slots that can be allocated and freed
quickly without the need to touch the swap info lock.

Two separate caches are maintained for swap slots allocated and swap
slots returned.  This is to allow the swap slots to be returned to the
global pool in a batch so they will have a chance to be coaelesced with
other slots in a cluster.  We do not reuse the slots that are returned
right away, as it may increase fragmentation of the slots.

The swap allocation cache is protected by a mutex as we may sleep when
searching for empty slots in cache.  The swap free cache is protected
by a spin lock as we cannot sleep in the free path.

We refill the swap slots cache when we run out of slots, and we disable
the swap slots cache and drain the slots if the global number of slots
fall below a low watermark threshold.  We re-enable the cache agian when
the slots available are above a high watermark.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Co-developed-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h       |   4 +
 include/linux/swap_slots.h |  28 ++++
 mm/Makefile                |   2 +-
 mm/swap_slots.c            | 339 +++++++++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c            |   1 +
 mm/swapfile.c              |  26 ++--
 6 files changed, 388 insertions(+), 12 deletions(-)
 create mode 100644 include/linux/swap_slots.h
 create mode 100644 mm/swap_slots.c

diff --git a/include/linux/swap.h b/include/linux/swap.h
index b021478a772d..d101d0e780da 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -371,6 +371,7 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 /* linux/mm/swapfile.c */
 extern atomic_long_t nr_swap_pages;
 extern long total_swap_pages;
+extern bool has_usable_swap(void);
 
 /* Swap 50% full? Release swapcache more aggressively.. */
 static inline bool vm_swap_full(void)
@@ -409,6 +410,9 @@ struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
 
+extern int get_swap_slots(int n, swp_entry_t *slots);
+extern void swapcache_free_batch(swp_entry_t *entries, int n);
+
 #else /* CONFIG_SWAP */
 
 #define swap_address_space(entry)		(NULL)
diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
new file mode 100644
index 000000000000..a59e6e2f2c47
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
index 295bd7a9f76b..433eaf9a876e 100644
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
index 000000000000..1b7a52e87aac
--- /dev/null
+++ b/mm/swap_slots.c
@@ -0,0 +1,339 @@
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
+static int alloc_swap_slot_cache(unsigned int cpu)
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
+	if (!slots)
+		return -ENOMEM;
+
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
+static void drain_slots_cache_cpu(unsigned int cpu, unsigned int type,
+				  bool free_slots)
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
+	unsigned int cpu;
+
+	/*
+	 * This function is called during
+	 *	1) swapoff, when we have to make sure no
+	 *	   left over slots are in cache when we remove
+	 *	   a swap device;
+	 *      2) disabling of swap slot cache, when we run low
+	 *	   on swap slots when allocating memory and need
+	 *	   to return swap slots to global pool.
+	 *
+	 * We cannot acquire cpu hot plug lock here as
+	 * this function can be invoked in the cpu
+	 * hot plug path:
+	 * cpu_up -> lock cpu_hotplug -> cpu hotplug state callback
+	 *   -> memory allocation -> direct reclaim -> get_swap_page
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
+static int free_slot_cache(unsigned int cpu)
+{
+	mutex_lock(&swap_slots_cache_mutex);
+	drain_slots_cache_cpu(cpu, SLOTS_CACHE | SLOTS_CACHE_RET, true);
+	mutex_unlock(&swap_slots_cache_mutex);
+	return 0;
+}
+
+int enable_swap_slots_cache(void)
+{
+	int ret = 0;
+
+	mutex_lock(&swap_slots_cache_enable_mutex);
+	if (swap_slot_cache_initialized) {
+		__reenable_swap_slots_cache();
+		goto out_unlock;
+	}
+
+	ret = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "swap_slots_cache",
+				alloc_swap_slot_cache, free_slot_cache);
+	if (ret < 0)
+		goto out_unlock;
+	swap_slot_cache_initialized = true;
+	__reenable_swap_slots_cache();
+out_unlock:
+	mutex_unlock(&swap_slots_cache_enable_mutex);
+	return 0;
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
+	} else {
+direct_free:
+		swapcache_free_entries(&entry, 1);
+	}
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
+	/*
+	 * Preemption need to be turned on here, because we may sleep
+	 * in refill_swap_slots_cache().  But it is safe, because
+	 * accesses to the per-CPU data structure are protected by a
+	 * mutex.
+	 */
+	cache = raw_cpu_ptr(&swp_slots);
+
+	entry.val = 0;
+	if (check_cache_active()) {
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
index 3d76d80c07d6..e1f07cafecaa 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -18,6 +18,7 @@
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
 #include <linux/vmalloc.h>
+#include <linux/swap_slots.h>
 
 #include <asm/pgtable.h>
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 72dfec7b8035..d4d7baf3c21a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -34,6 +34,7 @@
 #include <linux/frontswap.h>
 #include <linux/swapfile.h>
 #include <linux/export.h>
+#include <linux/swap_slots.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -859,14 +860,6 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
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
@@ -1057,7 +1050,7 @@ void swap_free(swp_entry_t entry)
 	p = _swap_info_get(entry);
 	if (p) {
 		if (!__swap_entry_free(p, entry, 1))
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot(entry);
 	}
 }
 
@@ -1071,7 +1064,7 @@ void swapcache_free(swp_entry_t entry)
 	p = _swap_info_get(entry);
 	if (p) {
 		if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot(entry);
 	}
 }
 
@@ -1279,7 +1272,7 @@ int free_swap_and_cache(swp_entry_t entry)
 				page = NULL;
 			}
 		} else if (!count)
-			swapcache_free_entries(&entry, 1);
+			free_swap_slot(entry);
 	}
 	if (page) {
 		/*
@@ -2107,6 +2100,17 @@ static void reinsert_swap_info(struct swap_info_struct *p)
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
