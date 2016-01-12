Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 54CEB4403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 08:30:01 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so63054503pff.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 05:30:01 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rd6si10355132pab.153.2016.01.12.05.30.00
        for <linux-mm@kvack.org>;
        Tue, 12 Jan 2016 05:30:00 -0800 (PST)
Date: Tue, 12 Jan 2016 08:29:57 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCHSET 0/2] Allow single pagefault in write access of a
 VM_MIXEDMAP mapping
Message-ID: <20160112132957.GA21285@linux.intel.com>
References: <569263BA.5060503@plexistor.com>
 <20160111193523.GA8945@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160111193523.GA8945@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Jan 11, 2016 at 02:35:23PM -0500, Matthew Wilcox wrote:
> I would rather see the memory.c code move in the direction of the
> huge_memory.c code.  How about something like this?

Whoops, missed some bits in the DAX conversion where we'd return an -errno instead of VM_FAULT flags.  Take two.

diff --git a/fs/dax.c b/fs/dax.c
index a610cbe..deff70f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -498,6 +498,7 @@ EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	const bool write = vmf->flags & FAULT_FLAG_WRITE;
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
 	struct address_space *mapping = inode->i_mapping;
 	struct block_device *bdev = bh->b_bdev;
@@ -506,7 +507,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		.size = bh->b_size,
 	};
 	pgoff_t size;
-	int error;
+	int result;
 
 	i_mmap_lock_read(mapping);
 
@@ -518,15 +519,11 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
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
@@ -534,17 +531,19 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
-	error = dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
-			vmf->flags & FAULT_FLAG_WRITE);
-	if (error)
-		goto out;
+	if (dax_radix_entry(mapping, vmf->pgoff, dax.sector, false, write))
+		goto sigbus;
 
-	error = vm_insert_mixed(vma, vaddr, dax.pfn);
+	result = vmf_insert_pfn(vma, vaddr, dax.pfn, write);
 
  out:
 	i_mmap_unlock_read(mapping);
 
-	return error;
+	return result;
+
+ sigbus:
+	result = VM_FAULT_SIGBUS;
+	goto out;
 }
 
 static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
@@ -559,7 +558,7 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	unsigned blkbits = inode->i_blkbits;
 	sector_t block;
 	pgoff_t size;
-	int error;
+	int result, error;
 	int major = 0;
 
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
@@ -660,13 +659,14 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 27dbd1b..a95242c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2170,8 +2170,10 @@ struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
-int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+int vm_insert_pfn(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn);
+int vmf_insert_pfn(struct vm_area_struct *, unsigned long addr,
+			pfn_t pfn, bool write);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
diff --git a/mm/memory.c b/mm/memory.c
index 708a0c7c..b93bcba 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1505,8 +1505,15 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+static pte_t maybe_pte_mkwrite(pte_t pte, struct vm_area_struct *vma)
+{
+	if (likely(vma->vm_flags & VM_WRITE))
+		pte = pte_mkwrite(pte);
+	return pte;
+}
+
 static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn, pgprot_t prot)
+			pfn_t pfn, pgprot_t prot, bool write)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -1526,6 +1533,10 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 		entry = pte_mkdevmap(pfn_t_pte(pfn, prot));
 	else
 		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
+	if (write) {
+		entry = pte_mkyoung(pte_mkdirty(entry));
+		entry = maybe_pte_mkwrite(entry, vma);
+	}
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
@@ -1537,26 +1548,28 @@ out:
 }
 
 /**
- * vm_insert_pfn - insert single pfn into user vma
+ * vmf_insert_pfn - insert single pfn into user vma
  * @vma: user vma to map to
  * @addr: target user address of this page
  * @pfn: source kernel pfn
+ * @write: Whether to insert a writable entry
  *
  * Similar to vm_insert_page, this allows drivers to insert individual pages
  * they've allocated into a user vma. Same comments apply.
  *
  * This function should only be called from a vm_ops->fault handler, and
- * in that case the handler should return NULL.
+ * the return value from this function is suitable for returning from that
+ * handler.
  *
  * vma cannot be a COW mapping.
  *
  * As this is called only for pages that do not currently exist, we
  * do not need to flush old virtual caches or the TLB.
  */
-int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn)
+int vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+			pfn_t pfn, bool write)
 {
-	int ret;
+	int error;
 	pgprot_t pgprot = vma->vm_page_prot;
 	/*
 	 * Technically, architectures with pte_special can avoid all these
@@ -1568,16 +1581,29 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_t_valid(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
-		return -EFAULT;
-	if (track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV)))
-		return -EINVAL;
+		return VM_FAULT_SIGBUS;
+	if (track_pfn_insert(vma, &pgprot, pfn))
+		return VM_FAULT_SIGBUS;
 
-	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
+	error = insert_pfn(vma, addr, pfn, pgprot, write);
+	if (error == -EBUSY || !error)
+		return VM_FAULT_NOPAGE;
+	return VM_FAULT_SIGBUS;
+}
+EXPORT_SYMBOL(vmf_insert_pfn);
 
-	return ret;
+/* TODO: Convert users to vmf_insert_pfn */
+int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn)
+{
+	int result = vmf_insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV),
+								false);
+	if (result & VM_FAULT_ERROR)
+		return -EFAULT;
+	return 0;
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
@@ -1602,7 +1628,7 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		page = pfn_t_to_page(pfn);
 		return insert_page(vma, addr, page, vma->vm_page_prot);
 	}
-	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
+	return insert_pfn(vma, addr, pfn, vma->vm_page_prot, false);
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
