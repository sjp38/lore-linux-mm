Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A78796B035F
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 14:07:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d6so3102803wrd.7
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 11:07:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 14si1846541wmr.219.2017.09.08.11.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 11:07:32 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v88I4RWC043775
	for <linux-mm@kvack.org>; Fri, 8 Sep 2017 14:07:31 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cuw50seaj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 08 Sep 2017 14:07:31 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 8 Sep 2017 19:07:29 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v3 05/20] mm: Protect VMA modifications using VMA sequence count
Date: Fri,  8 Sep 2017 20:06:49 +0200
In-Reply-To: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1504894024-2750-6-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

The VMA sequence count has been introduced to allow fast detection of
VMA modification when running a page fault handler without holding
the mmap_sem.

This patch provides protection against the VMA modification done in :
	- madvise()
	- mremap()
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
 mm/mmap.c          | 17 ++++++++++-------
 mm/mprotect.c      |  4 +++-
 mm/mremap.c        |  7 +++++++
 9 files changed, 87 insertions(+), 36 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 5589b4bd4b85..550bbc852143 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1152,8 +1152,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					goto out_mm;
 				}
 				for (vma = mm->mmap; vma; vma = vma->vm_next) {
-					vma->vm_flags &= ~VM_SOFTDIRTY;
+					write_seqcount_begin(&vma->vm_sequence);
+					WRITE_ONCE(vma->vm_flags,
+						   vma->vm_flags & ~VM_SOFTDIRTY);
 					vma_set_page_prot(vma);
+					write_seqcount_end(&vma->vm_sequence);
 				}
 				downgrade_write(&mm->mmap_sem);
 				break;
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ef4b48d1ea42..856570f327c3 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -634,8 +634,11 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 
 	octx = vma->vm_userfaultfd_ctx.ctx;
 	if (!octx || !(octx->features & UFFD_FEATURE_EVENT_FORK)) {
+		write_seqcount_begin(&vma->vm_sequence);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
-		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
+		WRITE_ONCE(vma->vm_flags,
+			   vma->vm_flags & ~(VM_UFFD_WP | VM_UFFD_MISSING));
+		write_seqcount_end(&vma->vm_sequence);
 		return 0;
 	}
 
@@ -860,8 +863,10 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 			vma = prev;
 		else
 			prev = vma;
-		vma->vm_flags = new_flags;
+		write_seqcount_begin(&vma->vm_sequence);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		write_seqcount_end(&vma->vm_sequence);
 	}
 	up_write(&mm->mmap_sem);
 	mmput(mm);
@@ -1379,8 +1384,10 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		 * the next vma was merged into the current one and
 		 * the current one has not been updated yet.
 		 */
-		vma->vm_flags = new_flags;
+		write_seqcount_begin(&vma->vm_sequence);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx.ctx = ctx;
+		write_seqcount_end(&vma->vm_sequence);
 
 	skip:
 		prev = vma;
@@ -1537,8 +1544,10 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * the next vma was merged into the current one and
 		 * the current one has not been updated yet.
 		 */
-		vma->vm_flags = new_flags;
+		write_seqcount_begin(&vma->vm_sequence);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		write_seqcount_end(&vma->vm_sequence);
 
 	skip:
 		prev = vma;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index c01f177a1120..56dd994c05d0 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1005,6 +1005,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (mm_find_pmd(mm, address) != pmd)
 		goto out;
 
+	write_seqcount_begin(&vma->vm_sequence);
 	anon_vma_lock_write(vma->anon_vma);
 
 	pte = pte_offset_map(pmd, address);
@@ -1040,6 +1041,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
 		spin_unlock(pmd_ptl);
 		anon_vma_unlock_write(vma->anon_vma);
+		write_seqcount_end(&vma->vm_sequence);
 		result = SCAN_FAIL;
 		goto out;
 	}
@@ -1074,6 +1076,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache_pmd(vma, address, pmd);
 	spin_unlock(pmd_ptl);
+	write_seqcount_end(&vma->vm_sequence);
 
 	*hpage = NULL;
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 21261ff0466f..bedb0ec25c77 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -183,7 +183,9 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
-	vma->vm_flags = new_flags;
+	write_seqcount_begin(&vma->vm_sequence);
+	WRITE_ONCE(vma->vm_flags, new_flags);
+	write_seqcount_end(&vma->vm_sequence);
 out:
 	return error;
 }
@@ -451,9 +453,11 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
 		.private = tlb,
 	};
 
+	write_seqcount_begin(&vma->vm_sequence);
 	tlb_start_vma(tlb, vma);
 	walk_page_range(addr, end, &free_walk);
 	tlb_end_vma(tlb, vma);
+	write_seqcount_end(&vma->vm_sequence);
 }
 
 static int madvise_free_single_vma(struct vm_area_struct *vma,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 006ba625c0b8..ac1096b1be21 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -379,8 +379,11 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		write_seqcount_begin(&vma->vm_sequence);
 		mpol_rebind_policy(vma->vm_policy, new);
+		write_seqcount_end(&vma->vm_sequence);
+	}
 	up_write(&mm->mmap_sem);
 }
 
@@ -578,9 +581,11 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
+	write_seqcount_begin(&vma->vm_sequence);
 	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
+	write_seqcount_end(&vma->vm_sequence);
 
 	return nr_updated;
 }
@@ -681,6 +686,7 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
+	write_seqcount_begin(&vma->vm_sequence);
 	if (vma->vm_ops && vma->vm_ops->set_policy) {
 		err = vma->vm_ops->set_policy(vma, new);
 		if (err)
@@ -688,11 +694,17 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	}
 
 	old = vma->vm_policy;
-	vma->vm_policy = new; /* protected by mmap_sem */
+	/*
+	 * The speculative page fault handler access this field without
+	 * hodling the mmap_sem.
+	 */
+	WRITE_ONCE(vma->vm_policy,  new);
+	write_seqcount_end(&vma->vm_sequence);
 	mpol_put(old);
 
 	return 0;
  err_out:
+	write_seqcount_end(&vma->vm_sequence);
 	mpol_put(new);
 	return err;
 }
@@ -1562,23 +1574,28 @@ COMPAT_SYSCALL_DEFINE6(mbind, compat_ulong_t, start, compat_ulong_t, len,
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
index dfc6f1912176..4793a96cbc35 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -438,7 +438,9 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
-	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+	write_seqcount_begin(&vma->vm_sequence);
+	WRITE_ONCE(vma->vm_flags, vma->vm_flags & VM_LOCKED_CLEAR_MASK);
+	write_seqcount_end(&vma->vm_sequence);
 
 	while (start < end) {
 		struct page *page;
@@ -561,10 +563,11 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, populate_vma_page_range will bring it back.
 	 */
-
-	if (lock)
-		vma->vm_flags = newflags;
-	else
+	if (lock) {
+		write_seqcount_begin(&vma->vm_sequence);
+		WRITE_ONCE(vma->vm_flags, newflags);
+		write_seqcount_end(&vma->vm_sequence);
+	} else
 		munlock_vma_pages_range(vma, start, end);
 
 out:
diff --git a/mm/mmap.c b/mm/mmap.c
index 0a0012c7e50c..04e72314274d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -826,17 +826,18 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
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
@@ -1735,6 +1736,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 out:
 	perf_event_mmap(vma);
 
+	write_seqcount_begin(&vma->vm_sequence);
 	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
@@ -1757,6 +1759,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	vma->vm_flags |= VM_SOFTDIRTY;
 
 	vma_set_page_prot(vma);
+	write_seqcount_end(&vma->vm_sequence);
 
 	return addr;
 
@@ -2385,8 +2388,8 @@ int expand_downwards(struct vm_area_struct *vma,
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
index 6d3e2f082290..0c9aa0b1a74e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -358,7 +358,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
 	 */
-	vma->vm_flags = newflags;
+	write_seqcount_begin(&vma->vm_sequence);
+	WRITE_ONCE(vma->vm_flags, newflags);
 	dirty_accountable = vma_wants_writenotify(vma, vma->vm_page_prot);
 	vma_set_page_prot(vma);
 
@@ -373,6 +374,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 			(newflags & VM_WRITE)) {
 		populate_vma_page_range(vma, start, end, NULL);
 	}
+	write_seqcount_end(&vma->vm_sequence);
 
 	vm_stat_account(mm, oldflags, -nrpages);
 	vm_stat_account(mm, newflags, nrpages);
diff --git a/mm/mremap.c b/mm/mremap.c
index cfec004c4ff9..240618950215 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -301,6 +301,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (!new_vma)
 		return -ENOMEM;
 
+	write_seqcount_begin(&vma->vm_sequence);
+	write_seqcount_begin_nested(&new_vma->vm_sequence,
+				    SINGLE_DEPTH_NESTING);
+
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len,
 				     need_rmap_locks);
 	if (moved_len < old_len) {
@@ -317,6 +321,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		 */
 		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len,
 				 true);
+		write_seqcount_end(&vma->vm_sequence);
 		vma = new_vma;
 		old_len = new_len;
 		old_addr = new_addr;
@@ -325,7 +330,9 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		mremap_userfaultfd_prep(new_vma, uf);
 		arch_remap(mm, old_addr, old_addr + old_len,
 			   new_addr, new_addr + new_len);
+		write_seqcount_end(&vma->vm_sequence);
 	}
+	write_seqcount_end(&new_vma->vm_sequence);
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
 	if (vm_flags & VM_ACCOUNT) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
