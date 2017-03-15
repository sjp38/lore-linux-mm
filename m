Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F360F6B0397
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:25:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v190so14085413pfb.5
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:25:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n11si976053plg.52.2017.03.14.22.24.59
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 08/10] mm: make rmap_walk void function
Date: Wed, 15 Mar 2017 14:24:51 +0900
Message-ID: <1489555493-14659-9-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-1-git-send-email-minchan@kernel.org>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>

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
index e1cfda4..78b44a0 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -61,7 +61,7 @@ static inline void set_page_stable_node(struct page *page,
 struct page *ksm_might_need_to_copy(struct page *page,
 			struct vm_area_struct *vma, unsigned long address);
 
-int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
+void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 
 #else  /* !CONFIG_KSM */
@@ -94,10 +94,9 @@ static inline int page_referenced_ksm(struct page *page,
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
index 19b4f2d..6edffb9 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1933,11 +1933,10 @@ struct page *ksm_might_need_to_copy(struct page *page,
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
@@ -1950,7 +1949,7 @@ int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 
 	stable_node = page_stable_node(page);
 	if (!stable_node)
-		return ret;
+		return;
 again:
 	hlist_for_each_entry(rmap_item, &stable_node->hlist, hlist) {
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
@@ -1978,23 +1977,20 @@ int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
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
index 04d5355..987b0d2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1603,13 +1603,12 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
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
@@ -1619,7 +1618,7 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 		anon_vma = rmap_walk_anon_lock(page, rwc);
 	}
 	if (!anon_vma)
-		return ret;
+		return;
 
 	pgoff_start = page_to_pgoff(page);
 	pgoff_end = pgoff_start + hpage_nr_pages(page) - 1;
@@ -1633,8 +1632,7 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		ret = rwc->rmap_one(page, vma, address, rwc->arg);
-		if (ret != SWAP_AGAIN)
+		if (SWAP_AGAIN != rwc->rmap_one(page, vma, address, rwc->arg))
 			break;
 		if (rwc->done && rwc->done(page))
 			break;
@@ -1642,7 +1640,6 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 
 	if (!locked)
 		anon_vma_unlock_read(anon_vma);
-	return ret;
 }
 
 /*
@@ -1658,13 +1655,12 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
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
@@ -1675,7 +1671,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	if (!mapping)
-		return ret;
+		return;
 
 	pgoff_start = page_to_pgoff(page);
 	pgoff_end = pgoff_start + hpage_nr_pages(page) - 1;
@@ -1690,8 +1686,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		ret = rwc->rmap_one(page, vma, address, rwc->arg);
-		if (ret != SWAP_AGAIN)
+		if (SWAP_AGAIN != rwc->rmap_one(page, vma, address, rwc->arg))
 			goto done;
 		if (rwc->done && rwc->done(page))
 			goto done;
@@ -1700,28 +1695,27 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
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
