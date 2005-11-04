From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] powerpc: mem_init crash for sparsemem
Date: Fri, 4 Nov 2005 16:31:16 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511041631.17237.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc64-dev@ozlabs.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a Cell blade with some broken memory in the middle of the
physical address space and this is correctly detected by the
firmware, but not relocated. When I enable CONFIG_SPARSEMEM,
the memsections for the nonexistant address space do not
get struct page entries allocated, as expected.

However, mem_init for the non-NUMA configuration tries to
access these pages without first looking if they are there.
I'm currently using the hack below to work around that, but
I have the feeling that there should be a cleaner solution
for this.

Please comment.

Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

--- linux-2.6.15-rc.orig/arch/powerpc/mm/mem.c
+++ linux-2.6.15-rc/arch/powerpc/mm/mem.c
@@ -348,6 +348,9 @@ void __init mem_init(void)
 #endif
 	for_each_pgdat(pgdat) {
 		for (i = 0; i < pgdat->node_spanned_pages; i++) {
+			if (!section_has_mem_map(__pfn_to_section
+					(pgdat->node_start_pfn + i)))
+				continue;
 			page = pgdat_page_nr(pgdat, i);
 			if (PageReserved(page))
 				reservedpages++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
