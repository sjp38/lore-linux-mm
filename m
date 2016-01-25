Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1616B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:26:12 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id n128so84910573pfn.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:26:12 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id n9si34860949pap.49.2016.01.25.09.26.11
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 09:26:11 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 3/3] dax: Handle write faults more efficiently
Date: Mon, 25 Jan 2016 12:25:17 -0500
Message-Id: <1453742717-10326-4-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Matthew Wilcox <willy@linux.intel.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

When we handle a write-fault on a DAX mapping, we currently insert a
read-only mapping and then take the page fault again to convert it to
a writable mapping.  This is necessary for the case where we cover a
hole with a read-only zero page, but when we have a data block already
allocated, it is inefficient.

Use the recently added vmf_insert_pfn_prot() to insert a writable mapping,
even though the default VM flags say to use a read-only mapping.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c | 73 ++++++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 53 insertions(+), 20 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 206650f..3f6138d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -519,9 +519,44 @@ int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
 }
 EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
 
+/*
+ * The default page protections for DAX VMAs are set to "copy" so that
+ * we get notifications when zero pages are written to.  This function
+ * is called when we're inserting a mapping to a data page.  If this is
+ * a write fault, we've already done all the necessary accounting and
+ * it's pointless to insert this translation entry read-only.  Convert
+ * the pgprot to be writable.
+ *
+ * While this is not the most elegant code, the compiler can see that (on
+ * any sane architecture) all four arms of the conditional are the same.
+ */
+static pgprot_t dax_pgprot(struct vm_area_struct *vma, bool write)
+{
+	pgprot_t pgprot = vma->vm_page_prot;
+	if (!write)
+		return pgprot;
+	if ((vma->vm_flags & (VM_READ|VM_EXEC)) == (VM_READ|VM_EXEC))
+		return __pgprot(pgprot_val(pgprot) ^
+				pgprot_val(__P111) ^
+				pgprot_val(__S111));
+	else if ((vma->vm_flags & (VM_READ|VM_EXEC)) == VM_READ)
+		return __pgprot(pgprot_val(pgprot) ^
+				pgprot_val(__P110) ^
+				pgprot_val(__S110));
+	else if ((vma->vm_flags & (VM_READ|VM_EXEC)) == VM_EXEC)
+		return __pgprot(pgprot_val(pgprot) ^
+				pgprot_val(__P011) ^
+				pgprot_val(__S011));
+	else
+		return __pgprot(pgprot_val(pgprot) ^
+				pgprot_val(__P010) ^
+				pgprot_val(__S010));
+}
+
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
 	struct address_space *mapping = inode->i_mapping;
 	struct block_device *bdev = bh->b_bdev;
@@ -530,7 +565,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		.size = bh->b_size,
 	};
 	pgoff_t size;
-	int error;
+	int result;
 
 	i_mmap_lock_read(mapping);
 
@@ -542,15 +577,11 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	 * allocated past the end of the file.
 	 */
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (unlikely(vmf->pgoff >= size)) {
-		error = -EIO;
-		goto out;
-	}
+	if (unlikely(vmf->pgoff >= size))
+		goto sigbus;
 
-	if (dax_map_atomic(bdev, &dax) < 0) {
-		error = PTR_ERR(dax.addr);
-		goto out;
-	}
+	if (dax_map_atomic(bdev, &dax) < 0)
+		goto sigbus;
 
 	if (buffer_unwritten(bh) || buffer_new(bh)) {
 		clear_pmem(dax.addr, PAGE_SIZE);
@@ -558,17 +589,19 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
-	error = dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
-			vmf->flags & FAULT_FLAG_WRITE);
-	if (error)
-		goto out;
+	if (dax_radix_entry(mapping, vmf->pgoff, dax.sector, false, write))
+		goto sigbus;
 
-	error = vm_insert_mixed(vma, vaddr, dax.pfn);
+	result = vmf_insert_pfn_prot(vma, vaddr, dax.pfn,
+					dax_pgprot(vma, write));
 
  out:
 	i_mmap_unlock_read(mapping);
+	return result;
 
-	return error;
+ sigbus:
+	result = VM_FAULT_SIGBUS;
+	goto out;
 }
 
 /**
@@ -599,7 +632,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	unsigned blkbits = inode->i_blkbits;
 	sector_t block;
 	pgoff_t size;
-	int error;
+	int result, error;
 	int major = 0;
 
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
@@ -701,19 +734,19 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 * indicate what the callback should do via the uptodate variable, same
 	 * as for normal BH based IO completions.
 	 */
-	error = dax_insert_mapping(inode, &bh, vma, vmf);
+	result = dax_insert_mapping(inode, &bh, vma, vmf);
 	if (buffer_unwritten(&bh)) {
 		if (complete_unwritten)
-			complete_unwritten(&bh, !error);
+			complete_unwritten(&bh, !(result & VM_FAULT_ERROR));
 		else
 			WARN_ON_ONCE(!(vmf->flags & FAULT_FLAG_WRITE));
 	}
+	return result | major;
 
  out:
 	if (error == -ENOMEM)
 		return VM_FAULT_OOM | major;
-	/* -EBUSY is fine, somebody else faulted on the same PTE */
-	if ((error < 0) && (error != -EBUSY))
+	if (error < 0)
 		return VM_FAULT_SIGBUS | major;
 	return VM_FAULT_NOPAGE | major;
 
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
