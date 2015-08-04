Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8126B0255
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:16 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so8452799pdr.2
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:16 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b8si804520pas.112.2015.08.04.12.58.12
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:12 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 01/11] ext4: Use ext4_get_block_write() for DAX
Date: Tue,  4 Aug 2015 15:57:55 -0400
Message-Id: <1438718285-21168-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

DAX relies on the get_block function either zeroing newly allocated blocks
before they're findable by subsequent calls to get_block, or marking newly
allocated blocks as unwritten.  ext4_get_block() cannot create unwritten
extents, but ext4_get_block_write() can.

Reported-by: Andy Rudoff <andy.rudoff@intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/ext4/file.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 953d519..ca5302a 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -196,7 +196,7 @@ out:
 static void ext4_end_io_unwritten(struct buffer_head *bh, int uptodate)
 {
 	struct inode *inode = bh->b_assoc_map->host;
-	/* XXX: breaks on 32-bit > 16GB. Is that even supported? */
+	/* XXX: breaks on 32-bit > 16TB. Is that even supported? */
 	loff_t offset = (loff_t)(uintptr_t)bh->b_private << inode->i_blkbits;
 	int err;
 	if (!uptodate)
@@ -207,8 +207,7 @@ static void ext4_end_io_unwritten(struct buffer_head *bh, int uptodate)
 
 static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return dax_fault(vma, vmf, ext4_get_block, ext4_end_io_unwritten);
-					/* Is this the right get_block? */
+	return dax_fault(vma, vmf, ext4_get_block_write, ext4_end_io_unwritten);
 }
 
 static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
@@ -220,7 +219,8 @@ static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 
 static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return dax_mkwrite(vma, vmf, ext4_get_block, ext4_end_io_unwritten);
+	return dax_mkwrite(vma, vmf, ext4_get_block_write,
+				ext4_end_io_unwritten);
 }
 
 static const struct vm_operations_struct ext4_dax_vm_ops = {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
