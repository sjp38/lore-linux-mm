Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA03567
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 14:53:45 -0500
Date: Thu, 26 Mar 1998 20:48:02 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: [PATCH] page cache limits reintroduced.
Message-ID: <Pine.LNX.3.91.980326203901.2343A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

here's the patch that reintroduces page_cache limits
to prevent heavy thrashing.
Unfortunately, the borrow and max limits of both buffer
and cache memory don't work separately, but since they're
not really hard limits anyway, we can do without it...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- linux/kernel/sysctl.c.pre91-2.1	Thu Mar 26 20:21:02 1998
+++ linux/kernel/sysctl.c	Thu Mar 26 20:23:00 1998
@@ -201,6 +201,8 @@
 	 sizeof(sysctl_overcommit_memory), 0644, NULL, &proc_dointvec},
 	{VM_BUFFERMEM, "buffermem",
 	 &buffer_mem, sizeof(buffer_mem_t), 0600, NULL, &proc_dointvec},
+	{VM_PAGECACHE, "pagecache",
+	 &page_cache, sizeof(buffer_mem_t), 0600, NULL, &proc_dointvec},
 	{0}
 };
 
--- linux/mm/vmscan.c.pre91-2.1	Thu Mar 26 20:08:48 1998
+++ linux/mm/vmscan.c	Thu Mar 26 20:16:16 1998
@@ -451,7 +451,8 @@
 	stop = 3;
 	if (gfp_mask & __GFP_WAIT)
 		stop = 0;
-	if ((buffermem >> PAGE_SHIFT) * 100 > buffer_mem.borrow_percent * num_physpages)
+	if (((buffermem >> PAGE_SHIFT) * 100 > buffer_mem.borrow_percent * num_physpages)
+			|| (page_cache_size * 100 > page_cache.borrow_percent))
 		state = 0;
 
 	switch (state) {
@@ -620,7 +621,8 @@
 	}
  
 	if ((long) (now - want) >= 0) {
-		if (want_wakeup || (num_physpages * buffer_mem.max_percent) < (buffermem >> PAGE_SHIFT) * 100) {
+		if (want_wakeup || (num_physpages * buffer_mem.max_percent) < (buffermem >> PAGE_SHIFT) * 100
+				|| (num_physpages * page_cache.max_percent < page_cache_size)) {
 			/* Set the next wake-up time */
 			next_swap_jiffies = now + swapout_interval;
 			wake_up(&kswapd_wait);
--- linux/mm/filemap.c.pre91-2.1	Thu Mar 26 20:08:57 1998
+++ linux/mm/filemap.c	Thu Mar 26 20:13:33 1998
@@ -171,7 +171,7 @@
 						break;
 					}
 					age_page(page);
-					if (page->age)
+					if (page->age || page_cache_size * 100 < (page_cache.min_percent * num_physpages))
 						break;
 					if (PageSwapCache(page)) {
 						delete_from_swap_cache(page);
--- linux/mm/swap.c.pre91-2.1	Thu Mar 26 20:09:09 1998
+++ linux/mm/swap.c	Thu Mar 26 20:31:06 1998
@@ -72,3 +72,8 @@
 	30	/* maximum percent buffer */
 };
 
+buffer_mem_t page_cache = {
+	8,	/* minimum percent page cache */
+	15,	/* borrow percent page cache */
+	50	/* maximum */
+};
--- linux/include/linux/swapctl.h.pre91-2.1	Thu Mar 26 20:09:24 1998
+++ linux/include/linux/swapctl.h	Thu Mar 26 20:09:50 1998
@@ -39,6 +39,7 @@
 } buffer_mem_v1;
 typedef buffer_mem_v1 buffer_mem_t;
 extern buffer_mem_t buffer_mem;
+extern buffer_mem_t page_cache;
 
 typedef struct freepages_v1
 {
--- linux/include/linux/sysctl.h.pre91-2.1	Thu Mar 26 20:23:17 1998
+++ linux/include/linux/sysctl.h	Thu Mar 26 20:24:08 1998
@@ -84,7 +84,8 @@
 	VM_FREEPG,		/* struct: Set free page thresholds */
 	VM_BDFLUSH,		/* struct: Control buffer cache flushing */
 	VM_OVERCOMMIT_MEMORY,	/* Turn off the virtual memory safety limit */
-	VM_BUFFERMEM		/* struct: Set cache memory thresholds */
+	VM_BUFFERMEM,		/* struct: Set buffer memory thresholds */
+	VM_PAGECACHE		/* struct: Set cache memory thresholds */
 };
 
 
--- linux/Documentation/sysctl/vm.txt.pre91-2.1	Thu Mar 26 20:16:53 1998
+++ linux/Documentation/sysctl/vm.txt	Thu Mar 26 20:20:46 1998
@@ -19,6 +19,7 @@
 - buffermem
 - freepages
 - overcommit_memory
+- pagecache
 - swapctl
 - swapout_interval
 
@@ -93,17 +94,16 @@
 
 The three values in this file correspond to the values in
 the struct buffer_mem. It controls how much memory should
-be used for buffer and cache memory. Note that memorymapped
-files are also counted as cache memory...
+be used for buffer memory.
 
 The values are:
 min_percent	-- this is the minumum percentage of memory
-		   that should be spent on buffer + page cache
-borrow_percent  -- when Linux is short on memory, and buffer
-                   and cache use more than this percentage of
-                   memory, free pages are stolen from them
+		   that should be spent on buffer memory
+borrow_percent  -- when Linux is short on memory, and the
+                   buffer cache uses more memory, free pages
+                   are stolen from it
 max_percent     -- this is the maximum amount of memory that
-                   can be used for buffer and cache memory 
+                   can be used for buffer memory 
 
 ==============================================================
 freepages:
@@ -173,6 +173,18 @@
     freepages -= num_physpages >> 4;
     return freepages > pages;
 }
+
+==============================================================
+
+pagecache:
+
+This file does exactly the same as buffermem, only this
+file controls the struct page_cache, and thus controls
+the amount of memory allowed for memory mapping of files.
+
+You don't want the minimum level to be too low, otherwise
+your system might thrash when memory is tight or fragmentation
+is high...
 
 ==============================================================
 
