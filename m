Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id F3F7F6B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 03:51:09 -0400 (EDT)
Received: by labbc20 with SMTP id bc20so16038756lab.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:09 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id iz3si7034245lbc.174.2015.06.15.00.51.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 00:51:08 -0700 (PDT)
Received: by lbbqq2 with SMTP id qq2so48121935lbb.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:07 -0700 (PDT)
Subject: [PATCH RFC v0 2/6] mm/migrate: move putback of old page out of
 unmap_and_move
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 15 Jun 2015 10:51:03 +0300
Message-ID: <20150615075103.18112.98625.stgit@zurg>
In-Reply-To: <20150615073926.18112.59207.stgit@zurg>
References: <20150615073926.18112.59207.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This is preparation for migrating non-isolated pages.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 mm/migrate.c |   34 ++++++++++++++--------------------
 1 file changed, 14 insertions(+), 20 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f53838f..eca80b3 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -939,19 +939,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	rc = __unmap_and_move(page, newpage, force, mode);
 
 out:
-	if (rc != -EAGAIN) {
-		/*
-		 * A page that has been migrated has all references
-		 * removed and will be freed. A page that has not been
-		 * migrated will have kepts its references and be
-		 * restored.
-		 */
-		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
-		putback_lru_page(page);
-	}
-
 	/*
 	 * If migration was not successful and there's a freeing callback, use
 	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
@@ -1011,10 +998,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	 * tables or check whether the hugepage is pmd-based or not before
 	 * kicking migration.
 	 */
-	if (!hugepage_migration_supported(page_hstate(hpage))) {
-		putback_active_hugepage(hpage);
+	if (!hugepage_migration_supported(page_hstate(hpage)))
 		return -ENOSYS;
-	}
 
 	new_hpage = get_new_page(hpage, private, &result);
 	if (!new_hpage)
@@ -1051,9 +1036,6 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 
 	unlock_page(hpage);
 out:
-	if (rc != -EAGAIN)
-		putback_active_hugepage(hpage);
-
 	/*
 	 * If migration was not successful and there's a freeing callback, use
 	 * it.  Otherwise, put_page() will drop the reference grabbed during
@@ -1129,7 +1111,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				goto out;
 			case -EAGAIN:
 				retry++;
-				break;
+				/* Keep that page for next pass */
+				continue;
 			case MIGRATEPAGE_SUCCESS:
 				nr_succeeded++;
 				break;
@@ -1143,6 +1126,17 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				nr_failed++;
 				break;
 			}
+
+			/* Putback migrated or permanently failed page. */
+			if (PageHuge(page)) {
+				putback_active_hugepage(page);
+			} else {
+				list_del(&page->lru);
+				if (unlikely(isolated_balloon_page(page)))
+					balloon_page_putback(page);
+				else
+					putback_lru_page(page);
+			}
 		}
 	}
 	rc = nr_failed + retry;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
