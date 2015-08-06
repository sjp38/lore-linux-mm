Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 94BC26B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 08:53:19 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so22891137wib.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 05:53:19 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id t2si3225122wiy.89.2015.08.06.05.53.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 05:53:17 -0700 (PDT)
Received: by wibhh20 with SMTP id hh20so22889552wib.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 05:53:17 -0700 (PDT)
Date: Thu, 6 Aug 2015 14:53:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2015-08-05-17-06 uploaded
Message-ID: <20150806125315.GG19825@dhcp22.suse.cz>
References: <55c2a523.5JaGZbDMxr+dV/A0%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55c2a523.5JaGZbDMxr+dV/A0%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

Andrew, it seems that proc-add-kpageidle-file-fix-6.patch
(pasted below) is incomplete. Unlike the original patch
(http://marc.info/?l=linux-mm&m=143826131310409&w=2) it is missing hunks
which are removing struct page_ext_operations page_idle_ops = {} and
others from
fs/proc/page.c and that leads to
fs/built-in.o:(.data+0xa4dc): multiple definition of `page_idle_ops'
mm/built-in.o:(.data+0x979c): first defined here
make: *** [vmlinux] Error 1

I have applied the original patch for my git tree. 
---
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Move /proc/kpageidle to /sys/kernel/mm/page_idle/bitmap

Since IDLE_PAGE_TRACKING does not need to depend on PROC_FS anymore,
this patch also moves the code from fs/proc/page.c to mm/page_idle.c and
introduces a dedicated header file include/linux/page_idle.h.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/vm/idle_page_tracking.txt |   38 +--
 Documentation/vm/pagemap.txt            |    5 
 fs/proc/page.c                          |    8 
 fs/proc/task_mmu.c                      |    1 
 include/linux/mm.h                      |   98 ---------
 include/linux/page_idle.h               |  110 ++++++++++
 mm/Kconfig                              |    3 
 mm/Makefile                             |    1 
 mm/huge_memory.c                        |    1 
 mm/migrate.c                            |    1 
 mm/page_ext.c                           |    1 
 mm/page_idle.c                          |  232 ++++++++++++++++++++++
 mm/rmap.c                               |    1 
 mm/swap.c                               |    1 
 14 files changed, 373 insertions(+), 128 deletions(-)

diff -puN Documentation/vm/idle_page_tracking.txt~proc-add-kpageidle-file-fix-6 Documentation/vm/idle_page_tracking.txt
--- a/Documentation/vm/idle_page_tracking.txt~proc-add-kpageidle-file-fix-6
+++ a/Documentation/vm/idle_page_tracking.txt
@@ -6,10 +6,12 @@ estimating the workload's working set si
 account when configuring the workload parameters, setting memory cgroup limits,
 or deciding where to place the workload within a compute cluster.
 
+It is enabled by CONFIG_IDLE_PAGE_TRACKING=y.
+
 USER API
 
-If CONFIG_IDLE_PAGE_TRACKING was enabled on compile time, a new read-write file
-is present on the proc filesystem, /proc/kpageidle.
+The idle page tracking API is located at /sys/kernel/mm/page_idle. Currently,
+it consists of the only read-write file, /sys/kernel/mm/page_idle/bitmap.
 
 The file implements a bitmap where each bit corresponds to a memory page. The
 bitmap is represented by an array of 8-byte integers, and the page at PFN #i is
@@ -30,24 +32,25 @@ and hence such pages are never reported
 For huge pages the idle flag is set only on the head page, so one has to read
 /proc/kpageflags in order to correctly count idle huge pages.
 
-Reading from or writing to /proc/kpageidle will return -EINVAL if you are not
-starting the read/write on an 8-byte boundary, or if the size of the read/write
-is not a multiple of 8 bytes. Writing to this file beyond max PFN will return
--ENXIO.
+Reading from or writing to /sys/kernel/mm/page_idle/bitmap will return
+-EINVAL if you are not starting the read/write on an 8-byte boundary, or
+if the size of the read/write is not a multiple of 8 bytes. Writing to
+this file beyond max PFN will return -ENXIO.
 
 That said, in order to estimate the amount of pages that are not used by a
 workload one should:
 
- 1. Mark all the workload's pages as idle by setting corresponding bits in the
-    /proc/kpageidle bitmap. The pages can be found by reading /proc/pid/pagemap
-    if the workload is represented by a process, or by filtering out alien pages
-    using /proc/kpagecgroup in case the workload is placed in a memory cgroup.
+ 1. Mark all the workload's pages as idle by setting corresponding bits in
+    /sys/kernel/mm/page_idle/bitmap. The pages can be found by reading
+    /proc/pid/pagemap if the workload is represented by a process, or by
+    filtering out alien pages using /proc/kpagecgroup in case the workload is
+    placed in a memory cgroup.
 
  2. Wait until the workload accesses its working set.
 
- 3. Read /proc/kpageidle and count the number of bits set. If one wants to
-    ignore certain types of pages, e.g. mlocked pages since they are not
-    reclaimable, he or she can filter them out using /proc/kpageflags.
+ 3. Read /sys/kernel/mm/page_idle/bitmap and count the number of bits set. If
+    one wants to ignore certain types of pages, e.g. mlocked pages since they
+    are not reclaimable, he or she can filter them out using /proc/kpageflags.
 
 See Documentation/vm/pagemap.txt for more information about /proc/pid/pagemap,
 /proc/kpageflags, and /proc/kpagecgroup.
@@ -74,8 +77,9 @@ When a dirty page is written to swap or
 exceeding the dirty memory limit, it is not marked referenced.
 
 The idle memory tracking feature adds a new page flag, the Idle flag. This flag
-is set manually, by writing to /proc/kpageidle (see the USER API section), and
-cleared automatically whenever a page is referenced as defined above.
+is set manually, by writing to /sys/kernel/mm/page_idle/bitmap (see the USER API
+section), and cleared automatically whenever a page is referenced as defined
+above.
 
 When a page is marked idle, the Accessed bit must be cleared in all PTEs it is
 mapped to, otherwise we will not be able to detect accesses to the page coming
@@ -90,5 +94,5 @@ Since the idle memory tracking feature i
 it only works with pages that are on an LRU list, other pages are silently
 ignored. That means it will ignore a user memory page if it is isolated, but
 since there are usually not many of them, it should not affect the overall
-result noticeably. In order not to stall scanning of /proc/kpageidle, locked
-pages may be skipped too.
+result noticeably. In order not to stall scanning of the idle page bitmap,
+locked pages may be skipped too.
diff -puN Documentation/vm/pagemap.txt~proc-add-kpageidle-file-fix-6 Documentation/vm/pagemap.txt
--- a/Documentation/vm/pagemap.txt~proc-add-kpageidle-file-fix-6
+++ a/Documentation/vm/pagemap.txt
@@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of i
 userspace programs to examine the page tables and related information by
 reading files in /proc.
 
-There are five components to pagemap:
+There are four components to pagemap:
 
  * /proc/pid/pagemap.  This file lets a userspace process find out which
    physical frame each virtual page is mapped to.  It contains one 64-bit
@@ -75,9 +75,6 @@ There are five components to pagemap:
    memory cgroup each page is charged to, indexed by PFN. Only available when
    CONFIG_MEMCG is set.
 
- * /proc/kpageidle.  This file comprises API of the idle page tracking feature.
-   See Documentation/vm/idle_page_tracking.txt for more details.
-
 Short descriptions to the page flags:
 
  0. LOCKED
diff -puN fs/proc/page.c~proc-add-kpageidle-file-fix-6 fs/proc/page.c
--- a/fs/proc/page.c~proc-add-kpageidle-file-fix-6
+++ a/fs/proc/page.c
@@ -5,20 +5,18 @@
 #include <linux/ksm.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
-#include <linux/rmap.h>
-#include <linux/mmu_notifier.h>
 #include <linux/huge_mm.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/hugetlb.h>
 #include <linux/memcontrol.h>
+#include <linux/page_idle.h>
 #include <linux/kernel-page-flags.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
 #define KPMSIZE sizeof(u64)
 #define KPMMASK (KPMSIZE - 1)
-#define KPMBITS (KPMSIZE * BITS_PER_BYTE)
 
 /* /proc/kpagecount - an array exposing page counts
  *
@@ -500,10 +498,6 @@ static int __init proc_page_init(void)
 #ifdef CONFIG_MEMCG
 	proc_create("kpagecgroup", S_IRUSR, NULL, &proc_kpagecgroup_operations);
 #endif
-#ifdef CONFIG_IDLE_PAGE_TRACKING
-	proc_create("kpageidle", S_IRUSR | S_IWUSR, NULL,
-		    &proc_kpageidle_operations);
-#endif
 	return 0;
 }
 fs_initcall(proc_page_init);
diff -puN fs/proc/task_mmu.c~proc-add-kpageidle-file-fix-6 fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~proc-add-kpageidle-file-fix-6
+++ a/fs/proc/task_mmu.c
@@ -13,6 +13,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/page_idle.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
diff -puN include/linux/mm.h~proc-add-kpageidle-file-fix-6 include/linux/mm.h
--- a/include/linux/mm.h~proc-add-kpageidle-file-fix-6
+++ a/include/linux/mm.h
@@ -2191,103 +2191,5 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
-#ifdef CONFIG_IDLE_PAGE_TRACKING
-#ifdef CONFIG_64BIT
-static inline bool page_is_young(struct page *page)
-{
-	return PageYoung(page);
-}
-
-static inline void set_page_young(struct page *page)
-{
-	SetPageYoung(page);
-}
-
-static inline bool test_and_clear_page_young(struct page *page)
-{
-	return TestClearPageYoung(page);
-}
-
-static inline bool page_is_idle(struct page *page)
-{
-	return PageIdle(page);
-}
-
-static inline void set_page_idle(struct page *page)
-{
-	SetPageIdle(page);
-}
-
-static inline void clear_page_idle(struct page *page)
-{
-	ClearPageIdle(page);
-}
-#else /* !CONFIG_64BIT */
-/*
- * If there is not enough space to store Idle and Young bits in page flags, use
- * page ext flags instead.
- */
-extern struct page_ext_operations page_idle_ops;
-
-static inline bool page_is_young(struct page *page)
-{
-	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
-}
-
-static inline void set_page_young(struct page *page)
-{
-	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
-}
-
-static inline bool test_and_clear_page_young(struct page *page)
-{
-	return test_and_clear_bit(PAGE_EXT_YOUNG,
-				  &lookup_page_ext(page)->flags);
-}
-
-static inline bool page_is_idle(struct page *page)
-{
-	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
-}
-
-static inline void set_page_idle(struct page *page)
-{
-	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
-}
-
-static inline void clear_page_idle(struct page *page)
-{
-	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
-}
-#endif /* CONFIG_64BIT */
-#else /* !CONFIG_IDLE_PAGE_TRACKING */
-static inline bool page_is_young(struct page *page)
-{
-	return false;
-}
-
-static inline void set_page_young(struct page *page)
-{
-}
-
-static inline bool test_and_clear_page_young(struct page *page)
-{
-	return false;
-}
-
-static inline bool page_is_idle(struct page *page)
-{
-	return false;
-}
-
-static inline void set_page_idle(struct page *page)
-{
-}
-
-static inline void clear_page_idle(struct page *page)
-{
-}
-#endif /* CONFIG_IDLE_PAGE_TRACKING */
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff -puN /dev/null include/linux/page_idle.h
--- /dev/null
+++ a/include/linux/page_idle.h
@@ -0,0 +1,110 @@
+#ifndef _LINUX_MM_PAGE_IDLE_H
+#define _LINUX_MM_PAGE_IDLE_H
+
+#include <linux/bitops.h>
+#include <linux/page-flags.h>
+#include <linux/page_ext.h>
+
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+
+#ifdef CONFIG_64BIT
+static inline bool page_is_young(struct page *page)
+{
+	return PageYoung(page);
+}
+
+static inline void set_page_young(struct page *page)
+{
+	SetPageYoung(page);
+}
+
+static inline bool test_and_clear_page_young(struct page *page)
+{
+	return TestClearPageYoung(page);
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return PageIdle(page);
+}
+
+static inline void set_page_idle(struct page *page)
+{
+	SetPageIdle(page);
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+	ClearPageIdle(page);
+}
+#else /* !CONFIG_64BIT */
+/*
+ * If there is not enough space to store Idle and Young bits in page flags, use
+ * page ext flags instead.
+ */
+extern struct page_ext_operations page_idle_ops;
+
+static inline bool page_is_young(struct page *page)
+{
+	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
+}
+
+static inline void set_page_young(struct page *page)
+{
+	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
+}
+
+static inline bool test_and_clear_page_young(struct page *page)
+{
+	return test_and_clear_bit(PAGE_EXT_YOUNG,
+				  &lookup_page_ext(page)->flags);
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+
+static inline void set_page_idle(struct page *page)
+{
+	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+#endif /* CONFIG_64BIT */
+
+#else /* !CONFIG_IDLE_PAGE_TRACKING */
+
+static inline bool page_is_young(struct page *page)
+{
+	return false;
+}
+
+static inline void set_page_young(struct page *page)
+{
+}
+
+static inline bool test_and_clear_page_young(struct page *page)
+{
+	return false;
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return false;
+}
+
+static inline void set_page_idle(struct page *page)
+{
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+}
+
+#endif /* CONFIG_IDLE_PAGE_TRACKING */
+
+#endif /* _LINUX_MM_PAGE_IDLE_H */
diff -puN mm/Kconfig~proc-add-kpageidle-file-fix-6 mm/Kconfig
--- a/mm/Kconfig~proc-add-kpageidle-file-fix-6
+++ a/mm/Kconfig
@@ -657,8 +657,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 
 config IDLE_PAGE_TRACKING
 	bool "Enable idle page tracking"
-	depends on PROC_FS && MMU
-	select PROC_PAGE_MONITOR
+	depends on SYSFS
 	select PAGE_EXTENSION if !64BIT
 	help
 	  This feature allows to estimate the amount of user pages that have
diff -puN mm/Makefile~proc-add-kpageidle-file-fix-6 mm/Makefile
--- a/mm/Makefile~proc-add-kpageidle-file-fix-6
+++ a/mm/Makefile
@@ -79,3 +79,4 @@ obj-$(CONFIG_MEMORY_BALLOON) += balloon_
 obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
 obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
 obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
+obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
diff -puN mm/huge_memory.c~proc-add-kpageidle-file-fix-6 mm/huge_memory.c
--- a/mm/huge_memory.c~proc-add-kpageidle-file-fix-6
+++ a/mm/huge_memory.c
@@ -25,6 +25,7 @@
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/page_idle.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
diff -puN mm/migrate.c~proc-add-kpageidle-file-fix-6 mm/migrate.c
--- a/mm/migrate.c~proc-add-kpageidle-file-fix-6
+++ a/mm/migrate.c
@@ -37,6 +37,7 @@
 #include <linux/gfp.h>
 #include <linux/balloon_compaction.h>
 #include <linux/mmu_notifier.h>
+#include <linux/page_idle.h>
 
 #include <asm/tlbflush.h>
 
diff -puN mm/page_ext.c~proc-add-kpageidle-file-fix-6 mm/page_ext.c
--- a/mm/page_ext.c~proc-add-kpageidle-file-fix-6
+++ a/mm/page_ext.c
@@ -6,6 +6,7 @@
 #include <linux/vmalloc.h>
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
+#include <linux/page_idle.h>
 
 /*
  * struct page extension
diff -puN /dev/null mm/page_idle.c
--- /dev/null
+++ a/mm/page_idle.c
@@ -0,0 +1,232 @@
+#include <linux/init.h>
+#include <linux/bootmem.h>
+#include <linux/fs.h>
+#include <linux/sysfs.h>
+#include <linux/kobject.h>
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
+#include <linux/page_ext.h>
+#include <linux/page_idle.h>
+
+#define BITMAP_CHUNK_SIZE	sizeof(u64)
+#define BITMAP_CHUNK_BITS	(BITMAP_CHUNK_SIZE * BITS_PER_BYTE)
+
+/*
+ * Idle page tracking only considers user memory pages, for other types of
+ * pages the idle flag is always unset and an attempt to set it is silently
+ * ignored.
+ *
+ * We treat a page as a user memory page if it is on an LRU list, because it is
+ * always safe to pass such a page to rmap_walk(), which is essential for idle
+ * page tracking. With such an indicator of user pages we can skip isolated
+ * pages, but since there are not usually many of them, it will hardly affect
+ * the overall result.
+ *
+ * This function tries to get a user memory page by pfn as described above.
+ */
+static struct page *page_idle_get_page(unsigned long pfn)
+{
+	struct page *page;
+	struct zone *zone;
+
+	if (!pfn_valid(pfn))
+		return NULL;
+
+	page = pfn_to_page(pfn);
+	if (!page || !PageLRU(page) ||
+	    !get_page_unless_zero(page))
+		return NULL;
+
+	zone = page_zone(page);
+	spin_lock_irq(&zone->lru_lock);
+	if (unlikely(!PageLRU(page))) {
+		put_page(page);
+		page = NULL;
+	}
+	spin_unlock_irq(&zone->lru_lock);
+	return page;
+}
+
+static int page_idle_clear_pte_refs_one(struct page *page,
+					struct vm_area_struct *vma,
+					unsigned long addr, void *arg)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
+	pmd_t *pmd;
+	pte_t *pte;
+	bool referenced = false;
+
+	if (unlikely(PageTransHuge(page))) {
+		pmd = page_check_address_pmd(page, mm, addr,
+					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
+		if (pmd) {
+			referenced = pmdp_clear_young_notify(vma, addr, pmd);
+			spin_unlock(ptl);
+		}
+	} else {
+		pte = page_check_address(page, mm, addr, &ptl, 0);
+		if (pte) {
+			referenced = ptep_clear_young_notify(vma, addr, pte);
+			pte_unmap_unlock(pte, ptl);
+		}
+	}
+	if (referenced) {
+		clear_page_idle(page);
+		/*
+		 * We cleared the referenced bit in a mapping to this page. To
+		 * avoid interference with page reclaim, mark it young so that
+		 * page_referenced() will return > 0.
+		 */
+		set_page_young(page);
+	}
+	return SWAP_AGAIN;
+}
+
+static void page_idle_clear_pte_refs(struct page *page)
+{
+	/*
+	 * Since rwc.arg is unused, rwc is effectively immutable, so we
+	 * can make it static const to save some cycles and stack.
+	 */
+	static const struct rmap_walk_control rwc = {
+		.rmap_one = page_idle_clear_pte_refs_one,
+		.anon_lock = page_lock_anon_vma_read,
+	};
+	bool need_lock;
+
+	if (!page_mapped(page) ||
+	    !page_rmapping(page))
+		return;
+
+	need_lock = !PageAnon(page) || PageKsm(page);
+	if (need_lock && !trylock_page(page))
+		return;
+
+	rmap_walk(page, (struct rmap_walk_control *)&rwc);
+
+	if (need_lock)
+		unlock_page(page);
+}
+
+static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
+				     struct bin_attribute *attr, char *buf,
+				     loff_t pos, size_t count)
+{
+	u64 *out = (u64 *)buf;
+	struct page *page;
+	unsigned long pfn, end_pfn;
+	int bit;
+
+	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
+		return -EINVAL;
+
+	pfn = pos * BITS_PER_BYTE;
+	if (pfn >= max_pfn)
+		return 0;
+
+	end_pfn = pfn + count * BITS_PER_BYTE;
+	if (end_pfn > max_pfn)
+		end_pfn = ALIGN(max_pfn, BITMAP_CHUNK_BITS);
+
+	for (; pfn < end_pfn; pfn++) {
+		bit = pfn % BITMAP_CHUNK_BITS;
+		if (!bit)
+			*out = 0ULL;
+		page = page_idle_get_page(pfn);
+		if (page) {
+			if (page_is_idle(page)) {
+				/*
+				 * The page might have been referenced via a
+				 * pte, in which case it is not idle. Clear
+				 * refs and recheck.
+				 */
+				page_idle_clear_pte_refs(page);
+				if (page_is_idle(page))
+					*out |= 1ULL << bit;
+			}
+			put_page(page);
+		}
+		if (bit == BITMAP_CHUNK_BITS - 1)
+			out++;
+		cond_resched();
+	}
+	return (char *)out - buf;
+}
+
+static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
+				      struct bin_attribute *attr, char *buf,
+				      loff_t pos, size_t count)
+{
+	const u64 *in = (u64 *)buf;
+	struct page *page;
+	unsigned long pfn, end_pfn;
+	int bit;
+
+	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
+		return -EINVAL;
+
+	pfn = pos * BITS_PER_BYTE;
+	if (pfn >= max_pfn)
+		return -ENXIO;
+
+	end_pfn = pfn + count * BITS_PER_BYTE;
+	if (end_pfn > max_pfn)
+		end_pfn = ALIGN(max_pfn, BITMAP_CHUNK_BITS);
+
+	for (; pfn < end_pfn; pfn++) {
+		bit = pfn % BITMAP_CHUNK_BITS;
+		if ((*in >> bit) & 1) {
+			page = page_idle_get_page(pfn);
+			if (page) {
+				page_idle_clear_pte_refs(page);
+				set_page_idle(page);
+				put_page(page);
+			}
+		}
+		if (bit == BITMAP_CHUNK_BITS - 1)
+			in++;
+		cond_resched();
+	}
+	return (char *)in - buf;
+}
+
+static struct bin_attribute page_idle_bitmap_attr =
+		__BIN_ATTR(bitmap, S_IRUSR | S_IWUSR,
+			   page_idle_bitmap_read, page_idle_bitmap_write, 0);
+
+static struct bin_attribute *page_idle_bin_attrs[] = {
+	&page_idle_bitmap_attr,
+	NULL,
+};
+
+static struct attribute_group page_idle_attr_group = {
+	.bin_attrs = page_idle_bin_attrs,
+	.name = "page_idle",
+};
+
+#ifndef CONFIG_64BIT
+static bool need_page_idle(void)
+{
+	return true;
+}
+struct page_ext_operations page_idle_ops = {
+	.need = need_page_idle,
+};
+#endif
+
+static int __init page_idle_init(void)
+{
+	int err;
+
+	err = sysfs_create_group(mm_kobj, &page_idle_attr_group);
+	if (err) {
+		pr_err("page_idle: register sysfs failed\n");
+		return err;
+	}
+	return 0;
+}
+subsys_initcall(page_idle_init);
diff -puN mm/rmap.c~proc-add-kpageidle-file-fix-6 mm/rmap.c
--- a/mm/rmap.c~proc-add-kpageidle-file-fix-6
+++ a/mm/rmap.c
@@ -59,6 +59,7 @@
 #include <linux/migrate.h>
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
+#include <linux/page_idle.h>
 
 #include <asm/tlbflush.h>
 
diff -puN mm/swap.c~proc-add-kpageidle-file-fix-6 mm/swap.c
--- a/mm/swap.c~proc-add-kpageidle-file-fix-6
+++ a/mm/swap.c
@@ -32,6 +32,7 @@
 #include <linux/gfp.h>
 #include <linux/uio.h>
 #include <linux/hugetlb.h>
+#include <linux/page_idle.h>
 
 #include "internal.h"
 
_
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
