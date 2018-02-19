Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5739C6B0279
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:15 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id l14so1475509pgn.21
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z21-v6si4788542plo.545.2018.02.19.11.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:13 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 18/61] xarray: Add xa_cmpxchg and xa_insert
Date: Mon, 19 Feb 2018 11:45:13 -0800
Message-Id: <20180219194556.6575-19-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Like cmpxchg(), xa_cmpxchg will only store to the index if the current
entry matches the old entry.  It returns the current entry, which is
usually more useful than the errno returned by radix_tree_insert().
For the users who really only want the errno, the xa_insert() wrapper
provides a more convenient calling convention.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                 | 60 ++++++++++++++++++++++++++++
 lib/xarray.c                           | 71 ++++++++++++++++++++++++++++++++++
 tools/testing/radix-tree/xarray-test.c | 10 +++++
 3 files changed, 141 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 38e290df2ff0..e95ebe2488f9 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -218,6 +218,8 @@ struct xarray {
 void xa_init_flags(struct xarray *, gfp_t flags);
 void *xa_load(struct xarray *, unsigned long index);
 void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
+void *xa_cmpxchg(struct xarray *, unsigned long index,
+			void *old, void *entry, gfp_t);
 bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
@@ -277,6 +279,34 @@ static inline bool xa_tagged(const struct xarray *xa, xa_tag_t tag)
 	return xa->xa_flags & XA_FLAGS_TAG(tag);
 }
 
+/**
+ * xa_insert() - Store this entry in the XArray unless another entry is
+ *			already present.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @entry: New entry.
+ * @gfp: Memory allocation flags.
+ *
+ * If you would rather see the existing entry in the array, use xa_cmpxchg().
+ * This function is for users who don't care what the entry is, only that
+ * one is present.
+ *
+ * Context: Process context.  Takes and releases the xa_lock.
+ *	    May sleep if the @gfp flags permit.
+ * Return: 0 if the store succeeded.  -EEXIST if another entry was present.
+ * 	   -ENOMEM if memory could not be allocated.
+ */
+static inline int xa_insert(struct xarray *xa, unsigned long index,
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
@@ -296,9 +326,39 @@ static inline bool xa_tagged(const struct xarray *xa, xa_tag_t tag)
  */
 void *__xa_erase(struct xarray *, unsigned long index);
 void *__xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
+void *__xa_cmpxchg(struct xarray *, unsigned long index, void *old,
+		void *entry, gfp_t);
 void __xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void __xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
 
+/**
+ * __xa_insert() - Store this entry in the XArray unless another entry is
+ *			already present.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @entry: New entry.
+ * @gfp: Memory allocation flags.
+ *
+ * If you would rather see the existing entry in the array, use __xa_cmpxchg().
+ * This function is for users who don't care what the entry is, only that
+ * one is present.
+ *
+ * Context: Any context.  Expects xa_lock to be held on entry.  May
+ *	    release and reacquire xa_lock if the @gfp flags permit.
+ * Return: 0 if the store succeeded.  -EEXIST if another entry was present.
+ *	   -ENOMEM if memory could not be allocated.
+ */
+static inline int __xa_insert(struct xarray *xa, unsigned long index,
+		void *entry, gfp_t gfp)
+{
+	void *curr = __xa_cmpxchg(xa, index, NULL, entry, gfp);
+	if (!curr)
+		return 0;
+	if (xa_is_err(curr))
+		return xa_err(curr);
+	return -EEXIST;
+}
+
 /* Everything below here is the Advanced API.  Proceed with caution. */
 
 /*
diff --git a/lib/xarray.c b/lib/xarray.c
index 9e50804f168c..a231699d894a 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -937,6 +937,77 @@ void *__xa_store(struct xarray *xa, unsigned long index, void *entry, gfp_t gfp)
 }
 EXPORT_SYMBOL(__xa_store);
 
+/**
+ * xa_cmpxchg() - Conditionally replace an entry in the XArray.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @old: Old value to test against.
+ * @entry: New value to place in array.
+ * @gfp: Memory allocation flags.
+ *
+ * If the entry at @index is the same as @old, replace it with @entry.
+ * If the return value is equal to @old, then the exchange was successful.
+ *
+ * Context: Process context.  Takes and releases the xa_lock.  May sleep
+ * if the @gfp flags permit.
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
+		curr = xas_load(&xas);
+		if (curr == old)
+			xas_store(&xas, entry);
+		xas_unlock(&xas);
+	} while (xas_nomem(&xas, gfp));
+
+	return xas_result(&xas, curr);
+}
+EXPORT_SYMBOL(xa_cmpxchg);
+
+/**
+ * __xa_cmpxchg() - Store this entry in the XArray.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @old: Old value to test against.
+ * @entry: New entry.
+ * @gfp: Memory allocation flags.
+ *
+ * You must already be holding the xa_lock when calling this function.
+ * It will drop the lock if needed to allocate memory, and then reacquire
+ * it afterwards.
+ *
+ * Context: Any context.  Expects xa_lock to be held on entry.  May
+ * release and reacquire xa_lock if @gfp flags permit.
+ * Return: The old entry at this index or xa_err() if an error happened.
+ */
+void *__xa_cmpxchg(struct xarray *xa, unsigned long index,
+			void *old, void *entry, gfp_t gfp)
+{
+	XA_STATE(xas, xa, index);
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return XA_ERROR(-EINVAL);
+
+	do {
+		curr = xas_load(&xas);
+		if (curr == old)
+			xas_store(&xas, entry);
+	} while (__xas_nomem(&xas, gfp));
+
+	return xas_result(&xas, curr);
+}
+EXPORT_SYMBOL(__xa_cmpxchg);
+
 /**
  * __xa_set_tag() - Set this tag on this entry while locked.
  * @xa: XArray.
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index 5defd0b9f85c..d6a969d999d9 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -84,6 +84,15 @@ void check_xa_shrink(struct xarray *xa)
 	assert(xa_load(xa, 0) == xa_mk_value(0));
 }
 
+void check_cmpxchg(struct xarray *xa)
+{
+	assert(xa_empty(xa));
+	assert(!xa_store(xa, 12345678, xa_mk_value(12345678), GFP_KERNEL));
+	assert(!xa_cmpxchg(xa, 5, xa_mk_value(5), NULL, GFP_KERNEL));
+	assert(xa_erase(xa, 12345678) == xa_mk_value(12345678));
+	assert(xa_empty(xa));
+}
+
 void check_multi_store(struct xarray *xa)
 {
 	unsigned long i, j, k;
@@ -149,6 +158,7 @@ void xarray_checks(void)
 	check_xa_shrink(&array);
 	item_kill_tree(&array);
 
+	check_cmpxchg(&array);
 	check_multi_store(&array);
 	item_kill_tree(&array);
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
