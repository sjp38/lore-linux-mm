Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 40FDC6B0039
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:04 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 04/13] mm: PRAM: implement byte stream operations
Date: Mon, 1 Jul 2013 15:57:39 +0400
Message-ID: <65bcf77aad13e514e805dd3e26a479ad42ce93c7.1372582755.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

This patch adds ability to save arbitrary byte strings to PRAM using
pram_write() to be restored later using pram_read(). These two
operations are implemented on top of pram_save_page() and
pram_load_page() respectively.
---
 include/linux/pram.h |    4 +++
 mm/pram.c            |   86 ++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 88 insertions(+), 2 deletions(-)

diff --git a/include/linux/pram.h b/include/linux/pram.h
index dd17316..61c536c 100644
--- a/include/linux/pram.h
+++ b/include/linux/pram.h
@@ -13,6 +13,10 @@ struct pram_stream {
 	struct pram_node *node;
 	struct pram_link *link;		/* current link */
 	unsigned int page_index;	/* next page index in link */
+
+	/* byte-stream specific */
+	struct page *data_page;
+	unsigned int data_offset;
 };
 
 #define PRAM_NAME_MAX		256	/* including nul */
diff --git a/mm/pram.c b/mm/pram.c
index a443eb0..f7eebe1 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -1,5 +1,6 @@
 #include <linux/err.h>
 #include <linux/gfp.h>
+#include <linux/highmem.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/mm.h>
@@ -46,6 +47,7 @@ struct pram_link {
 struct pram_node {
 	__u32	flags;		/* see PRAM_* flags below */
 	__u32	type;		/* data type, see enum pram_stream_type */
+	__u64	data_len;	/* data size, only for byte streams */
 	__u64	link_pfn;	/* points to the first link of the node */
 
 	__u8	name[PRAM_NAME_MAX];
@@ -284,6 +286,9 @@ void pram_finish_load(struct pram_stream *ps)
 
 	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_LOAD);
 
+	if (ps->data_page)
+		put_page(ps->data_page);
+
 	pram_truncate_node(node);
 	pram_free_page(node);
 }
@@ -422,10 +427,51 @@ struct page *pram_load_page(struct pram_stream *ps, int *flags)
  *
  * On success, returns the number of bytes written, which is always equal to
  * @count. On failure, -errno is returned.
+ *
+ * Error values:
+ *    %ENOMEM: insufficient amount of memory available
  */
 ssize_t pram_write(struct pram_stream *ps, const void *buf, size_t count)
 {
-	return -ENOSYS;
+	void *addr;
+	size_t copy_count, write_count = 0;
+	struct pram_node *node = ps->node;
+
+	BUG_ON(node->type != PRAM_BYTE_STREAM);
+	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_SAVE);
+
+	while (count > 0) {
+		if (!ps->data_page) {
+			struct page *page;
+			int err;
+
+			page = pram_alloc_page((ps->gfp_mask & GFP_RECLAIM_MASK) |
+					       __GFP_HIGHMEM | __GFP_ZERO);
+			if (!page)
+				return -ENOMEM;
+			err = __pram_save_page(ps, page, 0);
+			put_page(page);
+			if (err)
+				return err;
+			ps->data_page = page;
+			ps->data_offset = 0;
+		}
+
+		copy_count = min_t(size_t, count, PAGE_SIZE - ps->data_offset);
+		addr = kmap_atomic(ps->data_page);
+		memcpy(addr + ps->data_offset, buf, copy_count);
+		kunmap_atomic(addr);
+
+		buf += copy_count;
+		node->data_len += copy_count;
+		ps->data_offset += copy_count;
+		if (ps->data_offset >= PAGE_SIZE)
+			ps->data_page = NULL;
+
+		write_count += copy_count;
+		count -= copy_count;
+	}
+	return write_count;
 }
 
 /**
@@ -437,5 +483,41 @@ ssize_t pram_write(struct pram_stream *ps, const void *buf, size_t count)
  */
 size_t pram_read(struct pram_stream *ps, void *buf, size_t count)
 {
-	return 0;
+	char *addr;
+	size_t copy_count, read_count = 0;
+	struct pram_node *node = ps->node;
+
+	BUG_ON(node->type != PRAM_BYTE_STREAM);
+	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_LOAD);
+
+	while (count > 0 && node->data_len > 0) {
+		if (!ps->data_page) {
+			struct page *page;
+
+			page = __pram_load_page(ps, NULL);
+			if (!page)
+				break;
+			ps->data_page = page;
+			ps->data_offset = 0;
+		}
+
+		copy_count = min_t(size_t, count, PAGE_SIZE - ps->data_offset);
+		if (copy_count > node->data_len)
+			copy_count = node->data_len;
+		addr = kmap_atomic(ps->data_page);
+		memcpy(buf, addr + ps->data_offset, copy_count);
+		kunmap_atomic(addr);
+
+		buf += copy_count;
+		node->data_len -= copy_count;
+		ps->data_offset += copy_count;
+		if (ps->data_offset >= PAGE_SIZE || !node->data_len) {
+			put_page(ps->data_page);
+			ps->data_page = NULL;
+		}
+
+		read_count += copy_count;
+		count -= copy_count;
+	}
+	return read_count;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
