Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id B58C16B0068
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 16:24:32 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 04/10] migrate: clean up migrate_huge_page()
Date: Fri, 22 Mar 2013 16:23:49 -0400
Message-Id: <1363983835-20184-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

Due to the previous patch, soft_offline_huge_page() switches to use
migrate_pages(), and migrate_huge_page() is not used any more.
So let's remove it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/migrate.h |  5 -----
 mm/migrate.c            | 26 --------------------------
 2 files changed, 31 deletions(-)

diff --git v3.9-rc3.orig/include/linux/migrate.h v3.9-rc3/include/linux/migrate.h
index d4c6c08..0e05397 100644
--- v3.9-rc3.orig/include/linux/migrate.h
+++ v3.9-rc3/include/linux/migrate.h
@@ -44,8 +44,6 @@ extern int migrate_pages(struct list_head *l, new_page_t x,
 extern int migrate_movable_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private,
 		enum migrate_mode mode, int reason);
-extern int migrate_huge_page(struct page *, new_page_t x,
-		unsigned long private, enum migrate_mode mode);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -68,9 +66,6 @@ static inline int migrate_pages(struct list_head *l, new_page_t x,
 static inline int migrate_movable_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
 		enum migrate_mode mode, int reason) { return -ENOSYS; }
-static inline int migrate_huge_page(struct page *page, new_page_t x,
-		unsigned long private, enum migrate_mode mode)
-	{ return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
diff --git v3.9-rc3.orig/mm/migrate.c v3.9-rc3/mm/migrate.c
index 66030b6..38912ae 100644
--- v3.9-rc3.orig/mm/migrate.c
+++ v3.9-rc3/mm/migrate.c
@@ -1080,32 +1080,6 @@ int migrate_movable_pages(struct list_head *from, new_page_t get_new_page,
 	return err;
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
