Date: Thu, 18 Nov 2004 11:34:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: another approach to rss : sloppy rss 
In-Reply-To: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Nov 2004, Hugh Dickins wrote:

> But I don't know what the appropriate solution is.  My priorities
> may be wrong, but I dislike the thought of a struct mm dominated
> by a huge percpu array of rss longs (or cachelines?), even if the
> machines on which it would be huge are ones which could well afford
> the waste of memory.  It just offends my sense of proportion, when
> the exact rss is of no importance.  I'm more attracted to just
> leaving it unatomic, and living with the fact that it's racy
> and approximate (but /proc report negatives as 0).

Here is a patch that enables handling of rss outside of the page table
lock by simply ignoring errors introduced by not locking. The loss
of rss was always less than 1%.

The patch insures that negative rss values are not displayed and removes 3
checks in mm/rmap.c that utilized rss (unecessarily AFAIK).

Some numbers:

4 Gigabyte concurrent alocation from 4 cpus:

rss protect by page_table_lock:

margin:~/clameter # ./pftn -g4 -r3 -f4
Size=262415 RSS=262233
Size=262479 RSS=262234
Size=262415 RSS=262233
  4   3    4    0.180s     16.271s   5.010s 47801.151 154059.862
margin:~/clameter # ./pftn -g4 -r3 -f4
Size=262415 RSS=262233
Size=262415 RSS=262233
Size=262415 RSS=262233
  4   3    4    0.155s     14.616s   4.081s 53239.852 163270.962
margin:~/clameter # ./pftn -g4 -r3 -f4
Size=262415 RSS=262233
Size=262479 RSS=262234
Size=262415 RSS=262233
  4   3    4    0.172s     16.192s   5.018s 48055.018 151621.738

with sloppy rss:

margin2:~/clameter # ./pftn -g4 -r3 -f4
Size=262415 RSS=261120
Size=262415 RSS=261074
Size=262415 RSS=261215
  4   3    4    0.161s     13.058s   4.060s 59489.254 170939.864
margin2:~/clameter # ./pftn -g4 -r3 -f4
Size=262415 RSS=260900
Size=262543 RSS=261001
Size=262415 RSS=261053
  4   3    4    0.152s     13.565s   4.031s 57329.397 182103.081
margin2:~/clameter # ./pftn -g4 -r3 -f4
Size=262415 RSS=260988
Size=262479 RSS=261112
Size=262479 RSS=261343
  4   3    4    0.143s     12.994s   4.060s 59860.702 170770.399

32 GB allocation with 32 cpus.

with page_table_lock:

Size=2099307 RSS=2097270
Size=2099371 RSS=2097271
Size=2099307 RSS=2097270
Size=2099307 RSS=2097270
Size=2099307 RSS=2097270
Size=2099307 RSS=2097270
Size=2099307 RSS=2097270
Size=2099307 RSS=2097270
Size=2099307 RSS=2097270
Size=2099307 RSS=2097270
 32  10   32   18.105s   5466.913s 202.027s  3823.418 103676.172

sloppy rss:

Size=2099307 RSS=2094018
Size=2099307 RSS=2093738
Size=2099307 RSS=2093907
Size=2099307 RSS=2093634
Size=2099307 RSS=2093731
Size=2099307 RSS=2094343
Size=2099307 RSS=2094072
Size=2099307 RSS=2094185
Size=2099307 RSS=2093845
Size=2099307 RSS=2093396
32  10   32   14.872s   1036.711s  55.023s 19942.800 379701.332



Index: linux-2.6.9/include/linux/sched.h
===================================================================
--- linux-2.6.9.orig/include/linux/sched.h	2004-11-15 11:13:39.000000000 -0800
+++ linux-2.6.9/include/linux/sched.h	2004-11-17 06:58:51.000000000 -0800
@@ -216,7 +216,7 @@
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
-	spinlock_t page_table_lock;		/* Protects page tables, mm->rss, mm->anon_rss */
+	spinlock_t page_table_lock;		/* Protects page tables */

 	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung
 						 * together off init_mm.mmlist, and are protected
@@ -252,6 +252,19 @@
 	struct kioctx		default_kioctx;
 };

+/*
+ * rss and anon_rss are incremented and decremented in some locations without
+ * proper locking. This function insures that these values do not become negative
+ * and is called before reporting rss based statistics
+ */
+static void inline rss_fixup(struct mm_struct *mm)
+{
+	if ((long)mm->rss < 0)
+		 mm->rss = 0;
+	if ((long)mm->anon_rss < 0)
+		mm->anon_rss = 0;
+}
+
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];
Index: linux-2.6.9/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.9.orig/fs/proc/task_mmu.c	2004-11-15 11:13:38.000000000 -0800
+++ linux-2.6.9/fs/proc/task_mmu.c	2004-11-17 06:58:51.000000000 -0800
@@ -11,6 +11,7 @@
 	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
+	rss_fixup(mm);
 	buffer += sprintf(buffer,
 		"VmSize:\t%8lu kB\n"
 		"VmLck:\t%8lu kB\n"
@@ -37,6 +38,7 @@
 int task_statm(struct mm_struct *mm, int *shared, int *text,
 	       int *data, int *resident)
 {
+	rss_fixup(mm);
 	*shared = mm->rss - mm->anon_rss;
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
Index: linux-2.6.9/fs/proc/array.c
===================================================================
--- linux-2.6.9.orig/fs/proc/array.c	2004-11-15 11:13:38.000000000 -0800
+++ linux-2.6.9/fs/proc/array.c	2004-11-17 06:58:51.000000000 -0800
@@ -325,6 +325,7 @@
 		vsize = task_vsize(mm);
 		eip = KSTK_EIP(task);
 		esp = KSTK_ESP(task);
+		rss_fixup(mm);
 	}

 	get_task_comm(tcomm, task);
Index: linux-2.6.9/mm/rmap.c
===================================================================
--- linux-2.6.9.orig/mm/rmap.c	2004-11-15 11:13:40.000000000 -0800
+++ linux-2.6.9/mm/rmap.c	2004-11-17 07:07:00.000000000 -0800
@@ -263,8 +263,6 @@
 	pte_t *pte;
 	int referenced = 0;

-	if (!mm->rss)
-		goto out;
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
@@ -504,8 +502,6 @@
 	pte_t pteval;
 	int ret = SWAP_AGAIN;

-	if (!mm->rss)
-		goto out;
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
@@ -788,8 +784,7 @@
 			if (vma->vm_flags & (VM_LOCKED|VM_RESERVED))
 				continue;
 			cursor = (unsigned long) vma->vm_private_data;
-			while (vma->vm_mm->rss &&
-				cursor < max_nl_cursor &&
+			while (cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
 				try_to_unmap_cluster(cursor, &mapcount, vma);
 				cursor += CLUSTER_SIZE;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
