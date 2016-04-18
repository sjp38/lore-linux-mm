Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 941C16B0265
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:36:03 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l15so124675829lfg.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:36:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si67236607wjb.167.2016.04.18.14.35.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 14:35:52 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 14/18] dax: Define DAX lock bit for radix tree exceptional entry
Date: Mon, 18 Apr 2016 23:35:37 +0200
Message-Id: <1461015341-20153-15-git-send-email-jack@suse.cz>
In-Reply-To: <1461015341-20153-1-git-send-email-jack@suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>

We will use lowest available bit in the radix tree exceptional entry for
locking of the entry. Define it. Also clean up definitions of DAX entry
type bits in DAX exceptional entries to use defined constants instead of
hardcoding numbers and cleanup checking of these bits to not rely on how
other bits in the entry are set.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 17 +++++++++++------
 include/linux/dax.h |  3 +++
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 388327f56fa8..3e491eb37bc4 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -32,14 +32,19 @@
 #include <linux/pfn_t.h>
 #include <linux/sizes.h>
 
-#define RADIX_DAX_MASK	0xf
-#define RADIX_DAX_SHIFT	4
-#define RADIX_DAX_PTE  (0x4 | RADIX_TREE_EXCEPTIONAL_ENTRY)
-#define RADIX_DAX_PMD  (0x8 | RADIX_TREE_EXCEPTIONAL_ENTRY)
-#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_MASK)
+/*
+ * We use lowest available bit in exceptional entry for locking, other two
+ * bits to determine entry type. In total 3 special bits.
+ */
+#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 3)
+#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
+#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
+#define RADIX_DAX_TYPE_MASK (RADIX_DAX_PTE | RADIX_DAX_PMD)
+#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_TYPE_MASK)
 #define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
 #define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
-		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE)))
+		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE) | \
+		RADIX_TREE_EXCEPTIONAL_ENTRY))
 
 static long dax_map_atomic(struct block_device *bdev, struct blk_dax_ctl *dax)
 {
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 0591f4853228..bef5c44f71b3 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -5,6 +5,9 @@
 #include <linux/mm.h>
 #include <asm/pgtable.h>
 
+/* We use lowest available exceptional entry bit for locking */
+#define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
+
 ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *, loff_t,
 		  get_block_t, dio_iodone_t, int flags);
 int dax_clear_sectors(struct block_device *bdev, sector_t _sector, long _size);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
