Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA17964
	for <linux-mm@kvack.org>; Thu, 12 Mar 1998 12:03:07 -0500
Date: Thu, 12 Mar 1998 17:38:53 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [PATCH] disk cache memory limit + mm cleanup
Message-ID: <Pine.LNX.3.91.980312173826.894A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@caip.rutgers.edu>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Linus and David,

the following patch:
- puts min_free_pages, free_pages_[low,high] in a struct, so the
  sysctl control is free from compiler reorders (just take a look
  at the old sysctl.c :-) and we're freed from three global variables
- implements sysctl tunable disk cache memory limitations:
  buffer_mem.min_percent;	/* minimum amount of buffer + cache */
  buffer_mem.borrow_percent;	/* when there's more than this, kswapd
                                 * only steals from us */
  buffer_mem.max_percent;	/* the maximum amount of buffer + cache */
- removes the swap= and buff= startup options, since things are
  sysctl tunable now and nobody uses the old options
- cleans up the swapctl_t struct (v6 now :-)
- updates the documentation (Yes, sir!)

It patches cleanly against 2.1.89. The reason I send this to
David is that I had to change asm/sparc(64)/mm/init.c because
of min_free_pages et al...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- linux.89.orig/include/linux/swapctl.h	Sat Mar  7 06:02:12 1998
+++ linux-2.1.89/include/linux/swapctl.h	Thu Mar 12 15:13:45 1998
@@ -6,29 +6,18 @@
 
 /* Swap tuning control */
 
-/* First, enumerate the different reclaim policies */
-enum RCL_POLICY {RCL_ROUND_ROBIN, RCL_BUFF_FIRST, RCL_PERSIST};
-
-typedef struct swap_control_v5
+typedef struct swap_control_v6
 {
 	unsigned int	sc_max_page_age;
 	unsigned int	sc_page_advance;
 	unsigned int	sc_page_decline;
 	unsigned int	sc_page_initial_age;
-	unsigned int	sc_max_buff_age;
-	unsigned int	sc_buff_advance;
-	unsigned int	sc_buff_decline;
-	unsigned int	sc_buff_initial_age;
 	unsigned int	sc_age_cluster_fract;
 	unsigned int	sc_age_cluster_min;
 	unsigned int	sc_pageout_weight;
 	unsigned int	sc_bufferout_weight;
-	unsigned int 	sc_buffer_grace;
-	unsigned int 	sc_nr_buffs_to_free;
-	unsigned int 	sc_nr_pages_to_free;
-	enum RCL_POLICY	sc_policy;
-} swap_control_v5;
-typedef struct swap_control_v5 swap_control_t;
+} swap_control_v6;
+typedef struct swap_control_v6 swap_control_t;
 extern swap_control_t swap_control;
 
 typedef struct swapstat_v1
@@ -42,7 +31,23 @@
 typedef swapstat_v1 swapstat_t;
 extern swapstat_t swapstats;
 
-extern int min_free_pages, free_pages_low, free_pages_high;
+typedef struct buffer_mem_v1
+{
+	unsigned int	min_percent;
+	unsigned int	borrow_percent;
+	unsigned int	max_percent;
+} buffer_mem_v1;
+typedef buffer_mem_v1 buffer_mem_t;
+extern buffer_mem_t buffer_mem;
+
+typedef struct freepages_v1
+{
+	unsigned int	min;
+	unsigned int	low;
+	unsigned int	high;
+} freepages_v1;
+typedef freepages_v1 freepages_t;
+extern freepages_t freepages;
 
 #define SC_VERSION	1
 #define SC_MAX_VERSION	1
@@ -55,28 +60,17 @@
    failure to free a resource at any priority */
 #define RCL_FAILURE (RCL_MAXPRI + 1)
 
-#define RCL_POLICY		(swap_control.sc_policy)
 #define AGE_CLUSTER_FRACT	(swap_control.sc_age_cluster_fract)
 #define AGE_CLUSTER_MIN		(swap_control.sc_age_cluster_min)
 #define PAGEOUT_WEIGHT		(swap_control.sc_pageout_weight)
 #define BUFFEROUT_WEIGHT	(swap_control.sc_bufferout_weight)
 
-#define NR_BUFFS_TO_FREE	(swap_control.sc_nr_buffs_to_free)
-#define NR_PAGES_TO_FREE	(swap_control.sc_nr_pages_to_free)
-
-#define BUFFERMEM_GRACE		(swap_control.sc_buffer_grace)
-
 /* Page aging (see mm/swap.c) */
 
 #define MAX_PAGE_AGE		(swap_control.sc_max_page_age)
 #define PAGE_ADVANCE		(swap_control.sc_page_advance)
 #define PAGE_DECLINE		(swap_control.sc_page_decline)
 #define PAGE_INITIAL_AGE	(swap_control.sc_page_initial_age)
-
-#define MAX_BUFF_AGE		(swap_control.sc_max_buff_age)
-#define BUFF_ADVANCE		(swap_control.sc_buff_advance)
-#define BUFF_DECLINE		(swap_control.sc_buff_decline)
-#define BUFF_INITIAL_AGE	(swap_control.sc_buff_initial_age)
 
 /* Given a resource of N units (pages or buffers etc), we only try to
  * age and reclaim AGE_CLUSTER_FRACT per 1024 resources each time we
--- linux.89.orig/mm/swap.c	Wed May 14 07:41:20 1997
+++ linux-2.1.89/mm/swap.c	Thu Mar 12 15:18:17 1998
@@ -5,10 +5,12 @@
  */
 
 /*
- * This file should contain most things doing the swapping from/to disk.
+ * This file contains the default values for the opereation of the
+ * Linux VM subsystem. Finetuning documentation can be found in
+ * linux/Documentation/sysctl/vm.txt.
  * Started 18.12.91
- *
  * Swap aging added 23.2.95, Stephen Tweedie.
+ * Buffermem limits added 12.3.98, Rik van Riel.
  */
 
 #include <linux/mm.h>
@@ -33,15 +35,18 @@
 
 /*
  * We identify three levels of free memory.  We never let free mem
- * fall below the min_free_pages except for atomic allocations.  We
- * start background swapping if we fall below free_pages_high free
- * pages, and we begin intensive swapping below free_pages_low.
+ * fall below the freepages.min except for atomic allocations.  We
+ * start background swapping if we fall below freepages.high free
+ * pages, and we begin intensive swapping below freepages.low.
  *
- * Keep these three variables contiguous for sysctl(2).  
+ * These values are there to keep GCC from complaining. Actual
+ * initialization is done in mm/page_alloc.c or arch/sparc(64)/mm/init.c.
  */
-int min_free_pages = 48;
-int free_pages_low = 72;
-int free_pages_high = 96;
+freepages_t freepages = {
+	48,	/* freepages.min */
+	72,	/* freepages.low */
+	96	/* freepages.high */
+};
 
 /* We track the number of pages currently being asynchronously swapped
    out, so that we don't try to swap TOO many pages out at once */
@@ -55,53 +60,15 @@
 
 swap_control_t swap_control = {
 	20, 3, 1, 3,		/* Page aging */
-	10, 2, 2, 4,		/* Buffer aging */
 	32, 4,			/* Aging cluster */
 	8192, 8192,		/* Pageout and bufferout weights */
-	-200,			/* Buffer grace */
-	1, 1,			/* Buffs/pages to free */
-	RCL_ROUND_ROBIN		/* Balancing policy */
 };
 
 swapstat_t swapstats = {0};
 
-/* General swap control */
-
-/* Parse the kernel command line "swap=" option at load time: */
-__initfunc(void swap_setup(char *str, int *ints))
-{
-	int * swap_vars[8] = {
-		&MAX_PAGE_AGE,
-		&PAGE_ADVANCE,
-		&PAGE_DECLINE,
-		&PAGE_INITIAL_AGE,
-		&AGE_CLUSTER_FRACT,
-		&AGE_CLUSTER_MIN,
-		&PAGEOUT_WEIGHT,
-		&BUFFEROUT_WEIGHT
-	};
-	int i;
-	for (i=0; i < ints[0] && i < 8; i++) {
-		if (ints[i+1])
-			*(swap_vars[i]) = ints[i+1];
-	}
-}
-
-/* Parse the kernel command line "buff=" option at load time: */
-__initfunc(void buff_setup(char *str, int *ints))
-{
-	int * buff_vars[6] = {
-		&MAX_BUFF_AGE,
-		&BUFF_ADVANCE,
-		&BUFF_DECLINE,
-		&BUFF_INITIAL_AGE,
-		&BUFFEROUT_WEIGHT,
-		&BUFFERMEM_GRACE
-	};
-	int i;
-	for (i=0; i < ints[0] && i < 6; i++) {
-		if (ints[i+1])
-			*(buff_vars[i]) = ints[i+1];
-	}
-}
+buffer_mem_t buffer_mem = {
+	6,	/* minimum percent buffer + cache memory */
+	20,	/* borrow percent buffer + cache memory */
+	90	/* maximum percent buffer + cache memory */
+};
 
--- linux.89.orig/fs/buffer.c	Wed Mar  4 06:22:19 1998
+++ linux-2.1.89/fs/buffer.c	Thu Mar 12 15:48:30 1998
@@ -731,7 +731,8 @@
 	/* We are going to try to locate this much memory. */
 	needed = bdf_prm.b_un.nrefill * size;  
 
-	while ((nr_free_pages > min_free_pages*2) && 
+	while ((nr_free_pages > freepages.min*2) &&
+	        BUFFER_MEM < (buffer_mem.max_percent * num_physpages / 100) &&
 		grow_buffers(GFP_BUFFER, size)) {
 		obtained += PAGE_SIZE;
 		if (obtained >= needed)
@@ -815,7 +816,8 @@
 	 * are _any_ free buffers.
 	 */
 	while (obtained < (needed >> 1) &&
-	       nr_free_pages > min_free_pages + 5 &&
+	       nr_free_pages > freepages.min + 5 &&
+	       BUFFER_MEM < (buffer_mem.max_percent * num_physpages / 100) &&
 	       grow_buffers(GFP_BUFFER, size))
 		obtained += PAGE_SIZE;
 
--- linux.89.orig/arch/sparc/mm/init.c	Tue Jan 13 00:15:43 1998
+++ linux-2.1.89/arch/sparc/mm/init.c	Thu Mar 12 15:16:32 1998
@@ -17,6 +17,7 @@
 #include <linux/mman.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
+#include <linux/swapctl.h>
 #ifdef CONFIG_BLK_DEV_INITRD
 #include <linux/blk.h>
 #endif
@@ -172,9 +173,6 @@
 
 struct cache_palias *sparc_aliases;
 
-extern int min_free_pages;
-extern int free_pages_low;
-extern int free_pages_high;
 extern void srmmu_frob_mem_map(unsigned long);
 
 int physmem_mapped_contig = 1;
@@ -265,11 +263,11 @@
 	       initpages << (PAGE_SHIFT-10),
 	       PAGE_OFFSET, end_mem);
 
-	min_free_pages = nr_free_pages >> 7;
-	if(min_free_pages < 16)
-		min_free_pages = 16;
-	free_pages_low = min_free_pages + (min_free_pages >> 1);
-	free_pages_high = min_free_pages + min_free_pages;
+	freepages.min = nr_free_pages >> 7;
+	if(freepages.min < 16)
+		freepages.min = 16;
+	freepages.low = freepages.min + (freepages.min >> 1);
+	freepages.high = freepages.min + freepages.min;
 }
 
 void free_initmem (void)
--- linux.89.orig/arch/sparc64/mm/init.c	Sat Jan 17 05:34:00 1998
+++ linux-2.1.89/arch/sparc64/mm/init.c	Thu Mar 12 15:17:03 1998
@@ -10,6 +10,7 @@
 #include <linux/init.h>
 #include <linux/blk.h>
 #include <linux/swap.h>
+#include <linux/swapctl.h>
 
 #include <asm/head.h>
 #include <asm/system.h>
@@ -864,10 +865,6 @@
 	return device_scan (PAGE_ALIGN (start_mem));
 }
 
-extern int min_free_pages;
-extern int free_pages_low;
-extern int free_pages_high;
-
 __initfunc(static void taint_real_pages(unsigned long start_mem, unsigned long end_mem))
 {
 	unsigned long addr, tmp2 = 0;
@@ -946,11 +943,11 @@
 	       initpages << (PAGE_SHIFT-10), 
 	       PAGE_OFFSET, end_mem);
 
-	min_free_pages = nr_free_pages >> 7;
-	if(min_free_pages < 16)
-		min_free_pages = 16;
-	free_pages_low = min_free_pages + (min_free_pages >> 1);
-	free_pages_high = min_free_pages + min_free_pages;
+	freepages.low = nr_free_pages >> 7;
+	if(freepages.low < 16)
+		freepages.low = 16;
+	freepages.low = freepages.low + (freepages.low >> 1);
+	freepages.high = freepages.low + freepages.low;
 }
 
 void free_initmem (void)
--- linux.89.orig/kernel/sysctl.c	Sat Feb 21 22:27:56 1998
+++ linux-2.1.89/kernel/sysctl.c	Thu Mar 12 15:21:03 1998
@@ -183,12 +183,14 @@
 	{VM_SWAPOUT, "swapout_interval",
 	 &swapout_interval, sizeof(int), 0600, NULL, &proc_dointvec_jiffies},
 	{VM_FREEPG, "freepages", 
-	 &min_free_pages, 3*sizeof(int), 0600, NULL, &proc_dointvec},
+	 &freepages, sizeof(freepages_t), 0600, NULL, &proc_dointvec},
 	{VM_BDFLUSH, "bdflush", &bdf_prm, 9*sizeof(int), 0600, NULL,
 	 &proc_dointvec_minmax, &sysctl_intvec, NULL,
 	 &bdflush_min, &bdflush_max},
 	{VM_OVERCOMMIT_MEMORY, "overcommit_memory", &sysctl_overcommit_memory,
 	 sizeof(sysctl_overcommit_memory), 0644, NULL, &proc_dointvec},
+	{VM_BUFFERMEM, "buffermem",
+	 &buffer_mem, sizeof(buffer_mem_t), 0600, NULL, &proc_dointvec},
 	{0}
 };
 
--- linux.89.orig/include/linux/swap.h	Tue Feb 24 00:24:32 1998
+++ linux-2.1.89/include/linux/swap.h	Thu Mar 12 15:39:55 1998
@@ -36,10 +36,10 @@
 extern int nr_swap_pages;
 extern int nr_free_pages;
 extern atomic_t nr_async_pages;
-extern int min_free_pages;
-extern int free_pages_low;
-extern int free_pages_high;
 extern struct inode swapper_inode;
+extern unsigned long page_cache_size;
+extern int buffermem;
+#define BUFFER_MEM ((buffermem >> PAGE_SHIFT) + page_cache_size)
 
 /* Incomplete types for prototype declarations: */
 struct task_struct;
--- linux.89.orig/include/linux/sysctl.h	Sun Mar  1 23:40:40 1998
+++ linux-2.1.89/include/linux/sysctl.h	Thu Mar 12 14:22:39 1998
@@ -82,6 +82,7 @@
 	VM_FREEPG,		/* struct: Set free page thresholds */
 	VM_BDFLUSH,		/* struct: Control buffer cache flushing */
 	VM_OVERCOMMIT_MEMORY,	/* Turn off the virtual memory safety limit */
+	VM_BUFFERMEM		/* struct: Set cache memory thresholds */
 };
 
 
--- linux.89.orig/mm/vmscan.c	Thu Mar  5 03:00:09 1998
+++ linux-2.1.89/mm/vmscan.c	Thu Mar 12 16:54:24 1998
@@ -6,7 +6,7 @@
  *  Swap reorganised 29.12.95, Stephen Tweedie.
  *  kswapd added: 7.1.96  sct
  *  Removed kswapd_ctl limits, and swap out as many pages as needed
- *  to bring the system back to free_pages_high: 2.4.97, Rik van Riel.
+ *  to bring the system back to freepages.high: 2.4.97, Rik van Riel.
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
@@ -22,6 +22,8 @@
 #include <linux/smp_lock.h>
 #include <linux/slab.h>
 #include <linux/dcache.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
 
 #include <asm/bitops.h>
 #include <asm/pgtable.h>
@@ -454,11 +456,14 @@
 	stop = 3;
 	if (gfp_mask & __GFP_WAIT)
 		stop = 0;
+	if (BUFFER_MEM > buffer_mem.borrow_percent * num_physpages / 100)
+		state = 0;
 
 	switch (state) {
 		do {
 		case 0:
-			if (shrink_mmap(i, gfp_mask))
+			if (BUFFER_MEM > (buffer_mem.min_percent * num_physpages /100) &&
+					shrink_mmap(i, gfp_mask))
 				return 1;
 			state = 1;
 		case 1:
@@ -511,7 +516,6 @@
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
-#define MAX_SWAP_FAIL 3
 /*
  * The background pageout daemon.
  * Started as a kernel thread from the init process.
@@ -551,28 +555,25 @@
 		swapstats.wakeups++;
 		/* Do the background pageout: 
 		 * When we've got loads of memory, we try
-		 * (free_pages_high - nr_free_pages) times to
+		 * (freepages.high - nr_free_pages) times to
 		 * free memory. As memory gets tighter, kswapd
 		 * gets more and more agressive. -- Rik.
 		 */
-		tries = free_pages_high - nr_free_pages;
-		if (tries < min_free_pages) {
-			tries = min_free_pages;
+		tries = freepages.high - nr_free_pages;
+		if (tries < freepages.min) {
+			tries = freepages.min;
 		}
-		else if (nr_free_pages < (free_pages_high + free_pages_low) / 2) {
+		if (nr_free_pages < freepages.high + freepages.low) 
 			tries <<= 1;
-			if (nr_free_pages < free_pages_low) {
-				tries <<= 1;
-				if (nr_free_pages <= min_free_pages) {
-					tries <<= 1;
-				}
-			}
-		}
 		while (tries--) {
 			int gfp_mask;
 
-			if (free_memory_available())
-				break;
+			if (BUFFER_MEM < (buffer_mem.max_percent * num_physpages / 100)) {
+				if (free_memory_available())
+					break;
+				if (nr_free_pages + atomic_read(&nr_async_pages) > freepages.high * 4)
+					break;
+			}
 			gfp_mask = __GFP_IO;
 			try_to_free_page(gfp_mask);
 			/*
@@ -585,11 +586,11 @@
 		}
 #if 0
 	/*
-	 * Report failure if we couldn't even reach min_free_pages.
+	 * Report failure if we couldn't even reach freepages.min.
 	 */
-	if (nr_free_pages < min_free_pages)
+	if (nr_free_pages < freepages.min)
 		printk("kswapd: failed, got %d of %d\n",
-			nr_free_pages, min_free_pages);
+			nr_free_pages, freepages.min);
 #endif
 	}
 	/* As if we could ever get here - maybe we want to make this killable */
@@ -606,9 +607,10 @@
 	int want_wakeup = 0, memory_low = 0;
 	int pages = nr_free_pages + atomic_read(&nr_async_pages);
 
-	if (pages < free_pages_low)
+	if (pages < freepages.low)
 		memory_low = want_wakeup = 1;
-	else if (pages < free_pages_high && jiffies >= next_swap_jiffies)
+	else if ((pages < freepages.high || BUFFER_MEM > (num_physpages * buffer_mem.max_percent / 100))
+			&& jiffies >= next_swap_jiffies)
 		want_wakeup = 1;
 
 	if (want_wakeup) { 
--- linux.89.orig/init/main.c	Tue Feb 10 01:12:56 1998
+++ linux-2.1.89/init/main.c	Thu Mar 12 15:05:00 1998
@@ -78,8 +78,6 @@
 extern void smp_setup(char *str, int *ints);
 extern void ioapic_pirq_setup(char *str, int *ints);
 extern void no_scroll(char *str, int *ints);
-extern void swap_setup(char *str, int *ints);
-extern void buff_setup(char *str, int *ints);
 extern void panic_setup(char *str, int *ints);
 extern void bmouse_setup(char *str, int *ints);
 extern void msmouse_setup(char *str, int *ints);
@@ -490,8 +488,6 @@
 #if defined (CONFIG_AMIGA) || defined (CONFIG_ATARI)
 	{ "video=", video_setup },
 #endif
-	{ "swap=", swap_setup },
-	{ "buff=", buff_setup },
 	{ "panic=", panic_setup },
 	{ "console=", console_setup },
 #ifdef CONFIG_VT
--- linux.89.orig/Documentation/sysctl/vm.txt	Thu Feb 26 20:09:16 1998
+++ linux-2.1.89/Documentation/sysctl/vm.txt	Thu Mar 12 16:19:39 1998
@@ -16,6 +16,7 @@
 
 Currently, these files are in /proc/sys/vm:
 - bdflush
+- buffermem
 - freepages
 - overcommit_memory
 - swapctl
@@ -88,11 +89,27 @@
 age_super is for filesystem metadata.
 
 ==============================================================
+buffermem:
 
+The three values in this file correspond to the values in
+the struct buffer_mem. It controls how much memory should
+be used for buffer and cache memory. Note that memorymapped
+files are also counted as cache memory...
+
+The values are:
+min_percent	-- this is the minumum percentage of memory
+		   that should be spent on buffer + page cache
+borrow_percent  -- when Linux is short on memory, and buffer
+                   and cache use more than this percentage of
+                   memory, free pages are stolen from them
+max_percent     -- this is the maximum amount of memory that
+                   can be used for buffer and cache memory 
+
+==============================================================
 freepages:
 
-This file contains three values: min_free_pages, free_pages_low
-and free_pages_high in order.
+This file contains the values in the struct freepages. That
+struct contains three members: min, low and high.
 
 These numbers are used by the VM subsystem to keep a reasonable
 number of pages on the free page list, so that programs can
@@ -100,25 +117,23 @@
 free used pages first. The actual freeing of pages is done
 by kswapd, a kernel daemon.
 
-min_free_pages  -- when the number of free pages reaches this
-                   level, only the kernel can allocate memory
-                   for _critical_ tasks only
-free_pages_low  -- when the number of free pages drops below
-                   this level, kswapd is woken up immediately
-free_pages_high -- this is kswapd's target, when more than
-                   free_pages_high pages are free, kswapd will
-                   stop swapping.
-
-When the number of free pages is between free_pages_low and
-free_pages_high, and kswapd hasn't run for swapout_interval
-jiffies, then kswapd is woken up too. See swapout_interval
-for more info.
+min  -- when the number of free pages reaches this
+        level, only the kernel can allocate memory
+        for _critical_ tasks only
+low  -- when the number of free pages drops below
+        this level, kswapd is woken up immediately
+high -- this is kswapd's target, when more than <high>
+        pages are free, kswapd will stop swapping.
+
+When the number of free pages is between low and high,
+and kswapd hasn't run for swapout_interval jiffies, then
+kswapd is woken up too. See swapout_interval for more info.
 
 When free memory is always low on your system, and kswapd has
 trouble keeping up with allocations, you might want to
-increase these values, especially free_pages_high and perhaps
-free_pages_low. I've found that a 1:2:4 relation for these
-values tend to work rather well in a heavily loaded system.
+increase these values, especially high and perhaps low.
+I've found that a 1:2:4 relation for these values tend to work
+rather well in a heavily loaded system.
 
 ==============================================================
 
@@ -163,9 +178,7 @@
 
 swapctl:
 
-This file contains no less than 16 variables, of which about
-half is actually used :-) In the listing below, the unused
-variables are marked as such.
+This file contains no less than 8 variables.
 All of these values are used by kswapd, and the usage can be
 found in linux/mm/vmscan.c.
 
@@ -177,18 +190,10 @@
     unsigned int    sc_page_advance;
     unsigned int    sc_page_decline;
     unsigned int    sc_page_initial_age;
-    unsigned int    sc_max_buff_age;      /* unused */
-    unsigned int    sc_buff_advance;      /* unused */
-    unsigned int    sc_buff_decline;      /* unused */
-    unsigned int    sc_buff_initial_age;  /* unused */
     unsigned int    sc_age_cluster_fract;
     unsigned int    sc_age_cluster_min;
     unsigned int    sc_pageout_weight;
     unsigned int    sc_bufferout_weight;
-    unsigned int    sc_buffer_grace;      /* unused */
-    unsigned int    sc_nr_buffs_to_free;  /* unused */
-    unsigned int    sc_nr_pages_to_free;  /* unused */
-    enum RCL_POLICY sc_policy;            /* RCL_PERSIST hardcoded */
 } swap_control_v5;
 --------------------------------------------------------------
 
@@ -207,9 +212,8 @@
   (default 1)
 And when a page reaches age 0, it's ready to be swapped out.
 
-The variables sc_age_cluster_fract till sc_bufferout_weight
-have to do with the amount of scanning kswapd is doing on
-each call to try_to_swap_out().
+The next four variables can be used to control kswapd's
+agressiveness in swapping out pages.
 
 sc_age_cluster_fract is used to calculate how many pages from
 a process are to be scanned by kswapd. The formula used is
@@ -221,9 +225,12 @@
 
 The values of sc_pageout_weight and sc_bufferout_weight are
 used to control the how many tries kswapd will do in order
-to swapout one page / buffer. As with sc_age_cluster_fract,
-the actual value is calculated by several more or less complex
-formulae and the default value is good for every purpose.
+to swapout one page / buffer. These values can be used to
+finetune the ratio between user pages and buffer/cache memory.
+When you find that your Linux system is swapping out too much
+process pages in order to satisfy buffer memory demands, you
+might want to either increase sc_bufferout_weight, or decrease
+the value of sc_pageout_weight.
 
 ==============================================================
 
