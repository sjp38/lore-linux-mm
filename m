Message-ID: <4020BDFF.3010201@cyberone.com.au>
Date: Wed, 04 Feb 2004 20:40:15 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [PATCH 1/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au>
In-Reply-To: <4020BDCB.8030707@cyberone.com.au>
Content-Type: multipart/mixed;
 boundary="------------090307020905070603060309"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090307020905070603060309
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



Nick Piggin wrote:

> 1/5: vm-no-rss-limit.patch
>     Remove broken RSS limiting. Simple problem, Rik is onto it.
>


--------------090307020905070603060309
Content-Type: text/plain;
 name="vm-no-rss-limit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-no-rss-limit.patch"

 linux-2.6-npiggin/include/linux/init_task.h |    2 --
 linux-2.6-npiggin/include/linux/sched.h     |    1 -
 linux-2.6-npiggin/include/linux/swap.h      |    4 ++--
 linux-2.6-npiggin/kernel/sys.c              |    8 --------
 linux-2.6-npiggin/mm/rmap.c                 |   18 +-----------------
 linux-2.6-npiggin/mm/vmscan.c               |   12 ++++--------
 6 files changed, 7 insertions(+), 38 deletions(-)

diff -puN include/linux/init_task.h~vm-no-rss-limit include/linux/init_task.h
--- linux-2.6/include/linux/init_task.h~vm-no-rss-limit	2004-02-04 14:09:43.000000000 +1100
+++ linux-2.6-npiggin/include/linux/init_task.h	2004-02-04 14:09:43.000000000 +1100
@@ -2,7 +2,6 @@
 #define _LINUX__INIT_TASK_H
 
 #include <linux/file.h>
-#include <linux/resource.h>
 
 #define INIT_FILES \
 { 							\
@@ -43,7 +42,6 @@
 	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
 	.cpu_vm_mask	= CPU_MASK_ALL,				\
 	.default_kioctx = INIT_KIOCTX(name.default_kioctx, name),	\
-	.rlimit_rss	= RLIM_INFINITY			\
 }
 
 #define INIT_SIGNALS(sig) {	\
diff -puN include/linux/sched.h~vm-no-rss-limit include/linux/sched.h
--- linux-2.6/include/linux/sched.h~vm-no-rss-limit	2004-02-04 14:09:43.000000000 +1100
+++ linux-2.6-npiggin/include/linux/sched.h	2004-02-04 14:09:43.000000000 +1100
@@ -206,7 +206,6 @@ struct mm_struct {
 	unsigned long arg_start, arg_end, env_start, env_end;
 	unsigned long rss, total_vm, locked_vm;
 	unsigned long def_flags;
-	unsigned long rlimit_rss;
 
 	unsigned long saved_auxv[40]; /* for /proc/PID/auxv */
 
diff -puN include/linux/swap.h~vm-no-rss-limit include/linux/swap.h
--- linux-2.6/include/linux/swap.h~vm-no-rss-limit	2004-02-04 14:09:43.000000000 +1100
+++ linux-2.6-npiggin/include/linux/swap.h	2004-02-04 14:09:43.000000000 +1100
@@ -179,7 +179,7 @@ extern int vm_swappiness;
 
 /* linux/mm/rmap.c */
 #ifdef CONFIG_MMU
-int FASTCALL(page_referenced(struct page *, int *));
+int FASTCALL(page_referenced(struct page *));
 struct pte_chain *FASTCALL(page_add_rmap(struct page *, pte_t *,
 					struct pte_chain *));
 void FASTCALL(page_remove_rmap(struct page *, pte_t *));
@@ -188,7 +188,7 @@ int FASTCALL(try_to_unmap(struct page *)
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 #else
-#define page_referenced(page, _x)	TestClearPageReferenced(page)
+#define page_referenced(page)	TestClearPageReferenced(page)
 #define try_to_unmap(page)	SWAP_FAIL
 #endif /* CONFIG_MMU */
 
diff -puN kernel/sys.c~vm-no-rss-limit kernel/sys.c
--- linux-2.6/kernel/sys.c~vm-no-rss-limit	2004-02-04 14:09:43.000000000 +1100
+++ linux-2.6-npiggin/kernel/sys.c	2004-02-04 14:09:43.000000000 +1100
@@ -1478,14 +1478,6 @@ asmlinkage long sys_setrlimit(unsigned i
 	if (retval)
 		return retval;
 
-	/* The rlimit is specified in bytes, convert to pages for mm. */
-	if (resource == RLIMIT_RSS && current->mm) {
-		unsigned long pages = RLIM_INFINITY;
-		if (new_rlim.rlim_cur != RLIM_INFINITY)
-			pages = new_rlim.rlim_cur >> PAGE_SHIFT;
-		current->mm->rlimit_rss = pages;
-	}
-
 	*old_rlim = new_rlim;
 	return 0;
 }
diff -puN mm/rmap.c~vm-no-rss-limit mm/rmap.c
--- linux-2.6/mm/rmap.c~vm-no-rss-limit	2004-02-04 14:09:43.000000000 +1100
+++ linux-2.6-npiggin/mm/rmap.c	2004-02-04 14:09:43.000000000 +1100
@@ -104,7 +104,6 @@ pte_chain_encode(struct pte_chain *pte_c
 /**
  * page_referenced - test if the page was referenced
  * @page: the page to test
- * @rsslimit: set if the process(es) using the page is(are) over RSS limit.
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of processes which referenced the page.
@@ -112,13 +111,9 @@ pte_chain_encode(struct pte_chain *pte_c
  *
  * If the page has a single-entry pte_chain, collapse that back to a PageDirect
  * representation.  This way, it's only done under memory pressure.
- *
- * The pte_chain_lock() is sufficient to pin down mm_structs while we examine
- * them.
  */
-int page_referenced(struct page *page, int *rsslimit)
+int page_referenced(struct page * page)
 {
-	struct mm_struct * mm;
 	struct pte_chain *pc;
 	int referenced = 0;
 
@@ -132,17 +127,10 @@ int page_referenced(struct page *page, i
 		pte_t *pte = rmap_ptep_map(page->pte.direct);
 		if (ptep_test_and_clear_young(pte))
 			referenced++;
-
-		mm = ptep_to_mm(pte);
-		if (mm->rss > mm->rlimit_rss)
-			*rsslimit = 1;
 		rmap_ptep_unmap(pte);
 	} else {
 		int nr_chains = 0;
 
-		/* We clear it if any task using the page is under its limit. */
-		*rsslimit = 1;
-
 		/* Check all the page tables mapping this page. */
 		for (pc = page->pte.chain; pc; pc = pte_chain_next(pc)) {
 			int i;
@@ -154,10 +142,6 @@ int page_referenced(struct page *page, i
 				p = rmap_ptep_map(pte_paddr);
 				if (ptep_test_and_clear_young(p))
 					referenced++;
-
-				mm = ptep_to_mm(p);
-				if (mm->rss < mm->rlimit_rss)
-					*rsslimit = 0;
 				rmap_ptep_unmap(p);
 				nr_chains++;
 			}
diff -puN mm/vmscan.c~vm-no-rss-limit mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-no-rss-limit	2004-02-04 14:09:43.000000000 +1100
+++ linux-2.6-npiggin/mm/vmscan.c	2004-02-04 14:09:43.000000000 +1100
@@ -252,7 +252,6 @@ shrink_list(struct list_head *page_list,
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
-	int over_rsslimit = 0;
 	int ret = 0;
 
 	cond_resched();
@@ -279,8 +278,8 @@ shrink_list(struct list_head *page_list,
 			goto keep_locked;
 
 		pte_chain_lock(page);
-		referenced = page_referenced(page, &over_rsslimit);
-		if (referenced && page_mapping_inuse(page) && !over_rsslimit) {
+		referenced = page_referenced(page);
+		if (referenced && page_mapping_inuse(page)) {
 			/* In active use or really unfreeable.  Activate it. */
 			pte_chain_unlock(page);
 			goto activate_locked;
@@ -601,7 +600,6 @@ refill_inactive_zone(struct zone *zone, 
 	long mapped_ratio;
 	long distress;
 	long swap_tendency;
-	int over_rsslimit = 0;
 
 	lru_add_drain();
 	pgmoved = 0;
@@ -662,15 +660,13 @@ refill_inactive_zone(struct zone *zone, 
 		list_del(&page->lru);
 		if (page_mapped(page)) {
 			pte_chain_lock(page);
-			if (page_mapped(page) &&
-					page_referenced(page, &over_rsslimit) &&
-					!over_rsslimit) {
+			if (page_mapped(page) && page_referenced(page)) {
 				pte_chain_unlock(page);
 				list_add(&page->lru, &l_active);
 				continue;
 			}
 			pte_chain_unlock(page);
-			if (!reclaim_mapped && !over_rsslimit) {
+			if (!reclaim_mapped) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}

_

--------------090307020905070603060309--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
