Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6426B026C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:19 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q7so2740793pgr.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 59si13610866plp.642.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 26/62] xarray: Add xas_for_each_tag
Date: Wed, 22 Nov 2017 13:07:03 -0800
Message-Id: <20171122210739.29916-27-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This iterator operates across each tagged entry in the specified range.
We do not yet have a user for an xa_for_each_tag iterator, but it would
be straight-forward to add one if needed.  This commit also includes
xas_find_tag() and xas_next_tag().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h | 70 +++++++++++++++++++++++++++++++++++++++++++
 lib/xarray.c           | 80 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 150 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 19a3974fdc4f..427c792ddb2a 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -465,6 +465,8 @@ void *xas_find(struct xarray *, struct xa_state *, unsigned long max);
 bool xas_get_tag(const struct xarray *, const struct xa_state *, xa_tag_t);
 void xas_set_tag(struct xarray *, const struct xa_state *, xa_tag_t);
 void xas_clear_tag(struct xarray *, const struct xa_state *, xa_tag_t);
+void *xas_find_tag(struct xarray *, struct xa_state *, unsigned long max,
+			xa_tag_t);
 void xas_init_tags(struct xarray *, const struct xa_state *);
 
 void xas_destroy(struct xa_state *);
@@ -566,6 +568,55 @@ static inline void *xas_next(struct xarray *xa, struct xa_state *xas,
 	return entry;
 }
 
+static inline unsigned int xas_find_chunk(struct xa_state *xas, bool advance,
+		xa_tag_t tag)
+{
+	unsigned long *addr = xas->xa_node->tags[(__force unsigned)tag];
+	unsigned int offset = xas->xa_offset;
+
+	if (advance)
+		offset++;
+	if (XA_CHUNK_SIZE == BITS_PER_LONG) {
+		unsigned long data = *addr & (~0UL << offset);
+		if (data)
+			return __ffs(data);
+		return XA_CHUNK_SIZE;
+	}
+
+	return find_next_bit(addr, XA_CHUNK_SIZE, offset);
+}
+
+/**
+ * xas_next_tag() - Advance iterator to next tagged entry.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ * @tag: Tag to search for.
+ *
+ * xas_next_tag() is an inline function to optimise xarray traversal for
+ * speed.  It is equivalent to calling xas_find_tag(), and will call
+ * xas_find_tag() for all the hard cases.
+ *
+ * Return: The next tagged entry after the one currently referred to by @xas.
+ */
+static inline void *xas_next_tag(struct xarray *xa, struct xa_state *xas,
+					unsigned long max, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset;
+
+	if (unlikely(xas_not_node(node) || node->shift))
+		return xas_find_tag(xa, xas, max, tag);
+	offset = xas_find_chunk(xas, true, tag);
+	xas->xa_offset = offset;
+	xas->xa_index = (xas->xa_index & ~XA_CHUNK_MASK) + offset;
+	if (xas->xa_index > max)
+		return NULL;
+	if (offset == XA_CHUNK_SIZE)
+		return xas_find_tag(xa, xas, max, tag);
+	return xa_entry(xa, node, offset);
+}
+
 /**
  * xas_for_each() - Iterate over a range of an XArray
  * @xa: XArray.
@@ -584,4 +635,23 @@ static inline void *xas_next(struct xarray *xa, struct xa_state *xas,
 	for (entry = xas_find(xa, xas, max); entry; \
 	     entry = xas_next(xa, xas, max))
 
+/**
+ * xas_for_each_tag() - Iterate over a range of an XArray
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @entry: Entry retrieved from array.
+ * @max: Maximum index to retrieve from array.
+ * @tag: Tag to search for.
+ *
+ * The loop body will be executed for each tagged entry in the xarray
+ * between the current xas position and @max.  @entry will be set to
+ * the entry retrieved from the xarray.  It is safe to delete entries
+ * from the array in the loop body.  You should hold either the RCU lock
+ * or the xa_lock while iterating.  If you need to drop the lock, call
+ * xas_pause() first.
+ */
+#define xas_for_each_tag(xa, xas, entry, max, tag) \
+	for (entry = xas_find_tag(xa, xas, max, tag); entry; \
+	     entry = xas_next_tag(xa, xas, max, tag))
+
 #endif /* _LINUX_XARRAY_H */
diff --git a/lib/xarray.c b/lib/xarray.c
index 59f45c07988f..ea2dbd343380 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -868,6 +868,86 @@ void *xas_find(struct xarray *xa, struct xa_state *xas, unsigned long max)
 }
 EXPORT_SYMBOL_GPL(xas_find);
 
+/**
+ * xas_find_tag() - Find the next tagged entry in the XArray.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ * @tag: Tag number to search for.
+ *
+ * If the xas has not yet been walked to an entry, return the tagged entry
+ * which has an index >= xas.xa_index.  If it has been walked, the entry
+ * currently being pointed at has been processed, and so we move to the
+ * next tagged entry.
+ *
+ * If no tagged entry is found and the array is smaller than @max, @xas is
+ * set to the restart state and xas->xa_index is set to the smallest index
+ * not yet in the array.  This allows @xas to be immediately passed to
+ * xas_create().
+ *
+ * Return: The entry, if found, otherwise NULL.
+ */
+void *xas_find_tag(struct xarray *xa, struct xa_state *xas, unsigned long max,
+		xa_tag_t tag)
+{
+	bool advance = true;
+	unsigned int offset;
+	void *entry;
+
+	if (xas_error(xas))
+		return NULL;
+
+	if (xas->xa_node == NULL) {
+		xas->xa_index = 1;
+		goto out;
+	} else if (xas->xa_node == XAS_RESTART) {
+		advance = false;
+		entry = xa_head(xa);
+		if (xas->xa_index > max_index(entry))
+			goto out;
+		if (!xa_is_node(entry)) {
+			if (xa_tagged(xa, tag)) {
+				xas->xa_node = NULL;
+				return entry;
+			}
+			xas->xa_index = 1;
+			goto out;
+		}
+		xas->xa_node = xa_to_node(entry);
+		xas->xa_offset = xas->xa_index >> xas->xa_node->shift;
+	}
+
+	while (xas->xa_index <= max) {
+		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			xas->xa_offset = xas->xa_node->offset + 1;
+			xas->xa_node = xa_parent(xa, xas->xa_node);
+			if (!xas->xa_node)
+				break;
+			advance = false;
+			continue;
+		}
+
+		offset = xas_find_chunk(xas, advance, tag);
+		xas_add(xas, offset - xas->xa_offset);
+		if (offset == XA_CHUNK_SIZE) {
+			advance = false;
+			continue;
+		}
+
+		entry = xa_entry(xa, xas->xa_node, xas->xa_offset);
+		if (!xa_is_node(entry))
+			return entry;
+		xas->xa_node = xa_to_node(entry);
+		xas->xa_offset = get_offset(xas->xa_index, xas->xa_node);
+	}
+
+ out:
+	if (!xas->xa_node)
+		xas->xa_node = XAS_RESTART;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xas_find_tag);
+
 /**
  * __xa_init() - Initialise an empty XArray
  * @xa: XArray.
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
