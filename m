Subject: [PATCH] 2.4.0-test10-pre6  TLB flush race in establish_pte
Message-ID: <OFB4731A18.0D8D8BC1-ON85256988.0074562B@raleigh.ibm.com>
From: "Steve Pratt/Austin/IBM" <slpratt@us.ibm.com>
Date: Mon, 30 Oct 2000 15:31:22 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Back in April there were discussions about the race in establish_pte with
the flush_tlb before the set_pte.  Many options were discussed, but due in
part to a concern about S/390 having introduced the code, no patch ever
appeared.  I talked with Martin Schwidefsky of the S/390 Linux development
team and he said that:

>the establish_pte was in fact introduced because of Linux/390. We wanted
to use the special S/390 instruction ipte (invalidate page >table entry).
In the meantime we found out that we need a lot more changes to be able to
use this instruction, so we disabled it again. >Until we have a proper
patch you should revoke the establish_pte change if you found it to be
faulty. I too think there is a race >condition.

So while there may be a more elegant solution down the road, I would like
to see the simple fix put back into 2.4.  Here is the patch to essential
put the code back to the way it was before the S/390 merge.  Patch is
against 2.4.0-test10pre6.

--- linux/mm/memory.c    Fri Oct 27 15:26:14 2000
+++ linux-2.4.0-test10patch/mm/memory.c  Fri Oct 27 15:45:54 2000
@@ -781,8 +781,8 @@
  */
 static inline void establish_pte(struct vm_area_struct * vma, unsigned long address, pte_t *page_table, pte_t entry)
 {
-    flush_tlb_page(vma, address);
     set_pte(page_table, entry);
+    flush_tlb_page(vma, address);
     update_mmu_cache(vma, address, entry);
 }




Linux Technology Center - IBM Corporation
11400 Burnet Road
Austin, TX  78758
(512) 838-9763  EMAIL: SLPratt@US.IBM.COM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
