Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD1182F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:14 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id n5so237569147pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:14 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id h5si5314225pat.227.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 17/71] usb: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:24 +0300
Message-Id: <1458499278-1516-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Felipe Balbi <balbi@kernel.org>, Matthew Dharm <mdharm-usb@one-eyed-alien.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

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
Cc: Felipe Balbi <balbi@kernel.org>
Cc: Matthew Dharm <mdharm-usb@one-eyed-alien.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/usb/gadget/function/f_fs.c | 4 ++--
 drivers/usb/gadget/legacy/inode.c  | 4 ++--
 drivers/usb/storage/scsiglue.c     | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index 8cfce105c7ee..e21ca2bd6839 100644
--- a/drivers/usb/gadget/function/f_fs.c
+++ b/drivers/usb/gadget/function/f_fs.c
@@ -1147,8 +1147,8 @@ static int ffs_sb_fill(struct super_block *sb, void *_data, int silent)
 	ffs->sb              = sb;
 	data->ffs_data       = NULL;
 	sb->s_fs_info        = ffs;
-	sb->s_blocksize      = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize      = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic          = FUNCTIONFS_MAGIC;
 	sb->s_op             = &ffs_sb_operations;
 	sb->s_time_gran      = 1;
diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index 5cdaf0150a4e..e64479f882a5 100644
--- a/drivers/usb/gadget/legacy/inode.c
+++ b/drivers/usb/gadget/legacy/inode.c
@@ -1954,8 +1954,8 @@ gadgetfs_fill_super (struct super_block *sb, void *opts, int silent)
 		return -ENODEV;
 
 	/* superblock */
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = GADGETFS_MAGIC;
 	sb->s_op = &gadget_fs_operations;
 	sb->s_time_gran = 1;
diff --git a/drivers/usb/storage/scsiglue.c b/drivers/usb/storage/scsiglue.c
index dba51362d2e2..90901861bfc0 100644
--- a/drivers/usb/storage/scsiglue.c
+++ b/drivers/usb/storage/scsiglue.c
@@ -123,7 +123,7 @@ static int slave_configure(struct scsi_device *sdev)
 		unsigned int max_sectors = 64;
 
 		if (us->fflags & US_FL_MAX_SECTORS_MIN)
-			max_sectors = PAGE_CACHE_SIZE >> 9;
+			max_sectors = PAGE_SIZE >> 9;
 		if (queue_max_hw_sectors(sdev->request_queue) > max_sectors)
 			blk_queue_max_hw_sectors(sdev->request_queue,
 					      max_sectors);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
