Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C989A83293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:52:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b15so7874275wrb.1
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:52:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e66si2693360wmc.167.2017.06.16.10.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 10:52:54 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5GHnD2A042932
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:52:53 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b4hqpwe7n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:52:53 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Jun 2017 18:52:51 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v5 04/11] mm: VMA sequence count
Date: Fri, 16 Jun 2017 19:52:28 +0200
In-Reply-To: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497635555-25679-5-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

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

[port to 4.12 kernel]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm_types.h |  1 +
 mm/memory.c              |  2 ++
 mm/mmap.c                | 13 +++++++++++++
 3 files changed, 16 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45cdb27791a3..8945743e4609 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -342,6 +342,7 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+	seqcount_t vm_sequence;
 };
 
 struct core_thread {
diff --git a/mm/memory.c b/mm/memory.c
index f1132f7931ef..5d259cd67a83 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1379,6 +1379,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 	unsigned long next;
 
 	BUG_ON(addr >= end);
+	write_seqcount_begin(&vma->vm_sequence);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -1388,6 +1389,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 		next = zap_p4d_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
+	write_seqcount_end(&vma->vm_sequence);
 }
 
 
diff --git a/mm/mmap.c b/mm/mmap.c
index f82741e199c0..9f86356d0012 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -543,6 +543,8 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	else
 		mm->highest_vm_end = vma->vm_end;
 
+	seqcount_init(&vma->vm_sequence);
+
 	/*
 	 * vma->vm_prev wasn't known when we followed the rbtree to find the
 	 * correct insertion point for that vma. As a result, we could not
@@ -677,6 +679,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	long adjust_next = 0;
 	int remove_next = 0;
 
+	write_seqcount_begin(&vma->vm_sequence);
+	if (next)
+		write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING);
+
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL, *importer = NULL;
 
@@ -888,6 +894,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		mm->map_count--;
 		mpol_put(vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
+		write_seqcount_end(&next->vm_sequence);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -901,6 +908,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			 * "vma->vm_next" gap must be updated.
 			 */
 			next = vma->vm_next;
+			if (next)
+				write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING);
 		} else {
 			/*
 			 * For the scope of the comment "next" and
@@ -947,6 +956,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	if (insert && file)
 		uprobe_mmap(insert);
 
+	if (next)
+		write_seqcount_end(&next->vm_sequence);
+	write_seqcount_end(&vma->vm_sequence);
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
