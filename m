Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 7E23D6B0034
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 00:55:43 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/8] soft-offline: use migrate_pages() instead of migrate_huge_page()
Date: Thu, 25 Jul 2013 00:54:57 -0400
Message-Id: <1374728103-17468-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently migrate_huge_page() takes a pointer to a hugepage to be
migrated as an argument, instead of taking a pointer to the list of
hugepages to be migrated. This behavior was introduced in commit
189ebff28 ("hugetlb: simplify migrate_huge_page()"), and was OK
because until now hugepage migration is enabled only for soft-offlining
which migrates only one hugepage in a single call.

But the situation will change in the later patches in this series
which enable other users of page migration to support hugepage migration.
They can kick migration for both of normal pages and hugepages
in a single call, so we need to go back to original implementation
which uses linked lists to collect the hugepages to be migrated.

With this patch, soft_offline_huge_page() switches to use migrate_pages(),
and migrate_huge_page() is not used any more. So let's remove it.

ChangeLog v3:
 - Merged with another cleanup patch (4/10 in previous version)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/migrate.h |  5 -----
 mm/memory-failure.c     | 15 ++++++++++++---
 mm/migrate.c            | 28 ++--------------------------
 3 files changed, 14 insertions(+), 34 deletions(-)

diff --git v3.11-rc1.orig/include/linux/migrate.h v3.11-rc1/include/linux/migrate.h
index a405d3dc..6fe5214 100644
--- v3.11-rc1.orig/include/linux/migrate.h
+++ v3.11-rc1/include/linux/migrate.h
@@ -41,8 +41,6 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, enum migrate_mode mode, int reason);
-extern int migrate_huge_page(struct page *, new_page_t x,
-		unsigned long private, enum migrate_mode mode);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -62,9 +60,6 @@ static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, enum migrate_mode mode, int reason)
 	{ return -ENOSYS; }
-static inline int migrate_huge_page(struct page *page, new_page_t x,
-		unsigned long private, enum migrate_mode mode)
-	{ return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
diff --git v3.11-rc1.orig/mm/memory-failure.c v3.11-rc1/mm/memory-failure.c
index 2c13aa7..af6f61c 100644
--- v3.11-rc1.orig/mm/memory-failure.c
+++ v3.11-rc1/mm/memory-failure.c
@@ -1467,6 +1467,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
 	struct page *hpage = compound_head(page);
+	LIST_HEAD(pagelist);
 
 	/*
 	 * This double-check of PageHWPoison is to avoid the race with
@@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	unlock_page(hpage);
 
 	/* Keep page count to indicate a given hugepage is isolated. */
-	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
-				MIGRATE_SYNC);
-	put_page(hpage);
+	list_move(&hpage->lru, &pagelist);
+	ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
+				MIGRATE_SYNC, MR_MEMORY_FAILURE);
 	if (ret) {
 		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 			pfn, ret, page->flags);
+		/*
+		 * We know that soft_offline_huge_page() tries to migrate
+		 * only one hugepage pointed to by hpage, so we need not
+		 * run through the pagelist here.
+		 */
+		putback_active_hugepage(hpage);
+		if (ret > 0)
+			ret = -EIO;
 	} else {
 		set_page_hwpoison_huge_page(hpage);
 		dequeue_hwpoisoned_huge_page(hpage);
diff --git v3.11-rc1.orig/mm/migrate.c v3.11-rc1/mm/migrate.c
index b44a067..3ec47d3 100644
--- v3.11-rc1.orig/mm/migrate.c
+++ v3.11-rc1/mm/migrate.c
@@ -979,6 +979,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 
 	unlock_page(hpage);
 out:
+	if (rc != -EAGAIN)
+		putback_active_hugepage(hpage);
 	put_page(new_hpage);
 	if (result) {
 		if (rc)
@@ -1066,32 +1068,6 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	return rc;
 }
 
-int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
-		      unsigned long private, enum migrate_mode mode)
-{
-	int pass, rc;
-
-	for (pass = 0; pass < 10; pass++) {
-		rc = unmap_and_move_huge_page(get_new_page, private,
-						hpage, pass > 2, mode);
-		switch (rc) {
-		case -ENOMEM:
-			goto out;
-		case -EAGAIN:
-			/* try again */
-			cond_resched();
-			break;
-		case MIGRATEPAGE_SUCCESS:
-			goto out;
-		default:
-			rc = -EIO;
-			goto out;
-		}
-	}
-out:
-	return rc;
-}
-
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
