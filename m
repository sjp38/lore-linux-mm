Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id F292B6B0070
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 03:27:27 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so126927144pdb.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 00:27:27 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ue10si25112209pab.139.2015.06.02.00.27.23
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 00:27:24 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFC 4/4] mm: remove direct calling of migration
Date: Tue,  2 Jun 2015 16:27:44 +0900
Message-Id: <1433230065-3573-5-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
References: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mst@redhat.com, kirill@shutemov.name, minchan@kernel.org, mgorman@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.com>

Migration is completely generalized.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 mm/balloon_compaction.c |  8 --------
 mm/migrate.c            | 15 ---------------
 2 files changed, 23 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index f98a500..d29270aa 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -206,13 +206,6 @@ int balloon_page_migrate(struct address_space *mapping,
 	if (!isolated_balloon_page(page))
 		return rc;
 
-	/*
-	 * Block others from accessing the 'newpage' when we get around to
-	 * establishing additional references. We should be the only one
-	 * holding a reference to the 'newpage' at this point.
-	 */
-	BUG_ON(!trylock_page(newpage));
-
 	if (WARN_ON(!__is_movable_balloon_page(page))) {
 		dump_page(page, "not movable balloon page");
 		unlock_page(newpage);
@@ -222,7 +215,6 @@ int balloon_page_migrate(struct address_space *mapping,
 	if (balloon && balloon->migratepage)
 		rc = balloon->migratepage(balloon, newpage, page, mode);
 
-	unlock_page(newpage);
 	return rc;
 }
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 649b1cd..ca47b3e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -844,21 +844,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(driver_page_migratable(page))) {
-		/*
-		 * A migratable-page does not need any special attention from
-		 * physical to virtual reverse mapping procedures.
-		 * Skip any attempt to unmap PTEs or to remap swap cache,
-		 * in order to avoid burning cycles at rmap level, and perform
-		 * the page migration right away (proteced by page lock).
-		 */
-		rc = page->mapping->a_ops->migratepage(page->mapping,
-						       newpage,
-						       page,
-						       mode);
-		goto out_unlock;
-	}
-
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
