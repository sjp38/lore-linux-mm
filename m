Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id j0BIOCug193694
	for <linux-mm@kvack.org>; Tue, 11 Jan 2005 18:24:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0BIP5mZ173118
	for <linux-mm@kvack.org>; Tue, 11 Jan 2005 19:25:05 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.12.11) with ESMTP id j0BIOB6u024409
	for <linux-mm@kvack.org>; Tue, 11 Jan 2005 19:24:11 +0100
Date: Tue, 11 Jan 2005 19:24:11 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] Fix index calculations in clear_page_range.
Message-ID: <20050111182411.GA6055@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

[PATCH] Fix index calculations in clear_page_range.

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

pgd_index(end + PGDIR_SIZE - 1) returns 0 if end + PGDIR_SIZE - 1
is beyond the end of the address space.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

diffstat:
 mm/memory.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -urN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2005-01-11 19:10:54.000000000 +0100
+++ linux-2.6-patched/mm/memory.c	2005-01-11 19:11:01.000000000 +0100
@@ -190,10 +190,10 @@
 void clear_page_range(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
 	unsigned long addr = start, next;
-	unsigned long i, nr = pgd_index(end + PGDIR_SIZE-1) - pgd_index(start);
 	pgd_t * pgd = pgd_offset(tlb->mm, start);
+	unsigned long i;
 
-	for (i = 0; i < nr; i++) {
+	for (i = pgd_index(start); i <= pgd_index(end-1); i++) {
 		next = (addr + PGDIR_SIZE) & PGDIR_MASK;
 		if (next > end || next <= addr)
 			next = end;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
