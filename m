Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB556B0070
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 15:58:22 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so18823734wiv.13
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 12:58:21 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id cq2si31981802wjc.73.2014.12.01.12.58.21
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 12:58:21 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH v2 3/4] mm: refactor do_wp_page, extract the page copy flow
Date: Mon,  1 Dec 2014 22:58:10 +0200
Message-Id: <1417467491-20071-4-git-send-email-raindel@mellanox.com>
In-Reply-To: <1417467491-20071-1-git-send-email-raindel@mellanox.com>
References: <1417467491-20071-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, raindel@mellanox.com

In some cases, do_wp_page had to copy the page suffering a write fault
to a new location. If the function logic decided that to do this, it
was done by jumping with a "goto" operation to the relevant code
block. This made the code really hard to understand. It is also
against the kernel coding style guidelines.

This patch extracts the page copy and page table update logic to a
separate function. It also clean up the naming, from "gotten" to
"wp_page_copy", and adds few comments.

Signed-off-by: Shachar Raindel <raindel@mellanox.com>
---
 mm/memory.c | 265 +++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 147 insertions(+), 118 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index b42bec0..c7c0df2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2088,6 +2088,146 @@ static int wp_page_reuse(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 /*
+ * Handle the case of a page which we actually need to copy to a new page.
+ *
+ * Called with mmap_sem locked and the old page referenced, but
+ * without the ptl held.
+ *
+ * High level logic flow:
+ *
+ * - Allocate a page, copy the content of the old page to the new one.
+ * - Handle book keeping and accounting - cgroups, mmu-notifiers, etc.
+ * - Take the PTL. If the pte changed, bail out and release the allocated page
+ * - If the pte is still the way we remember it, update the page table and all
+ *   relevant references. This includes dropping the reference the page-table
+ *   held to the old page, as well as updating the rmap.
+ * - In any case, unlock the PTL and drop the reference we took to the old page.
+ */
+static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pte_t *page_table, pmd_t *pmd,
+			pte_t orig_pte, struct page *old_page)
+{
+	struct page *new_page = NULL;
+	spinlock_t *ptl = NULL;
+	pte_t entry;
+	int page_copied = 0;
+	const unsigned long mmun_start = address & PAGE_MASK;	/* For mmu_notifiers */
+	const unsigned long mmun_end = mmun_start + PAGE_SIZE;	/* For mmu_notifiers */
+	struct mem_cgroup *memcg;
+
+	if (unlikely(anon_vma_prepare(vma)))
+		goto oom;
+
+	if (is_zero_pfn(pte_pfn(orig_pte))) {
+		new_page = alloc_zeroed_user_highpage_movable(vma, address);
+		if (!new_page)
+			goto oom;
+	} else {
+		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+		if (!new_page)
+			goto oom;
+		cow_user_page(new_page, old_page, address, vma);
+	}
+	__SetPageUptodate(new_page);
+
+	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg))
+		goto oom_free_new;
+
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
+	/*
+	 * Re-check the pte - we dropped the lock
+	 */
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (likely(pte_same(*page_table, orig_pte))) {
+		if (old_page) {
+			if (!PageAnon(old_page)) {
+				dec_mm_counter_fast(mm, MM_FILEPAGES);
+				inc_mm_counter_fast(mm, MM_ANONPAGES);
+			}
+		} else {
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
+		}
+		flush_cache_page(vma, address, pte_pfn(orig_pte));
+		entry = mk_pte(new_page, vma->vm_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		/*
+		 * Clear the pte entry and flush it first, before updating the
+		 * pte with the new entry. This will avoid a race condition
+		 * seen in the presence of one thread doing SMC and another
+		 * thread doing COW.
+		 */
+		ptep_clear_flush(vma, address, page_table);
+		page_add_new_anon_rmap(new_page, vma, address);
+		mem_cgroup_commit_charge(new_page, memcg, false);
+		lru_cache_add_active_or_unevictable(new_page, vma);
+		/*
+		 * We call the notify macro here because, when using secondary
+		 * mmu page tables (such as kvm shadow page tables), we want the
+		 * new page to be mapped directly into the secondary page table.
+		 */
+		set_pte_at_notify(mm, address, page_table, entry);
+		update_mmu_cache(vma, address, page_table);
+		if (old_page) {
+			/*
+			 * Only after switching the pte to the new page may
+			 * we remove the mapcount here. Otherwise another
+			 * process may come and find the rmap count decremented
+			 * before the pte is switched to the new page, and
+			 * "reuse" the old page writing into it while our pte
+			 * here still points into it and can be read by other
+			 * threads.
+			 *
+			 * The critical issue is to order this
+			 * page_remove_rmap with the ptp_clear_flush above.
+			 * Those stores are ordered by (if nothing else,)
+			 * the barrier present in the atomic_add_negative
+			 * in page_remove_rmap.
+			 *
+			 * Then the TLB flush in ptep_clear_flush ensures that
+			 * no process can access the old page before the
+			 * decremented mapcount is visible. And the old page
+			 * cannot be reused until after the decremented
+			 * mapcount is visible. So transitively, TLBs to
+			 * old page will be flushed before it can be reused.
+			 */
+			page_remove_rmap(old_page);
+		}
+
+		/* Free the old page.. */
+		new_page = old_page;
+		page_copied = 1;
+	} else {
+		mem_cgroup_cancel_charge(new_page, memcg);
+	}
+
+	if (new_page)
+		page_cache_release(new_page);
+
+	pte_unmap_unlock(page_table, ptl);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	if (old_page) {
+		/*
+		 * Don't let another task, with possibly unlocked vma,
+		 * keep the mlocked page.
+		 */
+		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
+			lock_page(old_page);	/* LRU manipulation */
+			munlock_vma_page(old_page);
+			unlock_page(old_page);
+		}
+		page_cache_release(old_page);
+	}
+	return page_copied ? VM_FAULT_WRITE : 0;
+oom_free_new:
+	page_cache_release(new_page);
+oom:
+	if (old_page)
+		page_cache_release(old_page);
+	return VM_FAULT_OOM;
+}
+
+/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -2110,12 +2250,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		spinlock_t *ptl, pte_t orig_pte)
 	__releases(ptl)
 {
-	struct page *old_page, *new_page = NULL;
-	pte_t entry;
-	int page_copied = 0;
-	unsigned long mmun_start = 0;	/* For mmu_notifiers */
-	unsigned long mmun_end = 0;	/* For mmu_notifiers */
-	struct mem_cgroup *memcg;
+	struct page *old_page;
 
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page) {
@@ -2131,7 +2266,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				     (VM_WRITE|VM_SHARED))
 			return wp_page_reuse(mm, vma, address, page_table, ptl,
 					     orig_pte, old_page, 0, 0);
-		goto gotten;
+
+		pte_unmap_unlock(page_table, ptl);
+		return wp_page_copy(mm, vma, address, page_table, pmd,
+				    orig_pte, old_page);
 	}
 
 	/*
@@ -2211,119 +2349,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * Ok, we need to copy. Oh, well..
 	 */
 	page_cache_get(old_page);
-gotten:
-	pte_unmap_unlock(page_table, ptl);
-
-	if (unlikely(anon_vma_prepare(vma)))
-		goto oom;
-
-	if (is_zero_pfn(pte_pfn(orig_pte))) {
-		new_page = alloc_zeroed_user_highpage_movable(vma, address);
-		if (!new_page)
-			goto oom;
-	} else {
-		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
-		if (!new_page)
-			goto oom;
-		cow_user_page(new_page, old_page, address, vma);
-	}
-	__SetPageUptodate(new_page);
-
-	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg))
-		goto oom_free_new;
-
-	mmun_start  = address & PAGE_MASK;
-	mmun_end    = mmun_start + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
-	/*
-	 * Re-check the pte - we dropped the lock
-	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (likely(pte_same(*page_table, orig_pte))) {
-		if (old_page) {
-			if (!PageAnon(old_page)) {
-				dec_mm_counter_fast(mm, MM_FILEPAGES);
-				inc_mm_counter_fast(mm, MM_ANONPAGES);
-			}
-		} else
-			inc_mm_counter_fast(mm, MM_ANONPAGES);
-		flush_cache_page(vma, address, pte_pfn(orig_pte));
-		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		/*
-		 * Clear the pte entry and flush it first, before updating the
-		 * pte with the new entry. This will avoid a race condition
-		 * seen in the presence of one thread doing SMC and another
-		 * thread doing COW.
-		 */
-		ptep_clear_flush(vma, address, page_table);
-		page_add_new_anon_rmap(new_page, vma, address);
-		mem_cgroup_commit_charge(new_page, memcg, false);
-		lru_cache_add_active_or_unevictable(new_page, vma);
-		/*
-		 * We call the notify macro here because, when using secondary
-		 * mmu page tables (such as kvm shadow page tables), we want the
-		 * new page to be mapped directly into the secondary page table.
-		 */
-		set_pte_at_notify(mm, address, page_table, entry);
-		update_mmu_cache(vma, address, page_table);
-		if (old_page) {
-			/*
-			 * Only after switching the pte to the new page may
-			 * we remove the mapcount here. Otherwise another
-			 * process may come and find the rmap count decremented
-			 * before the pte is switched to the new page, and
-			 * "reuse" the old page writing into it while our pte
-			 * here still points into it and can be read by other
-			 * threads.
-			 *
-			 * The critical issue is to order this
-			 * page_remove_rmap with the ptp_clear_flush above.
-			 * Those stores are ordered by (if nothing else,)
-			 * the barrier present in the atomic_add_negative
-			 * in page_remove_rmap.
-			 *
-			 * Then the TLB flush in ptep_clear_flush ensures that
-			 * no process can access the old page before the
-			 * decremented mapcount is visible. And the old page
-			 * cannot be reused until after the decremented
-			 * mapcount is visible. So transitively, TLBs to
-			 * old page will be flushed before it can be reused.
-			 */
-			page_remove_rmap(old_page);
-		}
-
-		/* Free the old page.. */
-		new_page = old_page;
-		page_copied = 1;
-	} else
-		mem_cgroup_cancel_charge(new_page, memcg);
-
-	if (new_page)
-		page_cache_release(new_page);
 
 	pte_unmap_unlock(page_table, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-	if (old_page) {
-		/*
-		 * Don't let another task, with possibly unlocked vma,
-		 * keep the mlocked page.
-		 */
-		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
-			lock_page(old_page);	/* LRU manipulation */
-			munlock_vma_page(old_page);
-			unlock_page(old_page);
-		}
-		page_cache_release(old_page);
-	}
-	return page_copied ? VM_FAULT_WRITE : 0;
-oom_free_new:
-	page_cache_release(new_page);
-oom:
-	if (old_page)
-		page_cache_release(old_page);
-	return VM_FAULT_OOM;
+	return wp_page_copy(mm, vma, address, page_table, pmd,
+			    orig_pte, old_page);
 }
 
 static void unmap_mapping_range_vma(struct vm_area_struct *vma,
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
