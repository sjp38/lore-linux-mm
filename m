Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA30469
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 08:22:40 -0500
Date: Mon, 11 Jan 1999 14:21:24 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: arcavm15, et. al.
In-Reply-To: <36992ED2.D05EA28F@netplus.net>
Message-ID: <Pine.LNX.3.96.990111141747.229E-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jan 1999, Steve Bergman wrote:

> For the image load test:
> 
> pre6+zlatko's_patch             2:35
> arcavm15			1:59

Steve, could you give a try to this new arca-vm-16?

arca-vm-16 is still against 2.2.0-pre6 because last night I can't find
pre7 on the ftp site.

Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.11 linux/mm/vmscan.c:1.1.1.1.2.86
--- linux/mm/vmscan.c:1.1.1.11	Sat Jan  9 12:58:26 1999
+++ linux/mm/vmscan.c	Mon Jan 11 14:14:13 1999
@@ -10,6 +10,11 @@
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
+/*
+ * free_user_and_cache() and always async swapout original idea.
+ * Copyright (C) 1999  Andrea Arcangeli
+ */
+
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
@@ -20,6 +25,8 @@
 
 #include <asm/pgtable.h>
 
+int swapout_interval = HZ;
+
 /*
  * The swap-out functions return 1 if they successfully
  * threw something out, and we got a free page. It returns
@@ -306,7 +313,8 @@
 static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int counter, assign;
+	unsigned long max_cnt;
 
 	/* 
 	 * We make one or two passes through the task list, indexed by 
@@ -325,7 +333,7 @@
 	counter = nr_tasks / (priority+1);
 	if (counter < 1)
 		counter = 1;
-	if (counter > nr_tasks)
+	else if (counter > nr_tasks)
 		counter = nr_tasks;
 
 	for (; counter >= 0; counter--) {
@@ -338,7 +346,7 @@
 		for (; p != &init_task; p = p->next_task) {
 			if (!p->swappable)
 				continue;
-	 		if (p->mm->rss <= 0)
+	 		if (p->mm->rss == 0)
 				continue;
 			/* Refresh swap_cnt? */
 			if (assign)
@@ -430,7 +438,7 @@
 			break;
 		current->state = TASK_INTERRUPTIBLE;
 		run_task_queue(&tq_disk);
-		schedule_timeout(HZ);
+		schedule_timeout(swapout_interval);
 
 		/*
 		 * kswapd isn't even meant to keep up with anything,
@@ -438,13 +446,36 @@
 		 * point is to make sure that the system doesn't stay
 		 * forever in a really bad memory squeeze.
 		 */
-		if (nr_free_pages < freepages.high)
-			try_to_free_pages(0, 16);
+		if (nr_free_pages < freepages.min)
+			try_to_free_pages(0, freepages.high - nr_free_pages);
 	}
 
 	return 0;
 }
 
+static int free_user_and_cache(int priority, int gfp_mask)
+{
+	static unsigned long grow_swap_cache = 0;
+
+	if (!shrink_mmap(priority, gfp_mask))
+		grow_swap_cache = 1;
+
+	switch (grow_swap_cache)
+	{
+	case 0:
+		return 1;
+	default:
+		if (grow_swap_cache++ >= freepages.high)
+			grow_swap_cache = 0;
+	}
+
+	if (swap_out(priority, gfp_mask))
+		return 1;
+
+	grow_swap_cache = 0;
+	return 0;
+}
+
 /*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
@@ -457,33 +488,32 @@
 int try_to_free_pages(unsigned int gfp_mask, int count)
 {
 	int priority;
+	static int state = 0;
 
 	lock_kernel();
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(gfp_mask);
-
 	priority = 6;
-	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-
-		/* Try to get rid of some shared memory pages.. */
-		while (shm_swap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-	
-		/* Then, try to page stuff out.. */
-		while (swap_out(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
+	switch (state)
+	{
+		do {
+		case 0:
+			while (free_user_and_cache(priority, gfp_mask)) {
+				if (!--count)
+					goto done;
+			}
+			state = 1;
+		case 1:
+			/* Try to get rid of some shared memory pages.. */
+			while (shm_swap(priority, gfp_mask)) {
+				if (!--count)
+					goto done;
+			}
+			state = 0;
 
-		shrink_dcache_memory(priority, gfp_mask);
-	} while (--priority >= 0);
+			kmem_cache_reap(gfp_mask);
+			shrink_dcache_memory(priority, gfp_mask);
+		} while (--priority >= 0);
+	}
 done:
 	unlock_kernel();
 


Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
