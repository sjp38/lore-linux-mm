Message-ID: <4181EF69.4070201@yahoo.com.au>
Date: Fri, 29 Oct 2004 17:21:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 2/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <4181EF54.6080308@yahoo.com.au>
In-Reply-To: <4181EF54.6080308@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------080501060103010307040907"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080501060103010307040907
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

2/7

--------------080501060103010307040907
Content-Type: text/x-patch;
 name="vm-unmap_all_vmas.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-unmap_all_vmas.patch"



Small cleanup in preparation for unlocked page tables.


---

 linux-2.6-npiggin/include/linux/mm.h |    8 +++----
 linux-2.6-npiggin/mm/memory.c        |   40 ++++++++++++++++++++++++++++-------
 linux-2.6-npiggin/mm/mmap.c          |   22 +------------------
 3 files changed, 38 insertions(+), 32 deletions(-)

diff -puN mm/memory.c~vm-unmap_all_vmas mm/memory.c
--- linux-2.6/mm/memory.c~vm-unmap_all_vmas	2004-10-23 19:43:54.000000000 +1000
+++ linux-2.6-npiggin/mm/memory.c	2004-10-23 19:43:54.000000000 +1000
@@ -528,7 +528,7 @@ static void unmap_page_range(struct mmu_
  * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
  * drops the lock and schedules.
  */
-int unmap_vmas(struct mmu_gather **tlbp, struct mm_struct *mm,
+static int __unmap_vmas(struct mmu_gather **tlbp, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
@@ -588,6 +588,36 @@ int unmap_vmas(struct mmu_gather **tlbp,
 	return ret;
 }
 
+void unmap_vmas(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long start_addr, unsigned long end_addr,
+		unsigned long *nr_accounted, struct zap_details *details)
+{
+	struct mmu_gather *tlb;
+	lru_add_drain();
+	spin_lock(&mm->page_table_lock);
+	tlb = tlb_gather_mmu(mm, 0);
+	__unmap_vmas(&tlb, mm, vma,
+			start_addr, end_addr, nr_accounted, details);
+	tlb_finish_mmu(tlb, start_addr, end_addr);
+	spin_unlock(&mm->page_table_lock);
+}
+
+int unmap_all_vmas(struct mm_struct *mm, unsigned long *nr_accounted)
+{
+	struct mmu_gather *tlb;
+	int ret;
+	lru_add_drain();
+	spin_lock(&mm->page_table_lock);
+	tlb = tlb_gather_mmu(mm, 1);
+	flush_cache_mm(mm);
+	/* Use ~0UL here to ensure all VMAs in the mm are unmapped */
+	ret = __unmap_vmas(&tlb, mm, mm->mmap, 0, ~0UL, nr_accounted, NULL);
+	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
+	spin_unlock(&mm->page_table_lock);
+
+	return ret;
+}
+
 /**
  * zap_page_range - remove user pages in a given range
  * @vma: vm_area_struct holding the applicable pages
@@ -599,7 +629,6 @@ void zap_page_range(struct vm_area_struc
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
@@ -608,12 +637,7 @@ void zap_page_range(struct vm_area_struc
 		return;
 	}
 
-	lru_add_drain();
-	spin_lock(&mm->page_table_lock);
-	tlb = tlb_gather_mmu(mm, 0);
-	unmap_vmas(&tlb, mm, vma, address, end, &nr_accounted, details);
-	tlb_finish_mmu(tlb, address, end);
-	spin_unlock(&mm->page_table_lock);
+	unmap_vmas(mm, vma, address, end, &nr_accounted, details);
 }
 
 /*
diff -puN mm/mmap.c~vm-unmap_all_vmas mm/mmap.c
--- linux-2.6/mm/mmap.c~vm-unmap_all_vmas	2004-10-23 19:43:54.000000000 +1000
+++ linux-2.6-npiggin/mm/mmap.c	2004-10-23 19:43:54.000000000 +1000
@@ -1562,17 +1562,9 @@ static void unmap_region(struct mm_struc
 	unsigned long start,
 	unsigned long end)
 {
-	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
-
-	spin_lock(&mm->page_table_lock);
-	tlb = tlb_gather_mmu(mm, 0);
-	unmap_vmas(&tlb, mm, vma, start, end, &nr_accounted, NULL);
-	tlb_finish_mmu(tlb, start, end);
-	spin_unlock(&mm->page_table_lock);
-
+	unmap_vmas(mm, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 }
 
@@ -1850,17 +1842,7 @@ void exit_mmap(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
-
-	spin_lock(&mm->page_table_lock);
-	tlb = tlb_gather_mmu(mm, 1);
-	flush_cache_mm(mm);
-	/* Use ~0UL here to ensure all VMAs in the mm are unmapped */
-	mm->map_count -= unmap_vmas(&tlb, mm, mm->mmap, 0,
-					~0UL, &nr_accounted, NULL);
-	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
-	spin_unlock(&mm->page_table_lock);
-
+	mm->map_count -= unmap_all_vmas(mm, &nr_accounted);
 	vm_unacct_memory(nr_accounted);
 	BUG_ON(mm->map_count);	/* This is just debugging */
 
diff -puN include/linux/mm.h~vm-unmap_all_vmas include/linux/mm.h
--- linux-2.6/include/linux/mm.h~vm-unmap_all_vmas	2004-10-23 19:43:54.000000000 +1000
+++ linux-2.6-npiggin/include/linux/mm.h	2004-10-23 19:43:54.000000000 +1000
@@ -560,10 +560,10 @@ struct zap_details {
 
 void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-int unmap_vmas(struct mmu_gather **tlbp, struct mm_struct *mm,
-		struct vm_area_struct *start_vma, unsigned long start_addr,
-		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *);
+void unmap_vmas(struct mm_struct *mm, struct vm_area_struct *start_vma,
+		unsigned long start_addr, unsigned long end_addr,
+		unsigned long *nr_accounted, struct zap_details *);
+int unmap_all_vmas(struct mm_struct *mm, unsigned long *nr_accounted);
 void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int nr);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);

_

--------------080501060103010307040907--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
