Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA28249
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 09:13:08 -0500
Date: Thu, 7 Jan 1999 15:11:01 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.95.990106153252.7800D-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990107145522.5867B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jan 1999, Linus Torvalds wrote:

> Oh, well.. Based on what the arca-[678] patches did, there's now a pre-5
> out there. Not very similar, but it should incorporate the basic idea: 
> namely much more aggressively asynchronous swap-outs from a process
> context. 

I like it infact ;). I just have some diff that I would like to put under
testing. The patches are against 2.2.0-pre5.

This first patch allow swap_out to have a more fine grined weight. Should
help at least in low memory envinronments.

diff -u linux/mm/vmscan.c:1.1.1.10 linux/mm/vmscan.c:1.1.1.1.2.72
--- linux/mm/vmscan.c:1.1.1.10	Thu Jan  7 12:21:36 1999
+++ linux/mm/vmscan.c	Thu Jan  7 14:46:17 1999
@@ -171,7 +179,7 @@
  */
 
 static inline int swap_out_pmd(struct task_struct * tsk, struct vm_area_struct * vma,
-	pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+	pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask, unsigned long * counter)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
@@ -192,18 +200,20 @@
 
 	do {
 		int result;
-		tsk->swap_address = address + PAGE_SIZE;
 		result = try_to_swap_out(tsk, vma, address, pte, gfp_mask);
+		address += PAGE_SIZE;
+		tsk->swap_address = address;
 		if (result)
 			return result;
-		address += PAGE_SIZE;
+		if (!--*counter)
+			return 0;
 		pte++;
 	} while (address < end);
 	return 0;
 }
 
 static inline int swap_out_pgd(struct task_struct * tsk, struct vm_area_struct * vma,
-	pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+	pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask, unsigned long * counter)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
@@ -223,9 +233,11 @@
 		end = pgd_end;
 	
 	do {
-		int result = swap_out_pmd(tsk, vma, pmd, address, end, gfp_mask);
+		int result = swap_out_pmd(tsk, vma, pmd, address, end, gfp_mask, counter);
 		if (result)
 			return result;
+		if (!*counter)
+			return 0;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
@@ -233,7 +245,7 @@
 }
 
 static int swap_out_vma(struct task_struct * tsk, struct vm_area_struct * vma,
-	unsigned long address, int gfp_mask)
+	unsigned long address, int gfp_mask, unsigned long * counter)
 {
 	pgd_t *pgdir;
 	unsigned long end;
@@ -247,16 +259,19 @@
 
 	end = vma->vm_end;
 	while (address < end) {
-		int result = swap_out_pgd(tsk, vma, pgdir, address, end, gfp_mask);
+		int result = swap_out_pgd(tsk, vma, pgdir, address, end, gfp_mask, counter);
 		if (result)
 			return result;
+		if (!*counter)
+			return 0;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		pgdir++;
 	}
 	return 0;
 }
 
-static int swap_out_process(struct task_struct * p, int gfp_mask)
+static int swap_out_process(struct task_struct * p, int gfp_mask,
+			    unsigned long * counter)
 {
 	unsigned long address;
 	struct vm_area_struct* vma;
@@ -275,9 +290,12 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			int result = swap_out_vma(p, vma, address, gfp_mask);
+			int result = swap_out_vma(p, vma, address, gfp_mask,
+						  counter);
 			if (result)
 				return result;
+			if (!*counter)
+				return 0;
 			vma = vma->vm_next;
 			if (!vma)
 				break;
@@ -291,6 +309,25 @@
 	return 0;
 }
 
+static inline unsigned long calc_swapout_weight(int priority)
+{
+	struct task_struct * p;
+	unsigned long total_vm = 0;
+
+	read_lock(&tasklist_lock);
+	for_each_task(p)
+	{
+		if (!p->swappable)
+			continue;
+		if (p->mm->rss == 0)
+			continue;
+		total_vm += p->mm->total_vm;
+	}
+	read_unlock(&tasklist_lock);
+
+	return total_vm / (1+priority);
+}
+
 /*
  * Select the task with maximal swap_cnt and try to swap out a page.
  * N.B. This function returns only 0 or 1.  Return values != 1 from
@@ -299,7 +336,10 @@
 static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int assign;
+	unsigned long counter, max_cnt;
+
+	counter = calc_swapout_weight(priority);
 
 	/* 
 	 * We make one or two passes through the task list, indexed by 
@@ -315,23 +355,17 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = nr_tasks / (priority+1);
-	if (counter < 1)
-		counter = 1;
-	if (counter > nr_tasks)
-		counter = nr_tasks;
-
-	for (; counter >= 0; counter--) {
+	while (counter != 0) {
 		assign = 0;
 		max_cnt = 0;
 		pbest = NULL;
 	select:
 		read_lock(&tasklist_lock);
-		p = init_task.next_task;
-		for (; p != &init_task; p = p->next_task) {
+		for_each_task(p)
+		{
 			if (!p->swappable)
 				continue;
-	 		if (p->mm->rss <= 0)
+	 		if (p->mm->rss == 0)
 				continue;
 			/* Refresh swap_cnt? */
 			if (assign)
@@ -350,7 +384,7 @@
 			goto out;
 		}
 
-		if (swap_out_process(pbest, gfp_mask))
+		if (swap_out_process(pbest, gfp_mask, &counter))
 			return 1;
 	}
 out:







This other patch instead change a bit the trashing memory heuristic and
how many pages are freed every time. I am not sure it's the best thing to
do. So if you'll try it let me know the results... 

Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.6 linux/mm/page_alloc.c:1.1.1.1.2.22
--- linux/mm/page_alloc.c:1.1.1.6	Thu Jan  7 12:21:35 1999
+++ linux/mm/page_alloc.c	Thu Jan  7 12:57:23 1999
@@ -3,6 +3,7 @@
  *
  *  Copyright (C) 1991, 1992, 1993, 1994  Linus Torvalds
  *  Swap reorganised 29.12.95, Stephen Tweedie
+ *  memory_trashing heuristic. Copyright (C) 1998  Andrea Arcangeli
  */
 
 #include <linux/config.h>
@@ -258,20 +259,18 @@
 		 * a bad memory situation, we're better off trying
 		 * to free things up until things are better.
 		 *
-		 * Normally we shouldn't ever have to do this, with
-		 * kswapd doing this in the background.
-		 *
 		 * Most notably, this puts most of the onus of
 		 * freeing up memory on the processes that _use_
 		 * the most memory, rather than on everybody.
 		 */
-		if (nr_free_pages > freepages.min) {
+		if (nr_free_pages > freepages.min+(1<<order)) {
 			if (!current->trashing_memory)
 				goto ok_to_allocate;
-			if (nr_free_pages > freepages.low) {
+			if (nr_free_pages > freepages.high+(1<<order)) {
 				current->trashing_memory = 0;
 				goto ok_to_allocate;
-			}
+			} else if (nr_free_pages > freepages.low+(1<<order))
+				goto ok_to_allocate;
 		}
 		/*
 		 * Low priority (user) allocations must not
@@ -282,7 +281,7 @@
 		{
 			int freed;
 			current->flags |= PF_MEMALLOC;
-			freed = try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX);
+			freed = try_to_free_pages(gfp_mask, freepages.high - nr_free_pages + (1<<order));
 			current->flags &= ~PF_MEMALLOC;
 			if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
 				goto nopage;



Thanks.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
