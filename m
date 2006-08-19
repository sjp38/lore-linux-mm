Date: Fri, 18 Aug 2006 20:31:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Optimize free_one_page
Message-ID: <Pine.LNX.4.64.0608182030400.3009@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Free one_page currently adds the page to a fake list and calls 
free_page_bulk. Fee_page_bulk takes it off again and then calles 
__free_one_page.

Make free_one_page go directly to __free_one_page. Saves
list on / off and a temporary list in free_one_page for
higher ordered pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc4.orig/mm/page_alloc.c	2006-08-18 14:52:29.451028823 -0700
+++ linux-2.6.18-rc4/mm/page_alloc.c	2006-08-18 14:52:35.046386459 -0700
@@ -432,9 +432,11 @@ static void free_pages_bulk(struct zone 
 
 static void free_one_page(struct zone *zone, struct page *page, int order)
 {
-	LIST_HEAD(list);
-	list_add(&page->lru, &list);
-	free_pages_bulk(zone, 1, &list, order);
+	spin_lock(&zone->lock);
+	zone->all_unreclaimable = 0;
+	zone->pages_scanned = 0;
+	__free_one_page(page, zone ,order);
+	spin_unlock(&zone->lock);
 }
 
 static void __free_pages_ok(struct page *page, unsigned int order)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
