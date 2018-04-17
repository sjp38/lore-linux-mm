Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 433926B0008
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:02:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a6so10443554pfn.3
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:02:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u4si11758699pfb.42.2018.04.16.19.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:02:45 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 03/21] mm, THP, swap: Support PMD swap mapping in swap_duplicate()
Date: Tue, 17 Apr 2018 10:02:12 +0800
Message-Id: <20180417020230.26412-4-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

To support to swapin the THP as a whole, we need to create PMD swap
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

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 include/linux/huge_mm.h |   5 +
 include/linux/swap.h    |   9 +-
 mm/memory.c             |   2 +-
 mm/rmap.c               |   2 +-
 mm/swapfile.c           | 287 ++++++++++++++++++++++++++++------------
 5 files changed, 213 insertions(+), 92 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a126259bc4..0d0cfddbf4b7 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -79,6 +79,11 @@ extern struct kobj_attribute shmem_enabled_attr;
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 
+static inline bool thp_swap_supported(void)
+{
+	return IS_ENABLED(CONFIG_THP_SWAP);
+}
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define HPAGE_PMD_SHIFT PMD_SHIFT
 #define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1985940af479..fbdbac53894e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -451,8 +451,8 @@ extern swp_entry_t get_swap_page_of_type(int);
 extern int get_swap_pages(int n, bool cluster, swp_entry_t swp_entries[]);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
-extern int swap_duplicate(swp_entry_t);
-extern int swapcache_prepare(swp_entry_t);
+extern int swap_duplicate(swp_entry_t *entry, bool cluster);
+extern int swapcache_prepare(swp_entry_t entry, bool cluster);
 extern void swap_free(swp_entry_t);
 extern void swapcache_free_entries(swp_entry_t *entries, int n);
 extern int free_swap_and_cache(swp_entry_t);
@@ -510,7 +510,8 @@ static inline void show_swap_cache_info(void)
 }
 
 #define free_swap_and_cache(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
-#define swapcache_prepare(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
+#define swapcache_prepare(e, c)						\
+	({(is_migration_entry(e) || is_device_private_entry(e)); })
 
 static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
 {
@@ -521,7 +522,7 @@ static inline void swap_shmem_alloc(swp_entry_t swp)
 {
 }
 
-static inline int swap_duplicate(swp_entry_t swp)
+static inline int swap_duplicate(swp_entry_t *swp, bool cluster)
 {
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index a1f990e33e38..b795d62fdda9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -955,7 +955,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		swp_entry_t entry = pte_to_swp_entry(pte);
 
 		if (likely(!non_swap_entry(entry))) {
-			if (swap_duplicate(entry) < 0)
+			if (swap_duplicate(&entry, false) < 0)
 				return entry.val;
 
 			/* make sure dst_mm is on swapoff's mmlist. */
diff --git a/mm/rmap.c b/mm/rmap.c
index 8d5337fed37b..7eb948e1b966 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1556,7 +1556,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				break;
 			}
 
-			if (swap_duplicate(entry) < 0) {
+			if (swap_duplicate(&entry, false) < 0) {
 				set_pte_at(mm, address, pvmw.pte, pteval);
 				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5a280972bd87..337d06cf1dee 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -49,6 +49,9 @@ static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
 				 unsigned char);
 static void free_swap_count_continuations(struct swap_info_struct *);
 static sector_t map_swap_entry(swp_entry_t, struct block_device**);
+static int add_swap_count_continuation_locked(struct swap_info_struct *si,
+					      unsigned long offset,
+					      struct page *page);
 
 DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
@@ -319,6 +322,11 @@ static inline void unlock_cluster_or_swap_info(struct swap_info_struct *si,
 		spin_unlock(&si->lock);
 }
 
+static inline bool is_cluster_offset(unsigned long offset)
+{
+	return !(offset % SWAPFILE_CLUSTER);
+}
+
 static inline bool cluster_list_empty(struct swap_cluster_list *list)
 {
 	return cluster_is_null(&list->head);
@@ -1166,16 +1174,14 @@ struct swap_info_struct *get_swap_device(swp_entry_t entry)
 	return NULL;
 }
 
-static unsigned char __swap_entry_free(struct swap_info_struct *p,
-				       swp_entry_t entry, unsigned char usage)
+static unsigned char __swap_entry_free_locked(struct swap_info_struct *p,
+					      struct swap_cluster_info *ci,
+					      unsigned long offset,
+					      unsigned char usage)
 {
-	struct swap_cluster_info *ci;
-	unsigned long offset = swp_offset(entry);
 	unsigned char count;
 	unsigned char has_cache;
 
-	ci = lock_cluster_or_swap_info(p, offset);
-
 	count = p->swap_map[offset];
 
 	has_cache = count & SWAP_HAS_CACHE;
@@ -1203,6 +1209,17 @@ static unsigned char __swap_entry_free(struct swap_info_struct *p,
 	usage = count | has_cache;
 	p->swap_map[offset] = usage ? : SWAP_HAS_CACHE;
 
+	return usage;
+}
+
+static unsigned char __swap_entry_free(struct swap_info_struct *p,
+				       swp_entry_t entry, unsigned char usage)
+{
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+
+	ci = lock_cluster_or_swap_info(p, offset);
+	usage = __swap_entry_free_locked(p, ci, offset, usage);
 	unlock_cluster_or_swap_info(p, ci);
 
 	return usage;
@@ -3444,32 +3461,12 @@ void si_swapinfo(struct sysinfo *val)
 	spin_unlock(&swap_lock);
 }
 
-/*
- * Verify that a swap entry is valid and increment its swap map count.
- *
- * Returns error code in following case.
- * - success -> 0
- * - swp_entry is invalid -> EINVAL
- * - swp_entry is migration entry -> EINVAL
- * - swap-cache reference is requested but there is already one. -> EEXIST
- * - swap-cache reference is requested but the entry is not used. -> ENOENT
- * - swap-mapped reference requested but needs continued swap count. -> ENOMEM
- */
-static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
+static int __swap_duplicate_locked(struct swap_info_struct *p,
+				   unsigned long offset, unsigned char usage)
 {
-	struct swap_info_struct *p;
-	struct swap_cluster_info *ci;
-	unsigned long offset;
 	unsigned char count;
 	unsigned char has_cache;
-	int err = -EINVAL;
-
-	p = get_swap_device(entry);
-	if (!p)
-		goto out;
-
-	offset = swp_offset(entry);
-	ci = lock_cluster_or_swap_info(p, offset);
+	int err = 0;
 
 	count = p->swap_map[offset];
 
@@ -3479,12 +3476,11 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 	 */
 	if (unlikely(swap_count(count) == SWAP_MAP_BAD)) {
 		err = -ENOENT;
-		goto unlock_out;
+		goto out;
 	}
 
 	has_cache = count & SWAP_HAS_CACHE;
 	count &= ~SWAP_HAS_CACHE;
-	err = 0;
 
 	if (usage == SWAP_HAS_CACHE) {
 
@@ -3511,11 +3507,39 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 
 	p->swap_map[offset] = count | has_cache;
 
-unlock_out:
+out:
+	return err;
+}
+
+/*
+ * Verify that a swap entry is valid and increment its swap map count.
+ *
+ * Returns error code in following case.
+ * - success -> 0
+ * - swp_entry is invalid -> EINVAL
+ * - swp_entry is migration entry -> EINVAL
+ * - swap-cache reference is requested but there is already one. -> EEXIST
+ * - swap-cache reference is requested but the entry is not used. -> ENOENT
+ * - swap-mapped reference requested but needs continued swap count. -> ENOMEM
+ */
+static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
+{
+	struct swap_info_struct *p;
+	struct swap_cluster_info *ci;
+	unsigned long offset;
+	int err = -EINVAL;
+
+	p = get_swap_device(entry);
+	if (!p)
+		goto out;
+
+	offset = swp_offset(entry);
+	ci = lock_cluster_or_swap_info(p, offset);
+	err = __swap_duplicate_locked(p, offset, usage);
 	unlock_cluster_or_swap_info(p, ci);
+
+	put_swap_device(p);
 out:
-	if (p)
-		put_swap_device(p);
 	return err;
 }
 
@@ -3528,6 +3552,81 @@ void swap_shmem_alloc(swp_entry_t entry)
 	__swap_duplicate(entry, SWAP_MAP_SHMEM);
 }
 
+#ifdef CONFIG_THP_SWAP
+static int __swap_duplicate_cluster(swp_entry_t *entry, unsigned char usage)
+{
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci;
+	unsigned long offset;
+	unsigned char *map;
+	int i, err = 0;
+
+	si = get_swap_device(*entry);
+	if (!si) {
+		err = -EINVAL;
+		goto out;
+	}
+	offset = swp_offset(*entry);
+	ci = lock_cluster(si, offset);
+	if (cluster_is_free(ci)) {
+		err = -ENOENT;
+		goto unlock;
+	}
+	if (!cluster_is_huge(ci)) {
+		err = -ENOTDIR;
+		goto unlock;
+	}
+	VM_BUG_ON(!is_cluster_offset(offset));
+	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
+	map = si->swap_map + offset;
+	if (usage == SWAP_HAS_CACHE) {
+		if (map[0] & SWAP_HAS_CACHE) {
+			err = -EEXIST;
+			goto unlock;
+		}
+		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+			VM_BUG_ON(map[i] & SWAP_HAS_CACHE);
+			map[i] |= SWAP_HAS_CACHE;
+		}
+	} else {
+		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+retry:
+			err = __swap_duplicate_locked(si, offset + i, 1);
+			if (err == -ENOMEM) {
+				struct page *page;
+
+				page = alloc_page(GFP_ATOMIC | __GFP_HIGHMEM);
+				err = add_swap_count_continuation_locked(
+					si, offset + i, page);
+				if (err) {
+					*entry = swp_entry(si->type, offset+i);
+					goto undup;
+				}
+				goto retry;
+			} else if (err)
+				goto undup;
+		}
+		cluster_set_count(ci, cluster_count(ci) + 1);
+	}
+unlock:
+	unlock_cluster(ci);
+	put_swap_device(si);
+out:
+	return err;
+undup:
+	for (i--; i >= 0; i--)
+		__swap_entry_free_locked(
+			si, ci, offset + i, 1);
+	goto unlock;
+}
+#else
+static inline int __swap_duplicate_cluster(swp_entry_t entry,
+					   unsigned char usage)
+{
+	return 0;
+}
+#endif
+
 /*
  * Increase reference count of swap entry by 1.
  * Returns 0 for success, or -ENOMEM if a swap_count_continuation is required
@@ -3535,12 +3634,15 @@ void swap_shmem_alloc(swp_entry_t entry)
  * if __swap_duplicate() fails for another reason (-EINVAL or -ENOENT), which
  * might occur if a page table entry has got corrupted.
  */
-int swap_duplicate(swp_entry_t entry)
+int swap_duplicate(swp_entry_t *entry, bool cluster)
 {
 	int err = 0;
 
-	while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
-		err = add_swap_count_continuation(entry, GFP_ATOMIC);
+	if (thp_swap_supported() && cluster)
+		return __swap_duplicate_cluster(entry, 1);
+
+	while (!err && __swap_duplicate(*entry, 1) == -ENOMEM)
+		err = add_swap_count_continuation(*entry, GFP_ATOMIC);
 	return err;
 }
 
@@ -3552,9 +3654,12 @@ int swap_duplicate(swp_entry_t entry)
  * -EBUSY means there is a swap cache.
  * Note: return code is different from swap_duplicate().
  */
-int swapcache_prepare(swp_entry_t entry)
+int swapcache_prepare(swp_entry_t entry, bool cluster)
 {
-	return __swap_duplicate(entry, SWAP_HAS_CACHE);
+	if (thp_swap_supported() && cluster)
+		return __swap_duplicate_cluster(&entry, SWAP_HAS_CACHE);
+	else
+		return __swap_duplicate(entry, SWAP_HAS_CACHE);
 }
 
 struct swap_info_struct *swp_swap_info(swp_entry_t entry)
@@ -3584,51 +3689,13 @@ pgoff_t __page_file_index(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__page_file_index);
 
-/*
- * add_swap_count_continuation - called when a swap count is duplicated
- * beyond SWAP_MAP_MAX, it allocates a new page and links that to the entry's
- * page of the original vmalloc'ed swap_map, to hold the continuation count
- * (for that entry and for its neighbouring PAGE_SIZE swap entries).  Called
- * again when count is duplicated beyond SWAP_MAP_MAX * SWAP_CONT_MAX, etc.
- *
- * These continuation pages are seldom referenced: the common paths all work
- * on the original swap_map, only referring to a continuation page when the
- * low "digit" of a count is incremented or decremented through SWAP_MAP_MAX.
- *
- * add_swap_count_continuation(, GFP_ATOMIC) can be called while holding
- * page table locks; if it fails, add_swap_count_continuation(, GFP_KERNEL)
- * can be called after dropping locks.
- */
-int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
+static int add_swap_count_continuation_locked(struct swap_info_struct *si,
+					      unsigned long offset,
+					      struct page *page)
 {
-	struct swap_info_struct *si;
-	struct swap_cluster_info *ci;
 	struct page *head;
-	struct page *page;
 	struct page *list_page;
-	pgoff_t offset;
 	unsigned char count;
-	int ret = 0;
-
-	/*
-	 * When debugging, it's easier to use __GFP_ZERO here; but it's better
-	 * for latency not to zero a page while GFP_ATOMIC and holding locks.
-	 */
-	page = alloc_page(gfp_mask | __GFP_HIGHMEM);
-
-	si = get_swap_device(entry);
-	if (!si) {
-		/*
-		 * An acceptable race has occurred since the failing
-		 * __swap_duplicate(): the swap device may be swapoff
-		 */
-		goto outer;
-	}
-	spin_lock(&si->lock);
-
-	offset = swp_offset(entry);
-
-	ci = lock_cluster(si, offset);
 
 	count = si->swap_map[offset] & ~SWAP_HAS_CACHE;
 
@@ -3638,13 +3705,11 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 		 * will race to add swap count continuation: we need to avoid
 		 * over-provisioning.
 		 */
-		goto out;
+		return 0;
 	}
 
-	if (!page) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!page)
+		return -ENOMEM;
 
 	/*
 	 * We are fortunate that although vmalloc_to_page uses pte_offset_map,
@@ -3692,7 +3757,57 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	page = NULL;			/* now it's attached, don't free it */
 out_unlock_cont:
 	spin_unlock(&si->cont_lock);
-out:
+	if (page)
+		__free_page(page);
+	return 0;
+}
+
+/*
+ * add_swap_count_continuation - called when a swap count is duplicated
+ * beyond SWAP_MAP_MAX, it allocates a new page and links that to the entry's
+ * page of the original vmalloc'ed swap_map, to hold the continuation count
+ * (for that entry and for its neighbouring PAGE_SIZE swap entries).  Called
+ * again when count is duplicated beyond SWAP_MAP_MAX * SWAP_CONT_MAX, etc.
+ *
+ * These continuation pages are seldom referenced: the common paths all work
+ * on the original swap_map, only referring to a continuation page when the
+ * low "digit" of a count is incremented or decremented through SWAP_MAP_MAX.
+ *
+ * add_swap_count_continuation(, GFP_ATOMIC) can be called while holding
+ * page table locks; if it fails, add_swap_count_continuation(, GFP_KERNEL)
+ * can be called after dropping locks.
+ */
+int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
+{
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci;
+	struct page *page;
+	unsigned long offset;
+	int ret = 0;
+
+	/*
+	 * When debugging, it's easier to use __GFP_ZERO here; but it's better
+	 * for latency not to zero a page while GFP_ATOMIC and holding locks.
+	 */
+	page = alloc_page(gfp_mask | __GFP_HIGHMEM);
+
+	si = get_swap_device(entry);
+	if (!si) {
+		/*
+		 * An acceptable race has occurred since the failing
+		 * __swap_duplicate(): the swap device may be swapoff
+		 */
+		goto outer;
+	}
+	spin_lock(&si->lock);
+
+	offset = swp_offset(entry);
+
+	ci = lock_cluster(si, offset);
+
+	ret = add_swap_count_continuation_locked(si, offset, page);
+	page = NULL;
+
 	unlock_cluster(ci);
 	spin_unlock(&si->lock);
 	put_swap_device(si);
-- 
2.17.0
