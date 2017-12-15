Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E63426B029A
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:06:05 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id i66so30636938itf.0
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:06:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z76si2192013ioz.153.2017.12.15.14.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:06:04 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 13/78] xarray: Add xa_cmpxchg
Date: Fri, 15 Dec 2017 14:03:45 -0800
Message-Id: <20171215220450.7899-14-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This works like doing cmpxchg() on an array entry.  Code which wants
the radix_tree_insert() semantic of not overwriting an existing entry
can cmpxchg() with NULL and get the action it wants.  Plus, instead of
having an error returned, they get the value currently stored in the
array, which often saves them a subsequent lookup.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h | 33 +++++++++++++++++++++++++
 lib/xarray.c           | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 98 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 05873095bc7f..56db23edac82 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -75,6 +75,8 @@ static inline void xa_init(struct xarray *xa)
 
 void *xa_load(struct xarray *, unsigned long index);
 void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
+void *xa_cmpxchg(struct xarray *, unsigned long index,
+			void *old, void *entry, gfp_t);
 
 /**
  * xa_erase() - Erase this entry from the XArray.
@@ -216,6 +218,32 @@ static inline int xa_err(void *entry)
 	return 0;
 }
 
+/**
+ * xa_store_empty() - Store this entry in the XArray unless another entry is
+ * 			already present.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @entry: New entry.
+ * @gfp: Memory allocation flags.
+ *
+ * If you would rather see the existing entry in the array, use xa_cmpxchg().
+ * This function is for users who don't care what the entry is, only that
+ * one is present.
+ *
+ * Return: -EEXIST if another entry was present, 0 if the store succeeded,
+ * or another negative errno if a different error happened (eg -ENOMEM).
+ */
+static inline int xa_store_empty(struct xarray *xa, unsigned long index,
+		void *entry, gfp_t gfp)
+{
+	void *curr = xa_cmpxchg(xa, index, NULL, entry, gfp);
+	if (!curr)
+		return 0;
+	if (xa_is_err(curr))
+		return xa_err(curr);
+	return -EEXIST;
+}
+
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
 #define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
 #define xa_unlock(xa)		spin_unlock(&(xa)->xa_lock)
@@ -242,9 +270,14 @@ enum xa_ctx {
 void *__xa_erase(struct xarray *, unsigned long index);
 void *___xa_store(struct xarray *, unsigned long index,
 		void *entry, gfp_t, enum xa_ctx);
+void *___xa_cmpxchg(struct xarray *, unsigned long index, void *old,
+		void *entry, gfp_t, enum xa_ctx);
 #define __xa_store(x, i, e, g)		___xa_store(x, i, e, g, XA_CTX_PRC)
 #define __xa_store_bh(x, i, e, g)	___xa_store(x, i, e, g, XA_CTX_BH)
 #define __xa_store_irq(x, i, e, g)	___xa_store(x, i, e, g, XA_CTX_IRQ)
+#define __xa_cmpxchg(x, i, o, e, g)	___xa_cmpxchg(x, i, o, e, g, XA_CTX_PRC)
+#define __xa_cmpxchg_bh(x, i, o, e, g)	___xa_cmpxchg(x, i, o, e, g, XA_CTX_BH)
+#define __xa_cmpxchg_irq(x, i, o, e, g) ___xa_cmpxchg(x, i, o, e, g, XA_CTX_IRQ)
 void __xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void __xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
 
diff --git a/lib/xarray.c b/lib/xarray.c
index 64f88ce23392..ef3340471e5c 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -921,6 +921,71 @@ void *___xa_store(struct xarray *xa, unsigned long index, void *entry,
 }
 EXPORT_SYMBOL(___xa_store);
 
+/**
+ * xa_cmpxchg() - Conditionally replace an entry in the XArray.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @old: Old value to test against.
+ * @entry: New value to place in array.
+ * @gfp: Allocation flags.
+ *
+ * If the entry at @index is the same as @old, replace it with @entry.
+ * If the return value is equal to @old, then the exchange was successful.
+ *
+ * Return: The old value at this index or xa_err() if an error happened.
+ */
+void *xa_cmpxchg(struct xarray *xa, unsigned long index,
+			void *old, void *entry, gfp_t gfp)
+{
+	XA_STATE(xas, xa, index);
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return XA_ERROR(-EINVAL);
+
+	do {
+		xas_lock(&xas);
+		curr = xas_create(&xas);
+		if (curr == old)
+			xas_store(&xas, entry);
+		xas_unlock(&xas);
+	} while (xas_nomem(&xas, gfp));
+
+	return xas_result(&xas, curr);
+}
+EXPORT_SYMBOL(xa_cmpxchg);
+
+/*
+ * ___xa_cmpxchg() - Store this entry in the XArray.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @entry: New entry.
+ * @gfp: Allocation flags.
+ * @lock_type: Lock acquisition type.
+ *
+ * Internal implementation detail.
+ *
+ * Return: The old entry at this index or xa_err() if an error happened.
+ */
+void *___xa_cmpxchg(struct xarray *xa, unsigned long index,
+			void *old, void *entry, gfp_t gfp, enum xa_ctx ctx)
+{
+	XA_STATE(xas, xa, index);
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return XA_ERROR(-EINVAL);
+
+	do {
+		curr = xas_create(&xas);
+		if (curr == old)
+			xas_store(&xas, entry);
+	} while (__xas_nomem(&xas, gfp, ctx));
+
+	return xas_result(&xas, curr);
+}
+EXPORT_SYMBOL(___xa_cmpxchg);
+
 /**
  * __xa_set_tag() - Set this tag on this entry while locked.
  * @xa: XArray.
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
