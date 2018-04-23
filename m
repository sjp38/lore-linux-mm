Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4500F6B000D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 14:04:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k9so4830162pgo.15
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:04:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8sor2391665pfk.89.2018.04.23.11.04.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 11:04:30 -0700 (PDT)
Date: Mon, 23 Apr 2018 23:36:25 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v5] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180423180625.GA16101@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jack@suse.cz, viro@zeniv.linux.org.uk, willy@infradead.org, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, kirill.shutemov@linux.intel.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use new return type vm_fault_t for fault handler. For
now, this is just documenting that the function returns
a VM_FAULT value rather than an errno. Once all instances
are converted, vm_fault_t will become a distinct type.

commit 1c8f422059ae ("mm: change return type to vm_fault_t")

There was an existing bug inside dax_load_hole()
if vm_insert_mixed had failed to allocate a page table,
we'd return VM_FAULT_NOPAGE instead of VM_FAULT_OOM.
With new vmf_insert_mixed() this issue is addressed.

If the insertion of PTE failed because someone else
already added a different entry in the mean time, we
treat that as success as we assume the same entry was
actually inserted.

vm_insert_mixed_mkwrite has inefficiency when it returns
an error value, driver has to convert it to vm_fault_t
type. With new vmf_insert_mixed_mkwrite() this limitation
will be addressed.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
v2: vm_insert_mixed_mkwrite is replaced by new
    vmf_insert_mixed_mkwrite

v3: Addressed Matthew's comment. One patch which
    changes both at the same time. The history
    should be bisectable so that it compiles and
    works at every point.

v4: Updated the change log

v5: Updated the change log


 fs/dax.c            | 78 +++++++++++++++++++++++++----------------------------
 include/linux/dax.h |  4 +--
 include/linux/mm.h  |  4 +--
 mm/memory.c         | 15 ++++++++---
 4 files changed, 52 insertions(+), 49 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index aaec72de..821986c 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -905,12 +905,12 @@ static int dax_iomap_pfn(struct iomap *iomap, loff_t pos, size_t size,
  * If this page is ever written to we will re-fault and change the mapping to
  * point to real DAX storage instead.
  */
-static int dax_load_hole(struct address_space *mapping, void *entry,
+static vm_fault_t dax_load_hole(struct address_space *mapping, void *entry,
 			 struct vm_fault *vmf)
 {
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
-	int ret = VM_FAULT_NOPAGE;
+	vm_fault_t ret = VM_FAULT_NOPAGE;
 	struct page *zero_page;
 	void *entry2;
 	pfn_t pfn;
@@ -929,7 +929,7 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 		goto out;
 	}
 
-	vm_insert_mixed(vmf->vma, vaddr, pfn);
+	ret = vmf_insert_mixed(vmf->vma, vaddr, pfn);
 out:
 	trace_dax_load_hole(inode, vmf, ret);
 	return ret;
@@ -1112,7 +1112,7 @@ int __dax_zero_page_range(struct block_device *bdev,
 }
 EXPORT_SYMBOL_GPL(dax_iomap_rw);
 
-static int dax_fault_return(int error)
+static vm_fault_t dax_fault_return(int error)
 {
 	if (error == 0)
 		return VM_FAULT_NOPAGE;
@@ -1132,7 +1132,7 @@ static bool dax_fault_is_synchronous(unsigned long flags,
 		&& (iomap->flags & IOMAP_F_DIRTY);
 }
 
-static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
+static vm_fault_t dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 			       int *iomap_errp, const struct iomap_ops *ops)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -1145,18 +1145,18 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	int error, major = 0;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	bool sync;
-	int vmf_ret = 0;
+	vm_fault_t ret = 0;
 	void *entry;
 	pfn_t pfn;
 
-	trace_dax_pte_fault(inode, vmf, vmf_ret);
+	trace_dax_pte_fault(inode, vmf, ret);
 	/*
 	 * Check whether offset isn't beyond end of file now. Caller is supposed
 	 * to hold locks serializing us with truncate / punch hole so this is
 	 * a reliable test.
 	 */
 	if (pos >= i_size_read(inode)) {
-		vmf_ret = VM_FAULT_SIGBUS;
+		ret = VM_FAULT_SIGBUS;
 		goto out;
 	}
 
@@ -1165,7 +1165,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 
 	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
 	if (IS_ERR(entry)) {
-		vmf_ret = dax_fault_return(PTR_ERR(entry));
+		ret = dax_fault_return(PTR_ERR(entry));
 		goto out;
 	}
 
@@ -1176,7 +1176,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * retried.
 	 */
 	if (pmd_trans_huge(*vmf->pmd) || pmd_devmap(*vmf->pmd)) {
-		vmf_ret = VM_FAULT_NOPAGE;
+		ret = VM_FAULT_NOPAGE;
 		goto unlock_entry;
 	}
 
@@ -1189,7 +1189,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	if (iomap_errp)
 		*iomap_errp = error;
 	if (error) {
-		vmf_ret = dax_fault_return(error);
+		ret = dax_fault_return(error);
 		goto unlock_entry;
 	}
 	if (WARN_ON_ONCE(iomap.offset + iomap.length < pos + PAGE_SIZE)) {
@@ -1219,9 +1219,9 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 			goto error_finish_iomap;
 
 		__SetPageUptodate(vmf->cow_page);
-		vmf_ret = finish_fault(vmf);
-		if (!vmf_ret)
-			vmf_ret = VM_FAULT_DONE_COW;
+		ret = finish_fault(vmf);
+		if (!ret)
+			ret = VM_FAULT_DONE_COW;
 		goto finish_iomap;
 	}
 
@@ -1257,23 +1257,20 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 				goto error_finish_iomap;
 			}
 			*pfnp = pfn;
-			vmf_ret = VM_FAULT_NEEDDSYNC | major;
+			ret = VM_FAULT_NEEDDSYNC | major;
 			goto finish_iomap;
 		}
 		trace_dax_insert_mapping(inode, vmf, entry);
 		if (write)
-			error = vm_insert_mixed_mkwrite(vma, vaddr, pfn);
+			ret = vmf_insert_mixed_mkwrite(vma, vaddr, pfn);
 		else
-			error = vm_insert_mixed(vma, vaddr, pfn);
+			ret = vmf_insert_mixed(vma, vaddr, pfn);
 
-		/* -EBUSY is fine, somebody else faulted on the same PTE */
-		if (error == -EBUSY)
-			error = 0;
-		break;
+		goto finish_iomap;
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (!write) {
-			vmf_ret = dax_load_hole(mapping, entry, vmf);
+			ret = dax_load_hole(mapping, entry, vmf);
 			goto finish_iomap;
 		}
 		/*FALLTHRU*/
@@ -1284,12 +1281,12 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	}
 
  error_finish_iomap:
-	vmf_ret = dax_fault_return(error) | major;
+	ret = dax_fault_return(error);
  finish_iomap:
 	if (ops->iomap_end) {
 		int copied = PAGE_SIZE;
 
-		if (vmf_ret & VM_FAULT_ERROR)
+		if (ret & VM_FAULT_ERROR)
 			copied = 0;
 		/*
 		 * The fault is done by now and there's no way back (other
@@ -1302,12 +1299,12 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
  unlock_entry:
 	put_locked_mapping_entry(mapping, vmf->pgoff);
  out:
-	trace_dax_pte_fault_done(inode, vmf, vmf_ret);
-	return vmf_ret;
+	trace_dax_pte_fault_done(inode, vmf, ret);
+	return ret | major;
 }
 
 #ifdef CONFIG_FS_DAX_PMD
-static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
+static vm_fault_t dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 		void *entry)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
@@ -1348,7 +1345,7 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 	return VM_FAULT_FALLBACK;
 }
 
-static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
+static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 			       const struct iomap_ops *ops)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -1358,7 +1355,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	bool sync;
 	unsigned int iomap_flags = (write ? IOMAP_WRITE : 0) | IOMAP_FAULT;
 	struct inode *inode = mapping->host;
-	int result = VM_FAULT_FALLBACK;
+	vm_fault_t result = VM_FAULT_FALLBACK;
 	struct iomap iomap = { 0 };
 	pgoff_t max_pgoff, pgoff;
 	void *entry;
@@ -1509,7 +1506,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	return result;
 }
 #else
-static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
+static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 			       const struct iomap_ops *ops)
 {
 	return VM_FAULT_FALLBACK;
@@ -1529,7 +1526,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
  * has done all the necessary locking for page fault to proceed
  * successfully.
  */
-int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
+vm_fault_t dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
 		    pfn_t *pfnp, int *iomap_errp, const struct iomap_ops *ops)
 {
 	switch (pe_size) {
@@ -1553,14 +1550,14 @@ int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
  * DAX file.  It takes care of marking corresponding radix tree entry as dirty
  * as well.
  */
-static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
+static vm_fault_t dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 				  enum page_entry_size pe_size,
 				  pfn_t pfn)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
 	void *entry, **slot;
 	pgoff_t index = vmf->pgoff;
-	int vmf_ret, error;
+	vm_fault_t ret;
 
 	xa_lock_irq(&mapping->i_pages);
 	entry = get_unlocked_mapping_entry(mapping, index, &slot);
@@ -1579,21 +1576,20 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 	xa_unlock_irq(&mapping->i_pages);
 	switch (pe_size) {
 	case PE_SIZE_PTE:
-		error = vm_insert_mixed_mkwrite(vmf->vma, vmf->address, pfn);
-		vmf_ret = dax_fault_return(error);
+		ret = vmf_insert_mixed_mkwrite(vmf->vma, vmf->address, pfn);
 		break;
 #ifdef CONFIG_FS_DAX_PMD
 	case PE_SIZE_PMD:
-		vmf_ret = vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd,
+		ret = vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd,
 			pfn, true);
 		break;
 #endif
 	default:
-		vmf_ret = VM_FAULT_FALLBACK;
+		ret = VM_FAULT_FALLBACK;
 	}
 	put_locked_mapping_entry(mapping, index);
-	trace_dax_insert_pfn_mkwrite(mapping->host, vmf, vmf_ret);
-	return vmf_ret;
+	trace_dax_insert_pfn_mkwrite(mapping->host, vmf, ret);
+	return ret;
 }
 
 /**
@@ -1606,8 +1602,8 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
  * stored persistently on the media and handles inserting of appropriate page
  * table entry.
  */
-int dax_finish_sync_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
-			  pfn_t pfn)
+vm_fault_t dax_finish_sync_fault(struct vm_fault *vmf,
+		enum page_entry_size pe_size, pfn_t pfn)
 {
 	int err;
 	loff_t start = ((loff_t)vmf->pgoff) << PAGE_SHIFT;
diff --git a/include/linux/dax.h b/include/linux/dax.h
index f9eb22a..7fddea8 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -124,8 +124,8 @@ ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		const struct iomap_ops *ops);
 int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
 		    pfn_t *pfnp, int *errp, const struct iomap_ops *ops);
-int dax_finish_sync_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
-			  pfn_t pfn);
+vm_fault_t dax_finish_sync_fault(struct vm_fault *vmf,
+		enum page_entry_size pe_size, pfn_t pfn);
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
 int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 				      pgoff_t index);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06..9fe441c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2423,8 +2423,8 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
-int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn);
+vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
+		unsigned long addr, pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 static inline vm_fault_t vmf_insert_page(struct vm_area_struct *vma,
diff --git a/mm/memory.c b/mm/memory.c
index 01f5464..721cfd5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1955,12 +1955,19 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
-int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn)
+vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
+		unsigned long addr, pfn_t pfn)
 {
-	return __vm_insert_mixed(vma, addr, pfn, true);
+	int err;
+
+	err =  __vm_insert_mixed(vma, addr, pfn, true);
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	if (err < 0 && err != -EBUSY)
+		return VM_FAULT_SIGBUS;
+	return VM_FAULT_NOPAGE;
 }
-EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
+EXPORT_SYMBOL(vmf_insert_mixed_mkwrite);
 
 /*
  * maps a range of physical memory into the requested pages. the old
-- 
1.9.1
