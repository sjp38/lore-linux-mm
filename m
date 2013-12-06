Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4686B0039
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 03:39:16 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so671041pbb.31
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 00:39:15 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ws5si29341624pab.209.2013.12.06.00.39.13
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 00:39:14 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/4] mm/migrate: correct return value of migrate_pages()
Date: Fri,  6 Dec 2013 17:41:47 +0900
Message-Id: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

migrate_pages() should return number of pages not migrated or error code.
When unmap_and_move return -EAGAIN, outer loop is re-execution without
initialising nr_failed. This makes nr_failed over-counted.

So this patch correct it by initialising nr_failed in outer loop.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/migrate.c b/mm/migrate.c
index 3747fcd..1f59ccc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1102,6 +1102,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 
 	for(pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
+		nr_failed = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
 			cond_resched();
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
