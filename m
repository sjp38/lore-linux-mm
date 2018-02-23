Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 475066B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 01:00:50 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 4so3441922plb.1
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 22:00:50 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x5si1078683pgq.437.2018.02.22.22.00.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 22:00:47 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -V6 -mm] mm, swap: Fix race between swapoff and some swap operations
Date: Fri, 23 Feb 2018 14:00:10 +0800
Message-Id: <20180223060010.954-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

From: Huang Ying <ying.huang@intel.com>

When the swapin is performed, after getting the swap entry information
from the page table, system will swap in the swap entry, without any
lock held to prevent the swap device from being swapoff.  This may
cause the race like below,

CPU 1				CPU 2
-----				-----
				do_swap_page
				  swapin_readahead
				    __read_swap_cache_async
swapoff				      swapcache_prepare
  p->swap_map = NULL		        __swap_duplicate
					  p->swap_map[?] /* !!! NULL pointer access */

Because swapoff is usually done when system shutdown only, the race
may not hit many people in practice.  But it is still a race need to
be fixed.

To fix the race, get_swap_device() is added to check whether the
specified swap entry is valid in its swap device.  If so, it will keep
the swap entry valid via preventing the swap device from being
swapoff, until put_swap_device() is called.

Because swapoff() is very rare code path, to make the normal path runs
as fast as possible, disabling preemption + stop_machine() instead of
reference count is used to implement get/put_swap_device().  From
get_swap_device() to put_swap_device(), the preemption is disabled, so
stop_machine() in swapoff() will wait until put_swap_device() is
called.

In addition to swap_map, cluster_info, etc. data structure in the
struct swap_info_struct, the swap cache radix tree will be freed after
swapoff, so this patch fixes the race between swap cache looking up
and swapoff too.

Races between some other swap cache usages protected via disabling
preemption and swapoff are fixed too via calling stop_machine()
between clearing PageSwapCache() and freeing swap cache data
structure.

Alternative implementation could be replacing disable preemption with
rcu_read_lock_sched and stop_machine() with synchronize_sched().

Cc: Hugh Dickins <hughd@google.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Shaohua Li <shli@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>

Changelog:

v6:

- Add more comments to get_swap_device() to make it more clear about
  possible swapoff or swapoff+swapon.

v5:

- Replace RCU with stop_machine()

v4:

- Use synchronize_rcu() in enable_swap_info() to reduce overhead of
  normal paths further.

v3:

- Re-implemented with RCU to reduce the overhead of normal paths

v2:

- Re-implemented with SRCU to reduce the overhead of normal paths.

- Avoid to check whether the swap device has been swapoff in
  get_swap_device().  Because we can check the origin of the swap
  entry to make sure the swap device hasn't bee swapoff.
---
 include/linux/swap.h |  13 ++++-
 mm/memory.c          |   2 +-
 mm/swap_state.c      |  16 +++++-
 mm/swapfile.c        | 152 +++++++++++++++++++++++++++++++++++++++++----------
 4 files changed, 146 insertions(+), 37 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index a1a3f4ed94ce..b4462789b970 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -172,8 +172,9 @@ enum {
 	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
 	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
 	SWP_SYNCHRONOUS_IO = (1 << 11),	/* synchronous IO is efficient */
+	SWP_VALID	= (1 << 12),	/* swap is valid to be operated on? */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 12),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 13),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
@@ -470,7 +471,7 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
-extern int __swap_count(struct swap_info_struct *si, swp_entry_t entry);
+extern int __swap_count(swp_entry_t entry);
 extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
@@ -480,6 +481,12 @@ extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
+extern struct swap_info_struct *get_swap_device(swp_entry_t entry);
+
+static inline void put_swap_device(struct swap_info_struct *si)
+{
+	preempt_enable();
+}
 
 #else /* CONFIG_SWAP */
 
@@ -597,7 +604,7 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
-static inline int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+static inline int __swap_count(swp_entry_t entry)
 {
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 5ec6433d6a5c..dd499ff6d5c2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2938,7 +2938,7 @@ int do_swap_page(struct vm_fault *vmf)
 		struct swap_info_struct *si = swp_swap_info(entry);
 
 		if (si->flags & SWP_SYNCHRONOUS_IO &&
-				__swap_count(si, entry) == 1) {
+				__swap_count(entry) == 1) {
 			/* skip swapcache */
 			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
 			if (page) {
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 39ae7cfad90f..9fd14ef5a922 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -334,8 +334,13 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 	struct page *page;
 	unsigned long ra_info;
 	int win, hits, readahead;
+	struct swap_info_struct *si;
 
+	si = get_swap_device(entry);
+	if (!si)
+		return NULL;
 	page = find_get_page(swap_address_space(entry), swp_offset(entry));
+	put_swap_device(si);
 
 	INC_CACHE_INFO(find_total);
 	if (page) {
@@ -365,8 +370,8 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr,
 			bool *new_page_allocated)
 {
-	struct page *found_page, *new_page = NULL;
-	struct address_space *swapper_space = swap_address_space(entry);
+	struct page *found_page = NULL, *new_page = NULL;
+	struct swap_info_struct *si;
 	int err;
 	*new_page_allocated = false;
 
@@ -376,7 +381,12 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		found_page = find_get_page(swapper_space, swp_offset(entry));
+		si = get_swap_device(entry);
+		if (!si)
+			break;
+		found_page = find_get_page(swap_address_space(entry),
+					   swp_offset(entry));
+		put_swap_device(si);
 		if (found_page)
 			break;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 0d00471af98b..3f0e938c4581 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -38,6 +38,7 @@
 #include <linux/export.h>
 #include <linux/swap_slots.h>
 #include <linux/sort.h>
+#include <linux/stop_machine.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -1107,6 +1108,64 @@ static struct swap_info_struct *swap_info_get_cont(swp_entry_t entry,
 	return p;
 }
 
+/*
+ * Check whether swap entry is valid in the swap device.  If so,
+ * return pointer to swap_info_struct, and keep the swap entry valid
+ * via preventing the swap device from being swapoff, until
+ * put_swap_device() is called.  Otherwise return NULL.
+ *
+ * Notice that swapoff or swapoff+swapon can still happen before the
+ * preempt_disable() in get_swap_device() or after the
+ * preempt_enable() in put_swap_device() if there isn't any other way
+ * to prevent swapoff, such as page lock, page table lock, etc.  The
+ * caller must be prepared for that.  For example, the following
+ * situation is possible.
+ *
+ *   CPU1				CPU2
+ *   do_swap_page()
+ *     ...				swapoff+swapon
+ *     __read_swap_cache_async()
+ *       swapcache_prepare()
+ *         __swap_duplicate()
+ *           // check swap_map
+ *     // verify PTE not changed
+ *
+ * In __swap_duplicate(), the swap_map need to be checked before
+ * changing partly because the specified swap entry may be for another
+ * swap device which has been swapoff.  And in do_swap_page(), after
+ * the page is read from the swap device, the PTE is verified not
+ * changed with the page table locked to check whether the swap device
+ * has been swapoff or swapoff+swapon.
+ */
+struct swap_info_struct *get_swap_device(swp_entry_t entry)
+{
+	struct swap_info_struct *si;
+	unsigned long type, offset;
+
+	if (!entry.val)
+		goto out;
+	type = swp_type(entry);
+	if (type >= nr_swapfiles)
+		goto bad_nofile;
+	si = swap_info[type];
+
+	preempt_disable();
+	if (!(si->flags & SWP_VALID))
+		goto unlock_out;
+	offset = swp_offset(entry);
+	if (offset >= si->max)
+		goto unlock_out;
+
+	return si;
+bad_nofile:
+	pr_err("%s: %s%08lx\n", __func__, Bad_file, entry.val);
+out:
+	return NULL;
+unlock_out:
+	preempt_enable();
+	return NULL;
+}
+
 static unsigned char __swap_entry_free(struct swap_info_struct *p,
 				       swp_entry_t entry, unsigned char usage)
 {
@@ -1328,11 +1387,18 @@ int page_swapcount(struct page *page)
 	return count;
 }
 
-int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+int __swap_count(swp_entry_t entry)
 {
+	struct swap_info_struct *si;
 	pgoff_t offset = swp_offset(entry);
+	int count = 0;
 
-	return swap_count(si->swap_map[offset]);
+	si = get_swap_device(entry);
+	if (si) {
+		count = swap_count(si->swap_map[offset]);
+		put_swap_device(si);
+	}
+	return count;
 }
 
 static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
@@ -1357,9 +1423,11 @@ int __swp_swapcount(swp_entry_t entry)
 	int count = 0;
 	struct swap_info_struct *si;
 
-	si = __swap_info_get(entry);
-	if (si)
+	si = get_swap_device(entry);
+	if (si) {
 		count = swap_swapcount(si, entry);
+		put_swap_device(si);
+	}
 	return count;
 }
 
@@ -2451,9 +2519,9 @@ static int swap_node(struct swap_info_struct *p)
 	return bdev ? bdev->bd_disk->node_id : NUMA_NO_NODE;
 }
 
-static void _enable_swap_info(struct swap_info_struct *p, int prio,
-				unsigned char *swap_map,
-				struct swap_cluster_info *cluster_info)
+static void setup_swap_info(struct swap_info_struct *p, int prio,
+			    unsigned char *swap_map,
+			    struct swap_cluster_info *cluster_info)
 {
 	int i;
 
@@ -2478,7 +2546,11 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	}
 	p->swap_map = swap_map;
 	p->cluster_info = cluster_info;
-	p->flags |= SWP_WRITEOK;
+}
+
+static void _enable_swap_info(struct swap_info_struct *p)
+{
+	p->flags |= SWP_WRITEOK | SWP_VALID;
 	atomic_long_add(p->pages, &nr_swap_pages);
 	total_swap_pages += p->pages;
 
@@ -2497,6 +2569,11 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	add_to_avail_list(p);
 }
 
+static int swap_onoff_stop(void *arg)
+{
+	return 0;
+}
+
 static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				struct swap_cluster_info *cluster_info,
@@ -2505,7 +2582,17 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 	frontswap_init(p->type, frontswap_map);
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	 _enable_swap_info(p, prio, swap_map, cluster_info);
+	setup_swap_info(p, prio, swap_map, cluster_info);
+	spin_unlock(&p->lock);
+	spin_unlock(&swap_lock);
+	/*
+	 * Guarantee swap_map, cluster_info, etc. fields are used
+	 * between get/put_swap_device() only if SWP_VALID bit is set
+	 */
+	stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
+	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
+	_enable_swap_info(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -2514,7 +2601,8 @@ static void reinsert_swap_info(struct swap_info_struct *p)
 {
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	_enable_swap_info(p, p->prio, p->swap_map, p->cluster_info);
+	setup_swap_info(p, p->prio, p->swap_map, p->cluster_info);
+	_enable_swap_info(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -2617,6 +2705,17 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 
 	reenable_swap_slots_cache_unlock();
 
+	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
+	p->flags &= ~SWP_VALID;		/* mark swap device as invalid */
+	spin_unlock(&p->lock);
+	spin_unlock(&swap_lock);
+	/*
+	 * wait for swap operations protected by get/put_swap_device()
+	 * to complete
+	 */
+	stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
+
 	flush_work(&p->discard_work);
 
 	destroy_swap_extents(p);
@@ -3356,22 +3455,16 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 {
 	struct swap_info_struct *p;
 	struct swap_cluster_info *ci;
-	unsigned long offset, type;
+	unsigned long offset;
 	unsigned char count;
 	unsigned char has_cache;
 	int err = -EINVAL;
 
-	if (non_swap_entry(entry))
+	p = get_swap_device(entry);
+	if (!p)
 		goto out;
 
-	type = swp_type(entry);
-	if (type >= nr_swapfiles)
-		goto bad_file;
-	p = swap_info[type];
 	offset = swp_offset(entry);
-	if (unlikely(offset >= p->max))
-		goto out;
-
 	ci = lock_cluster_or_swap_info(p, offset);
 
 	count = p->swap_map[offset];
@@ -3417,11 +3510,9 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 unlock_out:
 	unlock_cluster_or_swap_info(p, ci);
 out:
+	if (p)
+		put_swap_device(p);
 	return err;
-
-bad_file:
-	pr_err("swap_dup: %s%08lx\n", Bad_file, entry.val);
-	goto out;
 }
 
 /*
@@ -3513,6 +3604,7 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	struct page *list_page;
 	pgoff_t offset;
 	unsigned char count;
+	int ret = 0;
 
 	/*
 	 * When debugging, it's easier to use __GFP_ZERO here; but it's better
@@ -3520,15 +3612,15 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	 */
 	page = alloc_page(gfp_mask | __GFP_HIGHMEM);
 
-	si = swap_info_get(entry);
+	si = get_swap_device(entry);
 	if (!si) {
 		/*
 		 * An acceptable race has occurred since the failing
-		 * __swap_duplicate(): the swap entry has been freed,
-		 * perhaps even the whole swap_map cleared for swapoff.
+		 * __swap_duplicate(): the swap device may be swapoff
 		 */
 		goto outer;
 	}
+	spin_lock(&si->lock);
 
 	offset = swp_offset(entry);
 
@@ -3546,9 +3638,8 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	}
 
 	if (!page) {
-		unlock_cluster(ci);
-		spin_unlock(&si->lock);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out;
 	}
 
 	/*
@@ -3600,10 +3691,11 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 out:
 	unlock_cluster(ci);
 	spin_unlock(&si->lock);
+	put_swap_device(si);
 outer:
 	if (page)
 		__free_page(page);
-	return 0;
+	return ret;
 }
 
 /*
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
