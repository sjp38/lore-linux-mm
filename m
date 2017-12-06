Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B47B96B02D2
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:43:54 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f8so1499508pgs.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:43:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 1si922710plz.113.2017.12.05.16.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:10 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 16/73] xarray: Add xa_destroy
Date: Tue,  5 Dec 2017 16:41:02 -0800
Message-Id: <20171206004159.3755-17-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This function frees all the internal memory allocated to the xarray
and reinitialises it to be empty.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  1 +
 lib/xarray.c           | 26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index c3efcc3432f7..b648c1b93d9f 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -74,6 +74,7 @@ void *xa_load(struct xarray *, unsigned long index);
 void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
 void *xa_cmpxchg(struct xarray *, unsigned long index,
 			void *old, void *entry, gfp_t);
+void xa_destroy(struct xarray *);
 
 /**
  * xa_erase() - Erase this entry from the XArray.
diff --git a/lib/xarray.c b/lib/xarray.c
index 251724f62b11..f3875b251b41 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1341,6 +1341,32 @@ int xa_get_tagged(struct xarray *xa, void **dst, unsigned long start,
 }
 EXPORT_SYMBOL(xa_get_tagged);
 
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
+	XA_STATE(xas, xa, 0);
+	unsigned long flags;
+	void *entry;
+
+	xas.xa_node = NULL;
+	xa_lock_irqsave(xa, flags);
+	entry = xa_head_locked(xa);
+	RCU_INIT_POINTER(xa->xa_head, NULL);
+	xas_init_tags(&xas);
+	/* lockdep checks we're still holding the lock in xas_free_nodes() */
+	if (xa_is_node(entry))
+		xas_free_nodes(&xas, xa_to_node(entry));
+	xa_unlock_irqrestore(xa, flags);
+}
+EXPORT_SYMBOL(xa_destroy);
+
 #ifdef XA_DEBUG
 void xa_dump_entry(void *entry, unsigned long index)
 {
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
