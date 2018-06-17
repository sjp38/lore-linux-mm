Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0E06B02D2
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:02:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id p91-v6so7643186plb.12
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:02:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f17-v6si9281658pgv.383.2018.06.16.19.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:07 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 15/74] xarray: Destroy an XArray
Date: Sat, 16 Jun 2018 18:59:53 -0700
Message-Id: <20180617020052.4759-16-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

This function frees all the internal memory allocated to the xarray
and reinitialises it to be empty.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/xarray.h |  1 +
 lib/xarray.c           | 28 ++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 6f398732b664..fa36a0670988 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -229,6 +229,7 @@ void *xa_find_after(struct xarray *xa, unsigned long *index,
 		unsigned long max, xa_tag_t) __attribute__((nonnull(2)));
 unsigned int xa_extract(struct xarray *, void **dst, unsigned long start,
 		unsigned long max, unsigned int n, xa_tag_t);
+void xa_destroy(struct xarray *);
 
 /**
  * xa_init() - Initialise an empty XArray.
diff --git a/lib/xarray.c b/lib/xarray.c
index 1e15ead40d78..e90ba76404ae 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1493,6 +1493,34 @@ unsigned int xa_extract(struct xarray *xa, void **dst, unsigned long start,
 }
 EXPORT_SYMBOL(xa_extract);
 
+/**
+ * xa_destroy() - Free all internal data structures.
+ * @xa: XArray.
+ *
+ * After calling this function, the XArray is empty and has freed all memory
+ * allocated for its internal data structures.  You are responsible for
+ * freeing the objects referenced by the XArray.
+ *
+ * Context: Any context.  Takes and releases the xa_lock, interrupt-safe.
+ */
+void xa_destroy(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+	unsigned long flags;
+	void *entry;
+
+	xas.xa_node = NULL;
+	xas_lock_irqsave(&xas, flags);
+	entry = xa_head_locked(xa);
+	RCU_INIT_POINTER(xa->xa_head, NULL);
+	xas_init_tags(&xas);
+	/* lockdep checks we're still holding the lock in xas_free_nodes() */
+	if (xa_is_node(entry))
+		xas_free_nodes(&xas, xa_to_node(entry));
+	xas_unlock_irqrestore(&xas, flags);
+}
+EXPORT_SYMBOL(xa_destroy);
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
-- 
2.17.1
