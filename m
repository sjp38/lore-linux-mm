Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 246056B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 23:24:29 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y26so6550880pfe.9
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 20:24:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h63si10117475pge.435.2018.01.12.20.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Jan 2018 20:24:27 -0800 (PST)
Date: Fri, 12 Jan 2018 20:23:54 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 22/24] mm: Speculative page fault handler return VMA
Message-ID: <20180113042354.GA24241@bombadil.infradead.org>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1515777968-867-23-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180112190251.GC7590@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180112190251.GC7590@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Fri, Jan 12, 2018 at 11:02:51AM -0800, Matthew Wilcox wrote:
> On Fri, Jan 12, 2018 at 06:26:06PM +0100, Laurent Dufour wrote:
> > @@ -1354,7 +1354,10 @@ extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
> >  		unsigned int flags);
> >  #ifdef CONFIG_SPF
> >  extern int handle_speculative_fault(struct mm_struct *mm,
> > +				    unsigned long address, unsigned int flags,
> > +				    struct vm_area_struct **vma);
> 
> I think this shows that we need to create 'struct vm_fault' on the stack
> in the arch code and then pass it to handle_speculative_fault(), followed
> by handle_mm_fault().  That should be quite a nice cleanup actually.
> I know that's only 30+ architectures to change ;-)

Of course, we don't need to change them all.  Try this:

Subject: [PATCH] Add vm_handle_fault

For the speculative fault handler, we want to create the struct vm_fault
on the stack in the arch code and pass it into the generic mm code.
To avoid changing 30+ architectures, leave handle_mm_fault with its
current function signature and move its guts into the new vm_handle_fault
function.  Even this saves a nice 172 bytes on the random x86-64 .config
I happen to have around.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/mm/memory.c b/mm/memory.c
index 5eb3d2524bdc..403934297a3d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3977,36 +3977,28 @@ static int handle_pte_fault(struct vm_fault *vmf)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+static int __handle_mm_fault(struct vm_fault *vmf)
 {
-	struct vm_fault vmf = {
-		.vma = vma,
-		.address = address & PAGE_MASK,
-		.flags = flags,
-		.pgoff = linear_page_index(vma, address),
-		.gfp_mask = __get_fault_gfp_mask(vma),
-	};
-	unsigned int dirty = flags & FAULT_FLAG_WRITE;
-	struct mm_struct *mm = vma->vm_mm;
+	unsigned int dirty = vmf->flags & FAULT_FLAG_WRITE;
+	struct mm_struct *mm = vmf->vma->vm_mm;
 	pgd_t *pgd;
 	p4d_t *p4d;
 	int ret;
 
-	pgd = pgd_offset(mm, address);
-	p4d = p4d_alloc(mm, pgd, address);
+	pgd = pgd_offset(mm, vmf->address);
+	p4d = p4d_alloc(mm, pgd, vmf->address);
 	if (!p4d)
 		return VM_FAULT_OOM;
 
-	vmf.pud = pud_alloc(mm, p4d, address);
-	if (!vmf.pud)
+	vmf->pud = pud_alloc(mm, p4d, vmf->address);
+	if (!vmf->pud)
 		return VM_FAULT_OOM;
-	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)) {
-		ret = create_huge_pud(&vmf);
+	if (pud_none(*vmf->pud) && transparent_hugepage_enabled(vmf->vma)) {
+		ret = create_huge_pud(vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-		pud_t orig_pud = *vmf.pud;
+		pud_t orig_pud = *vmf->pud;
 
 		barrier();
 		if (pud_trans_huge(orig_pud) || pud_devmap(orig_pud)) {
@@ -4014,50 +4006,51 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 			/* NUMA case for anonymous PUDs would go here */
 
 			if (dirty && !pud_access_permitted(orig_pud, WRITE)) {
-				ret = wp_huge_pud(&vmf, orig_pud);
+				ret = wp_huge_pud(vmf, orig_pud);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-				huge_pud_set_accessed(&vmf, orig_pud);
+				huge_pud_set_accessed(vmf, orig_pud);
 				return 0;
 			}
 		}
 	}
 
-	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
-	if (!vmf.pmd)
+	vmf->pmd = pmd_alloc(mm, vmf->pud, vmf->address);
+	if (!vmf->pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
-		ret = create_huge_pmd(&vmf);
+	if (pmd_none(*vmf->pmd) && transparent_hugepage_enabled(vmf->vma)) {
+		ret = create_huge_pmd(vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-		pmd_t orig_pmd = *vmf.pmd;
+		pmd_t orig_pmd = *vmf->pmd;
 
 		barrier();
 		if (unlikely(is_swap_pmd(orig_pmd))) {
 			VM_BUG_ON(thp_migration_supported() &&
 					  !is_pmd_migration_entry(orig_pmd));
 			if (is_pmd_migration_entry(orig_pmd))
-				pmd_migration_entry_wait(mm, vmf.pmd);
+				pmd_migration_entry_wait(mm, vmf->pmd);
 			return 0;
 		}
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
-			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
-				return do_huge_pmd_numa_page(&vmf, orig_pmd);
+			if (pmd_protnone(orig_pmd) &&
+						vma_is_accessible(vmf->vma))
+				return do_huge_pmd_numa_page(vmf, orig_pmd);
 
 			if (dirty && !pmd_access_permitted(orig_pmd, WRITE)) {
-				ret = wp_huge_pmd(&vmf, orig_pmd);
+				ret = wp_huge_pmd(vmf, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-				huge_pmd_set_accessed(&vmf, orig_pmd);
+				huge_pmd_set_accessed(vmf, orig_pmd);
 				return 0;
 			}
 		}
 	}
 
-	return handle_pte_fault(&vmf);
+	return handle_pte_fault(vmf);
 }
 
 /*
@@ -4066,9 +4059,10 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+int vm_handle_fault(struct vm_fault *vmf)
 {
+	unsigned int flags = vmf->flags;
+	struct vm_area_struct *vma = vmf->vma;
 	int ret;
 
 	__set_current_state(TASK_RUNNING);
@@ -4092,9 +4086,9 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		mem_cgroup_oom_enable();
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
-		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
+		ret = hugetlb_fault(vma->vm_mm, vma, vmf->address, flags);
 	else
-		ret = __handle_mm_fault(vma, address, flags);
+		ret = __handle_mm_fault(vmf);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
@@ -4110,6 +4104,26 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
 	return ret;
 }
+
+/*
+ * By the time we get here, we already hold the mm semaphore
+ *
+ * The mmap_sem may have been released depending on flags and our
+ * return value.  See filemap_fault() and __lock_page_or_retry().
+ */
+int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+		unsigned int flags)
+{
+	struct vm_fault vmf = {
+		.vma = vma,
+		.address = address & PAGE_MASK,
+		.flags = flags,
+		.pgoff = linear_page_index(vma, address),
+		.gfp_mask = __get_fault_gfp_mask(vma),
+	};
+
+	return vm_handle_fault(&vmf);
+}
 EXPORT_SYMBOL_GPL(handle_mm_fault);
 
 #ifndef __PAGETABLE_P4D_FOLDED

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
