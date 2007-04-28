Message-ID: <4632D0EF.9050701@redhat.com>
Date: Sat, 28 Apr 2007 00:43:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
Content-Type: multipart/mixed;
 boundary="------------070804080407080401080304"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070804080407080401080304
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

With lazy freeing of anonymous pages through MADV_FREE, performance of
the MySQL sysbench workload more than doubles on my quad-core system.

Madvise with MADV_FREE is used by applications to tell the kernel that
memory no longer contains useful data and can be reclaimed by the
kernel if it is needed elsewhere.  However, if the application puts
new data in the page (dirty bit gets set by hardware), the kernel
will not throw away the data.

This makes applications that free() and then later on malloc() the
same data again run a lot faster, since page faults are avoided.
In low memory situations, the kernel still knows which pages to
reclaim.

"Doing it all in userspace" is not a good solution for this problem,
because if the system needs the memory it is way cheaper to just throw
away these freed pages than to do the disk IO of swapping them out and
back in.

Signed-off-by: Rik van Riel <riel@redhat.com>

--------------070804080407080401080304
Content-Type: text/x-patch;
 name="linux-2.6.21-madv_free.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.21-madv_free.patch"

--- linux-2.6.21.noarch/mm/rmap.c.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/mm/rmap.c	2007-04-27 16:03:22.000000000 -0400
@@ -656,7 +656,17 @@ static int try_to_unmap_one(struct page 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
 
-	if (PageAnon(page)) {
+	/* MADV_FREE is used to lazily free memory from userspace. */
+	if (PageLazyFree(page) && !migration) {
+		if (unlikely(pte_dirty(pteval))) {
+			/* There is new data in the page.  Reinstate it. */
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+		/* Throw the page away. */
+		dec_mm_counter(mm, anon_rss);
+	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 
 		if (PageSwapCache(page)) {
--- linux-2.6.21.noarch/mm/page_alloc.c.madv_free	2007-04-27 16:03:22.000000000 -0400
+++ linux-2.6.21.noarch/mm/page_alloc.c	2007-04-27 16:03:22.000000000 -0400
@@ -203,6 +203,7 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
+			1 << PG_lazyfree |
 			1 << PG_buddy );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
@@ -442,6 +443,8 @@ static inline int free_pages_check(struc
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
+	if (PageLazyFree(page))
+		__ClearPageLazyFree(page);
 	/*
 	 * For now, we report if PG_reserved was found set, but do not
 	 * clear it, and do not free the page.  But we shall soon need
@@ -588,6 +591,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+			1 << PG_lazyfree |
 			1 << PG_buddy ))))
 		bad_page(page);
 
--- linux-2.6.21.noarch/mm/memory.c.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/mm/memory.c	2007-04-27 21:12:57.000000000 -0400
@@ -432,6 +432,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
 	struct page *page;
+	int dirty = 0;
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
@@ -466,6 +467,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	 * in the parent and the child
 	 */
 	if (is_cow_mapping(vm_flags)) {
+		dirty = pte_dirty(pte);
 		ptep_set_wrprotect(src_mm, addr, src_pte);
 		pte = pte_wrprotect(pte);
 	}
@@ -483,6 +485,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
 		get_page(page);
 		page_dup_rmap(page);
 		rss[!!PageAnon(page)]++;
+		if (dirty && PageLazyFree(page))
+			ClearPageLazyFree(page);
 	}
 
 out_set_pte:
@@ -661,6 +665,28 @@ static unsigned long zap_pte_range(struc
 				    (page->index < details->first_index ||
 				     page->index > details->last_index))
 					continue;
+
+				/*
+				 * MADV_FREE is used to lazily recycle
+				 * anon memory.  The process no longer
+				 * needs the data and wants to avoid IO.
+				 */
+				if (details->madv_free && PageAnon(page)) {
+					if (unlikely(PageSwapCache(page)) &&
+					    !TestSetPageLocked(page)) {
+						remove_exclusive_swap_page(page);
+						unlock_page(page);
+					}
+					ptep_test_and_clear_dirty(vma, addr, pte);
+					ptep_test_and_clear_young(vma, addr, pte);
+					SetPageLazyFree(page);
+					if (PageActive(page))
+						deactivate_tail_page(page);
+					/* tlb_remove_page frees it again */
+					get_page(page);
+					tlb_remove_page(tlb, page);
+					continue;
+				}
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
@@ -689,7 +715,8 @@ static unsigned long zap_pte_range(struc
 		 * If details->check_mapping, we leave swap entries;
 		 * if details->nonlinear_vma, we leave file entries.
 		 */
-		if (unlikely(details))
+		if (unlikely(details && (details->check_mapping ||
+				details->nonlinear_vma)))
 			continue;
 		if (!pte_file(ptent))
 			free_swap_and_cache(pte_to_swp_entry(ptent));
@@ -755,7 +782,8 @@ static unsigned long unmap_page_range(st
 	pgd_t *pgd;
 	unsigned long next;
 
-	if (details && !details->check_mapping && !details->nonlinear_vma)
+	if (details && !details->check_mapping && !details->nonlinear_vma
+			&& !details->madv_free)
 		details = NULL;
 
 	BUG_ON(addr >= end);
--- linux-2.6.21.noarch/mm/vmscan.c.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/mm/vmscan.c	2007-04-27 16:03:22.000000000 -0400
@@ -473,6 +473,24 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		/* 
+		 * MADV_DONTNEED pages get reclaimed lazily, unless the
+		 * process reuses them before we get to them.
+		 */
+		if (PageLazyFree(page)) {
+			switch (try_to_unmap(page, 0)) {
+			case SWAP_FAIL:
+				ClearPageLazyFree(page);
+				goto activate_locked;
+			case SWAP_AGAIN:
+				ClearPageLazyFree(page);
+				goto keep_locked;
+			case SWAP_SUCCESS:
+				ClearPageLazyFree(page);
+				goto free_it;
+			}
+		}
+
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 
--- linux-2.6.21.noarch/mm/madvise.c.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/mm/madvise.c	2007-04-27 21:20:11.000000000 -0400
@@ -130,7 +130,8 @@ static long madvise_willneed(struct vm_a
  */
 static long madvise_dontneed(struct vm_area_struct * vma,
 			     struct vm_area_struct ** prev,
-			     unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end,
+			     int behavior)
 {
 	*prev = vma;
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
@@ -142,8 +143,14 @@ static long madvise_dontneed(struct vm_a
 			.last_index = ULONG_MAX,
 		};
 		zap_page_range(vma, start, end - start, &details);
-	} else
+	} else if (behavior == MADV_FREE) {
+		struct zap_details details = {
+			.madv_free = 1,
+		};
+		zap_page_range(vma, start, end - start, &details);
+	} else /* behavior == MADV_DONTNEED */
 		zap_page_range(vma, start, end - start, NULL);
+
 	return 0;
 }
 
@@ -215,5 +222,6 @@ madvise_vma(struct vm_area_struct *vma, 
 		break;
 
 	case MADV_DONTNEED:
-		error = madvise_dontneed(vma, prev, start, end);
+	case MADV_FREE:
+		error = madvise_dontneed(vma, prev, start, end, behavior);
 		break;
 
--- linux-2.6.21.noarch/mm/swap.c.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/mm/swap.c	2007-04-27 16:03:22.000000000 -0400
@@ -151,6 +151,20 @@ void fastcall activate_page(struct page 
 	spin_unlock_irq(&zone->lru_lock);
 }
 
+void fastcall deactivate_tail_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	if (PageLRU(page) && PageActive(page)) {
+		del_page_from_active_list(zone, page);
+		ClearPageActive(page);
+		add_page_to_inactive_list_tail(zone, page);
+		__count_vm_event(PGDEACTIVATE);
+	}
+	spin_unlock_irq(&zone->lru_lock);
+}
+
 /*
  * Mark a page as having seen activity.
  *
--- linux-2.6.21.noarch/include/linux/page-flags.h.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/page-flags.h	2007-04-27 16:03:22.000000000 -0400
@@ -91,6 +91,8 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_lazyfree		20	/* MADV_FREE potential throwaway */
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 
@@ -237,6 +239,11 @@ static inline void SetPageUptodate(struc
 #define ClearPageReclaim(page)	clear_bit(PG_reclaim, &(page)->flags)
 #define TestClearPageReclaim(page) test_and_clear_bit(PG_reclaim, &(page)->flags)
 
+#define PageLazyFree(page)	test_bit(PG_lazyfree, &(page)->flags)
+#define SetPageLazyFree(page)	set_bit(PG_lazyfree, &(page)->flags)
+#define ClearPageLazyFree(page)	clear_bit(PG_lazyfree, &(page)->flags)
+#define __ClearPageLazyFree(page) __clear_bit(PG_lazyfree, &(page)->flags)
+
 #define PageCompound(page)	test_bit(PG_compound, &(page)->flags)
 #define __SetPageCompound(page)	__set_bit(PG_compound, &(page)->flags)
 #define __ClearPageCompound(page) __clear_bit(PG_compound, &(page)->flags)
--- linux-2.6.21.noarch/include/linux/mm.h.madv_free	2007-04-27 16:03:22.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/mm.h	2007-04-27 16:03:22.000000000 -0400
@@ -716,6 +716,7 @@ struct zap_details {
 	pgoff_t last_index;			/* Highest page->index to unmap */
 	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
+	short madv_free;			/* MADV_FREE anonymous memory */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
--- linux-2.6.21.noarch/include/linux/swap.h.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/swap.h	2007-04-27 16:03:22.000000000 -0400
@@ -181,6 +181,7 @@ extern unsigned int nr_free_pagecache_pa
 extern void FASTCALL(lru_cache_add(struct page *));
 extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(activate_page(struct page *));
+extern void FASTCALL(deactivate_tail_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
--- linux-2.6.21.noarch/include/linux/mm_inline.h.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/linux/mm_inline.h	2007-04-27 16:03:22.000000000 -0400
@@ -13,6 +13,13 @@ add_page_to_inactive_list(struct zone *z
 }
 
 static inline void
+add_page_to_inactive_list_tail(struct zone *zone, struct page *page)
+{
+	list_add_tail(&page->lru, &zone->inactive_list);
+	__inc_zone_state(zone, NR_INACTIVE);
+}
+
+static inline void
 del_page_from_active_list(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
--- linux-2.6.21.noarch/include/asm-sparc/mman.h.madv_free	2007-04-27 21:13:53.000000000 -0400
+++ linux-2.6.21.noarch/include/asm-sparc/mman.h	2007-04-27 21:14:13.000000000 -0400
@@ -33,8 +33,6 @@
 #define MC_LOCKAS       5  /* Lock an entire address space of the calling process */
 #define MC_UNLOCKAS     6  /* Unlock entire address space of calling process */
 
-#define MADV_FREE	0x5		/* (Solaris) contents can be freed */
-
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
 #define arch_mmap_check	sparc_mmap_check
--- linux-2.6.21.noarch/include/asm-parisc/mman.h.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/asm-parisc/mman.h	2007-04-27 16:03:22.000000000 -0400
@@ -38,6 +38,7 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
+#define MADV_FREE	8		/* don't need the pages or the data */
 
 /* common/generic parameters */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21.noarch/include/asm-xtensa/mman.h.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/asm-xtensa/mman.h	2007-04-27 16:03:22.000000000 -0400
@@ -72,6 +72,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21.noarch/include/asm-generic/mman.h.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/asm-generic/mman.h	2007-04-27 16:03:22.000000000 -0400
@@ -29,6 +29,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21.noarch/include/asm-mips/mman.h.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/asm-mips/mman.h	2007-04-27 16:03:22.000000000 -0400
@@ -65,6 +65,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21.noarch/include/asm-sparc64/mman.h.madv_free	2007-04-27 21:14:00.000000000 -0400
+++ linux-2.6.21.noarch/include/asm-sparc64/mman.h	2007-04-27 21:14:16.000000000 -0400
@@ -33,8 +33,6 @@
 #define MC_LOCKAS       5  /* Lock an entire address space of the calling process */
 #define MC_UNLOCKAS     6  /* Unlock entire address space of calling process */
 
-#define MADV_FREE	0x5		/* (Solaris) contents can be freed */
-
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
 #define arch_mmap_check	sparc64_mmap_check
--- linux-2.6.21.noarch/include/asm-alpha/mman.h.madv_free	2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21.noarch/include/asm-alpha/mman.h	2007-04-27 16:03:22.000000000 -0400
@@ -42,6 +42,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
+#define MADV_FREE	7		/* don't need the pages or the data */
 
 /* common/generic parameters */
 #define MADV_REMOVE	9		/* remove these pages & resources */

--------------070804080407080401080304--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
