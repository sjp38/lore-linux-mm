Message-ID: <3D605D36.CEB8A088@zip.com.au>
Date: Sun, 18 Aug 2002 19:51:34 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: [patch] fix uniprocessor lockup in page reclaim
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I have a test_and_set_bit(PG_chainlock, page->flags) in page reclaim.  Which
works fine on SMP.  But on uniprocessor, we made pte_chain_unlock() a no-op,
so all pages end up with PG_chainlock set.  refill_inactive() cannot move any
pages onto  the inactive list and the machine dies.

The patch removes the test_and_set_bit optimisation in there and just uses
pte_chain_lock().  If we want that (dubious) optimisation back then let's do
it right and create pte_chain_trylock().

Patch is against recent 2.5.31+BK.  Please include for 2.5.32.


--- 2.5.31/mm/vmscan.c~pte-chain-fix	Sun Aug 18 19:38:15 2002
+++ 2.5.31-akpm/mm/vmscan.c	Sun Aug 18 19:38:37 2002
@@ -398,10 +398,7 @@ static /* inline */ void refill_inactive
 		page = list_entry(l_hold.prev, struct page, lru);
 		list_del(&page->lru);
 		if (page->pte.chain) {
-			if (test_and_set_bit(PG_chainlock, &page->flags)) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
+			pte_chain_lock(page);
 			if (page->pte.chain && page_referenced(page)) {
 				pte_chain_unlock(page);
 				list_add(&page->lru, &l_active);

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
