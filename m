Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 132376B000C
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z9-v6so6619471pfe.23
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a7-v6si9498288pgc.125.2018.06.16.19.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:01 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 17/74] xarray: Add xas_for_each_conflict
Date: Sat, 16 Jun 2018 18:59:55 -0700
Message-Id: <20180617020052.4759-18-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

This iterator iterates over each entry that is stored in the index or
indices specified by the xa_state.  This is intended for use for a
conditional store of a multiindex entry, or to allow entries which are
about to be removed from the xarray to be disposed of properly.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/xarray.h | 17 ++++++++++++
 lib/test_xarray.c      | 63 ++++++++++++++++++++++++++++++++++++++++++
 lib/xarray.c           | 61 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 141 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 921d41034d7d..0a9f66266c9a 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -769,6 +769,7 @@ static inline bool xas_retry(struct xa_state *xas, const void *entry)
 void *xas_load(struct xa_state *);
 void *xas_store(struct xa_state *, void *entry);
 void *xas_find(struct xa_state *, unsigned long max);
+void *xas_next_conflict(struct xa_state *);
 
 bool xas_get_tag(const struct xa_state *, xa_tag_t);
 void xas_set_tag(const struct xa_state *, xa_tag_t);
@@ -983,6 +984,22 @@ enum {
 	for (entry = xas_find_tagged(xas, max, tag); entry; \
 	     entry = xas_next_tagged(xas, max, tag))
 
+/**
+ * xas_for_each_conflict() - Iterate over a range of an XArray.
+ * @xas: XArray operation state.
+ * @entry: Entry retrieved from the array.
+ *
+ * The loop body will be executed for each entry in the XArray that lies
+ * within the range specified by @xas.  If the loop completes successfully,
+ * any entries that lie in this range will be replaced by @entry.  The caller
+ * may break out of the loop; if they do so, the contents of the XArray will
+ * be unchanged.  The operation may fail due to an out of memory condition.
+ * The caller may also call xa_set_err() to exit the loop while setting an
+ * error to record the reason.
+ */
+#define xas_for_each_conflict(xas, entry) \
+	while ((entry = xas_next_conflict(xas)))
+
 void *__xas_next(struct xa_state *);
 void *__xas_prev(struct xa_state *);
 
diff --git a/lib/test_xarray.c b/lib/test_xarray.c
index e74ade12c663..818cfd8746ba 100644
--- a/lib/test_xarray.c
+++ b/lib/test_xarray.c
@@ -315,6 +315,68 @@ static void check_multi_store(struct xarray *xa)
 	}
 }
 
+static void __check_store_iter(struct xarray *xa, unsigned long start,
+			unsigned int order, unsigned int present)
+{
+	XA_STATE_ORDER(xas, xa, start, order);
+	void *entry;
+	unsigned int count = 0;
+
+retry:
+	xas_for_each_conflict(&xas, entry) {
+		XA_BUG_ON(xa, !xa_is_value(entry));
+		XA_BUG_ON(xa, entry < xa_mk_value(start));
+		XA_BUG_ON(xa, entry > xa_mk_value(start + (1UL << order) - 1));
+		count++;
+	}
+	xas_store(&xas, xa_mk_value(start));
+	if (xas_nomem(&xas, GFP_KERNEL)) {
+		count = 0;
+		goto retry;
+	}
+	XA_BUG_ON(xa, xas_error(&xas));
+	XA_BUG_ON(xa, count != present);
+	XA_BUG_ON(xa, xa_load(xa, start) != xa_mk_value(start));
+	XA_BUG_ON(xa, xa_load(xa, start + (1UL << order) - 1) !=
+			xa_mk_value(start));
+	xa_erase_value(xa, start);
+}
+
+static void check_store_iter(struct xarray *xa)
+{
+	unsigned int i, j;
+
+	for (i = 0; i < 20; i++) {
+		unsigned int min = 1 << i;
+		unsigned int max = (2 << i) - 1;
+		__check_store_iter(xa, 0, i, 0);
+		XA_BUG_ON(xa, !xa_empty(xa));
+		__check_store_iter(xa, min, i, 0);
+		XA_BUG_ON(xa, !xa_empty(xa));
+
+		xa_store_value(xa, min, GFP_KERNEL);
+		__check_store_iter(xa, min, i, 1);
+		XA_BUG_ON(xa, !xa_empty(xa));
+		xa_store_value(xa, max, GFP_KERNEL);
+		__check_store_iter(xa, min, i, 1);
+		XA_BUG_ON(xa, !xa_empty(xa));
+
+		for (j = 0; j < min; j++)
+			xa_store_value(xa, j, GFP_KERNEL);
+		__check_store_iter(xa, 0, i, min);
+		XA_BUG_ON(xa, !xa_empty(xa));
+		for (j = 0; j < min; j++)
+			xa_store_value(xa, min + j, GFP_KERNEL);
+		__check_store_iter(xa, min, i, min);
+		XA_BUG_ON(xa, !xa_empty(xa));
+	}
+	xa_store_value(xa, 63, GFP_KERNEL);
+	xa_store_value(xa, 65, GFP_KERNEL);
+	__check_store_iter(xa, 64, 2, 1);
+	xa_erase_value(xa, 63);
+	XA_BUG_ON(xa, !xa_empty(xa));
+}
+
 static void check_multi_find(struct xarray *xa)
 {
 	unsigned long index;
@@ -506,6 +568,7 @@ static int xarray_checks(void)
 	check_multi_store(&array);
 	check_find(&array);
 	check_move(&array);
+	check_store_iter(&array);
 
 	printk("XArray: %u of %u tests passed\n", tests_passed, tests_run);
 	return (tests_run != tests_passed) ? 0 : -EINVAL;
diff --git a/lib/xarray.c b/lib/xarray.c
index ab1b6786711e..31c5332c8146 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1086,6 +1086,67 @@ void *xas_find_tagged(struct xa_state *xas, unsigned long max, xa_tag_t tag)
 }
 EXPORT_SYMBOL_GPL(xas_find_tagged);
 
+/**
+ * xas_next_conflict() - Step for xas_for_each_conflict().
+ * @xas: XArray operation state.
+ *
+ * This function does the work for xas_for_each_conflict().
+ *
+ * Context: Any context.  Expects xa_lock to be held.
+ * Return: The next entry in the range covered by @xas or %NULL.
+ */
+void *xas_next_conflict(struct xa_state *xas)
+{
+	void *curr;
+
+	if (xas_error(xas))
+		return NULL;
+
+	if (!xas->xa_node)
+		return NULL;
+
+	if (xas_top(xas->xa_node)) {
+		curr = xas_start(xas);
+		if (!curr)
+			return NULL;
+		while (xa_is_node(curr)) {
+			struct xa_node *node = xa_to_node(curr);
+			curr = xas_descend(xas, node);
+		}
+		if (curr)
+			return curr;
+	}
+
+	if (xas->xa_node->shift > xas->xa_shift)
+		return NULL;
+
+	for (;;) {
+		if (xas->xa_node->shift == xas->xa_shift) {
+			if ((xas->xa_offset & xas->xa_sibs) == xas->xa_sibs)
+				break;
+		} else if (xas->xa_offset == XA_CHUNK_MASK) {
+			xas->xa_offset = xas->xa_node->offset;
+			xas->xa_node = xas->xa_node->parent;
+			if (!xas->xa_node)
+				break;
+			continue;
+		}
+		curr = xa_entry_locked(xas->xa, xas->xa_node, ++xas->xa_offset);
+		if (xa_is_sibling(curr))
+			continue;
+		while (xa_is_node(curr)) {
+			xas->xa_node = xa_to_node(curr);
+			xas->xa_offset = 0;
+			curr = xa_entry_locked(xas->xa, xas->xa_node, 0);
+		}
+		if (curr)
+			return curr;
+	}
+	xas->xa_offset -= xas->xa_sibs;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xas_next_conflict);
+
 /**
  * xa_init_flags() - Initialise an empty XArray with flags.
  * @xa: XArray.
-- 
2.17.1
