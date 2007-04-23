From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070423064921.5458.44650.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 07/16] Variable Order Page Cache: Add clearing and flushing function
Date: Sun, 22 Apr 2007 23:49:21 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, Adam Litke <aglitke@gmail.com>, Christoph Lameter <clameter@sgi.com>, Avi Kivity <avi@argo.co.il>, Mel Gorman <mel@skynet.ie>, Dave Hansen <hansendc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Variable Order Page Cache: Add clearing and flushing function

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
