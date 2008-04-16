Message-Id: <20080416113718.946786067@skyscraper.fehenstaub.lan>
References: <20080416113629.947746497@skyscraper.fehenstaub.lan>
Date: Wed, 16 Apr 2008 13:36:30 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC][patch 1/5] mm: Revert "mm: fix boundary checking in free_bootmem_core"
Content-Disposition: inline; filename=0001-bootmem-Revert-mm-fix-boundary-checking-in-free_b.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This reverts commit 5a982cbc7b3fe6cf72266f319286f29963c71b9e.

The intention behind this patch was to make the free_bootmem()
interface more robust with regards to the specified range and to let
it operate on multiple node setups as well.

However, it made free_bootmem_core()

  1. handle bogus node/memory-range combination input by just
     returning early without informing the callsite or screaming BUG()
     as it did before
  2. round slightly out of node-range values to the node boundaries
     instead of treating them as the invalid parameters they are

This was partially done to abuse free_bootmem_core() for node
iteration in free_bootmem (just feeding it every node on the box and
let it figure out what it wants to do with it) instead of looking up
the proper node before the call to free_bootmem_core().

It also affects free_bootmem_node() which relies on
free_bootmem_core() and on its sanity checks now removed.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Yinghai Lu <yhlu.kernel@gmail.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Yasunori Goto <y-goto@jp.fujitsu.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Ingo Molnar <mingo@elte.hu>
CC: Christoph Lameter <clameter@sgi.com>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 mm/bootmem.c |   25 ++++++-------------------
 1 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 2ccea70..f6ff433 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -125,7 +125,6 @@ static int __init reserve_bootmem_core(bootmem_data_t *bdata,
 	BUG_ON(!size);
 	BUG_ON(PFN_DOWN(addr) >= bdata->node_low_pfn);
 	BUG_ON(PFN_UP(addr + size) > bdata->node_low_pfn);
-	BUG_ON(addr < bdata->node_boot_start);
 
 	sidx = PFN_DOWN(addr - bdata->node_boot_start);
 	eidx = PFN_UP(addr + size - bdata->node_boot_start);
@@ -157,31 +156,21 @@ static void __init free_bootmem_core(bootmem_data_t *bdata, unsigned long addr,
 	unsigned long sidx, eidx;
 	unsigned long i;
 
-	BUG_ON(!size);
-
-	/* out range */
-	if (addr + size < bdata->node_boot_start ||
-		PFN_DOWN(addr) > bdata->node_low_pfn)
-		return;
 	/*
 	 * round down end of usable mem, partially free pages are
 	 * considered reserved.
 	 */
+	BUG_ON(!size);
+	BUG_ON(PFN_DOWN(addr + size) > bdata->node_low_pfn);
 
-	if (addr >= bdata->node_boot_start && addr < bdata->last_success)
+	if (addr < bdata->last_success)
 		bdata->last_success = addr;
 
 	/*
-	 * Round up to index to the range.
+	 * Round up the beginning of the address.
 	 */
-	if (PFN_UP(addr) > PFN_DOWN(bdata->node_boot_start))
-		sidx = PFN_UP(addr) - PFN_DOWN(bdata->node_boot_start);
-	else
-		sidx = 0;
-
+	sidx = PFN_UP(addr) - PFN_DOWN(bdata->node_boot_start);
 	eidx = PFN_DOWN(addr + size - bdata->node_boot_start);
-	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
-		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
 
 	for (i = sidx; i < eidx; i++) {
 		if (unlikely(!test_and_clear_bit(i, bdata->node_bootmem_map)))
@@ -432,9 +421,7 @@ int __init reserve_bootmem(unsigned long addr, unsigned long size,
 
 void __init free_bootmem(unsigned long addr, unsigned long size)
 {
-	bootmem_data_t *bdata;
-	list_for_each_entry(bdata, &bdata_list, list)
-		free_bootmem_core(bdata, addr, size);
+	free_bootmem_core(NODE_DATA(0)->bdata, addr, size);
 }
 
 unsigned long __init free_all_bootmem(void)
-- 
1.5.2.2

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
