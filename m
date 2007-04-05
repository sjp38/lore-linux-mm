Message-ID: <4614A5CC.5080508@redhat.com>
Date: Thu, 05 Apr 2007 03:31:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com>
In-Reply-To: <20070403202937.GE355@devserv.devel.redhat.com>
Content-Type: multipart/mixed;
 boundary="------------020209030605080206030806"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020209030605080206030806
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Jakub Jelinek wrote:

> My guess is that all the page zeroing is pretty expensive as well and
> takes significant time, but I haven't profiled it.

With the attached patch (Andrew, I'll change the details around
if you want - I just wanted something to test now), your test
case run time went down considerably.

I modified the test case to only run 1000 loops, so it would run
a bit faster on my system.  I also modified it to use MADV_DONTNEED
to zap the pages, instead of the mmap(PROT_NONE) thing you use.


MADV_DONTNEED, unpatched, 1000 loops

real    0m13.672s
user    0m1.217s
sys     0m45.712s


MADV_DONTNEED, with patch, 1000 loops

real    0m4.169s
user    0m2.033s
sys     0m3.224s


-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--------------020209030605080206030806
Content-Type: text/x-patch;
 name="linux-2.6-madv_free.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-madv_free.patch"

--- linux-2.6.20.noarch/include/asm-alpha/mman.h.madvise	2007-04-04 16:44:50.000000000 -0400
+++ linux-2.6.20.noarch/include/asm-alpha/mman.h	2007-04-04 16:56:24.000000000 -0400
@@ -42,6 +42,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
+#define MADV_FREE	7		/* don't need the pages or the data */
 
 /* common/generic parameters */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.20.noarch/include/asm-generic/mman.h.madvise	2007-04-04 16:44:50.000000000 -0400
+++ linux-2.6.20.noarch/include/asm-generic/mman.h	2007-04-04 16:56:53.000000000 -0400
@@ -29,6 +29,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.20.noarch/include/asm-mips/mman.h.madvise	2007-04-04 16:44:50.000000000 -0400
+++ linux-2.6.20.noarch/include/asm-mips/mman.h	2007-04-04 16:58:02.000000000 -0400
@@ -65,6 +65,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.20.noarch/include/asm-parisc/mman.h.madvise	2007-04-04 16:44:50.000000000 -0400
+++ linux-2.6.20.noarch/include/asm-parisc/mman.h	2007-04-04 16:58:40.000000000 -0400
@@ -38,6 +38,7 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
+#define MADV_FREE	8		/* don't need the pages or the data */
 
 /* common/generic parameters */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.20.noarch/include/asm-xtensa/mman.h.madvise	2007-04-04 16:44:51.000000000 -0400
+++ linux-2.6.20.noarch/include/asm-xtensa/mman.h	2007-04-04 16:59:14.000000000 -0400
@@ -72,6 +72,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* don't need the pages or the data */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
--- linux-2.6.20.noarch/include/linux/mm_inline.h.madvise	2007-04-03 22:53:25.000000000 -0400
+++ linux-2.6.20.noarch/include/linux/mm_inline.h	2007-04-04 22:19:24.000000000 -0400
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
--- linux-2.6.20.noarch/include/linux/mm.h.madvise	2007-04-03 22:53:25.000000000 -0400
+++ linux-2.6.20.noarch/include/linux/mm.h	2007-04-04 22:06:45.000000000 -0400
@@ -716,6 +716,7 @@ struct zap_details {
 	pgoff_t last_index;			/* Highest page->index to unmap */
 	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
+	short madv_free;			/* MADV_FREE anonymous memory */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
--- linux-2.6.20.noarch/include/linux/page-flags.h.madvise	2007-04-03 22:54:58.000000000 -0400
+++ linux-2.6.20.noarch/include/linux/page-flags.h	2007-04-05 01:27:38.000000000 -0400
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
--- linux-2.6.20.noarch/include/linux/swap.h.madvise	2007-04-05 00:29:40.000000000 -0400
+++ linux-2.6.20.noarch/include/linux/swap.h	2007-04-04 23:35:00.000000000 -0400
@@ -181,6 +181,7 @@ extern unsigned int nr_free_pagecache_pa
 extern void FASTCALL(lru_cache_add(struct page *));
 extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(activate_page(struct page *));
+extern void FASTCALL(deactivate_tail_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
--- linux-2.6.20.noarch/mm/madvise.c.madvise	2007-04-03 21:53:47.000000000 -0400
+++ linux-2.6.20.noarch/mm/madvise.c	2007-04-04 23:48:34.000000000 -0400
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
 
@@ -209,7 +213,9 @@ madvise_vma(struct vm_area_struct *vma, 
 		error = madvise_willneed(vma, prev, start, end);
 		break;
 
+	/* FIXME: POSIX says that MADV_DONTNEED cannot throw away data. */
 	case MADV_DONTNEED:
+	case MADV_FREE:
 		error = madvise_dontneed(vma, prev, start, end);
 		break;
 
--- linux-2.6.20.noarch/mm/memory.c.madvise	2007-04-03 21:53:47.000000000 -0400
+++ linux-2.6.20.noarch/mm/memory.c	2007-04-04 23:56:57.000000000 -0400
@@ -661,6 +661,26 @@ static unsigned long zap_pte_range(struc
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
+					/* Optimize this... */
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
@@ -689,7 +709,8 @@ static unsigned long zap_pte_range(struc
 		 * If details->check_mapping, we leave swap entries;
 		 * if details->nonlinear_vma, we leave file entries.
 		 */
-		if (unlikely(details))
+		if (unlikely(!details->check_mapping &&
+				!details->nonlinear_vma))
 			continue;
 		if (!pte_file(ptent))
 			free_swap_and_cache(pte_to_swp_entry(ptent));
@@ -755,7 +776,8 @@ static unsigned long unmap_page_range(st
 	pgd_t *pgd;
 	unsigned long next;
 
-	if (details && !details->check_mapping && !details->nonlinear_vma)
+	if (details && !details->check_mapping && !details->nonlinear_vma
+			&& !details->madv_free)
 		details = NULL;
 
 	BUG_ON(addr >= end);
--- linux-2.6.20.noarch/mm/page_alloc.c.madvise	2007-04-03 21:53:47.000000000 -0400
+++ linux-2.6.20.noarch/mm/page_alloc.c	2007-04-05 01:27:55.000000000 -0400
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
 
--- linux-2.6.20.noarch/mm/rmap.c.madvise	2007-04-03 21:53:47.000000000 -0400
+++ linux-2.6.20.noarch/mm/rmap.c	2007-04-04 23:53:29.000000000 -0400
@@ -656,7 +656,17 @@ static int try_to_unmap_one(struct page 
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
--- linux-2.6.20.noarch/mm/swap.c.madvise	2007-04-03 21:53:47.000000000 -0400
+++ linux-2.6.20.noarch/mm/swap.c	2007-04-04 23:33:27.000000000 -0400
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
--- linux-2.6.20.noarch/mm/vmscan.c.madvise	2007-04-03 21:53:47.000000000 -0400
+++ linux-2.6.20.noarch/mm/vmscan.c	2007-04-04 03:34:56.000000000 -0400
@@ -473,6 +473,24 @@ static unsigned long shrink_page_list(st
 
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
 

--------------020209030605080206030806--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
