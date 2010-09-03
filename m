Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8DCAB6B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:40:03 -0400 (EDT)
Date: Fri, 3 Sep 2010 17:39:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] fix swapin race condition
Message-ID: <20100903153958.GC16761@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

The pte_same check is reliable only if the swap entry remains pinned
(by the page lock on swapcache). We've also to ensure the swapcache
isn't removed before we take the lock as try_to_free_swap won't care
about the page pin.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -16,6 +16,9 @@
 struct stable_node;
 struct mem_cgroup;
 
+struct page *ksm_does_need_to_copy(struct page *page,
+			struct vm_area_struct *vma, unsigned long address);
+
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
@@ -70,19 +73,14 @@ static inline void set_page_stable_node(
  * We'd like to make this conditional on vma->vm_flags & VM_MERGEABLE,
  * but what if the vma was unmerged while the page was swapped out?
  */
-struct page *ksm_does_need_to_copy(struct page *page,
-			struct vm_area_struct *vma, unsigned long address);
-static inline struct page *ksm_might_need_to_copy(struct page *page,
+static inline int ksm_might_need_to_copy(struct page *page,
 			struct vm_area_struct *vma, unsigned long address)
 {
 	struct anon_vma *anon_vma = page_anon_vma(page);
 
-	if (!anon_vma ||
-	    (anon_vma->root == vma->anon_vma->root &&
-	     page->index == linear_page_index(vma, address)))
-		return page;
-
-	return ksm_does_need_to_copy(page, vma, address);
+	return anon_vma &&
+		(anon_vma->root != vma->anon_vma->root ||
+		 page->index != linear_page_index(vma, address));
 }
 
 int page_referenced_ksm(struct page *page,
@@ -115,10 +113,10 @@ static inline int ksm_madvise(struct vm_
 	return 0;
 }
 
-static inline struct page *ksm_might_need_to_copy(struct page *page,
+static inline int ksm_might_need_to_copy(struct page *page,
 			struct vm_area_struct *vma, unsigned long address)
 {
-	return page;
+	return 0;
 }
 
 static inline int page_referenced_ksm(struct page *page,
diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1518,8 +1518,6 @@ struct page *ksm_does_need_to_copy(struc
 {
 	struct page *new_page;
 
-	unlock_page(page);	/* any racers will COW it, not modify it */
-
 	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 	if (new_page) {
 		copy_user_highpage(new_page, page, address, vma);
@@ -1535,7 +1533,6 @@ struct page *ksm_does_need_to_copy(struc
 			add_page_to_unevictable_list(new_page);
 	}
 
-	page_cache_release(page);
 	return new_page;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2616,7 +2616,7 @@ static int do_swap_page(struct mm_struct
 		unsigned int flags, pte_t orig_pte)
 {
 	spinlock_t *ptl;
-	struct page *page;
+	struct page *page, *swapcache = NULL;
 	swp_entry_t entry;
 	pte_t pte;
 	struct mem_cgroup *ptr = NULL;
@@ -2671,10 +2671,23 @@ static int do_swap_page(struct mm_struct
 	lock_page(page);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
-	page = ksm_might_need_to_copy(page, vma, address);
-	if (!page) {
-		ret = VM_FAULT_OOM;
-		goto out;
+	/*
+	 * Make sure try_to_free_swap didn't release the swapcache
+	 * from under us. The page pin isn't enough to prevent that.
+	 */
+	if (unlikely(!PageSwapCache(page)))
+		goto out_page;
+
+	if (ksm_might_need_to_copy(page, vma, address)) {
+		swapcache = page;
+		page = ksm_does_need_to_copy(page, vma, address);
+
+		if (unlikely(!page)) {
+			ret = VM_FAULT_OOM;
+			page = swapcache;
+			swapcache = NULL;
+			goto out_page;
+		}
 	}
 
 	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
@@ -2725,6 +2738,18 @@ static int do_swap_page(struct mm_struct
 	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
+	if (swapcache) {
+		/*
+		 * Hold the lock to avoid the swap entry to be reused
+		 * until we take the PT lock for the pte_same() check
+		 * (to avoid false positives from pte_same). For
+		 * further safety release the lock after the swap_free
+		 * so that the swap count won't change under a
+		 * parallel locked swapcache.
+		 */
+		unlock_page(swapcache);
+		page_cache_release(swapcache);
+	}
 
 	if (flags & FAULT_FLAG_WRITE) {
 		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
@@ -2746,6 +2771,10 @@ out_page:
 	unlock_page(page);
 out_release:
 	page_cache_release(page);
+	if (swapcache) {
+		unlock_page(swapcache);
+		page_cache_release(swapcache);
+	}
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
