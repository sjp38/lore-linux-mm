Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 899076B0277
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:19 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id l19so17285546pgo.4
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o72si9021293pfa.375.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 29/62] xarray: Add xas_prev_any
Date: Wed, 22 Nov 2017 13:07:06 -0800
Message-Id: <20171122210739.29916-30-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The page cache wants to search backwards to find the first hole.
Its definition of a hole doesn't make sense for the xarray, so introduce
a function called xas_prev_any() which will return any kind of entry,
including NULL or internal entries.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  1 +
 lib/xarray.c           | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c           | 15 +++++----------
 3 files changed, 55 insertions(+), 10 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 347347499652..e0cfe6944752 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -466,6 +466,7 @@ void *xas_load(struct xarray *, struct xa_state *);
 void *xas_store(struct xarray *, struct xa_state *, void *entry);
 void *xas_create(struct xarray *, struct xa_state *);
 void *xas_find(struct xarray *, struct xa_state *, unsigned long max);
+void *xas_prev_any(struct xarray *, struct xa_state *);
 
 bool xas_get_tag(const struct xarray *, const struct xa_state *, xa_tag_t);
 void xas_set_tag(struct xarray *, const struct xa_state *, xa_tag_t);
diff --git a/lib/xarray.c b/lib/xarray.c
index 4fc1073f9454..202e5aae596d 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -948,6 +948,55 @@ void *xas_find_tag(struct xarray *xa, struct xa_state *xas, unsigned long max,
 }
 EXPORT_SYMBOL_GPL(xas_find_tag);
 
+/**
+ * xas_prev_any() - Find the previous entry in the XArray.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ *
+ * If the xas has not yet been walked to an entry, return the entry
+ * which has an index = xas.xa_index.  If it has been walked, the entry
+ * currently being pointed at has been processed, and so we move to the
+ * previous entry.
+ *
+ * If asked for the previous entry of 0, this function returns NULL and
+ * sets xa_index to ULONG_MAX.  The caller is responsible for detecting
+ * this situation.
+ *
+ * Return: The entry at the index, even if it is NULL.
+ */
+void *xas_prev_any(struct xarray *xa, struct xa_state *xas)
+{
+	void *entry;
+
+	if (xas_error(xas))
+		return NULL;
+
+	if (xas->xa_node == XAS_RESTART)
+		return xas_load(xa, xas);
+
+	while (xas->xa_node) {
+		if (unlikely(xas->xa_offset == 0)) {
+			xas->xa_offset = xas->xa_node->offset;
+			xas->xa_node = xa_parent(xa, xas->xa_node);
+			continue;
+		}
+
+		xas->xa_offset--;
+		xas->xa_index -= 1UL << xas->xa_node->shift;
+		entry = xa_entry(xa, xas->xa_node, xas->xa_offset);
+		if (!xa_is_node(entry))
+			return entry;
+
+		xas->xa_node = xa_to_node(entry);
+		xas->xa_offset = XA_CHUNK_MASK;
+		xas->xa_index |= XA_CHUNK_MASK << xas->xa_node->shift;
+	}
+
+	xas->xa_index = ULONG_MAX;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xas_prev_any);
+
 /**
  * __xa_init() - Initialise an empty XArray
  * @xa: XArray.
diff --git a/mm/filemap.c b/mm/filemap.c
index 1d012dd3629e..1c03b0ea105e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1390,20 +1390,15 @@ EXPORT_SYMBOL(page_cache_next_hole);
 pgoff_t page_cache_prev_hole(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan)
 {
-	unsigned long i;
-
-	for (i = 0; i < max_scan; i++) {
-		struct page *page;
+	XA_STATE(xas, index);
 
-		page = radix_tree_lookup(&mapping->pages, index);
-		if (!page || xa_is_value(page))
-			break;
-		index--;
-		if (index == ULONG_MAX)
+	while (max_scan--) {
+		void *entry = xas_prev_any(&mapping->pages, &xas);
+		if (!entry || xa_is_value(entry))
 			break;
 	}
 
-	return index;
+	return xas.xa_index;
 }
 EXPORT_SYMBOL(page_cache_prev_hole);
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
