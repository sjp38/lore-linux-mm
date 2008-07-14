Date: Tue, 15 Jul 2008 04:10:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 2/9] kill unnecessary lock_page() in vmscan.c
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715040923.F6F5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: unevictable-lru-infrastructure-kill-unnecessary-lock_page.patch
Against: mmotm Jul 14
Applies after: unevictable-lru-infrastructure-putback_lru_page-rework.patch


Old version putback_lru_page need() page lock held.
but current one doesn't.

So, several lock_page() can be removeed.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/vmscan.c |   20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -560,22 +560,6 @@ void putback_lru_page(struct page *page)
 
 
 /*
- * Cull page that shrink_*_list() has detected to be unevictable
- * under page lock to close races with other tasks that might be making
- * the page evictable.  Avoid stranding an evictable page on the
- * unevictable list.
- */
-static void cull_unevictable_page(struct page *page)
-{
-	get_page(page);
-	lock_page(page);
-	putback_lru_page(page);
-	unlock_page(page);
-	put_page(page);
-}
-
-
-/*
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
@@ -1148,7 +1132,7 @@ static unsigned long shrink_inactive_lis
 			list_del(&page->lru);
 			if (unlikely(!page_evictable(page, NULL))) {
 				spin_unlock_irq(&zone->lru_lock);
-				cull_unevictable_page(page);
+				putback_lru_page(page);
 				spin_lock_irq(&zone->lru_lock);
 				continue;
 			}
@@ -1252,7 +1236,7 @@ static void shrink_active_list(unsigned 
 		list_del(&page->lru);
 
 		if (unlikely(!page_evictable(page, NULL))) {
-			cull_unevictable_page(page);
+			putback_lru_page(page);
 			continue;
 		}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
