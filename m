From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 13/23] Buffer heads: Support slab defrag
Date: Tue, 06 Nov 2007 17:11:43 -0800
Message-ID: <20071107011229.669024609@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757531AbXKGBRA@vger.kernel.org>
Content-Disposition: inline; filename=0016-slab_defrag_buffer_head.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Defragmentation support for buffer heads. We convert the references to
buffers to struct page references and try to remove the buffers from
those pages. If the pages are dirty then trigger writeout so that the
buffer heads can be removed later.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/buffer.c |  103 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 102 insertions(+), 1 deletion(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-11-06 12:56:07.000000000 -0800
+++ linux-2.6/fs/buffer.c	2007-11-06 12:56:11.000000000 -0800
@@ -3213,7 +3213,7 @@ static int buffer_cpu_notify(struct noti
 }
 
 static void
-init_buffer_head(void *data, struct kmem_cache *cachep, unsigned long flags)
+init_buffer_head(struct kmem_cache *cachep, void *data)
 {
 	struct buffer_head * bh = (struct buffer_head *)data;
 
@@ -3221,6 +3221,106 @@ init_buffer_head(void *data, struct kmem
 	INIT_LIST_HEAD(&bh->b_assoc_buffers);
 }
 
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
@@ -3230,6 +3330,7 @@ void __init buffer_init(void)
 				(SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
 				SLAB_MEM_SPREAD),
 				init_buffer_head);
+	kmem_cache_setup_defrag(bh_cachep, get_buffers, kick_buffers);
 
 	/*
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL

-- 
