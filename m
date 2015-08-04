Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5366B0256
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:18 -0400 (EDT)
Received: by padck2 with SMTP id ck2so16221526pad.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b8si804520pas.112.2015.08.04.12.58.12
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:13 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 04/11] ext4: Add ext4_get_block_dax()
Date: Tue,  4 Aug 2015 15:57:58 -0400
Message-Id: <1438718285-21168-5-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

DAX wants different semantics from any currently-existing ext4
get_block callback.  Unlike ext4_get_block_write(), it needs to honour
the 'create' flag, and unlike ext4_get_block(), it needs to be able
to return unwritten extents.  So introduce a new ext4_get_block_dax()
which has those semantics.  We could also change ext4_get_block_write()
to honour the 'create' flag, but that might have consequences on other
users that I do not currently understand.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/ext4/ext4.h  |  2 ++
 fs/ext4/file.c  |  6 +++---
 fs/ext4/inode.c | 11 +++++++++++
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index d743d93..51c5008 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2274,6 +2274,8 @@ struct buffer_head *ext4_getblk(handle_t *, struct inode *, ext4_lblk_t, int);
 struct buffer_head *ext4_bread(handle_t *, struct inode *, ext4_lblk_t, int);
 int ext4_get_block_write(struct inode *inode, sector_t iblock,
 			 struct buffer_head *bh_result, int create);
+int ext4_get_block_dax(struct inode *inode, sector_t iblock,
+			 struct buffer_head *bh_result, int create);
 int ext4_get_block(struct inode *inode, sector_t iblock,
 				struct buffer_head *bh_result, int create);
 int ext4_da_get_block_prep(struct inode *inode, sector_t iblock,
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index ca5302a..d5219e4 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -207,19 +207,19 @@ static void ext4_end_io_unwritten(struct buffer_head *bh, int uptodate)
 
 static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return dax_fault(vma, vmf, ext4_get_block_write, ext4_end_io_unwritten);
+	return dax_fault(vma, vmf, ext4_get_block_dax, ext4_end_io_unwritten);
 }
 
 static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 						pmd_t *pmd, unsigned int flags)
 {
-	return dax_pmd_fault(vma, addr, pmd, flags, ext4_get_block_write,
+	return dax_pmd_fault(vma, addr, pmd, flags, ext4_get_block_dax,
 				ext4_end_io_unwritten);
 }
 
 static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return dax_mkwrite(vma, vmf, ext4_get_block_write,
+	return dax_mkwrite(vma, vmf, ext4_get_block_dax,
 				ext4_end_io_unwritten);
 }
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 40e6c66..75146d1 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3025,6 +3025,17 @@ static int ext4_get_block_write_nolock(struct inode *inode, sector_t iblock,
 			       EXT4_GET_BLOCKS_NO_LOCK);
 }
 
+int ext4_get_block_dax(struct inode *inode, sector_t iblock,
+		   struct buffer_head *bh_result, int create)
+{
+	int flags = EXT4_GET_BLOCKS_PRE_IO | EXT4_GET_BLOCKS_UNWRIT_EXT;
+	if (create)
+		flags |= EXT4_GET_BLOCKS_CREATE;
+	ext4_debug("ext4_get_block_dax: inode %lu, create flag %d\n",
+		   inode->i_ino, create);
+	return _ext4_get_block(inode, iblock, bh_result, flags);
+}
+
 static void ext4_end_io_dio(struct kiocb *iocb, loff_t offset,
 			    ssize_t size, void *private)
 {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
