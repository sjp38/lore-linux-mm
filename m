Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED2A6B02B2
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s11so17275160pgc.15
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n15si16019525pfj.278.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 27/62] xarray: Add xa_get_entries and xa_get_tagged
Date: Wed, 22 Nov 2017 13:07:04 -0800
Message-Id: <20171122210739.29916-28-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

These functions allow a range of xarray entries to be extracted into a
compact normal array.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  4 +++
 lib/xarray.c           | 69 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 427c792ddb2a..a48e7aa6406c 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -145,6 +145,10 @@ void *xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
 
 void *xa_find(struct xarray *xa, unsigned long *index, unsigned long max);
 void *xa_next(struct xarray *xa, unsigned long *index, unsigned long max);
+int xa_get_entries(struct xarray *, void **dst, unsigned long start,
+			unsigned long max, unsigned int n);
+int xa_get_tagged(struct xarray *, void **dst, unsigned long start,
+			unsigned long max, unsigned int n, xa_tag_t);
 
 /**
  * xa_for_each() - Iterate over a portion of an XArray.
diff --git a/lib/xarray.c b/lib/xarray.c
index ea2dbd343380..9577a70495c0 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1243,3 +1243,72 @@ void *xa_next(struct xarray *xa, unsigned long *indexp, unsigned long max)
 	return entry;
 }
 EXPORT_SYMBOL(xa_next);
+
+/**
+ * xa_get_entries() - Copy entries from the xarray into a normal array
+ * @xa: The source XArray to copy from
+ * @dst: The buffer to copy pointers into
+ * @start: The first index in the XArray eligible to be copied from
+ * @max: The last index in the XArray eligible to be copied from
+ * @n: The maximum number of entries to copy
+ *
+ * Return: The number of entries copied.
+ */
+int xa_get_entries(struct xarray *xa, void **dst, unsigned long start,
+			unsigned long max, unsigned int n)
+{
+	XA_STATE(xas, start);
+	void *entry;
+	unsigned int i = 0;
+
+	if (!n)
+		return 0;
+
+	rcu_read_lock();
+	xas_for_each(xa, &xas, entry, max) {
+		if (xas_retry(&xas, entry))
+			continue;
+		dst[i++] = entry;
+		if (i == n)
+			break;
+	}
+	rcu_read_unlock();
+
+	return i;
+}
+EXPORT_SYMBOL(xa_get_entries);
+
+/**
+ * xa_get_tagged() - Copy tagged entries from the xarray into a normal array.
+ * @xa: The source XArray to copy from.
+ * @dst: The buffer to copy pointers into.
+ * @start: The first index in the XArray eligible to be copied from.
+ * @max: The last index in the XArray eligible to be copied from
+ * @n: The maximum number of entries to copy.
+ * @tag: Tag number.
+ *
+ * Return: The number of entries copied.
+ */
+int xa_get_tagged(struct xarray *xa, void **dst, unsigned long start,
+			unsigned long max, unsigned int n, xa_tag_t tag)
+{
+	XA_STATE(xas, start);
+	void *entry;
+	unsigned int i = 0;
+
+	if (!n)
+		return 0;
+
+	rcu_read_lock();
+	xas_for_each_tag(xa, &xas, entry, max, tag) {
+		if (xas_retry(&xas, entry))
+			continue;
+		dst[i++] = entry;
+		if (i == n)
+			break;
+	}
+	rcu_read_unlock();
+
+	return i;
+}
+EXPORT_SYMBOL(xa_get_tagged);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
