Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id B32A96B00A1
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:10:23 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so22099331pbc.21
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:10:23 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id f4si24646103pbm.115.2013.12.03.16.10.21
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 16:10:22 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 6/9] mm/rmap: use rmap_walk() in try_to_unmap()
Date: Wed,  4 Dec 2013 09:12:17 +0900
Message-Id: <1386115940-21425-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have an infrastructure in rmap_walk() to handle difference
from variants of rmap traversing functions.

So, just use it in try_to_unmap().

In this patch, I change following things.

1. enable rmap_walk() if !CONFIG_MIGRATION.
2. mechanical change to use rmap_walk() in try_to_unmap().

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 616aa4d..2462458 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -190,7 +190,7 @@ int page_referenced_one(struct page *, struct vm_area_struct *,
 
 int try_to_unmap(struct page *, enum ttu_flags flags);
 int try_to_unmap_one(struct page *, struct vm_area_struct *,
-			unsigned long address, enum ttu_flags flags);
+			unsigned long address, void *arg);
 
 /*
  * Called from mm/filemap_xip.c to unmap empty zero page
@@ -256,9 +256,6 @@ struct rmap_walk_control {
 	bool (*invalid_vma)(struct vm_area_struct *vma, void *arg);
 };
 
-/*
- * Called by migrate.c to remove migration ptes, but might be used more later.
- */
 int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
 
 #else	/* !CONFIG_MMU */
diff --git a/mm/ksm.c b/mm/ksm.c
index 91b8cb3..6b4baa9 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1982,7 +1982,7 @@ again:
 				continue;
 
 			ret = try_to_unmap_one(page, vma,
-					rmap_item->address, flags);
+					rmap_item->address, (void *)flags);
 			if (ret != SWAP_AGAIN || !page_mapped(page)) {
 				anon_vma_unlock_read(anon_vma);
 				goto out;
@@ -1996,7 +1996,6 @@ out:
 	return ret;
 }
 
-#ifdef CONFIG_MIGRATION
 int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct stable_node *stable_node;
@@ -2054,6 +2053,7 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_MIGRATION
 void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 {
 	struct stable_node *stable_node;
diff --git a/mm/rmap.c b/mm/rmap.c
index a292707..d34fa0e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1175,15 +1175,18 @@ out:
 /*
  * Subfunctions of try_to_unmap: try_to_unmap_one called
  * repeatedly from try_to_unmap_ksm, try_to_unmap_anon or try_to_unmap_file.
+ *
+ * @arg: enum ttu_flags will be passed to this argument
  */
 int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
-		     unsigned long address, enum ttu_flags flags)
+		     unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte;
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
+	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
@@ -1509,6 +1512,11 @@ bool is_vma_temporary_stack(struct vm_area_struct *vma)
 	return false;
 }
 
+static bool invalid_migration_vma(struct vm_area_struct *vma, void *arg)
+{
+	return is_vma_temporary_stack(vma);
+}
+
 /**
  * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
  * rmap method
@@ -1554,7 +1562,7 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 			continue;
 
 		address = vma_address(page, vma);
-		ret = try_to_unmap_one(page, vma, address, flags);
+		ret = try_to_unmap_one(page, vma, address, (void *)flags);
 		if (ret != SWAP_AGAIN || !page_mapped(page))
 			break;
 	}
@@ -1588,7 +1596,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-		ret = try_to_unmap_one(page, vma, address, flags);
+		ret = try_to_unmap_one(page, vma, address, (void *)flags);
 		if (ret != SWAP_AGAIN || !page_mapped(page))
 			goto out;
 	}
@@ -1610,6 +1618,11 @@ out:
 	return ret;
 }
 
+static int page_not_mapped(struct page *page)
+{
+	return !page_mapped(page);
+};
+
 /**
  * try_to_unmap - try to remove all page table mappings to a page
  * @page: the page to get unmapped
@@ -1627,16 +1640,29 @@ out:
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
 	int ret;
+	struct rmap_walk_control rwc = {
+		.rmap_one = try_to_unmap_one,
+		.arg = (void *)flags,
+		.done = page_not_mapped,
+		.file_nonlinear = try_to_unmap_nonlinear,
+		.anon_lock = page_lock_anon_vma_read,
+	};
 
-	BUG_ON(!PageLocked(page));
 	VM_BUG_ON(!PageHuge(page) && PageTransHuge(page));
 
-	if (unlikely(PageKsm(page)))
-		ret = try_to_unmap_ksm(page, flags);
-	else if (PageAnon(page))
-		ret = try_to_unmap_anon(page, flags);
-	else
-		ret = try_to_unmap_file(page, flags);
+	/*
+	 * During exec, a temporary VMA is setup and later moved.
+	 * The VMA is moved under the anon_vma lock but not the
+	 * page tables leading to a race where migration cannot
+	 * find the migration ptes. Rather than increasing the
+	 * locking requirements of exec(), migration skips
+	 * temporary VMAs until after exec() completes.
+	 */
+	if (flags & TTU_MIGRATION && !PageKsm(page) && PageAnon(page))
+		rwc.invalid_vma = invalid_migration_vma;
+
+	ret = rmap_walk(page, &rwc);
+
 	if (ret != SWAP_MLOCK && !page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
@@ -1679,7 +1705,6 @@ void __put_anon_vma(struct anon_vma *anon_vma)
 	anon_vma_free(anon_vma);
 }
 
-#ifdef CONFIG_MIGRATION
 static struct anon_vma *rmap_walk_anon_lock(struct page *page,
 					struct rmap_walk_control *rwc)
 {
@@ -1781,7 +1806,6 @@ int rmap_walk(struct page *page, struct rmap_walk_control *rwc)
 	else
 		return rmap_walk_file(page, rwc);
 }
-#endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_HUGETLB_PAGE
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
