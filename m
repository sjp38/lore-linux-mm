Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 432AE6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:59:28 -0500 (EST)
Date: Tue, 10 Nov 2009 21:59:23 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 3/6] mm: CONFIG_MMU for PG_mlocked
In-Reply-To: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911102155180.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove three degrees of obfuscation, left over from when we had
CONFIG_UNEVICTABLE_LRU.  MLOCK_PAGES is CONFIG_HAVE_MLOCKED_PAGE_BIT
is CONFIG_HAVE_MLOCK is CONFIG_MMU.  rmap.o (and memory-failure.o)
are only built when CONFIG_MMU, so don't need such conditions at all.

Somehow, I feel no compulsion to remove the CONFIG_HAVE_MLOCK*
lines from 169 defconfigs: leave those to evolve in due course.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/page-flags.h |    8 +++-----
 mm/Kconfig                 |    8 --------
 mm/internal.h              |   26 ++++++++++++--------------
 mm/memory-failure.c        |    2 --
 mm/page_alloc.c            |    4 ----
 mm/rmap.c                  |   17 +++++------------
 6 files changed, 20 insertions(+), 45 deletions(-)

--- mm2/include/linux/page-flags.h	2009-11-02 12:32:34.000000000 +0000
+++ mm3/include/linux/page-flags.h	2009-11-04 10:52:58.000000000 +0000
@@ -99,7 +99,7 @@ enum pageflags {
 	PG_buddy,		/* Page is free, on buddy lists */
 	PG_swapbacked,		/* Page is backed by RAM/swap */
 	PG_unevictable,		/* Page is "unevictable"  */
-#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
+#ifdef CONFIG_MMU
 	PG_mlocked,		/* Page is vma mlocked */
 #endif
 #ifdef CONFIG_ARCH_USES_PG_UNCACHED
@@ -259,12 +259,10 @@ PAGEFLAG_FALSE(SwapCache)
 PAGEFLAG(Unevictable, unevictable) __CLEARPAGEFLAG(Unevictable, unevictable)
 	TESTCLEARFLAG(Unevictable, unevictable)
 
-#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
-#define MLOCK_PAGES 1
+#ifdef CONFIG_MMU
 PAGEFLAG(Mlocked, mlocked) __CLEARPAGEFLAG(Mlocked, mlocked)
 	TESTSCFLAG(Mlocked, mlocked) __TESTCLEARFLAG(Mlocked, mlocked)
 #else
-#define MLOCK_PAGES 0
 PAGEFLAG_FALSE(Mlocked) SETPAGEFLAG_NOOP(Mlocked)
 	TESTCLEARFLAG_FALSE(Mlocked) __TESTCLEARFLAG_FALSE(Mlocked)
 #endif
@@ -393,7 +391,7 @@ static inline void __ClearPageTail(struc
 
 #endif /* !PAGEFLAGS_EXTENDED */
 
-#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
+#ifdef CONFIG_MMU
 #define __PG_MLOCKED		(1 << PG_mlocked)
 #else
 #define __PG_MLOCKED		0
--- mm2/mm/Kconfig	2009-11-02 12:32:34.000000000 +0000
+++ mm3/mm/Kconfig	2009-11-04 10:52:58.000000000 +0000
@@ -203,14 +203,6 @@ config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
 
-config HAVE_MLOCK
-	bool
-	default y if MMU=y
-
-config HAVE_MLOCKED_PAGE_BIT
-	bool
-	default y if HAVE_MLOCK=y
-
 config MMU_NOTIFIER
 	bool
 
--- mm2/mm/internal.h	2009-09-28 00:28:41.000000000 +0100
+++ mm3/mm/internal.h	2009-11-04 10:52:58.000000000 +0000
@@ -63,17 +63,6 @@ static inline unsigned long page_order(s
 	return page_private(page);
 }
 
-#ifdef CONFIG_HAVE_MLOCK
-extern long mlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end);
-extern void munlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end);
-static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
-{
-	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
-}
-#endif
-
 /*
  * unevictable_migrate_page() called only from migrate_page_copy() to
  * migrate unevictable flag to new page.
@@ -86,7 +75,16 @@ static inline void unevictable_migrate_p
 		SetPageUnevictable(new);
 }
 
-#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
+#ifdef CONFIG_MMU
+extern long mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
+extern void munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
+static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
+{
+	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
+}
+
 /*
  * Called only in fault path via page_evictable() for a new page
  * to determine if it's being mapped into a LOCKED vma.
@@ -144,7 +142,7 @@ static inline void mlock_migrate_page(st
 	}
 }
 
-#else /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
+#else /* !CONFIG_MMU */
 static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
 {
 	return 0;
@@ -153,7 +151,7 @@ static inline void clear_page_mlock(stru
 static inline void mlock_vma_page(struct page *page) { }
 static inline void mlock_migrate_page(struct page *new, struct page *old) { }
 
-#endif /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
+#endif /* !CONFIG_MMU */
 
 /*
  * Return the mem_map entry representing the 'offset' subpage within
--- mm2/mm/memory-failure.c	2009-11-02 12:32:34.000000000 +0000
+++ mm3/mm/memory-failure.c	2009-11-04 10:52:58.000000000 +0000
@@ -582,10 +582,8 @@ static struct page_state {
 	{ unevict|dirty, unevict|dirty,	"unevictable LRU", me_pagecache_dirty},
 	{ unevict,	unevict,	"unevictable LRU", me_pagecache_clean},
 
-#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
 	{ mlock|dirty,	mlock|dirty,	"mlocked LRU",	me_pagecache_dirty },
 	{ mlock,	mlock,		"mlocked LRU",	me_pagecache_clean },
-#endif
 
 	{ lru|dirty,	lru|dirty,	"LRU",		me_pagecache_dirty },
 	{ lru|dirty,	lru,		"clean LRU",	me_pagecache_clean },
--- mm2/mm/page_alloc.c	2009-11-02 12:32:34.000000000 +0000
+++ mm3/mm/page_alloc.c	2009-11-04 10:52:58.000000000 +0000
@@ -487,7 +487,6 @@ static inline void __free_one_page(struc
 	zone->free_area[order].nr_free++;
 }
 
-#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
 /*
  * free_page_mlock() -- clean up attempts to free and mlocked() page.
  * Page should not be on lru, so no need to fix that up.
@@ -503,9 +502,6 @@ static inline void free_page_mlock(struc
 	__dec_zone_page_state(page, NR_MLOCK);
 	__count_vm_event(UNEVICTABLE_MLOCKFREED);
 }
-#else
-static void free_page_mlock(struct page *page) { }
-#endif
 
 static inline int free_pages_check(struct page *page)
 {
--- mm2/mm/rmap.c	2009-11-04 10:52:52.000000000 +0000
+++ mm3/mm/rmap.c	2009-11-04 10:52:58.000000000 +0000
@@ -787,7 +787,7 @@ static int try_to_unmap_one(struct page
 			ret = SWAP_MLOCK;
 			goto out_unmap;
 		}
-		if (MLOCK_PAGES && TTU_ACTION(flags) == TTU_MUNLOCK)
+		if (TTU_ACTION(flags) == TTU_MUNLOCK)
 			goto out_unmap;
 	}
 	if (!(flags & TTU_IGNORE_ACCESS)) {
@@ -860,7 +860,7 @@ static int try_to_unmap_one(struct page
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 
-	if (MLOCK_PAGES && ret == SWAP_MLOCK) {
+	if (ret == SWAP_MLOCK) {
 		ret = SWAP_AGAIN;
 		if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
 			if (vma->vm_flags & VM_LOCKED) {
@@ -937,11 +937,10 @@ static int try_to_unmap_cluster(unsigned
 		return ret;
 
 	/*
-	 * MLOCK_PAGES => feature is configured.
-	 * if we can acquire the mmap_sem for read, and vma is VM_LOCKED,
+	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
 	 * keep the sem while scanning the cluster for mlocking pages.
 	 */
-	if (MLOCK_PAGES && down_read_trylock(&vma->vm_mm->mmap_sem)) {
+	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
 		locked_vma = (vma->vm_flags & VM_LOCKED);
 		if (!locked_vma)
 			up_read(&vma->vm_mm->mmap_sem); /* don't need it */
@@ -1065,14 +1064,11 @@ static int try_to_unmap_file(struct page
 		goto out;
 
 	/* We don't bother to try to find the munlocked page in nonlinears */
-	if (MLOCK_PAGES && TTU_ACTION(flags) == TTU_MUNLOCK)
+	if (TTU_ACTION(flags) == TTU_MUNLOCK)
 		goto out;
 
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-		if (!MLOCK_PAGES && !(flags & TTU_IGNORE_MLOCK) &&
-			(vma->vm_flags & VM_LOCKED))
-			continue;
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
 			max_nl_cursor = cursor;
@@ -1105,9 +1101,6 @@ static int try_to_unmap_file(struct page
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if (!MLOCK_PAGES && !(flags & TTU_IGNORE_MLOCK) &&
-			    (vma->vm_flags & VM_LOCKED))
-				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
