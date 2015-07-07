Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2EA9003C7
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 00:35:00 -0400 (EDT)
Received: by pddu5 with SMTP id u5so30613678pdd.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 21:35:00 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id dv10si32446148pdb.202.2015.07.06.21.34.56
        for <linux-mm@kvack.org>;
        Mon, 06 Jul 2015 21:34:57 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFCv3 5/5] mm: remove direct calling of migration
Date: Tue,  7 Jul 2015 13:36:25 +0900
Message-Id: <1436243785-24105-6-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: gunho.lee@lge.com, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>, Gioh Kim <gioh.kim@lge.com>

From: Gioh Kim <gurugio@hanmail.net>

Migration is completely generalized so that migrating mobile page
is processed with lru-pages in move_to_new_page.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 mm/balloon_compaction.c |  8 --------
 mm/migrate.c            | 13 -------------
 2 files changed, 21 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 0dd0b0d..9d07ed9 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -170,13 +170,6 @@ int balloon_page_migrate(struct address_space *mapping,
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
@@ -186,7 +179,6 @@ int balloon_page_migrate(struct address_space *mapping,
 	if (balloon && balloon->migratepage)
 		rc = balloon->migratepage(balloon, newpage, page, mode);
 
-	unlock_page(newpage);
 	return rc;
 }
 
diff --git a/mm/migrate.c b/mm/migrate.c
index e22be67..b82539b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -844,19 +844,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(mobile_page(page))) {
-		/*
-		 * A mobile page does not need any special attention from
-		 * physical to virtual reverse mapping procedures.
-		 * Skip any attempt to unmap PTEs or to remap swap cache,
-		 * in order to avoid burning cycles at rmap level, and perform
-		 * the page migration right away (proteced by page lock).
-		 */
-		rc = page->mapping->a_ops->migratepage(page->mapping,
-						       newpage, page, mode);
-		goto out_unlock;
-	}
-
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
