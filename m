Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCD06B0254
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 18:20:32 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p63so133409wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 15:20:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dk9si16269998wjb.96.2016.01.29.15.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 15:20:31 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/3] mm: remove unnecessary uses of lock_page_memcg()
Date: Fri, 29 Jan 2016 18:19:33 -0500
Message-Id: <1454109573-29235-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

There are several users that nest lock_page_memcg() inside lock_page()
to prevent page->mem_cgroup from changing. But the page lock prevents
pages from moving between cgroups, so that is unnecessary overhead.

Remove lock_page_memcg() in contexts with locked contexts and fix the
debug code in the page stat functions to be okay with the page lock.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 12 +++++++-----
 mm/filemap.c               |  7 +------
 mm/page-writeback.c        |  2 --
 mm/truncate.c              |  3 ---
 mm/vmscan.c                |  4 ----
 5 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c355efff8148..ae7797d8bf6e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -28,6 +28,7 @@
 #include <linux/eventfd.h>
 #include <linux/mmzone.h>
 #include <linux/writeback.h>
+#include <linux/page-flags.h>
 
 struct mem_cgroup;
 struct page;
@@ -464,18 +465,19 @@ void unlock_page_memcg(struct page *page);
  * @idx: page state item to account
  * @val: number of pages (positive or negative)
  *
- * Callers must use lock_page_memcg() to prevent double accounting
- * when the page is concurrently being moved to another memcg:
+ * The @page must be locked or the caller must use lock_page_memcg()
+ * to prevent double accounting when the page is concurrently being
+ * moved to another memcg:
  *
- *   lock_page_memcg(page);
+ *   lock_page(page) or lock_page_memcg(page)
  *   if (TestClearPageState(page))
  *     mem_cgroup_update_page_stat(page, state, -1);
- *   unlock_page_memcg(page);
+ *   unlock_page(page) or unlock_page_memcg(page)
  */
 static inline void mem_cgroup_update_page_stat(struct page *page,
 				 enum mem_cgroup_stat_index idx, int val)
 {
-	VM_BUG_ON(!rcu_read_lock_held());
+	VM_BUG_ON(!(rcu_read_lock_held() || PageLocked(page)));
 
 	if (page->mem_cgroup)
 		this_cpu_add(page->mem_cgroup->stat->count[idx], val);
diff --git a/mm/filemap.c b/mm/filemap.c
index b9b1cb2ce40b..9b9f00d0099c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -176,8 +176,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 /*
  * Delete a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
- * is safe.  The caller must hold the mapping's tree_lock and
- * lock_page_memcg().
+ * is safe.  The caller must hold the mapping's tree_lock.
  */
 void __delete_from_page_cache(struct page *page, void *shadow)
 {
@@ -237,11 +236,9 @@ void delete_from_page_cache(struct page *page)
 
 	freepage = mapping->a_ops->freepage;
 
-	lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	__delete_from_page_cache(page, NULL);
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	unlock_page_memcg(page);
 
 	if (freepage)
 		freepage(page);
@@ -538,7 +535,6 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->mapping = mapping;
 		new->index = offset;
 
-		lock_page_memcg(old);
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		__delete_from_page_cache(old, NULL);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
@@ -553,7 +549,6 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		if (PageSwapBacked(new))
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		unlock_page_memcg(old);
 		mem_cgroup_migrate(old, new);
 		radix_tree_preload_end();
 		if (freepage)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d7cf2c53d125..11ff8f758631 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2700,7 +2700,6 @@ int clear_page_dirty_for_io(struct page *page)
 		 * always locked coming in here, so we get the desired
 		 * exclusion.
 		 */
-		lock_page_memcg(page);
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
@@ -2709,7 +2708,6 @@ int clear_page_dirty_for_io(struct page *page)
 			ret = 1;
 		}
 		unlocked_inode_to_wb_end(inode, locked);
-		unlock_page_memcg(page);
 		return ret;
 	}
 	return TestClearPageDirty(page);
diff --git a/mm/truncate.c b/mm/truncate.c
index 87311af936f2..7598b552ae03 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -527,7 +527,6 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	if (page_has_private(page) && !try_to_release_page(page, GFP_KERNEL))
 		return 0;
 
-	lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	if (PageDirty(page))
 		goto failed;
@@ -535,7 +534,6 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	BUG_ON(page_has_private(page));
 	__delete_from_page_cache(page, NULL);
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	unlock_page_memcg(page);
 
 	if (mapping->a_ops->freepage)
 		mapping->a_ops->freepage(page);
@@ -544,7 +542,6 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	return 1;
 failed:
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	unlock_page_memcg(page);
 	return 0;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 28e518d3c700..58e318337398 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -615,7 +615,6 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	/*
 	 * The non racy check for a busy page.
@@ -655,7 +654,6 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		unlock_page_memcg(page);
 		swapcache_free(swap);
 	} else {
 		void (*freepage)(struct page *);
@@ -683,7 +681,6 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 			shadow = workingset_eviction(mapping, page);
 		__delete_from_page_cache(page, shadow);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		unlock_page_memcg(page);
 
 		if (freepage != NULL)
 			freepage(page);
@@ -693,7 +690,6 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 
 cannot_free:
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	unlock_page_memcg(page);
 	return 0;
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
