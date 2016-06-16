Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2327B6B025F
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 17:26:31 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so30204990lfe.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 14:26:31 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id wn5si7606901wjb.116.2016.06.16.14.26.27
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 14:26:27 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 3/3] UBIFS: Implement ->migratepage()
Date: Thu, 16 Jun 2016 23:26:15 +0200
Message-Id: <1466112375-1717-4-git-send-email-richard@nod.at>
In-Reply-To: <1466112375-1717-1-git-send-email-richard@nod.at>
References: <1466112375-1717-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, hughd@google.com, vbabka@suse.cz, akpm@linux-foundation.org, adrian.hunter@intel.com, dedekind1@gmail.com, richard@nod.at, hch@infradead.org, linux-fsdevel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, alex@nextthing.co, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

During page migrations UBIFS might get confused
and the following assert triggers:
[  213.480000] UBIFS assert failed in ubifs_set_page_dirty at 1451 (pid 436)
[  213.490000] CPU: 0 PID: 436 Comm: drm-stress-test Not tainted 4.4.4-00176-geaa802524636-dirty #1008
[  213.490000] Hardware name: Allwinner sun4i/sun5i Families
[  213.490000] [<c0015e70>] (unwind_backtrace) from [<c0012cdc>] (show_stack+0x10/0x14)
[  213.490000] [<c0012cdc>] (show_stack) from [<c02ad834>] (dump_stack+0x8c/0xa0)
[  213.490000] [<c02ad834>] (dump_stack) from [<c0236ee8>] (ubifs_set_page_dirty+0x44/0x50)
[  213.490000] [<c0236ee8>] (ubifs_set_page_dirty) from [<c00fa0bc>] (try_to_unmap_one+0x10c/0x3a8)
[  213.490000] [<c00fa0bc>] (try_to_unmap_one) from [<c00fadb4>] (rmap_walk+0xb4/0x290)
[  213.490000] [<c00fadb4>] (rmap_walk) from [<c00fb1bc>] (try_to_unmap+0x64/0x80)
[  213.490000] [<c00fb1bc>] (try_to_unmap) from [<c010dc28>] (migrate_pages+0x328/0x7a0)
[  213.490000] [<c010dc28>] (migrate_pages) from [<c00d0cb0>] (alloc_contig_range+0x168/0x2f4)
[  213.490000] [<c00d0cb0>] (alloc_contig_range) from [<c010ec00>] (cma_alloc+0x170/0x2c0)
[  213.490000] [<c010ec00>] (cma_alloc) from [<c001a958>] (__alloc_from_contiguous+0x38/0xd8)
[  213.490000] [<c001a958>] (__alloc_from_contiguous) from [<c001ad44>] (__dma_alloc+0x23c/0x274)
[  213.490000] [<c001ad44>] (__dma_alloc) from [<c001ae08>] (arm_dma_alloc+0x54/0x5c)
[  213.490000] [<c001ae08>] (arm_dma_alloc) from [<c035cecc>] (drm_gem_cma_create+0xb8/0xf0)
[  213.490000] [<c035cecc>] (drm_gem_cma_create) from [<c035cf20>] (drm_gem_cma_create_with_handle+0x1c/0xe8)
[  213.490000] [<c035cf20>] (drm_gem_cma_create_with_handle) from [<c035d088>] (drm_gem_cma_dumb_create+0x3c/0x48)
[  213.490000] [<c035d088>] (drm_gem_cma_dumb_create) from [<c0341ed8>] (drm_ioctl+0x12c/0x444)
[  213.490000] [<c0341ed8>] (drm_ioctl) from [<c0121adc>] (do_vfs_ioctl+0x3f4/0x614)
[  213.490000] [<c0121adc>] (do_vfs_ioctl) from [<c0121d30>] (SyS_ioctl+0x34/0x5c)
[  213.490000] [<c0121d30>] (SyS_ioctl) from [<c000f2c0>] (ret_fast_syscall+0x0/0x34)

UBIFS is using PagePrivate() which can have different meanings across
filesystems. Therefore the generic page migration code cannot handle this
case correctly.
We have to implement our own migration function which basically does a
plain copy but also duplicates the page private flag.
UBIFS is not a block device filesystem and cannot use buffer_migrate_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
[rw: Massaged changelog, build fixes, etc...]
Signed-off-by: Richard Weinberger <richard@nod.at>
Acked-by: Christoph Hellwig <hch@lst.de>

---
 fs/ubifs/file.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 0831697..7bbf420 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -52,6 +52,7 @@
 #include "ubifs.h"
 #include <linux/mount.h>
 #include <linux/slab.h>
+#include <linux/migrate.h>
 
 static int read_block(struct inode *inode, void *addr, unsigned int block,
 		      struct ubifs_data_node *dn)
@@ -1452,6 +1453,26 @@ static int ubifs_set_page_dirty(struct page *page)
 	return ret;
 }
 
+#ifdef CONFIG_MIGRATION
+static int ubifs_migrate_page(struct address_space *mapping,
+		struct page *newpage, struct page *page, enum migrate_mode mode)
+{
+	int rc;
+
+	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
+	if (rc != MIGRATEPAGE_SUCCESS)
+		return rc;
+
+	if (PagePrivate(page)) {
+		ClearPagePrivate(page);
+		SetPagePrivate(newpage);
+	}
+
+	migrate_page_copy(newpage, page);
+	return MIGRATEPAGE_SUCCESS;
+}
+#endif
+
 static int ubifs_releasepage(struct page *page, gfp_t unused_gfp_flags)
 {
 	/*
@@ -1591,6 +1612,9 @@ const struct address_space_operations ubifs_file_address_operations = {
 	.write_end      = ubifs_write_end,
 	.invalidatepage = ubifs_invalidatepage,
 	.set_page_dirty = ubifs_set_page_dirty,
+#ifdef CONFIG_MIGRATION
+	.migratepage	= ubifs_migrate_page,
+#endif
 	.releasepage    = ubifs_releasepage,
 };
 
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
