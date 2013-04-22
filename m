Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 6AEEF6B0032
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 04:25:02 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm, highmem: remove useless virtual variable in page_address_map
Date: Mon, 22 Apr 2013 17:26:28 +0900
Message-Id: <1366619188-28087-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can get virtual address without virtual field.
So remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/highmem.c b/mm/highmem.c
index b32b70c..8f4c250 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -320,7 +320,6 @@ EXPORT_SYMBOL(kunmap_high);
  */
 struct page_address_map {
 	struct page *page;
-	void *virtual;
 	struct list_head list;
 };
 
@@ -362,7 +361,10 @@ void *page_address(const struct page *page)
 
 		list_for_each_entry(pam, &pas->lh, list) {
 			if (pam->page == page) {
-				ret = pam->virtual;
+				int nr;
+
+				nr = pam - page_address_map;
+				ret = PKMAP_ADDR(nr);
 				goto done;
 			}
 		}
@@ -391,7 +393,6 @@ void set_page_address(struct page *page, void *virtual)
 	if (virtual) {		/* Add */
 		pam = &page_address_maps[PKMAP_NR((unsigned long)virtual)];
 		pam->page = page;
-		pam->virtual = virtual;
 
 		spin_lock_irqsave(&pas->lock, flags);
 		list_add_tail(&pam->list, &pas->lh);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
