Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA20784
	for <linux-mm@kvack.org>; Sun, 16 Aug 1998 12:51:13 -0400
Date: Sun, 16 Aug 1998 18:34:32 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: [PATCH] OOM killer
Message-ID: <Pine.LNX.3.96.980816182759.697A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Claus Fischer <cfischer@td2cad.intel.com>
List-ID: <linux-mm.kvack.org>

Hi,

here is the first patch that provides kernel-based out-of-memory
killing.

It is only here to try if it works, I know it compiles but
I haven't even booted it yet :)

Basically, when kswapd fails to free up pages, we're out of
memory and the system would otherwise die, the added functions
select a process to kill.

I don't know if it will always select the right process, nor
if it even works correctly. All I do know is that the code
is currently _VERY_ dirty and that it needs some major cleanups
and sysctl tunables; right now I don't even dare sending Linus
a cc: of this message :-)  [Linus, if you read this, don't
read on unless you don't mind ROFLing]

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--- mm/Makefile.orig	Sun Aug 16 17:26:38 1998
+++ mm/Makefile	Sun Aug 16 17:26:57 1998
@@ -9,7 +9,7 @@
 
 O_TARGET := mm.o
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
-	    vmalloc.o slab.o \
+	    vmalloc.o slab.o oom_kill.o\
 	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o
 
 include $(TOPDIR)/Rules.make
--- mm/oom_kill.c.orig	Sun Aug 16 17:26:30 1998
+++ mm/oom_kill.c	Sun Aug 16 18:24:05 1998
@@ -0,0 +1,133 @@
+/*
+ *  linux/mm/oom_kill.c
+ * 
+ *  Copyright (C)  1998  Rik van Riel
+ *
+ *  The routines in this file are used to kill a process when
+ *  we're seriously out of memory. This gets called from kswapd()
+ *  in linux/mm/vmscan.c when we really run out of memory.
+ *
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
+ * it though... */
+#define min(a,b) (((a)<(b))?(a):(b))
+
+typedef struct vm_kill_t
+{
+	unsigned int ram;
+	unsigned int total;
+} vm_kill_t;
+
+struct vm_kill_t vm_kill = {25, 3};
+
+inline int int_sqrt(unsigned int x)
+{
+	int out = x;
+	while (x & ~(unsigned int)1) x >>=2, out >>=1;
+	if (x) out -= out >> 2;
+	return (out ? out : 1);
+}	
+
+/*
+ * Basically, points = size / (sqrt(CPU_used) * sqrt(sqrt(time_running)))
+ * with some bonusses/penalties.
+ *
+ * This is ugly as hell, and a nice cleanup is welcome :-)
+ */
+
+inline int badness(struct task_struct *p)
+{
+	int points = p->mm->total_vm;
+	points /= int_sqrt((p->times.tms_utime + p->times.tms_stime) >> (SHIFT_HZ + 3));
+	points /= int_sqrt(int_sqrt((jiffies - p->start_time) >> (SHIFT_HZ + 10)));
+	if (p->priority < DEF_PRIORITY)
+		points <<= 1;
+	if (p->uid == 0 || p->euid == 0 || p->cap_effective.cap & CAP_TO_MASK(CAP_SYS_ADMIN))
+		points >>= 2;
+	if (p->start_time < jiffies >> 6)
+		points >>= 2;
+/*
+ * NEVER, EVER kill a process with direct hardware acces. If
+ * we start doing that, we won't make a clean recovery and a
+ * sync + umount + reboot will be better.
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
+	int points = 0;
+	struct task_struct *p = NULL;
+	struct task_struct *chosen = NULL;
+	read_lock(&tasklist_lock);	/* We might need this on SMP */
+	for_each_task(p)
+		if (p->pid && badness(p) > points)
+			chosen = p;
+	read_unlock(&tasklist_lock);
+	return chosen;
+}
+
+/*
+ * The SCHED_FIFO magic should make sure that the killed context
+ * gets absolute priority when killing itself. This should prevent
+ * a looping kswapd from interfering with the process killing.
+ */
+void oom_kill(void)
+{
+
+	struct task_struct *p = select_bad_process();
+	if (p == NULL)
+		return;
+	printk(KERN_ERR "Out of Memory: Killed process %d (%s).", p->pid, p->comm);
+	force_sig(SIGKILL, p);
+	p->policy = SCHED_FIFO;
+	p->rt_priority = 1000;
+	current->policy |= SCHED_YIELD;
+	schedule();
+	return;
+}
+
+/*
+ * Are we out of memory?
+ *
+ * We ignore swap cache pages and simplify the situation a bit.
+ * This probably won't hurt, because when kswapd is failing we
+ * already have to assume the worst.
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
+		PAGE_SHIFT) + page_cache_size - (page_cache.min_percent +
+		buffer_mem.min_percent) * num_physpages;
+	if (free_vm * 100 < kill_limit)
+		return 1;
+	return 0;
+}
+
+	
\ No newline at end of file
--- mm/vmscan.c.orig	Sun Aug 16 17:26:20 1998
+++ mm/vmscan.c	Sun Aug 16 18:26:28 1998
@@ -28,6 +28,13 @@
 #include <asm/bitops.h>
 #include <asm/pgtable.h>
 
+/*
+ * OOM kill declarations. Move to .h file before submission :)
+ */
+ 
+extern int out_of_memory(void);
+extern void oom_kill(void);
+
 /* 
  * When are we next due for a page scan? 
  */
@@ -532,7 +539,7 @@
 	init_swap_timer();
 	add_wait_queue(&kswapd_wait, &wait);
 	while (1) {
-		int tries;
+		int tries, tried, succes;
 
 		current->state = TASK_INTERRUPTIBLE;
 		flush_signals(current);
@@ -558,14 +565,16 @@
 		 */
 		tries = pager_daemon.tries_base;
 		tries >>= 4*free_memory_available();
-	
+		tried = succes = 0;
+		
 		while (tries--) {
 			int gfp_mask;
 
-			if (free_memory_available() > 1)
+			if (free_memory_available() > 1 && ++tried > pager_daemon.tries_min)
 				break;
 			gfp_mask = __GFP_IO;
-			do_try_to_free_page(gfp_mask);
+			if (do_try_to_free_page(gfp_mask))
+				succes++;
 			/*
 			 * Syncing large chunks is faster than swapping
 			 * synchronously (less head movement). -- Rik.
@@ -574,6 +583,8 @@
 				run_task_queue(&tq_disk);
 
 		}
+		if (succes < 4 * tried && out_of_memory())
+			oom_kill();
 	}
 	/* As if we could ever get here - maybe we want to make this killable */
 	remove_wait_queue(&kswapd_wait, &wait);

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
