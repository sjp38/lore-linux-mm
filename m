Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56FC06B0287
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:55 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id f185so16494742itc.2
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u6si5881434itf.144.2017.12.15.14.05.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:54 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 17/78] xarray: Add xa_destroy
Date: Fri, 15 Dec 2017 14:03:49 -0800
Message-Id: <20171215220450.7899-18-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This function frees all the internal memory allocated to the xarray
and reinitialises it to be empty.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  1 +
 lib/xarray.c           | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 1367d694eebd..fea81383a301 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -77,6 +77,7 @@ void *xa_load(struct xarray *, unsigned long index);
 void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
 void *xa_cmpxchg(struct xarray *, unsigned long index,
 			void *old, void *entry, gfp_t);
+void xa_destroy(struct xarray *);
 
 /**
  * xa_erase() - Erase this entry from the XArray.
diff --git a/lib/xarray.c b/lib/xarray.c
index e73ae7b57fc9..a51fa1e1f74f 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1418,6 +1418,31 @@ int xa_get_tagged(struct xarray *xa, void **dst, unsigned long start,
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
+	void *entry;
+
+	xas.xa_node = NULL;
+	xa_lock(xa);
+	entry = xa_head_locked(xa);
+	RCU_INIT_POINTER(xa->xa_head, NULL);
+	xas_init_tags(&xas);
+	/* lockdep checks we're still holding the lock in xas_free_nodes() */
+	if (xa_is_node(entry))
+		xas_free_nodes(&xas, xa_to_node(entry));
+	xa_unlock(xa);
+}
+EXPORT_SYMBOL(xa_destroy);
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
