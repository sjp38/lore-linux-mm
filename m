Date: Fri, 8 Jun 2007 13:53:49 +0100
Subject: [PATCH] Allow PAGE_OWNER to be set on any architecture
Message-ID: <20070608125349.GA8444@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alexn@telia.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently PAGE_OWNER depends on CONFIG_X86. This appears to be due to
pfn_to_page() being called in an inappropriate for many memory models
and the presense of memory holes. This patch ensures that pfn_valid()
and pfn_valid_within() is called at the appropriate places and the offsets
correctly updated so that PAGE_OWNER is safe on any architecture.

In situations where CONFIG_HOLES_IN_ZONES is set (IA64 with VIRTUAL_MEM_MAP),
there may be cases where pages allocated within a MAX_ORDER_NR_PAGES block
of pages may not be displayed in /proc/page_owner if the hole is at the
start of the block. Addressing this would be quite complex, perform slowly
and is of no clear benefit.

Once PAGE_OWNER is allowed on all architectures, the statistics for grouping
pages by mobility that declare how many pageblocks contain mixed page types
becomes optionally available on all arches.

This patch was tested successfully on x86, x86_64, ppc64 and IA64 machines.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---
 fs/proc/proc_misc.c |   31 ++++++++++++++++++++++++-------
 lib/Kconfig.debug   |    2 +-
 2 files changed, 25 insertions(+), 8 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-clean/fs/proc/proc_misc.c linux-2.6.22-rc4-mm2-005_pageowner_anyarch/fs/proc/proc_misc.c
--- linux-2.6.22-rc4-mm2-clean/fs/proc/proc_misc.c	2007-06-07 14:11:20.000000000 +0100
+++ linux-2.6.22-rc4-mm2-005_pageowner_anyarch/fs/proc/proc_misc.c	2007-06-08 13:34:36.000000000 +0100
@@ -756,18 +756,35 @@ read_page_owner(struct file *file, char 
 	struct page *page;
 	char *kbuf, *modname;
 	const char *symname;
-	int ret = 0, next_idx = 1;
+	int ret = 0;
 	char namebuf[128];
 	unsigned long offset = 0, symsize;
 	int i;
 	ssize_t num_written = 0;
 	int blocktype = 0, pagetype = 0;
 
+	page = NULL;
 	pfn = min_low_pfn + *ppos;
-	page = pfn_to_page(pfn);
+
+	/* Find a valid PFN or the start of a MAX_ORDER_NR_PAGES area */
+	while (!pfn_valid(pfn) && (pfn & (MAX_ORDER_NR_PAGES - 1)) != 0)
+		pfn++;
+
+	/* Find an allocated page */
 	for (; pfn < max_pfn; pfn++) {
-		if (!pfn_valid(pfn))
+		/*
+		 * If the new page is in a new MAX_ORDER_NR_PAGES area,
+		 * validate the area as existing, skip it if not
+		 */
+		if ((pfn & (MAX_ORDER_NR_PAGES - 1)) == 0 && !pfn_valid(pfn)) {
+			pfn += MAX_ORDER_NR_PAGES - 1;
 			continue;
+		}
+
+		/* Check for holes within a MAX_ORDER area */
+		if (!pfn_valid_within(pfn))
+			continue;
+
 		page = pfn_to_page(pfn);
 
 		/* Catch situations where free pages have a bad ->order  */
@@ -776,16 +793,16 @@ read_page_owner(struct file *file, char 
 				"PageOwner info inaccurate for PFN %lu\n",
 				pfn);
 
-		if (page->order >= 0)
+		/* Stop search if page is allocated and has trace info */
+		if (page->order >= 0 && page->trace[0])
 			break;
-
-		next_idx++;
 	}
 
 	if (!pfn_valid(pfn))
 		return 0;
 
-	*ppos += next_idx;
+	/* Record the next PFN to read in the file offset */
+	*ppos = (pfn - min_low_pfn) + 1;
 
 	kbuf = kmalloc(count, GFP_KERNEL);
 	if (!kbuf)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-clean/lib/Kconfig.debug linux-2.6.22-rc4-mm2-005_pageowner_anyarch/lib/Kconfig.debug
--- linux-2.6.22-rc4-mm2-clean/lib/Kconfig.debug	2007-06-07 14:11:21.000000000 +0100
+++ linux-2.6.22-rc4-mm2-005_pageowner_anyarch/lib/Kconfig.debug	2007-06-08 13:34:36.000000000 +0100
@@ -49,7 +49,7 @@ config UNUSED_SYMBOLS
 
 config PAGE_OWNER
 	bool "Track page owner"
-	depends on DEBUG_KERNEL && X86
+	depends on DEBUG_KERNEL
 	help
 	  This keeps track of what call chain is the owner of a page, may
 	  help to find bare alloc_page(s) leaks. Eats a fair amount of memory.
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
