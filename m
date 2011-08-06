Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A31B16B00EE
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 14:18:22 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 2 of 3] mremap: avoid sending one IPI per page
Message-Id: <cbe9e822c59a912e9f76.1312649884@localhost>
In-Reply-To: <patchbomb.1312649882@localhost>
References: <patchbomb.1312649882@localhost>
Date: Sat, 06 Aug 2011 18:58:04 +0200
From: aarcange@redhat.com
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

From: Andrea Arcangeli <aarcange@redhat.com>

This replaces ptep_clear_flush() with ptep_get_and_clear() and a single
flush_tlb_range() at the end of the loop, to avoid sending one IPI for each
page.

The mmu_notifier_invalidate_range_start/end section is enlarged accordingly but
this is not going to fundamentally change things. It was more by accident that
the region under mremap was for the most part still available for secondary
MMUs: the primary MMU was never allowed to reliably access that region for the
duration of the mremap (modulo trapping SIGSEGV on the old address range which
sounds unpractical and flakey). If users wants secondary MMUs not to lose
access to a large region under mremap they should reduce the mremap size
accordingly in userland and run multiple calls. Overall this will run faster so
it's actually going to reduce the time the region is under mremap for the
primary MMU which should provide a net benefit to apps.

For KVM this is a noop because the guest physical memory is never mremapped,
there's just no point it ever moving it while guest runs. One target of this
optimization is JVM GC (so unrelated to the mmu notifier logic).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -80,11 +80,7 @@ static void move_ptes(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
-	unsigned long old_start;
 
-	old_start = old_addr;
-	mmu_notifier_invalidate_range_start(vma->vm_mm,
-					    old_start, old_end);
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
@@ -111,7 +107,7 @@ static void move_ptes(struct vm_area_str
 				   new_pte++, new_addr += PAGE_SIZE) {
 		if (pte_none(*old_pte))
 			continue;
-		pte = ptep_clear_flush(vma, old_addr, old_pte);
+		pte = ptep_get_and_clear(mm, old_addr, old_pte);
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		set_pte_at(mm, new_addr, new_pte, pte);
 	}
@@ -123,7 +119,6 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		mutex_unlock(&mapping->i_mmap_mutex);
-	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
@@ -134,10 +129,13 @@ unsigned long move_page_tables(struct vm
 {
 	unsigned long extent, next, old_end;
 	pmd_t *old_pmd, *new_pmd;
+	bool need_flush = false;
 
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
+	mmu_notifier_invalidate_range_start(vma->vm_mm, old_addr, old_end);
+
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
 		next = (old_addr + PMD_SIZE) & PMD_MASK;
@@ -158,7 +156,12 @@ unsigned long move_page_tables(struct vm
 			extent = LATENCY_LIMIT;
 		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
 				new_vma, new_pmd, new_addr);
+		need_flush = true;
 	}
+	if (likely(need_flush))
+		flush_tlb_range(vma, old_end-len, old_addr);
+
+	mmu_notifier_invalidate_range_end(vma->vm_mm, old_end-len, old_end);
 
 	return len + old_addr - old_end;	/* how much done */
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
