Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id D82726B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 12:59:13 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1234785pbb.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:59:13 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 2/5] mm, highmem: remove useless pool_lock
Date: Thu,  1 Nov 2012 01:56:34 +0900
Message-Id: <1351702597-10795-3-git-send-email-js1304@gmail.com>
In-Reply-To: <1351702597-10795-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1351702597-10795-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Peter Zijlstra <a.p.zijlstra@chello.nl>

The pool_lock protects the page_address_pool from concurrent access.
But, access to the page_address_pool is already protected by kmap_lock.
So remove it.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

diff --git a/mm/highmem.c b/mm/highmem.c
index b3b3d68..017bad1 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -328,7 +328,6 @@ struct page_address_map {
  * page_address_map freelist, allocated from page_address_maps.
  */
 static struct list_head page_address_pool;	/* freelist */
-static spinlock_t pool_lock;			/* protects page_address_pool */
 
 /*
  * Hash table bucket
@@ -395,11 +394,9 @@ void set_page_address(struct page *page, void *virtual)
 	if (virtual) {		/* Add */
 		BUG_ON(list_empty(&page_address_pool));
 
-		spin_lock_irqsave(&pool_lock, flags);
 		pam = list_entry(page_address_pool.next,
 				struct page_address_map, list);
 		list_del(&pam->list);
-		spin_unlock_irqrestore(&pool_lock, flags);
 
 		pam->page = page;
 		pam->virtual = virtual;
@@ -413,9 +410,7 @@ void set_page_address(struct page *page, void *virtual)
 			if (pam->page == page) {
 				list_del(&pam->list);
 				spin_unlock_irqrestore(&pas->lock, flags);
-				spin_lock_irqsave(&pool_lock, flags);
 				list_add_tail(&pam->list, &page_address_pool);
-				spin_unlock_irqrestore(&pool_lock, flags);
 				goto done;
 			}
 		}
@@ -438,7 +433,6 @@ void __init page_address_init(void)
 		INIT_LIST_HEAD(&page_address_htable[i].lh);
 		spin_lock_init(&page_address_htable[i].lock);
 	}
-	spin_lock_init(&pool_lock);
 }
 
 #endif	/* defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL) */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
