Date: Fri, 28 Jan 2000 15:59:45 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [PATCH] boobytrap 2 for 2.2.15pre5
In-Reply-To: <Pine.LNX.4.10.10001281553250.25452-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.10.10001281558130.25452-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tony Gale <gale@syntax.dera.gov.uk>
Cc: Linux MM <linux-mm@kvack.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Tony, Alan,

as it turns out there is the SLAB_ATOMIC flag which can be
used to call the slab cache in a legal way if the task isn't
in TASK_RUNNING.
 
The attached boobytrap2 patch adds checks for that situation
and won't barf when something like that happens. This should
reduce the number of false positives and the number of error
messages (making it more convinient for people to test the patches).

regards,
 
Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.


--- linux-2.2.15pre5/mm/vmscan.c.orig	Fri Jan 28 00:13:18 2000
+++ linux-2.2.15pre5/mm/vmscan.c	Fri Jan 28 01:46:02 2000
@@ -497,8 +497,11 @@
 		{
 			if (!do_try_to_free_pages(GFP_KSWAPD))
 				break;
-			if (tsk->need_resched)
+			if (tsk->need_resched) {
+				if (nr_free_pages > freepages.low)
+					break;
 				schedule();
+			}
 		}
 		run_task_queue(&tq_disk);
 		interruptible_sleep_on_timeout(&kswapd_wait, HZ);
--- linux-2.2.15pre5/mm/memory.c.orig	Fri Jan 28 00:16:30 2000
+++ linux-2.2.15pre5/mm/memory.c	Fri Jan 28 01:45:40 2000
@@ -611,6 +611,12 @@
 	pte_t pte;
 	unsigned long old_page, new_page;
 	struct page * page_map;
+
+	/* booby trap */
+	if (current->state != TASK_RUNNING) {
+		printk("do_wp_page called by non-running (%d) task from %p!\n",
+			current->state, __builtin_return_address(0));
+	}
 	
 	pte = *page_table;
 	new_page = __get_free_page(GFP_USER);
@@ -806,6 +812,13 @@
 static int do_anonymous_page(struct task_struct * tsk, struct vm_area_struct * vma, pte_t *page_table, int write_access, unsigned long addr)
 {
 	pte_t entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
+
+	/* booby trap */
+	if (current->state != TASK_RUNNING) {
+		printk("do_anonymous_page called by non-running (%d) task from %p!\n",
+			current->state, __builtin_return_address(0));
+	}
+	
 	if (write_access) {
 		unsigned long page = __get_free_page(GFP_USER);
 		if (!page)
@@ -932,6 +945,12 @@
 	pte_t * pte;
 	int ret;
 
+	/* booby trap */
+	if (current->state != TASK_RUNNING) {
+		printk("handle_mm_fault called by non-running (%d) task from %p!\n",
+			current->state, __builtin_return_address(0));
+	}
+	
 	pgd = pgd_offset(vma->vm_mm, address);
 	pmd = pmd_alloc(pgd, address);
 	if (!pmd)
--- linux-2.2.15pre5/mm/slab.c.orig	Fri Jan 28 00:16:50 2000
+++ linux-2.2.15pre5/mm/slab.c	Fri Jan 28 15:34:25 2000
@@ -687,6 +687,12 @@
 	size_t		left_over;
 	size_t		align;
 
+        /* booby trap */
+        if (current->state != TASK_RUNNING && flags != SLAB_ATOMIC) {
+                printk("kmem_cache_create called by non-running (%d) task from %p!\n",
+                        current->state, __builtin_return_address(0));
+        }
+
 	/* Sanity checks... */
 #if	SLAB_MGMT_CHECKS
 	if (!name) {
@@ -1589,6 +1595,12 @@
 void *
 kmem_cache_alloc(kmem_cache_t *cachep, int flags)
 {
+        /* booby trap */
+        if (current->state != TASK_RUNNING && flags != SLAB_ATOMIC) {
+                printk("kmem_cache_alloc called by non-running (%d) task from %p!\n",
+                        current->state, __builtin_return_address(0));
+        }
+
 	return __kmem_cache_alloc(cachep, flags);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
