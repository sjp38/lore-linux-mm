From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 30 Jul 2008 16:06:30 -0400
Message-Id: <20080730200630.24272.33226.sendpatchset@lts-notebook>
In-Reply-To: <20080730200618.24272.31756.sendpatchset@lts-notebook>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
Subject: [PATCH 2/7] unevictable lru:  defer vm event counting
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Fix to unevictable-lru-infrastructure.patch

NORECL_* events are not defined this early in the series.
Remove the event counting from this patch and add in with
unevictable lru statistics [subsequent patch].

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/vmscan.c |    6 ------
 1 file changed, 6 deletions(-)

Index: linux-2.6.27-rc1-mmotm-30jul/mm/vmscan.c
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/vmscan.c	2008-07-30 12:58:41.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/vmscan.c	2008-07-30 12:59:58.000000000 -0400
@@ -484,7 +484,6 @@ void putback_lru_page(struct page *page)
 {
 	int lru;
 	int active = !!TestClearPageActive(page);
-	int was_unevictable = PageUnevictable(page);
 
 	VM_BUG_ON(PageLRU(page));
 
@@ -526,11 +525,6 @@ redo:
 		 */
 	}
 
-	if (was_unevictable && lru != LRU_UNEVICTABLE)
-		count_vm_event(NORECL_PGRESCUED);
-	else if (!was_unevictable && lru == LRU_UNEVICTABLE)
-		count_vm_event(NORECL_PGCULLED);
-
 	put_page(page);		/* drop ref from isolate */
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
