Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9974983293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:53:00 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so8341590wrb.6
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:53:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r15si2893211wrr.227.2017.06.16.10.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 10:52:59 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5GHnXj5030260
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:52:57 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b4k36j5vr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:52:57 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Jun 2017 18:52:55 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v5 06/11] mm: Protect VMA modifications using VMA sequence count
Date: Fri, 16 Jun 2017 19:52:30 +0200
In-Reply-To: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497635555-25679-7-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

The VMA sequence count has been introduced to allow fast detection of
VMA modification when running a page fault handler without holding
the mmap_sem.

This patch provides protection agains the VMA modification done in :
	- madvise()
	- mremap()
	- mpol_rebind_policy()
	- vma_replace_policy()
	- change_prot_numa()
	- mlock(), munlock()
	- mprotect()
	- mmap_region()

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 fs/proc/task_mmu.c |  2 ++
 mm/madvise.c       |  4 ++++
 mm/mempolicy.c     | 10 +++++++++-
 mm/mlock.c         |  9 ++++++---
 mm/mmap.c          |  2 ++
 mm/mprotect.c      |  2 ++
 mm/mremap.c        |  7 +++++++
 7 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0c8b33d99b1..9bc40620ba39 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1069,8 +1069,10 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					goto out_mm;
 				}
 				for (vma = mm->mmap; vma; vma = vma->vm_next) {
+					write_seqcount_begin(&vma->vm_sequence);
 					vma->vm_flags &= ~VM_SOFTDIRTY;
 					vma_set_page_prot(vma);
+					write_seqcount_end(&vma->vm_sequence);
 				}
 				downgrade_write(&mm->mmap_sem);
 				break;
diff --git a/mm/madvise.c b/mm/madvise.c
index 25b78ee4fc2c..d1fa6a7ee604 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -172,7 +172,9 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
+	write_seqcount_begin(&vma->vm_sequence);
 	vma->vm_flags = new_flags;
+	write_seqcount_end(&vma->vm_sequence);
 out:
 	return error;
 }
@@ -439,9 +441,11 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
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
index 37d0b334bfe9..5e44b3e69a0d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -447,8 +447,11 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		write_seqcount_begin(&vma->vm_sequence);
 		mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
+		write_seqcount_end(&vma->vm_sequence);
+	}
 	up_write(&mm->mmap_sem);
 }
 
@@ -606,9 +609,11 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
+	write_seqcount_begin(&vma->vm_sequence);
 	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
+	write_seqcount_end(&vma->vm_sequence);
 
 	return nr_updated;
 }
@@ -709,6 +714,7 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
+	write_seqcount_begin(&vma->vm_sequence);
 	if (vma->vm_ops && vma->vm_ops->set_policy) {
 		err = vma->vm_ops->set_policy(vma, new);
 		if (err)
@@ -717,10 +723,12 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 
 	old = vma->vm_policy;
 	vma->vm_policy = new; /* protected by mmap_sem */
+	write_seqcount_end(&vma->vm_sequence);
 	mpol_put(old);
 
 	return 0;
  err_out:
+	write_seqcount_end(&vma->vm_sequence);
 	mpol_put(new);
 	return err;
 }
diff --git a/mm/mlock.c b/mm/mlock.c
index b562b5523a65..30d9bfc61929 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -438,7 +438,9 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
+	write_seqcount_begin(&vma->vm_sequence);
 	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+	write_seqcount_end(&vma->vm_sequence);
 
 	while (start < end) {
 		struct page *page;
@@ -563,10 +565,11 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, populate_vma_page_range will bring it back.
 	 */
-
-	if (lock)
+	if (lock) {
+		write_seqcount_begin(&vma->vm_sequence);
 		vma->vm_flags = newflags;
-	else
+		write_seqcount_end(&vma->vm_sequence);
+	} else
 		munlock_vma_pages_range(vma, start, end);
 
 out:
diff --git a/mm/mmap.c b/mm/mmap.c
index ad85f210a92c..b48bbe6a49c6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1720,6 +1720,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 out:
 	perf_event_mmap(vma);
 
+	write_seqcount_begin(&vma->vm_sequence);
 	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
@@ -1742,6 +1743,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	vma->vm_flags |= VM_SOFTDIRTY;
 
 	vma_set_page_prot(vma);
+	write_seqcount_end(&vma->vm_sequence);
 
 	return addr;
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8edd0d576254..1db5b0bf6952 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -345,6 +345,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
 	 */
+	write_seqcount_begin(&vma->vm_sequence);
 	vma->vm_flags = newflags;
 	dirty_accountable = vma_wants_writenotify(vma, vma->vm_page_prot);
 	vma_set_page_prot(vma);
@@ -360,6 +361,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 			(newflags & VM_WRITE)) {
 		populate_vma_page_range(vma, start, end, NULL);
 	}
+	write_seqcount_end(&vma->vm_sequence);
 
 	vm_stat_account(mm, oldflags, -nrpages);
 	vm_stat_account(mm, newflags, nrpages);
diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b199ef9..9c7f69c9e80f 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -300,6 +300,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (!new_vma)
 		return -ENOMEM;
 
+	write_seqcount_begin(&vma->vm_sequence);
+	write_seqcount_begin_nested(&new_vma->vm_sequence,
+				    SINGLE_DEPTH_NESTING);
+
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len,
 				     need_rmap_locks);
 	if (moved_len < old_len) {
@@ -316,6 +320,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		 */
 		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len,
 				 true);
+		write_seqcount_end(&vma->vm_sequence);
 		vma = new_vma;
 		old_len = new_len;
 		old_addr = new_addr;
@@ -324,7 +329,9 @@ static unsigned long move_vma(struct vm_area_struct *vma,
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
