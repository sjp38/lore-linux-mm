Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D010C6B00A1
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:10:24 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so21151163pdj.4
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:10:24 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id bo6si30550010pab.172.2013.12.03.16.10.22
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 16:10:23 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 7/9] mm/rmap: use rmap_walk() in try_to_munlock()
Date: Wed,  4 Dec 2013 09:12:18 +0900
Message-Id: <1386115940-21425-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have an infrastructure in rmap_walk() to handle difference
from variants of rmap traversing functions.

So, just use it in try_to_munlock().

In this patch, I change following things.

1. remove some variants of rmap traversing functions.
	cf> try_to_unmap_ksm, try_to_unmap_anon, try_to_unmap_file
2. mechanical change to use rmap_walk() in try_to_munlock().
3. copy and paste comments.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 0eef8cb..91b9719 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -75,7 +75,6 @@ struct page *ksm_might_need_to_copy(struct page *page,
 
 int page_referenced_ksm(struct page *page,
 			struct mem_cgroup *memcg, unsigned long *vm_flags);
-int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
 int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 
@@ -114,11 +113,6 @@ static inline int page_referenced_ksm(struct page *page,
 	return 0;
 }
 
-static inline int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
-{
-	return 0;
-}
-
 static inline int rmap_walk_ksm(struct page *page,
 			struct rmap_walk_control *rwc)
 {
diff --git a/mm/ksm.c b/mm/ksm.c
index 6b4baa9..646d45a 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1946,56 +1946,6 @@ out:
 	return referenced;
 }
 
-int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
-{
-	struct stable_node *stable_node;
-	struct rmap_item *rmap_item;
-	int ret = SWAP_AGAIN;
-	int search_new_forks = 0;
-
-	VM_BUG_ON(!PageKsm(page));
-	VM_BUG_ON(!PageLocked(page));
-
-	stable_node = page_stable_node(page);
-	if (!stable_node)
-		return SWAP_FAIL;
-again:
-	hlist_for_each_entry(rmap_item, &stable_node->hlist, hlist) {
-		struct anon_vma *anon_vma = rmap_item->anon_vma;
-		struct anon_vma_chain *vmac;
-		struct vm_area_struct *vma;
-
-		anon_vma_lock_read(anon_vma);
-		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
-					       0, ULONG_MAX) {
-			vma = vmac->vma;
-			if (rmap_item->address < vma->vm_start ||
-			    rmap_item->address >= vma->vm_end)
-				continue;
-			/*
-			 * Initially we examine only the vma which covers this
-			 * rmap_item; but later, if there is still work to do,
-			 * we examine covering vmas in other mms: in case they
-			 * were forked from the original since ksmd passed.
-			 */
-			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
-				continue;
-
-			ret = try_to_unmap_one(page, vma,
-					rmap_item->address, (void *)flags);
-			if (ret != SWAP_AGAIN || !page_mapped(page)) {
-				anon_vma_unlock_read(anon_vma);
-				goto out;
-			}
-		}
-		anon_vma_unlock_read(anon_vma);
-	}
-	if (!search_new_forks++)
-		goto again;
-out:
-	return ret;
-}
-
 int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct stable_node *stable_node;
diff --git a/mm/rmap.c b/mm/rmap.c
index d34fa0e..8724c06 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1173,9 +1173,6 @@ out:
 }
 
 /*
- * Subfunctions of try_to_unmap: try_to_unmap_one called
- * repeatedly from try_to_unmap_ksm, try_to_unmap_anon or try_to_unmap_file.
- *
  * @arg: enum ttu_flags will be passed to this argument
  */
 int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
@@ -1517,107 +1514,6 @@ static bool invalid_migration_vma(struct vm_area_struct *vma, void *arg)
 	return is_vma_temporary_stack(vma);
 }
 
-/**
- * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
- * rmap method
- * @page: the page to unmap/unlock
- * @flags: action and flags
- *
- * Find all the mappings of a page using the mapping pointer and the vma chains
- * contained in the anon_vma struct it points to.
- *
- * This function is only called from try_to_unmap/try_to_munlock for
- * anonymous pages.
- * When called from try_to_munlock(), the mmap_sem of the mm containing the vma
- * where the page was found will be held for write.  So, we won't recheck
- * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
- * 'LOCKED.
- */
-static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
-{
-	struct anon_vma *anon_vma;
-	pgoff_t pgoff;
-	struct anon_vma_chain *avc;
-	int ret = SWAP_AGAIN;
-
-	anon_vma = page_lock_anon_vma_read(page);
-	if (!anon_vma)
-		return ret;
-
-	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
-		struct vm_area_struct *vma = avc->vma;
-		unsigned long address;
-
-		/*
-		 * During exec, a temporary VMA is setup and later moved.
-		 * The VMA is moved under the anon_vma lock but not the
-		 * page tables leading to a race where migration cannot
-		 * find the migration ptes. Rather than increasing the
-		 * locking requirements of exec(), migration skips
-		 * temporary VMAs until after exec() completes.
-		 */
-		if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
-				is_vma_temporary_stack(vma))
-			continue;
-
-		address = vma_address(page, vma);
-		ret = try_to_unmap_one(page, vma, address, (void *)flags);
-		if (ret != SWAP_AGAIN || !page_mapped(page))
-			break;
-	}
-
-	page_unlock_anon_vma_read(anon_vma);
-	return ret;
-}
-
-/**
- * try_to_unmap_file - unmap/unlock file page using the object-based rmap method
- * @page: the page to unmap/unlock
- * @flags: action and flags
- *
- * Find all the mappings of a page using the mapping pointer and the vma chains
- * contained in the address_space struct it points to.
- *
- * This function is only called from try_to_unmap/try_to_munlock for
- * object-based pages.
- * When called from try_to_munlock(), the mmap_sem of the mm containing the vma
- * where the page was found will be held for write.  So, we won't recheck
- * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
- * 'LOCKED.
- */
-static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
-{
-	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << compound_order(page);
-	struct vm_area_struct *vma;
-	int ret = SWAP_AGAIN;
-
-	mutex_lock(&mapping->i_mmap_mutex);
-	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
-		unsigned long address = vma_address(page, vma);
-		ret = try_to_unmap_one(page, vma, address, (void *)flags);
-		if (ret != SWAP_AGAIN || !page_mapped(page))
-			goto out;
-	}
-
-	if (list_empty(&mapping->i_mmap_nonlinear))
-		goto out;
-
-	/*
-	 * We don't bother to try to find the munlocked page in nonlinears.
-	 * It's costly. Instead, later, page reclaim logic may call
-	 * try_to_unmap(TTU_MUNLOCK) and recover PG_mlocked lazily.
-	 */
-	if (TTU_ACTION(flags) == TTU_MUNLOCK)
-		goto out;
-
-	ret = try_to_unmap_nonlinear(page, mapping, vma);
-out:
-	mutex_unlock(&mapping->i_mmap_mutex);
-	return ret;
-}
-
 static int page_not_mapped(struct page *page)
 {
 	return !page_mapped(page);
@@ -1685,14 +1581,25 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
  */
 int try_to_munlock(struct page *page)
 {
+	int ret;
+	struct rmap_walk_control rwc = {
+		.rmap_one = try_to_unmap_one,
+		.arg = (void *)TTU_MUNLOCK,
+		.done = page_not_mapped,
+		/*
+		 * We don't bother to try to find the munlocked page in
+		 * nonlinears. It's costly. Instead, later, page reclaim logic
+		 * may call try_to_unmap() and recover PG_mlocked lazily.
+		 */
+		.file_nonlinear = NULL,
+		.anon_lock = page_lock_anon_vma_read,
+
+	};
+
 	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
 
-	if (unlikely(PageKsm(page)))
-		return try_to_unmap_ksm(page, TTU_MUNLOCK);
-	else if (PageAnon(page))
-		return try_to_unmap_anon(page, TTU_MUNLOCK);
-	else
-		return try_to_unmap_file(page, TTU_MUNLOCK);
+	ret = rmap_walk(page, &rwc);
+	return ret;
 }
 
 void __put_anon_vma(struct anon_vma *anon_vma)
@@ -1728,8 +1635,18 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
 }
 
 /*
- * rmap_walk() and its helpers rmap_walk_anon() and rmap_walk_file():
- * Called by migrate.c to remove migration ptes, but might be used more later.
+ * rmap_walk_anon - do something to anonymous page using the object-based
+ * rmap method
+ * @page: the page to be handled
+ * @rwc: control variable according to each walk type
+ *
+ * Find all the mappings of a page using the mapping pointer and the vma chains
+ * contained in the anon_vma struct it points to.
+ *
+ * When called from try_to_munlock(), the mmap_sem of the mm containing the vma
+ * where the page was found will be held for write.  So, we won't recheck
+ * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
+ * LOCKED.
  */
 static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 {
@@ -1759,6 +1676,19 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 	return ret;
 }
 
+/*
+ * rmap_walk_file - do something to file page using the object-based rmap method
+ * @page: the page to be handled
+ * @rwc: control variable according to each walk type
+ *
+ * Find all the mappings of a page using the mapping pointer and the vma chains
+ * contained in the address_space struct it points to.
+ *
+ * When called from try_to_munlock(), the mmap_sem of the mm containing the vma
+ * where the page was found will be held for write.  So, we won't recheck
+ * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
+ * LOCKED.
+ */
 static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct address_space *mapping = page->mapping;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
