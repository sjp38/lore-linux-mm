Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D39E58E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 01:28:00 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id x26so3019500pgc.5
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 22:28:00 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v19si3555849pfa.80.2018.12.13.22.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 22:27:59 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V9 06/21] swap: Support PMD swap mapping in free_swap_and_cache()/swap_free()
Date: Fri, 14 Dec 2018 14:27:39 +0800
Message-Id: <20181214062754.13723-7-ying.huang@intel.com>
In-Reply-To: <20181214062754.13723-1-ying.huang@intel.com>
References: <20181214062754.13723-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

When a PMD swap mapping is removed from a huge swap cluster, for
example, unmap a memory range mapped with PMD swap mapping, etc,
free_swap_and_cache() will be called to decrease the reference count
to the huge swap cluster.  free_swap_and_cache() may also free or
split the huge swap cluster, and free the corresponding THP in swap
cache if necessary.  swap_free() is similar, and shares most
implementation with free_swap_and_cache().  This patch revises
free_swap_and_cache() and swap_free() to implement this.

If the swap cluster has been split already, for example, because of
failing to allocate a THP during swapin, we just decrease one from the
reference count of all swap slots.

Otherwise, we will decrease one from the reference count of all swap
slots and the PMD swap mapping count in cluster_count().  When the
corresponding THP isn't in swap cache, if PMD swap mapping count
becomes 0, the huge swap cluster will be split, and if all swap count
becomes 0, the huge swap cluster will be freed.  When the corresponding
THP is in swap cache, if every swap_map[offset] == SWAP_HAS_CACHE, we
will try to delete the THP from swap cache.  Which will cause the THP
and the huge swap cluster be freed.

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
 arch/s390/mm/pgtable.c |   2 +-
 include/linux/swap.h   |   9 ++-
 kernel/power/swap.c    |   4 +-
 mm/madvise.c           |   2 +-
 mm/memory.c            |   4 +-
 mm/shmem.c             |   4 +-
 mm/swapfile.c          | 170 ++++++++++++++++++++++++++++++++---------
 7 files changed, 147 insertions(+), 48 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index f2cc7da473e4..ffd4b68adbb3 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -675,7 +675,7 @@ static void ptep_zap_swap_entry(struct mm_struct *mm, swp_entry_t entry)
 
 		dec_mm_counter(mm, mm_counter(page));
 	}
-	free_swap_and_cache(entry);
+	free_swap_and_cache(entry, 1);
 }
 
 void ptep_zap_unused(struct mm_struct *mm, unsigned long addr,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 70a6ede1e7e0..24c3014894dd 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -453,9 +453,9 @@ extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t *entry, int entry_size);
 extern int swapcache_prepare(swp_entry_t entry, int entry_size);
-extern void swap_free(swp_entry_t);
+extern void swap_free(swp_entry_t entry, int entry_size);
 extern void swapcache_free_entries(swp_entry_t *entries, int n);
-extern int free_swap_and_cache(swp_entry_t);
+extern int free_swap_and_cache(swp_entry_t entry, int entry_size);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
@@ -509,7 +509,8 @@ static inline void show_swap_cache_info(void)
 {
 }
 
-#define free_swap_and_cache(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
+#define free_swap_and_cache(e, s)					\
+	({(is_migration_entry(e) || is_device_private_entry(e)); })
 #define swapcache_prepare(e, s)						\
 	({(is_migration_entry(e) || is_device_private_entry(e)); })
 
@@ -527,7 +528,7 @@ static inline int swap_duplicate(swp_entry_t *swp, int entry_size)
 	return 0;
 }
 
-static inline void swap_free(swp_entry_t swp)
+static inline void swap_free(swp_entry_t swp, int entry_size)
 {
 }
 
diff --git a/kernel/power/swap.c b/kernel/power/swap.c
index d7f6c1a288d3..0275df84ed3d 100644
--- a/kernel/power/swap.c
+++ b/kernel/power/swap.c
@@ -182,7 +182,7 @@ sector_t alloc_swapdev_block(int swap)
 	offset = swp_offset(get_swap_page_of_type(swap));
 	if (offset) {
 		if (swsusp_extents_insert(offset))
-			swap_free(swp_entry(swap, offset));
+			swap_free(swp_entry(swap, offset), 1);
 		else
 			return swapdev_block(swap, offset);
 	}
@@ -206,7 +206,7 @@ void free_all_swap_pages(int swap)
 		ext = rb_entry(node, struct swsusp_extent, node);
 		rb_erase(node, &swsusp_extents);
 		for (offset = ext->start; offset <= ext->end; offset++)
-			swap_free(swp_entry(swap, offset));
+			swap_free(swp_entry(swap, offset), 1);
 
 		kfree(ext);
 	}
diff --git a/mm/madvise.c b/mm/madvise.c
index d220ad7087ed..fac48161b015 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -349,7 +349,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			if (non_swap_entry(entry))
 				continue;
 			nr_swap--;
-			free_swap_and_cache(entry);
+			free_swap_and_cache(entry, 1);
 			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 			continue;
 		}
diff --git a/mm/memory.c b/mm/memory.c
index 5efb9259d47b..78f341b5672d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1134,7 +1134,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			page = migration_entry_to_page(entry);
 			rss[mm_counter(page)]--;
 		}
-		if (unlikely(!free_swap_and_cache(entry)))
+		if (unlikely(!free_swap_and_cache(entry, 1)))
 			print_bad_pte(vma, addr, ptent, NULL);
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
@@ -2829,7 +2829,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	}
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 
-	swap_free(entry);
+	swap_free(entry, 1);
 	if (mem_cgroup_swap_full(page) ||
 	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
diff --git a/mm/shmem.c b/mm/shmem.c
index a9b7e65f4b2c..d00fe9a23670 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -670,7 +670,7 @@ static int shmem_free_swap(struct address_space *mapping,
 	old = xa_cmpxchg_irq(&mapping->i_pages, index, radswap, NULL, 0);
 	if (old != radswap)
 		return -ENOENT;
-	free_swap_and_cache(radix_to_swp_entry(radswap));
+	free_swap_and_cache(radix_to_swp_entry(radswap), 1);
 	return 0;
 }
 
@@ -1657,7 +1657,7 @@ static int shmem_swapin_page(struct inode *inode, pgoff_t index,
 
 	delete_from_swap_cache(page);
 	set_page_dirty(page);
-	swap_free(swap);
+	swap_free(swap, 1);
 
 	*pagep = page;
 	return 0;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 04cf6b95cae0..243131253238 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -49,6 +49,9 @@ static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
 				 unsigned char);
 static void free_swap_count_continuations(struct swap_info_struct *);
 static sector_t map_swap_entry(swp_entry_t, struct block_device**);
+static bool __swap_page_trans_huge_swapped(struct swap_info_struct *si,
+					   struct swap_cluster_info *ci,
+					   unsigned long offset);
 
 DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
@@ -1267,19 +1270,106 @@ struct swap_info_struct *get_swap_device(swp_entry_t entry)
 	return NULL;
 }
 
-static unsigned char __swap_entry_free(struct swap_info_struct *p,
-				       swp_entry_t entry, unsigned char usage)
+#define SF_FREE_CACHE		0x1
+
+static void __swap_free(struct swap_info_struct *p, swp_entry_t entry,
+			      int entry_size, unsigned long flags)
 {
 	struct swap_cluster_info *ci;
 	unsigned long offset = swp_offset(entry);
+	int i, free_entries = 0, cache_only = 0;
+	int size = swap_entry_size(entry_size);
+	unsigned char *map, count;
 
 	ci = lock_cluster_or_swap_info(p, offset);
-	usage = __swap_entry_free_locked(p, offset, usage);
+	VM_BUG_ON(!IS_ALIGNED(offset, size));
+	/*
+	 * Normal swap entry or huge swap cluster has been split, free
+	 * each swap entry
+	 */
+	if (size == 1 || !cluster_is_huge(ci)) {
+		for (i = 0; i < size; i++, entry.val++) {
+			count = __swap_entry_free_locked(p, offset + i, 1);
+			if (!count ||
+			    (flags & SF_FREE_CACHE &&
+			     count == SWAP_HAS_CACHE &&
+			     !__swap_page_trans_huge_swapped(p, ci,
+							     offset + i))) {
+				unlock_cluster_or_swap_info(p, ci);
+				if (!count)
+					free_swap_slot(entry);
+				else
+					__try_to_reclaim_swap(p, offset + i,
+						TTRS_UNMAPPED | TTRS_FULL);
+				if (i == size - 1)
+					return;
+				lock_cluster_or_swap_info(p, offset);
+			}
+		}
+		unlock_cluster_or_swap_info(p, ci);
+		return;
+	}
+	/*
+	 * Return for normal swap entry above, the following code is
+	 * for huge swap cluster only.
+	 */
+	cluster_add_swapcount(ci, -1);
+	/*
+	 * Decrease mapping count for each swap entry in cluster.
+	 * Because PMD swap mapping is counted in p->swap_map[] too.
+	 */
+	map = p->swap_map + offset;
+	for (i = 0; i < size; i++) {
+		/*
+		 * Mark swap entries to become free as SWAP_MAP_BAD
+		 * temporarily.
+		 */
+		if (map[i] == 1) {
+			map[i] = SWAP_MAP_BAD;
+			free_entries++;
+		} else if (__swap_entry_free_locked(p, offset + i, 1) ==
+			   SWAP_HAS_CACHE)
+			cache_only++;
+	}
+	/*
+	 * If there are PMD swap mapping or the THP is in swap cache,
+	 * it's impossible for some swap entries to become free.
+	 */
+	VM_BUG_ON(free_entries &&
+		  (cluster_swapcount(ci) || (map[0] & SWAP_HAS_CACHE)));
+	if (free_entries == SWAPFILE_CLUSTER)
+		memset(map, SWAP_HAS_CACHE, SWAPFILE_CLUSTER);
+	/*
+	 * If there are no PMD swap mappings remain and the THP isn't
+	 * in swap cache, split the huge swap cluster.
+	 */
+	else if (!cluster_swapcount(ci) && !(map[0] & SWAP_HAS_CACHE))
+		cluster_clear_huge(ci);
 	unlock_cluster_or_swap_info(p, ci);
-	if (!usage)
-		free_swap_slot(entry);
-
-	return usage;
+	if (free_entries == SWAPFILE_CLUSTER) {
+		spin_lock(&p->lock);
+		mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
+		swap_free_cluster(p, offset / SWAPFILE_CLUSTER);
+		spin_unlock(&p->lock);
+	} else if (free_entries) {
+		ci = lock_cluster(p, offset);
+		for (i = 0; i < size; i++, entry.val++) {
+			/*
+			 * To be freed swap entries are marked as SWAP_MAP_BAD
+			 * temporarily as above
+			 */
+			if (map[i] == SWAP_MAP_BAD) {
+				map[i] = SWAP_HAS_CACHE;
+				unlock_cluster(ci);
+				free_swap_slot(entry);
+				if (i == size - 1)
+					return;
+				ci = lock_cluster(p, offset);
+			}
+		}
+		unlock_cluster(ci);
+	} else if (cache_only == SWAPFILE_CLUSTER && flags & SF_FREE_CACHE)
+		__try_to_reclaim_swap(p, offset, TTRS_UNMAPPED | TTRS_FULL);
 }
 
 static void swap_entry_free(struct swap_info_struct *p, swp_entry_t entry)
@@ -1303,13 +1393,13 @@ static void swap_entry_free(struct swap_info_struct *p, swp_entry_t entry)
  * Caller has made sure that the swap device corresponding to entry
  * is still around or has not been recycled.
  */
-void swap_free(swp_entry_t entry)
+void swap_free(swp_entry_t entry, int entry_size)
 {
 	struct swap_info_struct *p;
 
 	p = _swap_info_get(entry);
 	if (p)
-		__swap_entry_free(p, entry, 1);
+		__swap_free(p, entry, entry_size, 0);
 }
 
 /*
@@ -1545,29 +1635,33 @@ int swp_swapcount(swp_entry_t entry)
 	return count;
 }
 
-static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
-					 swp_entry_t entry)
+/* si->lock or ci->lock must be held before calling this function */
+static bool __swap_page_trans_huge_swapped(struct swap_info_struct *si,
+					   struct swap_cluster_info *ci,
+					   unsigned long offset)
 {
-	struct swap_cluster_info *ci;
 	unsigned char *map = si->swap_map;
-	unsigned long roffset = swp_offset(entry);
-	unsigned long offset = round_down(roffset, SWAPFILE_CLUSTER);
+	unsigned long hoffset = round_down(offset, SWAPFILE_CLUSTER);
 	int i;
-	bool ret = false;
 
-	ci = lock_cluster_or_swap_info(si, offset);
-	if (!ci || !cluster_is_huge(ci)) {
-		if (swap_count(map[roffset]))
-			ret = true;
-		goto unlock_out;
-	}
+	if (!ci || !cluster_is_huge(ci))
+		return !!swap_count(map[offset]);
 	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
-		if (swap_count(map[offset + i])) {
-			ret = true;
-			break;
-		}
+		if (swap_count(map[hoffset + i]))
+			return true;
 	}
-unlock_out:
+	return false;
+}
+
+static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
+					 swp_entry_t entry)
+{
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+	bool ret;
+
+	ci = lock_cluster_or_swap_info(si, offset);
+	ret = __swap_page_trans_huge_swapped(si, ci, offset);
 	unlock_cluster_or_swap_info(si, ci);
 	return ret;
 }
@@ -1739,22 +1833,17 @@ int try_to_free_swap(struct page *page)
  * Free the swap entry like above, but also try to
  * free the page cache entry if it is the last user.
  */
-int free_swap_and_cache(swp_entry_t entry)
+int free_swap_and_cache(swp_entry_t entry, int entry_size)
 {
 	struct swap_info_struct *p;
-	unsigned char count;
 
 	if (non_swap_entry(entry))
 		return 1;
 
 	p = _swap_info_get(entry);
-	if (p) {
-		count = __swap_entry_free(p, entry, 1);
-		if (count == SWAP_HAS_CACHE &&
-		    !swap_page_trans_huge_swapped(p, entry))
-			__try_to_reclaim_swap(p, swp_offset(entry),
-					      TTRS_UNMAPPED | TTRS_FULL);
-	}
+	if (p)
+		__swap_free(p, entry, entry_size, SF_FREE_CACHE);
+
 	return p != NULL;
 }
 
@@ -1901,7 +1990,7 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	}
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	swap_free(entry);
+	swap_free(entry, 1);
 	/*
 	 * Move the page to the active list so it is not
 	 * immediately swapped out again after swapon.
@@ -2630,6 +2719,15 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		reinsert_swap_info(p);
 		reenable_swap_slots_cache_unlock();
 		goto out_dput;
+	} else {
+		/*
+		 * Swap entries may be marked as SWAP_MAP_BAD temporarily in
+		 * __swap_free() before being freed really. try_to_unuse()
+		 * will skip these swap entries, that is OK.  But we need to
+		 * wait until they are freed really.
+		 */
+		while (READ_ONCE(p->inuse_pages))
+			schedule_timeout_uninterruptible(1);
 	}
 
 	reenable_swap_slots_cache_unlock();
-- 
2.18.1
