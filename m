Date: Fri, 21 Nov 2003 18:49:16 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] Minor rmap optimizations.
Message-ID: <20031121174916.GD1341@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
while working on my mm patch for s390 I played with rmap a bit, adding
BUG statements and the like. While doing so I noticed some room for
improvement in rmap. Its minor stuff but anyway... 

The first observation is that the pte chain array doesn't have holes,
meaning that from the pte_chain_idx() of the first array every slot of
all following pte chain arrays are full. That is there can't be NULL
pointers. The "if (!pte_paddr)" check in try_to_unmap() can be removed
and if the loop in page_referenced() is started from pte_chain_idx(pc)
then the "if (!pte_paddr)" in page_referenced() can be removed as well.

The second observation is that the first pte array of a pte chain has
at least one entry. Empty pte chain arrays are always freed immediatly
after the last entry was removed. Because of that victim_i can be
calculated in a simpler way. Instead of setting victim_i to -1 and then
check in each loop iteration against -1 victim_i can just be set to
the pte_chain_idx of the first pte chain array.

blue skies,
  Martin.

diffstat:
 mm/rmap.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff -urN linux-2.6/mm/rmap.c linux-2.6-s390/mm/rmap.c
--- linux-2.6/mm/rmap.c	Sat Oct 25 20:44:44 2003
+++ linux-2.6-s390/mm/rmap.c	Fri Nov 21 16:20:25 2003
@@ -132,12 +132,10 @@
 		for (pc = page->pte.chain; pc; pc = pte_chain_next(pc)) {
 			int i;
 
-			for (i = NRPTE-1; i >= 0; i--) {
+			for (i = pte_chain_idx(pc); i < NRPTE; i++) {
 				pte_addr_t pte_paddr = pc->ptes[i];
 				pte_t *p;
 
-				if (!pte_paddr)
-					break;
 				p = rmap_ptep_map(pte_paddr);
 				if (ptep_test_and_clear_young(p))
 					referenced++;
@@ -242,7 +240,7 @@
 	} else {
 		struct pte_chain *start = page->pte.chain;
 		struct pte_chain *next;
-		int victim_i = -1;
+		int victim_i = pte_chain_idx(start);
 
 		for (pc = start; pc; pc = next) {
 			int i;
@@ -253,8 +251,6 @@
 			for (i = pte_chain_idx(pc); i < NRPTE; i++) {
 				pte_addr_t pa = pc->ptes[i];
 
-				if (victim_i == -1)
-					victim_i = i;
 				if (pa != pte_paddr)
 					continue;
 				pc->ptes[i] = start->ptes[victim_i];
@@ -386,7 +382,7 @@
 {
 	struct pte_chain *pc, *next_pc, *start;
 	int ret = SWAP_SUCCESS;
-	int victim_i = -1;
+	int victim_i;
 
 	/* This page should not be on the pageout lists. */
 	if (PageReserved(page))
@@ -407,6 +403,7 @@
 	}		
 
 	start = page->pte.chain;
+	victim_i = pte_chain_idx(start);
 	for (pc = start; pc; pc = next_pc) {
 		int i;
 
@@ -416,11 +413,6 @@
 		for (i = pte_chain_idx(pc); i < NRPTE; i++) {
 			pte_addr_t pte_paddr = pc->ptes[i];
 
-			if (!pte_paddr)
-				continue;
-			if (victim_i == -1) 
-				victim_i = i;
-
 			switch (try_to_unmap_one(page, pte_paddr)) {
 			case SWAP_SUCCESS:
 				/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
