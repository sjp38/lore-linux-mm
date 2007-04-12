Message-ID: <461E9D77.4080308@redhat.com>
Date: Thu, 12 Apr 2007 16:58:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] make MADV_FREE lazily free memory
References: <461C6452.1000706@redhat.com> <461D6413.6050605@cosmosbay.com> <461D67A9.5020509@redhat.com> <461DC75B.8040200@cosmosbay.com> <461DCCEB.70004@yahoo.com.au> <461DCDDA.2030502@yahoo.com.au> <461DDE44.2040409@redhat.com> <461E30A6.5030203@yahoo.com.au>
In-Reply-To: <461E30A6.5030203@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------090803040506050309000905"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ulrich Drepper <drepper@redhat.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090803040506050309000905
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

>> The lazy freeing is aimed at avoiding page faults on memory
>> that is freed and later realloced, which is quite a common
>> thing in many workloads.
> 
> I would be interested to see how it performs and what these
> workloads look like, although we do need to fix the basic glibc and
> madvise locking problems first.

The attached graph are results of running the MySQL sysbench
workload on my quad core system.  As you can see, performance
with #threads == #cpus (4) almost doubles from 1070 transactions
per second to 2014 transactions/second.

On the high end (16 threads on 4 cpus), performance increases
from 778 transactions/second on vanilla to 1310 transactions/second.

I have also benchmarked running Ulrich's changed glibc on a vanilla
kernel, which gives results somewhere in-between, but much closer to
just the vanilla kernel.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--------------090803040506050309000905
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
+++ linux-2.6.20.noarch/include/linux/swap.h	2007-04-06 17:19:20.000000000 -0400
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
+++ linux-2.6.20.noarch/mm/memory.c	2007-04-06 17:18:23.000000000 -0400
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
@@ -661,6 +665,26 @@ static unsigned long zap_pte_range(struc
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
@@ -689,7 +713,8 @@ static unsigned long zap_pte_range(struc
 		 * If details->check_mapping, we leave swap entries;
 		 * if details->nonlinear_vma, we leave file entries.
 		 */
-		if (unlikely(details))
+		if (unlikely(!details->check_mapping &&
+				!details->nonlinear_vma))
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
 

--------------090803040506050309000905
Content-Type: image/png;
 name="mysql.png"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="mysql.png"

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
--------------090803040506050309000905--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
