Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6F1136B00F9
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 03:03:21 -0500 (EST)
From: Huang Shijie <b32955@freescale.com>
Subject: [PATCH] mm: introduce __linear_page_index()
Date: Tue, 5 Feb 2013 15:03:39 +0800
Message-ID: <1360047819-6669-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Shijie <b32955@freescale.com>

There are many places we should get the offset(in PAGE_SIZE unit) of
an address within a non-hugetlb vma.

In order to simplify the code, add a new helper __linear_page_index()
to do the work.

Signed-off-by: Huang Shijie <b32955@freescale.com>
---

This patch is based on linux-next tree.

---
 arch/arm/mm/fault-armv.c            |    2 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c |    5 ++---
 arch/x86/mm/hugetlbpage.c           |    3 +--
 include/linux/pagemap.h             |   16 ++++++++++++----
 ipc/shm.c                           |    7 ++-----
 mm/hugetlb.c                        |    3 +--
 mm/madvise.c                        |    8 ++++----
 mm/memory.c                         |   10 +++-------
 mm/mempolicy.c                      |    6 ++----
 mm/mlock.c                          |    2 +-
 mm/mprotect.c                       |    2 +-
 mm/mremap.c                         |   14 +++++---------
 mm/shmem.c                          |    5 ++---
 virt/kvm/kvm_main.c                 |    3 +--
 14 files changed, 38 insertions(+), 48 deletions(-)

diff --git a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
index 2a5907b..f50df8a 100644
--- a/arch/arm/mm/fault-armv.c
+++ b/arch/arm/mm/fault-armv.c
@@ -138,7 +138,7 @@ make_coherent(struct address_space *mapping, struct vm_area_struct *vma,
 	pgoff_t pgoff;
 	int aliases = 0;
 
-	pgoff = vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT);
+	pgoff = __linear_page_index(vma, addr);
 
 	/*
 	 * If we have any shared mappings that are in the same mm
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 8cc18ab..a4a893b 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -310,7 +310,7 @@ static long kvmppc_get_guest_page(struct kvm *kvm, unsigned long gfn,
 		    !(vma->vm_flags & VM_PFNMAP))
 			goto up_err;
 		is_io = hpte_cache_bits(pgprot_val(vma->vm_page_prot));
-		pfn = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
+		pfn = __linear_page_index(vma, start);
 		/* check alignment of pfn vs. requested page size */
 		if (psize > PAGE_SIZE && (pfn & ((psize >> PAGE_SHIFT) - 1)))
 			goto up_err;
@@ -658,8 +658,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 		vma = find_vma(current->mm, hva);
 		if (vma && vma->vm_start <= hva && hva + psize <= vma->vm_end &&
 		    (vma->vm_flags & VM_PFNMAP)) {
-			pfn = vma->vm_pgoff +
-				((hva - vma->vm_start) >> PAGE_SHIFT);
+			pfn = __linear_page_index(vma, hva);
 			pte_size = psize;
 			is_io = hpte_cache_bits(pgprot_val(vma->vm_page_prot));
 			write_ok = vma->vm_flags & VM_WRITE;
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index ae1aa71..5dfcd5b 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -69,8 +69,7 @@ huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 {
 	struct vm_area_struct *vma = find_vma(mm, addr);
 	struct address_space *mapping = vma->vm_file->f_mapping;
-	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
-			vma->vm_pgoff;
+	pgoff_t idx = __linear_page_index(vma, addr);
 	struct vm_area_struct *svma;
 	unsigned long saddr;
 	pte_t *spte = NULL;
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0e38e13..03e442a 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -310,15 +310,23 @@ static inline loff_t page_file_offset(struct page *page)
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
 				     unsigned long address);
 
-static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
+/* The offset for an address within a non-hugetlb vma, in PAGE_SIZE unit. */
+static inline pgoff_t __linear_page_index(struct vm_area_struct *vma,
 					unsigned long address)
 {
 	pgoff_t pgoff;
+
+	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
+	return pgoff + vma->vm_pgoff;
+}
+
+static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
+					unsigned long address)
+{
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return linear_hugepage_index(vma, address);
-	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
-	pgoff += vma->vm_pgoff;
-	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	return __linear_page_index(vma, address) >>
+				(PAGE_CACHE_SHIFT - PAGE_SHIFT);
 }
 
 extern void __lock_page(struct page *page);
diff --git a/ipc/shm.c b/ipc/shm.c
index be3ec9a..77b7d02 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1172,9 +1172,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 		 * otherwise it starts at this address with no hassles.
 		 */
 		if ((vma->vm_ops == &shm_vm_ops) &&
-			(vma->vm_start - addr)/PAGE_SIZE == vma->vm_pgoff) {
-
-
+			0 == __linear_page_index(vma, addr)) {
 			size = vma->vm_file->f_path.dentry->d_inode->i_size;
 			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
 			/*
@@ -1201,8 +1199,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 
 		/* finding a matching vma now does not alter retval */
 		if ((vma->vm_ops == &shm_vm_ops) &&
-			(vma->vm_start - addr)/PAGE_SIZE == vma->vm_pgoff)
-
+			0 == __linear_page_index(vma, addr))
 			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
 		vma = next;
 	}
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e14a8c7..756bf6e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2477,8 +2477,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * from page cache lookup which is in HPAGE_SIZE units.
 	 */
 	address = address & huge_page_mask(h);
-	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) +
-			vma->vm_pgoff;
+	pgoff = __linear_page_index(vma, address);
 	mapping = vma->vm_file->f_dentry->d_inode->i_mapping;
 
 	/*
diff --git a/mm/madvise.c b/mm/madvise.c
index c58c94b..51bfaf2 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -100,7 +100,7 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		goto out;
 	}
 
-	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
+	pgoff = __linear_page_index(vma, start);
 	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
 				vma->vm_file, pgoff, vma_policy(vma));
 	if (*prev) {
@@ -193,7 +193,7 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
 	swp_entry_t swap;
 
 	for (; start < end; start += PAGE_SIZE) {
-		index = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+		index = __linear_page_index(vma, start);
 
 		page = find_get_page(mapping, index);
 		if (!radix_tree_exceptional_entry(page)) {
@@ -242,10 +242,10 @@ static long madvise_willneed(struct vm_area_struct * vma,
 	}
 
 	*prev = vma;
-	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	start = __linear_page_index(vma, start);
 	if (end > vma->vm_end)
 		end = vma->vm_end;
-	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	end = __linear_page_index(vma, end);
 
 	force_page_cache_readahead(file->f_mapping, file, start, end - start);
 	return 0;
diff --git a/mm/memory.c b/mm/memory.c
index c04078b..b7e4f04 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -798,9 +798,7 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 				return NULL;
 			goto out;
 		} else {
-			unsigned long off;
-			off = (addr - vma->vm_start) >> PAGE_SHIFT;
-			if (pfn == vma->vm_pgoff + off)
+			if (pfn == __linear_page_index(vma, addr))
 				return NULL;
 			if (!is_cow_mapping(vma->vm_flags))
 				return NULL;
@@ -3404,11 +3402,9 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
-	pgoff_t pgoff = (((address & PAGE_MASK)
-			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-
 	pte_unmap(page_table);
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return __do_fault(mm, vma, address, pmd,
+			__linear_page_index(vma, address), flags, orig_pte);
 }
 
 /*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6f7979c..870f40a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -725,8 +725,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 		if (mpol_equal(vma_policy(vma), new_pol))
 			continue;
 
-		pgoff = vma->vm_pgoff +
-			((vmstart - vma->vm_start) >> PAGE_SHIFT);
+		pgoff = __linear_page_index(vma, vmstart);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
 				  vma->anon_vma, vma->vm_file, pgoff,
 				  new_pol);
@@ -2257,8 +2256,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		BUG_ON(addr >= vma->vm_end);
 		BUG_ON(addr < vma->vm_start);
 
-		pgoff = vma->vm_pgoff;
-		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
+		pgoff = __linear_page_index(vma, addr);
 		polnid = offset_il_node(pol, vma, pgoff);
 		break;
 
diff --git a/mm/mlock.c b/mm/mlock.c
index b1647fb..fb62a2e 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -269,7 +269,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
 		goto out;	/* don't set VM_LOCKED,  don't count */
 
-	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
+	pgoff = __linear_page_index(vma, start);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
 			  vma->vm_file, pgoff, vma_policy(vma));
 	if (*prev) {
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 94722a4..c9d57f0 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -269,7 +269,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	/*
 	 * First try to merge with previous and/or next vma.
 	 */
-	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
+	pgoff = __linear_page_index(vma, start);
 	*pprev = vma_merge(mm, *pprev, start, end, newflags,
 			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
 	if (*pprev) {
diff --git a/mm/mremap.c b/mm/mremap.c
index 38fffd8..640c616 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -240,7 +240,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (err)
 		return err;
 
-	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
+	new_pgoff = __linear_page_index(vma, old_addr);
 	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff,
 			   &need_rmap_locks);
 	if (!new_vma)
@@ -327,8 +327,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 
 		if (vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP))
 			goto Efault;
-		pgoff = (addr - vma->vm_start) >> PAGE_SHIFT;
-		pgoff += vma->vm_pgoff;
+		pgoff = __linear_page_index(vma, addr);
 		if (pgoff + (new_len >> PAGE_SHIFT) < pgoff)
 			goto Einval;
 	}
@@ -409,9 +408,8 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (vma->vm_flags & VM_MAYSHARE)
 		map_flags |= MAP_SHARED;
 
-	ret = get_unmapped_area(vma->vm_file, new_addr, new_len, vma->vm_pgoff +
-				((addr - vma->vm_start) >> PAGE_SHIFT),
-				map_flags);
+	ret = get_unmapped_area(vma->vm_file, new_addr, new_len,
+				__linear_page_index(vma, addr), map_flags);
 	if (ret & ~PAGE_MASK)
 		goto out1;
 
@@ -538,9 +536,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			map_flags |= MAP_SHARED;
 
 		new_addr = get_unmapped_area(vma->vm_file, 0, new_len,
-					vma->vm_pgoff +
-					((addr - vma->vm_start) >> PAGE_SHIFT),
-					map_flags);
+				__linear_page_index(vma, addr), map_flags);
 		if (new_addr & ~PAGE_MASK) {
 			ret = new_addr;
 			goto out;
diff --git a/mm/shmem.c b/mm/shmem.c
index 3049cfc..50e1b38 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1322,10 +1322,9 @@ static struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
 					  unsigned long addr)
 {
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
-	pgoff_t index;
 
-	index = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	return mpol_shared_policy_lookup(&SHMEM_I(inode)->policy, index);
+	return mpol_shared_policy_lookup(&SHMEM_I(inode)->policy,
+			__linear_page_index(vma, addr));
 }
 #endif
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index c94088d..fbbfaf1 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1240,8 +1240,7 @@ static pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (vma == NULL)
 		pfn = KVM_PFN_ERR_FAULT;
 	else if ((vma->vm_flags & VM_PFNMAP)) {
-		pfn = ((addr - vma->vm_start) >> PAGE_SHIFT) +
-			vma->vm_pgoff;
+		pfn = __linear_page_index(vma, addr);
 		BUG_ON(!kvm_is_mmio_pfn(pfn));
 	} else {
 		if (async && vma_is_valid(vma, write_fault))
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
