Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA33928024B
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 17:09:23 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hm5so37165144pac.4
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 14:09:23 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d6si6717713pfk.51.2016.10.07.14.09.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Oct 2016 14:09:21 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 14/17] dax: move RADIX_DAX_* defines to dax.h
Date: Fri,  7 Oct 2016 15:09:01 -0600
Message-Id: <1475874544-24842-15-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

The RADIX_DAX_* defines currently mostly live in fs/dax.c, with just
RADIX_DAX_ENTRY_LOCK being in include/linux/dax.h so it can be used in
mm/filemap.c.  When we add PMD support, though, mm/filemap.c will also need
access to the RADIX_DAX_PTE type so it can properly construct a 4k sized
empty entry.

Instead of shifting the defines between dax.c and dax.h as they are
individually used in other code, just move them wholesale to dax.h so
they'll be available when we need them.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c            | 14 --------------
 include/linux/dax.h | 15 ++++++++++++++-
 2 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 5e8febe..ac3cd05 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -34,20 +34,6 @@
 #include <linux/iomap.h>
 #include "internal.h"
 
-/*
- * We use lowest available bit in exceptional entry for locking, other two
- * bits to determine entry type. In total 3 special bits.
- */
-#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 3)
-#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
-#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
-#define RADIX_DAX_TYPE_MASK (RADIX_DAX_PTE | RADIX_DAX_PMD)
-#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_TYPE_MASK)
-#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
-#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
-		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE) | \
-		RADIX_TREE_EXCEPTIONAL_ENTRY))
-
 /* We choose 4096 entries - same as per-zone page wait tables */
 #define DAX_WAIT_TABLE_BITS 12
 #define DAX_WAIT_TABLE_ENTRIES (1 << DAX_WAIT_TABLE_BITS)
diff --git a/include/linux/dax.h b/include/linux/dax.h
index a3dfee4..e9ea78c 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -8,8 +8,21 @@
 
 struct iomap_ops;
 
-/* We use lowest available exceptional entry bit for locking */
+/*
+ * We use lowest available bit in exceptional entry for locking, other two
+ * bits to determine entry type. In total 3 special bits.
+ */
+#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 3)
 #define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
+#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
+#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
+#define RADIX_DAX_TYPE_MASK (RADIX_DAX_PTE | RADIX_DAX_PMD)
+#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_TYPE_MASK)
+#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
+#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
+		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE) | \
+		RADIX_TREE_EXCEPTIONAL_ENTRY))
+
 
 ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		struct iomap_ops *ops);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
