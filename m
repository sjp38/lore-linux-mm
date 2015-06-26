Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CDD826B0072
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 05:57:52 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so72271605pdc.3
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 02:57:52 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id vt3si49553976pbc.189.2015.06.26.02.57.47
        for <linux-mm@kvack.org>;
        Fri, 26 Jun 2015 02:57:48 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFCv2 5/5] mm: remove direct calling of migration
Date: Fri, 26 Jun 2015 18:58:30 +0900
Message-Id: <1435312710-15108-6-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1435312710-15108-1-git-send-email-gioh.kim@lge.com>
References: <1435312710-15108-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Gioh Kim <gioh.kim@lge.com>

Migration is completely generalized.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 mm/balloon_compaction.c |  8 --------
 mm/migrate.c            | 15 ---------------
 2 files changed, 23 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index df72846..a7b7c79 100644
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
index a0bc1e4..0b52fa4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -844,21 +844,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(driver_page_migratable(page))) {
-		/*
-		 * A driver page does not need any special attention from
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
