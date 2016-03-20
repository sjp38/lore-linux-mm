Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4E27082F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:47 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 4so106657550pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ds16si10308712pac.149.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 24/71] ceph: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:31 +0300
Message-Id: <1458499278-1516-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: "Yan, Zheng" <zyan@redhat.com>
Cc: Sage Weil <sage@redhat.com>
---
 fs/ceph/addr.c               | 106 +++++++++++++++++++++----------------------
 fs/ceph/caps.c               |   2 +-
 fs/ceph/dir.c                |   4 +-
 fs/ceph/file.c               |  32 ++++++-------
 fs/ceph/inode.c              |   4 +-
 fs/ceph/mds_client.c         |   2 +-
 fs/ceph/mds_client.h         |   2 +-
 fs/ceph/super.c              |   8 ++--
 include/linux/ceph/libceph.h |   4 +-
 net/ceph/messenger.c         |   6 +--
 net/ceph/pagelist.c          |   4 +-
 net/ceph/pagevec.c           |  30 ++++++------
 12 files changed, 102 insertions(+), 102 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 19adeb0ef82a..355e2bc794cd 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -143,7 +143,7 @@ static void ceph_invalidatepage(struct page *page, unsigned int offset,
 	inode = page->mapping->host;
 	ci = ceph_inode(inode);
 
-	if (offset != 0 || length != PAGE_CACHE_SIZE) {
+	if (offset != 0 || length != PAGE_SIZE) {
 		dout("%p invalidatepage %p idx %lu partial dirty page %u~%u\n",
 		     inode, page, page->index, offset, length);
 		return;
@@ -197,10 +197,10 @@ static int readpage_nounlock(struct file *filp, struct page *page)
 		&ceph_inode_to_client(inode)->client->osdc;
 	int err = 0;
 	u64 off = page_offset(page);
-	u64 len = PAGE_CACHE_SIZE;
+	u64 len = PAGE_SIZE;
 
 	if (off >= i_size_read(inode)) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		return 0;
 	}
@@ -212,7 +212,7 @@ static int readpage_nounlock(struct file *filp, struct page *page)
 		 */
 		if (off == 0)
 			return -EINVAL;
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		return 0;
 	}
@@ -234,9 +234,9 @@ static int readpage_nounlock(struct file *filp, struct page *page)
 		ceph_fscache_readpage_cancel(inode, page);
 		goto out;
 	}
-	if (err < PAGE_CACHE_SIZE)
+	if (err < PAGE_SIZE)
 		/* zero fill remainder of page */
-		zero_user_segment(page, err, PAGE_CACHE_SIZE);
+		zero_user_segment(page, err, PAGE_SIZE);
 	else
 		flush_dcache_page(page);
 
@@ -278,10 +278,10 @@ static void finish_read(struct ceph_osd_request *req, struct ceph_msg *msg)
 
 		if (rc < 0 && rc != ENOENT)
 			goto unlock;
-		if (bytes < (int)PAGE_CACHE_SIZE) {
+		if (bytes < (int)PAGE_SIZE) {
 			/* zero (remainder of) page */
 			int s = bytes < 0 ? 0 : bytes;
-			zero_user_segment(page, s, PAGE_CACHE_SIZE);
+			zero_user_segment(page, s, PAGE_SIZE);
 		}
  		dout("finish_read %p uptodate %p idx %lu\n", inode, page,
 		     page->index);
@@ -290,8 +290,8 @@ static void finish_read(struct ceph_osd_request *req, struct ceph_msg *msg)
 		ceph_readpage_to_fscache(inode, page);
 unlock:
 		unlock_page(page);
-		page_cache_release(page);
-		bytes -= PAGE_CACHE_SIZE;
+		put_page(page);
+		bytes -= PAGE_SIZE;
 	}
 	kfree(osd_data->pages);
 }
@@ -336,7 +336,7 @@ static int start_read(struct inode *inode, struct list_head *page_list, int max)
 		if (max && nr_pages == max)
 			break;
 	}
-	len = nr_pages << PAGE_CACHE_SHIFT;
+	len = nr_pages << PAGE_SHIFT;
 	dout("start_read %p nr_pages %d is %lld~%lld\n", inode, nr_pages,
 	     off, len);
 	vino = ceph_vino(inode);
@@ -364,7 +364,7 @@ static int start_read(struct inode *inode, struct list_head *page_list, int max)
 		if (add_to_page_cache_lru(page, &inode->i_data, page->index,
 					  GFP_KERNEL)) {
 			ceph_fscache_uncache_page(inode, page);
-			page_cache_release(page);
+			put_page(page);
 			dout("start_read %p add_to_page_cache failed %p\n",
 			     inode, page);
 			nr_pages = i;
@@ -415,8 +415,8 @@ static int ceph_readpages(struct file *file, struct address_space *mapping,
 	if (rc == 0)
 		goto out;
 
-	if (fsc->mount_options->rsize >= PAGE_CACHE_SIZE)
-		max = (fsc->mount_options->rsize + PAGE_CACHE_SIZE - 1)
+	if (fsc->mount_options->rsize >= PAGE_SIZE)
+		max = (fsc->mount_options->rsize + PAGE_SIZE - 1)
 			>> PAGE_SHIFT;
 
 	dout("readpages %p file %p nr_pages %d max %d\n", inode,
@@ -484,7 +484,7 @@ static int writepage_nounlock(struct page *page, struct writeback_control *wbc)
 	long writeback_stat;
 	u64 truncate_size;
 	u32 truncate_seq;
-	int err = 0, len = PAGE_CACHE_SIZE;
+	int err = 0, len = PAGE_SIZE;
 
 	dout("writepage %p idx %lu\n", page, page->index);
 
@@ -725,9 +725,9 @@ static int ceph_writepages_start(struct address_space *mapping,
 	}
 	if (fsc->mount_options->wsize && fsc->mount_options->wsize < wsize)
 		wsize = fsc->mount_options->wsize;
-	if (wsize < PAGE_CACHE_SIZE)
-		wsize = PAGE_CACHE_SIZE;
-	max_pages_ever = wsize >> PAGE_CACHE_SHIFT;
+	if (wsize < PAGE_SIZE)
+		wsize = PAGE_SIZE;
+	max_pages_ever = wsize >> PAGE_SHIFT;
 
 	pagevec_init(&pvec, 0);
 
@@ -737,8 +737,8 @@ static int ceph_writepages_start(struct address_space *mapping,
 		end = -1;
 		dout(" cyclic, start at %lu\n", start);
 	} else {
-		start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		start = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		should_loop = 0;
@@ -953,14 +953,14 @@ get_more_pages:
 
 		/* Format the osd request message and submit the write */
 		offset = page_offset(pages[0]);
-		len = (u64)locked_pages << PAGE_CACHE_SHIFT;
+		len = (u64)locked_pages << PAGE_SHIFT;
 		if (snap_size == -1) {
 			len = min(len, (u64)i_size_read(inode) - offset);
 			 /* writepages_finish() clears writeback pages
 			  * according to the data length, so make sure
 			  * data length covers all locked pages */
 			len = max(len, 1 +
-				((u64)(locked_pages - 1) << PAGE_CACHE_SHIFT));
+				((u64)(locked_pages - 1) << PAGE_SHIFT));
 		} else {
 			len = min(len, snap_size - offset);
 		}
@@ -1048,8 +1048,8 @@ static int ceph_update_writeable_page(struct file *file,
 {
 	struct inode *inode = file_inode(file);
 	struct ceph_inode_info *ci = ceph_inode(inode);
-	loff_t page_off = pos & PAGE_CACHE_MASK;
-	int pos_in_page = pos & ~PAGE_CACHE_MASK;
+	loff_t page_off = pos & PAGE_MASK;
+	int pos_in_page = pos & ~PAGE_MASK;
 	int end_in_page = pos_in_page + len;
 	loff_t i_size;
 	int r;
@@ -1104,7 +1104,7 @@ retry_locked:
 	}
 
 	/* full page? */
-	if (pos_in_page == 0 && len == PAGE_CACHE_SIZE)
+	if (pos_in_page == 0 && len == PAGE_SIZE)
 		return 0;
 
 	/* past end of file? */
@@ -1112,12 +1112,12 @@ retry_locked:
 
 	if (page_off >= i_size ||
 	    (pos_in_page == 0 && (pos+len) >= i_size &&
-	     end_in_page - pos_in_page != PAGE_CACHE_SIZE)) {
+	     end_in_page - pos_in_page != PAGE_SIZE)) {
 		dout(" zeroing %p 0 - %d and %d - %d\n",
-		     page, pos_in_page, end_in_page, (int)PAGE_CACHE_SIZE);
+		     page, pos_in_page, end_in_page, (int)PAGE_SIZE);
 		zero_user_segments(page,
 				   0, pos_in_page,
-				   end_in_page, PAGE_CACHE_SIZE);
+				   end_in_page, PAGE_SIZE);
 		return 0;
 	}
 
@@ -1141,7 +1141,7 @@ static int ceph_write_begin(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = file_inode(file);
 	struct page *page;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	int r;
 
 	do {
@@ -1155,7 +1155,7 @@ static int ceph_write_begin(struct file *file, struct address_space *mapping,
 
 		r = ceph_update_writeable_page(file, pos, len, page);
 		if (r < 0)
-			page_cache_release(page);
+			put_page(page);
 		else
 			*pagep = page;
 	} while (r == -EAGAIN);
@@ -1172,7 +1172,7 @@ static int ceph_write_end(struct file *file, struct address_space *mapping,
 			  struct page *page, void *fsdata)
 {
 	struct inode *inode = file_inode(file);
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	int check_cap = 0;
 
 	dout("write_end file %p inode %p page %p %d~%d (%d)\n", file,
@@ -1192,7 +1192,7 @@ static int ceph_write_end(struct file *file, struct address_space *mapping,
 	set_page_dirty(page);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (check_cap)
 		ceph_check_caps(ceph_inode(inode), CHECK_CAPS_AUTHONLY, NULL);
@@ -1235,11 +1235,11 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_file_info *fi = vma->vm_file->private_data;
 	struct page *pinned_page = NULL;
-	loff_t off = vmf->pgoff << PAGE_CACHE_SHIFT;
+	loff_t off = vmf->pgoff << PAGE_SHIFT;
 	int want, got, ret;
 
 	dout("filemap_fault %p %llx.%llx %llu~%zd trying to get caps\n",
-	     inode, ceph_vinop(inode), off, (size_t)PAGE_CACHE_SIZE);
+	     inode, ceph_vinop(inode), off, (size_t)PAGE_SIZE);
 	if (fi->fmode & CEPH_FILE_MODE_LAZY)
 		want = CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LAZYIO;
 	else
@@ -1256,7 +1256,7 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		}
 	}
 	dout("filemap_fault %p %llu~%zd got cap refs on %s\n",
-	     inode, off, (size_t)PAGE_CACHE_SIZE, ceph_cap_string(got));
+	     inode, off, (size_t)PAGE_SIZE, ceph_cap_string(got));
 
 	if ((got & (CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LAZYIO)) ||
 	    ci->i_inline_version == CEPH_INLINE_NONE)
@@ -1265,16 +1265,16 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		ret = -EAGAIN;
 
 	dout("filemap_fault %p %llu~%zd dropping cap refs on %s ret %d\n",
-	     inode, off, (size_t)PAGE_CACHE_SIZE, ceph_cap_string(got), ret);
+	     inode, off, (size_t)PAGE_SIZE, ceph_cap_string(got), ret);
 	if (pinned_page)
-		page_cache_release(pinned_page);
+		put_page(pinned_page);
 	ceph_put_cap_refs(ci, got);
 
 	if (ret != -EAGAIN)
 		return ret;
 
 	/* read inline data */
-	if (off >= PAGE_CACHE_SIZE) {
+	if (off >= PAGE_SIZE) {
 		/* does not support inline data > PAGE_SIZE */
 		ret = VM_FAULT_SIGBUS;
 	} else {
@@ -1291,12 +1291,12 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 					 CEPH_STAT_CAP_INLINE_DATA, true);
 		if (ret1 < 0 || off >= i_size_read(inode)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			ret = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		if (ret1 < PAGE_CACHE_SIZE)
-			zero_user_segment(page, ret1, PAGE_CACHE_SIZE);
+		if (ret1 < PAGE_SIZE)
+			zero_user_segment(page, ret1, PAGE_SIZE);
 		else
 			flush_dcache_page(page);
 		SetPageUptodate(page);
@@ -1305,7 +1305,7 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 out:
 	dout("filemap_fault %p %llu~%zd read inline data ret %d\n",
-	     inode, off, (size_t)PAGE_CACHE_SIZE, ret);
+	     inode, off, (size_t)PAGE_SIZE, ret);
 	return ret;
 }
 
@@ -1343,10 +1343,10 @@ static int ceph_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		}
 	}
 
-	if (off + PAGE_CACHE_SIZE <= size)
-		len = PAGE_CACHE_SIZE;
+	if (off + PAGE_SIZE <= size)
+		len = PAGE_SIZE;
 	else
-		len = size & ~PAGE_CACHE_MASK;
+		len = size & ~PAGE_MASK;
 
 	dout("page_mkwrite %p %llx.%llx %llu~%zd getting caps i_size %llu\n",
 	     inode, ceph_vinop(inode), off, len, size);
@@ -1432,7 +1432,7 @@ void ceph_fill_inline_data(struct inode *inode, struct page *locked_page,
 			return;
 		if (PageUptodate(page)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			return;
 		}
 	}
@@ -1447,14 +1447,14 @@ void ceph_fill_inline_data(struct inode *inode, struct page *locked_page,
 	}
 
 	if (page != locked_page) {
-		if (len < PAGE_CACHE_SIZE)
-			zero_user_segment(page, len, PAGE_CACHE_SIZE);
+		if (len < PAGE_SIZE)
+			zero_user_segment(page, len, PAGE_SIZE);
 		else
 			flush_dcache_page(page);
 
 		SetPageUptodate(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
@@ -1491,7 +1491,7 @@ int ceph_uninline_data(struct file *filp, struct page *locked_page)
 				from_pagecache = true;
 				lock_page(page);
 			} else {
-				page_cache_release(page);
+				put_page(page);
 				page = NULL;
 			}
 		}
@@ -1499,8 +1499,8 @@ int ceph_uninline_data(struct file *filp, struct page *locked_page)
 
 	if (page) {
 		len = i_size_read(inode);
-		if (len > PAGE_CACHE_SIZE)
-			len = PAGE_CACHE_SIZE;
+		if (len > PAGE_SIZE)
+			len = PAGE_SIZE;
 	} else {
 		page = __page_cache_alloc(GFP_NOFS);
 		if (!page) {
@@ -1584,7 +1584,7 @@ out:
 	if (page && page != locked_page) {
 		if (from_pagecache) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		} else
 			__free_pages(page, 0);
 	}
diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index 6fe0ad26a7df..835b1d9a8873 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -2507,7 +2507,7 @@ int ceph_get_caps(struct ceph_inode_info *ci, int need, int want,
 					*pinned_page = page;
 					break;
 				}
-				page_cache_release(page);
+				put_page(page);
 			}
 			/*
 			 * drop cap refs first because getattr while
diff --git a/fs/ceph/dir.c b/fs/ceph/dir.c
index fd11fb231a2e..b91369988eaa 100644
--- a/fs/ceph/dir.c
+++ b/fs/ceph/dir.c
@@ -146,7 +146,7 @@ static int __dcache_readdir(struct file *file,  struct dir_context *ctx,
 	struct inode *dir = d_inode(parent);
 	struct dentry *dentry, *last = NULL;
 	struct ceph_dentry_info *di;
-	unsigned nsize = PAGE_CACHE_SIZE / sizeof(struct dentry *);
+	unsigned nsize = PAGE_SIZE / sizeof(struct dentry *);
 	int err = 0;
 	loff_t ptr_pos = 0;
 	struct ceph_readdir_cache_control cache_ctl = {};
@@ -171,7 +171,7 @@ static int __dcache_readdir(struct file *file,  struct dir_context *ctx,
 		}
 
 		err = -EAGAIN;
-		pgoff = ptr_pos >> PAGE_CACHE_SHIFT;
+		pgoff = ptr_pos >> PAGE_SHIFT;
 		if (!cache_ctl.page || pgoff != page_index(cache_ctl.page)) {
 			ceph_readdir_cache_release(&cache_ctl);
 			cache_ctl.page = find_lock_page(&dir->i_data, pgoff);
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index eb9028e8cfc5..04040daaf5f1 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -459,7 +459,7 @@ more:
 			ret += zlen;
 		}
 
-		didpages = (page_align + ret) >> PAGE_CACHE_SHIFT;
+		didpages = (page_align + ret) >> PAGE_SHIFT;
 		pos += ret;
 		read = pos - off;
 		left -= ret;
@@ -800,8 +800,8 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 
 	if (write) {
 		ret = invalidate_inode_pages2_range(inode->i_mapping,
-					pos >> PAGE_CACHE_SHIFT,
-					(pos + count) >> PAGE_CACHE_SHIFT);
+					pos >> PAGE_SHIFT,
+					(pos + count) >> PAGE_SHIFT);
 		if (ret < 0)
 			dout("invalidate_inode_pages2_range returned %d\n", ret);
 
@@ -866,7 +866,7 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 			 * may block.
 			 */
 			truncate_inode_pages_range(inode->i_mapping, pos,
-					(pos+len) | (PAGE_CACHE_SIZE - 1));
+					(pos+len) | (PAGE_SIZE - 1));
 
 			osd_req_op_init(req, 1, CEPH_OSD_OP_STARTSYNC, 0);
 		}
@@ -1001,8 +1001,8 @@ ceph_sync_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos,
 		return ret;
 
 	ret = invalidate_inode_pages2_range(inode->i_mapping,
-					    pos >> PAGE_CACHE_SHIFT,
-					    (pos + count) >> PAGE_CACHE_SHIFT);
+					    pos >> PAGE_SHIFT,
+					    (pos + count) >> PAGE_SHIFT);
 	if (ret < 0)
 		dout("invalidate_inode_pages2_range returned %d\n", ret);
 
@@ -1031,7 +1031,7 @@ ceph_sync_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos,
 		 * write from beginning of first page,
 		 * regardless of io alignment
 		 */
-		num_pages = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		num_pages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 		pages = ceph_alloc_page_vector(num_pages, GFP_KERNEL);
 		if (IS_ERR(pages)) {
@@ -1154,7 +1154,7 @@ again:
 	dout("aio_read %p %llx.%llx dropping cap refs on %s = %d\n",
 	     inode, ceph_vinop(inode), ceph_cap_string(got), (int)ret);
 	if (pinned_page) {
-		page_cache_release(pinned_page);
+		put_page(pinned_page);
 		pinned_page = NULL;
 	}
 	ceph_put_cap_refs(ci, got);
@@ -1183,10 +1183,10 @@ again:
 		if (retry_op == READ_INLINE) {
 			BUG_ON(ret > 0 || read > 0);
 			if (iocb->ki_pos < i_size &&
-			    iocb->ki_pos < PAGE_CACHE_SIZE) {
+			    iocb->ki_pos < PAGE_SIZE) {
 				loff_t end = min_t(loff_t, i_size,
 						   iocb->ki_pos + len);
-				end = min_t(loff_t, end, PAGE_CACHE_SIZE);
+				end = min_t(loff_t, end, PAGE_SIZE);
 				if (statret < end)
 					zero_user_segment(page, statret, end);
 				ret = copy_page_to_iter(page,
@@ -1458,21 +1458,21 @@ static inline void ceph_zero_partial_page(
 	struct inode *inode, loff_t offset, unsigned size)
 {
 	struct page *page;
-	pgoff_t index = offset >> PAGE_CACHE_SHIFT;
+	pgoff_t index = offset >> PAGE_SHIFT;
 
 	page = find_lock_page(inode->i_mapping, index);
 	if (page) {
 		wait_on_page_writeback(page);
-		zero_user(page, offset & (PAGE_CACHE_SIZE - 1), size);
+		zero_user(page, offset & (PAGE_SIZE - 1), size);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
 static void ceph_zero_pagecache_range(struct inode *inode, loff_t offset,
 				      loff_t length)
 {
-	loff_t nearly = round_up(offset, PAGE_CACHE_SIZE);
+	loff_t nearly = round_up(offset, PAGE_SIZE);
 	if (offset < nearly) {
 		loff_t size = nearly - offset;
 		if (length < size)
@@ -1481,8 +1481,8 @@ static void ceph_zero_pagecache_range(struct inode *inode, loff_t offset,
 		offset += size;
 		length -= size;
 	}
-	if (length >= PAGE_CACHE_SIZE) {
-		loff_t size = round_down(length, PAGE_CACHE_SIZE);
+	if (length >= PAGE_SIZE) {
+		loff_t size = round_down(length, PAGE_SIZE);
 		truncate_pagecache_range(inode, offset, offset + size - 1);
 		offset += size;
 		length -= size;
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index e48fd8b23257..d5572db245e5 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -1333,7 +1333,7 @@ void ceph_readdir_cache_release(struct ceph_readdir_cache_control *ctl)
 {
 	if (ctl->page) {
 		kunmap(ctl->page);
-		page_cache_release(ctl->page);
+		put_page(ctl->page);
 		ctl->page = NULL;
 	}
 }
@@ -1343,7 +1343,7 @@ static int fill_readdir_cache(struct inode *dir, struct dentry *dn,
 			      struct ceph_mds_request *req)
 {
 	struct ceph_inode_info *ci = ceph_inode(dir);
-	unsigned nsize = PAGE_CACHE_SIZE / sizeof(struct dentry*);
+	unsigned nsize = PAGE_SIZE / sizeof(struct dentry*);
 	unsigned idx = ctl->index % nsize;
 	pgoff_t pgoff = ctl->index / nsize;
 
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 911d64d865f1..859c0444d3b9 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -1610,7 +1610,7 @@ again:
 	while (!list_empty(&tmp_list)) {
 		if (!msg) {
 			msg = ceph_msg_new(CEPH_MSG_CLIENT_CAPRELEASE,
-					PAGE_CACHE_SIZE, GFP_NOFS, false);
+					PAGE_SIZE, GFP_NOFS, false);
 			if (!msg)
 				goto out_err;
 			head = msg->front.iov_base;
diff --git a/fs/ceph/mds_client.h b/fs/ceph/mds_client.h
index 37712ccffcc6..3a8408ccf337 100644
--- a/fs/ceph/mds_client.h
+++ b/fs/ceph/mds_client.h
@@ -97,7 +97,7 @@ struct ceph_mds_reply_info_parsed {
 /*
  * cap releases are batched and sent to the MDS en masse.
  */
-#define CEPH_CAPS_PER_RELEASE ((PAGE_CACHE_SIZE -			\
+#define CEPH_CAPS_PER_RELEASE ((PAGE_SIZE -				\
 				sizeof(struct ceph_mds_cap_release)) /	\
 			       sizeof(struct ceph_mds_cap_item))
 
diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index ca4d5e8457f1..98acbf7b3efc 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -560,7 +560,7 @@ static struct ceph_fs_client *create_fs_client(struct ceph_mount_options *fsopt,
 
 	/* set up mempools */
 	err = -ENOMEM;
-	page_count = fsc->mount_options->wsize >> PAGE_CACHE_SHIFT;
+	page_count = fsc->mount_options->wsize >> PAGE_SHIFT;
 	size = sizeof (struct page *) * (page_count ? page_count : 1);
 	fsc->wb_pagevec_pool = mempool_create_kmalloc_pool(10, size);
 	if (!fsc->wb_pagevec_pool)
@@ -915,13 +915,13 @@ static int ceph_register_bdi(struct super_block *sb,
 	int err;
 
 	/* set ra_pages based on rasize mount option? */
-	if (fsc->mount_options->rasize >= PAGE_CACHE_SIZE)
+	if (fsc->mount_options->rasize >= PAGE_SIZE)
 		fsc->backing_dev_info.ra_pages =
-			(fsc->mount_options->rasize + PAGE_CACHE_SIZE - 1)
+			(fsc->mount_options->rasize + PAGE_SIZE - 1)
 			>> PAGE_SHIFT;
 	else
 		fsc->backing_dev_info.ra_pages =
-			VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE;
+			VM_MAX_READAHEAD * 1024 / PAGE_SIZE;
 
 	err = bdi_register(&fsc->backing_dev_info, NULL, "ceph-%ld",
 			   atomic_long_inc_return(&bdi_seq));
diff --git a/include/linux/ceph/libceph.h b/include/linux/ceph/libceph.h
index 3e3799cdc6e6..9092a92400ac 100644
--- a/include/linux/ceph/libceph.h
+++ b/include/linux/ceph/libceph.h
@@ -172,8 +172,8 @@ extern void ceph_put_snap_context(struct ceph_snap_context *sc);
  */
 static inline int calc_pages_for(u64 off, u64 len)
 {
-	return ((off+len+PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT) -
-		(off >> PAGE_CACHE_SHIFT);
+	return ((off+len+PAGE_SIZE-1) >> PAGE_SHIFT) -
+		(off >> PAGE_SHIFT);
 }
 
 extern struct kmem_cache *ceph_inode_cachep;
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 9382619a405b..298770cf66e5 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -275,7 +275,7 @@ static void _ceph_msgr_exit(void)
 	}
 
 	BUG_ON(zero_page == NULL);
-	page_cache_release(zero_page);
+	put_page(zero_page);
 	zero_page = NULL;
 
 	ceph_msgr_slab_exit();
@@ -288,7 +288,7 @@ int ceph_msgr_init(void)
 
 	BUG_ON(zero_page != NULL);
 	zero_page = ZERO_PAGE(0);
-	page_cache_get(zero_page);
+	get_page(zero_page);
 
 	/*
 	 * The number of active work items is limited by the number of
@@ -1614,7 +1614,7 @@ static int write_partial_skip(struct ceph_connection *con)
 
 	dout("%s %p %d left\n", __func__, con, con->out_skip);
 	while (con->out_skip > 0) {
-		size_t size = min(con->out_skip, (int) PAGE_CACHE_SIZE);
+		size_t size = min(con->out_skip, (int) PAGE_SIZE);
 
 		ret = ceph_tcp_sendpage(con->sock, zero_page, 0, size, true);
 		if (ret <= 0)
diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index c7c220a736e5..6864007e64fc 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -56,7 +56,7 @@ int ceph_pagelist_append(struct ceph_pagelist *pl, const void *buf, size_t len)
 		size_t bit = pl->room;
 		int ret;
 
-		memcpy(pl->mapped_tail + (pl->length & ~PAGE_CACHE_MASK),
+		memcpy(pl->mapped_tail + (pl->length & ~PAGE_MASK),
 		       buf, bit);
 		pl->length += bit;
 		pl->room -= bit;
@@ -67,7 +67,7 @@ int ceph_pagelist_append(struct ceph_pagelist *pl, const void *buf, size_t len)
 			return ret;
 	}
 
-	memcpy(pl->mapped_tail + (pl->length & ~PAGE_CACHE_MASK), buf, len);
+	memcpy(pl->mapped_tail + (pl->length & ~PAGE_MASK), buf, len);
 	pl->length += len;
 	pl->room -= len;
 	return 0;
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index d4f5f220a8e5..72ca9651562a 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -95,19 +95,19 @@ int ceph_copy_user_to_page_vector(struct page **pages,
 					 loff_t off, size_t len)
 {
 	int i = 0;
-	int po = off & ~PAGE_CACHE_MASK;
+	int po = off & ~PAGE_MASK;
 	int left = len;
 	int l, bad;
 
 	while (left > 0) {
-		l = min_t(int, PAGE_CACHE_SIZE-po, left);
+		l = min_t(int, PAGE_SIZE-po, left);
 		bad = copy_from_user(page_address(pages[i]) + po, data, l);
 		if (bad == l)
 			return -EFAULT;
 		data += l - bad;
 		left -= l - bad;
 		po += l - bad;
-		if (po == PAGE_CACHE_SIZE) {
+		if (po == PAGE_SIZE) {
 			po = 0;
 			i++;
 		}
@@ -121,17 +121,17 @@ void ceph_copy_to_page_vector(struct page **pages,
 				    loff_t off, size_t len)
 {
 	int i = 0;
-	size_t po = off & ~PAGE_CACHE_MASK;
+	size_t po = off & ~PAGE_MASK;
 	size_t left = len;
 
 	while (left > 0) {
-		size_t l = min_t(size_t, PAGE_CACHE_SIZE-po, left);
+		size_t l = min_t(size_t, PAGE_SIZE-po, left);
 
 		memcpy(page_address(pages[i]) + po, data, l);
 		data += l;
 		left -= l;
 		po += l;
-		if (po == PAGE_CACHE_SIZE) {
+		if (po == PAGE_SIZE) {
 			po = 0;
 			i++;
 		}
@@ -144,17 +144,17 @@ void ceph_copy_from_page_vector(struct page **pages,
 				    loff_t off, size_t len)
 {
 	int i = 0;
-	size_t po = off & ~PAGE_CACHE_MASK;
+	size_t po = off & ~PAGE_MASK;
 	size_t left = len;
 
 	while (left > 0) {
-		size_t l = min_t(size_t, PAGE_CACHE_SIZE-po, left);
+		size_t l = min_t(size_t, PAGE_SIZE-po, left);
 
 		memcpy(data, page_address(pages[i]) + po, l);
 		data += l;
 		left -= l;
 		po += l;
-		if (po == PAGE_CACHE_SIZE) {
+		if (po == PAGE_SIZE) {
 			po = 0;
 			i++;
 		}
@@ -168,25 +168,25 @@ EXPORT_SYMBOL(ceph_copy_from_page_vector);
  */
 void ceph_zero_page_vector_range(int off, int len, struct page **pages)
 {
-	int i = off >> PAGE_CACHE_SHIFT;
+	int i = off >> PAGE_SHIFT;
 
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 
 	dout("zero_page_vector_page %u~%u\n", off, len);
 
 	/* leading partial page? */
 	if (off) {
-		int end = min((int)PAGE_CACHE_SIZE, off + len);
+		int end = min((int)PAGE_SIZE, off + len);
 		dout("zeroing %d %p head from %d\n", i, pages[i],
 		     (int)off);
 		zero_user_segment(pages[i], off, end);
 		len -= (end - off);
 		i++;
 	}
-	while (len >= PAGE_CACHE_SIZE) {
+	while (len >= PAGE_SIZE) {
 		dout("zeroing %d %p len=%d\n", i, pages[i], len);
-		zero_user_segment(pages[i], 0, PAGE_CACHE_SIZE);
-		len -= PAGE_CACHE_SIZE;
+		zero_user_segment(pages[i], 0, PAGE_SIZE);
+		len -= PAGE_SIZE;
 		i++;
 	}
 	/* trailing partial page? */
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
