Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B57606B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 20:23:28 -0400 (EDT)
Date: Fri, 9 Jul 2010 02:23:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] fix swapin race condition
Message-ID: <20100709002322.GO6197@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Hugh,

can you review this patch? This is only theoretical so far.

Basically a thread can get stuck in ksm_does_need_to_copy after the
unlock_page (with orig_pte pointing to swap entry A). In the meantime
another thread can do the ksm swapin copy too, the copy can be swapped
out to swap entry B, then a new swapin can create a new copy that can
return to swap entry A if reused by things like try_to_free_swap (to
me it seems the page pin is useless to prevent the swapcache to go
away, it only helps in page reclaim but swapcache is removed by other
things too). So then the first thread can finish the ksm-copy find the
pte_same pointing to swap entry A again (despite it passed through
swap entry B) and break.

I also don't seem to see a guarantee that lookup_swap_cache returns
swapcache until we take the lock on the page.

I exclude this can cause regressions, but I'd like to know if it
really can happen or if I'm missing something and it cannot happen. I
surely looks weird that lookup_swap_cache might return a page that
gets removed from swapcache before we take the page lock but I don't
see anything preventing it. Surely it's not going to happen until >50%
swap is full.

It's also possible to fix it by forcing do_wp_page to run but for a
little while it won't be possible to rmap the the instantiated page so
I didn't change that even if it probably would make life easier to
memcg swapin handlers (maybe, dunno).

Thanks,
Andrea

======
Subject: fix swapin race condition

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
