From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:37:46 +0200
Message-Id: <20060712143746.16998.62284.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 4/39] mm: pgrep: convert insertion
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Abstract the insertion of pages into the page cache.

API:

give a hint to the page replace algorithm as to the 
importance of the given page.

	void pgrep_hint_active(struct page *);

insert the given page in a per cpu pagevec

	void fastcall pgrep_add(struct page *);

flush either the current, the given or all CPU(s) pagevec.

	void pgrep_add_drain(void);
	void __pgrep_add_drain(unsigned int);
	int pgrep_add_drain_all(void);

functions to insert a pagevec worth of pages

	void __pagevec_pgrep_add(struct pagevec *);
	void pagevec_pgrep_add(struct pagevec *);


Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 fs/cifs/file.c                     |    5 -
 fs/exec.c                          |    4 -
 fs/mpage.c                         |    5 -
 fs/ntfs/file.c                     |    4 -
 fs/ramfs/file-nommu.c              |    2 
 fs/splice.c                        |    4 -
 include/linux/mm_page_replace.h    |   38 +++++++++++
 include/linux/mm_use_once_policy.h |   21 ++++++
 include/linux/pagevec.h            |    8 --
 include/linux/swap.h               |    4 -
 mm/filemap.c                       |    7 +-
 mm/memory.c                        |   14 ++--
 mm/mempolicy.c                     |    1 
 mm/migrate.c                       |   14 ----
 mm/mmap.c                          |    5 -
 mm/readahead.c                     |    9 +-
 mm/shmem.c                         |    2 
 mm/swap.c                          |  120 ++-----------------------------------
 mm/swap_state.c                    |    6 +
 mm/useonce.c                       |  108 +++++++++++++++++++++++++++++++++
 mm/vmscan.c                        |    5 -
 21 files changed, 224 insertions(+), 162 deletions(-)

Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:57.000000000 +0200
@@ -0,0 +1,21 @@
+#ifndef _LINUX_MM_USEONCE_POLICY_H
+#define _LINUX_MM_USEONCE_POLICY_H
+
+#ifdef __KERNEL__
+
+static inline void pgrep_hint_active(struct page *page)
+{
+	SetPageActive(page);
+}
+
+static inline void
+__pgrep_add(struct zone *zone, struct page *page)
+{
+	if (PageActive(page))
+		add_page_to_active_list(zone, page);
+	else
+		add_page_to_inactive_list(zone, page);
+}
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_MM_USEONCE_POLICY_H */
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:57.000000000 +0200
@@ -0,0 +1,38 @@
+#ifndef _LINUX_MM_PAGE_REPLACE_H
+#define _LINUX_MM_PAGE_REPLACE_H
+
+#ifdef __KERNEL__
+
+#include <linux/mmzone.h>
+#include <linux/mm.h>
+#include <linux/pagevec.h>
+#include <linux/mm_inline.h>
+
+/* void pgrep_hint_active(struct page *); */
+extern void fastcall pgrep_add(struct page *);
+/* void __pgrep_add(struct zone *, struct page *); */
+/* void pgrep_add_drain(void); */
+extern void __pgrep_add_drain(unsigned int);
+extern int pgrep_add_drain_all(void);
+extern void __pagevec_pgrep_add(struct pagevec *);
+
+#ifdef CONFIG_MM_POLICY_USEONCE
+#include <linux/mm_use_once_policy.h>
+#else
+#error no mm policy
+#endif
+
+static inline void pagevec_pgrep_add(struct pagevec *pvec)
+{
+	if (pagevec_count(pvec))
+		__pagevec_pgrep_add(pvec);
+}
+
+static inline void pgrep_add_drain(void)
+{
+	__pgrep_add_drain(get_cpu());
+	put_cpu();
+}
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_MM_PAGE_REPLACE_H */
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/filemap.c	2006-07-12 16:11:56.000000000 +0200
@@ -30,6 +30,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
+#include <linux/mm_page_replace.h>
 #include "filemap.h"
 #include "internal.h"
 
@@ -430,7 +431,7 @@ int add_to_page_cache_lru(struct page *p
 {
 	int ret = add_to_page_cache(page, mapping, offset, gfp_mask);
 	if (ret == 0)
-		lru_cache_add(page);
+		pgrep_add(page);
 	return ret;
 }
 
@@ -1784,7 +1785,7 @@ repeat:
 			page = *cached_page;
 			page_cache_get(page);
 			if (!pagevec_add(lru_pvec, page))
-				__pagevec_lru_add(lru_pvec);
+				__pagevec_pgrep_add(lru_pvec);
 			*cached_page = NULL;
 		}
 	}
@@ -2114,7 +2115,7 @@ generic_file_buffered_write(struct kiocb
 	if (unlikely(file->f_flags & O_DIRECT) && written)
 		status = filemap_write_and_wait(mapping);
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_pgrep_add(&lru_pvec);
 	return written ? written : status;
 }
 EXPORT_SYMBOL(generic_file_buffered_write);
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:55.000000000 +0200
@@ -1,3 +1,111 @@
+#include <linux/mm_page_replace.h>
+#include <linux/mm_inline.h>
+#include <linux/swap.h>
+#include <linux/module.h>
+#include <linux/pagemap.h>
 
+/**
+ * lru_cache_add: add a page to the page lists
+ * @page: the page to add
+ */
+static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
 
+/*
+ * Add the passed pages to the LRU, then drop the caller's refcount
+ * on them.  Reinitialises the caller's pagevec.
+ */
+void __pagevec_pgrep_add(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
 
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		add_page_to_inactive_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+EXPORT_SYMBOL(__pagevec_pgrep_add);
+
+static void __pagevec_lru_add_active(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		BUG_ON(PageActive(page));
+		SetPageActive(page);
+		add_page_to_active_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+static inline void lru_cache_add(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_pgrep_add(pvec);
+	put_cpu_var(lru_add_pvecs);
+}
+
+static inline void lru_cache_add_active(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_active(pvec);
+	put_cpu_var(lru_add_active_pvecs);
+}
+
+void fastcall pgrep_add(struct page *page)
+{
+	if (PageActive(page)) {
+		ClearPageActive(page);
+		lru_cache_add_active(page);
+	} else {
+		lru_cache_add(page);
+	}
+}
+
+void __pgrep_add_drain(unsigned int cpu)
+{
+	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
+
+	if (pagevec_count(pvec))
+		__pagevec_pgrep_add(pvec);
+	pvec = &per_cpu(lru_add_active_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_active(pvec);
+}
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/memory.c	2006-07-12 16:11:36.000000000 +0200
@@ -48,6 +48,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -870,7 +871,7 @@ unsigned long zap_page_range(struct vm_a
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
+	pgrep_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
@@ -1505,7 +1506,8 @@ gotten:
 		ptep_establish(vma, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lazy_mmu_prot_update(entry);
-		lru_cache_add_active(new_page);
+		pgrep_hint_active(new_page);
+		pgrep_add(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -1857,7 +1859,7 @@ void swapin_readahead(swp_entry_t entry,
 		}
 #endif
 	}
-	lru_add_drain();	/* Push any new pages onto the LRU now */
+	pgrep_add_drain();	/* Push any new pages onto the LRU now */
 }
 
 /*
@@ -1991,7 +1993,8 @@ static int do_anonymous_page(struct mm_s
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
+		pgrep_hint_active(page);
+		pgrep_add(page);
 		page_add_new_anon_rmap(page, vma, address);
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
@@ -2122,7 +2125,8 @@ retry:
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
-			lru_cache_add_active(new_page);
+			pgrep_hint_active(new_page);
+			pgrep_add(new_page);
 			page_add_new_anon_rmap(new_page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/mmap.c	2006-07-12 16:08:18.000000000 +0200
@@ -25,6 +25,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1662,7 +1663,7 @@ static void unmap_region(struct mm_struc
 	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
+	pgrep_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
@@ -1942,7 +1943,7 @@ void exit_mmap(struct mm_struct *mm)
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
-	lru_add_drain();
+	pgrep_add_drain();
 	flush_cache_mm(mm);
 	tlb = tlb_gather_mmu(mm, 1);
 	/* Don't update_hiwater_rss(mm) here, do_exit already did */
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/shmem.c	2006-07-12 16:08:18.000000000 +0200
@@ -954,7 +954,7 @@ struct page *shmem_swapin(struct shmem_i
 			break;
 		page_cache_release(page);
 	}
-	lru_add_drain();	/* Push any new pages onto the LRU now */
+	pgrep_add_drain();	/* Push any new pages onto the LRU now */
 	return shmem_swapin_async(p, entry, idx);
 }
 
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/swap.c	2006-07-12 16:11:55.000000000 +0200
@@ -30,6 +30,7 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/init.h>
+#include <linux/mm_page_replace.h>
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
@@ -132,63 +133,18 @@ void fastcall mark_page_accessed(struct 
 
 EXPORT_SYMBOL(mark_page_accessed);
 
-/**
- * lru_cache_add: add a page to the page lists
- * @page: the page to add
- */
-static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
-static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
-
-void fastcall lru_cache_add(struct page *page)
-{
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
-
-	page_cache_get(page);
-	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add(pvec);
-	put_cpu_var(lru_add_pvecs);
-}
-
-void fastcall lru_cache_add_active(struct page *page)
-{
-	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
-
-	page_cache_get(page);
-	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add_active(pvec);
-	put_cpu_var(lru_add_active_pvecs);
-}
-
-static void __lru_add_drain(int cpu)
-{
-	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
-
-	/* CPU is dead, so no locking needed. */
-	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
-	pvec = &per_cpu(lru_add_active_pvecs, cpu);
-	if (pagevec_count(pvec))
-		__pagevec_lru_add_active(pvec);
-}
-
-void lru_add_drain(void)
-{
-	__lru_add_drain(get_cpu());
-	put_cpu();
-}
-
 #ifdef CONFIG_NUMA
-static void lru_add_drain_per_cpu(void *dummy)
+static void drain_per_cpu(void *dummy)
 {
-	lru_add_drain();
+	pgrep_add_drain();
 }
 
 /*
  * Returns 0 for success
  */
-int lru_add_drain_all(void)
+int pgrep_add_drain_all(void)
 {
-	return schedule_on_each_cpu(lru_add_drain_per_cpu, NULL);
+	return schedule_on_each_cpu(drain_per_cpu, NULL);
 }
 
 #else
@@ -196,9 +152,9 @@ int lru_add_drain_all(void)
 /*
  * Returns 0 for success
  */
-int lru_add_drain_all(void)
+int pgrep_add_drain_all(void)
 {
-	lru_add_drain();
+	pgrep_add_drain();
 	return 0;
 }
 #endif
@@ -297,7 +253,7 @@ void release_pages(struct page **pages, 
  */
 void __pagevec_release(struct pagevec *pvec)
 {
-	lru_add_drain();
+	pgrep_add_drain();
 	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
 	pagevec_reinit(pvec);
 }
@@ -327,64 +283,6 @@ void __pagevec_release_nonlru(struct pag
 }
 
 /*
- * Add the passed pages to the LRU, then drop the caller's refcount
- * on them.  Reinitialises the caller's pagevec.
- */
-void __pagevec_lru_add(struct pagevec *pvec)
-{
-	int i;
-	struct zone *zone = NULL;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		add_page_to_inactive_list(zone, page);
-	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
-}
-
-EXPORT_SYMBOL(__pagevec_lru_add);
-
-void __pagevec_lru_add_active(struct pagevec *pvec)
-{
-	int i;
-	struct zone *zone = NULL;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		BUG_ON(PageActive(page));
-		SetPageActive(page);
-		add_page_to_active_list(zone, page);
-	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
-}
-
-/*
  * Try to drop buffers from the pages in a pagevec
  */
 void pagevec_strip(struct pagevec *pvec)
@@ -473,7 +371,7 @@ static int cpu_swap_callback(struct noti
 	if (action == CPU_DEAD) {
 		atomic_add(*committed, &vm_committed_space);
 		*committed = 0;
-		__lru_add_drain((long)hcpu);
+		__pgrep_add_drain((long)hcpu);
 	}
 	return NOTIFY_OK;
 }
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/swap_state.c	2006-07-12 16:08:18.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/pgtable.h>
 
@@ -276,7 +277,7 @@ void free_pages_and_swap_cache(struct pa
 {
 	struct page **pagep = pages;
 
-	lru_add_drain();
+	pgrep_add_drain();
 	while (nr) {
 		int todo = min(nr, PAGEVEC_SIZE);
 		int i;
@@ -354,7 +355,8 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active(new_page);
+			pgrep_hint_active(new_page);
+			pgrep_add(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:54.000000000 +0200
@@ -34,6 +34,7 @@
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
 #include <linux/delay.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -630,7 +631,7 @@ static unsigned long shrink_inactive_lis
 
 	pagevec_init(&pvec, 1);
 
-	lru_add_drain();
+	pgrep_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	do {
 		struct page *page;
@@ -757,7 +758,7 @@ static void shrink_active_list(unsigned 
 			reclaim_mapped = 1;
 	}
 
-	lru_add_drain();
+	pgrep_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
 				    &l_hold, &pgscanned);
Index: linux-2.6/fs/cifs/file.c
===================================================================
--- linux-2.6.orig/fs/cifs/file.c	2006-07-12 16:07:24.000000000 +0200
+++ linux-2.6/fs/cifs/file.c	2006-07-12 16:08:18.000000000 +0200
@@ -30,6 +30,7 @@
 #include <linux/smp_lock.h>
 #include <linux/writeback.h>
 #include <linux/delay.h>
+#include <linux/mm_page_replace.h>
 #include <asm/div64.h>
 #include "cifsfs.h"
 #include "cifspdu.h"
@@ -1654,7 +1655,7 @@ static void cifs_copy_cache_pages(struct
 		SetPageUptodate(page);
 		unlock_page(page);
 		if (!pagevec_add(plru_pvec, page))
-			__pagevec_lru_add(plru_pvec);
+			__pagevec_pgrep_add(plru_pvec);
 		data += PAGE_CACHE_SIZE;
 	}
 	return;
@@ -1808,7 +1809,7 @@ static int cifs_readpages(struct file *f
 		bytes_read = 0;
 	}
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_pgrep_add(&lru_pvec);
 
 /* need to free smb_read_data buf before exit */
 	if (smb_read_data) {
Index: linux-2.6/fs/mpage.c
===================================================================
--- linux-2.6.orig/fs/mpage.c	2006-07-12 16:07:25.000000000 +0200
+++ linux-2.6/fs/mpage.c	2006-07-12 16:08:18.000000000 +0200
@@ -26,6 +26,7 @@
 #include <linux/writeback.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
+#include <linux/mm_page_replace.h>
 
 /*
  * I/O completion handler for multipage BIOs.
@@ -408,12 +409,12 @@ mpage_readpages(struct address_space *ma
 					&first_logical_block,
 					get_block);
 			if (!pagevec_add(&lru_pvec, page))
-				__pagevec_lru_add(&lru_pvec);
+				__pagevec_pgrep_add(&lru_pvec);
 		} else {
 			page_cache_release(page);
 		}
 	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_pgrep_add(&lru_pvec);
 	BUG_ON(!list_empty(pages));
 	if (bio)
 		mpage_bio_submit(READ, bio);
Index: linux-2.6/fs/ntfs/file.c
===================================================================
--- linux-2.6.orig/fs/ntfs/file.c	2006-07-12 16:07:25.000000000 +0200
+++ linux-2.6/fs/ntfs/file.c	2006-07-12 16:08:18.000000000 +0200
@@ -441,7 +441,7 @@ static inline int __ntfs_grab_cache_page
 			pages[nr] = *cached_page;
 			page_cache_get(*cached_page);
 			if (unlikely(!pagevec_add(lru_pvec, *cached_page)))
-				__pagevec_lru_add(lru_pvec);
+				__pagevec_pgrep_add(lru_pvec);
 			*cached_page = NULL;
 		}
 		index++;
@@ -2111,7 +2111,7 @@ err_out:
 						OSYNC_METADATA|OSYNC_DATA);
 		}
   	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_pgrep_add(&lru_pvec);
 	ntfs_debug("Done.  Returning %s (written 0x%lx, status %li).",
 			written ? "written" : "status", (unsigned long)written,
 			(long)status);
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/readahead.c	2006-07-12 16:08:18.000000000 +0200
@@ -14,6 +14,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
+#include <linux/mm_page_replace.h>
 
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page)
 {
@@ -146,7 +147,7 @@ int read_cache_pages(struct address_spac
 		}
 		ret = filler(data, page);
 		if (!pagevec_add(&lru_pvec, page))
-			__pagevec_lru_add(&lru_pvec);
+			__pagevec_pgrep_add(&lru_pvec);
 		if (ret) {
 			while (!list_empty(pages)) {
 				struct page *victim;
@@ -158,7 +159,7 @@ int read_cache_pages(struct address_spac
 			break;
 		}
 	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_pgrep_add(&lru_pvec);
 	return ret;
 }
 
@@ -185,13 +186,13 @@ static int read_pages(struct address_spa
 			ret = mapping->a_ops->readpage(filp, page);
 			if (ret != AOP_TRUNCATED_PAGE) {
 				if (!pagevec_add(&lru_pvec, page))
-					__pagevec_lru_add(&lru_pvec);
+					__pagevec_pgrep_add(&lru_pvec);
 				continue;
 			} /* else fall through to release */
 		}
 		page_cache_release(page);
 	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_pgrep_add(&lru_pvec);
 	ret = 0;
 out:
 	return ret;
Index: linux-2.6/fs/exec.c
===================================================================
--- linux-2.6.orig/fs/exec.c	2006-07-12 16:07:24.000000000 +0200
+++ linux-2.6/fs/exec.c	2006-07-12 16:08:18.000000000 +0200
@@ -49,6 +49,7 @@
 #include <linux/rmap.h>
 #include <linux/acct.h>
 #include <linux/cn_proc.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -321,7 +322,8 @@ void install_arg_page(struct vm_area_str
 		goto out;
 	}
 	inc_mm_counter(mm, anon_rss);
-	lru_cache_add_active(page);
+	pgrep_hint_active(page);
+	pgrep_add(page);
 	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
 	page_add_new_anon_rmap(page, vma, address);
Index: linux-2.6/include/linux/pagevec.h
===================================================================
--- linux-2.6.orig/include/linux/pagevec.h	2006-06-12 06:51:15.000000000 +0200
+++ linux-2.6/include/linux/pagevec.h	2006-07-12 16:08:18.000000000 +0200
@@ -23,8 +23,6 @@ struct pagevec {
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_release_nonlru(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
-void __pagevec_lru_add(struct pagevec *pvec);
-void __pagevec_lru_add_active(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
@@ -81,10 +79,4 @@ static inline void pagevec_free(struct p
 		__pagevec_free(pvec);
 }
 
-static inline void pagevec_lru_add(struct pagevec *pvec)
-{
-	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
-}
-
 #endif /* _LINUX_PAGEVEC_H */
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/swap.h	2006-07-12 16:11:49.000000000 +0200
@@ -163,13 +163,11 @@ extern unsigned int nr_free_buffer_pages
 extern unsigned int nr_free_pagecache_pages(void);
 
 /* linux/mm/swap.c */
-extern void FASTCALL(lru_cache_add(struct page *));
-extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
-extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern int rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
+extern void release_pages(struct page **, int, int);
 
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zone **, gfp_t);
Index: linux-2.6/fs/ramfs/file-nommu.c
===================================================================
--- linux-2.6.orig/fs/ramfs/file-nommu.c	2006-07-12 16:07:25.000000000 +0200
+++ linux-2.6/fs/ramfs/file-nommu.c	2006-07-12 16:08:18.000000000 +0200
@@ -108,7 +108,7 @@ static int ramfs_nommu_expand_for_mappin
 			goto add_error;
 
 		if (!pagevec_add(&lru_pvec, page))
-			__pagevec_lru_add(&lru_pvec);
+			__pagevec_pgrep_add(&lru_pvec);
 
 		unlock_page(page);
 	}
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/mempolicy.c	2006-07-12 16:11:46.000000000 +0200
@@ -87,6 +87,7 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/migrate.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2006-07-12 16:07:25.000000000 +0200
+++ linux-2.6/fs/splice.c	2006-07-12 16:08:18.000000000 +0200
@@ -21,13 +21,13 @@
 #include <linux/file.h>
 #include <linux/pagemap.h>
 #include <linux/pipe_fs_i.h>
-#include <linux/mm_inline.h>
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/buffer_head.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
 #include <linux/uio.h>
+#include <linux/mm_page_replace.h>
 
 struct partial_page {
 	unsigned int offset;
@@ -587,7 +587,7 @@ static int pipe_to_file(struct pipe_inod
 		page_cache_get(page);
 
 		if (!(buf->flags & PIPE_BUF_FLAG_LRU))
-			lru_cache_add(page);
+			pgrep_add(page);
 	} else {
 find_page:
 		page = find_lock_page(mapping, index);
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/migrate.c	2006-07-12 16:11:46.000000000 +0200
@@ -24,6 +24,7 @@
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
 #include <linux/swapops.h>
+#include <linux/mm_page_replace.h>
 
 #include "internal.h"
 
@@ -80,7 +81,7 @@ int migrate_prep(void)
 	 * drained them. Those pages will fail to migrate like other
 	 * pages that may be busy.
 	 */
-	lru_add_drain_all();
+	pgrep_add_drain();
 
 	return 0;
 }
@@ -88,16 +89,7 @@ int migrate_prep(void)
 static inline void move_to_lru(struct page *page)
 {
 	list_del(&page->lru);
-	if (PageActive(page)) {
-		/*
-		 * lru_cache_add_active checks that
-		 * the PG_active bit is off.
-		 */
-		ClearPageActive(page);
-		lru_cache_add_active(page);
-	} else {
-		lru_cache_add(page);
-	}
+	pgrep_add(page);
 	put_page(page);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
