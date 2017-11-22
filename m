Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6A646B02CC
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id u3so17276481pgn.3
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n1si14251516pgt.498.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 28/62] xarray: Add xa_destroy
Date: Wed, 22 Nov 2017 13:07:05 -0800
Message-Id: <20171122210739.29916-29-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This function frees all the internal memory allocated to the xarray
and reinitialises it to be empty.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  1 +
 lib/xarray.c           | 26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index a48e7aa6406c..347347499652 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -98,6 +98,7 @@ void *xa_load(struct xarray *, unsigned long index);
 void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
 void *xa_cmpxchg(struct xarray *, unsigned long index,
 			void *old, void *entry, gfp_t);
+void xa_destroy(struct xarray *);
 
 /**
  * xa_empty() - Determine if an array has any present entries
diff --git a/lib/xarray.c b/lib/xarray.c
index 9577a70495c0..4fc1073f9454 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1312,3 +1312,29 @@ int xa_get_tagged(struct xarray *xa, void **dst, unsigned long start,
 	return i;
 }
 EXPORT_SYMBOL(xa_get_tagged);
+
+/**
+ * xa_destroy() - Free all internal data structures.
+ * @xa: XArray.
+ *
+ * After calling this function, the XArray is empty and has freed all memory
+ * allocated for its internal data structures.  You are responsible for
+ * freeing the objects referenced by the XArray.
+ */
+void xa_destroy(struct xarray *xa)
+{
+	XA_STATE(xas, 0);
+	unsigned long flags;
+	void *entry;
+
+	xas.xa_node = NULL;
+	xa_lock_irqsave(xa, flags);
+	entry = xa_head_locked(xa);
+	RCU_INIT_POINTER(xa->xa_head, NULL);
+	xas_init_tags(xa, &xas);
+	/* lockdep checks we're still holding the lock in xas_free_nodes() */
+	if (xa_is_node(entry))
+		xas_free_nodes(xa, &xas, xa_to_node(entry));
+	xa_unlock_irqrestore(xa, flags);
+}
+EXPORT_SYMBOL(xa_destroy);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
