Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA09612
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 01:28:48 -0500
Subject: [PATCH] MM code cleanup
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 09 Jan 1999 07:28:39 +0100
Message-ID: <87yand559k.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is promised MM code cleanup. It mostly removes unused code and is 
COMPLETELY SAFE.

Patch breakdown:

a) removes /proc/swapstats which is not filled anywhere
b) removes /proc/swapctl which is not used anymore
c) removes obsolete page aging structures
d) removes two obsolete variables from task structure
e) removes free_memory_available() (not used anymore)
f) removes remaining "#if 0" constructs
g) modifies swap cache statistics to report useful data

Applies cleanly to pre6.

Enjoy!


Index: 2206.2/include/linux/swapctl.h
--- 2206.2/include/linux/swapctl.h Mon, 04 Jan 1999 17:24:06 +0100 zcalusic (linux-2.1/v/b/38_swapctl.h 1.1.2.2 644)
+++ 2206.3/include/linux/swapctl.h Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/v/b/38_swapctl.h 1.1.2.2.1.1 644)
@@ -4,41 +4,6 @@
 #include <asm/page.h>
 #include <linux/fs.h>
 
-/* Swap tuning control */
-
-typedef struct swap_control_v6
-{
-	unsigned int	sc_max_page_age;
-	unsigned int	sc_page_advance;
-	unsigned int	sc_page_decline;
-	unsigned int	sc_page_initial_age;
-	unsigned int	sc_age_cluster_fract;
-	unsigned int	sc_age_cluster_min;
-	unsigned int	sc_pageout_weight;
-	unsigned int	sc_bufferout_weight;
-} swap_control_v6;
-typedef struct swap_control_v6 swap_control_t;
-extern swap_control_t swap_control;
-
-typedef struct swapstat_v1
-{
-	unsigned long	wakeups;
-	unsigned long	pages_reclaimed;
-	unsigned long	pages_shm;
-	unsigned long	pages_mmap;
-	unsigned long	pages_swap;
-
-	unsigned long	gfp_freepage_attempts;
-	unsigned long	gfp_freepage_successes;
-	unsigned long	gfp_shrink_attempts;
-	unsigned long	gfp_shrink_successes;
-	unsigned long	kswap_freepage_attempts;
-	unsigned long	kswap_freepage_successes;
-	unsigned long	kswap_wakeups[4];
-} swapstat_v1;
-typedef swapstat_v1 swapstat_t;
-extern swapstat_t swapstats;
-
 typedef struct buffer_mem_v1
 {
 	unsigned int	min_percent;
@@ -66,30 +31,5 @@
 } pager_daemon_v1;
 typedef pager_daemon_v1 pager_daemon_t;
 extern pager_daemon_t pager_daemon;
-
-#define SC_VERSION	1
-#define SC_MAX_VERSION	1
-
-#ifdef __KERNEL__
-
-/* Define the maximum (least urgent) priority for the page reclaim code */
-#define RCL_MAXPRI 6
-/* We use an extra priority in the swap accounting code to represent
-   failure to free a resource at any priority */
-#define RCL_FAILURE (RCL_MAXPRI + 1)
-
-#define AGE_CLUSTER_FRACT	(swap_control.sc_age_cluster_fract)
-#define AGE_CLUSTER_MIN		(swap_control.sc_age_cluster_min)
-#define PAGEOUT_WEIGHT		(swap_control.sc_pageout_weight)
-#define BUFFEROUT_WEIGHT	(swap_control.sc_bufferout_weight)
-
-/* Page aging (see mm/swap.c) */
-
-#define MAX_PAGE_AGE		(swap_control.sc_max_page_age)
-#define PAGE_ADVANCE		(swap_control.sc_page_advance)
-#define PAGE_DECLINE		(swap_control.sc_page_decline)
-#define PAGE_INITIAL_AGE	(swap_control.sc_page_initial_age)
-
-#endif /* __KERNEL */
 
 #endif /* _LINUX_SWAPCTL_H */
Index: 2206.2/include/linux/swap.h
--- 2206.2/include/linux/swap.h Thu, 07 Jan 1999 08:28:20 +0100 zcalusic (linux-2.1/w/b/28_swap.h 1.1.2.1.6.1.1.1.4.1 644)
+++ 2206.3/include/linux/swap.h Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/w/b/28_swap.h 1.1.2.1.6.1.1.1.4.1.2.1 644)
@@ -61,15 +61,6 @@
 extern unsigned long page_cache_size;
 extern int buffermem;
 
-struct swap_stats 
-{
-	long	proc_freepage_attempts;
-	long	proc_freepage_successes;
-	long	kswap_freepage_attempts;
-	long	kswap_freepage_successes;
-};
-extern struct swap_stats swap_stats;
-
 /* Incomplete types for prototype declarations: */
 struct task_struct;
 struct vm_area_struct;
@@ -139,9 +130,7 @@
 
 #ifdef SWAP_CACHE_INFO
 extern unsigned long swap_cache_add_total;
-extern unsigned long swap_cache_add_success;
 extern unsigned long swap_cache_del_total;
-extern unsigned long swap_cache_del_success;
 extern unsigned long swap_cache_find_total;
 extern unsigned long swap_cache_find_success;
 #endif
Index: 2206.2/include/linux/proc_fs.h
--- 2206.2/include/linux/proc_fs.h Mon, 04 Jan 1999 17:24:06 +0100 zcalusic (linux-2.1/y/b/16_proc_fs.h 1.2.6.1.1.1 644)
+++ 2206.3/include/linux/proc_fs.h Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/y/b/16_proc_fs.h 1.2.6.1.1.1.1.1 644)
@@ -52,8 +52,7 @@
 	PROC_STRAM,
 	PROC_SOUND,
 	PROC_MTRR, /* whether enabled or not */
-	PROC_FS,
-	PROC_SWAPSTATS
+	PROC_FS
 };
 
 enum pid_directory_inos {
Index: 2206.2/include/linux/sched.h
--- 2206.2/include/linux/sched.h Sat, 09 Jan 1999 03:44:23 +0100 zcalusic (linux-2.1/z/b/13_sched.h 1.1.4.4 644)
+++ 2206.3/include/linux/sched.h Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/z/b/13_sched.h 1.1.4.5 644)
@@ -271,8 +271,6 @@
 	int swappable:1;
 	int trashing_memory:1;
 	unsigned long swap_address;
-	unsigned long old_maj_flt;	/* old value of maj_flt */
-	unsigned long dec_flt;		/* page fault count of the last time */
 	unsigned long swap_cnt;		/* number of pages to swap on next pass */
 /* process credentials */
 	uid_t uid,euid,suid,fsuid;
@@ -356,7 +354,7 @@
 /* utime */	{0,0,0,0},0, \
 /* per CPU times */ {0, }, {0, }, \
 /* flt */	0,0,0,0,0,0, \
-/* swp */	0,0,0,0,0,0, \
+/* swp */	0,0,0,0, \
 /* process credentials */					\
 /* uid etc */	0,0,0,0,0,0,0,0,				\
 /* suppl grps*/ 0, {0,},					\
Index: 2206.2/mm/swap_state.c
--- 2206.2/mm/swap_state.c Sat, 02 Jan 1999 00:49:51 +0100 zcalusic (linux-2.1/z/b/18_swap_state 1.2.7.2 644)
+++ 2206.3/mm/swap_state.c Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/z/b/18_swap_state 1.2.7.2.1.1 644)
@@ -29,18 +29,16 @@
 
 #ifdef SWAP_CACHE_INFO
 unsigned long swap_cache_add_total = 0;
-unsigned long swap_cache_add_success = 0;
 unsigned long swap_cache_del_total = 0;
-unsigned long swap_cache_del_success = 0;
 unsigned long swap_cache_find_total = 0;
 unsigned long swap_cache_find_success = 0;
 
 void show_swap_cache_info(void)
 {
-	printk("Swap cache: add %ld/%ld, delete %ld/%ld, find %ld/%ld\n",
-		swap_cache_add_total, swap_cache_add_success, 
-		swap_cache_del_total, swap_cache_del_success,
-		swap_cache_find_total, swap_cache_find_success);
+	printk("Swap cache: add %ld, delete %ld, find %ld/%ld\n",
+		swap_cache_add_total, 
+		swap_cache_del_total,
+		swap_cache_find_success, swap_cache_find_total);
 }
 #endif
 
@@ -69,9 +67,6 @@
 	page->offset = entry;
 	add_page_to_hash_queue(page, &swapper_inode, entry);
 	add_page_to_inode_queue(&swapper_inode, page);
-#ifdef SWAP_CACHE_INFO
-	swap_cache_add_success++;
-#endif
 	return 1;
 }
 
@@ -192,16 +187,6 @@
 		printk ("VM: Removing swap cache page with wrong inode hash "
 			"on page %08lx\n", page_address(page));
 	}
-#if 0
-	/*
-	 * This is a legal case, but warn about it.
-	 */
-	if (atomic_read(&page->count) == 1) {
-		printk (KERN_WARNING 
-			"VM: Removing page cache on unshared page %08lx\n", 
-			page_address(page));
-	}
-#endif
 
 #ifdef DEBUG_SWAP
 	printk("DebugVM: remove_from_swap_cache(%08lx count %d)\n",
@@ -222,7 +207,6 @@
 
 #ifdef SWAP_CACHE_INFO
 	swap_cache_del_total++;
-	swap_cache_del_success++;
 #endif
 #ifdef DEBUG_SWAP
 	printk("DebugVM: delete_from_swap_cache(%08lx count %d, "
@@ -262,15 +246,22 @@
 struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
-	
+
+#ifdef SWAP_CACHE_INFO
+	swap_cache_find_total++;
+#endif
 	while (1) {
 		found = find_page(&swapper_inode, entry);
 		if (!found)
 			return 0;
 		if (found->inode != &swapper_inode || !PageSwapCache(found))
 			goto out_bad;
-		if (!PageLocked(found))
+		if (!PageLocked(found)) {
+#ifdef SWAP_CACHE_INFO
+			swap_cache_find_success++;
+#endif
 			return found;
+		}
 		__free_page(found);
 		__wait_on_page(found);
 	}
Index: 2206.2/mm/page_alloc.c
--- 2206.2/mm/page_alloc.c Sat, 09 Jan 1999 03:44:23 +0100 zcalusic (linux-2.1/z/b/26_page_alloc 1.2.6.1.1.2.4.1.1.1 644)
+++ 2206.3/mm/page_alloc.c Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/z/b/26_page_alloc 1.2.6.1.1.2.4.1.1.2 644)
@@ -90,33 +90,6 @@
  */
 spinlock_t page_alloc_lock = SPIN_LOCK_UNLOCKED;
 
-/*
- * This routine is used by the kernel swap daemon to determine
- * whether we have "enough" free pages. It is fairly arbitrary,
- * having a low-water and high-water mark.
- *
- * This returns:
- *  0 - urgent need for memory
- *  1 - need some memory, but do it slowly in the background
- *  2 - no need to even think about it.
- */
-int free_memory_available(void)
-{
-	static int available = 1;
-
-	if (nr_free_pages < freepages.low) {
-		available = 0;
-		return 0;
-	}
-
-	if (nr_free_pages > freepages.high) {
-		available = 1;
-		return 2;
-	}
-
-	return available;
-}
-
 static inline void free_pages_ok(unsigned long map_nr, unsigned long order)
 {
 	struct free_area_struct *area = free_area + order;
@@ -155,11 +128,6 @@
 		free_pages_ok(page->map_nr, 0);
 		return;
 	}
-#if 0
-	if (PageSwapCache(page) && atomic_read(&page->count) == 1)
-		printk(KERN_WARNING "VM: Releasing swap cache page at %p",
-			__builtin_return_address(0));
-#endif
 }
 
 void free_pages(unsigned long addr, unsigned long order)
@@ -177,12 +145,6 @@
 			free_pages_ok(map_nr, order);
 			return;
 		}
-#if 0
-		if (PageSwapCache(map) && atomic_read(&map->count) == 1)
-			printk(KERN_WARNING 
-				"VM: Releasing swap cache pages at %p",
-				__builtin_return_address(0));
-#endif
 	}
 }
 
Index: 2206.2/mm/swap.c
--- 2206.2/mm/swap.c Sat, 02 Jan 1999 00:49:51 +0100 zcalusic (linux-2.1/z/b/29_swap.c 1.2.1.1.5.2 644)
+++ 2206.3/mm/swap.c Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/z/b/29_swap.c 1.2.1.1.5.2.4.1 644)
@@ -46,23 +46,6 @@
    out, so that we don't try to swap TOO many pages out at once */
 atomic_t nr_async_pages = ATOMIC_INIT(0);
 
-/*
- * Constants for the page aging mechanism: the maximum age (actually,
- * the maximum "youthfulness"); the quanta by which pages rejuvenate
- * and age; and the initial age for new pages. 
- *
- * The "pageout_weight" is strictly a fixedpoint number with the
- * ten low bits being the fraction (ie 8192 really means "8.0").
- */
-swap_control_t swap_control = {
-	20, 3, 1, 3,		/* Page aging */
-	32, 4,			/* Aging cluster */
-	8192,			/* sc_pageout_weight aka PAGEOUT_WEIGHT */
-	8192,			/* sc_bufferout_weight aka BUFFEROUT_WEIGHT */
-};
-
-swapstat_t swapstats = {0};
-
 buffer_mem_t buffer_mem = {
 	2,	/* minimum percent buffer */
 	10,	/* borrow percent buffer */
@@ -80,7 +63,6 @@
 	SWAP_CLUSTER_MAX,	/* minimum number of tries */
 	SWAP_CLUSTER_MAX,	/* do swap I/O in clusters of this size */
 };
-
 
 /*
  * Perform any setup for the swap system
Index: 2206.2/kernel/sysctl.c
--- 2206.2/kernel/sysctl.c Thu, 07 Jan 1999 08:28:20 +0100 zcalusic (linux-2.1/z/b/41_sysctl.c 1.2.4.3 644)
+++ 2206.3/kernel/sysctl.c Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/z/b/41_sysctl.c 1.2.4.3.1.1 644)
@@ -216,8 +216,6 @@
 };
 
 static ctl_table vm_table[] = {
-	{VM_SWAPCTL, "swapctl", 
-	 &swap_control, sizeof(swap_control_t), 0644, NULL, &proc_dointvec},
 	{VM_FREEPG, "freepages", 
 	 &freepages, sizeof(freepages_t), 0644, NULL, &proc_dointvec},
 	{VM_BDFLUSH, "bdflush", &bdf_prm, 9*sizeof(int), 0600, NULL,
Index: 2206.2/fs/proc/array.c
--- 2206.2/fs/proc/array.c Thu, 07 Jan 1999 08:28:20 +0100 zcalusic (linux-2.1/G/b/18_array.c 1.2.6.1.1.1 644)
+++ 2206.3/fs/proc/array.c Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/G/b/18_array.c 1.2.6.1.1.1.1.1 644)
@@ -60,7 +60,6 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/slab.h>
 #include <linux/smp.h>
 #include <linux/signal.h>
@@ -372,28 +371,6 @@
 		i.freeswap >> 10);
 }
 
-static int get_swapstats(char * buffer)
-{
-	unsigned long *w = swapstats.kswap_wakeups;
-	
-	return sprintf(buffer,
-		       "ProcFreeTry:    %8lu\n"
-		       "ProcFreeSucc:   %8lu\n"
-		       "ProcShrinkTry:  %8lu\n"
-		       "ProcShrinkSucc: %8lu\n"
-		       "KswapFreeTry:   %8lu\n"
-		       "KswapFreeSucc:  %8lu\n"
-		       "KswapWakeups:	%8lu %lu %lu %lu\n",
-		       swapstats.gfp_freepage_attempts,
-		       swapstats.gfp_freepage_successes,
-		       swapstats.gfp_shrink_attempts,
-		       swapstats.gfp_shrink_successes,
-		       swapstats.kswap_freepage_attempts,
-		       swapstats.kswap_freepage_successes,
-		       w[0], w[1], w[2], w[3]
-		       );
-}
-
 static int get_version(char * buffer)
 {
 	extern char *linux_banner;
@@ -1279,9 +1256,6 @@
 
 		case PROC_MEMINFO:
 			return get_meminfo(page);
-
-		case PROC_SWAPSTATS:
-			return get_swapstats(page);
 
 #ifdef CONFIG_PCI_OLD_PROC
   	        case PROC_PCI:
Index: 2206.2/fs/proc/root.c
--- 2206.2/fs/proc/root.c Tue, 22 Dec 1998 23:27:41 +0100 zcalusic (linux-2.1/G/b/24_root.c 1.1.4.1 644)
+++ 2206.3/fs/proc/root.c Sat, 09 Jan 1999 04:07:03 +0100 zcalusic (linux-2.1/G/b/24_root.c 1.1.4.1.2.1 644)
@@ -493,11 +493,6 @@
 	S_IFREG | S_IRUGO, 1, 0, 0,
 	0, &proc_array_inode_operations
 };
-static struct proc_dir_entry proc_root_swapstats = {
-	PROC_SWAPSTATS, 9, "swapstats",
-	S_IFREG | S_IRUGO, 1, 0, 0,
-	0, &proc_array_inode_operations
-};
 static struct proc_dir_entry proc_root_kmsg = {
 	PROC_KMSG, 4, "kmsg",
 	S_IFREG | S_IRUSR, 1, 0, 0,
@@ -653,7 +648,6 @@
 	proc_register(&proc_root, &proc_root_loadavg);
 	proc_register(&proc_root, &proc_root_uptime);
 	proc_register(&proc_root, &proc_root_meminfo);
-	proc_register(&proc_root, &proc_root_swapstats);
 	proc_register(&proc_root, &proc_root_kmsg);
 	proc_register(&proc_root, &proc_root_version);
 	proc_register(&proc_root, &proc_root_cpuinfo);

-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
