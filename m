Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA25794
	for <linux-mm@kvack.org>; Fri, 25 Sep 1998 18:03:39 -0400
Date: Fri, 25 Sep 1998 23:59:51 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: OOM killer patch, vs 2.1.122
Message-ID: <Pine.LNX.3.96.980925235730.14162A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Claus Fischer <cfischer@td2cad.intel.com>, Samuli Kaski <samkaski@cs.helsinki.fi>, security-audit@ferret.lmh.ox.ac.uk
List-ID: <linux-mm.kvack.org>

Hi,

in response to Samuli's bug reports and the DoS discussion on
the audit list, here is my out_of_memory() killer patch.

This time, the out_of_memory function is fully functional
(that last little bug has been ironed out) and the time
the task has been running weighs more heavily than the CPU
time...

have fun,

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

diff -urN linux-2.1.122/mm/Makefile linux-local/mm/Makefile
--- linux-2.1.122/mm/Makefile	Sun May  3 21:14:31 1998
+++ linux-local/mm/Makefile	Thu Aug 27 21:16:35 1998
@@ -9,7 +9,7 @@
 
 O_TARGET := mm.o
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
-	    vmalloc.o slab.o \
+	    vmalloc.o slab.o oom_kill.o\
 	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o
 
 include $(TOPDIR)/Rules.make
diff -urN linux-2.1.122/mm/oom_kill.c linux-local/mm/oom_kill.c
--- linux-2.1.122/mm/oom_kill.c	Thu Jan  1 01:00:00 1970
+++ linux-local/mm/oom_kill.c	Fri Sep 25 18:23:00 1998
@@ -0,0 +1,184 @@
+/*
+ *  linux/mm/oom_kill.c
+ * 
+ *  Copyright (C)  1998  Rik van Riel
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
+#define DEBUG
+/* Hmm, I remember a global declaration. Haven't found
+ * it though...
+ */
+#define min(a,b) (((a)<(b))?(a):(b))
+
+/*
+ * These definitions should move to linux/include/linux/swapctl.h
+ * but I want to change as little files as possible while the patch
+ * is still in beta -- this will have to change before submission
+ * however -- Rik.
+ */
+typedef struct vm_kill_t
+{
+	unsigned int ram;
+	unsigned int total;
+} vm_kill_t;
+
+struct vm_kill_t vm_kill = {25, 3};
+
+/*
+ * Wow, black magic :)  [read closely, the TCP code is hairier]
+ */
+inline int int_sqrt(unsigned int x)
+{
+	unsigned int out = x;
+	while (x & ~(unsigned int)1) x >>=2, out >>=1;
+	if (x) out -= out >> 2;
+#if WANT_PRECISION /* which we don't :) */
+	out = (out + (x / out)) >> 1;
+	out = (out + (x / out)) >> 1;
+	out = (out + (x / out)) >> 1;
+#endif
+	return (out ? out : 1);
+
+}	
+
+/*
+ * Basically, points = size / (sqrt(sqrt((CPU_used)) * sqrt(time_running))
+ * with some bonusses/penalties.
+ *
+ * The definition of the task_struct, the structure describing the state
+ * of each process, can be found in include/linux/sched.h. For
+ * capability info, you should read include/linux/capability.h.
+ */
+
+inline int badness(struct task_struct *p)
+{
+	int points = p->mm->total_vm;
+	points /= int_sqrt(int_sqrt(p->times.tms_utime + p->times.tms_stime)) >> (SHIFT_HZ + 3));
+	points /= int_sqrt((jiffies - p->start_time) >> (SHIFT_HZ + 3));
+/*
+ * DEF_PRIORITY is the lenght of the standard process priority;
+ * see include/linux/sched.h for more info.
+ */
+	if (p->priority < DEF_PRIORITY)
+		points <<= 1;
+/*
+ * p->(e)uid is the process User ID, ID 0 is root, the super user. Since
+ * the super user can do anything, and does almost nothing (on a proper
+ * system), we have to assume that the process is trusted/good.
+ * Besides, the super user usually runs important system services, which
+ * we don't want to kill...
+ */
+	if (p->uid == 0 || p->euid == 0 || p->cap_effective.cap & CAP_TO_MASK(CAP_SYS_ADMIN))
+		points >>= 2;
+/*
+ * NEVER, EVER kill a process with direct hardware acces. Since
+ * they function almost as a device driver, killing one of those
+ * might hang the system -- which is something we need to prevent
+ * at all cost...
+ */
+	if (p->cap_effective.cap & CAP_TO_MASK(CAP_SYS_RAWIO)
+#ifdef __i386__
+	|| p->tss.bitmap == offsetof(struct thread_struct, io_bitmap)
+#endif	
+	)
+		points = 0;
+#ifdef DEBUG
+	printk(KERN_DEBUG "OOMkill: task %d (%s) got %d points\n",
+	p->pid, p->comm, points);
+#endif
+	return points;
+}
+
+inline struct task_struct * select_bad_process(void)
+{
+	int points = 0, maxpoints = 0;
+	struct task_struct *p = NULL;
+	struct task_struct *chosen = NULL;
+/*
+ * These locks are used to prevent modification of critical
+ * structures while we're working with them. Remember that
+ * Linux is a multitasking (and sometimes SMP) system.
+ *  -- Luckily these nice macros are made available so we don't
+ * have to do cumbersome locking ourselves :)
+ */
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
+ * The SCHED_FIFO magic should make sure that the killed context
+ * gets absolute priority when killing itself. This should prevent
+ * a looping kswapd from interfering with the process killing.
+ * Read kernel/sched.c::goodness() and kernel/sched.c::schedule()
+ * for more info.
+ */
+void oom_kill(void)
+{
+
+	struct task_struct *p = select_bad_process();
+	if (p == NULL)
+		return;
+	printk(KERN_ERR "Out of Memory: Killed process %d (%s).", p->pid, p->comm);
+	/*
+	 * If kswapd is looping, the below is needed. If we're just
+	 * thrashing, it can't hurt since p will be thrashing too...
+	 */
+	p->rt_priority = 1000;
+	p->policy = SCHED_FIFO;
+	force_sig(SIGKILL, p);
+	return;
+}
+
+/*
+ * Are we out of memory?
+ *
+ * We ignore swap cache pages and simplify the situation a bit.
+ * This won't do any damage, because we're only called when kswapd
+ * is already failing to free pages and when that is happening we
+ * can assume that the swap cache is very small. See the test in
+ * mm/vmscan.c::kswapd() for more info.
+ */
+
+int out_of_memory(void)
+{
+	struct sysinfo val;
+	int free_vm, kill_limit;
+	si_meminfo(&val);
+	si_swapinfo(&val);
+	kill_limit = min(vm_kill.ram * (val.totalram >> PAGE_SHIFT),
+		vm_kill.total * ((val.totalram + val.totalswap) >> PAGE_SHIFT));
+	free_vm = ((val.freeram + val.bufferram + val.freeswap) >>
+		PAGE_SHIFT) + page_cache_size - (((page_cache.min_percent +
+		buffer_mem.min_percent) * num_physpages) / 100);
+	if (free_vm * 100 < kill_limit)
+		return 1;
+	return 0;
+}
diff -urN linux-2.1.122/mm/vmscan.c linux-local/mm/vmscan.c
--- linux-2.1.122/mm/vmscan.c	Fri Sep 25 16:44:07 1998
+++ linux-local/mm/vmscan.c	Fri Sep 25 10:41:11 1998
@@ -28,6 +28,12 @@
 #include <asm/bitops.h>
 #include <asm/pgtable.h>
 
+/*
+ * OOM kill declarations. Move to .h file before submission ;)
+ */
+extern int out_of_memory(void);
+extern void oom_kill(void);
+
 /* 
  * When are we next due for a page scan? 
  */
@@ -467,7 +473,10 @@
 		case 0:
 			if (shrink_mmap(i, gfp_mask))
 				return 1;
-			state = 1;
+	/* Don't allow a mode change when page cache or buffermem is over max */
+			if (((buffermem >> PAGE_SHIFT) * 100 < buffer_mem.max_percent * num_physpages) &&
+				(page_cache_size * 100 < page_cache.max_percent * num_physpages))			
+				state = 1;
 		case 1:
 			if (shm_swap(i, gfp_mask))
 				return 1;
@@ -546,7 +555,7 @@
 	init_swap_timer();
 	add_wait_queue(&kswapd_wait, &wait);
 	while (1) {
-		int tries;
+		int tries, tried, success;
 
 		current->state = TASK_INTERRUPTIBLE;
 		flush_signals(current);
@@ -572,18 +581,23 @@
 		 */
 		tries = pager_daemon.tries_base;
 		tries >>= 4*free_memory_available();
+		tried = success = 0;
 
 		do {
-			do_try_to_free_page(0);
+			if (do_try_to_free_page(0))
+				success++;
+			tried++;
 			/*
 			 * Syncing large chunks is faster than swapping
 			 * synchronously (less head movement). -- Rik.
 			 */
 			if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster)
 				run_task_queue(&tq_disk);
-			if (free_memory_available() > 1)
+			if (free_memory_available() > 1 && tried > pager_daemon.tries_min)
 				break;
 		} while (--tries > 0);
+	if (success + 1 < tried && out_of_memory())
+		oom_kill();
 	}
 	/* As if we could ever get here - maybe we want to make this killable */
 	remove_wait_queue(&kswapd_wait, &wait);

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
