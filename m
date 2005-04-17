From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16994.40728.397980.431164@gargle.gargle.HOWL>
Date: Sun, 17 Apr 2005 21:38:32 +0400
Subject: [PATCH]: VM 8/8 shrink_list(): set PG_reclaimed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

set PG_reclaimed bit on pages that are under writeback when shrink_list()
looks at them: these pages are at end of the inactive list, and it only makes
sense to reclaim them as soon as possible when writeout finishes.

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 mm/vmscan.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff -puN mm/vmscan.c~SetPageReclaimed-inactive-tail mm/vmscan.c
--- bk-linux/mm/vmscan.c~SetPageReclaimed-inactive-tail	2005-04-17 17:52:53.000000000 +0400
+++ bk-linux-nikita/mm/vmscan.c	2005-04-17 17:52:53.000000000 +0400
@@ -556,8 +556,11 @@ static int shrink_list(struct list_head 
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
 
-		if (PageWriteback(page))
+		if (PageWriteback(page)) {
+			if (!PageReclaim(page))
+				SetPageReclaim(page);
 			goto keep_locked;
+		}
 
 		referenced = page_referenced(page, 1, sc->priority <= 0);
 		/* In active use or really unfreeable?  Activate it. */

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
