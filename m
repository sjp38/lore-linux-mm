Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6C8E6B0006
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 18:06:43 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id g66so8215157vke.0
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 15:06:43 -0800 (PST)
Received: from smtp.tom.com (smtprz15.163.net. [106.3.154.248])
        by mx.google.com with SMTP id g15-v6si236706pli.791.2018.02.10.05.21.12
        for <linux-mm@kvack.org>;
        Sat, 10 Feb 2018 05:21:13 -0800 (PST)
Received: from antispam2.tom.com (unknown [172.25.16.56])
	by my-app01.tom.com (SMTP) with ESMTP id 273B11B00613
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 21:26:44 +0800 (CST)
Received: from antispam2.tom.com (antispam2.tom.com [127.0.0.1])
	by antispam2.tom.com (Postfix) with ESMTP id A19D8810D0
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 21:21:10 +0800 (CST)
Received: from antispam2.tom.com ([127.0.0.1])
	by antispam2.tom.com (antispam2.tom.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vnNAxC33xmc9 for <linux-mm@kvack.org>;
	Sat, 10 Feb 2018 21:21:09 +0800 (CST)
From: zhouxianrong <zhouxianrong@tom.com>
Subject: [PATCH] mm: Reset zero swap page to empty_zero_page for reading swap fault.
Date: Sat, 10 Feb 2018 08:20:44 -0500
Message-Id: <20180210132044.15255-1-zhouxianrong@tom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, dave.jiang@intel.com, jglisse@redhat.com, willy@linux.intel.com, hughd@google.com, dan.j.williams@intel.com, ying.huang@intel.com, kstewart@linuxfoundation.org, tglx@linutronix.de, gregkh@linuxfoundation.org, tim.c.chen@linux.intel.com, hannes@cmpxchg.org, shli@fb.com, mgorman@suse.de, vbabka@suse.cz, alexander.levin@verizon.com, riel@redhat.com, mhairgrove@nvidia.com, egtvedt@samfundet.no, dennisz@fb.com, me@tobin.cc, n-horiguchi@ah.jp.nec.com, will.deacon@arm.com, hillf.zj@alibaba-inc.com, vegard.nossum@oracle.com, aaron.lu@intel.com, zhouxianrong@tom.com

Reset zero swap page to empty_zero_page for reading swap fault.
for now zram driver could tell us which page is zero page and so it
introduces PG_zero to flag the zeroed page.

When reading swap fault happens it directly maps the fault
address to empty_zero_page rather than the original swap page.
The original allocated swap page would be freed soon. so it
saves few memories but it might increase same amount page
faults as well.

The PG_zero page is only present in swap cache. when the page
is deleted from swap cache the PG_zero flag is removed at the
same time. and when the PG_zero page is reused in swap cache
for writing the PG_zero flag is removed as well.

For huge page i do not think clearly.

Test:
1. android 7.0 and kernel 3.10 and zram swap device.
2. launch 120 apps and once every 4s.
3. At last sample hiting/pswpin/pswpout.

The result is:
663/84776/254630

Signed-off-by: zhouxianrong <zhouxianrong@tom.com>
---
 drivers/block/zram/zram_drv.c  |  3 +++
 include/linux/mm.h             |  1 +
 include/linux/page-flags.h     | 10 ++++++++++
 include/linux/swap.h           | 17 +++++++++++++++++
 include/trace/events/mmflags.h |  9 ++++++++-
 mm/Kconfig                     | 12 ++++++++++++
 mm/memory.c                    | 36 ++++++++++++++++++++++++++++++++++++
 mm/migrate.c                   |  6 +++++-
 mm/rmap.c                      |  5 +++++
 mm/swap_state.c                |  1 +
 mm/swapfile.c                  |  1 +
 11 files changed, 99 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index d70eba30003a..de7b161828f1 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -32,6 +32,7 @@
 #include <linux/idr.h>
 #include <linux/sysfs.h>
 #include <linux/cpuhotplug.h>
+#include <linux/swap.h>
 
 #include "zram_drv.h"
 
@@ -866,6 +867,8 @@ static int __zram_bvec_read(struct zram *zram, struct page *page, u32 index,
 		zram_fill_page(mem, PAGE_SIZE, value);
 		kunmap_atomic(mem);
 		zram_slot_unlock(zram, index);
+		if (value == 0)
+			wap_mark_page_zero(page);
 		return 0;
 	}
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..789ef75eac2b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -344,6 +344,7 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
+	swp_entry_t entry;		/* Swap entry at the time of fault */
 	/* These three entries are valid only while holding ptl lock */
 	pte_t *pte;			/* Pointer to pte entry matching
 					 * the 'address'. NULL if the page
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 3ec44e27aa9d..e987cc5047f9 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -106,6 +106,9 @@ enum pageflags {
 	PG_young,
 	PG_idle,
 #endif
+#ifdef CONFIG_SWAP_PAGE_ZERO
+	PG_zero,		/* zero page */
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -374,6 +377,13 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
+#ifdef CONFIG_SWAP_PAGE_ZERO
+PAGEFLAG(Zero, zero, PF_ANY)
+#else
+PAGEFLAG_FALSE(Zero)
+#endif
+
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c2b8128799c1..6d00ad1ac6ff 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -435,6 +435,17 @@ extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 					   struct vm_fault *vmf,
 					   struct vma_swap_readahead *swap_ra);
 
+#ifdef CONFIG_SWAP_PAGE_ZERO
+static inline void swap_mark_page_zero(struct page *page)
+{
+	if (unlikely(!PageLocked(page)))
+		return;
+	if (unlikely(!PageSwapCache(page)))
+		return;
+	SetPageZero(page);
+}
+#endif
+
 /* linux/mm/swapfile.c */
 extern atomic_long_t nr_swap_pages;
 extern long total_swap_pages;
@@ -631,6 +642,12 @@ static inline swp_entry_t get_swap_page(struct page *page)
 	return entry;
 }
 
+#ifdef CONFIG_SWAP_PAGE_ZERO
+void swap_mark_page_zero(struct page *page)
+{
+}
+#endif
+
 #endif /* CONFIG_SWAP */
 
 #ifdef CONFIG_THP_SWAP
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index dbe1bb058c09..967e751592ef 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -79,6 +79,12 @@
 #define IF_HAVE_PG_IDLE(flag,string)
 #endif
 
+#ifdef CONFIG_SWAP_PAGE_ZERO
+#define IF_HAVE_PG_ZERO(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_ZERO(flag,string)
+#endif
+
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
 	{1UL << PG_waiters,		"waiters"	},		\
@@ -104,7 +110,8 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
 IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
-IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
+IF_HAVE_PG_ZERO(PG_zero,		"zero"		)
 
 #define show_page_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
diff --git a/mm/Kconfig b/mm/Kconfig
index 03ff7703d322..152014adc19c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -486,6 +486,18 @@ config FRONTSWAP
 
 	  If unsure, say Y to enable frontswap.
 
+config SWAP_PAGE_ZERO
+	bool "Reset zero swap page to empty_zero_page for reading swap fault"
+	depends on SWAP
+	default n
+	help
+	  Reset zero swap page to empty_zero_page when reading
+	  swap fault happens. The original swap page would be freed soon.
+	  This could save few memories as well increase same amount page
+	  faults.
+
+	  If unsure, say N
+
 config CMA
 	bool "Contiguous Memory Allocator"
 	depends on HAVE_MEMBLOCK && MMU
diff --git a/mm/memory.c b/mm/memory.c
index 793004608332..5b088d43d5c8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2836,6 +2836,35 @@ void unmap_mapping_range(struct address_space *mapping,
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
+#ifdef CONFIG_SWAP_PAGE_ZERO
+static int swap_page_zero_shared(struct vm_fault *vmf)
+{
+	pte_t pte;
+	struct vm_area_struct *vma = vmf->vma;
+
+	/* Use the zero-page for reads */
+	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
+			!mm_forbids_zeropage(vma->vm_mm)) {
+		pte = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
+						vma->vm_page_prot));
+
+		dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
+		set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
+		/* No need to invalidate - it was non-present before */
+		update_mmu_cache(vma, vmf->address, vmf->pte);
+		swap_free(vmf->entry);
+		try_to_free_swap(vmf->page);
+		return 1;
+	}
+	return 0;
+}
+#else
+static int swap_page_zero_shared(struct vm_fault *vmf)
+{
+	return 0;
+}
+#endif
+
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
@@ -2994,6 +3023,13 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out_nomap;
 	}
 
+	if (unlikely(PageZero(page))) {
+		vmf->page = page;
+		vmf->entry = entry;
+		if (swap_page_zero_shared(vmf))
+			goto out_nomap;
+	}
+
 	/*
 	 * The page isn't present yet, go ahead with the fault.
 	 *
diff --git a/mm/migrate.c b/mm/migrate.c
index 4d0be47a322a..b59bf5596974 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -509,6 +509,8 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		if (PageSwapCache(page)) {
 			SetPageSwapCache(newpage);
 			set_page_private(newpage, page_private(page));
+			if (PageZero(page))
+				SetPageZero(newpage);
 		}
 	} else {
 		VM_BUG_ON_PAGE(PageSwapCache(page), page);
@@ -696,8 +698,10 @@ void migrate_page_states(struct page *newpage, struct page *page)
 	 * Please do not reorder this without considering how mm/ksm.c's
 	 * get_ksm_page() depends upon ksm_migrate_page() and PageSwapCache().
 	 */
-	if (PageSwapCache(page))
+	if (PageSwapCache(page)) {
 		ClearPageSwapCache(page);
+		ClearPageZero(page);
+	}
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 47db27f8049e..2ab463ef65b6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1550,6 +1550,11 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				break;
 			}
 
+			if (unlikely(PageZero(page))) {
+				dec_mm_counter(mm, MM_ANONPAGES);
+				goto discard;
+			}
+
 			if (swap_duplicate(entry) < 0) {
 				set_pte_at(mm, address, pvmw.pte, pteval);
 				ret = false;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 39ae7cfad90f..51fe913f695e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -192,6 +192,7 @@ void __delete_from_swap_cache(struct page *page)
 		set_page_private(page + i, 0);
 	}
 	ClearPageSwapCache(page);
+	ClearPageZero(page);
 	address_space->nrpages -= nr;
 	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
 	ADD_CACHE_INFO(del_total, nr);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3074b02eaa09..3753c6b1b19f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1577,6 +1577,7 @@ bool reuse_swap_page(struct page *page, int *total_map_swapcount)
 				return false;
 			}
 			spin_unlock(&p->lock);
+			ClearPageZero(page);
 		}
 	}
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
