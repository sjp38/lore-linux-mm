Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 26A0D6B009D
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:10:21 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so22092698pbc.41
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:10:20 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id bo6si30550010pab.172.2013.12.03.16.10.18
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 16:10:19 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 2/9] mm/rmap: factor nonlinear handling out of try_to_unmap_file()
Date: Wed,  4 Dec 2013 09:12:13 +0900
Message-Id: <1386115940-21425-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

To merge all kinds of rmap traverse functions, try_to_unmap(),
try_to_munlock(), page_referenced() and page_mkclean(), we need to
extract common parts and separate out non-common parts.

Nonlinear handling is handled just in try_to_unmap_file() and other
rmap traverse functions doesn't care of it. Therfore it is better
to factor nonlinear handling out of try_to_unmap_file() in order to
merge all kinds of rmap traverse functions easily.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/rmap.c b/mm/rmap.c
index 20c1a0d..a387c44 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1422,6 +1422,79 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	return ret;
 }
 
+static int try_to_unmap_nonlinear(struct page *page,
+		struct address_space *mapping, struct vm_area_struct *vma)
+{
+	int ret = SWAP_AGAIN;
+	unsigned long cursor;
+	unsigned long max_nl_cursor = 0;
+	unsigned long max_nl_size = 0;
+	unsigned int mapcount;
+
+	list_for_each_entry(vma,
+		&mapping->i_mmap_nonlinear, shared.nonlinear) {
+
+		cursor = (unsigned long) vma->vm_private_data;
+		if (cursor > max_nl_cursor)
+			max_nl_cursor = cursor;
+		cursor = vma->vm_end - vma->vm_start;
+		if (cursor > max_nl_size)
+			max_nl_size = cursor;
+	}
+
+	if (max_nl_size == 0) {	/* all nonlinears locked or reserved ? */
+		return SWAP_FAIL;
+	}
+
+	/*
+	 * We don't try to search for this page in the nonlinear vmas,
+	 * and page_referenced wouldn't have found it anyway.  Instead
+	 * just walk the nonlinear vmas trying to age and unmap some.
+	 * The mapcount of the page we came in with is irrelevant,
+	 * but even so use it as a guide to how hard we should try?
+	 */
+	mapcount = page_mapcount(page);
+	if (!mapcount)
+		return ret;
+
+	cond_resched();
+
+	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
+	if (max_nl_cursor == 0)
+		max_nl_cursor = CLUSTER_SIZE;
+
+	do {
+		list_for_each_entry(vma,
+			&mapping->i_mmap_nonlinear, shared.nonlinear) {
+
+			cursor = (unsigned long) vma->vm_private_data;
+			while (cursor < max_nl_cursor &&
+				cursor < vma->vm_end - vma->vm_start) {
+				if (try_to_unmap_cluster(cursor, &mapcount,
+						vma, page) == SWAP_MLOCK)
+					ret = SWAP_MLOCK;
+				cursor += CLUSTER_SIZE;
+				vma->vm_private_data = (void *) cursor;
+				if ((int)mapcount <= 0)
+					return ret;
+			}
+			vma->vm_private_data = (void *) max_nl_cursor;
+		}
+		cond_resched();
+		max_nl_cursor += CLUSTER_SIZE;
+	} while (max_nl_cursor <= max_nl_size);
+
+	/*
+	 * Don't loop forever (perhaps all the remaining pages are
+	 * in locked vmas).  Reset cursor on all unreserved nonlinear
+	 * vmas, now forgetting on which ones it had fallen behind.
+	 */
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.nonlinear)
+		vma->vm_private_data = NULL;
+
+	return ret;
+}
+
 bool is_vma_temporary_stack(struct vm_area_struct *vma)
 {
 	int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);
@@ -1511,10 +1584,6 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	pgoff_t pgoff = page->index << compound_order(page);
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
-	unsigned long cursor;
-	unsigned long max_nl_cursor = 0;
-	unsigned long max_nl_size = 0;
-	unsigned int mapcount;
 
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
@@ -1535,64 +1604,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	if (TTU_ACTION(flags) == TTU_MUNLOCK)
 		goto out;
 
-	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
-							shared.nonlinear) {
-		cursor = (unsigned long) vma->vm_private_data;
-		if (cursor > max_nl_cursor)
-			max_nl_cursor = cursor;
-		cursor = vma->vm_end - vma->vm_start;
-		if (cursor > max_nl_size)
-			max_nl_size = cursor;
-	}
-
-	if (max_nl_size == 0) {	/* all nonlinears locked or reserved ? */
-		ret = SWAP_FAIL;
-		goto out;
-	}
-
-	/*
-	 * We don't try to search for this page in the nonlinear vmas,
-	 * and page_referenced wouldn't have found it anyway.  Instead
-	 * just walk the nonlinear vmas trying to age and unmap some.
-	 * The mapcount of the page we came in with is irrelevant,
-	 * but even so use it as a guide to how hard we should try?
-	 */
-	mapcount = page_mapcount(page);
-	if (!mapcount)
-		goto out;
-	cond_resched();
-
-	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
-	if (max_nl_cursor == 0)
-		max_nl_cursor = CLUSTER_SIZE;
-
-	do {
-		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
-							shared.nonlinear) {
-			cursor = (unsigned long) vma->vm_private_data;
-			while ( cursor < max_nl_cursor &&
-				cursor < vma->vm_end - vma->vm_start) {
-				if (try_to_unmap_cluster(cursor, &mapcount,
-						vma, page) == SWAP_MLOCK)
-					ret = SWAP_MLOCK;
-				cursor += CLUSTER_SIZE;
-				vma->vm_private_data = (void *) cursor;
-				if ((int)mapcount <= 0)
-					goto out;
-			}
-			vma->vm_private_data = (void *) max_nl_cursor;
-		}
-		cond_resched();
-		max_nl_cursor += CLUSTER_SIZE;
-	} while (max_nl_cursor <= max_nl_size);
-
-	/*
-	 * Don't loop forever (perhaps all the remaining pages are
-	 * in locked vmas).  Reset cursor on all unreserved nonlinear
-	 * vmas, now forgetting on which ones it had fallen behind.
-	 */
-	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.nonlinear)
-		vma->vm_private_data = NULL;
+	ret = try_to_unmap_nonlinear(page, mapping, vma);
 out:
 	mutex_unlock(&mapping->i_mmap_mutex);
 	return ret;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
