Date: Wed, 9 Feb 2000 01:49:42 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [PATCH] OOM handler for 2.2.15pre6
Message-ID: <Pine.LNX.4.10.10002090145030.459-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

I've finished the out of memory handling code for 2.2.15pre6.

I've tested it in a number of situations and it seems to
always kill the `guilty' party and leave important stuff
intact.

I'd like to hear it if anybody gets this patch to really
misbehave... If people are happy about it, this patch will
most likely be included into 2.2.15 (since no current 2.2
kernel handles OOM really well).

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.




--- linux-2.2.15pre6/mm/vmscan.c.orig	Tue Feb  8 15:47:06 2000
+++ linux-2.2.15pre6/mm/vmscan.c	Wed Feb  9 01:26:42 2000
@@ -19,6 +19,7 @@
 #include <linux/init.h>
 
 #include <asm/pgtable.h>
+extern int low_on_memory;
 
 /*
  * The swap-out functions return 1 if they successfully
@@ -495,8 +496,17 @@
 		 */
 		while (nr_free_pages < freepages.high)
 		{
-			if (!do_try_to_free_pages(GFP_KSWAPD))
-				break;
+			if (!do_try_to_free_pages(GFP_KSWAPD)) {
+				/* out of memory? we can't do much */
+				low_on_memory = jiffies;
+				if (nr_free_pages < freepages.min) {
+					run_task_queue(&tq_disk);
+					tsk->state = TASK_INTERRUPTIBLE;
+					schedule_timeout(HZ);
+				} else {	
+					break;
+				}
+			}
 			if (tsk->need_resched)
 				schedule();
 		}
--- linux-2.2.15pre6/mm/page_alloc.c.orig	Tue Feb  8 15:47:14 2000
+++ linux-2.2.15pre6/mm/page_alloc.c	Wed Feb  9 01:27:57 2000
@@ -20,7 +20,9 @@
 
 int nr_swap_pages = 0;
 int nr_free_pages = 0;
+int low_on_memory = 0;
 extern struct wait_queue * kswapd_wait;
+extern int out_of_memory(unsigned long);
 
 /*
  * Free area management
@@ -209,32 +211,45 @@
 	 * further thought.
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
-		int freed;
 		if (current->state != TASK_RUNNING && (gfp_mask & __GFP_WAIT)) {
-			printk("gfp called by non-running (%d) task from %p!\n",
+			printk("gfp called by non-running (%ld) task from %p!\n",
 				current->state, __builtin_return_address(0));
 			/* if we're not running, we can't sleep */
 			gfp_mask &= ~__GFP_WAIT;
 		}
 
+		if (low_on_memory) {
+			int freed;
+			current->flags |= PF_MEMALLOC;
+			freed = try_to_free_pages(gfp_mask);
+			current->flags &= ~PF_MEMALLOC;
+			if (time_after(jiffies, low_on_memory + 60 * HZ))
+				out_of_memory(gfp_mask);
+			if (freed && nr_free_pages > freepages.low)
+				low_on_memory = 0;
+		}
+
 		if (nr_free_pages <= freepages.low) {
 			wake_up_interruptible(&kswapd_wait);
 			/* a bit of defensive programming */
 			if (gfp_mask & __GFP_WAIT)
 				schedule();
+			low_on_memory = jiffies;
 		}
+
 		if (nr_free_pages > freepages.min)
 			goto ok_to_allocate;
-
-		/* Danger, danger! Do something or fail */
-		current->flags |= PF_MEMALLOC;
-		freed = try_to_free_pages(gfp_mask);
-		current->flags &= ~PF_MEMALLOC;
+		/*
+		 * out_of_memory() should usually fix the situation.
+		 * If it does, we can continue like nothing happened.
+		 */
+		if (!out_of_memory(gfp_mask))
+			goto ok_to_allocate;
 
 		if ((gfp_mask & __GFP_MED) && nr_free_pages > freepages.min / 2)
 			goto ok_to_allocate;
 
-		if (!freed && !(gfp_mask & __GFP_HIGH))
+		if (!(gfp_mask & __GFP_HIGH))
 			goto nopage;
 	}
 ok_to_allocate:
--- linux-2.2.15pre6/mm/oom_kill.c.orig	Tue Feb  8 16:02:53 2000
+++ linux-2.2.15pre6/mm/oom_kill.c	Wed Feb  9 01:19:41 2000
@@ -0,0 +1,188 @@
+/*
+ *  linux/mm/oom_kill.c
+ * 
+ *  Copyright (C)  1998,2000  Rik van Riel
+ *	Thanks go out to Claus Fischer for some serious inspiration and
+ *	for goading me into coding this file...
+ *
+ *  The routines in this file are used to kill a process when
+ *  we're seriously out of memory. This gets called from kswapd()
+ *  in linux/mm/vmscan.c when we really run out of memory.
+ *
+ *  Since we won't call these routines often (on a well-configured
+ *  machine) this file will double as a 'coding guide' and a signpost
+ *  for newbie kernel hackers. It features several pointers to major
+ *  kernel subsystems and hints as to where to find out what things do.
+ */
+
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/stddef.h>
+#include <linux/swap.h>
+#include <linux/swapctl.h>
+#include <linux/timex.h>
+
+/* #define DEBUG */
+#define min(a,b) (((a)<(b))?(a):(b))
+
+/*
+ * A rough approximation to the sqrt() function.
+ */
+inline int int_sqrt(unsigned int x)
+{
+	unsigned int out = x;
+	while (x & ~(unsigned int)1) x >>=2, out >>=1;
+	if (x) out -= out >> 2;
+	return (out ? out : 1);
+}	
+
+/*
+ * Basically, points = size / (sqrt(CPU_used) * sqrt(sqrt(time_running)))
+ * with some bonusses/penalties.
+ *
+ * We try to chose our `guilty' task in such a way that we free
+ * up the maximum amount of memory and lose the minimum amount of
+ * done work.
+ *
+ * The definition of the task_struct, the structure describing the state
+ * of each process, can be found in include/linux/sched.h. For
+ * capability info, you should read include/linux/capability.h.
+ */
+
+inline int badness(struct task_struct *p)
+{
+	int points = p->mm->total_vm;
+	points /= int_sqrt((p->times.tms_utime + p->times.tms_stime) >> (SHIFT_HZ + 3));
+	points /= int_sqrt(int_sqrt((jiffies - p->start_time) >> (SHIFT_HZ + 10)));
+/*
+ * Niced processes are probably less important; kernel/sched.c
+ * and include/linux/sched.h contain most info on scheduling.
+ */
+	if (p->priority < DEF_PRIORITY)
+		points <<= 1;
+/*
+ * p->(e)uid is the process User ID, ID 0 is root, the super user.
+ * The super user usually only runs (important) system services
+ * and properly checked programs which we don't want to kill.
+ */
+	if (p->uid == 0 || p->euid == 0 || cap_t(p->cap_effective) & CAP_TO_MASK(CAP_SYS_ADMIN))
+		points >>= 2;
+/*
+ * We don't want to kill a process with direct hardware access.
+ * Not only could this mess up the hardware, but these processes
+ * are usually fairly important too.
+ */
+	if (cap_t(p->cap_effective) & CAP_TO_MASK(CAP_SYS_RAWIO))
+		points >>= 1;
+#ifdef DEBUG
+	printk(KERN_DEBUG "OOMkill: task %d (%s) got %d points\n",
+	p->pid, p->comm, points);
+#endif
+	return points;
+}
+
+/*
+ * Simple selection loop. We chose the process with the highest
+ * number of 'points'. We need the locks to make sure that the
+ * list of task structs doesn't change while we look the other way.
+ */
+inline struct task_struct * select_bad_process(void)
+{
+	int points = 0, maxpoints = 0;
+	struct task_struct *p = NULL;
+	struct task_struct *chosen = NULL;
+
+	read_lock(&tasklist_lock);
+	for_each_task(p)
+	{
+		if (p->pid)
+			points = badness(p);
+		if (points > maxpoints) {
+			chosen = p;
+			maxpoints = points;
+		}
+	}
+	read_unlock(&tasklist_lock);
+	return chosen;
+}
+
+/*
+ * We kill the 'best' process and print a message to userspace.
+ * The only things to be careful about are:
+ *  - don't SIGKILL a process with direct hardware access.
+ *  - are we killing ourselves?
+ *  - when we kill someone else, can we sleep and get out of the way?
+ */
+void oom_kill(unsigned long gfp_mask)
+{
+
+	struct task_struct *p = select_bad_process();
+
+	if (p == NULL)
+		return;
+
+	if (p == current) {
+		printk(KERN_ERR "Out of Memory: Killed process %d (%s).",
+			 p->pid, p->comm);
+	} else {
+		printk(KERN_ERR "Out of Memory: Killed process %d (%s), "
+			"saved process %d (%s).",
+			p->pid, p->comm, current->pid, current->comm);
+	}
+
+	/* This process has hardware access, be more careful */
+	if (cap_t(p->cap_effective) & CAP_TO_MASK(CAP_SYS_RAWIO)) {
+		force_sig(SIGTERM, p);
+	} else {
+		force_sig(SIGKILL, p);
+	}
+
+	/* Get out of the way so that p can die */
+	if (p != current && (gfp_mask & __GFP_WAIT)) {
+		p->counter = 2 * DEF_PRIORITY;
+		current->policy |= SCHED_YIELD;
+		schedule();
+	}
+	return;
+}
+
+/*
+ * We are called when __get_free_pages() thinks the system may
+ * be out of memory. If we really are out of memory, we can do
+ * nothing except freeing up memory by killing a process...
+ */
+
+int out_of_memory(unsigned long gfp_mask)
+{
+	int count = page_cluster;
+	int loop = 0;
+	int freed = 0;
+
+again:
+	if (gfp_mask & __GFP_WAIT) {
+		/* Try to free up some memory */
+		current->flags |= PF_MEMALLOC;
+		do {
+			freed += try_to_free_pages(gfp_mask);
+			run_task_queue(&tq_disk);
+			if (freed && nr_free_pages > freepages.min) {
+				current->flags &= ~PF_MEMALLOC;
+				return 0;
+			}
+		} while (--count);
+		current->flags &= ~PF_MEMALLOC;
+	}
+
+	/* Darn, we failed. Now we have to kill something */
+	if (!loop)
+		oom_kill(gfp_mask);
+
+	if (nr_free_pages > freepages.min)
+		return 0;
+	if (!loop) {
+		loop = 1;
+		goto again;
+	}
+	/* Still out of memory, let the caller deal with it */
+	return 1;
+}
--- linux-2.2.15pre6/mm/Makefile.orig	Tue Feb  8 17:46:55 2000
+++ linux-2.2.15pre6/mm/Makefile	Tue Feb  8 17:47:07 2000
@@ -9,7 +9,7 @@
 
 O_TARGET := mm.o
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
-	    vmalloc.o slab.o \
+	    vmalloc.o slab.o oom_kill.o \
 	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o
 
 include $(TOPDIR)/Rules.make

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
