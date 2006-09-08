Date: Fri, 8 Sep 2006 13:26:17 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/5] linear reclaim pull out unfreeable page return
Message-ID: <20060908122617.GA1284@shadowen.org>
References: <exportbomb.1157718286@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

linear reclaim pull out unfreeable page return

Both lru reclaim and linear reclaim need to return unused pages.
Pull out unfreeable page return code for later use by linear reclaim.

Added in: V1

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index afa7c03..4a72976 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -632,6 +632,32 @@ static unsigned long isolate_lru_pages(u
 }
 
 /*
+ * Put back any unfreeable pages, returning them to the appropriate
+ * lru list.
+ */
+static void return_unfreeable_pages(struct list_head *page_list,
+				struct zone *zone, struct pagevec *pvec)
+{
+	struct page *page;
+
+	while (!list_empty(page_list)) {
+		page = lru_to_page(page_list);
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		list_del(&page->lru);
+		if (PageActive(page))
+			add_page_to_active_list(zone, page);
+		else
+			add_page_to_inactive_list(zone, page);
+		if (!pagevec_add(pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+}
+
+/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
@@ -648,7 +674,6 @@ static unsigned long shrink_inactive_lis
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	do {
-		struct page *page;
 		unsigned long nr_taken;
 		unsigned long nr_scan;
 		unsigned long nr_freed;
@@ -676,24 +701,8 @@ static unsigned long shrink_inactive_lis
 			goto done;
 
 		spin_lock(&zone->lru_lock);
-		/*
-		 * Put back any unfreeable pages.
-		 */
-		while (!list_empty(&page_list)) {
-			page = lru_to_page(&page_list);
-			VM_BUG_ON(PageLRU(page));
-			SetPageLRU(page);
-			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
-			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&zone->lru_lock);
-				__pagevec_release(&pvec);
-				spin_lock_irq(&zone->lru_lock);
-			}
-		}
+
+		return_unfreeable_pages(&page_list, zone, &pvec);
   	} while (nr_scanned < max_scan);
 	spin_unlock(&zone->lru_lock);
 done:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
