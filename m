Date: Fri, 28 Jan 2000 03:28:48 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [PATCH] boobytrap for 2.2.15pre5
Message-ID: <Pine.LNX.4.10.10001280155560.25452-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.rutgers.edu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

the `boobytrap' code in __get_free_pages() that was
included in 2.2.15-pre5 has been quite succesful,
the kernel programmers have already managed to fix
a number of bugs found by people running this patch.

However, there are a number of places in the kernel
where the patch to __get_free_pages() is done in an
`indirect' way. This patch adds boobytrap code to
some (most?) of these indirect code paths as well,
allowing us to track down more errors and have a
BugFree(tm) 2.2 kernel sooner.

If you apply this patch your kernel will spit out
a one-line error message on every offence (and a
2-liner on a recursive offence). Each error message
will be of the form:

gfp called by non-running (1) task from c0121e23!

The first word, `gfp' is the function that raises the alarm.
The number between parentheses (1) is the tsk->state.
The last number is the memory address from where we were
called.

You can find this memory address in System.map or in
/proc/ksyms (useful if you have modules). When your
system spits out such a message, you can look up the
offending function in this way:

$ cat /proc/ksyms | sort | grep c0121
c0121474 vfree
c01214dc vmalloc
c01216a4 kmem_cache_create
c0121be0 kmem_cache_shrink
c0122114 kmem_cache_alloc    (added for aestetic value)

Of course, you replace the number `c0121' with the
first few numbers of the error message you get...

As we can see, the address from the error message above
(c0121e23) lies between the beginnings of kmem_cache_shrink
and kmem_cache_alloc, that is, it is _in_ kmem_cache_shrink.

When you encounter these error messages, please send them
to linux-kernel, _with_ the names of the functions (because
they differ on every compilation) and, if possible, a short
explanation of what do did to provoke these errors.

kind regards,

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
+++ linux-2.2.15pre5/mm/slab.c	Fri Jan 28 01:40:36 2000
@@ -687,6 +687,12 @@
 	size_t		left_over;
 	size_t		align;
 
+        /* booby trap */
+        if (current->state != TASK_RUNNING) {
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
+        if (current->state != TASK_RUNNING) {
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
