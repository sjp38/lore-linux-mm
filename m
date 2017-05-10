Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39CBC28085C
	for <linux-mm@kvack.org>; Wed, 10 May 2017 04:54:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k57so6318980wrk.6
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:54:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l125si2928670wmg.143.2017.05.10.01.54.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 01:54:25 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/4] dax: Fix data corruption when fault races with write
Date: Wed, 10 May 2017 10:54:19 +0200
Message-Id: <20170510085419.27601-5-jack@suse.cz>
In-Reply-To: <20170510085419.27601-1-jack@suse.cz>
References: <20170510085419.27601-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, stable@vger.kernel.org

Currently DAX read fault can race with write(2) in the following way:

CPU1 - write(2)			CPU2 - read fault
				dax_iomap_pte_fault()
				  ->iomap_begin() - sees hole
dax_iomap_rw()
  iomap_apply()
    ->iomap_begin - allocates blocks
    dax_iomap_actor()
      invalidate_inode_pages2_range()
        - there's nothing to invalidate
				  grab_mapping_entry()
				  - we add zero page in the radix tree
				    and map it to page tables

The result is that hole page is mapped into page tables (and thus zeros
are seen in mmap) while file has data written in that place.

Fix the problem by locking exception entry before mapping blocks for the
fault. That way we are sure invalidate_inode_pages2_range() call for
racing write will either block on entry lock waiting for the fault to
finish (and unmap stale page tables after that) or read fault will see
already allocated blocks by write(2).

Fixes: 9f141d6ef6258a3a37a045842d9ba7e68f368956
CC: stable@vger.kernel.org
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 123d9903c77d..32f020c9cedf 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1148,6 +1148,12 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 	if ((vmf->flags & FAULT_FLAG_WRITE) && !vmf->cow_page)
 		flags |= IOMAP_WRITE;
 
+	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
+	if (IS_ERR(entry)) {
+		vmf_ret = dax_fault_return(PTR_ERR(entry));
+		goto out;
+	}
+
 	/*
 	 * Note that we don't bother to use iomap_apply here: DAX required
 	 * the file system block size to be equal the page size, which means
@@ -1156,17 +1162,11 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 	error = ops->iomap_begin(inode, pos, PAGE_SIZE, flags, &iomap);
 	if (error) {
 		vmf_ret = dax_fault_return(error);
-		goto out;
+		goto unlock_entry;
 	}
 	if (WARN_ON_ONCE(iomap.offset + iomap.length < pos + PAGE_SIZE)) {
-		vmf_ret = dax_fault_return(-EIO);	/* fs corruption? */
-		goto finish_iomap;
-	}
-
-	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
-	if (IS_ERR(entry)) {
-		vmf_ret = dax_fault_return(PTR_ERR(entry));
-		goto finish_iomap;
+		error = -EIO;	/* fs corruption? */
+		goto error_finish_iomap;
 	}
 
 	sector = dax_iomap_sector(&iomap, pos);
@@ -1188,13 +1188,13 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 		}
 
 		if (error)
-			goto error_unlock_entry;
+			goto error_finish_iomap;
 
 		__SetPageUptodate(vmf->cow_page);
 		vmf_ret = finish_fault(vmf);
 		if (!vmf_ret)
 			vmf_ret = VM_FAULT_DONE_COW;
-		goto unlock_entry;
+		goto finish_iomap;
 	}
 
 	switch (iomap.type) {
@@ -1214,7 +1214,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 	case IOMAP_HOLE:
 		if (!(vmf->flags & FAULT_FLAG_WRITE)) {
 			vmf_ret = dax_load_hole(mapping, &entry, vmf);
-			goto unlock_entry;
+			goto finish_iomap;
 		}
 		/*FALLTHRU*/
 	default:
@@ -1223,10 +1223,8 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 		break;
 	}
 
- error_unlock_entry:
+ error_finish_iomap:
 	vmf_ret = dax_fault_return(error) | major;
- unlock_entry:
-	put_locked_mapping_entry(mapping, vmf->pgoff, entry);
  finish_iomap:
 	if (ops->iomap_end) {
 		int copied = PAGE_SIZE;
@@ -1241,7 +1239,9 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 		 */
 		ops->iomap_end(inode, pos, PAGE_SIZE, copied, flags, &iomap);
 	}
-out:
+ unlock_entry:
+	put_locked_mapping_entry(mapping, vmf->pgoff, entry);
+ out:
 	trace_dax_pte_fault_done(inode, vmf, vmf_ret);
 	return vmf_ret;
 }
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
