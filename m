Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 882BE6B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 14:18:24 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4B78982C517
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 14:24:57 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rDdAstmBvPYH for <linux-mm@kvack.org>;
	Wed,  4 Nov 2009 14:24:52 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7132482C51A
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 14:24:51 -0500 (EST)
Date: Wed, 4 Nov 2009 14:17:24 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Remove rss batching from copy_page_range() 
In-Reply-To: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
Message-ID: <alpine.DEB.1.10.0911041415480.7409@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

From: Christoph Lameter <cl@linux-foundation.org>
Subject: Remove rss batching from copy_page_range()

With per cpu counters in mm there is no need for batching
mm counter updates anymore. Update counters directly while
copying pages.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/memory.c |   27 ++++++++-------------------
 1 file changed, 8 insertions(+), 19 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2009-11-04 12:15:03.000000000 -0600
+++ linux-2.6/mm/memory.c	2009-11-04 13:03:45.000000000 -0600
@@ -376,14 +376,6 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	return 0;
 }

-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
-{
-	if (file_rss)
-		__this_cpu_add(mm->rss->file, file_rss);
-	if (anon_rss)
-		__this_cpu_add(mm->rss->anon, anon_rss);
-}
-
 /*
  * This function is called to print an error when a bad pte
  * is found. For example, we might have a PFN-mapped pte in
@@ -575,7 +567,7 @@ out:
 static inline void
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
-		unsigned long addr, int *rss)
+		unsigned long addr)
 {
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
@@ -630,7 +622,10 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page);
-		rss[PageAnon(page)]++;
+		if (PageAnon(page))
+			__this_cpu_inc(dst_mm->rss->anon);
+		else
+			__this_cpu_inc(dst_mm->rss->file);
 	}

 out_set_pte:
@@ -645,10 +640,8 @@ static int copy_pte_range(struct mm_stru
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
-	int rss[2];

 again:
-	rss[1] = rss[0] = 0;
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
 		return -ENOMEM;
@@ -674,14 +667,13 @@ again:
 			progress++;
 			continue;
 		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr);
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);

 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap_nested(orig_src_pte);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 	if (addr != end)
@@ -803,8 +795,6 @@ static unsigned long zap_pte_range(struc
 	struct mm_struct *mm = tlb->mm;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int file_rss = 0;
-	int anon_rss = 0;

 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -850,14 +840,14 @@ static unsigned long zap_pte_range(struc
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
 			if (PageAnon(page))
-				anon_rss--;
+				__this_cpu_dec(mm->rss->anon);
 			else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent) &&
 				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
-				file_rss--;
+				__this_cpu_dec(mm->rss->file);
 			}
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
@@ -880,7 +870,6 @@ static unsigned long zap_pte_range(struc
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));

-	add_mm_rss(mm, file_rss, anon_rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
