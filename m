Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id C26ED6B0039
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 02:46:45 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so12130806pbc.19
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 23:46:45 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id ot3si25785247pac.166.2013.11.27.23.46.43
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 23:46:44 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 4/9] mm/rmap: make rmap_walk to get the rmap_walk_control argument
Date: Thu, 28 Nov 2013 16:48:41 +0900
Message-Id: <1385624926-28883-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
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
index 6dacb93..0f65686 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -235,11 +235,16 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page);
 void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
+struct rmap_walk_control {
+	int (*main)(struct page *, struct vm_area_struct *,
+					unsigned long, void *);
+	void *arg;	/* argument to main function */
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
index 175fff7..c42ec30 100644
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
+			ret = rwc->main(page, vma,
+					rmap_item->address, rwc->arg);
 			if (ret != SWAP_AGAIN) {
 				anon_vma_unlock_read(anon_vma);
 				goto out;
diff --git a/mm/migrate.c b/mm/migrate.c
index bb94004..c47425b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -198,7 +198,12 @@ out:
  */
 static void remove_migration_ptes(struct page *old, struct page *new)
 {
-	rmap_walk(new, remove_migration_pte, old);
+	struct rmap_walk_control rwc;
+
+	memset(&rwc, 0, sizeof(rwc));
+	rwc.main = remove_migration_pte;
+	rwc.arg = old;
+	rmap_walk(new, &rwc);
 }
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index 916f2ed..5933488 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1705,8 +1705,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page)
  * rmap_walk() and its helpers rmap_walk_anon() and rmap_walk_file():
  * Called by migrate.c to remove migration ptes, but might be used more later.
  */
-static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
-		struct vm_area_struct *, unsigned long, void *), void *arg)
+static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -1720,7 +1719,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
-		ret = rmap_one(page, vma, address, arg);
+		ret = rwc->main(page, vma, address, rwc->arg);
 		if (ret != SWAP_AGAIN)
 			break;
 	}
@@ -1728,8 +1727,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	return ret;
 }
 
-static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
-		struct vm_area_struct *, unsigned long, void *), void *arg)
+static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -1745,7 +1743,7 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-		ret = rmap_one(page, vma, address, arg);
+		ret = rwc->main(page, vma, address, rwc->arg);
 		if (ret != SWAP_AGAIN)
 			break;
 	}
@@ -1758,17 +1756,16 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
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
