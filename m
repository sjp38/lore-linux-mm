Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 467A76B00A4
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 07:21:37 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so7173104pbb.12
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 04:21:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id s8si7074312pas.426.2014.04.13.04.21.34
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 04:21:35 -0700 (PDT)
Date: Sun, 13 Apr 2014 07:21:32 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140413112132.GP5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408220525.GC26019@quack.suse.cz>
 <20140409204806.GF5727@linux.intel.com>
 <20140409211203.GP32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409211203.GP32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 11:12:03PM +0200, Jan Kara wrote:
>   This would be fine except that unmap_mapping_range() grabs i_mmap_mutex
> again :-|. But it might be easier to provide a version of that function
> which assumes i_mmap_mutex is already locked than what I was suggesting.

*sigh*.  I knew that once ... which was why the call was after dropping
the lock.  OK, another try at fixing the problem; handle it down in the
insert_pfn code:

diff --git a/fs/dax.c b/fs/dax.c
index 6a8725b..2453025 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -390,7 +390,7 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	error = dax_get_pfn(&bh, &pfn, blkbits);
 	if (error > 0)
-		error = vm_insert_mixed(vma, vaddr, pfn);
+		error = vm_replace_mixed(vma, vaddr, pfn);
 	mutex_unlock(&mapping->i_mmap_mutex);
 
 	if (page) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ba72c54..df25410 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1944,8 +1944,12 @@ int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn);
+int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, bool replace);
+#define vm_insert_mixed(vma, addr, pfn)	\
+	__vm_insert_mixed(vma, addr, pfn, false)
+#define vm_replace_mixed(vma, addr, pfn)	\
+	__vm_insert_mixed(vma, addr, pfn, true)
 int vm_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
 			unsigned long pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
diff --git a/mm/memory.c b/mm/memory.c
index 76fd657..ec59239 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2100,7 +2100,7 @@ pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
  * pages reserved for the old functions anyway.
  */
 static int insert_page(struct vm_area_struct *vma, unsigned long addr,
-			struct page *page, pgprot_t prot)
+			struct page *page, pgprot_t prot, bool replace)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -2116,8 +2116,12 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 	if (!pte)
 		goto out;
 	retval = -EBUSY;
-	if (!pte_none(*pte))
-		goto out_unlock;
+	if (!pte_none(*pte)) {
+		if (!replace)
+			goto out_unlock;
+		VM_BUG_ON(!mutex_is_locked(&vma->vm_file->f_mapping->i_mmap_mutex));
+		zap_page_range_single(vma, addr, PAGE_SIZE, NULL);
+	}
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
@@ -2173,12 +2177,12 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 		BUG_ON(vma->vm_flags & VM_PFNMAP);
 		vma->vm_flags |= VM_MIXEDMAP;
 	}
-	return insert_page(vma, addr, page, vma->vm_page_prot);
+	return insert_page(vma, addr, page, vma->vm_page_prot, false);
 }
 EXPORT_SYMBOL(vm_insert_page);
 
 static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t prot)
+			unsigned long pfn, pgprot_t prot, bool replace)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -2190,8 +2194,12 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	if (!pte)
 		goto out;
 	retval = -EBUSY;
-	if (!pte_none(*pte))
-		goto out_unlock;
+	if (!pte_none(*pte)) {
+		if (!replace)
+			goto out_unlock;
+		VM_BUG_ON(!mutex_is_locked(&vma->vm_file->f_mapping->i_mmap_mutex));
+		zap_page_range_single(vma, addr, PAGE_SIZE, NULL);
+	}
 
 	/* Ok, finally just insert the thing.. */
 	entry = pte_mkspecial(pfn_pte(pfn, prot));
@@ -2244,14 +2252,14 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	if (track_pfn_insert(vma, &pgprot, pfn))
 		return -EINVAL;
 
-	ret = insert_pfn(vma, addr, pfn, pgprot);
+	ret = insert_pfn(vma, addr, pfn, pgprot, false);
 
 	return ret;
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn)
+int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, bool replace)
 {
 	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
 
@@ -2269,11 +2277,11 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		struct page *page;
 
 		page = pfn_to_page(pfn);
-		return insert_page(vma, addr, page, vma->vm_page_prot);
+		return insert_page(vma, addr, page, vma->vm_page_prot, replace);
 	}
-	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
+	return insert_pfn(vma, addr, pfn, vma->vm_page_prot, replace);
 }
-EXPORT_SYMBOL(vm_insert_mixed);
+EXPORT_SYMBOL(__vm_insert_mixed);
 
 static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, unsigned long pfn, pgprot_t prot)

> > > > +int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> > > > +			get_block_t get_block)
> > > > +{
> > > > +	int result;
> > > > +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> > > > +
> > > > +	sb_start_pagefault(sb);
> > >   You don't need any filesystem freeze protection for the fault handler
> > > since that's not going to modify the filesystem.
> > 
> > Err ... we might allocate a block as a result of doing a write to a hole.
> > Or does that not count as 'modifying the filesystem' in this context?
>   Ah, it does. But it would be nice to avoid doing sb_start_pagefault() if
> it's not a write fault - because you don't want to block reading from a
> frozen filesystem (imagine what would happen when you freeze your root
> filesystem to do a snapshot...).
> 
> I have somewhat a mindset of standard pagecache mmap where filemap_fault()
> only reads in data regardless of FAULT_FLAG_WRITE setting so I was confused
> by your difference :).

Understood!  So this should work:

diff --git a/fs/dax.c b/fs/dax.c
index 2453025..e4d00fc 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -431,10 +431,13 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	int result;
 	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
 
-	sb_start_pagefault(sb);
-	file_update_time(vma->vm_file);
+	if (vmf->flags & FAULT_FLAG_WRITE) {
+		sb_start_pagefault(sb);
+		file_update_time(vma->vm_file);
+	}
 	result = do_dax_fault(vma, vmf, get_block);
-	sb_end_pagefault(sb);
+	if (vmf->flags & FAULT_FLAG_WRITE)
+		sb_end_pagefault(sb);
 
 	return result;
 }
@@ -453,15 +456,7 @@ EXPORT_SYMBOL_GPL(dax_fault);
 int dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 			get_block_t get_block)
 {
-	int result;
-	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
-
-	sb_start_pagefault(sb);
-	file_update_time(vma->vm_file);
-	result = do_dax_fault(vma, vmf, get_block);
-	sb_end_pagefault(sb);
-
-	return result;
+	return dax_fault(vma, vmf, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_mkwrite);
 

> > > > +	file_update_time(vma->vm_file);
> > >   Why do you update m/ctime? We are only reading the file...
> > 
> > ... except that it might be a write fault.  I think we modify the file
> > iff we return VM_FAULT_MAJOR from do_dax_fault().  So I'd be open to
> > something like this:
> > 
> > 	sb_start_pagefault(sb);
> > 	result = do_dax_fault(vma, vmf, get_block);
> > 	if (result & VM_FAULT_MAJOR)
> > 		file_update_time(vma->vm_file);
> > 	sb_end_pagefault(sb);
> > 
> > Would that work better for you?
>   Definitely. It's also a performance thing BTW - updating time stamps is
> relatively expensive for journalling filesystems - you have to start a
> transaction, add block with inode to the journal, stop a transaction - not
> something you want to do unless you have to.

I realised that this isn't right.  If you do a store to an mmaped file,
you should update the timestamps, whether or not the fs had to allocate
blocks.  Hence the version above that only checks whether the fault is
for write or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
