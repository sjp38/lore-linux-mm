Date: Wed, 7 Feb 2007 23:55:27 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH 1 of 2] Implement generic block_page_mkwrite() functionality
Message-ID: <20070207125527.GM44411608@melbourne.sgi.com>
References: <20070207124922.GK44411608@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070207124922.GK44411608@melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mental Note: must remember to refresh patch after fixing compile
errors. New patch attached.

-

On Christoph's suggestion, take the guts of the proposed
xfs_vm_page_mkwrite function and implement it as a generic
core function as it used no specific XFS code at all.

This allows any filesystem to easily hook the ->page_mkwrite()
VM callout to allow them to set up pages dirtied by mmap
writes correctly for later writeout.

Signed-Off-By: Dave Chinner <dgc@sgi.com>


---
 fs/buffer.c                 |   30 ++++++++++++++++++++++++++++++
 include/linux/buffer_head.h |    2 ++
 2 files changed, 32 insertions(+)

Index: 2.6.x-xfs-new/fs/buffer.c
===================================================================
--- 2.6.x-xfs-new.orig/fs/buffer.c	2007-02-07 23:00:05.000000000 +1100
+++ 2.6.x-xfs-new/fs/buffer.c	2007-02-07 23:09:47.642356116 +1100
@@ -2194,6 +2194,36 @@ int generic_commit_write(struct file *fi
 	return 0;
 }
 
+/*
+ * block_page_mkwrite() is not allowed to change the file size as
+ * it gets called from a page fault handler when a page is first
+ * dirtied. Hence we must be careful to check for EOF conditions
+ * here. We set the page up correctly for a written page which means
+ * we get ENOSPC checking when writing into holes and correct
+ * delalloc and unwritten extent mapping on filesystems that support
+ * these features.
+ */
+int
+block_page_mkwrite(struct vm_area_struct *vma, struct page *page,
+		   get_block_t get_block)
+{
+	struct inode	*inode = vma->vm_file->f_path.dentry->d_inode;
+	unsigned long	end;
+	int		ret = 0;
+
+	if (((page->index + 1) << PAGE_CACHE_SHIFT) > i_size_read(inode))
+		end = i_size_read(inode) & ~PAGE_CACHE_MASK;
+	else
+		end = PAGE_CACHE_SIZE;
+
+	lock_page(page);
+	ret = block_prepare_write(page, 0, end, get_block);
+	if (!ret)
+		ret = block_commit_write(page, 0, end);
+	unlock_page(page);
+
+	return ret;
+}
 
 /*
  * nobh_prepare_write()'s prereads are special: the buffer_heads are freed
Index: 2.6.x-xfs-new/include/linux/buffer_head.h
===================================================================
--- 2.6.x-xfs-new.orig/include/linux/buffer_head.h	2007-02-07 23:00:02.000000000 +1100
+++ 2.6.x-xfs-new/include/linux/buffer_head.h	2007-02-07 23:19:25.110816993 +1100
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
