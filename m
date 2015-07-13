Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9DE6B0254
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 04:35:22 -0400 (EDT)
Received: by pacan13 with SMTP id an13so12235833pac.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 01:35:21 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id dk4si26492913pbb.219.2015.07.13.01.35.19
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 01:35:21 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [PATCH 4/4] mm: remove direct calling of migration
Date: Mon, 13 Jul 2015 17:35:19 +0900
Message-Id: <1436776519-17337-5-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1436776519-17337-1-git-send-email-gioh.kim@lge.com>
References: <1436776519-17337-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: dri-devel@lists.freedesktop.org, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>, Gioh Kim <gioh.kim@lge.com>

From: Gioh Kim <gurugio@hanmail.net>

Migration is completely generalized so that migrating mobile page
is processed with lru-pages in move_to_new_page.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
---
 mm/migrate.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 53f0081d..e6644ac 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -844,21 +844,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
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
-		lock_page(newpage);
-		rc = page->mapping->a_ops->migratepage(page->mapping,
-						       newpage, page, mode);
-		unlock_page(newpage);
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
