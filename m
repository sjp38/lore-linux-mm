Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0987F6B026B
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 06:08:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p2so3347982pfk.13
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 03:08:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m123si6085490qkd.333.2017.10.09.03.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 03:08:24 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v99A66gY062093
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 06:08:23 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dg5xwk8k5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 06:08:23 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 11:08:19 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 04/20] mm: VMA sequence count
Date: Mon,  9 Oct 2017 12:07:36 +0200
In-Reply-To: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507543672-25821-5-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

From: Peter Zijlstra <peterz@infradead.org>

Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
counts such that we can easily test if a VMA is changed.

The unmap_page_range() one allows us to make assumptions about
page-tables; when we find the seqcount hasn't changed we can assume
page-tables are still valid.

The flip side is that we cannot distinguish between a vma_adjust() and
the unmap_page_range() -- where with the former we could have
re-checked the vma bounds against the address.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Port to 4.12 kernel]
[Build depends on __HAVE_ARCH_CALL_SPF]
[Introduce vm_write_* inline function depending on __HAVE_ARCH_CALL_SPF]
[Fix lock dependency between mapping->i_mmap_rwsem and vma->vm_sequence by
 using vm_raw_write* functions]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Fix locked by raw function

undo lockdep fix as raw services are now used
---
 include/linux/mm.h       | 41 +++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |  3 +++
 mm/memory.c              |  2 ++
 mm/mmap.c                | 40 +++++++++++++++++++++++++++++++++++++---
 4 files changed, 83 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fb3477f7f742..aa06332fc01e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1349,6 +1349,47 @@ static inline int fixup_user_fault(struct task_struct *tsk,
 }
 #endif
 
+#ifdef __HAVE_ARCH_CALL_SPF
+static inline void vm_write_begin(struct vm_area_struct *vma)
+{
+	write_seqcount_begin(&vma->vm_sequence);
+}
+static inline void vm_write_begin_nested(struct vm_area_struct *vma,
+					 int subclass)
+{
+	write_seqcount_begin_nested(&vma->vm_sequence, subclass);
+}
+static inline void vm_write_end(struct vm_area_struct *vma)
+{
+	write_seqcount_end(&vma->vm_sequence);
+}
+static inline void vm_raw_write_begin(struct vm_area_struct *vma)
+{
+	raw_write_seqcount_begin(&vma->vm_sequence);
+}
+static inline void vm_raw_write_end(struct vm_area_struct *vma)
+{
+	raw_write_seqcount_end(&vma->vm_sequence);
+}
+#else
+static inline void vm_write_begin(struct vm_area_struct *vma)
+{
+}
+static inline void vm_write_begin_nested(struct vm_area_struct *vma,
+					 int subclass)
+{
+}
+static inline void vm_write_end(struct vm_area_struct *vma)
+{
+}
+static inline void vm_raw_write_begin(struct vm_area_struct *vma)
+{
+}
+static inline void vm_raw_write_end(struct vm_area_struct *vma)
+{
+}
+#endif /* __HAVE_ARCH_CALL_SPF */
+
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len,
 		unsigned int gup_flags);
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d1e5062b0c00..6736feb8cb28 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -346,6 +346,9 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+#ifdef __HAVE_ARCH_CALL_SPF
+	seqcount_t vm_sequence;
+#endif
 } __randomize_layout;
 
 struct core_thread {
diff --git a/mm/memory.c b/mm/memory.c
index 27f626c229f7..ac6822356a37 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1504,6 +1504,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 	unsigned long next;
 
 	BUG_ON(addr >= end);
+	vm_write_begin(vma);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -1513,6 +1514,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 		next = zap_p4d_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
+	vm_write_end(vma);
 }
 
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 2f3971a051c6..ec896358fc5a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -558,6 +558,10 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	else
 		mm->highest_vm_end = vm_end_gap(vma);
 
+#ifdef __HAVE_ARCH_CALL_SPF
+	seqcount_init(&vma->vm_sequence);
+#endif
+
 	/*
 	 * vma->vm_prev wasn't known when we followed the rbtree to find the
 	 * correct insertion point for that vma. As a result, we could not
@@ -692,6 +696,30 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	long adjust_next = 0;
 	int remove_next = 0;
 
+	/*
+	 * Why using vm_raw_write*() functions here to avoid lockdep's warning ?
+	 *
+	 * Locked is complaining about a theoretical lock dependency, involving
+	 * 3 locks:
+	 *   mapping->i_mmap_rwsem --> vma->vm_sequence --> fs_reclaim
+	 *
+	 * Here are the major path leading to this dependency :
+	 *  1. __vma_adjust() mmap_sem  -> vm_sequence -> i_mmap_rwsem
+	 *  2. move_vmap() mmap_sem -> vm_sequence -> fs_reclaim
+	 *  3. __alloc_pages_nodemask() fs_reclaim -> i_mmap_rwsem
+	 *  4. unmap_mapping_range() i_mmap_rwsem -> vm_sequence
+	 *
+	 * So there is no way to solve this easily, especially because in
+	 * unmap_mapping_range() the i_mmap_rwsem is grab while the impacted
+	 * VMAs are not yet known.
+	 * However, the way the vm_seq is used is guarantying that we will
+	 * never block on it since we just check for its value and never wait
+	 * for it to move, see vma_has_changed() and handle_speculative_fault().
+	 */
+	vm_raw_write_begin(vma);
+	if (next)
+		vm_raw_write_begin(next);
+
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL, *importer = NULL;
 
@@ -903,6 +931,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		mm->map_count--;
 		mpol_put(vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
+		vm_raw_write_end(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -916,6 +945,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			 * "vma->vm_next" gap must be updated.
 			 */
 			next = vma->vm_next;
+			if (next)
+				vm_raw_write_begin(next);
 		} else {
 			/*
 			 * For the scope of the comment "next" and
@@ -933,10 +964,9 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			remove_next = 1;
 			end = next->vm_end;
 			goto again;
-		}
-		else if (next)
+		} else if (next) {
 			vma_gap_update(next);
-		else {
+		} else {
 			/*
 			 * If remove_next == 2 we obviously can't
 			 * reach this path.
@@ -962,6 +992,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	if (insert && file)
 		uprobe_mmap(insert);
 
+	if (next && next != vma)
+		vm_raw_write_end(next);
+	vm_raw_write_end(vma);
+
 	validate_mm(mm);
 
 	return 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
