Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9DE6B00A0
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:10:23 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so22082201pbc.24
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:10:22 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id bo6si30550010pab.172.2013.12.03.16.10.20
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 16:10:21 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 5/9] mm/rmap: extend rmap_walk_xxx() to cope with different cases
Date: Wed,  4 Dec 2013 09:12:16 +0900
Message-Id: <1386115940-21425-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There are a lot of common parts in traversing functions, but there are
also a little of uncommon parts in it. By assigning proper function
pointer on each rmap_walker_control, we can handle these difference
correctly.

Following are differences we should handle.

1. difference of lock function in anon mapping case
2. nonlinear handling in file mapping case
3. prechecked condition:
	checking memcg in page_referenced(),
	checking VM_SHARE in page_mkclean()
	checking temporary vma in try_to_unmap()
4. exit condition:
	checking page_mapped() in try_to_unmap()

So, in this patch, I introduce 4 function pointers to
handle above differences.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 6a456ce..616aa4d 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -235,10 +235,25 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page);
 void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
+/*
+ * rmap_walk_control: To control rmap traversing for specific needs
+ *
+ * arg: passed to rmap_one() and invalid_vma()
+ * rmap_one: executed on each vma where page is mapped
+ * done: for checking traversing termination condition
+ * file_nonlinear: for handling file nonlinear mapping
+ * anon_lock: for getting anon_lock by optimized way rather than default
+ * invalid_vma: for skipping uninterested vma
+ */
 struct rmap_walk_control {
 	void *arg;
 	int (*rmap_one)(struct page *page, struct vm_area_struct *vma,
 					unsigned long addr, void *arg);
+	int (*done)(struct page *page);
+	int (*file_nonlinear)(struct page *, struct address_space *,
+					struct vm_area_struct *vma);
+	struct anon_vma *(*anon_lock)(struct page *page);
+	bool (*invalid_vma)(struct vm_area_struct *vma, void *arg);
 };
 
 /*
diff --git a/mm/ksm.c b/mm/ksm.c
index c3035fe..91b8cb3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2032,12 +2032,19 @@ again:
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
 				continue;
 
+			if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
+				continue;
+
 			ret = rwc->rmap_one(page, vma,
 					rmap_item->address, rwc->arg);
 			if (ret != SWAP_AGAIN) {
 				anon_vma_unlock_read(anon_vma);
 				goto out;
 			}
+			if (rwc->done && rwc->done(page)) {
+				anon_vma_unlock_read(anon_vma);
+				goto out;
+			}
 		}
 		anon_vma_unlock_read(anon_vma);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index 1ef74e2..a292707 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1680,10 +1680,14 @@ void __put_anon_vma(struct anon_vma *anon_vma)
 }
 
 #ifdef CONFIG_MIGRATION
-static struct anon_vma *rmap_walk_anon_lock(struct page *page)
+static struct anon_vma *rmap_walk_anon_lock(struct page *page,
+					struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
 
+	if (rwc->anon_lock)
+		return rwc->anon_lock(page);
+
 	/*
 	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma_read()
 	 * because that depends on page_mapped(); but not all its usages
@@ -1709,16 +1713,22 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = rmap_walk_anon_lock(page);
+	anon_vma = rmap_walk_anon_lock(page, rwc);
 	if (!anon_vma)
 		return ret;
 
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
+
+		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
+			continue;
+
 		ret = rwc->rmap_one(page, vma, address, rwc->arg);
 		if (ret != SWAP_AGAIN)
 			break;
+		if (rwc->done && rwc->done(page))
+			break;
 	}
 	anon_vma_unlock_read(anon_vma);
 	return ret;
@@ -1736,15 +1746,26 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
+
+		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
+			continue;
+
 		ret = rwc->rmap_one(page, vma, address, rwc->arg);
 		if (ret != SWAP_AGAIN)
-			break;
+			goto done;
+		if (rwc->done && rwc->done(page))
+			goto done;
 	}
-	/*
-	 * No nonlinear handling: being always shared, nonlinear vmas
-	 * never contain migration ptes.  Decide what to do about this
-	 * limitation to linear when we need rmap_walk() on nonlinear.
-	 */
+
+	if (!rwc->file_nonlinear)
+		goto done;
+
+	if (list_empty(&mapping->i_mmap_nonlinear))
+		goto done;
+
+	ret = rwc->file_nonlinear(page, mapping, vma);
+
+done:
 	mutex_unlock(&mapping->i_mmap_mutex);
 	return ret;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
