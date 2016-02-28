Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7576B0009
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 00:17:56 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id n186so7286383wmn.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 21:17:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o139si13178427wmd.116.2016.02.27.21.17.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Feb 2016 21:17:55 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sun, 28 Feb 2016 16:09:29 +1100
Subject: [PATCH 1/3] DAX: move RADIX_DAX_ definitions to dax.c
Message-ID: <145663616971.3865.212066814876758706.stgit@notabene>
In-Reply-To: <145663588892.3865.9987439671424028216.stgit@notabene>
References: <145663588892.3865.9987439671424028216.stgit@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

These don't belong in radix-tree.c any more than PAGECACHE_TAG_* do.
Let's try to maintain the idea that radix-tree simply implements an
abstract data type.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/dax.c                   |    9 +++++++++
 include/linux/radix-tree.h |    9 ---------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 711172450da6..9c4d697fb6fc 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -32,6 +32,15 @@
 #include <linux/pfn_t.h>
 #include <linux/sizes.h>
 
+#define RADIX_DAX_MASK	0xf
+#define RADIX_DAX_SHIFT	4
+#define RADIX_DAX_PTE  (0x4 | RADIX_TREE_EXCEPTIONAL_ENTRY)
+#define RADIX_DAX_PMD  (0x8 | RADIX_TREE_EXCEPTIONAL_ENTRY)
+#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_MASK)
+#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
+#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
+		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE)))
+
 static long dax_map_atomic(struct block_device *bdev, struct blk_dax_ctl *dax)
 {
 	struct request_queue *q = bdev->bd_queue;
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f54be7082207..968150ab8a1c 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -51,15 +51,6 @@
 #define RADIX_TREE_EXCEPTIONAL_ENTRY	2
 #define RADIX_TREE_EXCEPTIONAL_SHIFT	2
 
-#define RADIX_DAX_MASK	0xf
-#define RADIX_DAX_SHIFT	4
-#define RADIX_DAX_PTE  (0x4 | RADIX_TREE_EXCEPTIONAL_ENTRY)
-#define RADIX_DAX_PMD  (0x8 | RADIX_TREE_EXCEPTIONAL_ENTRY)
-#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_MASK)
-#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
-#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
-		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE)))
-
 static inline int radix_tree_is_indirect_ptr(void *ptr)
 {
 	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
