Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5BFB96B007B
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 22:57:44 -0400 (EDT)
Subject: [RFC]vmscan: doing page_referenced() in batch way
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 Sep 2010 10:57:33 +0800
Message-ID: <1285729053.27440.13.camel@sli10-conroe.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: riel@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, hughd@google.com
List-ID: <linux-mm.kvack.org>

when memory pressure is high, page_referenced() causes a lot of lock contention
for anon_vma->lock or mapping->i_mmap_lock. Considering pages from one file
usually live side by side in LRU list, we can lock several pages in
shrink_page_list() and do batch page_referenced() to avoid some lock/unlock,
which should reduce lock contention a lot. The locking rule documented in
rmap.c is:
page_lock
	mapping->i_mmap_lock
		anon_vma->lock
For a batch of pages, we do page lock for all of them first and check their
reference, and then release their i_mmap_lock or anon_vma lock. This seems not
break the rule to me.
Before I further polish the patch, I'd like to know if there is anything
preventing us to do such batch here.

Thanks,
Shaohua

---
 include/linux/rmap.h |    7 ++--
 mm/internal.h        |   11 ++++++
 mm/memory-failure.c  |    2 -
 mm/rmap.c            |   60 ++++++++++++++++++++++++++++------
 mm/vmscan.c          |   88 ++++++++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 147 insertions(+), 21 deletions(-)

Index: linux/include/linux/rmap.h
===================================================================
--- linux.orig/include/linux/rmap.h	2010-09-29 09:13:04.000000000 +0800
+++ linux/include/linux/rmap.h	2010-09-29 10:29:54.000000000 +0800
@@ -181,8 +181,10 @@ static inline void page_dup_rmap(struct 
 /*
  * Called from mm/vmscan.c to handle paging out
  */
+struct page_reference_control;
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *cnt, unsigned long *vm_flags);
+			struct mem_cgroup *cnt, unsigned long *vm_flags,
+			struct page_reference_control *prc);
 int page_referenced_one(struct page *, struct vm_area_struct *,
 	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
 
@@ -230,7 +232,8 @@ int try_to_munlock(struct page *);
 /*
  * Called by memory-failure.c to kill processes.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page);
+struct anon_vma *page_lock_anon_vma(struct page *page,
+	struct page_reference_control *prc);
 void page_unlock_anon_vma(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h	2010-09-29 09:13:05.000000000 +0800
+++ linux/mm/internal.h	2010-09-29 10:29:54.000000000 +0800
@@ -249,6 +249,17 @@ int __get_user_pages(struct task_struct 
 #define ZONE_RECLAIM_FULL	-1
 #define ZONE_RECLAIM_SOME	0
 #define ZONE_RECLAIM_SUCCESS	1
+
+#define PRC_PAGE_NUM 8
+struct page_reference_control {
+	int num;
+	struct page *pages[PRC_PAGE_NUM];
+	int references[PRC_PAGE_NUM];
+	struct anon_vma *anon_vma;
+	struct address_space *mapping;
+	/* no ksm */
+};
+
 #endif
 
 extern int hwpoison_filter(struct page *p);
Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c	2010-09-29 09:13:05.000000000 +0800
+++ linux/mm/rmap.c	2010-09-29 10:30:09.000000000 +0800
@@ -314,7 +314,8 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma(struct page *page,
+	struct page_reference_control *prc)
 {
 	struct anon_vma *anon_vma, *root_anon_vma;
 	unsigned long anon_mapping;
@@ -328,6 +329,22 @@ struct anon_vma *page_lock_anon_vma(stru
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	root_anon_vma = ACCESS_ONCE(anon_vma->root);
+
+	if (prc) {
+		if (root_anon_vma == prc->anon_vma) {
+			rcu_read_unlock();
+			return root_anon_vma;
+		}
+		if (prc->anon_vma) {
+			page_unlock_anon_vma(prc->anon_vma);
+			prc->anon_vma = NULL;
+		}
+		if (prc->mapping) {
+			spin_unlock(&prc->mapping->i_mmap_lock);
+			prc->mapping = NULL;
+		}
+		prc->anon_vma = root_anon_vma;
+	}
 	spin_lock(&root_anon_vma->lock);
 
 	/*
@@ -530,14 +547,15 @@ out:
 
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags,
+				struct page_reference_control *prc)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
 	int referenced = 0;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, prc);
 	if (!anon_vma)
 		return referenced;
 
@@ -560,7 +578,8 @@ static int page_referenced_anon(struct p
 			break;
 	}
 
-	page_unlock_anon_vma(anon_vma);
+	if (!prc)
+		page_unlock_anon_vma(anon_vma);
 	return referenced;
 }
 
@@ -579,7 +598,8 @@ static int page_referenced_anon(struct p
  */
 static int page_referenced_file(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags,
+				struct page_reference_control *prc)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -603,8 +623,25 @@ static int page_referenced_file(struct p
 	 */
 	BUG_ON(!PageLocked(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	if (prc) {
+		if (mapping == prc->mapping) {
+			goto skip_lock;
+		}
+		if (prc->anon_vma) {
+			page_unlock_anon_vma(prc->anon_vma);
+			prc->anon_vma = NULL;
+		}
+		if (prc->mapping) {
+			spin_unlock(&prc->mapping->i_mmap_lock);
+			prc->mapping = NULL;
+		}
+		prc->mapping = mapping;
+
+		spin_lock(&mapping->i_mmap_lock);
+	} else
+		spin_lock(&mapping->i_mmap_lock);
 
+skip_lock:
 	/*
 	 * i_mmap_lock does not stabilize mapcount at all, but mapcount
 	 * is more likely to be accurate if we note it after spinning.
@@ -628,7 +665,8 @@ static int page_referenced_file(struct p
 			break;
 	}
 
-	spin_unlock(&mapping->i_mmap_lock);
+	if (!prc)
+		spin_unlock(&mapping->i_mmap_lock);
 	return referenced;
 }
 
@@ -645,7 +683,7 @@ static int page_referenced_file(struct p
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *mem_cont,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags, struct page_reference_control *prc)
 {
 	int referenced = 0;
 	int we_locked = 0;
@@ -664,10 +702,10 @@ int page_referenced(struct page *page,
 								vm_flags);
 		else if (PageAnon(page))
 			referenced += page_referenced_anon(page, mem_cont,
-								vm_flags);
+								vm_flags, prc);
 		else if (page->mapping)
 			referenced += page_referenced_file(page, mem_cont,
-								vm_flags);
+								vm_flags, prc);
 		if (we_locked)
 			unlock_page(page);
 	}
@@ -1239,7 +1277,7 @@ static int try_to_unmap_anon(struct page
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, NULL);
 	if (!anon_vma)
 		return ret;
 
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2010-09-29 10:29:48.000000000 +0800
+++ linux/mm/vmscan.c	2010-09-29 10:39:26.000000000 +0800
@@ -40,6 +40,7 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <linux/ksm.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -571,12 +572,12 @@ enum page_references {
 };
 
 static enum page_references page_check_references(struct page *page,
-						  struct scan_control *sc)
+	struct scan_control *sc, struct page_reference_control *prc)
 {
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
 
-	referenced_ptes = page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
+	referenced_ptes = page_referenced(page, 1, sc->mem_cgroup, &vm_flags, prc);
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
@@ -640,6 +641,44 @@ static noinline_for_stack void free_page
 	pagevec_free(&freed_pvec);
 }
 
+static void do_prc_batch(struct scan_control *sc,
+	struct page_reference_control *prc)
+{
+	int i;
+	for (i = 0; i < prc->num; i++)
+		prc->references[i] = page_check_references(prc->pages[i], sc,
+			prc);
+	/*
+	 * we must release all locks here, the lock ordering requries
+	 * pagelock->
+	 *   mapping->i_mmap_lock->
+	 *     anon_vma->lock
+	 * release lock guarantee we don't break the rule in next run
+	 */
+	if (prc->anon_vma) {
+		page_unlock_anon_vma(prc->anon_vma);
+		prc->anon_vma = NULL;
+	}
+	if (prc->mapping) {
+		spin_unlock(&prc->mapping->i_mmap_lock);
+		prc->mapping = NULL;
+	}
+}
+
+static int page_check_references_batch(struct page *page, struct scan_control *sc,
+	struct page_reference_control *prc)
+{
+	/* bypass ksm pages */
+	if (PageKsm(page))
+		return 1;
+	if (prc->num < PRC_PAGE_NUM)
+		prc->pages[prc->num] = page;
+	prc->num++;
+	if (prc->num == PRC_PAGE_NUM)
+		return 1;
+	return 0;
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -651,18 +690,36 @@ static unsigned long shrink_page_list(st
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
+	struct page_reference_control prc;
+	int do_batch_count = 0;
+
+	prc.num = 0;
+	prc.anon_vma = NULL;
+	prc.mapping = NULL;
 
 	cond_resched();
 
-	while (!list_empty(page_list)) {
+	while (!list_empty(page_list) || prc.num > 0) {
 		enum page_references references;
 		struct address_space *mapping;
-		struct page *page;
+		struct page *uninitialized_var(page);
 		int may_enter_fs;
 
 		cond_resched();
 
-		page = lru_to_page(page_list);
+		if (do_batch_count)
+			goto do_one_batch_page;
+
+		/* bypass ksm pages */
+		if (!list_empty(page_list)) {
+			page = lru_to_page(page_list);
+			if (PageKsm(page) && prc.num > 0)
+				goto do_batch_pages;
+		}
+
+		if (list_empty(page_list) && prc.num > 0)
+			goto do_batch_pages;
+
 		list_del(&page->lru);
 
 		if (!trylock_page(page))
@@ -700,7 +757,22 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 		}
 
-		references = page_check_references(page, sc);
+		if (!page_check_references_batch(page, sc, &prc))
+			continue;
+do_batch_pages:
+		do_prc_batch(sc, &prc);
+		do_batch_count = prc.num;
+do_one_batch_page:
+		/* be careful to not reorder the pages */
+		page = prc.pages[do_batch_count - prc.num];
+		references = prc.references[do_batch_count - prc.num];
+		prc.num--;
+		if (prc.num <= 0)
+			do_batch_count = 0;
+		/* The page might be changed, recheck */
+		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
+			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
+
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
@@ -857,6 +929,8 @@ keep:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
+	BUG_ON(prc.num > 0);
+
 	free_page_list(&free_pages);
 
 	list_splice(&ret_pages, page_list);
@@ -1465,7 +1539,7 @@ static void shrink_active_list(unsigned 
 			continue;
 		}
 
-		if (page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		if (page_referenced(page, 0, sc->mem_cgroup, &vm_flags, NULL)) {
 			nr_rotated++;
 			/*
 			 * Identify referenced, file-backed active pages and
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c	2010-09-29 09:13:05.000000000 +0800
+++ linux/mm/memory-failure.c	2010-09-29 10:29:54.000000000 +0800
@@ -382,7 +382,7 @@ static void collect_procs_anon(struct pa
 	struct anon_vma *av;
 
 	read_lock(&tasklist_lock);
-	av = page_lock_anon_vma(page);
+	av = page_lock_anon_vma(page, NULL);
 	if (av == NULL)	/* Not actually mapped anymore */
 		goto out;
 	for_each_process (tsk) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
