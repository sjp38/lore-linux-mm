Date: Tue, 01 Jul 2008 16:01:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH -mm] split_lru: fix pagevec_move_tail() doesn't treat unevictable page 
Message-Id: <20080701155749.37F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

even under writebacking, page can move to unevictable list.
so shouldn't pagevec_move_tail() check unevictable?


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/swap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -116,7 +116,7 @@ static void pagevec_move_tail(struct pag
 			zone = pagezone;
 			spin_lock(&zone->lru_lock);
 		}
-		if (PageLRU(page) && !PageActive(page)) {
+		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 			int lru = page_is_file_cache(page);
 			list_move_tail(&page->lru, &zone->lru[lru].list);
 			pgmoved++;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
