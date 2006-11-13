Date: Mon, 13 Nov 2006 16:13:18 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: [hugepage] Fix unmap_and_free_vma backout path
Message-ID: <20061113051318.GD27042@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew, please apply:

If hugetlbfs_file_mmap() returns a failure to do_mmap_pgoff() - for
example, because the given file offset is not hugepage aligned - then
do_mmap_pgoff will go to the unmap_and_free_vma backout path.

But at this stage the vma hasn't been marked as hugepage, and the
backout path will call unmap_region() on it.  That will eventually
call down to the non-hugepage version of unmap_page_range().  On
ppc64, at least, that will cause serious problems if there are any
existing hugepage pagetable entries in the vicinity - for example if
there are any other hugepage mappings under the same PUD.
unmap_page_range() will trigger a bad_pud() on the hugepage pud
entries.  I suspect this will also cause bad problems on ia64, though
I don't have a machine to test it on.

This patch addresses the problem by having hugetlbfs_file_mmap() mark
the vma as hugepage before it does anything else, thus ensuring we use
the right path for any subsequent backout.

This may not be all we want.  Even with this patch, performing such a
failing map on to of an existing mapping will clobber (unmap) that
pre-existing mapping.  This is in contrast to the analogous situation
with normal page mappings - mapping on top with a misaligned offset
will fail early enough not to clobber the pre-existing mapping.

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Index: working-2.6/fs/hugetlbfs/inode.c
===================================================================
--- working-2.6.orig/fs/hugetlbfs/inode.c	2006-11-13 15:49:14.000000000 +1100
+++ working-2.6/fs/hugetlbfs/inode.c	2006-11-13 15:49:29.000000000 +1100
@@ -62,6 +62,9 @@ static int hugetlbfs_file_mmap(struct fi
 	loff_t len, vma_len;
 	int ret;
 
+	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
+	vma->vm_ops = &hugetlb_vm_ops;
+
 	if (vma->vm_pgoff & (HPAGE_SIZE / PAGE_SIZE - 1))
 		return -EINVAL;
 
@@ -78,8 +81,6 @@ static int hugetlbfs_file_mmap(struct fi
 
 	mutex_lock(&inode->i_mutex);
 	file_accessed(file);
-	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
-	vma->vm_ops = &hugetlb_vm_ops;
 
 	ret = -ENOMEM;
 	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
