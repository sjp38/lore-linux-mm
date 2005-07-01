Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j61NFmAi017927
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 16:15:48 -0700
Date: Fri, 1 Jul 2005 15:40:51 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224051.542.55045.30184@jackhammer.engr.sgi.com>
In-Reply-To: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
References: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 2/11] mm: manual page migration-rc4 -- xfs-migrate-page-rc4.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Nathan Scott of SGI provided this patch for XFS that supports
the migrate_page method in the address_space operations vector.
It is basically the same as what is in ext2_migrate_page().
However, the routine "xfs_skip_migrate_page()" is added to
disallow migration of xfs metadata.

Signed-off-by: Ray Bryant <raybry@sgi.com>

 xfs_aops.c |   10 ++++++++++
 xfs_buf.c  |    7 +++++++
 2 files changed, 17 insertions(+)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/fs/xfs/linux-2.6/xfs_aops.c	2005-06-13 11:12:36.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/fs/xfs/linux-2.6/xfs_aops.c	2005-06-13 11:12:42.000000000 -0700
@@ -54,6 +54,7 @@
 #include "xfs_iomap.h"
 #include <linux/mpage.h>
 #include <linux/writeback.h>
+#include <linux/mmigrate.h>
 
 STATIC void xfs_count_page_state(struct page *, int *, int *, int *);
 STATIC void xfs_convert_page(struct inode *, struct page *, xfs_iomap_t *,
@@ -1273,6 +1274,14 @@ linvfs_prepare_write(
 	return block_prepare_write(page, from, to, linvfs_get_block);
 }
 
+STATIC int
+linvfs_migrate_page(
+	struct page		*from,
+	struct page		*to)
+{
+	return generic_migrate_page(from, to, migrate_page_buffer);
+}
+
 struct address_space_operations linvfs_aops = {
 	.readpage		= linvfs_readpage,
 	.readpages		= linvfs_readpages,
@@ -1283,4 +1292,5 @@ struct address_space_operations linvfs_a
 	.commit_write		= generic_commit_write,
 	.bmap			= linvfs_bmap,
 	.direct_IO		= linvfs_direct_IO,
+	.migrate_page		= linvfs_migrate_page,
 };
Index: linux-2.6.12-rc5-mhp1-page-migration-export/fs/xfs/linux-2.6/xfs_buf.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/fs/xfs/linux-2.6/xfs_buf.c	2005-06-13 11:12:36.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/fs/xfs/linux-2.6/xfs_buf.c	2005-06-13 11:12:42.000000000 -0700
@@ -1626,6 +1626,12 @@ xfs_setsize_buftarg(
 }
 
 STATIC int
+xfs_skip_migrate_page(struct page *from, struct page *to)
+{
+	return -EBUSY;
+}
+
+STATIC int
 xfs_mapping_buftarg(
 	xfs_buftarg_t		*btp,
 	struct block_device	*bdev)
@@ -1635,6 +1641,7 @@ xfs_mapping_buftarg(
 	struct address_space	*mapping;
 	static struct address_space_operations mapping_aops = {
 		.sync_page = block_sync_page,
+		.migrate_page = xfs_skip_migrate_page,
 	};
 
 	inode = new_inode(bdev->bd_inode->i_sb);

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
