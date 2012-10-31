Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 554106B006E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 12:59:16 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1223572pad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:59:15 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 3/5] mm, highmem: remove page_address_pool list
Date: Thu,  1 Nov 2012 01:56:35 +0900
Message-Id: <1351702597-10795-4-git-send-email-js1304@gmail.com>
In-Reply-To: <1351702597-10795-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1351702597-10795-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Peter Zijlstra <a.p.zijlstra@chello.nl>

We can find free page_address_map instance without the page_address_pool.
So remove it.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

diff --git a/mm/highmem.c b/mm/highmem.c
index 017bad1..d98b0a9 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -324,10 +324,7 @@ struct page_address_map {
 	struct list_head list;
 };
 
-/*
- * page_address_map freelist, allocated from page_address_maps.
- */
-static struct list_head page_address_pool;	/* freelist */
+static struct page_address_map page_address_maps[LAST_PKMAP];
 
 /*
  * Hash table bucket
@@ -392,12 +389,7 @@ void set_page_address(struct page *page, void *virtual)
 
 	pas = page_slot(page);
 	if (virtual) {		/* Add */
-		BUG_ON(list_empty(&page_address_pool));
-
-		pam = list_entry(page_address_pool.next,
-				struct page_address_map, list);
-		list_del(&pam->list);
-
+		pam = &page_address_maps[PKMAP_NR((unsigned long)virtual)];
 		pam->page = page;
 		pam->virtual = virtual;
 
@@ -410,7 +402,6 @@ void set_page_address(struct page *page, void *virtual)
 			if (pam->page == page) {
 				list_del(&pam->list);
 				spin_unlock_irqrestore(&pas->lock, flags);
-				list_add_tail(&pam->list, &page_address_pool);
 				goto done;
 			}
 		}
@@ -420,15 +411,10 @@ done:
 	return;
 }
 
-static struct page_address_map page_address_maps[LAST_PKMAP];
-
 void __init page_address_init(void)
 {
 	int i;
 
-	INIT_LIST_HEAD(&page_address_pool);
-	for (i = 0; i < ARRAY_SIZE(page_address_maps); i++)
-		list_add(&page_address_maps[i].list, &page_address_pool);
 	for (i = 0; i < ARRAY_SIZE(page_address_htable); i++) {
 		INIT_LIST_HEAD(&page_address_htable[i].lh);
 		spin_lock_init(&page_address_htable[i].lock);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
