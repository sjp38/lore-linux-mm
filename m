Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA19017
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 18:11:40 -0500
Date: Mon, 23 Mar 1998 15:11:09 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.1.90 dies with many procs procs, partial fix
In-Reply-To: <Pine.LNX.3.91.980323203732.771G-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980323140148.431A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: Finn Arne Gangstad <finnag@guardian.no>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Mon, 23 Mar 1998, Rik van Riel wrote:

> On Sun, 22 Mar 1998, Finn Arne Gangstad wrote:
> 
> > int main() {
> > 	int procs = 0;
> > 	while (1) {
> > 		int err = fork();
> > 		if (err == -1) {
> > 			perror("fork failed. eek.");
> > 			exit(EXIT_FAILURE);
> > 		} else if (err == 0) {
> > 			setsid();
> > 			pause();
> > 			_exit(EXIT_SUCCESS);
> > 		}
> > 		++procs;
> > 		printf("%d children forked off\n", procs);
> > 		usleep(30000);
> > 	}
> > 	exit(EXIT_SUCCESS);
> > }
> 
> Hmm, this is evidence that I was right when I said
> that the free_memory_available() system combined
> with our current allocation scheme gives trouble.
> Linus, what fix do you propose?
> (I don't really feel like coding a fix that will
> be rejected :-)

I tried the above, but I have way too much memory in my machine: the
per-user process limit of 256 keeps me well under the problem, and when I
add a 3MB buffer to each process and make sure to do a "memset()" on it in
the child, I still get perfectly reasonable behaviour from my system (it
pages out almost 300MB worth of stuff on my 512MB RAM system but because
it is easy to page out it wasn't a problem). 

Of course, this is with some changes to the kswapd logic that I had
anyway, so maybe they just behave really well, but I think the basic
problem is that I have too much RAM to really see any bad behaviour. 

Anyway, I'm appending the diffs as I have them in my current pre-91 mm
changes to let people comment on them..

		Linus

-----
diff -u --recursive --new-file v2.1.90/linux/include/linux/mm.h linux/include/linux/mm.h
--- v2.1.90/linux/include/linux/mm.h	Tue Mar 10 10:03:35 1998
+++ linux/include/linux/mm.h	Mon Mar 23 13:14:18 1998
@@ -251,7 +251,23 @@
 }
 
 /* memory.c & swap.c*/
-extern int free_memory_available(void);
+
+/*
+ * This traverses "nr" memory size lists,
+ * and returns true if there is enough memory.
+ *
+ * For example, we want to keep on waking up
+ * kswapd every once in a while until the highest
+ * memory order has an entry (ie nr == 0), but
+ * we want to do it in the background.
+ *
+ * We want to do it in the foreground only if
+ * none of the three highest lists have enough
+ * memory. Random number.
+ */
+extern int free_memory_available(int nr);
+#define kswapd_continue()	(!free_memory_available(3))
+#define kswapd_wakeup()		(!free_memory_available(0))
 
 #define free_page(addr) free_pages((addr),0)
 extern void FASTCALL(free_pages(unsigned long addr, unsigned long order));
diff -u --recursive --new-file v2.1.90/linux/mm/page_alloc.c linux/mm/page_alloc.c
--- v2.1.90/linux/mm/page_alloc.c	Tue Mar 17 22:18:15 1998
+++ linux/mm/page_alloc.c	Mon Mar 23 12:50:18 1998
@@ -118,28 +118,33 @@
  *
  * [previously, there had to be two entries of the highest memory
  *  order, but this lead to problems on large-memory machines.]
+ *
+ * This will return zero if no list was found, non-zero
+ * if there was memory (the bigger, the better).
  */
-int free_memory_available(void)
+int free_memory_available(int nr)
 {
-	int i, retval = 0;
 	unsigned long flags;
 	struct free_area_struct * list = NULL;
 
+	list = free_area + NR_MEM_LISTS;
 	spin_lock_irqsave(&page_alloc_lock, flags);
 	/* We fall through the loop if the list contains one
 	 * item. -- thanks to Colin Plumb <colin@nyx.net>
 	 */
-	for (i = 1; i < 4; ++i) {
-		list = free_area + NR_MEM_LISTS - i;
+	do {
+		list--;
+		/* Empty list? Bad - we need more memory */
 		if (list->next == memory_head(list))
 			break;
+		/* One item on the list? Look further */
 		if (list->next->next == memory_head(list))
 			continue;
-		retval = 1;
+		/* More than one item? We're ok */
 		break;
-	}
+	} while (--nr >= 0);
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
-	return retval;
+	return nr + 1;
 }
 
 static inline void free_pages_ok(unsigned long map_nr, unsigned long order)
diff -u --recursive --new-file v2.1.90/linux/mm/vmscan.c linux/mm/vmscan.c
--- v2.1.90/linux/mm/vmscan.c	Tue Mar 17 22:18:15 1998
+++ linux/mm/vmscan.c	Mon Mar 23 13:35:08 1998
@@ -44,11 +44,6 @@
  */
 static struct wait_queue * kswapd_wait = NULL;
 
-/* 
- * We avoid doing a reschedule if the pageout daemon is already awake;
- */
-static int kswapd_awake = 0;
-
 static void init_swap_timer(void);
 
 /*
@@ -545,13 +540,12 @@
 	add_wait_queue(&kswapd_wait, &wait);
 	while (1) {
 		int tries;
+		int tried = 0;
 
 		current->state = TASK_INTERRUPTIBLE;
-		kswapd_awake = 0;
 		flush_signals(current);
 		run_task_queue(&tq_disk);
 		schedule();
-		kswapd_awake = 1;
 		swapstats.wakeups++;
 		/* Do the background pageout: 
 		 * When we've got loads of memory, we try
@@ -563,12 +557,12 @@
 		if (tries < freepages.min) {
 			tries = freepages.min;
 		}
-		if (nr_free_pages < freepages.high + freepages.low)
+		if (nr_free_pages < freepages.low)
 			tries <<= 1;
 		while (tries--) {
 			int gfp_mask;
 
-			if (free_memory_available())
+			if (++tried > SWAP_CLUSTER_MAX && free_memory_available(0))
 				break;
 			gfp_mask = __GFP_IO;
 			try_to_free_page(gfp_mask);
@@ -592,24 +586,35 @@
 
 void swap_tick(void)
 {
-	int want_wakeup = 0, memory_low = 0;
-	int pages = nr_free_pages + atomic_read(&nr_async_pages);
+	unsigned long now, want;
+	int want_wakeup = 0;
 
-	if (pages < freepages.low)
-		memory_low = want_wakeup = 1;
-	else if ((pages < freepages.high || BUFFER_MEM > (num_physpages * buffer_mem.max_percent / 100))
-			&& jiffies >= next_swap_jiffies)
-		want_wakeup = 1;
+	want = next_swap_jiffies;
+	now = jiffies;
 
-	if (want_wakeup) { 
-		if (!kswapd_awake) {
+	/*
+	 * Examine the memory queues. Mark memory low
+	 * if there is nothing available in the three
+	 * highest queues.
+	 *
+	 * Schedule for wakeup if there isn't lots
+	 * of free memory.
+	 */
+	switch (free_memory_available(3)) {
+	case 0:
+		want = now;
+		/* Fall through */
+	case 1 ... 2:
+		want_wakeup = 1;
+	default:
+	}
+ 
+	if ((long) (now - want) >= 0) {
+		if (want_wakeup || (num_physpages * buffer_mem.max_percent / 100) < BUFFER_MEM) {
+			/* Set the next wake-up time */
+			next_swap_jiffies = now + swapout_interval;
 			wake_up(&kswapd_wait);
-			need_resched = 1;
 		}
-		/* Set the next wake-up time */
-		next_swap_jiffies = jiffies;
-		if (!memory_low) 
-			next_swap_jiffies += swapout_interval;
 	}
 	timer_active |= (1<<SWAP_TIMER);
 }
