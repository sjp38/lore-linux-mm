Message-Id: <200104121659.f3CGxX714605@tuttle.kansas.net>
Date: Thu, 12 Apr 2001 11:58:38 -0500
From: Slats Grobnik <kannzas@excite.com>
Subject: [PATCH] a simple OOM killer to save me from Netscape
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is to solve a specific problem, with no claim to generality.  Say
some X-app memory hog (always seems to be a browser) sneaks up on you,
and by the time HD thrashing catches your attention, the mouse & keyboard
have become sluggish or unresponsive--it may already be too late.
Pretty soon, even the Magic SysRq keybindings don't work....
This used to be my only occasion for ever resorting to the Reset
button, until I found out about oom_kill.  In all the message 
traffic about it, I haven't found this particular solution, so
here's my patch.  It might be useful on some desktop systems.

First, I simplified the criteria for selecting the killable app, as
seemed appropriate.  No root processes;  don't worry about CPU time,
nor nice-ness;  leave direct-hardware-access processes alone.  These
changes to the function `badness' weren't quite enough.  A 2.2.17
kernel patched with such an oom_kill was saved from hard-rebooting
5 or 6 times during a 50-day uptime....but only after waiting through
_extended_ bouts of thrashing.  Here's what happens:

By running `free -s1' or `top' it's clear that once swap memory gets
maxed out, *cache* memory size decreases until, at about 4M, mouse & 
keyboard response becomes noticeably sluggish.  At cache=3M or less,
all hope is lost.  But at this point, *free* RAM size may not be
affected much.  And since CPU activity is down to a crawl, it may
take a while to reach minimum (or some small arbitrary figure.)
So I altered the `out_of_memory' function accordingly, and expect to
never reboot again.  (Except for changing kernels, and power outage.
 (But don't ever try to mount a swap partition.  Seriously.  Nor stick
 beans up your nose. ))       regards,   Slats  

:THANKS:
to Rik van Riel for documenting his code with comments plain enough
that a beginner might be tempted.  It's the chance you take.

:NOTES:  
occasioned by my ignorance of LK programming and C.
  1. PAGE_CACHE_SHIFT would be better than PAGE_SHIFT, but the former
     is undefined in oom_kill.c and I don't know enough to go messing
     with includes.  I _think_ the patch is arch independent, if anyone cares.
  2. I don't know why `atomic_read(&page_cache_size)' is better than 
     `page_cache_size.counter';  I'm just mimicking something I saw 
     while grepping source.  Anyway, to patch 2.2.19 & preceding 
     versions, just substitute `page_cache_size' instead
     (which is just a number in 2.2, while in 2.4 it's a struct
     containing a single member, which is a number.  Go figure.)
  3. (3 << 20)-1, or anything under 3 megs:  This value is of course
     negotiable, depending on your system.  Mine's an old Pentium
     MMX, 32M RAM, piix4 chipset, standard Award BIOS, 3.8G IDE HD.
     For an immediate stress test, try Netscape 4.x rendering
     http://www.nature.com/nature/journal/v409/n6822/toc_r.html
     http://www.nature.com/nature/journal/v409/n6818/toc_r.html
     etc.  Swap grows _absurdly_ fast if Javascript is enabled.
  4. After browsing the ML:  It may be better security on a multi-
     user system NOT to neglect processes with direct hardware 
     access.  Either delete that section of `badness' (treating
     DHA cases the same as others), or restore RR's `points /= 4',
     or some other formula.

=== PATCH against Linux kernel 2.4.3 ===   made with diff -u
Copyright (c) 1999-2001 by Rik van Riel & others, under GNU General
     Public License.  http://www.fsf.org/
--- linux-2.4.3/mm/oom_kill.c	Tue Nov 14 12:56:46 2000
+++ linux-alt/mm/oom_kill.c	Wed Apr 11 19:48:30 2001
@@ -23,19 +23,6 @@
 
 /* #define DEBUG */
 
-/**
- * int_sqrt - oom_kill.c internal function, rough approximation to sqrt
- * @x: integer of which to calculate the sqrt
- * 
- * A very rough approximation to the sqrt() function.
- */
-static unsigned int int_sqrt(unsigned int x)
-{
-	unsigned int out = x;
-	while (x & ~(unsigned int)1) x >>=2, out >>=1;
-	if (x) out -= out >> 2;
-	return (out ? out : 1);
-}	
 
 /**
  * oom_badness - calculate a numeric value for how bad this task has been
@@ -46,7 +33,8 @@
  * to kill when we run out of memory.
  *
  * Good in this context means that:
- * 1) we lose the minimum amount of work done
+ * 1) kill only a normal user (not root) process
+ * -)  (amount of work done and niceness don't count)
  * 2) we recover a large amount of memory
  * 3) we don't kill anything innocent of eating tons of memory
  * 4) we want to kill the minimum amount of processes (one)
@@ -57,7 +45,7 @@
 
 static int badness(struct task_struct *p)
 {
-	int points, cpu_time, run_time;
+	int points;
 
 	if (!p->mm)
 		return 0;
@@ -66,41 +54,26 @@
 	 */
 	points = p->mm->total_vm;
 
-	/*
-	 * CPU time is in seconds and run time is in minutes. There is no
-	 * particular reason for this other than that it turned out to work
-	 * very well in practice. This is not safe against jiffie wraps
-	 * but we don't care _that_ much...
-	 */
-	cpu_time = (p->times.tms_utime + p->times.tms_stime) >> (SHIFT_HZ + 3);
-	run_time = (jiffies - p->start_time) >> (SHIFT_HZ + 10);
+	/* CPU time not considered:  this is for MEMory hogs. */
 
-	points /= int_sqrt(cpu_time);
-	points /= int_sqrt(int_sqrt(run_time));
-
-	/*
-	 * Niced processes are most likely less important, so double
-	 * their badness points.
-	 */
-	if (p->nice > 0)
-		points *= 2;
+	/* Niced processes less important?  Distributed.net would disagree! */
 
 	/*
 	 * Superuser processes are usually more important, so we make it
-	 * less likely that we kill those.
+	 * less likely (impossible) that we kill those.
 	 */
 	if (cap_t(p->cap_effective) & CAP_TO_MASK(CAP_SYS_ADMIN) ||
 				p->uid == 0 || p->euid == 0)
-		points /= 4;
+		points = 0;
 
 	/*
-	 * We don't want to kill a process with direct hardware access.
+	 * We WON'T kill a process with direct hardware access.
 	 * Not only could that mess up the hardware, but usually users
 	 * tend to only have this flag set on applications they think
 	 * of as important.
 	 */
 	if (cap_t(p->cap_effective) & CAP_TO_MASK(CAP_SYS_RAWIO))
-		points /= 4;
+		points = 0;
 #ifdef DEBUG
 	printk(KERN_DEBUG "OOMkill: task %d (%s) got %d points\n",
 	p->pid, p->comm, points);
@@ -193,11 +166,10 @@
 {
 	struct sysinfo swp_info;
 
-	/* Enough free memory?  Not OOM. */
-	if (nr_free_pages() > freepages.min)
-		return 0;
+	/* Even if free memory stays big enough...  */
+	/*  ...a cramped cache means thrashing, then keyboard lockout. */
 
-	if (nr_free_pages() + nr_inactive_clean_pages() > freepages.low)
+	if ((atomic_read(&page_cache_size) << PAGE_SHIFT)  >  (3 << 20)-1 )
 		return 0;
 
 	/* Enough swap space left?  Not OOM. */
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
