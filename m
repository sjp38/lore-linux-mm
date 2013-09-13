Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 768C26B0034
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 09:06:29 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/9] mm: rename SPLIT_PTLOCKS to SPLIT_PTE_PTLOCKS
Date: Fri, 13 Sep 2013 16:06:08 +0300
Message-Id: <1379077576-2472-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20130910074748.GA2971@gmail.com>
 <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to introduce split page table lock for PMD level.
Let's rename existing split ptlock for PTE level to avoid confusion.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/arm/mm/fault-armv.c            | 6 +++---
 arch/um/defconfig                   | 2 +-
 arch/x86/xen/mmu.c                  | 6 +++---
 arch/xtensa/configs/iss_defconfig   | 2 +-
 arch/xtensa/configs/s6105_defconfig | 2 +-
 include/linux/mm.h                  | 6 +++---
 include/linux/mm_types.h            | 8 ++++----
 mm/Kconfig                          | 2 +-
 8 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
index 2a5907b..ff379ac 100644
--- a/arch/arm/mm/fault-armv.c
+++ b/arch/arm/mm/fault-armv.c
@@ -65,7 +65,7 @@ static int do_adjust_pte(struct vm_area_struct *vma, unsigned long address,
 	return ret;
 }
 
-#if USE_SPLIT_PTLOCKS
+#if USE_SPLIT_PTE_PTLOCKS
 /*
  * If we are using split PTE locks, then we need to take the page
  * lock here.  Otherwise we are using shared mm->page_table_lock
@@ -84,10 +84,10 @@ static inline void do_pte_unlock(spinlock_t *ptl)
 {
 	spin_unlock(ptl);
 }
-#else /* !USE_SPLIT_PTLOCKS */
+#else /* !USE_SPLIT_PTE_PTLOCKS */
 static inline void do_pte_lock(spinlock_t *ptl) {}
 static inline void do_pte_unlock(spinlock_t *ptl) {}
-#endif /* USE_SPLIT_PTLOCKS */
+#endif /* USE_SPLIT_PTE_PTLOCKS */
 
 static int adjust_pte(struct vm_area_struct *vma, unsigned long address,
 	unsigned long pfn)
diff --git a/arch/um/defconfig b/arch/um/defconfig
index 08107a7..6b0a10f 100644
--- a/arch/um/defconfig
+++ b/arch/um/defconfig
@@ -82,7 +82,7 @@ CONFIG_FLATMEM_MANUAL=y
 CONFIG_FLATMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
 CONFIG_PAGEFLAGS_EXTENDED=y
-CONFIG_SPLIT_PTLOCK_CPUS=4
+CONFIG_SPLIT_PTE_PTLOCK_CPUS=4
 # CONFIG_COMPACTION is not set
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index fdc3ba2..455c873 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -796,7 +796,7 @@ static spinlock_t *xen_pte_lock(struct page *page, struct mm_struct *mm)
 {
 	spinlock_t *ptl = NULL;
 
-#if USE_SPLIT_PTLOCKS
+#if USE_SPLIT_PTE_PTLOCKS
 	ptl = __pte_lockptr(page);
 	spin_lock_nest_lock(ptl, &mm->page_table_lock);
 #endif
@@ -1637,7 +1637,7 @@ static inline void xen_alloc_ptpage(struct mm_struct *mm, unsigned long pfn,
 
 			__set_pfn_prot(pfn, PAGE_KERNEL_RO);
 
-			if (level == PT_PTE && USE_SPLIT_PTLOCKS)
+			if (level == PT_PTE && USE_SPLIT_PTE_PTLOCKS)
 				__pin_pagetable_pfn(MMUEXT_PIN_L1_TABLE, pfn);
 
 			xen_mc_issue(PARAVIRT_LAZY_MMU);
@@ -1671,7 +1671,7 @@ static inline void xen_release_ptpage(unsigned long pfn, unsigned level)
 		if (!PageHighMem(page)) {
 			xen_mc_batch();
 
-			if (level == PT_PTE && USE_SPLIT_PTLOCKS)
+			if (level == PT_PTE && USE_SPLIT_PTE_PTLOCKS)
 				__pin_pagetable_pfn(MMUEXT_UNPIN_TABLE, pfn);
 
 			__set_pfn_prot(pfn, PAGE_KERNEL);
diff --git a/arch/xtensa/configs/iss_defconfig b/arch/xtensa/configs/iss_defconfig
index 77c52f8..54cc946 100644
--- a/arch/xtensa/configs/iss_defconfig
+++ b/arch/xtensa/configs/iss_defconfig
@@ -174,7 +174,7 @@ CONFIG_FLATMEM_MANUAL=y
 CONFIG_FLATMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
 CONFIG_PAGEFLAGS_EXTENDED=y
-CONFIG_SPLIT_PTLOCK_CPUS=4
+CONFIG_SPLIT_PTE_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
diff --git a/arch/xtensa/configs/s6105_defconfig b/arch/xtensa/configs/s6105_defconfig
index 4799c6a..d802f11 100644
--- a/arch/xtensa/configs/s6105_defconfig
+++ b/arch/xtensa/configs/s6105_defconfig
@@ -138,7 +138,7 @@ CONFIG_FLATMEM_MANUAL=y
 CONFIG_FLATMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
 CONFIG_PAGEFLAGS_EXTENDED=y
-CONFIG_SPLIT_PTLOCK_CPUS=4
+CONFIG_SPLIT_PTE_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_VIRT_TO_BUS=y
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8b6e55e..6cf8ddb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1232,7 +1232,7 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 }
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
 
-#if USE_SPLIT_PTLOCKS
+#if USE_SPLIT_PTE_PTLOCKS
 /*
  * We tuck a spinlock to guard each pagetable page into its struct page,
  * at page->private, with BUILD_BUG_ON to make sure that this will not
@@ -1245,14 +1245,14 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 } while (0)
 #define pte_lock_deinit(page)	((page)->mapping = NULL)
 #define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
-#else	/* !USE_SPLIT_PTLOCKS */
+#else	/* !USE_SPLIT_PTE_PTLOCKS */
 /*
  * We use mm->page_table_lock to guard all pagetable pages of the mm.
  */
 #define pte_lock_init(page)	do {} while (0)
 #define pte_lock_deinit(page)	do {} while (0)
 #define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
-#endif /* USE_SPLIT_PTLOCKS */
+#endif /* USE_SPLIT_PTE_PTLOCKS */
 
 static inline void pgtable_page_ctor(struct page *page)
 {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index faf4b7c..fe0a4bb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -23,7 +23,7 @@
 
 struct address_space;
 
-#define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
+#define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTE_PTLOCK_CPUS)
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -141,7 +141,7 @@ struct page {
 						 * indicates order in the buddy
 						 * system if PG_buddy is set.
 						 */
-#if USE_SPLIT_PTLOCKS
+#if USE_SPLIT_PTE_PTLOCKS
 		spinlock_t ptl;
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
@@ -309,14 +309,14 @@ enum {
 	NR_MM_COUNTERS
 };
 
-#if USE_SPLIT_PTLOCKS && defined(CONFIG_MMU)
+#if USE_SPLIT_PTE_PTLOCKS && defined(CONFIG_MMU)
 #define SPLIT_RSS_COUNTING
 /* per-thread cached information, */
 struct task_rss_stat {
 	int events;	/* for synchronization threshold */
 	int count[NR_MM_COUNTERS];
 };
-#endif /* USE_SPLIT_PTLOCKS */
+#endif /* USE_SPLIT_PTE_PTLOCKS */
 
 struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
diff --git a/mm/Kconfig b/mm/Kconfig
index 026771a..1977a33 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -207,7 +207,7 @@ config PAGEFLAGS_EXTENDED
 # PA-RISC 7xxx's spinlock_t would enlarge struct page from 32 to 44 bytes.
 # DEBUG_SPINLOCK and DEBUG_LOCK_ALLOC spinlock_t also enlarge struct page.
 #
-config SPLIT_PTLOCK_CPUS
+config SPLIT_PTE_PTLOCK_CPUS
 	int
 	default "999999" if ARM && !CPU_CACHE_VIPT
 	default "999999" if PARISC && !PA20
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
