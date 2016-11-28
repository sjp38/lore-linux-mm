Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BACFC6B025E
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 03:40:16 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so201771508pfk.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 00:40:16 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q8si54106734pgc.289.2016.11.28.00.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 00:40:15 -0800 (PST)
Date: Mon, 28 Nov 2016 16:40:12 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 2/2] mremap: use mmu gather logic for tlb flush in mremap
Message-ID: <20161128084012.GC21738@aaronlu.sh.intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
 <20161128083715.GA21738@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161128083715.GA21738@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org

As suggested by Linus, the same mmu gather logic could be used for tlb
flush in mremap and this patch just did that.

Note that since there is no page added to "struct mmu_gather" for free
during mremap, when tlb needs to be flushed, we can use tlb_flush_mmu or
tlb_flush_mmu_tlbonly. Using tlb_flush_mmu could also avoid exporting
tlb_flush_mmu_tlbonly. But tlb_flush_mmu_tlbonly *looks* more clear and
straightforward so I end up using it.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/linux/huge_mm.h |  6 +++---
 mm/huge_memory.c        | 13 +++++++------
 mm/mremap.c             | 30 +++++++++++++++---------------
 3 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index e35e6de633b9..bbf64e05a49a 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -20,9 +20,9 @@ extern int zap_huge_pmd(struct mmu_gather *tlb,
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
-extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
-			 unsigned long new_addr, unsigned long old_end,
-			 pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush);
+extern bool move_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+			 unsigned long old_addr, unsigned long new_addr,
+			 unsigned long old_end, pmd_t *old_pmd, pmd_t *new_pmd);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index eff3de359d50..33909f16a9ad 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1424,9 +1424,9 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	return 1;
 }
 
-bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
-		  unsigned long new_addr, unsigned long old_end,
-		  pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
+bool move_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		   unsigned long old_addr, unsigned long new_addr,
+		   unsigned long old_end, pmd_t *old_pmd, pmd_t *new_pmd)
 {
 	spinlock_t *old_ptl, *new_ptl;
 	pmd_t pmd;
@@ -1456,8 +1456,11 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		new_ptl = pmd_lockptr(mm, new_pmd);
 		if (new_ptl != old_ptl)
 			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+
+		tlb_remove_pmd_tlb_entry(tlb, old_pmd, old_addr);
 		if (pmd_present(*old_pmd) && pmd_dirty(*old_pmd))
 			force_flush = true;
+
 		pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
 
@@ -1471,9 +1474,7 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
 		if (force_flush)
-			flush_tlb_range(vma, old_addr, old_addr + PMD_SIZE);
-		else
-			*need_flush = true;
+			tlb_flush_mmu_tlbonly(tlb);
 		spin_unlock(old_ptl);
 		return true;
 	}
diff --git a/mm/mremap.c b/mm/mremap.c
index 6ccecc03f56a..dfac96ec7294 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -25,6 +25,7 @@
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
+#include <asm/tlb.h>
 
 #include "internal.h"
 
@@ -101,16 +102,15 @@ static pte_t move_soft_dirty_pte(pte_t pte)
 	return pte;
 }
 
-static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
-		unsigned long old_addr, unsigned long old_end,
+static void move_ptes(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		pmd_t *old_pmd, unsigned long old_addr, unsigned long old_end,
 		struct vm_area_struct *new_vma, pmd_t *new_pmd,
-		unsigned long new_addr, bool need_rmap_locks, bool *need_flush)
+		unsigned long new_addr, bool need_rmap_locks)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
 	bool force_flush = false;
-	unsigned long len = old_end - old_addr;
 
 	/*
 	 * When need_rmap_locks is true, we take the i_mmap_rwsem and anon_vma
@@ -149,6 +149,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		if (pte_none(*old_pte))
 			continue;
 
+		tlb_remove_tlb_entry(tlb, old_pte, old_addr);
 		/*
 		 * We are remapping a dirty PTE, make sure to
 		 * flush TLB before we drop the PTL for the
@@ -166,10 +167,9 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (new_ptl != old_ptl)
 		spin_unlock(new_ptl);
 	pte_unmap(new_pte - 1);
+
 	if (force_flush)
-		flush_tlb_range(vma, old_end - len, old_end);
-	else
-		*need_flush = true;
+		tlb_flush_mmu_tlbonly(tlb);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (need_rmap_locks)
 		drop_rmap_locks(vma);
@@ -184,15 +184,16 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 {
 	unsigned long extent, next, old_end;
 	pmd_t *old_pmd, *new_pmd;
-	bool need_flush = false;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_gather tlb;
 
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
 	mmun_start = old_addr;
 	mmun_end   = old_end;
+	tlb_gather_mmu(&tlb, vma->vm_mm, mmun_start, mmun_end);
 	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
@@ -214,9 +215,9 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 				/* See comment in move_ptes() */
 				if (need_rmap_locks)
 					take_rmap_locks(vma);
-				moved = move_huge_pmd(vma, old_addr, new_addr,
-						    old_end, old_pmd, new_pmd,
-						    &need_flush);
+				moved = move_huge_pmd(&tlb, vma, old_addr,
+						      new_addr, old_end,
+						      old_pmd, new_pmd);
 				if (need_rmap_locks)
 					drop_rmap_locks(vma);
 				if (moved)
@@ -233,13 +234,12 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 			extent = next - new_addr;
 		if (extent > LATENCY_LIMIT)
 			extent = LATENCY_LIMIT;
-		move_ptes(vma, old_pmd, old_addr, old_addr + extent, new_vma,
-			  new_pmd, new_addr, need_rmap_locks, &need_flush);
+		move_ptes(&tlb, vma, old_pmd, old_addr, old_addr + extent,
+			  new_vma, new_pmd, new_addr, need_rmap_locks);
 	}
-	if (need_flush)
-		flush_tlb_range(vma, old_end-len, old_addr);
 
 	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
+	tlb_finish_mmu(&tlb, mmun_start, mmun_end);
 
 	return len + old_addr - old_end;	/* how much done */
 }
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
