Date: Tue, 15 Jul 2008 04:24:07 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 7/9] fix truncate race and sevaral comments
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715042138.F704.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: mlock-mlocked-pages-are-unevictable-putback_lru_page-rework.patch
Against:  mmotm Jul 14
Applies after: mlock-mlocked-pages-are-unevictable-resutore-patch-failure-hunk.patch

Changelog
================================
  V1
    - split out from putback_lru_page rework
    - 
    - add truncate check in __clear_page_mlock().
      it merged from Lee's fix page unlocking protocol for putback_lru_page patch.

this patch is part of putback_lru_page() rework.
sevaral comment fix and one bugfix contained.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

 mm/mlock.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

Index: linux-2.6.26-rc9-mmotm-putback/mm/mlock.c
===================================================================
--- linux-2.6.26-rc9-mmotm-putback.orig/mm/mlock.c
+++ linux-2.6.26-rc9-mmotm-putback/mm/mlock.c
@@ -54,7 +54,11 @@ EXPORT_SYMBOL(can_do_mlock);
  */
 void __clear_page_mlock(struct page *page)
 {
-	VM_BUG_ON(!PageLocked(page));	/* for LRU isolate/putback */
+	VM_BUG_ON(!PageLocked(page));
+
+	if (!page->mapping) {	/* truncated ? */
+		return;
+	}
 
 	if (!isolate_lru_page(page)) {
 		putback_lru_page(page);
@@ -138,7 +142,9 @@ static int __mlock_vma_pages_range(struc
 
 		/*
 		 * get_user_pages makes pages present if we are
-		 * setting mlock.
+		 * setting mlock. and this extra reference count will
+		 * disable migration of this page.  However, page may
+		 * still be truncated out from under us.
 		 */
 		ret = get_user_pages(current, mm, addr,
 				min_t(int, nr_pages, ARRAY_SIZE(pages)),
@@ -166,11 +172,12 @@ static int __mlock_vma_pages_range(struc
 		for (i = 0; i < ret; i++) {
 			struct page *page = pages[i];
 
+			lock_page(page);
 			/*
-			 * page might be truncated or migrated out from under
-			 * us.  Check after acquiring page lock.
+			 * Because we lock page here and migration is blocked
+			 * by the elevated reference, we need only check for
+			 * page truncation (file-cache only).
 			 */
-			lock_page(page);
 			if (page->mapping)
 				mlock_vma_page(page);
 			unlock_page(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
