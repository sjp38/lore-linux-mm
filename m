Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C70F6B03F7
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:03 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so139308237pfb.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:09:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r64si7732588pfj.252.2016.11.18.03.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 03:09:02 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAIB8nb7058637
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:01 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26svx4285t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:01 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 18 Nov 2016 11:08:57 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id CEAB21B0806E
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:11:11 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAIB8s0v52560116
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:54 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAIB8ss2020887
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:08:54 -0700
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 4/7] mm: VMA sequence count
Date: Fri, 18 Nov 2016 12:08:48 +0100
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
Message-Id: <95790e53bfcfb536eb8f1dcdf4750e7e8050d8f4.1479465699.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

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
---
 include/linux/mm_types.h |  1 +
 mm/memory.c              |  2 ++
 mm/mmap.c                | 12 ++++++++++++
 3 files changed, 15 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 903200f4ec41..620719bef808 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -358,6 +358,7 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+	seqcount_t vm_sequence;
 };
 
 struct core_thread {
diff --git a/mm/memory.c b/mm/memory.c
index d19800904272..ec32cf710403 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1290,6 +1290,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 	unsigned long next;
 
 	BUG_ON(addr >= end);
+	write_seqcount_begin(&vma->vm_sequence);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -1299,6 +1300,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 		next = zap_pud_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
+	write_seqcount_end(&vma->vm_sequence);
 }
 
 
diff --git a/mm/mmap.c b/mm/mmap.c
index ca9d91bca0d6..c2be9bd0ad92 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -514,6 +514,8 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	else
 		mm->highest_vm_end = vma->vm_end;
 
+	seqcount_init(&vma->vm_sequence);
+
 	/*
 	 * vma->vm_prev wasn't known when we followed the rbtree to find the
 	 * correct insertion point for that vma. As a result, we could not
@@ -629,6 +631,10 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	long adjust_next = 0;
 	int remove_next = 0;
 
+	write_seqcount_begin(&vma->vm_sequence);
+	if (next)
+		write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING);
+
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL, *importer = NULL;
 
@@ -802,7 +808,9 @@ again:
 		 * we must remove another next too. It would clutter
 		 * up the code too much to do both in one go.
 		 */
+		write_seqcount_end(&next->vm_sequence);
 		next = vma->vm_next;
+		write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING);
 		if (remove_next == 2) {
 			remove_next = 1;
 			end = next->vm_end;
@@ -816,6 +824,10 @@ again:
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
