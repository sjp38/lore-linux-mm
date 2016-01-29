Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 895766B0253
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 18:20:27 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id 128so1712791wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 15:20:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id km9si2799961wjb.149.2016.01.29.15.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 15:20:26 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/3] mm: migrate: do not touch page->mem_cgroup of live pages
Date: Fri, 29 Jan 2016 18:19:31 -0500
Message-Id: <1454109573-29235-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Changing a page's memcg association complicates dealing with the page,
so we want to limit this as much as possible. Page migration e.g. does
not have to do that. Just like page cache replacement, it can forcibly
charge a replacement page, and then uncharge the old page when it gets
freed. Temporarily overcharging the cgroup by a single page is not an
issue in practice, and charging is so cheap nowadays that this is much
preferrable to the headache of messing with live pages.

The only place that still changes the page->mem_cgroup binding of live
pages is when pages move along with a task to another cgroup. But that
path isolates the page from the LRU, takes the page lock, and the move
lock (lock_page_memcg()). That means page->mem_cgroup is always stable
in callers that have the page isolated from the LRU or locked. Lighter
unlocked paths, like writeback accounting, can use lock_page_memcg().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  4 ++--
 include/linux/mm.h         |  9 ---------
 mm/filemap.c               |  2 +-
 mm/memcontrol.c            | 13 +++++++------
 mm/migrate.c               | 14 ++++++++------
 mm/shmem.c                 |  2 +-
 6 files changed, 19 insertions(+), 25 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4667bd6163a5..b246e1b1fd4b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -300,7 +300,7 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
 void mem_cgroup_uncharge(struct page *page);
 void mem_cgroup_uncharge_list(struct list_head *page_list);
 
-void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage);
+void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
@@ -580,7 +580,7 @@ static inline void mem_cgroup_uncharge_list(struct list_head *page_list)
 {
 }
 
-static inline void mem_cgroup_replace_page(struct page *old, struct page *new)
+static inline void mem_cgroup_migrate(struct page *old, struct page *new)
 {
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e38cf3f65d44..d11955f2d69c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -902,20 +902,11 @@ static inline struct mem_cgroup *page_memcg(struct page *page)
 {
 	return page->mem_cgroup;
 }
-
-static inline void set_page_memcg(struct page *page, struct mem_cgroup *memcg)
-{
-	page->mem_cgroup = memcg;
-}
 #else
 static inline struct mem_cgroup *page_memcg(struct page *page)
 {
 	return NULL;
 }
-
-static inline void set_page_memcg(struct page *page, struct mem_cgroup *memcg)
-{
-}
 #endif
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index f812976350ca..37d0ecb94061 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -558,7 +558,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		unlock_page_memcg(memcg);
-		mem_cgroup_replace_page(old, new);
+		mem_cgroup_migrate(old, new);
 		radix_tree_preload_end();
 		if (freepage)
 			freepage(old);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 864e237f32d9..64506b2eef34 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4457,7 +4457,7 @@ static int mem_cgroup_move_account(struct page *page,
 	VM_BUG_ON(compound && !PageTransHuge(page));
 
 	/*
-	 * Prevent mem_cgroup_replace_page() from looking at
+	 * Prevent mem_cgroup_migrate() from looking at
 	 * page->mem_cgroup of its source page while we change it.
 	 */
 	ret = -EBUSY;
@@ -5486,16 +5486,17 @@ void mem_cgroup_uncharge_list(struct list_head *page_list)
 }
 
 /**
- * mem_cgroup_replace_page - migrate a charge to another page
- * @oldpage: currently charged page
- * @newpage: page to transfer the charge to
+ * mem_cgroup_migrate - charge a page's replacement
+ * @oldpage: currently circulating page
+ * @newpage: replacement page
  *
- * Migrate the charge from @oldpage to @newpage.
+ * Charge @newpage as a replacement page for @oldpage. @oldpage will
+ * be uncharged upon free.
  *
  * Both pages must be locked, @newpage->mapping must be set up.
  * Either or both pages might be on the LRU already.
  */
-void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
+void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 {
 	struct mem_cgroup *memcg;
 	unsigned int nr_pages;
diff --git a/mm/migrate.c b/mm/migrate.c
index b1034f9c77e7..908a5519bbae 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -325,12 +325,13 @@ int migrate_page_move_mapping(struct address_space *mapping,
 			return -EAGAIN;
 
 		/* No turning back from here */
-		set_page_memcg(newpage, page_memcg(page));
 		newpage->index = page->index;
 		newpage->mapping = page->mapping;
 		if (PageSwapBacked(page))
 			SetPageSwapBacked(newpage);
 
+		mem_cgroup_migrate(page, newpage);
+
 		return MIGRATEPAGE_SUCCESS;
 	}
 
@@ -372,12 +373,13 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * Now we know that no one else is looking at the page:
 	 * no turning back from here.
 	 */
-	set_page_memcg(newpage, page_memcg(page));
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
 	if (PageSwapBacked(page))
 		SetPageSwapBacked(newpage);
 
+	mem_cgroup_migrate(page, newpage);
+
 	get_page(newpage);	/* add cache reference */
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
@@ -457,9 +459,11 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 		return -EAGAIN;
 	}
 
-	set_page_memcg(newpage, page_memcg(page));
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
+
+	mem_cgroup_migrate(page, newpage);
+
 	get_page(newpage);
 
 	radix_tree_replace_slot(pslot, newpage);
@@ -772,7 +776,6 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	 * page is freed; but stats require that PageAnon be left as PageAnon.
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		set_page_memcg(page, NULL);
 		if (!PageAnon(page))
 			page->mapping = NULL;
 	}
@@ -1836,8 +1839,7 @@ fail_putback:
 	}
 
 	mlock_migrate_page(new_page, page);
-	set_page_memcg(new_page, page_memcg(page));
-	set_page_memcg(page, NULL);
+	mem_cgroup_migrate(page, newpage);
 	page_remove_rmap(page, true);
 
 	spin_unlock(ptl);
diff --git a/mm/shmem.c b/mm/shmem.c
index 440e2a7e6c1c..1acfdbc4bd9e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1116,7 +1116,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 		 */
 		oldpage = newpage;
 	} else {
-		mem_cgroup_replace_page(oldpage, newpage);
+		mem_cgroup_migrate(oldpage, newpage);
 		lru_cache_add_anon(newpage);
 		*pagep = newpage;
 	}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
