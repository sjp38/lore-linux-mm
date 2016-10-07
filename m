Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01F2928024B
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 17:09:22 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id tz10so37194799pab.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 14:09:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d6si6717713pfk.51.2016.10.07.14.09.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Oct 2016 14:09:20 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 13/17] dax: dax_iomap_fault() needs to call iomap_end()
Date: Fri,  7 Oct 2016 15:09:00 -0600
Message-Id: <1475874544-24842-14-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Currently iomap_end() doesn't do anything for DAX page faults for both ext2
and XFS.  ext2_iomap_end() just checks for a write underrun, and
xfs_file_iomap_end() checks to see if it needs to finish a delayed
allocation.  However, in the future iomap_end() calls might be needed to
make sure we have balanced allocations, locks, etc.  So, add calls to
iomap_end() with appropriate error handling to dax_iomap_fault().

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 7689ab0..5e8febe 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1187,7 +1187,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		goto unlock_entry;
 	if (WARN_ON_ONCE(iomap.offset + iomap.length < pos + PAGE_SIZE)) {
 		error = -EIO;		/* fs corruption? */
-		goto unlock_entry;
+		goto finish_iomap;
 	}
 
 	sector = dax_iomap_sector(&iomap, pos);
@@ -1209,7 +1209,14 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		}
 
 		if (error)
-			goto unlock_entry;
+			goto finish_iomap;
+
+		if (ops->iomap_end) {
+			error = ops->iomap_end(inode, pos, PAGE_SIZE,
+					PAGE_SIZE, flags, &iomap);
+			if (error)
+				goto unlock_entry;
+		}
 		if (!radix_tree_exceptional_entry(entry)) {
 			vmf->page = entry;
 			return VM_FAULT_LOCKED;
@@ -1230,8 +1237,15 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		break;
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
-		if (!(vmf->flags & FAULT_FLAG_WRITE))
+		if (!(vmf->flags & FAULT_FLAG_WRITE)) {
+			if (ops->iomap_end)  {
+				error = ops->iomap_end(inode, pos, PAGE_SIZE,
+						PAGE_SIZE, flags, &iomap);
+				if (error)
+					goto unlock_entry;
+			}
 			return dax_load_hole(mapping, entry, vmf);
+		}
 		/*FALLTHRU*/
 	default:
 		WARN_ON_ONCE(1);
@@ -1239,6 +1253,17 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		break;
 	}
 
+ finish_iomap:
+	if (ops->iomap_end) {
+		if (error) {
+			/* keep previous error */
+			ops->iomap_end(inode, pos, PAGE_SIZE, PAGE_SIZE, flags,
+					&iomap);
+		} else {
+			error = ops->iomap_end(inode, pos, PAGE_SIZE,
+					PAGE_SIZE, flags, &iomap);
+		}
+	}
  unlock_entry:
 	put_locked_mapping_entry(mapping, vmf->pgoff, entry);
  out:
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
