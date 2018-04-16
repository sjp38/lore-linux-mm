Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0576B0003
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 22:42:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o9so2351061pgv.8
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 19:42:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l12si8463161pgq.691.2018.04.15.19.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 15 Apr 2018 19:42:33 -0700 (PDT)
Date: Sun, 15 Apr 2018 19:42:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [RFC] Speed up tag_pages_for_writeback
Message-ID: <20180416024232.GA14571@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org


I was looking at tag_pages_for_writeback and thinking how silly it was
to iterate over every dirty page only to set the perwrite bit on each
radix tree entry.  Dirty pages are _probably_ clustered, and so what
we're really trying to do is walk over each node in the array (between
start and end) and copy the bits from the dirty tag to the towrite tag.

Then it was just a matter of coming up with a decent interface
without moving the entire functionality into the xarray code (remember
radix_tree_range_tag_if_tagged?) and I think I've done a reasonable job
of that.

Completely untested, this was a random weekend thought.  I'd also
need to do kernel-doc and I'd probably want to refactor xas_find_tag()
and xas_next_batch() to share code rather than have xas_next_batch()
call xas_find_tag().

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 5aaac29e52cf..e75a191aa899 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -777,6 +777,10 @@ bool xas_get_tag(const struct xa_state *, xa_tag_t);
 void xas_set_tag(const struct xa_state *, xa_tag_t);
 void xas_clear_tag(const struct xa_state *, xa_tag_t);
 void *xas_find_tag(struct xa_state *, unsigned long max, xa_tag_t);
+unsigned long xas_get_tag_batch(struct xa_state *, xa_tag_t);
+void xas_set_tag_batch(struct xa_state *, unsigned long tags,
+		unsigned long max, xa_tag_t);
+bool xas_next_batch(struct xa_state *, unsigned long max, xa_tag_t tag);
 void xas_init_tags(const struct xa_state *);
 
 bool xas_nomem(struct xa_state *, gfp_t);
diff --git a/lib/xarray.c b/lib/xarray.c
index c8e52d8d2f9b..8c6025c1819e 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -753,6 +753,21 @@ bool xas_get_tag(const struct xa_state *xas, xa_tag_t tag)
 }
 EXPORT_SYMBOL_GPL(xas_get_tag);
 
+static void xa_node_set_tag(struct xarray *xa, struct xa_node *node,
+		unsigned int offset, xa_tag_t tag)
+{
+	while (node) {
+		if (node_get_tag(node, offset, tag))
+			return;
+		node_set_tag(node, offset, tag);
+		offset = node->offset;
+		node = xa_parent_locked(xa, node);
+	}
+
+	if (!xa_tagged(xa, tag))
+		xa_tag_set(xa, tag);
+}
+
 /**
  * xas_set_tag() - Sets the tag on this entry and its parents.
  * @xas: XArray operation state.
@@ -764,22 +779,10 @@ EXPORT_SYMBOL_GPL(xas_get_tag);
  */
 void xas_set_tag(const struct xa_state *xas, xa_tag_t tag)
 {
-	struct xa_node *node = xas->xa_node;
-	unsigned int offset = xas->xa_offset;
-
 	if (xas_invalid(xas))
 		return;
 
-	while (node) {
-		if (node_get_tag(node, offset, tag))
-			return;
-		node_set_tag(node, offset, tag);
-		offset = node->offset;
-		node = xa_parent_locked(xas->xa, node);
-	}
-
-	if (!xa_tagged(xas->xa, tag))
-		xa_tag_set(xas->xa, tag);
+	xa_node_set_tag(xas->xa, xas->xa_node, xas->xa_offset, tag);
 }
 EXPORT_SYMBOL_GPL(xas_set_tag);
 
@@ -814,6 +817,39 @@ void xas_clear_tag(const struct xa_state *xas, xa_tag_t tag)
 }
 EXPORT_SYMBOL_GPL(xas_clear_tag);
 
+unsigned long xas_get_tag_batch(struct xa_state *xas, xa_tag_t tag)
+{
+	unsigned int word = (xas->xa_index / BITS_PER_LONG) &
+				(XA_TAG_LONGS - 1);
+	unsigned int shift = xas->xa_index & (BITS_PER_LONG - 1);
+
+	return xas->xa_node->tags[tag][word] >> shift;
+}
+EXPORT_SYMBOL_GPL(xas_get_tag_batch);
+
+void xas_set_tag_batch(struct xa_state *xas, unsigned long tags,
+		unsigned long max, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int word = (xas->xa_index / BITS_PER_LONG) &
+				(XA_TAG_LONGS - 1);
+	unsigned int shift = xas->xa_index & (BITS_PER_LONG - 1);
+	unsigned long remain = max - xas->xa_index;
+
+	if (remain < BITS_PER_LONG)
+		tags &= (1UL << remain) - 1;
+
+	node->tags[tag][word] |= tags << shift;
+	xa_node_set_tag(xas->xa, node->parent, node->offset, tag);
+}
+EXPORT_SYMBOL_GPL(xas_set_tag_batch);
+
+bool xas_next_batch(struct xa_state *xas, unsigned long max, xa_tag_t tag)
+{
+	return xas_find_tag(xas, max, tag) != NULL;
+}
+EXPORT_SYMBOL_GPL(xas_next_batch);
+
 /**
  * xas_init_tags() - Initialise all tags for the entry
  * @xas: Array operations state.
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3e082cad387a..31e753c78d68 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2102,12 +2102,12 @@ void tag_pages_for_writeback(struct address_space *mapping,
 			     pgoff_t start, pgoff_t end)
 {
 	XA_STATE(xas, &mapping->i_pages, start);
-	void *page;
+	unsigned long tags;
 
-	xas_iter_pause_irq(&xas);
 	xas_lock_irq(&xas);
-	xas_for_each_tag(&xas, page, end, PAGECACHE_TAG_DIRTY) {
-		xas_set_tag(&xas, PAGECACHE_TAG_TOWRITE);
+	while (xas_next_batch(&xas, end, PAGECACHE_TAG_DIRTY)) {
+		tags = xas_get_tag_batch(&xas, PAGECACHE_TAG_DIRTY);
+		xas_set_tag_batch(&xas, tags, end, PAGECACHE_TAG_TOWRITE);
 	}
 	xas_unlock_irq(&xas);
 }
