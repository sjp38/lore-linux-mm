Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA25832
	for <linux-mm@kvack.org>; Sat, 2 Jan 1999 01:57:02 -0500
Date: Fri, 1 Jan 1999 22:55:09 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <368D5E52.FE8B7B8@netplus.net>
Message-ID: <Pine.LNX.3.95.990101225111.16066K-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Fri, 1 Jan 1999, Steve Bergman wrote:
>
> I got the patch and I must say I'm impressed.  I ran my "117 image" test
> and got these results:
> 
> 2.1.131-ac11                         172 sec  (This was previously the best)
> 2.2.0-pre1 + Arcangeli's 1st patch   400 sec
> test1-pre  + Arcangeli's 2nd patch   119 sec (!)

Would you care to do some more testing? In particular, I'd like to hear
how basic 2.2.0pre3 works (that's essentially the same as test1-pre, with
only minor updates)? I'd like to calibrate the numbers against that,
rather than against kernels that I haven't actually ever run myself. 

The other thing I'd like to hear is how pre3 looks with this patch, which
should behave basically like Andrea's latest patch but without the
obfuscation he put into his patch..

		Linus

-----
diff -u --recursive --new-file v2.2.0-pre3/linux/Makefile linux/Makefile
--- v2.2.0-pre3/linux/Makefile	Fri Jan  1 12:58:14 1999
+++ linux/Makefile	Fri Jan  1 12:58:29 1999
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 2
 SUBLEVEL = 0
-EXTRAVERSION =-pre3
+EXTRAVERSION =-pre4
 
 ARCH := $(shell uname -m | sed -e s/i.86/i386/ -e s/sun4u/sparc64/ -e s/arm.*/arm/ -e s/sa110/arm/)
 
diff -u --recursive --new-file v2.2.0-pre3/linux/drivers/misc/parport_procfs.c linux/drivers/misc/parport_procfs.c
--- v2.2.0-pre3/linux/drivers/misc/parport_procfs.c	Sun Nov  8 14:02:59 1998
+++ linux/drivers/misc/parport_procfs.c	Fri Jan  1 21:27:12 1999
@@ -305,12 +305,11 @@
 {
 	base = new_proc_entry("parport", S_IFDIR, &proc_root,PROC_PARPORT,
 			      NULL);
-	base->fill_inode = &parport_modcount;
-
 	if (base == NULL) {
 		printk(KERN_ERR "Unable to initialise /proc/parport.\n");
 		return 0;
 	}
+	base->fill_inode = &parport_modcount;
 
 	return 1;
 }
diff -u --recursive --new-file v2.2.0-pre3/linux/fs/binfmt_misc.c linux/fs/binfmt_misc.c
--- v2.2.0-pre3/linux/fs/binfmt_misc.c	Fri Jan  1 12:58:20 1999
+++ linux/fs/binfmt_misc.c	Fri Jan  1 13:00:10 1999
@@ -30,6 +30,16 @@
 #include <asm/uaccess.h>
 #include <asm/spinlock.h>
 
+/*
+ * We should make this work with a "stub-only" /proc,
+ * which would just not be able to be configured.
+ * Right now the /proc-fs support is too black and white,
+ * though, so just remind people that this should be
+ * fixed..
+ */
+#ifndef CONFIG_PROC_FS
+#error You really need /proc support for binfmt_misc. Please reconfigure!
+#endif
 
 #define VERBOSE_STATUS /* undef this to save 400 bytes kernel memory */
 
diff -u --recursive --new-file v2.2.0-pre3/linux/include/linux/swapctl.h linux/include/linux/swapctl.h
--- v2.2.0-pre3/linux/include/linux/swapctl.h	Tue Dec 22 14:16:58 1998
+++ linux/include/linux/swapctl.h	Fri Jan  1 22:31:21 1999
@@ -90,18 +90,6 @@
 #define PAGE_DECLINE		(swap_control.sc_page_decline)
 #define PAGE_INITIAL_AGE	(swap_control.sc_page_initial_age)
 
-/* Given a resource of N units (pages or buffers etc), we only try to
- * age and reclaim AGE_CLUSTER_FRACT per 1024 resources each time we
- * scan the resource list. */
-static inline int AGE_CLUSTER_SIZE(int resources)
-{
-	unsigned int n = (resources * AGE_CLUSTER_FRACT) >> 10;
-	if (n < AGE_CLUSTER_MIN)
-		return AGE_CLUSTER_MIN;
-	else
-		return n;
-}
-
 #endif /* __KERNEL */
 
 #endif /* _LINUX_SWAPCTL_H */
diff -u --recursive --new-file v2.2.0-pre3/linux/mm/vmscan.c linux/mm/vmscan.c
--- v2.2.0-pre3/linux/mm/vmscan.c	Fri Jan  1 12:58:21 1999
+++ linux/mm/vmscan.c	Fri Jan  1 22:41:58 1999
@@ -363,13 +363,23 @@
 	/* 
 	 * We make one or two passes through the task list, indexed by 
 	 * assign = {0, 1}:
-	 *   Pass 1: select the swappable task with maximal swap_cnt.
-	 *   Pass 2: assign new swap_cnt values, then select as above.
+	 *   Pass 1: select the swappable task with maximal RSS that has
+	 *         not yet been swapped out. 
+	 *   Pass 2: re-assign rss swap_cnt values, then select as above.
+	 *
 	 * With this approach, there's no need to remember the last task
 	 * swapped out.  If the swap-out fails, we clear swap_cnt so the 
 	 * task won't be selected again until all others have been tried.
+	 *
+	 * Think of swap_cnt as a "shadow rss" - it tells us which process
+	 * we want to page out (always try largest first).
 	 */
-	counter = ((PAGEOUT_WEIGHT * nr_tasks) >> 10) >> priority;
+	counter = nr_tasks / (priority+1);
+	if (counter < 1)
+		counter = 1;
+	if (counter > nr_tasks)
+		counter = nr_tasks;
+
 	for (; counter >= 0; counter--) {
 		assign = 0;
 		max_cnt = 0;
@@ -382,15 +392,9 @@
 				continue;
 	 		if (p->mm->rss <= 0)
 				continue;
-			if (assign) {
-				/* 
-				 * If we didn't select a task on pass 1, 
-				 * assign each task a new swap_cnt.
-				 * Normalise the number of pages swapped
-				 * by multiplying by (RSS / 1MB)
-				 */
-				p->swap_cnt = AGE_CLUSTER_SIZE(p->mm->rss);
-			}
+			/* Refresh swap_cnt? */
+			if (assign)
+				p->swap_cnt = p->mm->rss;
 			if (p->swap_cnt > max_cnt) {
 				max_cnt = p->swap_cnt;
 				pbest = p;
@@ -404,14 +408,13 @@
 			}
 			goto out;
 		}
-		pbest->swap_cnt--;
 
 		/*
 		 * Nonzero means we cleared out something, but only "1" means
 		 * that we actually free'd up a page as a result.
 		 */
 		if (swap_out_process(pbest, gfp_mask) == 1)
-				return 1;
+			return 1;
 	}
 out:
 	return 0;
@@ -451,19 +454,17 @@
 	/* max one hundreth of a second */
 	end_time = jiffies + (HZ-1)/100;
 	do {
-		int priority = 5;
+		int priority = 8;
 		int count = pager_daemon.swap_cluster;
 
 		switch (kswapd_state) {
 			do {
 			default:
 				free_memory(shrink_mmap(priority, 0));
+				free_memory(swap_out(priority, 0));
 				kswapd_state++;
 			case 1:
 				free_memory(shm_swap(priority, 0));
-				kswapd_state++;
-			case 2:
-				free_memory(swap_out(priority, 0));
 				shrink_dcache_memory(priority, 0);
 				kswapd_state = 0;
 			} while (--priority >= 0);
@@ -562,7 +563,7 @@
 
 		current->flags |= PF_MEMALLOC;
 	
-		priority = 5;
+		priority = 8;
 		do {
 			free_memory(shrink_mmap(priority, gfp_mask));
 			free_memory(shm_swap(priority, gfp_mask));


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
