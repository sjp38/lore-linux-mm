Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2976B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:41:37 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hb4so183986759pac.3
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:41:37 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id e83si11567290pfj.74.2016.04.16.16.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 16:41:36 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id er2so38055056pad.3
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:41:36 -0700 (PDT)
Date: Sat, 16 Apr 2016 16:41:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm 5/5] huge tmpfs: add shmem_pmd_fault()
In-Reply-To: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604161638230.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kernel test robot <xiaolong.ye@intel.com>, Xiong Zhou <jencce.kernel@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The pmd_fault() method gives the filesystem an opportunity to place
a trans huge pmd entry at *pmd, before any pagetable is exposed (and
an opportunity to split it on COW fault): now use it for huge tmpfs.

This patch is a little raw: with more time before LSF/MM, I would
probably want to dress it up better - the shmem_mapping() calls look
a bit ugly; it's odd to want FAULT_FLAG_MAY_HUGE and VM_FAULT_HUGE just
for a private conversation between shmem_fault() and shmem_pmd_fault();
and there might be a better distribution of work between those two, but
prising apart that series of huge tests is not to be done in a hurry.

Good for now, presents the new way, but might be improved later.

This patch still leaves the huge tmpfs map_team_by_pmd() allocating a
pagetable while holding page lock, but other filesystems are no longer
doing so; and we've not yet settled whether huge tmpfs should (like anon
THP) or should not (like DAX) participate in deposit/withdraw protocol.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
I've been testing with this applied on top of mmotm plus 1-4/5,
but I suppose the right place for it is immediately after
huge-tmpfs-map-shmem-by-huge-page-pmd-or-by-page-team-ptes.patch
with a view to perhaps merging it into that in the future.

 mm/huge_memory.c |    4 ++--
 mm/memory.c      |   13 +++++++++----
 mm/shmem.c       |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 44 insertions(+), 6 deletions(-)

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3084,7 +3084,7 @@ void __split_huge_pmd(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 
-	if (!vma_is_anonymous(vma) && !vma->vm_ops->pmd_fault) {
+	if (vma->vm_file && shmem_mapping(vma->vm_file->f_mapping)) {
 		remap_team_by_ptes(vma, address, pmd);
 		return;
 	}
@@ -3622,7 +3622,7 @@ int map_team_by_pmd(struct vm_area_struc
 	pgtable_t pgtable;
 	spinlock_t *pml;
 	pmd_t pmdval;
-	int ret = VM_FAULT_NOPAGE;
+	int ret = 0;
 
 	/*
 	 * Another task may have mapped it in just ahead of us; but we
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3410,6 +3410,7 @@ static int __handle_mm_fault(struct mm_s
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	int ret = 0;
 
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 					    flags & FAULT_FLAG_INSTRUCTION,
@@ -3426,13 +3427,16 @@ static int __handle_mm_fault(struct mm_s
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
-		int ret = create_huge_pmd(mm, vma, address, pmd, flags);
+
+	if (pmd_none(*pmd) &&
+	    (transparent_hugepage_enabled(vma) ||
+	     (vma->vm_file && shmem_mapping(vma->vm_file->f_mapping)))) {
+		ret = create_huge_pmd(mm, vma, address, pmd, flags);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
+		ret &= VM_FAULT_MAJOR;
 	} else {
 		pmd_t orig_pmd = *pmd;
-		int ret;
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
@@ -3447,6 +3451,7 @@ static int __handle_mm_fault(struct mm_s
 							orig_pmd, flags);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
+				ret = 0;
 			} else {
 				huge_pmd_set_accessed(mm, vma, address, pmd,
 						      orig_pmd, dirty);
@@ -3483,7 +3488,7 @@ static int __handle_mm_fault(struct mm_s
 	 */
 	pte = pte_offset_map(pmd, address);
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+	return ret | handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
 /*
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3223,6 +3223,36 @@ single:
 	return ret | VM_FAULT_LOCKED | VM_FAULT_HUGE;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static int shmem_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+			   pmd_t *pmd, unsigned int flags)
+{
+	struct vm_fault vmf;
+	int ret;
+
+	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
+		/* Copy On Write: don't insert huge pmd; or split if already */
+		if (pmd_trans_huge(*pmd))
+			remap_team_by_ptes(vma, address, pmd);
+		return VM_FAULT_FALLBACK;
+	}
+
+	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.pgoff = linear_page_index(vma, address);
+	vmf.flags = flags | FAULT_FLAG_MAY_HUGE;
+
+	ret = shmem_fault(vma, &vmf);
+	if (ret & VM_FAULT_HUGE)
+		return ret | map_team_by_pmd(vma, address, pmd, vmf.page);
+	if (ret & VM_FAULT_ERROR)
+		return ret;
+
+	unlock_page(vmf.page);
+	put_page(vmf.page);
+	return ret | VM_FAULT_FALLBACK;
+}
+#endif
+
 unsigned long shmem_get_unmapped_area(struct file *file,
 				      unsigned long uaddr, unsigned long len,
 				      unsigned long pgoff, unsigned long flags)
@@ -5129,6 +5159,9 @@ static const struct super_operations shm
 
 static const struct vm_operations_struct shmem_vm_ops = {
 	.fault		= shmem_fault,
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	.pmd_fault	= shmem_pmd_fault,
+#endif
 	.map_pages	= filemap_map_pages,
 #ifdef CONFIG_NUMA
 	.set_policy     = shmem_set_policy,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
