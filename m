Date: Fri, 6 Oct 2000 15:59:48 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <Pine.LNX.4.21.0010061555150.13585-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.redhat.com
List-ID: <linux-mm.kvack.org>

Hi Linus,

the following patch contains 2 fixes and one addition
to the VM layer:

1. Roger Larson's fix to make sure there is no
   "1 page gap" between the point where __alloc_pages()
   goes to sleep and kswapd() wakes up    <== livelock fix

2. fix the calculation of freepages.{min,low,high} to better
   reflect the reality of having per-zone tunable free
   memory target                          <== balancing fix

3. add the out of memory killer, which has been tuned with
   -test9 to be ran at exactly the right moment; process
   selection: "principle of least surprise"  <== OOM handling

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.4.0-test9/fs/buffer.c.orig	Tue Oct  3 10:19:10 2000
+++ linux-2.4.0-test9/fs/buffer.c	Tue Oct  3 12:25:23 2000
@@ -706,7 +706,7 @@
 static void refill_freelist(int size)
 {
 	if (!grow_buffers(size)) {
-		wakeup_bdflush(1);
+		wakeup_bdflush(1);  /* Sets task->state to TASK_RUNNING */
 		current->policy |= SCHED_YIELD;
 		schedule();
 	}
--- linux-2.4.0-test9/mm/highmem.c.orig	Tue Oct  3 10:20:41 2000
+++ linux-2.4.0-test9/mm/highmem.c	Tue Oct  3 12:25:44 2000
@@ -310,7 +310,7 @@
 repeat_bh:
 	bh = kmem_cache_alloc(bh_cachep, SLAB_BUFFER);
 	if (!bh) {
-		wakeup_bdflush(1);
+		wakeup_bdflush(1);  /* Sets task->state to TASK_RUNNING */
 		current->policy |= SCHED_YIELD;
 		schedule();
 		goto repeat_bh;
@@ -324,7 +324,7 @@
 repeat_page:
 	page = alloc_page(GFP_BUFFER);
 	if (!page) {
-		wakeup_bdflush(1);
+		wakeup_bdflush(1);  /* Sets task->state to TASK_RUNNING */
 		current->policy |= SCHED_YIELD;
 		schedule();
 		goto repeat_page;
--- linux-2.4.0-test9/mm/page_alloc.c.orig	Tue Oct  3 10:20:41 2000
+++ linux-2.4.0-test9/mm/page_alloc.c	Fri Oct  6 15:45:36 2000
@@ -268,7 +268,8 @@
 				water_mark = z->pages_high;
 		}
 
-		if (z->free_pages + z->inactive_clean_pages > water_mark) {
+		/* Use >= to have one page overlap with free_shortage() !! */
+		if (z->free_pages + z->inactive_clean_pages >= water_mark) {
 			struct page *page = NULL;
 			/* If possible, reclaim a page directly. */
 			if (direct_reclaim && z->free_pages < z->pages_min + 8)
@@ -795,21 +796,6 @@
 			
 	printk("On node %d totalpages: %lu\n", nid, realtotalpages);
 
-	/*
-	 * Select nr of pages we try to keep free for important stuff
-	 * with a minimum of 10 pages and a maximum of 256 pages, so
-	 * that we don't waste too much memory on large systems.
-	 * This is fairly arbitrary, but based on some behaviour
-	 * analysis.
-	 */
-	i = realtotalpages >> 7;
-	if (i < 10)
-		i = 10;
-	if (i > 256)
-		i = 256;
-	freepages.min += i;
-	freepages.low += i * 2;
-	freepages.high += i * 3;
 	memlist_init(&active_list);
 	memlist_init(&inactive_dirty_list);
 
@@ -875,6 +861,20 @@
 		zone->pages_min = mask;
 		zone->pages_low = mask*2;
 		zone->pages_high = mask*3;
+		/*
+		 * Add these free targets to the global free target;
+		 * we have to be SURE that freepages.high is higher
+		 * than SUM [zone->pages_min] for all zones, otherwise
+		 * we may have bad bad problems.
+		 *
+		 * This means we cannot make the freepages array writable
+		 * in /proc, but have to add a separate extra_free_target
+		 * for people who require it to catch load spikes in eg.
+		 * gigabit ethernet routing...
+		 */
+		freepages.min += mask;
+		freepages.low += mask*2;
+		freepages.high += mask*3;
 		zone->zone_mem_map = mem_map + offset;
 		zone->zone_start_mapnr = offset;
 		zone->zone_start_paddr = zone_start_paddr;
--- linux-2.4.0-test9/mm/vmscan.c.orig	Tue Oct  3 10:20:41 2000
+++ linux-2.4.0-test9/mm/vmscan.c	Fri Oct  6 15:46:14 2000
@@ -837,8 +837,9 @@
 		for(i = 0; i < MAX_NR_ZONES; i++) {
 			zone_t *zone = pgdat->node_zones+ i;
 			if (zone->size && (zone->inactive_clean_pages +
-					zone->free_pages < zone->pages_min)) {
-				sum += zone->pages_min;
+					zone->free_pages < zone->pages_min+1)) {
+				/* + 1 to have overlap with alloc_pages() !! */
+				sum += zone->pages_min + 1;
 				sum -= zone->free_pages;
 				sum -= zone->inactive_clean_pages;
 			}
@@ -1095,12 +1096,20 @@
 		 * We go to sleep for one second, but if it's needed
 		 * we'll be woken up earlier...
 		 */
-		if (!free_shortage() || !inactive_shortage())
+		if (!free_shortage() || !inactive_shortage()) {
 			interruptible_sleep_on_timeout(&kswapd_wait, HZ);
 		/*
-		 * TODO: insert out of memory check & oom killer
-		 * invocation in an else branch here.
+		 * If we couldn't free enough memory, we see if it was
+		 * due to the system just not having enough memory.
+		 * If that is the case, the only solution is to kill
+		 * a process (the alternative is enternal deadlock).
+		 *
+		 * If there still is enough memory around, we just loop
+		 * and try free some more memory...
 		 */
+		} else if (out_of_memory()) {
+			oom_kill();
+		}
 	}
 }
 
--- linux-2.4.0-test9/mm/Makefile.orig	Wed Oct  4 21:11:05 2000
+++ linux-2.4.0-test9/mm/Makefile	Wed Oct  4 21:11:13 2000
@@ -10,7 +10,7 @@
 O_TARGET := mm.o
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
 	    vmalloc.o slab.o bootmem.o swap.o vmscan.o page_io.o \
-	    page_alloc.o swap_state.o swapfile.o numa.o
+	    page_alloc.o swap_state.o swapfile.o numa.o oom_kill.o
 
 ifeq ($(CONFIG_HIGHMEM),y)
 O_OBJS += highmem.o
--- linux-2.4.0-test9/mm/oom_kill.c.orig	Wed Oct  4 21:12:51 2000
+++ linux-2.4.0-test9/mm/oom_kill.c	Fri Oct  6 15:35:29 2000
@@ -0,0 +1,210 @@
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
+#include <linux/swap.h>
+#include <linux/swapctl.h>
+#include <linux/timex.h>
+
+/* #define DEBUG */
+
+/**
+ * int_sqrt - oom_kill.c internal function, rough approximation to sqrt
+ * @x: integer of which to calculate the sqrt
+ * 
+ * A very rough approximation to the sqrt() function.
+ */
+static unsigned int int_sqrt(unsigned int x)
+{
+	unsigned int out = x;
+	while (x & ~(unsigned int)1) x >>=2, out >>=1;
+	if (x) out -= out >> 2;
+	return (out ? out : 1);
+}	
+
+/**
+ * oom_badness - calculate a numeric value for how bad this task has been
+ * @p: task struct of which task we should calculate
+ *
+ * The formula used is relatively simple and documented inline in the
+ * function. The main rationale is that we want to select a good task
+ * to kill when we run out of memory.
+ *
+ * Good in this context means that:
+ * 1) we lose the minimum amount of work done
+ * 2) we recover a large amount of memory
+ * 3) we don't kill anything innocent of eating tons of memory
+ * 4) we want to kill the minimum amount of processes (one)
+ * 5) we try to kill the process the user expects us to kill, this
+ *    algorithm has been meticulously tuned to meet the priniciple
+ *    of least surprise ... (be careful when you change it)
+ */
+
+static int badness(struct task_struct *p)
+{
+	int points, cpu_time, run_time;
+
+	if (!p->mm)
+		return 0;
+	/*
+	 * The memory size of the process is the basis for the badness.
+	 */
+	points = p->mm->total_vm;
+
+	/*
+	 * CPU time is in seconds and run time is in minutes. There is no
+	 * particular reason for this other than that it turned out to work
+	 * very well in practice. This is not safe against jiffie wraps
+	 * but we don't care _that_ much...
+	 */
+	cpu_time = (p->times.tms_utime + p->times.tms_stime) >> (SHIFT_HZ + 3);
+	run_time = (jiffies - p->start_time) >> (SHIFT_HZ + 10);
+
+	points /= int_sqrt(cpu_time);
+	points /= int_sqrt(int_sqrt(run_time));
+
+	/*
+	 * Niced processes are most likely less important, so double
+	 * their badness points.
+	 */
+	if (p->nice > 0)
+		points *= 2;
+
+	/*
+	 * Superuser processes are usually more important, so we make it
+	 * less likely that we kill those.
+	 */
+	if (cap_t(p->cap_effective) & CAP_TO_MASK(CAP_SYS_ADMIN) ||
+				p->uid == 0 || p->euid == 0)
+		points /= 4;
+
+	/*
+	 * We don't want to kill a process with direct hardware access.
+	 * Not only could that mess up the hardware, but usually users
+	 * tend to only have this flag set on applications they think
+	 * of as important.
+	 */
+	if (cap_t(p->cap_effective) & CAP_TO_MASK(CAP_SYS_RAWIO))
+		points /= 4;
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
+ *
+ * (not docbooked, we don't want this one cluttering up the manual)
+ */
+static struct task_struct * select_bad_process(void)
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
+/**
+ * oom_kill - kill the "best" process when we run out of memory
+ *
+ * If we run out of memory, we have the choice between either
+ * killing a random task (bad), letting the system crash (worse)
+ * OR try to be smart about which process to kill. Note that we
+ * don't have to be perfect here, we just have to be good.
+ *
+ * We must be careful though to never send SIGKILL a process with
+ * CAP_SYS_RAW_IO set, send SIGTERM instead (but it's unlikely that
+ * we select a process with CAP_SYS_RAW_IO set).
+ */
+void oom_kill(void)
+{
+
+	struct task_struct *p = select_bad_process();
+
+	/* Found nothing?!?! Either we hang forever, or we panic. */
+	if (p == NULL)
+		panic("Out of memory and no killable processes...\n");
+
+	printk(KERN_ERR "Out of Memory: Killed process %d (%s).", p->pid, p->comm);
+
+	/*
+	 * We give our sacrificial lamb high priority and access to
+	 * all the memory it needs. That way it should be able to
+	 * exit() and clear out its resources quickly...
+	 */
+	p->counter = 5 * HZ;
+	p->flags |= PF_MEMALLOC;
+
+	/* This process has hardware access, be more careful. */
+	if (cap_t(p->cap_effective) & CAP_TO_MASK(CAP_SYS_RAWIO)) {
+		force_sig(SIGTERM, p);
+	} else {
+		force_sig(SIGKILL, p);
+	}
+
+	/*
+	 * Make kswapd go out of the way, so "p" has a good chance of
+	 * killing itself before someone else gets the chance to ask
+	 * for more memory.
+	 */
+	current->policy |= SCHED_YIELD;
+	schedule();
+	return;
+}
+
+/**
+ * out_of_memory - is the system out of memory?
+ *
+ * Returns 0 if there is still enough memory left,
+ * 1 when we are out of memory (otherwise).
+ */
+int out_of_memory(void)
+{
+	struct sysinfo swp_info;
+
+	/* Enough free memory?  Not OOM. */
+	if (nr_free_pages() > freepages.min)
+		return 0;
+
+	if (nr_free_pages() + nr_inactive_clean_pages() > freepages.low)
+		return 0;
+
+	/* Enough swap space left?  Not OOM. */
+	si_swapinfo(&swp_info);
+	if (swp_info.freeswap > 0)
+		return 0;
+
+	/* Else... */
+	return 1;
+}
--- linux-2.4.0-test9/include/linux/swap.h.orig	Fri Oct  6 12:33:05 2000
+++ linux-2.4.0-test9/include/linux/swap.h	Fri Oct  6 12:33:48 2000
@@ -126,6 +126,10 @@
 extern struct page * read_swap_cache_async(swp_entry_t, int);
 #define read_swap_cache(entry) read_swap_cache_async(entry, 1);
 
+/* linux/mm/oom_kill.c */
+extern int out_of_memory(void);
+extern void oom_kill(void);
+
 /*
  * Make these inline later once they are working properly.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
