Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B84116B0267
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:47:27 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so15348879wmd.6
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 08:47:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k24si29091907wmi.156.2016.12.12.08.47.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 08:47:22 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 5/6] dax: Call ->iomap_begin without entry lock during dax fault
Date: Mon, 12 Dec 2016 17:47:07 +0100
Message-Id: <20161212164708.23244-6-jack@suse.cz>
In-Reply-To: <20161212164708.23244-1-jack@suse.cz>
References: <20161212164708.23244-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>

Currently ->iomap_begin() handler is called with entry lock held. If the
filesystem held any locks between ->iomap_begin() and ->iomap_end()
(such as ext4 which will want to hold transaction open), this would cause
lock inversion with the iomap_apply() from standard IO path which first
calls ->iomap_begin() and only then calls ->actor() callback which grabs
entry locks for DAX (if it faults when copying from/to user provided
buffers).

Fix the problem by nesting grabbing of entry lock inside ->iomap_begin()
- ->iomap_end() pair.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 121 ++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 66 insertions(+), 55 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index e186bba0a642..51b03e91d3e2 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1079,6 +1079,15 @@ dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 }
 EXPORT_SYMBOL_GPL(dax_iomap_rw);
 
+static int dax_fault_return(int error)
+{
+	if (error == 0)
+		return VM_FAULT_NOPAGE;
+	if (error == -ENOMEM)
+		return VM_FAULT_OOM;
+	return VM_FAULT_SIGBUS;
+}
+
 /**
  * dax_iomap_fault - handle a page fault on a DAX file
  * @vma: The virtual memory area where the fault occurred
@@ -1111,12 +1120,6 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (pos >= i_size_read(inode))
 		return VM_FAULT_SIGBUS;
 
-	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
-	if (IS_ERR(entry)) {
-		error = PTR_ERR(entry);
-		goto out;
-	}
-
 	if ((vmf->flags & FAULT_FLAG_WRITE) && !vmf->cow_page)
 		flags |= IOMAP_WRITE;
 
@@ -1127,9 +1130,15 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 */
 	error = ops->iomap_begin(inode, pos, PAGE_SIZE, flags, &iomap);
 	if (error)
-		goto unlock_entry;
+		return dax_fault_return(error);
 	if (WARN_ON_ONCE(iomap.offset + iomap.length < pos + PAGE_SIZE)) {
-		error = -EIO;		/* fs corruption? */
+		vmf_ret = dax_fault_return(-EIO);	/* fs corruption? */
+		goto finish_iomap;
+	}
+
+	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
+	if (IS_ERR(entry)) {
+		vmf_ret = dax_fault_return(PTR_ERR(entry));
 		goto finish_iomap;
 	}
 
@@ -1152,13 +1161,13 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		}
 
 		if (error)
-			goto finish_iomap;
+			goto error_unlock_entry;
 
 		__SetPageUptodate(vmf->cow_page);
 		vmf_ret = finish_fault(vmf);
 		if (!vmf_ret)
 			vmf_ret = VM_FAULT_DONE_COW;
-		goto finish_iomap;
+		goto unlock_entry;
 	}
 
 	switch (iomap.type) {
@@ -1170,12 +1179,15 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		}
 		error = dax_insert_mapping(mapping, iomap.bdev, sector,
 				PAGE_SIZE, &entry, vma, vmf);
+		/* -EBUSY is fine, somebody else faulted on the same PTE */
+		if (error == -EBUSY)
+			error = 0;
 		break;
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (!(vmf->flags & FAULT_FLAG_WRITE)) {
 			vmf_ret = dax_load_hole(mapping, &entry, vmf);
-			goto finish_iomap;
+			goto unlock_entry;
 		}
 		/*FALLTHRU*/
 	default:
@@ -1184,30 +1196,25 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		break;
 	}
 
- finish_iomap:
-	if (ops->iomap_end) {
-		if (error || (vmf_ret & VM_FAULT_ERROR)) {
-			/* keep previous error */
-			ops->iomap_end(inode, pos, PAGE_SIZE, 0, flags,
-					&iomap);
-		} else {
-			error = ops->iomap_end(inode, pos, PAGE_SIZE,
-					PAGE_SIZE, flags, &iomap);
-		}
-	}
+ error_unlock_entry:
+	vmf_ret = dax_fault_return(error) | major;
  unlock_entry:
 	put_locked_mapping_entry(mapping, vmf->pgoff, entry);
- out:
-	if (error == -ENOMEM)
-		return VM_FAULT_OOM | major;
-	/* -EBUSY is fine, somebody else faulted on the same PTE */
-	if (error < 0 && error != -EBUSY)
-		return VM_FAULT_SIGBUS | major;
-	if (vmf_ret) {
-		WARN_ON_ONCE(error); /* -EBUSY from ops->iomap_end? */
-		return vmf_ret;
+ finish_iomap:
+	if (ops->iomap_end) {
+		int copied = PAGE_SIZE;
+
+		if (vmf_ret & VM_FAULT_ERROR)
+			copied = 0;
+		/*
+		 * The fault is done by now and there's no way back (other
+		 * thread may be already happily using PTE we have installed).
+		 * Just ignore error from ->iomap_end since we cannot do much
+		 * with it.
+		 */
+		ops->iomap_end(inode, pos, PAGE_SIZE, copied, flags, &iomap);
 	}
-	return VM_FAULT_NOPAGE | major;
+	return vmf_ret;
 }
 EXPORT_SYMBOL_GPL(dax_iomap_fault);
 
@@ -1332,16 +1339,6 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		goto fallback;
 
 	/*
-	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
-	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
-	 * the tree, for instance), it will return -EEXIST and we just fall
-	 * back to 4k entries.
-	 */
-	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
-	if (IS_ERR(entry))
-		goto fallback;
-
-	/*
 	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
 	 * setting up a mapping, so really we're using iomap_begin() as a way
 	 * to look up our filesystem block.
@@ -1349,10 +1346,21 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	pos = (loff_t)pgoff << PAGE_SHIFT;
 	error = ops->iomap_begin(inode, pos, PMD_SIZE, iomap_flags, &iomap);
 	if (error)
-		goto unlock_entry;
+		goto fallback;
+
 	if (iomap.offset + iomap.length < pos + PMD_SIZE)
 		goto finish_iomap;
 
+	/*
+	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
+	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
+	 * the tree, for instance), it will return -EEXIST and we just fall
+	 * back to 4k entries.
+	 */
+	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
+	if (IS_ERR(entry))
+		goto finish_iomap;
+
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
 	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
@@ -1365,7 +1373,7 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (WARN_ON_ONCE(write))
-			goto finish_iomap;
+			goto unlock_entry;
 		result = dax_pmd_load_hole(vma, pmd, &vmf, address, &iomap,
 				&entry);
 		break;
@@ -1374,20 +1382,23 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		break;
 	}
 
+ unlock_entry:
+	put_locked_mapping_entry(mapping, pgoff, entry);
  finish_iomap:
 	if (ops->iomap_end) {
-		if (result == VM_FAULT_FALLBACK) {
-			ops->iomap_end(inode, pos, PMD_SIZE, 0, iomap_flags,
-					&iomap);
-		} else {
-			error = ops->iomap_end(inode, pos, PMD_SIZE, PMD_SIZE,
-					iomap_flags, &iomap);
-			if (error)
-				result = VM_FAULT_FALLBACK;
-		}
+		int copied = PMD_SIZE;
+
+		if (result == VM_FAULT_FALLBACK)
+			copied = 0;
+		/*
+		 * The fault is done by now and there's no way back (other
+		 * thread may be already happily using PMD we have installed).
+		 * Just ignore error from ->iomap_end since we cannot do much
+		 * with it.
+		 */
+		ops->iomap_end(inode, pos, PMD_SIZE, copied, iomap_flags,
+				&iomap);
 	}
- unlock_entry:
-	put_locked_mapping_entry(mapping, pgoff, entry);
  fallback:
 	if (result == VM_FAULT_FALLBACK) {
 		split_huge_pmd(vma, pmd, address);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
