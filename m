Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBD29280254
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:22:37 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id o11so12181808pgp.14
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:22:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q5si4820353pll.252.2018.01.17.12.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:36 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 21/99] xarray: Add xa_reserve and xa_release
Date: Wed, 17 Jan 2018 12:20:45 -0800
Message-Id: <20180117202203.19756-22-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This function simply creates a slot in the XArray for users which need
to acquire multiple locks before storing their entry in the tree and
so cannot use a plain xa_store().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                 | 14 ++++++++++
 lib/xarray.c                           | 51 ++++++++++++++++++++++++++++++++++
 tools/testing/radix-tree/xarray-test.c | 25 +++++++++++++++++
 3 files changed, 90 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 6f59f1f60205..c3f7405c5517 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -259,6 +259,7 @@ void *xa_load(struct xarray *, unsigned long index);
 void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
 void *xa_cmpxchg(struct xarray *, unsigned long index,
 			void *old, void *entry, gfp_t);
+int xa_reserve(struct xarray *, unsigned long index, gfp_t);
 bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
@@ -373,6 +374,19 @@ static inline int xa_insert(struct xarray *xa, unsigned long index,
 	return -EEXIST;
 }
 
+/**
+ * xa_release() - Release a reserved entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ *
+ * After calling xa_reserve(), you can call this function to release the
+ * reservation.  It is harmless to call this function if the entry was used.
+ */
+static inline void xa_release(struct xarray *xa, unsigned long index)
+{
+	xa_cmpxchg(xa, index, NULL, NULL, 0);
+}
+
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
 #define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
 #define xa_unlock(xa)		spin_unlock(&(xa)->xa_lock)
diff --git a/lib/xarray.c b/lib/xarray.c
index ace309cc9253..b4dec8e2d202 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1275,6 +1275,8 @@ void *xa_cmpxchg(struct xarray *xa, unsigned long index,
 	do {
 		xas_lock(&xas);
 		curr = xas_load(&xas);
+		if (curr == XA_ZERO_ENTRY)
+			curr = NULL;
 		if (curr == old)
 			xas_store(&xas, entry);
 		xas_unlock(&xas);
@@ -1310,6 +1312,8 @@ void *__xa_cmpxchg(struct xarray *xa, unsigned long index,
 
 	do {
 		curr = xas_load(&xas);
+		if (curr == XA_ZERO_ENTRY)
+			curr = NULL;
 		if (curr == old)
 			xas_store(&xas, entry);
 	} while (__xas_nomem(&xas, gfp));
@@ -1318,6 +1322,53 @@ void *__xa_cmpxchg(struct xarray *xa, unsigned long index,
 }
 EXPORT_SYMBOL(__xa_cmpxchg);
 
+/**
+ * xa_reserve() - Reserve this index in the XArray.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @gfp: Memory allocation flags.
+ *
+ * Ensures there is somewhere to store an entry at @index in the array.
+ * If there is already something stored at @index, this function does
+ * nothing.  If there was nothing there, the entry is marked as reserved.
+ * Loads from @index will continue to see a %NULL pointer until a
+ * subsequent store to @index.
+ *
+ * If you do not use the entry that you have reserved, call xa_release()
+ * or xa_erase() to free any unnecessary memory.
+ *
+ * Return: 0 if the reservation succeeded or -ENOMEM if it failed.
+ */
+int xa_reserve(struct xarray *xa, unsigned long index, gfp_t gfp)
+{
+	XA_STATE(xas, xa, index);
+	unsigned int lock_type = xa_lock_type(xa);
+	void *curr;
+
+	do {
+		if (lock_type == XA_LOCK_IRQ)
+			xas_lock_irq(&xas);
+		else if (lock_type == XA_LOCK_BH)
+			xas_lock_bh(&xas);
+		else
+			xas_lock(&xas);
+
+		curr = xas_create(&xas);
+		if (!curr)
+			xas_store(&xas, XA_ZERO_ENTRY);
+
+                if (lock_type == XA_LOCK_IRQ)
+                        xas_unlock_irq(&xas);
+                else if (lock_type == XA_LOCK_BH)
+                        xas_unlock_bh(&xas);
+                else
+                        xas_unlock(&xas);
+	} while (xas_nomem(&xas, gfp));
+
+	return xas_error(&xas);
+}
+EXPORT_SYMBOL(xa_reserve);
+
 /**
  * __xa_set_tag() - Set this tag on this entry while locked.
  * @xa: XArray.
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index 4d3541ac31e9..fe38b53df2ab 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -502,6 +502,29 @@ void check_move(struct xarray *xa)
 	} while (i < (1 << 16));
 }
 
+void check_reserve(struct xarray *xa)
+{
+	assert(xa_empty(xa));
+	xa_reserve(xa, 12345678, GFP_KERNEL);
+	assert(!xa_empty(xa));
+	assert(!xa_load(xa, 12345678));
+	xa_release(xa, 12345678);
+	assert(xa_empty(xa));
+
+	xa_reserve(xa, 12345678, GFP_KERNEL);
+	assert(!xa_store(xa, 12345678, xa_mk_value(12345678), GFP_NOWAIT));
+	xa_release(xa, 12345678);
+	assert(xa_erase(xa, 12345678) == xa_mk_value(12345678));
+	assert(xa_empty(xa));
+
+	xa_reserve(xa, 12345678, GFP_KERNEL);
+	assert(!xa_cmpxchg(xa, 12345678, NULL, xa_mk_value(12345678),
+								GFP_NOWAIT));
+	xa_release(xa, 12345678);
+	assert(xa_erase(xa, 12345678) == xa_mk_value(12345678));
+	assert(xa_empty(xa));
+}
+
 void xarray_checks(void)
 {
 	DEFINE_XARRAY(array);
@@ -548,6 +571,8 @@ void xarray_checks(void)
 
 	check_move(&array);
 	item_kill_tree(&array);
+
+	check_reserve(&array);
 }
 
 int __weak main(void)
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
