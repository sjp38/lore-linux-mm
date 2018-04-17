Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 248056B0026
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:03:20 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e11so3214944pgv.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:03:20 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q74si633723pfi.282.2018.04.16.19.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:03:18 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 14/21] mm, cgroup, THP, swap: Support to move swap account for PMD swap mapping
Date: Tue, 17 Apr 2018 10:02:23 +0800
Message-Id: <20180417020230.26412-15-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

Previously the huge swap cluster will be split after the THP is
swapout.  Now, to support to swapin the THP as a whole, the huge swap
cluster will not be split after the THP is reclaimed.  So in memcg, we
need to move the swap account for PMD swap mappings in the process's
page table.

When the page table is scanned during moving memcg charge, the PMD
swap mapping will be identified.  And mem_cgroup_move_swap_account()
and its callee is revised to move account for the whole huge swap
cluster.  If the swap cluster mapped by PMD has been split, the PMD
swap mapping will be split and fallback to PTE processing.  Because
the swap slots of the swap cluster may have been swapin or moved to
other cgroup already.

Because there is no way to prevent a huge swap cluster from being
split except when it has SWAP_HAS_CACHE flag set.  It is possible for
the huge swap cluster to be split and the charge for the swap slots
inside to be changed, after we check the PMD swap mapping and the huge
swap cluster before we commit the charge moving.  But the race window
is so small, that we will just ignore the race.

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
 include/linux/huge_mm.h     |   9 +++
 include/linux/swap.h        |   6 ++
 include/linux/swap_cgroup.h |   3 +-
 mm/huge_memory.c            |  12 +---
 mm/memcontrol.c             | 136 +++++++++++++++++++++++++++++-------
 mm/swap_cgroup.c            |  45 +++++++++---
 mm/swapfile.c               |  12 ++++
 7 files changed, 179 insertions(+), 44 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4e299e327720..5001c28b3d18 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -405,6 +405,9 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #ifdef CONFIG_THP_SWAP
+extern void __split_huge_swap_pmd(struct vm_area_struct *vma,
+				  unsigned long haddr,
+				  pmd_t *pmd);
 extern int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			       unsigned long address, pmd_t orig_pmd);
 extern int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd);
@@ -432,6 +435,12 @@ static inline bool transparent_hugepage_swapin_enabled(
 	return false;
 }
 #else /* CONFIG_THP_SWAP */
+static inline void __split_huge_swap_pmd(struct vm_area_struct *vma,
+					 unsigned long haddr,
+					 pmd_t *pmd)
+{
+}
+
 static inline int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 				      unsigned long address, pmd_t orig_pmd)
 {
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 32b9c8df938f..ef40d1862eff 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -628,6 +628,7 @@ static inline swp_entry_t get_swap_page(struct page *page)
 #ifdef CONFIG_THP_SWAP
 extern int split_swap_cluster(swp_entry_t entry, bool force);
 extern int split_swap_cluster_map(swp_entry_t entry);
+extern bool in_huge_swap_cluster(swp_entry_t entry);
 #else
 static inline int split_swap_cluster(swp_entry_t entry, bool force)
 {
@@ -638,6 +639,11 @@ static inline int split_swap_cluster_map(swp_entry_t entry)
 {
 	return 0;
 }
+
+static inline bool in_huge_swap_cluster(swp_entry_t entry)
+{
+	return false;
+}
 #endif
 
 #ifdef CONFIG_MEMCG
diff --git a/include/linux/swap_cgroup.h b/include/linux/swap_cgroup.h
index a12dd1c3966c..c40fb52b0563 100644
--- a/include/linux/swap_cgroup.h
+++ b/include/linux/swap_cgroup.h
@@ -7,7 +7,8 @@
 #ifdef CONFIG_MEMCG_SWAP
 
 extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
-					unsigned short old, unsigned short new);
+					unsigned short old, unsigned short new,
+					unsigned int nr_ents);
 extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
 					 unsigned int nr_ents);
 extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3e395f52c5a4..1d3309c61136 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1633,9 +1633,9 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 }
 
 #ifdef CONFIG_THP_SWAP
-static void __split_huge_swap_pmd(struct vm_area_struct *vma,
-				  unsigned long haddr,
-				  pmd_t *pmd)
+void __split_huge_swap_pmd(struct vm_area_struct *vma,
+			   unsigned long haddr,
+			   pmd_t *pmd)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgtable_t pgtable;
@@ -1838,12 +1838,6 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	count_vm_event(THP_SWPIN_FALLBACK);
 	goto fallback;
 }
-#else
-static inline void __split_huge_swap_pmd(struct vm_area_struct *vma,
-					 unsigned long haddr,
-					 pmd_t *pmd)
-{
-}
 #endif
 
 static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 448db08d97a0..35e07ba989a4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2423,9 +2423,10 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 #ifdef CONFIG_MEMCG_SWAP
 /**
  * mem_cgroup_move_swap_account - move swap charge and swap_cgroup's record.
- * @entry: swap entry to be moved
+ * @entry: the first swap entry to be moved
  * @from:  mem_cgroup which the entry is moved from
  * @to:  mem_cgroup which the entry is moved to
+ * @nr_ents: number of swap entries
  *
  * It succeeds only when the swap_cgroup's record for this entry is the same
  * as the mem_cgroup's id of @from.
@@ -2436,23 +2437,27 @@ void mem_cgroup_split_huge_fixup(struct page *head)
  * both res and memsw, and called css_get().
  */
 static int mem_cgroup_move_swap_account(swp_entry_t entry,
-				struct mem_cgroup *from, struct mem_cgroup *to)
+					struct mem_cgroup *from,
+					struct mem_cgroup *to,
+					unsigned int nr_ents)
 {
 	unsigned short old_id, new_id;
 
 	old_id = mem_cgroup_id(from);
 	new_id = mem_cgroup_id(to);
 
-	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
-		mod_memcg_state(from, MEMCG_SWAP, -1);
-		mod_memcg_state(to, MEMCG_SWAP, 1);
+	if (swap_cgroup_cmpxchg(entry, old_id, new_id, nr_ents) == old_id) {
+		mod_memcg_state(from, MEMCG_SWAP, -nr_ents);
+		mod_memcg_state(to, MEMCG_SWAP, nr_ents);
 		return 0;
 	}
 	return -EINVAL;
 }
 #else
 static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
-				struct mem_cgroup *from, struct mem_cgroup *to)
+					       struct mem_cgroup *from,
+					       struct mem_cgroup *to,
+					       unsigned int nr_ents)
 {
 	return -EINVAL;
 }
@@ -4603,6 +4608,7 @@ enum mc_target_type {
 	MC_TARGET_PAGE,
 	MC_TARGET_SWAP,
 	MC_TARGET_DEVICE,
+	MC_TARGET_FALLBACK,
 };
 
 static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
@@ -4669,6 +4675,34 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
 }
 #endif
 
+#ifdef CONFIG_THP_SWAP
+static struct page *mc_handle_swap_pmd(struct vm_area_struct *vma,
+			pmd_t pmd, swp_entry_t *entry)
+{
+	struct page *page = NULL;
+	swp_entry_t ent = pmd_to_swp_entry(pmd);
+
+	if (!(mc.flags & MOVE_ANON) || non_swap_entry(ent))
+		return NULL;
+
+	/*
+	 * Because lookup_swap_cache() updates some statistics counter,
+	 * we call find_get_page() with swapper_space directly.
+	 */
+	page = find_get_page(swap_address_space(ent), swp_offset(ent));
+	if (do_memsw_account())
+		entry->val = ent.val;
+
+	return page;
+}
+#else
+static struct page *mc_handle_swap_pmd(struct vm_area_struct *vma,
+			pmd_t pmd, swp_entry_t *entry)
+{
+	return NULL;
+}
+#endif
+
 static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 			unsigned long addr, pte_t ptent, swp_entry_t *entry)
 {
@@ -4857,7 +4891,9 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 	 * There is a swap entry and a page doesn't exist or isn't charged.
 	 * But we cannot move a tail-page in a THP.
 	 */
-	if (ent.val && !ret && (!page || !PageTransCompound(page)) &&
+	if (ent.val && !ret &&
+	    ((page && !PageTransCompound(page)) ||
+	     (!page && !in_huge_swap_cluster(ent))) &&
 	    mem_cgroup_id(mc.from) == lookup_swap_cgroup_id(ent)) {
 		ret = MC_TARGET_SWAP;
 		if (target)
@@ -4868,32 +4904,60 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /*
- * We don't consider PMD mapped swapping or file mapped pages because THP does
- * not support them for now.
- * Caller should make sure that pmd_trans_huge(pmd) is true.
+ * We don't consider file mapped pages because THP does not support
+ * them for now.
  */
 static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
-		unsigned long addr, pmd_t pmd, union mc_target *target)
+		unsigned long addr, pmd_t *pmdp, union mc_target *target)
 {
+	pmd_t pmd = *pmdp;
 	struct page *page = NULL;
 	enum mc_target_type ret = MC_TARGET_NONE;
+	swp_entry_t ent = { .val = 0 };
 
 	if (unlikely(is_swap_pmd(pmd))) {
-		VM_BUG_ON(thp_migration_supported() &&
-				  !is_pmd_migration_entry(pmd));
-		return ret;
+		if (is_pmd_migration_entry(pmd)) {
+			VM_BUG_ON(!thp_migration_supported());
+			return ret;
+		}
+		page = mc_handle_swap_pmd(vma, pmd, &ent);
+		/* The swap cluster has been split under us */
+		if ((page && !PageTransHuge(page)) ||
+		    (!page && ent.val && !in_huge_swap_cluster(ent))) {
+			__split_huge_swap_pmd(vma, addr, pmdp);
+			ret = MC_TARGET_FALLBACK;
+			goto out;
+		}
+	} else {
+		page = pmd_page(pmd);
+		get_page(page);
 	}
-	page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
+	VM_BUG_ON_PAGE(page && !PageHead(page), page);
 	if (!(mc.flags & MOVE_ANON))
-		return ret;
-	if (page->mem_cgroup == mc.from) {
+		goto out;
+	if (!page && !ent.val)
+		goto out;
+	if (page && page->mem_cgroup == mc.from) {
 		ret = MC_TARGET_PAGE;
 		if (target) {
 			get_page(page);
 			target->page = page;
 		}
 	}
+	if (ent.val && !ret && !page &&
+	    mem_cgroup_id(mc.from) == lookup_swap_cgroup_id(ent)) {
+		/*
+		 * It is possible for the huge swap cluster to be
+		 * split by others and the charge is changed, but the
+		 * race window is small.
+		 */
+		ret = MC_TARGET_SWAP;
+		if (target)
+			target->ent = ent;
+	}
+out:
+	if (page)
+		put_page(page);
 	return ret;
 }
 #else
@@ -4911,6 +4975,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int ret;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
@@ -4919,12 +4984,16 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 		 * support transparent huge page with MEMORY_DEVICE_PUBLIC or
 		 * MEMORY_DEVICE_PRIVATE but this might change.
 		 */
-		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
-			mc.precharge += HPAGE_PMD_NR;
+		ret = get_mctgt_type_thp(vma, addr, pmd, NULL);
 		spin_unlock(ptl);
+		if (ret == MC_TARGET_FALLBACK)
+			goto fallback;
+		if (ret)
+			mc.precharge += HPAGE_PMD_NR;
 		return 0;
 	}
 
+fallback:
 	if (pmd_trans_unstable(pmd))
 		return 0;
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
@@ -5115,6 +5184,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	enum mc_target_type target_type;
 	union mc_target target;
 	struct page *page;
+	swp_entry_t ent;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
@@ -5122,8 +5192,9 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			spin_unlock(ptl);
 			return 0;
 		}
-		target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
-		if (target_type == MC_TARGET_PAGE) {
+		target_type = get_mctgt_type_thp(vma, addr, pmd, &target);
+		switch (target_type) {
+		case MC_TARGET_PAGE:
 			page = target.page;
 			if (!isolate_lru_page(page)) {
 				if (!mem_cgroup_move_account(page, true,
@@ -5134,7 +5205,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 				putback_lru_page(page);
 			}
 			put_page(page);
-		} else if (target_type == MC_TARGET_DEVICE) {
+			break;
+		case MC_TARGET_DEVICE:
 			page = target.page;
 			if (!mem_cgroup_move_account(page, true,
 						     mc.from, mc.to)) {
@@ -5142,9 +5214,21 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 				mc.moved_charge += HPAGE_PMD_NR;
 			}
 			put_page(page);
+			break;
+		case MC_TARGET_SWAP:
+			ent = target.ent;
+			if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to,
+							  HPAGE_PMD_NR)) {
+				mc.precharge -= HPAGE_PMD_NR;
+				mc.moved_swap += HPAGE_PMD_NR;
+			}
+			break;
+		default:
+			break;
 		}
 		spin_unlock(ptl);
-		return 0;
+		if (target_type != MC_TARGET_FALLBACK)
+			return 0;
 	}
 
 	if (pmd_trans_unstable(pmd))
@@ -5154,7 +5238,6 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	for (; addr != end; addr += PAGE_SIZE) {
 		pte_t ptent = *(pte++);
 		bool device = false;
-		swp_entry_t ent;
 
 		if (!mc.precharge)
 			break;
@@ -5188,7 +5271,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			break;
 		case MC_TARGET_SWAP:
 			ent = target.ent;
-			if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to)) {
+			if (!mem_cgroup_move_swap_account(ent, mc.from,
+							  mc.to, 1)) {
 				mc.precharge--;
 				/* we fixup refcnts and charges later. */
 				mc.moved_swap++;
diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
index 45affaef3bc6..ccc08e88962a 100644
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -87,29 +87,58 @@ static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 
 /**
  * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
- * @ent: swap entry to be cmpxchged
+ * @ent: the first swap entry to be cmpxchged
  * @old: old id
  * @new: new id
+ * @nr_ents: number of swap entries
  *
  * Returns old id at success, 0 at failure.
  * (There is no mem_cgroup using 0 as its id)
  */
 unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
-					unsigned short old, unsigned short new)
+				   unsigned short old, unsigned short new,
+				   unsigned int nr_ents)
 {
 	struct swap_cgroup_ctrl *ctrl;
-	struct swap_cgroup *sc;
+	struct swap_cgroup *sc_start, *sc;
 	unsigned long flags;
 	unsigned short retval;
+	pgoff_t offset_start = swp_offset(ent), offset;
+	pgoff_t end = offset_start + nr_ents;
 
-	sc = lookup_swap_cgroup(ent, &ctrl);
+	sc_start = lookup_swap_cgroup(ent, &ctrl);
 
 	spin_lock_irqsave(&ctrl->lock, flags);
-	retval = sc->id;
-	if (retval == old)
+	sc = sc_start;
+	offset = offset_start;
+	for (;;) {
+		if (sc->id != old) {
+			retval = 0;
+			goto out;
+		}
+		offset++;
+		if (offset == end)
+			break;
+		if (offset % SC_PER_PAGE)
+			sc++;
+		else
+			sc = __lookup_swap_cgroup(ctrl, offset);
+	}
+
+	sc = sc_start;
+	offset = offset_start;
+	for (;;) {
 		sc->id = new;
-	else
-		retval = 0;
+		offset++;
+		if (offset == end)
+			break;
+		if (offset % SC_PER_PAGE)
+			sc++;
+		else
+			sc = __lookup_swap_cgroup(ctrl, offset);
+	}
+	retval = old;
+out:
 	spin_unlock_irqrestore(&ctrl->lock, flags);
 	return retval;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 9599c7059539..e4ed049aee8d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1687,6 +1687,18 @@ static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
 
 	return map_swapcount;
 }
+
+bool in_huge_swap_cluster(swp_entry_t entry)
+{
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci;
+
+	si = _swap_info_get(entry);
+	if (!si || !si->cluster_info)
+		return false;
+	ci = si->cluster_info + swp_offset(entry) / SWAPFILE_CLUSTER;
+	return cluster_is_huge(ci);
+}
 #else
 #define swap_page_trans_huge_swapped(si, entry)	swap_swapcount(si, entry, NULL)
 #define page_swapped(page)			(page_swapcount(page) != 0)
-- 
2.17.0
