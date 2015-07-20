Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id DC2FC9003CA
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:21:27 -0400 (EDT)
Received: by ietj16 with SMTP id j16so118804006iet.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:21:27 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id f4si6168436igc.19.2015.07.20.07.21.22
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 02/36] rmap: add argument to charge compound page
Date: Mon, 20 Jul 2015 17:20:35 +0300
Message-Id: <1437402069-105900-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
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
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/rmap.h    | 12 +++++++++---
 kernel/events/uprobes.c |  4 ++--
 mm/huge_memory.c        | 16 ++++++++--------
 mm/hugetlb.c            |  4 ++--
 mm/ksm.c                |  4 ++--
 mm/memory.c             | 14 +++++++-------
 mm/migrate.c            |  8 ++++----
 mm/rmap.c               | 48 +++++++++++++++++++++++++++++++-----------------
 mm/swapfile.c           |  4 ++--
 mm/userfaultfd.c        |  2 +-
 10 files changed, 68 insertions(+), 48 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 0860336c6c40..082928aba785 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -162,16 +162,22 @@ static inline void anon_vma_merge(struct vm_area_struct *vma,
 
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
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8f9a334a6c66..4e8e3c267cdf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -769,7 +769,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		page_add_new_anon_rmap(page, vma, haddr);
+		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
@@ -1111,7 +1111,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
-		page_add_new_anon_rmap(pages[i], vma, haddr);
+		page_add_new_anon_rmap(pages[i], vma, haddr, false);
 		mem_cgroup_commit_charge(pages[i], memcg, false);
 		lru_cache_add_active_or_unevictable(pages[i], vma);
 		pte = pte_offset_map(&_pmd, haddr);
@@ -1123,7 +1123,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
-	page_remove_rmap(page);
+	page_remove_rmap(page, true);
 	spin_unlock(ptl);
 
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
@@ -1243,7 +1243,7 @@ alloc:
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_huge_clear_flush_notify(vma, haddr, pmd);
-		page_add_new_anon_rmap(new_page, vma, haddr);
+		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		set_pmd_at(mm, haddr, pmd, entry);
@@ -1253,7 +1253,7 @@ alloc:
 			put_huge_zero_page();
 		} else {
 			VM_BUG_ON_PAGE(!PageHead(page), page);
-			page_remove_rmap(page);
+			page_remove_rmap(page, true);
 			put_page(page);
 		}
 		ret |= VM_FAULT_WRITE;
@@ -1516,7 +1516,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			put_huge_zero_page();
 		} else {
 			struct page *page = pmd_page(orig_pmd);
-			page_remove_rmap(page);
+			page_remove_rmap(page, true);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON_PAGE(!PageHead(page), page);
@@ -2363,7 +2363,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			 * superfluous.
 			 */
 			pte_clear(vma->vm_mm, address, _pte);
-			page_remove_rmap(src_page);
+			page_remove_rmap(src_page, false);
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
 		}
@@ -2658,7 +2658,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
-	page_add_new_anon_rmap(new_page, vma, address);
+	page_add_new_anon_rmap(new_page, vma, address, true);
 	mem_cgroup_commit_charge(new_page, memcg, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 51ae41d0fbc0..b98f5e944849 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2877,7 +2877,7 @@ again:
 		if (huge_pte_dirty(pte))
 			set_page_dirty(page);
 
-		page_remove_rmap(page);
+		page_remove_rmap(page, true);
 		force_flush = !__tlb_remove_page(tlb, page);
 		if (force_flush) {
 			address += sz;
@@ -3098,7 +3098,7 @@ retry_avoidcopy:
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
index c70252ca9ef9..ae98aba42697 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1125,7 +1125,7 @@ again:
 					mark_page_accessed(page);
 				rss[MM_FILEPAGES]--;
 			}
-			page_remove_rmap(page);
+			page_remove_rmap(page, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(!__tlb_remove_page(tlb, page))) {
@@ -2113,7 +2113,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * thread doing COW.
 		 */
 		ptep_clear_flush_notify(vma, address, page_table);
-		page_add_new_anon_rmap(new_page, vma, address);
+		page_add_new_anon_rmap(new_page, vma, address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		/*
@@ -2146,7 +2146,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 			 * mapcount is visible. So transitively, TLBs to
 			 * old page will be flushed before it can be reused.
 			 */
-			page_remove_rmap(old_page);
+			page_remove_rmap(old_page, false);
 		}
 
 		/* Free the old page.. */
@@ -2562,7 +2562,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
-		exclusive = 1;
+		exclusive = RMAP_EXCLUSIVE;
 	}
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(orig_pte))
@@ -2572,7 +2572,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		do_page_add_anon_rmap(page, vma, address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, address);
+		page_add_new_anon_rmap(page, vma, address, false);
 		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
@@ -2730,7 +2730,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, address);
+	page_add_new_anon_rmap(page, vma, address, false);
 	mem_cgroup_commit_charge(page, memcg, false);
 	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
@@ -2818,7 +2818,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, address);
+		page_add_new_anon_rmap(page, vma, address, false);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
 		page_add_file_rmap(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index d3529d620a5b..4870a1daa8ae 100644
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
 
@@ -1792,7 +1792,7 @@ fail_putback:
 	 * guarantee the copy is visible before the pagetable update.
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
-	page_add_anon_rmap(new_page, vma, mmun_start);
+	page_add_anon_rmap(new_page, vma, mmun_start, true);
 	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);
@@ -1803,13 +1803,13 @@ fail_putback:
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
index 30812e9042ae..5ee08e082e51 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1150,6 +1150,7 @@ static void __page_check_anon_rmap(struct page *page,
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
+ * @compound:	charge the page as compound or small page
  *
  * The caller needs to hold the pte lock, and the page must be locked in
  * the anon_vma case: to serialize mapping,index checking after setting,
@@ -1157,9 +1158,9 @@ static void __page_check_anon_rmap(struct page *page,
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
@@ -1168,21 +1169,24 @@ void page_add_anon_rmap(struct page *page,
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
@@ -1190,7 +1194,8 @@ void do_page_add_anon_rmap(struct page *page,
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
-		__page_set_anon_rmap(page, vma, address, exclusive);
+		__page_set_anon_rmap(page, vma, address,
+				flags & RMAP_EXCLUSIVE);
 	else
 		__page_check_anon_rmap(page, vma, address);
 }
@@ -1200,21 +1205,25 @@ void do_page_add_anon_rmap(struct page *page,
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
+ * @compound:	charge the page as compound or small page
  *
  * Same as page_add_anon_rmap but must only be called on *new* pages.
  * This means the inc-and-test can be bypassed.
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
 
@@ -1266,13 +1275,17 @@ out:
 
 /**
  * page_remove_rmap - take down pte mapping from a page
- * @page: page to remove mapping from
+ * @page:	page to remove mapping from
+ * @compound:	uncharge the page as compound or small page
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
@@ -1290,11 +1303,12 @@ void page_remove_rmap(struct page *page)
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
@@ -1449,7 +1463,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		dec_mm_counter(mm, MM_FILEPAGES);
 
 discard:
-	page_remove_rmap(page);
+	page_remove_rmap(page, false);
 	page_cache_release(page);
 
 out_unmap:
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 738c2662209e..7ba293b112e3 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1163,10 +1163,10 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
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
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 77fee9325a57..ae21a1f309c2 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -76,7 +76,7 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 		goto out_release_uncharge_unlock;
 
 	inc_mm_counter(dst_mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, dst_vma, dst_addr);
+	page_add_new_anon_rmap(page, dst_vma, dst_addr, false);
 	mem_cgroup_commit_charge(page, memcg, false);
 	lru_cache_add_active_or_unevictable(page, dst_vma);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
