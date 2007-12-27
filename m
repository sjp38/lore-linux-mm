Message-Id: <20071227203402.147181129@sgi.com>
References: <20071227203253.297427289@sgi.com>
Date: Thu, 27 Dec 2007 12:33:01 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [08/17] Buffer heads: Support slab defrag
Content-Disposition: inline; filename=0054-Buffer-heads-Support-slab-defrag.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

Defragmentation support for buffer heads. We convert the references to
buffers to struct page references and try to remove the buffers from
those pages. If the pages are dirty then trigger writeout so that the
buffer heads can be removed later.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/buffer.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 102 insertions(+)

Index: linux-2.6.24-rc6-mm1/fs/buffer.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/buffer.c	2007-12-27 12:01:09.781396609 -0800
+++ linux-2.6.24-rc6-mm1/fs/buffer.c	2007-12-27 12:04:31.946289493 -0800
@@ -3269,6 +3269,107 @@ int bh_submit_read(struct buffer_head *b
 	return -EIO;
 }
 EXPORT_SYMBOL(bh_submit_read);
+
+/*
+ * Writeback a page to clean the dirty state
+ */
+static void trigger_write(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+	int rc;
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = 1,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
+		.nonblocking = 1,
+		.for_reclaim = 0
+	};
+
+	if (!mapping->a_ops->writepage)
+		/* No write method for the address space */
+		return;
+
+	if (!clear_page_dirty_for_io(page))
+		/* Someone else already triggered a write */
+		return;
+
+	rc = mapping->a_ops->writepage(page, &wbc);
+	if (rc < 0)
+		/* I/O Error writing */
+		return;
+
+	if (rc == AOP_WRITEPAGE_ACTIVATE)
+		unlock_page(page);
+}
+
+/*
+ * Get references on buffers.
+ *
+ * We obtain references on the page that uses the buffer. v[i] will point to
+ * the corresponding page after get_buffers() is through.
+ *
+ * We are safe from the underlying page being removed simply by doing
+ * a get_page_unless_zero. The buffer head removal may race at will.
+ * try_to_free_buffes will later take appropriate locks to remove the
+ * buffers if they are still there.
+ */
+static void *get_buffers(struct kmem_cache *s, int nr, void **v)
+{
+	struct page *page;
+	struct buffer_head *bh;
+	int i,j;
+	int n = 0;
+
+	for (i = 0; i < nr; i++) {
+		bh = v[i];
+		v[i] = NULL;
+
+		page = bh->b_page;
+
+		if (page && PagePrivate(page)) {
+			for (j = 0; j < n; j++)
+				if (page == v[j])
+					goto cont;
+		}
+
+		if (get_page_unless_zero(page))
+			v[n++] = page;
+cont:	;
+	}
+	return NULL;
+}
+
+/*
+ * Despite its name: kick_buffers operates on a list of pointers to
+ * page structs that was setup by get_buffer
+ */
+static void kick_buffers(struct kmem_cache *s, int nr, void **v,
+							void *private)
+{
+	struct page *page;
+	int i;
+
+	for (i = 0; i < nr; i++) {
+		page = v[i];
+
+		if (!page || PageWriteback(page))
+			continue;
+
+
+		if (!TestSetPageLocked(page)) {
+			if (PageDirty(page))
+				trigger_write(page);
+			else {
+				if (PagePrivate(page))
+					try_to_free_buffers(page);
+				unlock_page(page);
+			}
+		}
+		put_page(page);
+	}
+}
+
 void __init buffer_init(void)
 {
 	int nrpages;
@@ -3278,6 +3379,7 @@ void __init buffer_init(void)
 				(SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
 				SLAB_MEM_SPREAD),
 				init_buffer_head);
+	kmem_cache_setup_defrag(bh_cachep, get_buffers, kick_buffers);
 
 	/*
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
