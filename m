Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FAA06B026F
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:42:11 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n187so1616983pfn.10
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:42:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v12si911332plg.663.2017.12.05.16.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:09 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 12/73] xarray: Add xa_cmpxchg
Date: Tue,  5 Dec 2017 16:40:58 -0800
Message-Id: <20171206004159.3755-13-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This works like doing cmpxchg() on an array entry.  Code which wants
the radix_tree_insert() semantic of not overwriting an existing entry
can cmpxchg() with NULL and get the action it wants.  Plus, instead of
having an error returned, they get the value currently stored in the
array, which often saves them a subsequent lookup.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  2 ++
 lib/xarray.c           | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 6f1f55d9fc94..a570d7d9a252 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -72,6 +72,8 @@ static inline void xa_init(struct xarray *xa)
 
 void *xa_load(struct xarray *, unsigned long index);
 void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
+void *xa_cmpxchg(struct xarray *, unsigned long index,
+			void *old, void *entry, gfp_t);
 
 /**
  * xa_erase() - Erase this entry from the XArray.
diff --git a/lib/xarray.c b/lib/xarray.c
index fbbb02c25b6d..6625b1763123 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -852,6 +852,43 @@ void *xa_store(struct xarray *xa, unsigned long index, void *entry, gfp_t gfp)
 }
 EXPORT_SYMBOL(xa_store);
 
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
+ * Return: The old value at this index or ERR_PTR() if an error happened.
+ */
+void *xa_cmpxchg(struct xarray *xa, unsigned long index,
+			void *old, void *entry, gfp_t gfp)
+{
+	XA_STATE(xas, xa, index);
+	unsigned long flags;
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return ERR_PTR(-EINVAL);
+
+	do {
+		xa_lock_irqsave(xa, flags);
+		curr = xas_create(&xas);
+		if (curr == old)
+			xas_store(&xas, entry);
+		xa_unlock_irqrestore(xa, flags);
+	} while (xas_nomem(&xas, gfp));
+
+	if (xas_error(&xas))
+		curr = ERR_PTR(xas_error(&xas));
+	return curr;
+}
+EXPORT_SYMBOL(xa_cmpxchg);
+
 /**
  * __xa_set_tag() - Set this tag on this entry while locked.
  * @xa: XArray.
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
