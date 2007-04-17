Message-ID: <46247427.6000902@redhat.com>
Date: Tue, 17 Apr 2007 03:15:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [PATCH] lazy freeing of memory through MADV_FREE
Content-Type: multipart/mixed;
 boundary="------------020001060208070206010504"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020001060208070206010504
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Make it possible for applications to have the kernel free memory
lazily.  This reduces a repeated free/malloc cycle from freeing
pages and allocating them, to just marking them freeable.  If the
application wants to reuse them before the kernel needs the memory,
not even a page fault will happen.

This patch, together with Ulrich's glibc change, increases
MySQL sysbench performance by a factor of 2 on my quad core
test system.

Signed-off-by: Rik van Riel <riel@redhat.com>

---
Ulrich Drepper has test glibc RPMS for this functionality at:

     http://people.redhat.com/drepper/rpms

Andrew, I have stress tested this patch for a few days now and
have not been able to find any more bugs.  I believe it is ready
to be merged in -mm, and upstream at the next merge window.

When the patch goes upstream, I will submit a small follow-up
patch to revert MADV_DONTNEED behaviour to what it did previously
and have the new behaviour trigger only on MADV_FREE: at that
point people will have to get new test RPMs of glibc.


--------------020001060208070206010504
Content-Type: text/x-patch;
 name="linux-2.6.21-rc6-mm1-madv_free.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.21-rc6-mm1-madv_free.patch"

--- linux-2.6.21-rc6-mm1/include/asm-parisc/mman.h.madv_free	2007-04-17 02:17:19.000000000 -0400
+++ linux-2.6.21-rc6-mm1/include/asm-parisc/mman.h	2007-04-17 02:22:46.000000000 -0400
@@ -38,6 +38,7 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
+#define MADV_FREE	8		/* don't need the pages or the data */
 
 /* common/generic parameters */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21-rc6-mm1/include/asm-mips/mman.h.madv_free	2007-04-17 02:17:19.000000000 -0400
+++ linux-2.6.21-rc6-mm1/include/asm-mips/mman.h	2007-04-17 02:22:46.000000000 -0400
@@ -65,6 +65,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21-rc6-mm1/include/asm-xtensa/mman.h.madv_free	2007-04-17 02:17:19.000000000 -0400
+++ linux-2.6.21-rc6-mm1/include/asm-xtensa/mman.h	2007-04-17 02:22:46.000000000 -0400
@@ -72,6 +72,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21-rc6-mm1/include/linux/swap.h.madv_free	2007-04-17 02:17:43.000000000 -0400
+++ linux-2.6.21-rc6-mm1/include/linux/swap.h	2007-04-17 02:22:46.000000000 -0400
@@ -182,6 +182,7 @@ extern void FASTCALL(lru_cache_add(struc
 extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(lru_cache_add_tail(struct page *));
 extern void FASTCALL(activate_page(struct page *));
+extern void FASTCALL(deactivate_tail_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
--- linux-2.6.21-rc6-mm1/include/linux/mm.h.madv_free	2007-04-17 02:17:43.000000000 -0400
+++ linux-2.6.21-rc6-mm1/include/linux/mm.h	2007-04-17 02:22:46.000000000 -0400
@@ -767,6 +767,7 @@ struct zap_details {
 	pgoff_t last_index;			/* Highest page->index to unmap */
 	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
+	short madv_free;			/* MADV_FREE anonymous memory */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
--- linux-2.6.21-rc6-mm1/include/linux/page-flags.h.madv_free	2007-04-17 02:17:43.000000000 -0400
+++ linux-2.6.21-rc6-mm1/include/linux/page-flags.h	2007-04-17 02:23:16.000000000 -0400
@@ -91,6 +91,7 @@
 #define PG_booked		20	/* Has blocks reserved on-disk */
 
 #define PG_readahead		21	/* Reminder to do read-ahead */
+#define PG_lazyfree		22	/* MADV_FREE potential throwaway */
 
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
@@ -216,6 +217,11 @@ static inline void SetPageUptodate(struc
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
--- linux-2.6.21-rc6-mm1/include/asm-alpha/mman.h.madv_free	2007-04-17 02:17:19.000000000 -0400
+++ linux-2.6.21-rc6-mm1/include/asm-alpha/mman.h	2007-04-17 02:22:46.000000000 -0400
@@ -42,6 +42,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
+#define MADV_FREE	7		/* don't need the pages or the data */
 
 /* common/generic parameters */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21-rc6-mm1/include/asm-generic/mman.h.madv_free	2007-04-17 02:17:19.000000000 -0400
+++ linux-2.6.21-rc6-mm1/include/asm-generic/mman.h	2007-04-17 02:22:46.000000000 -0400
@@ -29,6 +29,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.21-rc6-mm1/mm/memory.c.madv_free	2007-04-17 02:17:43.000000000 -0400
+++ linux-2.6.21-rc6-mm1/mm/memory.c	2007-04-17 02:22:46.000000000 -0400
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
 		page_dup_rmap(page, vma, addr);
 		rss[!!PageAnon(page)]++;
+		if (dirty && PageLazyFree(page))
+			ClearPageLazyFree(page);
 	}
 
 out_set_pte:
@@ -661,6 +665,25 @@ static unsigned long zap_pte_range(struc
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
+					ptep_clear_flush_dirty(vma, addr, pte);
+					ptep_clear_flush_young(vma, addr, pte);
+					SetPageLazyFree(page);
+					if (PageActive(page))
+						deactivate_tail_page(page);
+					continue;
+				}
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
@@ -689,7 +713,8 @@ static unsigned long zap_pte_range(struc
 		 * If details->check_mapping, we leave swap entries;
 		 * if details->nonlinear_vma, we leave file entries.
 		 */
-		if (unlikely(details))
+		if (unlikely(details && (details->check_mapping ||
+				details->nonlinear_vma)))
 			continue;
 		if (!pte_file(ptent))
 			free_swap_and_cache(pte_to_swp_entry(ptent));
@@ -755,7 +780,8 @@ static unsigned long unmap_page_range(st
 	pgd_t *pgd;
 	unsigned long next;
 
-	if (details && !details->check_mapping && !details->nonlinear_vma)
+	if (details && !details->check_mapping && !details->nonlinear_vma
+			&& !details->madv_free)
 		details = NULL;
 
 	BUG_ON(addr >= end);
--- linux-2.6.21-rc6-mm1/mm/page_alloc.c.madv_free	2007-04-17 02:17:43.000000000 -0400
+++ linux-2.6.21-rc6-mm1/mm/page_alloc.c	2007-04-17 02:22:46.000000000 -0400
@@ -266,6 +266,7 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
+			1 << PG_lazyfree |
 			1 << PG_buddy );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
@@ -514,6 +515,8 @@ static inline int free_pages_check(struc
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
+	if (PageLazyFree(page))
+		__ClearPageLazyFree(page);
 	/*
 	 * For now, we report if PG_reserved was found set, but do not
 	 * clear it, and do not free the page.  But we shall soon need
@@ -661,6 +664,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+			1 << PG_lazyfree |
 			1 << PG_buddy ))))
 		bad_page(page);
 
--- linux-2.6.21-rc6-mm1/mm/swap.c.madv_free	2007-04-17 02:17:43.000000000 -0400
+++ linux-2.6.21-rc6-mm1/mm/swap.c	2007-04-17 02:22:46.000000000 -0400
@@ -152,6 +152,20 @@ void fastcall activate_page(struct page 
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
--- linux-2.6.21-rc6-mm1/mm/vmscan.c.madv_free	2007-04-17 02:17:43.000000000 -0400
+++ linux-2.6.21-rc6-mm1/mm/vmscan.c	2007-04-17 02:22:46.000000000 -0400
@@ -460,6 +460,24 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		/* 
+		 * MADV_DONTNEED pages get reclaimed lazily, unless the
+		 * process reuses it before we get to it.
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
 
--- linux-2.6.21-rc6-mm1/mm/madvise.c.madv_free	2007-04-17 02:17:20.000000000 -0400
+++ linux-2.6.21-rc6-mm1/mm/madvise.c	2007-04-17 02:22:46.000000000 -0400
@@ -142,8 +142,12 @@ static long madvise_dontneed(struct vm_a
 			.last_index = ULONG_MAX,
 		};
 		zap_page_range(vma, start, end - start, &details);
-	} else
-		zap_page_range(vma, start, end - start, NULL);
+	} else {
+		struct zap_details details = {
+			.madv_free = 1,
+		};
+		zap_page_range(vma, start, end - start, &details);
+	}
 	return 0;
 }
 
@@ -215,7 +219,9 @@ madvise_vma(struct vm_area_struct *vma, 
 		error = madvise_willneed(vma, prev, start, end);
 		break;
 
+	/* FIXME: POSIX says that MADV_DONTNEED cannot throw away data. */
 	case MADV_DONTNEED:
+	case MADV_FREE:
 		error = madvise_dontneed(vma, prev, start, end);
 		break;
 
--- linux-2.6.21-rc6-mm1/mm/rmap.c.madv_free	2007-04-17 02:17:43.000000000 -0400
+++ linux-2.6.21-rc6-mm1/mm/rmap.c	2007-04-17 02:22:46.000000000 -0400
@@ -707,7 +707,17 @@ static int try_to_unmap_one(struct page 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
 
-	if (PageAnon(page)) {
+	/* MADV_FREE is used to lazily free memory from userspace. */
+	if (PageLazyFree(page) && !migration) {
+		/* There is new data in the page.  Reinstate it. */
+		if (unlikely(pte_dirty(pteval))) {
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+		/* Throw the page away. */
+		dec_mm_counter(mm, anon_rss);
+	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 
 		if (PageSwapCache(page)) {

--------------020001060208070206010504--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
