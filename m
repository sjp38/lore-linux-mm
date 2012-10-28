Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id D652F6B0074
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 15:15:14 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so4135274pbb.14
        for <linux-mm@kvack.org>; Sun, 28 Oct 2012 12:15:14 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 3/5] mm, highmem: remove page_address_pool list
Date: Mon, 29 Oct 2012 04:12:54 +0900
Message-Id: <1351451576-2611-4-git-send-email-js1304@gmail.com>
In-Reply-To: <1351451576-2611-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1351451576-2611-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

We can find free page_address_map instance without the page_address_pool.
So remove it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/highmem.c b/mm/highmem.c
index 017bad1..731cf9a 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -323,11 +323,7 @@ struct page_address_map {
 	void *virtual;
 	struct list_head list;
 };
-
-/*
- * page_address_map freelist, allocated from page_address_maps.
- */
-static struct list_head page_address_pool;	/* freelist */
+static struct page_address_map page_address_maps[LAST_PKMAP];
 
 /*
  * Hash table bucket
@@ -392,12 +388,7 @@ void set_page_address(struct page *page, void *virtual)
 
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
 
@@ -410,7 +401,6 @@ void set_page_address(struct page *page, void *virtual)
 			if (pam->page == page) {
 				list_del(&pam->list);
 				spin_unlock_irqrestore(&pas->lock, flags);
-				list_add_tail(&pam->list, &page_address_pool);
 				goto done;
 			}
 		}
@@ -420,15 +410,10 @@ done:
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
