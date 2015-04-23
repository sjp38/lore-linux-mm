Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A99796B0081
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:05:02 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so28265511pab.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:05:02 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id e9si14201687pas.150.2015.04.23.14.04.59
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:05:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 02/28] rmap: add argument to charge compound page
Date: Fri, 24 Apr 2015 00:03:37 +0300
Message-Id: <1429823043-157133-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to allow mapping of individual 4k pages of THP compound
page. It means we cannot rely on PageTransHuge() check to decide if
map/unmap small page or THP.

The patch adds new argument to rmap functions to indicate whether we want
to operate on whole compound page or only the small page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/rmap.h    | 12 +++++++++---
 kernel/events/uprobes.c |  4 ++--
 mm/filemap_xip.c        |  2 +-
 mm/huge_memory.c        | 16 ++++++++--------
 mm/hugetlb.c            |  4 ++--
 mm/ksm.c                |  4 ++--
 mm/memory.c             | 14 +++++++-------
 mm/migrate.c            |  8 ++++----
 mm/rmap.c               | 43 +++++++++++++++++++++++++++----------------
 mm/swapfile.c           |  4 ++--
 10 files changed, 64 insertions(+), 47 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index d3630fa3a17b..e7ecba43ae71 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -159,16 +159,22 @@ static inline void anon_vma_merge(struct vm_area_struct *vma,
 
 struct anon_vma *page_get_anon_vma(struct page *page);
 
+/* bitflags for do_page_add_anon_rmap() */
+#define RMAP_EXCLUSIVE 0x01
+#define RMAP_COMPOUND 0x02
+
 /*
  * rmap interfaces called when adding or removing pte of page
  */
 void page_move_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
-void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
+void page_add_anon_rmap(struct page *, struct vm_area_struct *,
+		unsigned long, bool);
 void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
 			   unsigned long, int);
-void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
+void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
+		unsigned long, bool);
 void page_add_file_rmap(struct page *);
-void page_remove_rmap(struct page *);
+void page_remove_rmap(struct page *, bool);
 
 void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
 			    unsigned long);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index cb346f26a22d..5523daf59953 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -183,7 +183,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 		goto unlock;
 
 	get_page(kpage);
-	page_add_new_anon_rmap(kpage, vma, addr);
+	page_add_new_anon_rmap(kpage, vma, addr, false);
 	mem_cgroup_commit_charge(kpage, memcg, false);
 	lru_cache_add_active_or_unevictable(kpage, vma);
 
@@ -196,7 +196,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	ptep_clear_flush_notify(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
 
-	page_remove_rmap(page);
+	page_remove_rmap(page, false);
 	if (!page_mapped(page))
 		try_to_free_swap(page);
 	pte_unmap_unlock(ptep, ptl);
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index c175f9f25210..791d9043a983 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -189,7 +189,7 @@ retry:
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
-			page_remove_rmap(page);
+			page_remove_rmap(page, false);
 			dec_mm_counter(mm, MM_FILEPAGES);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5a137c3a7f2f..b40fc0ff9315 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -752,7 +752,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pmd_t entry;
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		page_add_new_anon_rmap(page, vma, haddr);
+		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
@@ -1043,7 +1043,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
-		page_add_new_anon_rmap(pages[i], vma, haddr);
+		page_add_new_anon_rmap(pages[i], vma, haddr, false);
 		mem_cgroup_commit_charge(pages[i], memcg, false);
 		lru_cache_add_active_or_unevictable(pages[i], vma);
 		pte = pte_offset_map(&_pmd, haddr);
@@ -1055,7 +1055,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
-	page_remove_rmap(page);
+	page_remove_rmap(page, true);
 	spin_unlock(ptl);
 
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
@@ -1175,7 +1175,7 @@ alloc:
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_clear_flush_notify(vma, haddr, pmd);
-		page_add_new_anon_rmap(new_page, vma, haddr);
+		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		set_pmd_at(mm, haddr, pmd, entry);
@@ -1185,7 +1185,7 @@ alloc:
 			put_huge_zero_page();
 		} else {
 			VM_BUG_ON_PAGE(!PageHead(page), page);
-			page_remove_rmap(page);
+			page_remove_rmap(page, true);
 			put_page(page);
 		}
 		ret |= VM_FAULT_WRITE;
@@ -1440,7 +1440,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			put_huge_zero_page();
 		} else {
 			page = pmd_page(orig_pmd);
-			page_remove_rmap(page);
+			page_remove_rmap(page, true);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON_PAGE(!PageHead(page), page);
@@ -2285,7 +2285,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			 * superfluous.
 			 */
 			pte_clear(vma->vm_mm, address, _pte);
-			page_remove_rmap(src_page);
+			page_remove_rmap(src_page, false);
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
 		}
@@ -2580,7 +2580,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
-	page_add_new_anon_rmap(new_page, vma, address);
+	page_add_new_anon_rmap(new_page, vma, address, true);
 	mem_cgroup_commit_charge(new_page, memcg, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e8c92ae35b4b..eb2a0430535e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2797,7 +2797,7 @@ again:
 		if (huge_pte_dirty(pte))
 			set_page_dirty(page);
 
-		page_remove_rmap(page);
+		page_remove_rmap(page, true);
 		force_flush = !__tlb_remove_page(tlb, page);
 		if (force_flush) {
 			address += sz;
@@ -3018,7 +3018,7 @@ retry_avoidcopy:
 		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
-		page_remove_rmap(old_page);
+		page_remove_rmap(old_page, true);
 		hugepage_add_new_anon_rmap(new_page, vma, address);
 		/* Make the old page be freed below */
 		new_page = old_page;
diff --git a/mm/ksm.c b/mm/ksm.c
index bc7be0ee2080..fe09f3ddc912 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -957,13 +957,13 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	}
 
 	get_page(kpage);
-	page_add_anon_rmap(kpage, vma, addr);
+	page_add_anon_rmap(kpage, vma, addr, false);
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush_notify(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
 
-	page_remove_rmap(page);
+	page_remove_rmap(page, false);
 	if (!page_mapped(page))
 		try_to_free_swap(page);
 	put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index f150f7ed4e84..d6171752ea59 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1122,7 +1122,7 @@ again:
 					mark_page_accessed(page);
 				rss[MM_FILEPAGES]--;
 			}
-			page_remove_rmap(page);
+			page_remove_rmap(page, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(!__tlb_remove_page(tlb, page))) {
@@ -2108,7 +2108,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * thread doing COW.
 		 */
 		ptep_clear_flush_notify(vma, address, page_table);
-		page_add_new_anon_rmap(new_page, vma, address);
+		page_add_new_anon_rmap(new_page, vma, address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		/*
@@ -2141,7 +2141,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 			 * mapcount is visible. So transitively, TLBs to
 			 * old page will be flushed before it can be reused.
 			 */
-			page_remove_rmap(old_page);
+			page_remove_rmap(old_page, false);
 		}
 
 		/* Free the old page.. */
@@ -2556,7 +2556,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
-		exclusive = 1;
+		exclusive = RMAP_EXCLUSIVE;
 	}
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(orig_pte))
@@ -2566,7 +2566,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		do_page_add_anon_rmap(page, vma, address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, address);
+		page_add_new_anon_rmap(page, vma, address, false);
 		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
@@ -2704,7 +2704,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto release;
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, address);
+	page_add_new_anon_rmap(page, vma, address, false);
 	mem_cgroup_commit_charge(page, memcg, false);
 	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
@@ -2787,7 +2787,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, address);
+		page_add_new_anon_rmap(page, vma, address, false);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
 		page_add_file_rmap(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index 022adc253cd4..9a380238a4d0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -166,7 +166,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		else
 			page_dup_rmap(new);
 	} else if (PageAnon(new))
-		page_add_anon_rmap(new, vma, addr);
+		page_add_anon_rmap(new, vma, addr, false);
 	else
 		page_add_file_rmap(new);
 
@@ -1795,7 +1795,7 @@ fail_putback:
 	 * guarantee the copy is visible before the pagetable update.
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
-	page_add_anon_rmap(new_page, vma, mmun_start);
+	page_add_anon_rmap(new_page, vma, mmun_start, true);
 	pmdp_clear_flush_notify(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);
@@ -1806,13 +1806,13 @@ fail_putback:
 		flush_tlb_range(vma, mmun_start, mmun_end);
 		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
 		update_mmu_cache_pmd(vma, address, &entry);
-		page_remove_rmap(new_page);
+		page_remove_rmap(new_page, true);
 		goto fail_putback;
 	}
 
 	mem_cgroup_migrate(page, new_page, false);
 
-	page_remove_rmap(page);
+	page_remove_rmap(page, true);
 
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
diff --git a/mm/rmap.c b/mm/rmap.c
index dad23a43e42c..4ca4b5cffd95 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1048,9 +1048,9 @@ static void __page_check_anon_rmap(struct page *page,
  * (but PageKsm is never downgraded to PageAnon).
  */
 void page_add_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address)
+	struct vm_area_struct *vma, unsigned long address, bool compound)
 {
-	do_page_add_anon_rmap(page, vma, address, 0);
+	do_page_add_anon_rmap(page, vma, address, compound ? RMAP_COMPOUND : 0);
 }
 
 /*
@@ -1059,21 +1059,24 @@ void page_add_anon_rmap(struct page *page,
  * Everybody else should continue to use page_add_anon_rmap above.
  */
 void do_page_add_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address, int exclusive)
+	struct vm_area_struct *vma, unsigned long address, int flags)
 {
 	int first = atomic_inc_and_test(&page->_mapcount);
 	if (first) {
+		bool compound = flags & RMAP_COMPOUND;
+		int nr = compound ? hpage_nr_pages(page) : 1;
 		/*
 		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
 		 * these counters are not modified in interrupt context, and
 		 * pte lock(a spinlock) is held, which implies preemption
 		 * disabled.
 		 */
-		if (PageTransHuge(page))
+		if (compound) {
+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
-		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-				hpage_nr_pages(page));
+		}
+		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1081,7 +1084,8 @@ void do_page_add_anon_rmap(struct page *page,
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
-		__page_set_anon_rmap(page, vma, address, exclusive);
+		__page_set_anon_rmap(page, vma, address,
+				flags & RMAP_EXCLUSIVE);
 	else
 		__page_check_anon_rmap(page, vma, address);
 }
@@ -1097,15 +1101,18 @@ void do_page_add_anon_rmap(struct page *page,
  * Page does not have to be locked.
  */
 void page_add_new_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address)
+	struct vm_area_struct *vma, unsigned long address, bool compound)
 {
+	int nr = compound ? hpage_nr_pages(page) : 1;
+
 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
-	if (PageTransHuge(page))
+	if (compound) {
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-			hpage_nr_pages(page));
+	}
+	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
 }
 
@@ -1161,9 +1168,12 @@ out:
  *
  * The caller needs to hold the pte lock.
  */
-void page_remove_rmap(struct page *page)
+void page_remove_rmap(struct page *page, bool compound)
 {
+	int nr = compound ? hpage_nr_pages(page) : 1;
+
 	if (!PageAnon(page)) {
+		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
 		page_remove_file_rmap(page);
 		return;
 	}
@@ -1181,11 +1191,12 @@ void page_remove_rmap(struct page *page)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	if (PageTransHuge(page))
+	if (compound) {
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	}
 
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-			      -hpage_nr_pages(page));
+	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
@@ -1327,7 +1338,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		dec_mm_counter(mm, MM_FILEPAGES);
 
 discard:
-	page_remove_rmap(page);
+	page_remove_rmap(page, false);
 	page_cache_release(page);
 
 out_unmap:
diff --git a/mm/swapfile.c b/mm/swapfile.c
index a7e72103f23b..65825c2687f5 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1121,10 +1121,10 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	if (page == swapcache) {
-		page_add_anon_rmap(page, vma, addr);
+		page_add_anon_rmap(page, vma, addr, false);
 		mem_cgroup_commit_charge(page, memcg, true);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, addr);
+		page_add_new_anon_rmap(page, vma, addr, false);
 		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
