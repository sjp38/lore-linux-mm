From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 30 Jul 2008 16:06:24 -0400
Message-Id: <20080730200624.24272.7234.sendpatchset@lts-notebook>
In-Reply-To: <20080730200618.24272.31756.sendpatchset@lts-notebook>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
Subject: [PATCH 1/7] unevictable lru:  Remember page's active state
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Fix to unevictable-lru-infrastructure.patch

Not sure this is absolutely required, but:

Preserve page's incoming active flag across retries in
putback_lru_page().


Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/vmscan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.27-rc1-mmotm-30jul/mm/vmscan.c
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/vmscan.c	2008-07-30 12:57:31.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/vmscan.c	2008-07-30 12:58:41.000000000 -0400
@@ -483,12 +483,12 @@ int remove_mapping(struct address_space 
 void putback_lru_page(struct page *page)
 {
 	int lru;
+	int active = !!TestClearPageActive(page);
 	int was_unevictable = PageUnevictable(page);
 
 	VM_BUG_ON(PageLRU(page));
 
 redo:
-	lru = !!TestClearPageActive(page);
 	ClearPageUnevictable(page);
 
 	if (page_evictable(page, NULL)) {
@@ -498,7 +498,7 @@ redo:
 		 * unevictable page on [in]active list.
 		 * We know how to handle that.
 		 */
-		lru += page_is_file_cache(page);
+		lru = active + page_is_file_cache(page);
 		lru_cache_add_lru(page, lru);
 	} else {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
