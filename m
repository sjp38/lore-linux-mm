Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id AA3C46B0034
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 15:44:14 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id 5so3616104pdd.6
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 12:44:13 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [RFC 2/3] fs: Add block_willwrite
Date: Mon,  5 Aug 2013 12:44:00 -0700
Message-Id: <50d921ff5d6fcb1a5da59b4bdb755e886cecab1f.1375729665.git.luto@amacapital.net>
In-Reply-To: <cover.1375729665.git.luto@amacapital.net>
References: <cover.1375729665.git.luto@amacapital.net>
In-Reply-To: <cover.1375729665.git.luto@amacapital.net>
References: <cover.1375729665.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

This provides generic support for MADV_WILLWRITE.  It creates and maps
buffer heads, but it should not result in anything being marked dirty.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

As described in the 0/0 summary, this may have issues.

 fs/buffer.c                 | 57 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/buffer_head.h |  3 +++
 2 files changed, 60 insertions(+)

diff --git a/fs/buffer.c b/fs/buffer.c
index 4d74335..017e822 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2444,6 +2444,63 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 }
 EXPORT_SYMBOL(block_page_mkwrite);
 
+long block_willwrite(struct vm_area_struct *vma,
+		     unsigned long start, unsigned long end,
+		     get_block_t get_block)
+{
+	long ret = 0;
+	loff_t size;
+	struct inode *inode = file_inode(vma->vm_file);
+	struct super_block *sb = inode->i_sb;
+
+	for (; start < end; start += PAGE_CACHE_SIZE) {
+		struct page *p;
+		int size_in_page;
+		int tmp = get_user_pages_fast(start, 1, 0, &p);
+		if (tmp == 0)
+			tmp = -EFAULT;
+		if (tmp != 1) {
+			ret = tmp;
+			break;
+		}
+
+		sb_start_pagefault(sb);
+
+		lock_page(p);
+		size = i_size_read(inode);
+		if (WARN_ON_ONCE(p->mapping != inode->i_mapping) ||
+		    (page_offset(p) > size)) {
+			ret = -EFAULT;  /* A real write would have failed. */
+			goto pagedone_unlock;
+		}
+
+		/* page is partially inside EOF? */
+		if (((p->index + 1) << PAGE_CACHE_SHIFT) > size)
+			size_in_page = size & ~PAGE_CACHE_MASK;
+		else
+			size_in_page = PAGE_CACHE_SIZE;
+
+		tmp = __block_write_begin(p, 0, size_in_page, get_block);
+		if (tmp) {
+			ret = tmp;
+			goto pagedone_unlock;
+		}
+
+		ret += PAGE_CACHE_SIZE;
+
+		/* No need to commit -- we're not writing anything yet. */
+
+	pagedone_unlock:
+		unlock_page(p);
+		sb_end_pagefault(sb);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(block_willwrite);
+
 /*
  * nobh_write_begin()'s prereads are special: the buffer_heads are freed
  * immediately, while under the page lock.  So it needs a special end_io
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 91fa9a9..c84639d 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -230,6 +230,9 @@ int __block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 				get_block_t get_block);
 int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 				get_block_t get_block);
+long block_willwrite(struct vm_area_struct *vma,
+		     unsigned long start, unsigned long end,
+		     get_block_t get_block);
 /* Convert errno to return value from ->page_mkwrite() call */
 static inline int block_page_mkwrite_return(int err)
 {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
