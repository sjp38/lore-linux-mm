Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E30066B7E94
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 00:41:38 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so1837389pgq.9
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 21:41:38 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id cf16si2126256plb.227.2018.12.06.21.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 21:41:36 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V8 03/21] swap: Support PMD swap mapping in swap_duplicate()
Date: Fri,  7 Dec 2018 13:41:03 +0800
Message-Id: <20181207054122.27822-4-ying.huang@intel.com>
In-Reply-To: <20181207054122.27822-1-ying.huang@intel.com>
References: <20181207054122.27822-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

To support to swapin the THP in one piece, we need to create PMD swap
mapping during swapout, and maintain PMD swap mapping count.  This
patch implements the support to increase the PMD swap mapping
count (for swapout, fork, etc.)  and set SWAP_HAS_CACHE flag (for
swapin, etc.) for a huge swap cluster in swap_duplicate() function
family.  Although it only implements a part of the design of the swap
reference count with PMD swap mapping, the whole design is described
as follow to make it easy to understand the patch and the whole
picture.

A huge swap cluster is used to hold the contents of a swapouted THP.
After swapout, a PMD page mapping to the THP will become a PMD
swap mapping to the huge swap cluster via a swap entry in PMD.  While
a PTE page mapping to a subpage of the THP will become the PTE swap
mapping to a swap slot in the huge swap cluster via a swap entry in
PTE.

If there is no PMD swap mapping and the corresponding THP is removed
from the page cache (reclaimed), the huge swap cluster will be split
and become a normal swap cluster.

The count (cluster_count()) of the huge swap cluster is
SWAPFILE_CLUSTER (= HPAGE_PMD_NR) + PMD swap mapping count.  Because
all swap slots in the huge swap cluster are mapped by PTE or PMD, or
has SWAP_HAS_CACHE bit set, the usage count of the swap cluster is
HPAGE_PMD_NR.  And the PMD swap mapping count is recorded too to make
it easy to determine whether there are remaining PMD swap mappings.

The count in swap_map[offset] is the sum of PTE and PMD swap mapping
count.  This means when we increase the PMD swap mapping count, we
need to increase swap_map[offset] for all swap slots inside the swap
cluster.  An alternative choice is to make swap_map[offset] to record
PTE swap map count only, given we have recorded PMD swap mapping count
in the count of the huge swap cluster.  But this need to increase
swap_map[offset] when splitting the PMD swap mapping, that may fail
because of memory allocation for swap count continuation.  That is
hard to dealt with.  So we choose current solution.

The PMD swap mapping to a huge swap cluster may be split when unmap a
part of PMD mapping etc.  That is easy because only the count of the
huge swap cluster need to be changed.  When the last PMD swap mapping
is gone and SWAP_HAS_CACHE is unset, we will split the huge swap
cluster (clear the huge flag).  This makes it easy to reason the
cluster state.

A huge swap cluster will be split when splitting the THP in swap
cache, or failing to allocate THP during swapin, etc.  But when
splitting the huge swap cluster, we will not try to split all PMD swap
mappings, because we haven't enough information available for that
sometimes.  Later, when the PMD swap mapping is duplicated or swapin,
etc, the PMD swap mapping will be split and fallback to the PTE
operation.

When a THP is added into swap cache, the SWAP_HAS_CACHE flag will be
set in the swap_map[offset] of all swap slots inside the huge swap
cluster backing the THP.  This huge swap cluster will not be split
unless the THP is split even if its PMD swap mapping count dropped to
0.  Later, when the THP is removed from swap cache, the SWAP_HAS_CACHE
flag will be cleared in the swap_map[offset] of all swap slots inside
the huge swap cluster.  And this huge swap cluster will be split if
its PMD swap mapping count is 0.

The first parameter of swap_duplicate() is changed to return the swap
entry to call add_swap_count_continuation() for.  Because we may need
to call it for a swap entry in the middle of a huge swap cluster.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/swap.h |   9 ++--
 mm/memory.c          |   2 +-
 mm/rmap.c            |   2 +-
 mm/swap_state.c      |   2 +-
 mm/swapfile.c        | 109 ++++++++++++++++++++++++++++++++++++-------
 5 files changed, 99 insertions(+), 25 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 928550bd28f3..70a6ede1e7e0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -451,8 +451,8 @@ extern swp_entry_t get_swap_page_of_type(int);
 extern int get_swap_pages(int n, swp_entry_t swp_entries[], int entry_size);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
-extern int swap_duplicate(swp_entry_t);
-extern int swapcache_prepare(swp_entry_t);
+extern int swap_duplicate(swp_entry_t *entry, int entry_size);
+extern int swapcache_prepare(swp_entry_t entry, int entry_size);
 extern void swap_free(swp_entry_t);
 extern void swapcache_free_entries(swp_entry_t *entries, int n);
 extern int free_swap_and_cache(swp_entry_t);
@@ -510,7 +510,8 @@ static inline void show_swap_cache_info(void)
 }
 
 #define free_swap_and_cache(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
-#define swapcache_prepare(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
+#define swapcache_prepare(e, s)						\
+	({(is_migration_entry(e) || is_device_private_entry(e)); })
 
 static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
 {
@@ -521,7 +522,7 @@ static inline void swap_shmem_alloc(swp_entry_t swp)
 {
 }
 
-static inline int swap_duplicate(swp_entry_t swp)
+static inline int swap_duplicate(swp_entry_t *swp, int entry_size)
 {
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 820e8905d0e8..6ec2d0070d4f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -710,7 +710,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		swp_entry_t entry = pte_to_swp_entry(pte);
 
 		if (likely(!non_swap_entry(entry))) {
-			if (swap_duplicate(entry) < 0)
+			if (swap_duplicate(&entry, 1) < 0)
 				return entry.val;
 
 			/* make sure dst_mm is on swapoff's mmlist. */
diff --git a/mm/rmap.c b/mm/rmap.c
index 85b7f9423352..a488d325946d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1598,7 +1598,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				break;
 			}
 
-			if (swap_duplicate(entry) < 0) {
+			if (swap_duplicate(&entry, 1) < 0) {
 				set_pte_at(mm, address, pvmw.pte, pteval);
 				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 5a1cc9387151..97831166994a 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -402,7 +402,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */
-		err = swapcache_prepare(entry);
+		err = swapcache_prepare(entry, 1);
 		if (err == -EEXIST) {
 			/*
 			 * We might race against get_swap_page() and stumble
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f3c175d830b1..37e20ce4983c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -534,6 +534,40 @@ static void dec_cluster_info_page(struct swap_info_struct *p,
 		free_cluster(p, idx);
 }
 
+/*
+ * When swapout a THP in one piece, PMD page mappings to THP are
+ * replaced by PMD swap mappings to the corresponding swap cluster.
+ * cluster_swapcount() returns the PMD swap mapping count.
+ *
+ * cluster_count() = PMD swap mapping count + count of allocated swap
+ * entries in cluster.  If a cluster is mapped by PMD, all swap
+ * entries inside is used, so here cluster_count() = PMD swap mapping
+ * count + SWAPFILE_CLUSTER.
+ */
+static inline int cluster_swapcount(struct swap_cluster_info *ci)
+{
+	VM_BUG_ON(!cluster_is_huge(ci) || cluster_count(ci) < SWAPFILE_CLUSTER);
+	return cluster_count(ci) - SWAPFILE_CLUSTER;
+}
+
+/*
+ * Set PMD swap mapping count for the huge cluster
+ */
+static inline void cluster_set_swapcount(struct swap_cluster_info *ci,
+					 unsigned int count)
+{
+	VM_BUG_ON(!cluster_is_huge(ci) || cluster_count(ci) < SWAPFILE_CLUSTER);
+	cluster_set_count(ci, SWAPFILE_CLUSTER + count);
+}
+
+static inline void cluster_add_swapcount(struct swap_cluster_info *ci, int add)
+{
+	int count = cluster_swapcount(ci) + add;
+
+	VM_BUG_ON(count < 0);
+	cluster_set_swapcount(ci, count);
+}
+
 /*
  * It's possible scan_swap_map() uses a free cluster in the middle of free
  * cluster list. Avoiding such abuse to avoid list corruption.
@@ -3492,35 +3526,66 @@ static int __swap_duplicate_locked(struct swap_info_struct *p,
 }
 
 /*
- * Verify that a swap entry is valid and increment its swap map count.
+ * Verify that the swap entries from *entry is valid and increment their
+ * PMD/PTE swap mapping count.
  *
  * Returns error code in following case.
  * - success -> 0
  * - swp_entry is invalid -> EINVAL
- * - swp_entry is migration entry -> EINVAL
  * - swap-cache reference is requested but there is already one. -> EEXIST
  * - swap-cache reference is requested but the entry is not used. -> ENOENT
  * - swap-mapped reference requested but needs continued swap count. -> ENOMEM
+ * - the huge swap cluster has been split. -> ENOTDIR
  */
-static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
+static int __swap_duplicate(swp_entry_t *entry, int entry_size,
+			    unsigned char usage)
 {
 	struct swap_info_struct *p;
 	struct swap_cluster_info *ci;
 	unsigned long offset;
 	int err = -EINVAL;
+	int i, size = swap_entry_size(entry_size);
 
-	p = get_swap_device(entry);
+	p = get_swap_device(*entry);
 	if (!p)
 		goto out;
 
-	offset = swp_offset(entry);
+	offset = swp_offset(*entry);
 	ci = lock_cluster_or_swap_info(p, offset);
-	err = __swap_duplicate_locked(p, offset, usage);
+	if (size == SWAPFILE_CLUSTER) {
+		/*
+		 * The huge swap cluster has been split, for example, failed to
+		 * allocate huge page during swapin, the caller should split
+		 * the PMD swap mapping and operate on normal swap entries.
+		 */
+		if (!cluster_is_huge(ci)) {
+			err = -ENOTDIR;
+			goto unlock;
+		}
+		VM_BUG_ON(!IS_ALIGNED(offset, size));
+		/* If cluster is huge, all swap entries inside is in-use */
+		VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
+	}
+	/* p->swap_map[] = PMD swap map count + PTE swap map count */
+	for (i = 0; i < size; i++) {
+		err = __swap_duplicate_locked(p, offset + i, usage);
+		if (err && size != 1) {
+			*entry = swp_entry(p->type, offset + i);
+			goto undup;
+		}
+	}
+	if (size == SWAPFILE_CLUSTER && usage == 1)
+		cluster_add_swapcount(ci, usage);
+unlock:
 	unlock_cluster_or_swap_info(p, ci);
 
 	put_swap_device(p);
 out:
 	return err;
+undup:
+	for (i--; i >= 0; i--)
+		__swap_entry_free_locked(p, offset + i, usage);
+	goto unlock;
 }
 
 /*
@@ -3529,36 +3594,44 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
  */
 void swap_shmem_alloc(swp_entry_t entry)
 {
-	__swap_duplicate(entry, SWAP_MAP_SHMEM);
+	__swap_duplicate(&entry, 1, SWAP_MAP_SHMEM);
 }
 
 /*
  * Increase reference count of swap entry by 1.
- * Returns 0 for success, or -ENOMEM if a swap_count_continuation is required
- * but could not be atomically allocated.  Returns 0, just as if it succeeded,
- * if __swap_duplicate() fails for another reason (-EINVAL or -ENOENT), which
- * might occur if a page table entry has got corrupted.
+ *
+ * Return error code in following case.
+ * - success -> 0
+ * - swap_count_continuation is required but could not be atomically allocated.
+ *   *entry is used to return swap entry to call add_swap_count_continuation().
+ *								      -> ENOMEM
+ * - otherwise same as __swap_duplicate()
  */
-int swap_duplicate(swp_entry_t entry)
+int swap_duplicate(swp_entry_t *entry, int entry_size)
 {
 	int err = 0;
 
-	while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
-		err = add_swap_count_continuation(entry, GFP_ATOMIC);
+	while (!err &&
+	       (err = __swap_duplicate(entry, entry_size, 1)) == -ENOMEM)
+		err = add_swap_count_continuation(*entry, GFP_ATOMIC);
+	/* If kernel works correctly, other errno is impossible */
+	VM_BUG_ON(err && err != -ENOMEM && err != -ENOTDIR);
 	return err;
 }
 
 /*
  * @entry: swap entry for which we allocate swap cache.
+ * @entry_size: size of the swap entry, 1 or SWAPFILE_CLUSTER
  *
  * Called when allocating swap cache for existing swap entry,
  * This can return error codes. Returns 0 at success.
- * -EBUSY means there is a swap cache.
- * Note: return code is different from swap_duplicate().
+ * -EINVAL means the swap device has been swapoff.
+ * -EEXIST means there is a swap cache.
+ * Otherwise same as __swap_duplicate()
  */
-int swapcache_prepare(swp_entry_t entry)
+int swapcache_prepare(swp_entry_t entry, int entry_size)
 {
-	return __swap_duplicate(entry, SWAP_HAS_CACHE);
+	return __swap_duplicate(&entry, entry_size, SWAP_HAS_CACHE);
 }
 
 struct swap_info_struct *swp_swap_info(swp_entry_t entry)
-- 
2.18.1
