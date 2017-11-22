Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5863C6B02B5
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:05 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id g75so15515026pfg.4
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d72si15829820pfe.73.2017.11.22.13.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 25/62] xarray: Add xa_init
Date: Wed, 22 Nov 2017 13:07:02 -0800
Message-Id: <20171122210739.29916-26-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

For initialising xarrays in code rather than data.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h | 13 +++++++++++++
 lib/xarray.c           | 15 +++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 08ddad60a43d..19a3974fdc4f 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -81,6 +81,19 @@ struct xarray {
 
 #define DEFINE_XARRAY(name) struct xarray name = XARRAY_INIT(name)
 
+void __xa_init(struct xarray *, gfp_t flags);
+
+/**
+ * xa_init() - Initialise an empty XArray.
+ * @xa: XArray.
+ *
+ * An empty XArray is full of NULL entries.
+ */
+static inline void xa_init(struct xarray *xa)
+{
+	__xa_init(xa, 0);
+}
+
 void *xa_load(struct xarray *, unsigned long index);
 void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
 void *xa_cmpxchg(struct xarray *, unsigned long index,
diff --git a/lib/xarray.c b/lib/xarray.c
index 5409048e8b44..59f45c07988f 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -868,6 +868,21 @@ void *xas_find(struct xarray *xa, struct xa_state *xas, unsigned long max)
 }
 EXPORT_SYMBOL_GPL(xas_find);
 
+/**
+ * __xa_init() - Initialise an empty XArray
+ * @xa: XArray.
+ * @flags: XA_FLAG_ values
+ *
+ * An empty XArray is full of NULL pointers.
+ */
+void __xa_init(struct xarray *xa, gfp_t flags)
+{
+	spin_lock_init(&xa->xa_lock);
+	xa->xa_flags = flags;
+	xa->xa_head = NULL;
+}
+EXPORT_SYMBOL(__xa_init);
+
 /**
  * xa_load() - Load an entry from an XArray.
  * @xa: XArray.
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
