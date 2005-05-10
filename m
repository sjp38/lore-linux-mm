Message-ID: <4280D72C.4090203@shadowen.org>
Date: Tue, 10 May 2005 16:45:48 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: sparsemem ppc64 tidy flat memory comments and fix benign mempresent
 call
References: <E1DVAVE-00012m-Pq@pinky.shadowen.org> <427FEC57.8060505@austin.ibm.com>
In-Reply-To: <427FEC57.8060505@austin.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------060509030101080602000401"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jschopp@austin.ibm.com
Cc: akpm@osdl.org, anton@samba.org, haveblue@us.ibm.com, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc64-dev@ozlabs.org, olof@lixom.net, paulus@samba.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060509030101080602000401
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

> Instead of moving all that around why don't we just drop the duplicate
> and the if altogether?  I tested and sent a patch back in March that
> cleaned up the non-numa case pretty well.
> 
> http://sourceforge.net/mailarchive/message.php?msg_id=11320001

Ok, Mike also expressed the feeling that it was no longer necessary to
handle the first block separatly.  I've tested the attached patch on the
machines I have to hand and it seems to boot just fine in the flat
memory modes with this applied.

Joel, Mike, Dave could you test this one on your platforms to confirm
its widly applicable, if so we can push it up to -mm.  The patch
attached applies to the patches proposed for the next -mm.  A full stack
on top of 2.6.12-rc3-mm2 can be found at the URL below (see the series
file):

http://www.shadowen.org/~apw/linux/sparsemem/sparsemem-2.6.12-rc3-mm2-V3/

Cheers.

-apw

--------------060509030101080602000401
Content-Type: text/plain;
 name="sparsemem-ppc64-flat-first-block-is-not-special"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sparsemem-ppc64-flat-first-block-is-not-special"

Testing seems to confirm that we do not need to handle the first memory
block specially in do_init_bootmem.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diffstat sparsemem-ppc64-flat-first-block-is-not-special
---

diff -upN reference/arch/ppc64/mm/init.c current/arch/ppc64/mm/init.c
--- reference/arch/ppc64/mm/init.c
+++ current/arch/ppc64/mm/init.c
@@ -612,14 +612,6 @@ void __init do_init_bootmem(void)
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
@@ -636,18 +628,19 @@ void __init do_init_bootmem(void)
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
 

--------------060509030101080602000401--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
