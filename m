Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 32AFB6B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 17:58:49 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id 20so98203wmh.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 14:58:49 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id lp7si13671493wjb.73.2016.03.31.14.58.46
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 14:58:46 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/2] UBIFS: Implement ->migratepage()
Date: Thu, 31 Mar 2016 23:58:33 +0200
Message-Id: <1459461513-31765-3-git-send-email-richard@nod.at>
In-Reply-To: <1459461513-31765-1-git-send-email-richard@nod.at>
References: <1459461513-31765-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hch@infradead.org, hughd@google.com, mgorman@techsingularity.net, vbabka@suse.cz, Richard Weinberger <richard@nod.at>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

During page migrations UBIFS might get confused
and the following assert triggers:
UBIFS assert failed in ubifs_set_page_dirty at 1451 (pid 436)

UBIFS is using PagePrivate() which can have different meanings across
filesystems. Therefore the generic page migration code cannot handle this
case correctly.
We have to implement our own migration function which basically does a
plain copy but also duplicates the page private flag.
UBIFS is not a block device filesystem and cannot use buffer_migrate_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
[rw: Massaged changelog]
Signed-off-by: Richard Weinberger <richard@nod.at>

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 fs/ubifs/file.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 065c88f..5eea5f5 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -52,6 +52,7 @@
 #include "ubifs.h"
 #include <linux/mount.h>
 #include <linux/slab.h>
+#include <linux/migrate.h>
 
 static int read_block(struct inode *inode, void *addr, unsigned int block,
 		      struct ubifs_data_node *dn)
@@ -1452,6 +1453,24 @@ static int ubifs_set_page_dirty(struct page *page)
 	return ret;
 }
 
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
+
 static int ubifs_releasepage(struct page *page, gfp_t unused_gfp_flags)
 {
 	/*
@@ -1591,6 +1610,7 @@ const struct address_space_operations ubifs_file_address_operations = {
 	.write_end      = ubifs_write_end,
 	.invalidatepage = ubifs_invalidatepage,
 	.set_page_dirty = ubifs_set_page_dirty,
+	.migratepage	= ubifs_migrate_page,
 	.releasepage    = ubifs_releasepage,
 };
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
