Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 11818828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 13:01:50 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e65so189559857pfe.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 10:01:50 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qy6si61005097pab.19.2016.01.06.10.01.49
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 10:01:49 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v7 2/9] dax: fix conversion of holes to PMDs
Date: Wed,  6 Jan 2016 11:00:56 -0700
Message-Id: <1452103263-1592-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1452103263-1592-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1452103263-1592-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

When we get a DAX PMD fault for a write it is possible that there could be
some number of 4k zero pages already present for the same range that were
inserted to service reads from a hole.  These 4k zero pages need to be
unmapped from the VMAs and removed from the struct address_space radix tree
before the real DAX PMD entry can be inserted.

For PTE faults this same use case also exists and is handled by a
combination of unmap_mapping_range() to unmap the VMAs and
delete_from_page_cache() to remove the page from the address_space radix
tree.

For PMD faults we do have a call to unmap_mapping_range() (protected by a
buffer_new() check), but nothing clears out the radix tree entry.  The
buffer_new() check is also incorrect as the current ext4 and XFS filesystem
code will never return a buffer_head with BH_New set, even when allocating
new blocks over a hole.  Instead the filesystem will zero the blocks
manually and return a buffer_head with only BH_Mapped set.

Fix this situation by removing the buffer_new() check and adding a call to
truncate_inode_pages_range() to clear out the radix tree entries before we
insert the DAX PMD.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 03cc4a3..9dc0c97 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -594,6 +594,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	bool write = flags & FAULT_FLAG_WRITE;
 	struct block_device *bdev;
 	pgoff_t size, pgoff;
+	loff_t lstart, lend;
 	sector_t block;
 	int result = 0;
 
@@ -647,15 +648,13 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		goto fallback;
 	}
 
-	/*
-	 * If we allocated new storage, make sure no process has any
-	 * zero pages covering this hole
-	 */
-	if (buffer_new(&bh)) {
-		i_mmap_unlock_read(mapping);
-		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
-		i_mmap_lock_read(mapping);
-	}
+	/* make sure no process has any zero pages covering this hole */
+	lstart = pgoff << PAGE_SHIFT;
+	lend = lstart + PMD_SIZE - 1; /* inclusive */
+	i_mmap_unlock_read(mapping);
+	unmap_mapping_range(mapping, lstart, PMD_SIZE, 0);
+	truncate_inode_pages_range(mapping, lstart, lend);
+	i_mmap_lock_read(mapping);
 
 	/*
 	 * If a truncate happened while we were allocating blocks, we may
@@ -669,7 +668,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		goto out;
 	}
 	if ((pgoff | PG_PMD_COLOUR) >= size) {
-		dax_pmd_dbg(&bh, address, "pgoff unaligned");
+		dax_pmd_dbg(&bh, address,
+				"offset + huge page size > file size");
 		goto fallback;
 	}
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
