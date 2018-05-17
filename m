Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 583E96B04AE
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27-v6so2737579wre.23
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:07:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i2-v6si4749883edb.100.2018.05.17.04.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 04:07:10 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4HB4FDb054424
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:08 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j17kxawbm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:08 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 May 2018 12:07:06 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v11 09/26] mm: VMA sequence count
Date: Thu, 17 May 2018 13:06:16 +0200
In-Reply-To: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1526555193-7242-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

From: Peter Zijlstra <peterz@infradead.org>

Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
counts such that we can easily test if a VMA is changed.

The calls to vm_write_begin/end() in unmap_page_range() are
used to detect when a VMA is being unmap and thus that new page fault
should not be satisfied for this VMA. If the seqcount hasn't changed when
the page table are locked, this means we are safe to satisfy the page
fault.

The flip side is that we cannot distinguish between a vma_adjust() and
the unmap_page_range() -- where with the former we could have
re-checked the vma bounds against the address.

The VMA's sequence counter is also used to detect change to various VMA's
fields used during the page fault handling, such as:
 - vm_start, vm_end
 - vm_pgoff
 - vm_flags, vm_page_prot
 - anon_vma
 - vm_policy

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Port to 4.12 kernel]
[Build depends on CONFIG_SPECULATIVE_PAGE_FAULT]
[Introduce vm_write_* inline function depending on
 CONFIG_SPECULATIVE_PAGE_FAULT]
[Fix lock dependency between mapping->i_mmap_rwsem and vma->vm_sequence by
 using vm_raw_write* functions]
[Fix a lock dependency warning in mmap_region() when entering the error
 path]
[move sequence initialisation INIT_VMA()]
[Review the patch description about unmap_page_range()]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h       | 44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |  3 +++
 mm/memory.c              |  2 ++
 mm/mmap.c                | 31 +++++++++++++++++++++++++++++++
 4 files changed, 80 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 35ecb983ff36..18acfdeee759 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1306,6 +1306,9 @@ struct zap_details {
 static inline void INIT_VMA(struct vm_area_struct *vma)
 {
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	seqcount_init(&vma->vm_sequence);
+#endif
 }
 
 struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
@@ -1428,6 +1431,47 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 	unmap_mapping_range(mapping, holebegin, holelen, 0);
 }
 
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
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
+#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
+
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags);
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 54f1e05ecf3e..fb5962308183 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -335,6 +335,9 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	seqcount_t vm_sequence;
+#endif
 } __randomize_layout;
 
 struct core_thread {
diff --git a/mm/memory.c b/mm/memory.c
index 75163c145c76..551a1916da5d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1499,6 +1499,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 	unsigned long next;
 
 	BUG_ON(addr >= end);
+	vm_write_begin(vma);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -1508,6 +1509,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 		next = zap_p4d_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
+	vm_write_end(vma);
 }
 
 
diff --git a/mm/mmap.c b/mm/mmap.c
index ceb1c2c1b46b..eeafd0bc8b36 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -701,6 +701,30 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
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
 
@@ -911,6 +935,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			anon_vma_merge(vma, next);
 		mm->map_count--;
 		mpol_put(vma_policy(next));
+		vm_raw_write_end(next);
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
@@ -925,6 +950,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			 * "vma->vm_next" gap must be updated.
 			 */
 			next = vma->vm_next;
+			if (next)
+				vm_raw_write_begin(next);
 		} else {
 			/*
 			 * For the scope of the comment "next" and
@@ -971,6 +998,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
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
