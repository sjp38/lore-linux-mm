Subject: [5/6] sparsemem swiss cheese numa layouts
Message-Id: <E1DTQRR-0002VV-5H@pinky.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Wed, 04 May 2005 21:25:57 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org, haveblue@us.ibm.com, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

The part of the sparsemem patch which modifies memmap_init_zone() has
recently become a problem.  It changes behavior so that there is a
call to pfn_to_page() for each individual page inside of a node's
range: node_start_pfn through node_end_pfn.  It used to simply do
this once, at the beginning of the node, but having sparsemem's
non-contiguous mem_map[]s inside of a node made it necessary to
change.

Mike Kravetz recently wrote a patch which made the NUMA code accept
some new kinds of layouts.  The system's memory was laid out like
this, with node 0's memory in two pieces: one before and one after
node 1's memory:

	Node 0: +++++     +++++
	Node 1:      +++++       

Previous behavior before Mike's patch was to assign nodes like this:

	Node 0: 00000     XXXXX
	Node 1:      11111       

Where the 'X' areas were simply thrown away.  The new behavior was
to make the pg_data_t span node 0 across all of its areas, including
areas that are really node 1's:
	               
	Node 0: 000000000000000
	Node 1:      11111       

This wastes a little bit of mem_map space, but ends up being OK, and
more fully utilizes the system's memory.  memmap_init_zone()
initializes all of the "struct page"s for  node 0, even for the
"hole", but those never get used, because there is no pfn_to_page()
that resolves to those pages.  However, only calling pfn_to_page() once,
memmap_init_zone() always uses the pages that were allocated for
node0->node_mem_map because:

	struct page *start = pfn_to_page(start_pfn);
	// effectively start = &node->node_mem_map[0]
	for (page = start; page < (start + size); page++) {
		init_page_here();...
		page++;
	}

Slow, and wasteful, but generally harmless.	

But, modify that to call pfn_to_page() for each loop iteration (like
sparsemem does):

	for (pfn = start_pfn; pfn < < (start_pfn + size); pfn++++) {
		page = pfn_to_page(pfn);
	}

And you end up trying to initialize node 1's pages too early, along
with bogus data from node 0.  This patch checks for those weird
layouts and declines to touch the pages, making the more frequent
pfn_to_page() calls OK to do.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/ppc64/Kconfig     |   12 ++++++++++++
 include/linux/mmzone.h |    6 ++++++
 mm/page_alloc.c        |    2 ++
 3 files changed, 20 insertions(+)

diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/ppc64/Kconfig current/arch/ppc64/Kconfig
--- reference/arch/ppc64/Kconfig	2005-05-04 20:54:21.000000000 +0100
+++ current/arch/ppc64/Kconfig	2005-05-04 20:54:37.000000000 +0100
@@ -211,6 +211,18 @@ config ARCH_FLATMEM_ENABLE
 
 source "mm/Kconfig"
 
+# Some NUMA nodes have memory ranges that span
+# other nodes.  Even though a pfn is valid and
+# between a node's start and end pfns, it may not
+# reside on that node.
+#
+# This is a relatively temporary hack that should
+# be able to go away when sparsemem is fully in
+# place
+config NODES_SPAN_OTHER_NODES
+	def_bool y
+	depends on NEED_MULTIPLE_NODES
+
 config NUMA
 	bool "NUMA support"
 	depends on DISCONTIGMEM
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h	2005-05-04 20:54:33.000000000 +0100
+++ current/include/linux/mmzone.h	2005-05-04 20:54:37.000000000 +0100
@@ -511,6 +511,12 @@ void sparse_init(void);
 #define sparse_init()	do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
+#ifdef CONFIG_NODES_SPAN_OTHER_NODES
+#define early_pfn_in_nid(pfn, nid)	(early_pfn_to_nid(pfn) == (nid))
+#else
+#define early_pfn_in_nid(pfn, nid)	(1)
+#endif
+
 #ifndef early_pfn_valid
 #define early_pfn_valid(pfn)	(1)
 #endif
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/mm/page_alloc.c current/mm/page_alloc.c
--- reference/mm/page_alloc.c	2005-05-04 20:54:33.000000000 +0100
+++ current/mm/page_alloc.c	2005-05-04 20:54:37.000000000 +0100
@@ -1589,6 +1589,8 @@ void __init memmap_init_zone(unsigned lo
 	for (pfn = start_pfn; pfn < end_pfn; pfn++, page++) {
 		if (!early_pfn_valid(pfn))
 			continue;
+		if (!early_pfn_in_nid(pfn, nid))
+			continue;
 		page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
 		set_page_count(page, 0);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
