Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BECD86B000A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:02:52 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x5-v6so11335979pln.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:02:52 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b7si2783831pfh.257.2018.04.16.19.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:02:51 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 05/21] mm, THP, swap: Support PMD swap mapping in free_swap_and_cache()/swap_free()
Date: Tue, 17 Apr 2018 10:02:14 +0800
Message-Id: <20180417020230.26412-6-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

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
 arch/s390/mm/pgtable.c |   2 +-
 include/linux/swap.h   |   9 ++--
 kernel/power/swap.c    |   4 +-
 mm/madvise.c           |   2 +-
 mm/memory.c            |   4 +-
 mm/shmem.c             |   6 +--
 mm/swapfile.c          | 114 ++++++++++++++++++++++++++++++++++++-----
 7 files changed, 116 insertions(+), 25 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 4f2b65d01a70..2bb82ad677ec 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -646,7 +646,7 @@ static void ptep_zap_swap_entry(struct mm_struct *mm, swp_entry_t entry)
 
 		dec_mm_counter(mm, mm_counter(page));
 	}
-	free_swap_and_cache(entry);
+	free_swap_and_cache(entry, false);
 }
 
 void ptep_zap_unused(struct mm_struct *mm, unsigned long addr,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index fbdbac53894e..89f34ebfd318 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -453,9 +453,9 @@ extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t *entry, bool cluster);
 extern int swapcache_prepare(swp_entry_t entry, bool cluster);
-extern void swap_free(swp_entry_t);
+extern void swap_free(swp_entry_t entry, bool cluster);
 extern void swapcache_free_entries(swp_entry_t *entries, int n);
-extern int free_swap_and_cache(swp_entry_t);
+extern int free_swap_and_cache(swp_entry_t entry, bool cluster);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
@@ -509,7 +509,8 @@ static inline void show_swap_cache_info(void)
 {
 }
 
-#define free_swap_and_cache(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
+#define free_swap_and_cache(e, c)					\
+	({(is_migration_entry(e) || is_device_private_entry(e)); })
 #define swapcache_prepare(e, c)						\
 	({(is_migration_entry(e) || is_device_private_entry(e)); })
 
@@ -527,7 +528,7 @@ static inline int swap_duplicate(swp_entry_t *swp, bool cluster)
 	return 0;
 }
 
-static inline void swap_free(swp_entry_t swp)
+static inline void swap_free(swp_entry_t swp, bool cluster)
 {
 }
 
diff --git a/kernel/power/swap.c b/kernel/power/swap.c
index 11b4282c2d20..0dec99decde1 100644
--- a/kernel/power/swap.c
+++ b/kernel/power/swap.c
@@ -182,7 +182,7 @@ sector_t alloc_swapdev_block(int swap)
 	offset = swp_offset(get_swap_page_of_type(swap));
 	if (offset) {
 		if (swsusp_extents_insert(offset))
-			swap_free(swp_entry(swap, offset));
+			swap_free(swp_entry(swap, offset), false);
 		else
 			return swapdev_block(swap, offset);
 	}
@@ -206,7 +206,7 @@ void free_all_swap_pages(int swap)
 		ext = rb_entry(node, struct swsusp_extent, node);
 		rb_erase(node, &swsusp_extents);
 		for (offset = ext->start; offset <= ext->end; offset++)
-			swap_free(swp_entry(swap, offset));
+			swap_free(swp_entry(swap, offset), false);
 
 		kfree(ext);
 	}
diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..d180000c626b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -349,7 +349,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			if (non_swap_entry(entry))
 				continue;
 			nr_swap--;
-			free_swap_and_cache(entry);
+			free_swap_and_cache(entry, false);
 			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 			continue;
 		}
diff --git a/mm/memory.c b/mm/memory.c
index b795d62fdda9..37dc3b15fe11 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1380,7 +1380,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			page = migration_entry_to_page(entry);
 			rss[mm_counter(page)]--;
 		}
-		if (unlikely(!free_swap_and_cache(entry)))
+		if (unlikely(!free_swap_and_cache(entry, false)))
 			print_bad_pte(vma, addr, ptent, NULL);
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
@@ -3050,7 +3050,7 @@ int do_swap_page(struct vm_fault *vmf)
 	}
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 
-	swap_free(entry);
+	swap_free(entry, false);
 	if (mem_cgroup_swap_full(page) ||
 	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
diff --git a/mm/shmem.c b/mm/shmem.c
index 9d6c7e595415..0516ce2e0fb3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -667,7 +667,7 @@ static int shmem_free_swap(struct address_space *mapping,
 	xa_unlock_irq(&mapping->i_pages);
 	if (old != radswap)
 		return -ENOENT;
-	free_swap_and_cache(radix_to_swp_entry(radswap));
+	free_swap_and_cache(radix_to_swp_entry(radswap), false);
 	return 0;
 }
 
@@ -1191,7 +1191,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 			spin_lock_irq(&info->lock);
 			info->swapped--;
 			spin_unlock_irq(&info->lock);
-			swap_free(swap);
+			swap_free(swap, false);
 		}
 	}
 	return error;
@@ -1734,7 +1734,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 
 		delete_from_swap_cache(page);
 		set_page_dirty(page);
-		swap_free(swap);
+		swap_free(swap, false);
 
 	} else {
 		if (vma && userfaultfd_missing(vma)) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index ef4c6017e207..c25c7759df6b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -885,7 +885,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 }
 
 #ifdef CONFIG_THP_SWAP
-static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
+static int __swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
 {
 	unsigned long idx;
 	struct swap_cluster_info *ci;
@@ -911,7 +911,7 @@ static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
 	return 1;
 }
 
-static void swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
+static void __swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
 {
 	unsigned long offset = idx * SWAPFILE_CLUSTER;
 	struct swap_cluster_info *ci;
@@ -924,11 +924,15 @@ static void swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
 	swap_range_free(si, offset, SWAPFILE_CLUSTER);
 }
 #else
-static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
+static int __swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
 {
 	VM_WARN_ON_ONCE(1);
 	return 0;
 }
+
+static void __swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
+{
+}
 #endif /* CONFIG_THP_SWAP */
 
 static unsigned long scan_swap_map(struct swap_info_struct *si,
@@ -996,7 +1000,7 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 		}
 		if (cluster) {
 			if (!(si->flags & SWP_FILE))
-				n_ret = swap_alloc_cluster(si, swp_entries);
+				n_ret = __swap_alloc_cluster(si, swp_entries);
 		} else
 			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
 						    n_goal, swp_entries);
@@ -1215,8 +1219,10 @@ static unsigned char __swap_entry_free_locked(struct swap_info_struct *p,
 				count = SWAP_MAP_MAX | COUNT_CONTINUED;
 			else
 				count = SWAP_MAP_MAX;
-		} else
+		} else {
+			VM_BUG_ON(!count);
 			count--;
+		}
 	}
 
 	usage = count | has_cache;
@@ -1255,17 +1261,90 @@ static void swap_entry_free(struct swap_info_struct *p, swp_entry_t entry)
 	swap_range_free(p, offset, 1);
 }
 
+#ifdef CONFIG_THP_SWAP
+static unsigned char swap_free_cluster(struct swap_info_struct *si,
+				       swp_entry_t entry)
+{
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+	unsigned int count, i, free_entries = 0, cache_only = 0;
+	unsigned char *map, ret = 1;
+
+	ci = lock_cluster(si, offset);
+	VM_BUG_ON(!is_cluster_offset(offset));
+	/* Cluster has been split, free each swap entries in cluster */
+	if (!cluster_is_huge(ci)) {
+		unlock_cluster(ci);
+		for (i = 0; i < SWAPFILE_CLUSTER; i++, entry.val++) {
+			if (!__swap_entry_free(si, entry, 1)) {
+				free_entries++;
+				free_swap_slot(entry);
+			}
+		}
+		return !(free_entries == SWAPFILE_CLUSTER);
+	}
+	count = cluster_count(ci) - 1;
+	VM_BUG_ON(count < SWAPFILE_CLUSTER);
+	cluster_set_count(ci, count);
+	map = si->swap_map + offset;
+	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+		if (map[i] == 1) {
+			map[i] = SWAP_MAP_BAD;
+			free_entries++;
+		} else if (__swap_entry_free_locked(si, ci, offset + i, 1) ==
+			   SWAP_HAS_CACHE)
+			cache_only++;
+	}
+	VM_BUG_ON(free_entries && (count != SWAPFILE_CLUSTER ||
+				   (map[0] & SWAP_HAS_CACHE)));
+	if (free_entries == SWAPFILE_CLUSTER)
+		memset(map, SWAP_HAS_CACHE, SWAPFILE_CLUSTER);
+	else if (!cluster_swapcount(ci) && !(map[0] & SWAP_HAS_CACHE))
+		cluster_clear_huge(ci);
+	unlock_cluster(ci);
+	if (free_entries == SWAPFILE_CLUSTER) {
+		spin_lock(&si->lock);
+		mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
+		__swap_free_cluster(si, offset / SWAPFILE_CLUSTER);
+		spin_unlock(&si->lock);
+		ret = 0;
+	} else if (free_entries) {
+		ci = lock_cluster(si, offset);
+		for (i = 0; i < SWAPFILE_CLUSTER; i++, entry.val++) {
+			if (map[i] == SWAP_MAP_BAD) {
+				map[i] = SWAP_HAS_CACHE;
+				unlock_cluster(ci);
+				free_swap_slot(entry);
+				ci = lock_cluster(si, offset);
+			}
+		}
+		unlock_cluster(ci);
+	} else if (cache_only == SWAPFILE_CLUSTER)
+		ret = SWAP_HAS_CACHE;
+
+	return ret;
+}
+#else
+static inline unsigned char swap_free_cluster(struct swap_info_struct *si,
+					      swp_entry_t entry)
+{
+	return 0;
+}
+#endif
+
 /*
  * Caller has made sure that the swap device corresponding to entry
  * is still around or has not been recycled.
  */
-void swap_free(swp_entry_t entry)
+void swap_free(swp_entry_t entry, bool cluster)
 {
 	struct swap_info_struct *p;
 
 	p = _swap_info_get(entry);
 	if (p) {
-		if (!__swap_entry_free(p, entry, 1))
+		if (thp_swap_supported() && cluster)
+			swap_free_cluster(p, entry);
+		else if (!__swap_entry_free(p, entry, 1))
 			free_swap_slot(entry);
 	}
 }
@@ -1326,7 +1405,7 @@ static void swapcache_free_cluster(swp_entry_t entry)
 	if (free_entries == SWAPFILE_CLUSTER) {
 		spin_lock(&si->lock);
 		mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
-		swap_free_cluster(si, idx);
+		__swap_free_cluster(si, idx);
 		spin_unlock(&si->lock);
 	} else if (free_entries) {
 		for (i = 0; i < SWAPFILE_CLUSTER; i++, entry.val++) {
@@ -1730,7 +1809,7 @@ int try_to_free_swap(struct page *page)
  * Free the swap entry like above, but also try to
  * free the page cache entry if it is the last user.
  */
-int free_swap_and_cache(swp_entry_t entry)
+int free_swap_and_cache(swp_entry_t entry, bool cluster)
 {
 	struct swap_info_struct *p;
 	struct page *page = NULL;
@@ -1741,7 +1820,8 @@ int free_swap_and_cache(swp_entry_t entry)
 
 	p = _swap_info_get(entry);
 	if (p) {
-		count = __swap_entry_free(p, entry, 1);
+		count = cluster ? swap_free_cluster(p, entry) :
+			__swap_entry_free(p, entry, 1);
 		if (count == SWAP_HAS_CACHE &&
 		    !swap_page_trans_huge_swapped(p, entry)) {
 			page = find_get_page(swap_address_space(entry),
@@ -1750,7 +1830,7 @@ int free_swap_and_cache(swp_entry_t entry)
 				put_page(page);
 				page = NULL;
 			}
-		} else if (!count)
+		} else if (!count && !cluster)
 			free_swap_slot(entry);
 	}
 	if (page) {
@@ -1914,7 +1994,7 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	}
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	swap_free(entry);
+	swap_free(entry, false);
 	/*
 	 * Move the page to the active list so it is not
 	 * immediately swapped out again after swapon.
@@ -2353,6 +2433,16 @@ int try_to_unuse(unsigned int type, bool frontswap,
 	}
 
 	mmput(start_mm);
+
+	/*
+	 * Swap entries may be marked as SWAP_MAP_BAD temporarily in
+	 * swap_free_cluster() before being freed really.
+	 * find_next_to_unuse() will skip these swap entries, that is
+	 * OK.  But we need to wait until they are freed really.
+	 */
+	while (!retval && READ_ONCE(si->inuse_pages))
+		schedule_timeout_uninterruptible(1);
+
 	return retval;
 }
 
-- 
2.17.0
