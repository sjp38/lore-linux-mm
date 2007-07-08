From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 07/12] Slab defragmentation: Support for buffer_head defrag
Date: Sat, 07 Jul 2007 20:05:45 -0700
Message-ID: <20070708030845.032023558@sgi.com>
References: <20070708030538.729027694@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756393AbXGHDL3@vger.kernel.org>
Content-Disposition: inline; filename=slub_defrag_buffer_heads
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-Id: linux-mm.kvack.org

Limited defragmentation support for buffer heads. Simply try to free the
buffers in a sparsely populated slab page.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/buffer.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 65 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc6-mm1/fs/buffer.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/fs/buffer.c	2007-07-04 11:14:01.000000000 -0700
+++ linux-2.6.22-rc6-mm1/fs/buffer.c	2007-07-04 17:23:02.000000000 -0700
@@ -3078,12 +3078,75 @@ static int buffer_cpu_notify(struct noti
 	return NOTIFY_OK;
 }
 
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
+ *
+ * TODO: Write out dirty buffers to increase the chance of kick_buffers
+ * to be successful.
+ */
+static void *get_buffers(struct kmem_cache *s, int nr, void **v)
+{
+	struct page *page;
+	struct buffer_head *bh;
+	int i;
+
+	for (i = 0; i < nr; i++) {
+		bh = v[i];
+		page = bh->b_page;
+		if (page && PagePrivate(page) && get_page_unless_zero(page))
+			v[i] = page;
+		else
+			v[i] = NULL;
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
+		if (!page)
+			continue;
+
+		if (!TestSetPageLocked(page)) {
+			if (PagePrivate(page))
+				try_to_free_buffers(page);
+			unlock_page(page);
+		}
+		put_page(page);
+	}
+}
+
+static struct kmem_cache_ops buffer_head_kmem_cache_ops = {
+	.get = get_buffers,
+	.kick = kick_buffers,
+};
+
+
 void __init buffer_init(void)
 {
 	int nrpages;
 
-	bh_cachep = KMEM_CACHE(buffer_head,
-			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
+	bh_cachep = KMEM_CACHE_OPS(buffer_head,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD,
+			&buffer_head_kmem_cache_ops);
 
 	/*
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL

-- 
