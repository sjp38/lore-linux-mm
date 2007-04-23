Message-Id: <20070423062130.131716294@sgi.com>
References: <20070423062107.843307112@sgi.com>
Date: Sun, 22 Apr 2007 23:21:14 -0700
From: clameter@sgi.com
Subject: [RFC 07/16] Variable Order Page Cache: Add clearing and flushing function
Content-Disposition: inline; filename=var_pc_flush_zero
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <aglitke@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>
List-ID: <linux-mm.kvack.org>

Add a flushing and clearing function for higher order pages.
These are provisional and will likely have to be optimized.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/pagemap.h |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

Index: linux-2.6.21-rc7/include/linux/pagemap.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/pagemap.h	2007-04-22 17:37:24.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/pagemap.h	2007-04-22 17:37:39.000000000 -0700
@@ -250,6 +250,31 @@ static inline void wait_on_page_writebac
 
 extern void end_page_writeback(struct page *page);
 
+/* Support for clearing higher order pages */
+static inline void clear_mapping_page(struct page *page)
+{
+	int nr_pages = base_pages(page);
+	int i;
+
+	for (i = 0; i < nr_pages; i++)
+		clear_highpage(page + i);
+}
+
+/*
+ * Support for flushing higher order pages.
+ *
+ * A bit stupid: On many platforms flushing the first page
+ * will flush any TLB starting there
+ */
+static inline void flush_mapping_page(struct page *page)
+{
+	int nr_pages = base_pages(page);
+	int i;
+
+	for (i = 0; i < nr_pages; i++)
+		flush_dcache_page(page + i);
+}
+
 /*
  * Fault a userspace page into pagetables.  Return non-zero on a fault.
  *

--
