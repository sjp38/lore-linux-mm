Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09E116B02A4
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:09:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q187so996902pga.6
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:09:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t19si14043666plo.127.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 30/62] xarray: Add xas_find_any / xas_next_any
Date: Wed, 22 Nov 2017 13:07:07 -0800
Message-Id: <20171122210739.29916-31-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

These variations will find any entry (whether it be NULL or an internal
entry).  The only thing they won't return is a node pointer (because it
will walk down the tree).  xas_next_any() is an inline version of
xas_find_any() which avoids making a function call for the common cases.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h | 25 +++++++++++++++++++++++++
 lib/xarray.c           | 51 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index e0cfe6944752..8ab6c4468c21 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -466,6 +466,7 @@ void *xas_load(struct xarray *, struct xa_state *);
 void *xas_store(struct xarray *, struct xa_state *, void *entry);
 void *xas_create(struct xarray *, struct xa_state *);
 void *xas_find(struct xarray *, struct xa_state *, unsigned long max);
+void *xas_find_any(struct xarray *, struct xa_state *);
 void *xas_prev_any(struct xarray *, struct xa_state *);
 
 bool xas_get_tag(const struct xarray *, const struct xa_state *, xa_tag_t);
@@ -540,6 +541,30 @@ static inline bool xa_iter_skip(void *entry)
 			(xa_is_internal(entry) && entry < XA_RETRY_ENTRY));
 }
 
+/**
+ * xas_next_any() - Advance iterator to next entry of any kind.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ *
+ * xas_next_any() is an inline function to optimise xarray traversal for speed.
+ * It is equivalent to calling xas_find_any(), and will call xas_find_any()
+ * for all the hard cases.
+ *
+ * Return: The next entry after the one currently referred to by @xas.
+ */
+static inline void *xas_next_any(struct xarray *xa, struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	if (unlikely(xas_not_node(node) || node->shift ||
+				xas->xa_offset == XA_CHUNK_MASK))
+		return xas_find_any(xa, xas);
+
+	xas->xa_index++;
+	xas->xa_offset++;
+	return xa_entry(xa, node, xas->xa_offset);
+}
+
 /**
  * xas_next() - Advance iterator to next present entry.
  * @xa: XArray.
diff --git a/lib/xarray.c b/lib/xarray.c
index 202e5aae596d..38e5fe39bb97 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -805,6 +805,57 @@ void xas_pause(struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_pause);
 
+/**
+ * xas_find_any() - Find the next entry in the XArray.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ *
+ * If the xas has not yet been walked to an entry, return the entry
+ * which has an index >= xas.xa_index.  If it has been walked, the entry
+ * currently being pointed at has been processed, and so we move to the
+ * next entry.
+ *
+ * Return: The entry at that location.
+ */
+void *xas_find_any(struct xarray *xa, struct xa_state *xas)
+{
+	void *entry;
+
+	if (xas_error(xas))
+		return NULL;
+
+	if (xas->xa_node == XAS_RESTART) {
+		return xas_load(xa, xas);
+	} else if (!xas->xa_node) {
+		xas->xa_index = 1;
+		xas->xa_node = XAS_RESTART;
+		return NULL;
+	}
+
+	xas->xa_index = next_index(xas->xa_index, xas->xa_node);
+	xas->xa_offset++;
+
+	while (xas->xa_node) {
+		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			xas->xa_offset = xas->xa_node->offset + 1;
+			xas->xa_node = xa_parent(xa, xas->xa_node);
+			continue;
+		}
+
+		entry = xa_entry(xa, xas->xa_node, xas->xa_offset);
+		if (!xa_is_node(entry))
+			return entry;
+
+		xas->xa_node = xa_to_node(entry);
+		xas->xa_offset = 0;
+	}
+
+	if (!xas->xa_node)
+		xas->xa_node = XAS_RESTART;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xas_find_any);
+
 /**
  * xas_find() - Find the next present entry in the XArray.
  * @xa: XArray.
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
