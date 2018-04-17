Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9D06B0012
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:19 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c21so5330901qtn.0
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:34:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 3si2341144qtp.263.2018.04.17.07.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:34:17 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HEWWcl053895
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:16 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hdj8n2bfm-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:15 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:34:12 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 09/25] mm: protect VMA modifications using VMA sequence count
Date: Tue, 17 Apr 2018 16:33:15 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

The VMA sequence count has been introduced to allow fast detection of
VMA modification when running a page fault handler without holding
the mmap_sem.

This patch provides protection against the VMA modification done in :
	- madvise()
	- mpol_rebind_policy()
	- vma_replace_policy()
	- change_prot_numa()
	- mlock(), munlock()
	- mprotect()
	- mmap_region()
	- collapse_huge_page()
	- userfaultd registering services

In addition, VMA fields which will be read during the speculative fault
path needs to be written using WRITE_ONCE to prevent write to be split
and intermediate values to be pushed to other CPUs.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 fs/proc/task_mmu.c |  5 ++++-
 fs/userfaultfd.c   | 17 +++++++++++++----
 mm/khugepaged.c    |  3 +++
 mm/madvise.c       |  6 +++++-
 mm/mempolicy.c     | 51 ++++++++++++++++++++++++++++++++++-----------------
 mm/mlock.c         | 13 ++++++++-----
 mm/mmap.c          | 22 +++++++++++++---------
 mm/mprotect.c      |  4 +++-
 mm/swap_state.c    |  8 ++++++--
 9 files changed, 89 insertions(+), 40 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c486ad4b43f0..aeb417f28839 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1136,8 +1136,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					goto out_mm;
 				}
 				for (vma = mm->mmap; vma; vma = vma->vm_next) {
-					vma->vm_flags &= ~VM_SOFTDIRTY;
+					vm_write_begin(vma);
+					WRITE_ONCE(vma->vm_flags,
+						   vma->vm_flags & ~VM_SOFTDIRTY);
 					vma_set_page_prot(vma);
+					vm_write_end(vma);
 				}
 				downgrade_write(&mm->mmap_sem);
 				break;
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cec550c8468f..b8212ba17695 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -659,8 +659,11 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 
 	octx = vma->vm_userfaultfd_ctx.ctx;
 	if (!octx || !(octx->features & UFFD_FEATURE_EVENT_FORK)) {
+		vm_write_begin(vma);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
-		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
+		WRITE_ONCE(vma->vm_flags,
+			   vma->vm_flags & ~(VM_UFFD_WP | VM_UFFD_MISSING));
+		vm_write_end(vma);
 		return 0;
 	}
 
@@ -885,8 +888,10 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 			vma = prev;
 		else
 			prev = vma;
-		vma->vm_flags = new_flags;
+		vm_write_begin(vma);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		vm_write_end(vma);
 	}
 	up_write(&mm->mmap_sem);
 	mmput(mm);
@@ -1434,8 +1439,10 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		 * the next vma was merged into the current one and
 		 * the current one has not been updated yet.
 		 */
-		vma->vm_flags = new_flags;
+		vm_write_begin(vma);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx.ctx = ctx;
+		vm_write_end(vma);
 
 	skip:
 		prev = vma;
@@ -1592,8 +1599,10 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * the next vma was merged into the current one and
 		 * the current one has not been updated yet.
 		 */
-		vma->vm_flags = new_flags;
+		vm_write_begin(vma);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		vm_write_end(vma);
 
 	skip:
 		prev = vma;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4bf8671..0b28af4b950d 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1011,6 +1011,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (mm_find_pmd(mm, address) != pmd)
 		goto out;
 
+	vm_write_begin(vma);
 	anon_vma_lock_write(vma->anon_vma);
 
 	pte = pte_offset_map(pmd, address);
@@ -1046,6 +1047,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
 		spin_unlock(pmd_ptl);
 		anon_vma_unlock_write(vma->anon_vma);
+		vm_write_end(vma);
 		result = SCAN_FAIL;
 		goto out;
 	}
@@ -1080,6 +1082,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache_pmd(vma, address, pmd);
 	spin_unlock(pmd_ptl);
+	vm_write_end(vma);
 
 	*hpage = NULL;
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..e328f7ab5942 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -184,7 +184,9 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
-	vma->vm_flags = new_flags;
+	vm_write_begin(vma);
+	WRITE_ONCE(vma->vm_flags, new_flags);
+	vm_write_end(vma);
 out:
 	return error;
 }
@@ -450,9 +452,11 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
 		.private = tlb,
 	};
 
+	vm_write_begin(vma);
 	tlb_start_vma(tlb, vma);
 	walk_page_range(addr, end, &free_walk);
 	tlb_end_vma(tlb, vma);
+	vm_write_end(vma);
 }
 
 static int madvise_free_single_vma(struct vm_area_struct *vma,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9ac49ef17b4e..898d325c9fea 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -380,8 +380,11 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		vm_write_begin(vma);
 		mpol_rebind_policy(vma->vm_policy, new);
+		vm_write_end(vma);
+	}
 	up_write(&mm->mmap_sem);
 }
 
@@ -554,9 +557,11 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
+	vm_write_begin(vma);
 	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
+	vm_write_end(vma);
 
 	return nr_updated;
 }
@@ -657,6 +662,7 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
+	vm_write_begin(vma);
 	if (vma->vm_ops && vma->vm_ops->set_policy) {
 		err = vma->vm_ops->set_policy(vma, new);
 		if (err)
@@ -664,11 +670,17 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	}
 
 	old = vma->vm_policy;
-	vma->vm_policy = new; /* protected by mmap_sem */
+	/*
+	 * The speculative page fault handler accesses this field without
+	 * hodling the mmap_sem.
+	 */
+	WRITE_ONCE(vma->vm_policy,  new);
+	vm_write_end(vma);
 	mpol_put(old);
 
 	return 0;
  err_out:
+	vm_write_end(vma);
 	mpol_put(new);
 	return err;
 }
@@ -1614,23 +1626,28 @@ COMPAT_SYSCALL_DEFINE4(migrate_pages, compat_pid_t, pid,
 struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
 						unsigned long addr)
 {
-	struct mempolicy *pol = NULL;
+	struct mempolicy *pol;
 
-	if (vma) {
-		if (vma->vm_ops && vma->vm_ops->get_policy) {
-			pol = vma->vm_ops->get_policy(vma, addr);
-		} else if (vma->vm_policy) {
-			pol = vma->vm_policy;
+	if (!vma)
+		return NULL;
 
-			/*
-			 * shmem_alloc_page() passes MPOL_F_SHARED policy with
-			 * a pseudo vma whose vma->vm_ops=NULL. Take a reference
-			 * count on these policies which will be dropped by
-			 * mpol_cond_put() later
-			 */
-			if (mpol_needs_cond_ref(pol))
-				mpol_get(pol);
-		}
+	if (vma->vm_ops && vma->vm_ops->get_policy)
+		return vma->vm_ops->get_policy(vma, addr);
+
+	/*
+	 * This could be called without holding the mmap_sem in the
+	 * speculative page fault handler's path.
+	 */
+	pol = READ_ONCE(vma->vm_policy);
+	if (pol) {
+		/*
+		 * shmem_alloc_page() passes MPOL_F_SHARED policy with
+		 * a pseudo vma whose vma->vm_ops=NULL. Take a reference
+		 * count on these policies which will be dropped by
+		 * mpol_cond_put() later
+		 */
+		if (mpol_needs_cond_ref(pol))
+			mpol_get(pol);
 	}
 
 	return pol;
diff --git a/mm/mlock.c b/mm/mlock.c
index 74e5a6547c3d..c40285c94ced 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -445,7 +445,9 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
-	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+	vm_write_begin(vma);
+	WRITE_ONCE(vma->vm_flags, vma->vm_flags & VM_LOCKED_CLEAR_MASK);
+	vm_write_end(vma);
 
 	while (start < end) {
 		struct page *page;
@@ -568,10 +570,11 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, populate_vma_page_range will bring it back.
 	 */
-
-	if (lock)
-		vma->vm_flags = newflags;
-	else
+	if (lock) {
+		vm_write_begin(vma);
+		WRITE_ONCE(vma->vm_flags, newflags);
+		vm_write_end(vma);
+	} else
 		munlock_vma_pages_range(vma, start, end);
 
 out:
diff --git a/mm/mmap.c b/mm/mmap.c
index 813e49589ea1..921f20cc6df0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -843,17 +843,18 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	}
 
 	if (start != vma->vm_start) {
-		vma->vm_start = start;
+		WRITE_ONCE(vma->vm_start, start);
 		start_changed = true;
 	}
 	if (end != vma->vm_end) {
-		vma->vm_end = end;
+		WRITE_ONCE(vma->vm_end, end);
 		end_changed = true;
 	}
-	vma->vm_pgoff = pgoff;
+	WRITE_ONCE(vma->vm_pgoff, pgoff);
 	if (adjust_next) {
-		next->vm_start += adjust_next << PAGE_SHIFT;
-		next->vm_pgoff += adjust_next;
+		WRITE_ONCE(next->vm_start,
+			   next->vm_start + (adjust_next << PAGE_SHIFT));
+		WRITE_ONCE(next->vm_pgoff, next->vm_pgoff + adjust_next);
 	}
 
 	if (root) {
@@ -1784,13 +1785,15 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 out:
 	perf_event_mmap(vma);
 
+	vm_write_begin(vma);
 	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
 					vma == get_gate_vma(current->mm)))
 			mm->locked_vm += (len >> PAGE_SHIFT);
 		else
-			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+			WRITE_ONCE(vma->vm_flags,
+				   vma->vm_flags & VM_LOCKED_CLEAR_MASK);
 	}
 
 	if (file)
@@ -1803,9 +1806,10 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	 * then new mapped in-place (which must be aimed as
 	 * a completely new data area).
 	 */
-	vma->vm_flags |= VM_SOFTDIRTY;
+	WRITE_ONCE(vma->vm_flags, vma->vm_flags | VM_SOFTDIRTY);
 
 	vma_set_page_prot(vma);
+	vm_write_end(vma);
 
 	return addr;
 
@@ -2434,8 +2438,8 @@ int expand_downwards(struct vm_area_struct *vma,
 					mm->locked_vm += grow;
 				vm_stat_account(mm, vma->vm_flags, grow);
 				anon_vma_interval_tree_pre_update_vma(vma);
-				vma->vm_start = address;
-				vma->vm_pgoff -= grow;
+				WRITE_ONCE(vma->vm_start, address);
+				WRITE_ONCE(vma->vm_pgoff, vma->vm_pgoff - grow);
 				anon_vma_interval_tree_post_update_vma(vma);
 				vma_gap_update(vma);
 				spin_unlock(&mm->page_table_lock);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 625608bc8962..83594cc68062 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -375,12 +375,14 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
 	 */
-	vma->vm_flags = newflags;
+	vm_write_begin(vma);
+	WRITE_ONCE(vma->vm_flags, newflags);
 	dirty_accountable = vma_wants_writenotify(vma, vma->vm_page_prot);
 	vma_set_page_prot(vma);
 
 	change_protection(vma, start, end, vma->vm_page_prot,
 			  dirty_accountable, 0);
+	vm_write_end(vma);
 
 	/*
 	 * Private VM_LOCKED VMA becoming writable: trigger COW to avoid major
diff --git a/mm/swap_state.c b/mm/swap_state.c
index fe079756bb18..8a8a402ed59f 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -575,6 +575,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
  * the readahead.
  *
  * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
+ * This is needed to ensure the VMA will not be freed in our back. In the case
+ * of the speculative page fault handler, this cannot happen, even if we don't
+ * hold the mmap_sem. Callees are assumed to take care of reading VMA's fields
+ * using READ_ONCE() to read consistent values.
  */
 struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 				struct vm_fault *vmf)
@@ -668,9 +672,9 @@ static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
 				     unsigned long *start,
 				     unsigned long *end)
 {
-	*start = max3(lpfn, PFN_DOWN(vma->vm_start),
+	*start = max3(lpfn, PFN_DOWN(READ_ONCE(vma->vm_start)),
 		      PFN_DOWN(faddr & PMD_MASK));
-	*end = min3(rpfn, PFN_DOWN(vma->vm_end),
+	*end = min3(rpfn, PFN_DOWN(READ_ONCE(vma->vm_end)),
 		    PFN_DOWN((faddr & PMD_MASK) + PMD_SIZE));
 }
 
-- 
2.7.4
