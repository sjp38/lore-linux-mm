Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6A0C280251
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 18:50:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r16so55880175pfg.4
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 15:50:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m6si9442179pab.331.2016.10.12.15.50.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 15:50:38 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v6 11/17] dax: add dax_iomap_sector() helper function
Date: Wed, 12 Oct 2016 16:50:16 -0600
Message-Id: <20161012225022.15507-12-ross.zwisler@linux.intel.com>
In-Reply-To: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

To be able to correctly calculate the sector from a file position and a
struct iomap there is a complex little bit of logic that currently happens
in both dax_iomap_actor() and dax_iomap_fault().  This will need to be
repeated yet again in the DAX PMD fault handler when it is added, so break
it out into a helper function.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index fdbd7a1..7737954 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1030,6 +1030,11 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 EXPORT_SYMBOL_GPL(dax_truncate_page);
 
 #ifdef CONFIG_FS_IOMAP
+static sector_t dax_iomap_sector(struct iomap *iomap, loff_t pos)
+{
+	return iomap->blkno + (((pos & PAGE_MASK) - iomap->offset) >> 9);
+}
+
 static loff_t
 dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		struct iomap *iomap)
@@ -1055,8 +1060,7 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		struct blk_dax_ctl dax = { 0 };
 		ssize_t map_len;
 
-		dax.sector = iomap->blkno +
-			(((pos & PAGE_MASK) - iomap->offset) >> 9);
+		dax.sector = dax_iomap_sector(iomap, pos);
 		dax.size = (length + offset + PAGE_SIZE - 1) & PAGE_MASK;
 		map_len = dax_map_atomic(iomap->bdev, &dax);
 		if (map_len < 0) {
@@ -1193,7 +1197,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		goto unlock_entry;
 	}
 
-	sector = iomap.blkno + (((pos & PAGE_MASK) - iomap.offset) >> 9);
+	sector = dax_iomap_sector(&iomap, pos);
 
 	if (vmf->cow_page) {
 		switch (iomap.type) {
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
