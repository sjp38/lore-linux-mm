Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA11912
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 09:03:06 -0500
Date: Thu, 26 Feb 1998 13:58:05 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: memory limitation test kit (tm) :-)
Message-ID: <Pine.LNX.3.91.980226135506.30101A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, werner@suse.de
List-ID: <linux-mm.kvack.org>

Hi there,

I've made a 'very preliminary' test patch to test
whether memory limitation / quotation might work.
It's untested, untunable and plain wrong, but nevertheless
I'd like you all to take a look at it and point out things
that I've forgotten in the limitation code...

-----------------------------------------------------
--- linux2188orig/mm/page_alloc.c	Thu Feb 26 13:51:16 1998
+++ linux-2.1.88/mm/page_alloc.c	Thu Feb 26 13:09:17 1998
@@ -26,6 +26,7 @@
 #include <asm/bitops.h>
 #include <asm/pgtable.h>
 #include <asm/spinlock.h>
+#include <asm/smp_lock.h> /* for (un)lock_kernel() */
 
 int nr_swap_pages = 0;
 int nr_free_pages = 0;
@@ -328,7 +329,20 @@
 void swap_in(struct task_struct * tsk, struct vm_area_struct * vma,
 	pte_t * page_table, unsigned long entry, int write_access)
 {
-	unsigned long page = __get_free_page(GFP_KERNEL);
+	int i = 0;
+	unsigned long page = 0;
+	static int swap_out_process(struct task_struct *, int);
+
+	if (vma->vm_mm->rss > num_physpages / 2 && nr_free_pages < 
+			free_pages_high) {
+		lock_kernel();
+		for (i = vma->vm_mm->rss; i > 0; i--)
+			if (swap_out_process(tsk, __GFP_IO|__GFP_WAIT))
+				break;
+		unlock_kernel();
+	}
+
+	page = __get_free_page(GFP_KERNEL);
 
 	if (pte_val(*page_table) != entry) {
 		free_page(page);
------------------------------------------------------------

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
