Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 639FA6B02C3
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:49:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s21so6259979pfm.15
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:49:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q5-v6si7120266pll.348.2018.03.29.20.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 20:42:54 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v10 12/62] xarray: Add xa_extract
Date: Thu, 29 Mar 2018 20:41:55 -0700
Message-Id: <20180330034245.10462-13-willy@infradead.org>
In-Reply-To: <20180330034245.10462-1-willy@infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This function combines the functionality of radix_tree_gang_lookup() and
radix_tree_gang_lookup_tagged().  It extracts entries matching the
specified filter into a normal array.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  2 ++
 lib/xarray.c           | 80 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index c8b3645c6760..864f16660785 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -227,6 +227,8 @@ void *xa_find(struct xarray *xa, unsigned long *index,
 		unsigned long max, xa_tag_t) __attribute__((nonnull(2)));
 void *xa_find_after(struct xarray *xa, unsigned long *index,
 		unsigned long max, xa_tag_t) __attribute__((nonnull(2)));
+unsigned int xa_extract(struct xarray *, void **dst, unsigned long start,
+		unsigned long max, unsigned int n, xa_tag_t);
 
 /**
  * xa_init() - Initialise an empty XArray.
diff --git a/lib/xarray.c b/lib/xarray.c
index 73cf4c984c2d..77133bc5419f 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1402,6 +1402,86 @@ void *xa_find_after(struct xarray *xa, unsigned long *indexp,
 }
 EXPORT_SYMBOL(xa_find_after);
 
+static unsigned int xas_extract_present(struct xa_state *xas, void **dst,
+			unsigned long max, unsigned int n)
+{
+	void *entry;
+	unsigned int i = 0;
+
+	rcu_read_lock();
+	xas_for_each(xas, entry, max) {
+		if (xas_retry(xas, entry))
+			continue;
+		dst[i++] = entry;
+		if (i == n)
+			break;
+	}
+	rcu_read_unlock();
+
+	return i;
+}
+
+static unsigned int xas_extract_tag(struct xa_state *xas, void **dst,
+			unsigned long max, unsigned int n, xa_tag_t tag)
+{
+	void *entry;
+	unsigned int i = 0;
+
+	rcu_read_lock();
+	xas_for_each_tag(xas, entry, max, tag) {
+		if (xas_retry(xas, entry))
+			continue;
+		dst[i++] = entry;
+		if (i == n)
+			break;
+	}
+	rcu_read_unlock();
+
+	return i;
+}
+
+/**
+ * xa_extract() - Copy selected entries from the XArray into a normal array.
+ * @xa: The source XArray to copy from.
+ * @dst: The buffer to copy entries into.
+ * @start: The first index in the XArray eligible to be selected.
+ * @max: The last index in the XArray eligible to be selected.
+ * @n: The maximum number of entries to copy.
+ * @filter: Selection criterion.
+ *
+ * Copies up to @n entries that match @filter from the XArray.  The
+ * copied entries will have indices between @start and @max, inclusive.
+ *
+ * The @filter may be an XArray tag value, in which case entries which are
+ * tagged with that tag will be copied.  It may also be %XA_PRESENT, in
+ * which case non-NULL entries will be copied.
+ *
+ * The entries returned may not represent a snapshot of the XArray at a
+ * moment in time.  For example, if another thread stores to index 5, then
+ * index 10, calling xa_extract() may return the old contents of index 5
+ * and the new contents of index 10.  Indices not modified while this
+ * function is running will not be skipped.
+ *
+ * If you need stronger guarantees, holding the xa_lock across calls to this
+ * function will prevent concurrent modification.
+ *
+ * Context: Any context.  Takes and releases the RCU lock.
+ * Return: The number of entries copied.
+ */
+unsigned int xa_extract(struct xarray *xa, void **dst, unsigned long start,
+			unsigned long max, unsigned int n, xa_tag_t filter)
+{
+	XA_STATE(xas, xa, start);
+
+	if (!n)
+		return 0;
+
+	if ((__force unsigned int)filter < XA_MAX_TAGS)
+		return xas_extract_tag(&xas, dst, max, n, filter);
+	return xas_extract_present(&xas, dst, max, n);
+}
+EXPORT_SYMBOL(xa_extract);
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
-- 
2.16.2
