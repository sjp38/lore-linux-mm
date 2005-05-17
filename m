Subject: [PATCH] sparsemem-ppc64-flat-first-block-is-not-special
In-Reply-To: <4280D72C.4090203@shadowen.org>
Message-Id: <E1DY1oW-0002hE-7B@pinky.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Tue, 17 May 2005 14:08:48 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: anton@samba.org, apw@shadowen.org, haveblue@us.ibm.com, jschopp@austin.ibm.com, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc64-dev@ozlabs.org, olof@lixom.net, paulus@samba.org
List-ID: <linux-mm.kvack.org>

Ok.  Testing seems to show that indeed the initial memory blocks
do not need to be treated specially on ppc64 non-numa systems.
Andrew could you add this to the sparsemem patches please.
Applies on top of 2.6.12-rc4-mm2.

-apw

Testing seems to confirm that we do not need to handle the first memory
block specially in do_init_bootmem.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diffstat sparsemem-ppc64-flat-first-block-is-not-special
---
 init.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff -upN reference/arch/ppc64/mm/init.c current/arch/ppc64/mm/init.c
--- reference/arch/ppc64/mm/init.c
+++ current/arch/ppc64/mm/init.c
@@ -538,14 +538,6 @@ void __init do_init_bootmem(void)
 	unsigned long start, bootmap_pages;
 	unsigned long total_pages = lmb_end_of_DRAM() >> PAGE_SHIFT;
 	int boot_mapsize;
-	unsigned long start_pfn, end_pfn;
-	/*
-	 * Note presence of first (logical/coalasced) LMB which will
-	 * contain RMO region
-	 */
-	start_pfn = lmb.memory.region[0].physbase >> PAGE_SHIFT;
-	end_pfn = start_pfn + (lmb.memory.region[0].size >> PAGE_SHIFT);
-	memory_present(0, start_pfn, end_pfn);
 
 	/*
 	 * Find an area to use for the bootmem bitmap.  Calculate the size of
@@ -562,18 +554,19 @@ void __init do_init_bootmem(void)
 	max_pfn = max_low_pfn;
 
 	/* Add all physical memory to the bootmem map, mark each area
-	 * present.  The first block has already been marked present above.
+	 * present.
 	 */
 	for (i=0; i < lmb.memory.cnt; i++) {
 		unsigned long physbase, size;
+		unsigned long start_pfn, end_pfn;
 
 		physbase = lmb.memory.region[i].physbase;
 		size = lmb.memory.region[i].size;
-		if (i) {
-			start_pfn = physbase >> PAGE_SHIFT;
-			end_pfn = start_pfn + (size >> PAGE_SHIFT);
-			memory_present(0, start_pfn, end_pfn);
-		}
+
+		start_pfn = physbase >> PAGE_SHIFT;
+		end_pfn = start_pfn + (size >> PAGE_SHIFT);
+		memory_present(0, start_pfn, end_pfn);
+
 		free_bootmem(physbase, size);
 	}
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
