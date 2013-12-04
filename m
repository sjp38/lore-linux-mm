Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0456B009D
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:10:22 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so21241672pdj.3
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:10:22 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id f4si24646103pbm.115.2013.12.03.16.10.19
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 16:10:21 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 4/9] mm/rmap: make rmap_walk to get the rmap_walk_control argument
Date: Wed,  4 Dec 2013 09:12:15 +0900
Message-Id: <1386115940-21425-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In each rmap traverse case, there is some difference so that we need
function pointers and arguments to them in order to handle these
difference properly.

For this purpose, struct rmap_walk_control is introduced in this patch,
and will be extended in following patch. Introducing and extending are
separate, because it clarify changes.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 45c9b6a..0eef8cb 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -76,8 +76,7 @@ struct page *ksm_might_need_to_copy(struct page *page,
 int page_referenced_ksm(struct page *page,
 			struct mem_cgroup *memcg, unsigned long *vm_flags);
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
-int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
-		  struct vm_area_struct *, unsigned long, void *), void *arg);
+int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 
 #else  /* !CONFIG_KSM */
@@ -120,8 +119,8 @@ static inline int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
 	return 0;
 }
 
-static inline int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page*,
-		struct vm_area_struct *, unsigned long, void *), void *arg)
+static inline int rmap_walk_ksm(struct page *page,
+			struct rmap_walk_control *rwc)
 {
 	return 0;
 }
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 6dacb93..6a456ce 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -235,11 +235,16 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page);
 void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
+struct rmap_walk_control {
+	void *arg;
+	int (*rmap_one)(struct page *page, struct vm_area_struct *vma,
+					unsigned long addr, void *arg);
+};
+
 /*
  * Called by migrate.c to remove migration ptes, but might be used more later.
  */
-int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
-		struct vm_area_struct *, unsigned long, void *), void *arg);
+int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
 
 #else	/* !CONFIG_MMU */
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 175fff7..c3035fe 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1997,8 +1997,7 @@ out:
 }
 
 #ifdef CONFIG_MIGRATION
-int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
-		  struct vm_area_struct *, unsigned long, void *), void *arg)
+int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct stable_node *stable_node;
 	struct rmap_item *rmap_item;
@@ -2033,7 +2032,8 @@ again:
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
 				continue;
 
-			ret = rmap_one(page, vma, rmap_item->address, arg);
+			ret = rwc->rmap_one(page, vma,
+					rmap_item->address, rwc->arg);
 			if (ret != SWAP_AGAIN) {
 				anon_vma_unlock_read(anon_vma);
 				goto out;
diff --git a/mm/migrate.c b/mm/migrate.c
index bb94004..3747fcd 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -198,7 +198,12 @@ out:
  */
 static void remove_migration_ptes(struct page *old, struct page *new)
 {
-	rmap_walk(new, remove_migration_pte, old);
+	struct rmap_walk_control rwc = {
+		.rmap_one = remove_migration_pte,
+		.arg = old,
+	};
+
+	rmap_walk(new, &rwc);
 }
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index 91c73c4..1ef74e2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1702,8 +1702,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page)
  * rmap_walk() and its helpers rmap_walk_anon() and rmap_walk_file():
  * Called by migrate.c to remove migration ptes, but might be used more later.
  */
-static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
-		struct vm_area_struct *, unsigned long, void *), void *arg)
+static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -1717,7 +1716,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
-		ret = rmap_one(page, vma, address, arg);
+		ret = rwc->rmap_one(page, vma, address, rwc->arg);
 		if (ret != SWAP_AGAIN)
 			break;
 	}
@@ -1725,8 +1724,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	return ret;
 }
 
-static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
-		struct vm_area_struct *, unsigned long, void *), void *arg)
+static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << compound_order(page);
@@ -1738,7 +1736,7 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-		ret = rmap_one(page, vma, address, arg);
+		ret = rwc->rmap_one(page, vma, address, rwc->arg);
 		if (ret != SWAP_AGAIN)
 			break;
 	}
@@ -1751,17 +1749,16 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	return ret;
 }
 
-int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
-		struct vm_area_struct *, unsigned long, void *), void *arg)
+int rmap_walk(struct page *page, struct rmap_walk_control *rwc)
 {
 	VM_BUG_ON(!PageLocked(page));
 
 	if (unlikely(PageKsm(page)))
-		return rmap_walk_ksm(page, rmap_one, arg);
+		return rmap_walk_ksm(page, rwc);
 	else if (PageAnon(page))
-		return rmap_walk_anon(page, rmap_one, arg);
+		return rmap_walk_anon(page, rwc);
 	else
-		return rmap_walk_file(page, rmap_one, arg);
+		return rmap_walk_file(page, rwc);
 }
 #endif /* CONFIG_MIGRATION */
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
