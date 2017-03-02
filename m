Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 091E36B038E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:38 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id t184so82027751pgt.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:38 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i191si66836pge.48.2017.03.01.22.39.33
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:37 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 09/11] mm: make rmap_walk void function
Date: Thu,  2 Mar 2017 15:39:23 +0900
Message-Id: <1488436765-32350-10-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

There is no user of return value from rmap_walk friend so this
patch makes them void function.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/ksm.h  |  5 ++---
 include/linux/rmap.h |  4 ++--
 mm/ksm.c             | 16 ++++++----------
 mm/rmap.c            | 32 +++++++++++++-------------------
 4 files changed, 23 insertions(+), 34 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 481c8c4..317ad0b 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -60,7 +60,7 @@ static inline void set_page_stable_node(struct page *page,
 struct page *ksm_might_need_to_copy(struct page *page,
 			struct vm_area_struct *vma, unsigned long address);
 
-int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
+void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 
 #else  /* !CONFIG_KSM */
@@ -93,10 +93,9 @@ static inline int page_referenced_ksm(struct page *page,
 	return 0;
 }
 
-static inline int rmap_walk_ksm(struct page *page,
+static inline void rmap_walk_ksm(struct page *page,
 			struct rmap_walk_control *rwc)
 {
-	return 0;
 }
 
 static inline void ksm_migrate_page(struct page *newpage, struct page *oldpage)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 6028c38..1d7d457c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -264,8 +264,8 @@ struct rmap_walk_control {
 	bool (*invalid_vma)(struct vm_area_struct *vma, void *arg);
 };
 
-int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
-int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc);
+void rmap_walk(struct page *page, struct rmap_walk_control *rwc);
+void rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc);
 
 #else	/* !CONFIG_MMU */
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 520e4c3..68f8820 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1931,11 +1931,10 @@ struct page *ksm_might_need_to_copy(struct page *page,
 	return new_page;
 }
 
-int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
+void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct stable_node *stable_node;
 	struct rmap_item *rmap_item;
-	int ret = SWAP_AGAIN;
 	int search_new_forks = 0;
 
 	VM_BUG_ON_PAGE(!PageKsm(page), page);
@@ -1948,7 +1947,7 @@ int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 
 	stable_node = page_stable_node(page);
 	if (!stable_node)
-		return ret;
+		return;
 again:
 	hlist_for_each_entry(rmap_item, &stable_node->hlist, hlist) {
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
@@ -1976,23 +1975,20 @@ int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 			if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 				continue;
 
-			ret = rwc->rmap_one(page, vma,
-					rmap_item->address, rwc->arg);
-			if (ret != SWAP_AGAIN) {
+			if (SWAP_AGAIN != rwc->rmap_one(page, vma,
+					rmap_item->address, rwc->arg)) {
 				anon_vma_unlock_read(anon_vma);
-				goto out;
+				return;
 			}
 			if (rwc->done && rwc->done(page)) {
 				anon_vma_unlock_read(anon_vma);
-				goto out;
+				return;
 			}
 		}
 		anon_vma_unlock_read(anon_vma);
 	}
 	if (!search_new_forks++)
 		goto again;
-out:
-	return ret;
 }
 
 #ifdef CONFIG_MIGRATION
diff --git a/mm/rmap.c b/mm/rmap.c
index 01f7832..08e4f81 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1595,13 +1595,12 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * LOCKED.
  */
-static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
+static void rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 		bool locked)
 {
 	struct anon_vma *anon_vma;
 	pgoff_t pgoff_start, pgoff_end;
 	struct anon_vma_chain *avc;
-	int ret = SWAP_AGAIN;
 
 	if (locked) {
 		anon_vma = page_anon_vma(page);
@@ -1611,7 +1610,7 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 		anon_vma = rmap_walk_anon_lock(page, rwc);
 	}
 	if (!anon_vma)
-		return ret;
+		return;
 
 	pgoff_start = page_to_pgoff(page);
 	pgoff_end = pgoff_start + hpage_nr_pages(page) - 1;
@@ -1625,8 +1624,7 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		ret = rwc->rmap_one(page, vma, address, rwc->arg);
-		if (ret != SWAP_AGAIN)
+		if (SWAP_AGAIN != rwc->rmap_one(page, vma, address, rwc->arg))
 			break;
 		if (rwc->done && rwc->done(page))
 			break;
@@ -1634,7 +1632,6 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 
 	if (!locked)
 		anon_vma_unlock_read(anon_vma);
-	return ret;
 }
 
 /*
@@ -1650,13 +1647,12 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * LOCKED.
  */
-static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
+static void rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 		bool locked)
 {
 	struct address_space *mapping = page_mapping(page);
 	pgoff_t pgoff_start, pgoff_end;
 	struct vm_area_struct *vma;
-	int ret = SWAP_AGAIN;
 
 	/*
 	 * The page lock not only makes sure that page->mapping cannot
@@ -1667,7 +1663,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	if (!mapping)
-		return ret;
+		return;
 
 	pgoff_start = page_to_pgoff(page);
 	pgoff_end = pgoff_start + hpage_nr_pages(page) - 1;
@@ -1682,8 +1678,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		ret = rwc->rmap_one(page, vma, address, rwc->arg);
-		if (ret != SWAP_AGAIN)
+		if (SWAP_AGAIN != rwc->rmap_one(page, vma, address, rwc->arg))
 			goto done;
 		if (rwc->done && rwc->done(page))
 			goto done;
@@ -1692,28 +1687,27 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 done:
 	if (!locked)
 		i_mmap_unlock_read(mapping);
-	return ret;
 }
 
-int rmap_walk(struct page *page, struct rmap_walk_control *rwc)
+void rmap_walk(struct page *page, struct rmap_walk_control *rwc)
 {
 	if (unlikely(PageKsm(page)))
-		return rmap_walk_ksm(page, rwc);
+		rmap_walk_ksm(page, rwc);
 	else if (PageAnon(page))
-		return rmap_walk_anon(page, rwc, false);
+		rmap_walk_anon(page, rwc, false);
 	else
-		return rmap_walk_file(page, rwc, false);
+		rmap_walk_file(page, rwc, false);
 }
 
 /* Like rmap_walk, but caller holds relevant rmap lock */
-int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
+void rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
 {
 	/* no ksm support for now */
 	VM_BUG_ON_PAGE(PageKsm(page), page);
 	if (PageAnon(page))
-		return rmap_walk_anon(page, rwc, true);
+		rmap_walk_anon(page, rwc, true);
 	else
-		return rmap_walk_file(page, rwc, true);
+		rmap_walk_file(page, rwc, true);
 }
 
 #ifdef CONFIG_HUGETLB_PAGE
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
