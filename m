Subject: sparsemem ppc64 tidy flat memory comments and fix benign mempresent call
In-Reply-To: <427A59BC.1020208@shadowen.org>
Message-Id: <E1DVAVE-00012m-Pq@pinky.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Mon, 09 May 2005 16:49:04 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: anton@samba.org, apw@shadowen.org, haveblue@us.ibm.com, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc64-dev@ozlabs.org, olof@lixom.net, paulus@samba.org
List-ID: <linux-mm.kvack.org>

I was going to rediff the memory present patches, but as -mm has
picked these up already here is a simple patch to clean up this
errant comment and address a benign call to memory_present().
Applies onto the existing patches.

-apw

Tidy up the comments for the ppc64 flat memory support and fix
a currently benign double call to memory_present() for the first
memory block.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

---
 init.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff -upN reference/arch/ppc64/mm/init.c current/arch/ppc64/mm/init.c
--- reference/arch/ppc64/mm/init.c
+++ current/arch/ppc64/mm/init.c
@@ -631,18 +631,19 @@ void __init do_init_bootmem(void)
 
 	max_pfn = max_low_pfn;
 
-	/* add all physical memory to the bootmem map. Also, find the first
-	 * presence of all LMBs*/
+	/* Add all physical memory to the bootmem map, mark each area
+	 * present.  The first block has already been marked present above.
+	 */
 	for (i=0; i < lmb.memory.cnt; i++) {
 		unsigned long physbase, size;
 
 		physbase = lmb.memory.region[i].physbase;
 		size = lmb.memory.region[i].size;
-		if (i) { /* already created mappings for first LMB */
+		if (i) {
 			start_pfn = physbase >> PAGE_SHIFT;
 			end_pfn = start_pfn + (size >> PAGE_SHIFT);
+			memory_present(0, start_pfn, end_pfn);
 		}
-		memory_present(0, start_pfn, end_pfn);
 		free_bootmem(physbase, size);
 	}
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
