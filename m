Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5110E6B0268
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:26:46 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id c185so5481693qke.14
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 09:26:46 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i40si2480197qtf.87.2018.01.12.09.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 09:26:45 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0CHONjq100311
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:26:44 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fey0rs70p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:26:43 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 12 Jan 2018 17:26:41 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v6 06/24] mm: VMA sequence count
Date: Fri, 12 Jan 2018 18:25:50 +0100
In-Reply-To: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1515777968-867-7-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com
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
[Build depends on CONFIG_SPF]
[Introduce vm_write_* inline function depending on CONFIG_SPF]
[Fix lock dependency between mapping->i_mmap_rwsem and vma->vm_sequence by
 using vm_raw_write* functions]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h       | 41 +++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |  3 +++
 mm/memory.c              |  2 ++
 mm/mmap.c                | 35 +++++++++++++++++++++++++++++++++++
 4 files changed, 81 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad299ed7b85c..ca7ceba84292 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1369,6 +1369,47 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 	unmap_mapping_range(mapping, holebegin, holelen, 0);
 }
 
+#ifdef CONFIG_SPF
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
+#endif /* CONFIG_SPF */
+
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags);
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fd1af6b9591d..e0e3df3b9641 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -333,6 +333,9 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+#ifdef CONFIG_SPF
+	seqcount_t vm_sequence;
+#endif
 } __randomize_layout;
 
 struct core_thread {
diff --git a/mm/memory.c b/mm/memory.c
index 6b2c4732e49d..22bdc5c6c5ee 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1503,6 +1503,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 	unsigned long next;
 
 	BUG_ON(addr >= end);
+	vm_write_begin(vma);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -1512,6 +1513,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 		next = zap_p4d_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
+	vm_write_end(vma);
 }
 
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 4bb038e7984b..1dc5397fbd59 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -558,6 +558,10 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	else
 		mm->highest_vm_end = vm_end_gap(vma);
 
+#ifdef CONFIG_SPF
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
 
@@ -902,6 +930,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			anon_vma_merge(vma, next);
 		mm->map_count--;
 		mpol_put(vma_policy(next));
+		vm_raw_write_end(next);
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
@@ -916,6 +945,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			 * "vma->vm_next" gap must be updated.
 			 */
 			next = vma->vm_next;
+			if (next)
+				vm_raw_write_begin(next);
 		} else {
 			/*
 			 * For the scope of the comment "next" and
@@ -962,6 +993,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
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
