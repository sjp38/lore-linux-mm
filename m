Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E48656B0071
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:41:56 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lj1so25234pab.4
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:41:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z9si9169391pdp.52.2014.10.20.15.41.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 15:41:53 -0700 (PDT)
Message-Id: <20141020222841.361741939@infradead.org>
Date: Mon, 20 Oct 2014 23:56:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 3/6] mm: VMA sequence count
References: <20141020215633.717315139@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-mm-vma-seq.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

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
 include/linux/mm_types.h |    2 ++
 mm/memory.c              |    2 ++
 mm/mmap.c                |   13 +++++++++++++
 3 files changed, 17 insertions(+)

--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
+#include <linux/seqlock.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -308,6 +309,7 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	seqcount_t vm_sequence;
 };
 
 struct core_thread {
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1293,6 +1293,7 @@ static void unmap_page_range(struct mmu_
 		details = NULL;
 
 	BUG_ON(addr >= end);
+	write_seqcount_begin(&vma->vm_sequence);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -1302,6 +1303,7 @@ static void unmap_page_range(struct mmu_
 		next = zap_pud_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
+	write_seqcount_end(&vma->vm_sequence);
 }
 
 
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -596,6 +596,8 @@ void __vma_link_rb(struct mm_struct *mm,
 	else
 		mm->highest_vm_end = vma->vm_end;
 
+	seqcount_init(&vma->vm_sequence);
+
 	/*
 	 * vma->vm_prev wasn't known when we followed the rbtree to find the
 	 * correct insertion point for that vma. As a result, we could not
@@ -715,6 +717,10 @@ int vma_adjust(struct vm_area_struct *vm
 	long adjust_next = 0;
 	int remove_next = 0;
 
+	write_seqcount_begin(&vma->vm_sequence);
+	if (next)
+		write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING);
+
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL;
 
@@ -880,7 +886,10 @@ again:			remove_next = 1 + (end > next->
 		 * we must remove another next too. It would clutter
 		 * up the code too much to do both in one go.
 		 */
+		write_seqcount_end(&next->vm_sequence);
 		next = vma->vm_next;
+		write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING);
+
 		if (remove_next == 2)
 			goto again;
 		else if (next)
@@ -891,6 +900,10 @@ again:			remove_next = 1 + (end > next->
 	if (insert && file)
 		uprobe_mmap(insert);
 
+	if (next)
+		write_seqcount_end(&next->vm_sequence);
+	write_seqcount_end(&vma->vm_sequence);
+
 	validate_mm(mm);
 
 	return 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
