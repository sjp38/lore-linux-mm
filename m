Date: Wed, 4 Feb 2004 23:18:40 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] RSS limit enforcement for 2.6
Message-Id: <20040204231840.67cbb388.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0401271248580.23718-100000@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.44.0401271248580.23718-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: pavel@ucw.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> wrote:
>
>  the patch below (softly) enforces RLIMIT_RSS in the 2.6 kernel,

I fixed another problem in this.  page_referenced() was going into the
second leg of that big if() statement for pagecache and swapcache pages
which are not mapped into anyone's pagetables.  Due to the logic in there
we end up never setting *rsslimit again and we think all pagecache pages
are "rss over limit"


 mm/rmap.c |    4 ++++
 1 files changed, 4 insertions(+)

diff -puN mm/rmap.c~vm-rss-limit-fix-fix mm/rmap.c
--- 25/mm/rmap.c~vm-rss-limit-fix-fix	2004-02-04 23:01:30.000000000 -0800
+++ 25-akpm/mm/rmap.c	2004-02-04 23:01:46.000000000 -0800
@@ -130,6 +130,9 @@ int page_referenced(struct page *page, i
 	if (TestClearPageReferenced(page))
 		referenced++;
 
+	if (!page_mapped(page))
+		goto out;
+
 	if (PageDirect(page)) {
 		pte_t *pte = rmap_ptep_map(page->pte.direct);
 		if (ptep_test_and_clear_young(pte))
@@ -172,6 +175,7 @@ int page_referenced(struct page *page, i
 			__pte_chain_free(pc);
 		}
 	}
+out:
 	return referenced;
 }
 


With this patch, everything seems to be doing what it's supposed to do.

But it doesn't seem to be effective.  On a 256M box I started a process
which allocated 100M of anon memory and just went to sleep.  Then I set
`ulimit -m 4000' (4 megs) and ran 4-thread qsbench under that.  Debug code
told me that page_referenced() was returning non-zero *rsslimit.

But after 20 seconds of qsbenching I killed it and found that all of the
innocent 100M had been swapped out and reclaimed.

Note that there is still a problem in refill_inactive_zone():

		if (page_mapped(page)) {

			/*
			 * Don't clear page referenced if we're not going
			 * to use it.
			 */
			if (!reclaim_mapped && !over_rsslimit) {
				list_add(&page->lru, &l_ignore);
				continue;
			}

			/*
			 * probably it would be useful to transfer dirty bit
			 * from pte to the @page here.
			 */
			pte_chain_lock(page);
			if (page_mapped(page) &&
					page_referenced(page, &over_rsslimit) &&
					!over_rsslimit) {
				pte_chain_unlock(page);
				list_add(&page->lru, &l_active);
				continue;
			}
			pte_chain_unlock(page);
		}

That first test of over_rsslimit is kinda bogus: we haven't run
page_referenced() yet!  But the recent change of moving that little chunk
of code to before the page_referenced() check was correct.

So to get this right, we may need to split the over-limit stuff apart from
the page_referenced() processing.


Anyway, needs more work.  I'll drop the patch out.  Here's what I currently
have, against next -mm.



 fs/exec.c                 |    5 +++++
 include/linux/init_task.h |    2 ++
 include/linux/sched.h     |    1 +
 include/linux/swap.h      |    4 ++--
 kernel/sys.c              |    8 ++++++++
 mm/rmap.c                 |   24 +++++++++++++++++++++++-
 mm/vmscan.c               |   12 ++++++++----
 7 files changed, 49 insertions(+), 7 deletions(-)

diff -puN include/linux/init_task.h~vm-rss-limit-enforcement include/linux/init_task.h
--- 25/include/linux/init_task.h~vm-rss-limit-enforcement	2004-02-04 22:28:38.000000000 -0800
+++ 25-akpm/include/linux/init_task.h	2004-02-04 22:28:38.000000000 -0800
@@ -2,6 +2,7 @@
 #define _LINUX__INIT_TASK_H
 
 #include <linux/file.h>
+#include <linux/resource.h>
 
 #define INIT_FILES \
 { 							\
@@ -42,6 +43,7 @@
 	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
 	.cpu_vm_mask	= CPU_MASK_ALL,				\
 	.default_kioctx = INIT_KIOCTX(name.default_kioctx, name),	\
+	.rlimit_rss	= RLIM_INFINITY			\
 }
 
 #define INIT_SIGNALS(sig) {	\
diff -puN include/linux/sched.h~vm-rss-limit-enforcement include/linux/sched.h
--- 25/include/linux/sched.h~vm-rss-limit-enforcement	2004-02-04 22:28:38.000000000 -0800
+++ 25-akpm/include/linux/sched.h	2004-02-04 22:28:38.000000000 -0800
@@ -205,6 +205,7 @@ struct mm_struct {
 	unsigned long arg_start, arg_end, env_start, env_end;
 	unsigned long rss, total_vm, locked_vm;
 	unsigned long def_flags;
+	unsigned long rlimit_rss;
 
 	unsigned long saved_auxv[40]; /* for /proc/PID/auxv */
 
diff -puN include/linux/swap.h~vm-rss-limit-enforcement include/linux/swap.h
--- 25/include/linux/swap.h~vm-rss-limit-enforcement	2004-02-04 22:28:38.000000000 -0800
+++ 25-akpm/include/linux/swap.h	2004-02-04 22:28:38.000000000 -0800
@@ -179,7 +179,7 @@ extern int vm_swappiness;
 
 /* linux/mm/rmap.c */
 #ifdef CONFIG_MMU
-int FASTCALL(page_referenced(struct page *));
+int FASTCALL(page_referenced(struct page *, int *));
 struct pte_chain *FASTCALL(page_add_rmap(struct page *, pte_t *,
 					struct pte_chain *));
 void FASTCALL(page_remove_rmap(struct page *, pte_t *));
@@ -188,7 +188,7 @@ int FASTCALL(try_to_unmap(struct page *)
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 #else
-#define page_referenced(page)	TestClearPageReferenced(page)
+#define page_referenced(page, _x)	TestClearPageReferenced(page)
 #define try_to_unmap(page)	SWAP_FAIL
 #endif /* CONFIG_MMU */
 
diff -puN kernel/sys.c~vm-rss-limit-enforcement kernel/sys.c
--- 25/kernel/sys.c~vm-rss-limit-enforcement	2004-02-04 22:28:38.000000000 -0800
+++ 25-akpm/kernel/sys.c	2004-02-04 22:28:38.000000000 -0800
@@ -1306,6 +1306,14 @@ asmlinkage long sys_setrlimit(unsigned i
 	if (retval)
 		return retval;
 
+	/* The rlimit is specified in bytes, convert to pages for mm. */
+	if (resource == RLIMIT_RSS && current->mm) {
+		unsigned long pages = RLIM_INFINITY;
+		if (new_rlim.rlim_cur != RLIM_INFINITY)
+			pages = new_rlim.rlim_cur >> PAGE_SHIFT;
+		current->mm->rlimit_rss = pages;
+	}
+
 	*old_rlim = new_rlim;
 	return 0;
 }
diff -puN mm/rmap.c~vm-rss-limit-enforcement mm/rmap.c
--- 25/mm/rmap.c~vm-rss-limit-enforcement	2004-02-04 22:28:38.000000000 -0800
+++ 25-akpm/mm/rmap.c	2004-02-04 23:13:14.000000000 -0800
@@ -104,6 +104,7 @@ pte_chain_encode(struct pte_chain *pte_c
 /**
  * page_referenced - test if the page was referenced
  * @page: the page to test
+ * @rsslimit: set if the process(es) using the page is(are) over RSS limit.
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of processes which referenced the page.
@@ -111,26 +112,42 @@ pte_chain_encode(struct pte_chain *pte_c
  *
  * If the page has a single-entry pte_chain, collapse that back to a PageDirect
  * representation.  This way, it's only done under memory pressure.
+ *
+ * The pte_chain_lock() is sufficient to pin down mm_structs while we examine
+ * them.
  */
-int page_referenced(struct page * page)
+int page_referenced(struct page *page, int *rsslimit)
 {
+	struct mm_struct * mm;
 	struct pte_chain *pc;
 	int referenced = 0;
 
+	*rsslimit = 0;
+
 	if (page_test_and_clear_young(page))
 		mark_page_accessed(page);
 
 	if (TestClearPageReferenced(page))
 		referenced++;
 
+	if (!page_mapped(page))
+		goto out;
+
 	if (PageDirect(page)) {
 		pte_t *pte = rmap_ptep_map(page->pte.direct);
 		if (ptep_test_and_clear_young(pte))
 			referenced++;
+
+		mm = ptep_to_mm(pte);
+		if (mm->rss > mm->rlimit_rss)
+			*rsslimit = 1;
 		rmap_ptep_unmap(pte);
 	} else {
 		int nr_chains = 0;
 
+		/* We clear it if any task using the page is under its limit. */
+		*rsslimit = 1;
+
 		/* Check all the page tables mapping this page. */
 		for (pc = page->pte.chain; pc; pc = pte_chain_next(pc)) {
 			int i;
@@ -142,6 +159,10 @@ int page_referenced(struct page * page)
 				p = rmap_ptep_map(pte_paddr);
 				if (ptep_test_and_clear_young(p))
 					referenced++;
+
+				mm = ptep_to_mm(p);
+				if (mm->rss < mm->rlimit_rss)
+					*rsslimit = 0;
 				rmap_ptep_unmap(p);
 				nr_chains++;
 			}
@@ -154,6 +175,7 @@ int page_referenced(struct page * page)
 			__pte_chain_free(pc);
 		}
 	}
+out:
 	return referenced;
 }
 
diff -puN mm/vmscan.c~vm-rss-limit-enforcement mm/vmscan.c
--- 25/mm/vmscan.c~vm-rss-limit-enforcement	2004-02-04 22:28:38.000000000 -0800
+++ 25-akpm/mm/vmscan.c	2004-02-04 22:28:38.000000000 -0800
@@ -249,6 +249,7 @@ shrink_list(struct list_head *page_list,
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
+	int over_rsslimit;
 	int ret = 0;
 
 	cond_resched();
@@ -275,8 +276,8 @@ shrink_list(struct list_head *page_list,
 			goto keep_locked;
 
 		pte_chain_lock(page);
-		referenced = page_referenced(page);
-		if (referenced && page_mapping_inuse(page)) {
+		referenced = page_referenced(page, &over_rsslimit);
+		if (referenced && page_mapping_inuse(page) && !over_rsslimit) {
 			/* In active use or really unfreeable.  Activate it. */
 			pte_chain_unlock(page);
 			goto activate_locked;
@@ -635,6 +636,7 @@ refill_inactive_zone(struct zone *zone, 
 	long mapped_ratio;
 	long distress;
 	long swap_tendency;
+	int over_rsslimit;
 
 	/*
 	 * `distress' is a measure of how much trouble we're having reclaiming
@@ -715,7 +717,7 @@ refill_inactive_zone(struct zone *zone, 
 			 * Don't clear page referenced if we're not going
 			 * to use it.
 			 */
-			if (!reclaim_mapped) {
+			if (!reclaim_mapped && !over_rsslimit) {
 				list_add(&page->lru, &l_ignore);
 				continue;
 			}
@@ -725,7 +727,9 @@ refill_inactive_zone(struct zone *zone, 
 			 * from pte to the @page here.
 			 */
 			pte_chain_lock(page);
-			if (page_mapped(page) && page_referenced(page)) {
+			if (page_mapped(page) &&
+					page_referenced(page, &over_rsslimit) &&
+					!over_rsslimit) {
 				pte_chain_unlock(page);
 				list_add(&page->lru, &l_active);
 				continue;
diff -puN fs/exec.c~vm-rss-limit-enforcement fs/exec.c
--- 25/fs/exec.c~vm-rss-limit-enforcement	2004-02-04 23:13:03.000000000 -0800
+++ 25-akpm/fs/exec.c	2004-02-04 23:13:03.000000000 -0800
@@ -1117,6 +1117,11 @@ int do_execve(char * filename,
 	retval = init_new_context(current, bprm.mm);
 	if (retval < 0)
 		goto out_mm;
+	if (likely(current->mm)) {
+		bprm.mm->rlimit_rss = current->mm->rlimit_rss;
+	} else {
+		bprm.mm->rlimit_rss = init_mm.rlimit_rss;
+	}
 
 	bprm.argc = count(argv, bprm.p / sizeof(void *));
 	if ((retval = bprm.argc) < 0)

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
