Date: Mon, 19 Mar 2007 10:30:08 +1100
From: David Chinner <dgc@sgi.com>
Subject: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
Message-ID: <20070318233008.GA32597093@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Generic page_mkwrite functionality.

Filesystems that make use of the VM ->page_mkwrite() callout will generally use
the same core code to implement it. There are several tricky truncate-related
issues that we need to deal with here as we cannot take the i_mutex as we
normally would for these paths.  These issues are not documented anywhere yet
so block_page_mkwrite() seems like the best place to start.

Version 2:

- read inode size only once
- more comments explaining implementation restrictions

Signed-Off-By: Dave Chinner <dgc@sgi.com>

---
 fs/buffer.c                 |   47 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/buffer_head.h |    2 +
 2 files changed, 49 insertions(+)

Index: 2.6.x-xfs-new/fs/buffer.c
===================================================================
--- 2.6.x-xfs-new.orig/fs/buffer.c	2007-03-17 10:55:32.291414968 +1100
+++ 2.6.x-xfs-new/fs/buffer.c	2007-03-19 08:13:54.519909087 +1100
@@ -2194,6 +2194,52 @@ int generic_commit_write(struct file *fi
 	return 0;
 }
 
+/*
+ * block_page_mkwrite() is not allowed to change the file size as it gets
+ * called from a page fault handler when a page is first dirtied. Hence we must
+ * be careful to check for EOF conditions here. We set the page up correctly
+ * for a written page which means we get ENOSPC checking when writing into
+ * holes and correct delalloc and unwritten extent mapping on filesystems that
+ * support these features.
+ *
+ * We are not allowed to take the i_mutex here so we have to play games to
+ * protect against truncate races as the page could now be beyond EOF.  Because
+ * vmtruncate() writes the inode size before removing pages, once we have the
+ * page lock we can determine safely if the page is beyond EOF. If it is not
+ * beyond EOF, then the page is guaranteed safe against truncation until we
+ * unlock the page.
+ */
+int
+block_page_mkwrite(struct vm_area_struct *vma, struct page *page,
+		   get_block_t get_block)
+{
+	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
+	unsigned long end;
+	loff_t size;
+	int ret = -EINVAL;
+
+	lock_page(page);
+	size = i_size_read(inode);
+	if ((page->mapping != inode->i_mapping) ||
+	    ((page->index << PAGE_CACHE_SHIFT) > size)) {
+		/* page got truncated out from underneath us */
+		goto out_unlock;
+	}
+
+	/* page is wholly or partially inside EOF */
+	if (((page->index + 1) << PAGE_CACHE_SHIFT) > size)
+		end = size & ~PAGE_CACHE_MASK;
+	else
+		end = PAGE_CACHE_SIZE;
+
+	ret = block_prepare_write(page, 0, end, get_block);
+	if (!ret)
+		ret = block_commit_write(page, 0, end);
+
+out_unlock:
+	unlock_page(page);
+	return ret;
+}
 
 /*
  * nobh_prepare_write()'s prereads are special: the buffer_heads are freed
@@ -2997,6 +3043,7 @@ EXPORT_SYMBOL(__brelse);
 EXPORT_SYMBOL(__wait_on_buffer);
 EXPORT_SYMBOL(block_commit_write);
 EXPORT_SYMBOL(block_prepare_write);
+EXPORT_SYMBOL(block_page_mkwrite);
 EXPORT_SYMBOL(block_read_full_page);
 EXPORT_SYMBOL(block_sync_page);
 EXPORT_SYMBOL(block_truncate_page);
Index: 2.6.x-xfs-new/include/linux/buffer_head.h
===================================================================
--- 2.6.x-xfs-new.orig/include/linux/buffer_head.h	2007-03-17 10:55:32.135435539 +1100
+++ 2.6.x-xfs-new/include/linux/buffer_head.h	2007-03-17 10:55:32.567378573 +1100
@@ -206,6 +206,8 @@ int cont_prepare_write(struct page*, uns
 int generic_cont_expand(struct inode *inode, loff_t size);
 int generic_cont_expand_simple(struct inode *inode, loff_t size);
 int block_commit_write(struct page *page, unsigned from, unsigned to);
+int block_page_mkwrite(struct vm_area_struct *vma, struct page *page,
+				get_block_t get_block);
 void block_sync_page(struct page *);
 sector_t generic_block_bmap(struct address_space *, sector_t, get_block_t *);
 int generic_commit_write(struct file *, struct page *, unsigned, unsigned);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
