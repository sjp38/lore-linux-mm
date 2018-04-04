Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED98C6B0027
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:15 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f13so16337040qtg.15
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:15 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u7si6514077qkf.194.2018.04.04.12.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:14 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 30/79] fs/block: add struct address_space to __block_write_begin() arguments
Date: Wed,  4 Apr 2018 15:18:04 -0400
Message-Id: <20180404191831.5378-15-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Add struct address_space to __block_write_begin() arguments.

One step toward dropping reliance on page->mapping.

----------------------------------------------------------------------
identifier M;
expression E1, E2, E3, E4;
@@
struct address_space *M;
...
-__block_write_begin(E1, E2, E3, E4)
+__block_write_begin(M, E1, E2, E3, E4)

@exists@
identifier M, F;
expression E1, E2, E3, E4;
@@
F(..., struct address_space *M, ...) {...
-__block_write_begin(E1, E2, E3, E4)
+__block_write_begin(M, E1, E2, E3, E4)
...}

@exists@
identifier I;
expression E1, E2, E3, E4, E5;
@@
struct inode *I;
...
-__block_write_begin(E1, E2, E3, E4)
+__block_write_begin(I->i_mapping, E1, E2, E3, E4)

@exists@
identifier I, F;
expression E1, E2, E3, E4;
@@
F(..., struct inode *I, ...) {...
-__block_write_begin(E1, E2, E3, E4)
+__block_write_begin(I->i_mapping, E1, E2, E3, E4)
...}

@exists@
identifier P;
expression E1, E2, E3, E4, E5;
@@
struct page *P;
...
-__block_write_begin(E1, E2, E3, E4)
+__block_write_begin(P->mapping, E1, E2, E3, E4)

@exists@
identifier P, F;
expression E1, E2, E3, E4;
@@
F(..., struct page *P, ...) {...
-__block_write_begin(E1, E2, E3, E4)
+__block_write_begin(P->mapping, E1, E2, E3, E4)
...}
----------------------------------------------------------------------

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 fs/buffer.c                 | 10 +++++-----
 fs/ext2/dir.c               |  3 ++-
 fs/ext4/inline.c            |  7 ++++---
 fs/ext4/inode.c             |  8 +++++---
 fs/gfs2/aops.c              |  2 +-
 fs/minix/inode.c            |  3 ++-
 fs/nilfs2/dir.c             |  3 ++-
 fs/ocfs2/file.c             |  2 +-
 fs/reiserfs/inode.c         |  8 +++++---
 fs/sysv/itree.c             |  2 +-
 fs/ufs/inode.c              |  3 ++-
 include/linux/buffer_head.h |  4 ++--
 12 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 8b2eb3dfb539..de16588d7f7f 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2028,8 +2028,8 @@ int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 	return err;
 }
 
-int __block_write_begin(struct page *page, loff_t pos, unsigned len,
-		get_block_t *get_block)
+int __block_write_begin(struct address_space *mapping, struct page *page,
+		loff_t pos, unsigned len, get_block_t *get_block)
 {
 	return __block_write_begin_int(page, pos, len, get_block, NULL);
 }
@@ -2090,7 +2090,7 @@ int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
 	if (!page)
 		return -ENOMEM;
 
-	status = __block_write_begin(page, pos, len, get_block);
+	status = __block_write_begin(mapping, page, pos, len, get_block);
 	if (unlikely(status)) {
 		unlock_page(page);
 		put_page(page);
@@ -2495,7 +2495,7 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	else
 		end = PAGE_SIZE;
 
-	ret = __block_write_begin(page, 0, end, get_block);
+	ret = __block_write_begin(inode->i_mapping, page, 0, end, get_block);
 	if (!ret)
 		ret = block_commit_write(page, 0, end);
 
@@ -2579,7 +2579,7 @@ int nobh_write_begin(struct address_space *mapping,
 	*fsdata = NULL;
 
 	if (page_has_buffers(page)) {
-		ret = __block_write_begin(page, pos, len, get_block);
+		ret = __block_write_begin(mapping, page, pos, len, get_block);
 		if (unlikely(ret))
 			goto out_release;
 		return ret;
diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index 3b8114def693..0d116d4e923c 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -453,7 +453,8 @@ ino_t ext2_inode_by_name(struct inode *dir, const struct qstr *child)
 
 static int ext2_prepare_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	return __block_write_begin(page, pos, len, ext2_get_block);
+	return __block_write_begin(page->mapping, page, pos, len,
+				   ext2_get_block);
 }
 
 /* Releases the page */
diff --git a/fs/ext4/inline.c b/fs/ext4/inline.c
index 70cf4c7b268a..ffdbd443c67a 100644
--- a/fs/ext4/inline.c
+++ b/fs/ext4/inline.c
@@ -580,10 +580,11 @@ static int ext4_convert_inline_data_to_extent(struct address_space *mapping,
 		goto out;
 
 	if (ext4_should_dioread_nolock(inode)) {
-		ret = __block_write_begin(page, from, to,
+		ret = __block_write_begin(mapping, page, from, to,
 					  ext4_get_block_unwritten);
 	} else
-		ret = __block_write_begin(page, from, to, ext4_get_block);
+		ret = __block_write_begin(mapping, page, from, to,
+					  ext4_get_block);
 
 	if (!ret && ext4_should_journal_data(inode)) {
 		ret = ext4_walk_page_buffers(handle, page_buffers(page),
@@ -808,7 +809,7 @@ static int ext4_da_convert_inline_data_to_extent(struct address_space *mapping,
 			goto out;
 	}
 
-	ret = __block_write_begin(page, 0, inline_size,
+	ret = __block_write_begin(mapping, page, 0, inline_size,
 				  ext4_da_get_block_prep);
 	if (ret) {
 		up_read(&EXT4_I(inode)->xattr_sem);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 394fed206138..1947aac3e8ee 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1314,10 +1314,11 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 					     ext4_get_block);
 #else
 	if (ext4_should_dioread_nolock(inode))
-		ret = __block_write_begin(page, pos, len,
+		ret = __block_write_begin(mapping, page, pos, len,
 					  ext4_get_block_unwritten);
 	else
-		ret = __block_write_begin(page, pos, len, ext4_get_block);
+		ret = __block_write_begin(mapping, page, pos, len,
+					  ext4_get_block);
 #endif
 	if (!ret && ext4_should_journal_data(inode)) {
 		ret = ext4_walk_page_buffers(handle, page_buffers(page),
@@ -3080,7 +3081,8 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 	ret = ext4_block_write_begin(page, pos, len,
 				     ext4_da_get_block_prep);
 #else
-	ret = __block_write_begin(page, pos, len, ext4_da_get_block_prep);
+	ret = __block_write_begin(mapping, page, pos, len,
+				  ext4_da_get_block_prep);
 #endif
 	if (ret < 0) {
 		unlock_page(page);
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 21cb6bc98645..466f2f909108 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -744,7 +744,7 @@ static int gfs2_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 prepare_write:
-	error = __block_write_begin(page, from, len, gfs2_block_map);
+	error = __block_write_begin(mapping, page, from, len, gfs2_block_map);
 out:
 	if (error == 0)
 		return 0;
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index 2a151fa6b013..450aa4e87cd9 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -396,7 +396,8 @@ static int minix_readpage(struct file *file, struct address_space *mapping,
 
 int minix_prepare_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	return __block_write_begin(page, pos, len, minix_get_block);
+	return __block_write_begin(page->mapping, page, pos, len,
+				   minix_get_block);
 }
 
 static void minix_write_failed(struct address_space *mapping, loff_t to)
diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
index 582831ab3eb9..837d7eb9a920 100644
--- a/fs/nilfs2/dir.c
+++ b/fs/nilfs2/dir.c
@@ -98,7 +98,8 @@ static int nilfs_prepare_chunk(struct page *page, unsigned int from,
 {
 	loff_t pos = page_offset(page) + from;
 
-	return __block_write_begin(page, pos, to - from, nilfs_get_block);
+	return __block_write_begin(page->mapping, page, pos, to - from,
+				   nilfs_get_block);
 }
 
 static void nilfs_commit_chunk(struct page *page,
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 5d1784a365a3..fe1d542def25 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -810,7 +810,7 @@ static int ocfs2_write_zero_page(struct inode *inode, u64 abs_from,
 		 * __block_write_begin and block_commit_write to zero the
 		 * whole block.
 		 */
-		ret = __block_write_begin(page, block_start + 1, 0,
+		ret = __block_write_begin(mapping, page, block_start + 1, 0,
 					  ocfs2_get_block);
 		if (ret < 0) {
 			mlog_errno(ret);
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index d4ab2d45f846..aec309175fd0 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -2210,7 +2210,8 @@ static int grab_tail_page(struct inode *inode,
 	/* start within the page of the last block in the file */
 	start = (offset / blocksize) * blocksize;
 
-	error = __block_write_begin(page, start, offset - start,
+	error = __block_write_begin(inode->i_mapping, page, start,
+				    offset - start,
 				    reiserfs_get_block_create_0);
 	if (error)
 		goto unlock;
@@ -2788,7 +2789,7 @@ static int reiserfs_write_begin(struct file *file,
 		old_ref = th->t_refcount;
 		th->t_refcount++;
 	}
-	ret = __block_write_begin(page, pos, len, reiserfs_get_block);
+	ret = __block_write_begin(mapping, page, pos, len, reiserfs_get_block);
 	if (ret && reiserfs_transaction_running(inode->i_sb)) {
 		struct reiserfs_transaction_handle *th = current->journal_info;
 		/*
@@ -2848,7 +2849,8 @@ int __reiserfs_write_begin(struct page *page, unsigned from, unsigned len)
 		th->t_refcount++;
 	}
 
-	ret = __block_write_begin(page, from, len, reiserfs_get_block);
+	ret = __block_write_begin(inode->i_mapping, page, from, len,
+				  reiserfs_get_block);
 	if (ret && reiserfs_transaction_running(inode->i_sb)) {
 		struct reiserfs_transaction_handle *th = current->journal_info;
 		/*
diff --git a/fs/sysv/itree.c b/fs/sysv/itree.c
index 7cec1e024dc3..3b7d27e07e31 100644
--- a/fs/sysv/itree.c
+++ b/fs/sysv/itree.c
@@ -465,7 +465,7 @@ static int sysv_readpage(struct file *file, struct address_space *mapping,
 
 int sysv_prepare_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	return __block_write_begin(page, pos, len, get_block);
+	return __block_write_begin(page->mapping, page, pos, len, get_block);
 }
 
 static void sysv_write_failed(struct address_space *mapping, loff_t to)
diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index 8589b934be09..fcaa60bfad49 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -483,7 +483,8 @@ static int ufs_readpage(struct file *file, struct address_space *mapping,
 
 int ufs_prepare_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	return __block_write_begin(page, pos, len, ufs_getfrag_block);
+	return __block_write_begin(page->mapping, page, pos, len,
+				   ufs_getfrag_block);
 }
 
 static void ufs_truncate_blocks(struct inode *);
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index fb68a3358330..dca0d3eb789a 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -228,8 +228,8 @@ int block_is_partially_uptodate(struct page *page,
 	unsigned long count);
 int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
 		unsigned flags, struct page **pagep, get_block_t *get_block);
-int __block_write_begin(struct page *page, loff_t pos, unsigned len,
-		get_block_t *get_block);
+int __block_write_begin(struct address_space *mapping, struct page *page,
+		loff_t pos, unsigned len, get_block_t *get_block);
 int block_write_end(struct file *, struct address_space *,
 				loff_t, unsigned, unsigned,
 				struct page *, void *);
-- 
2.14.3
