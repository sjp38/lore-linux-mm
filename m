Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA11895
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 12:11:34 -0500
Date: Sat, 19 Dec 1998 17:09:14 GMT
Message-Id: <199812191709.RAA01245@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="JicA824Y4A"
Content-Transfer-Encoding: 7bit
Subject: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.95.981216171905.2111A-100000@penguin.transmeta.com>
References: <Pine.LNX.3.96.981201075322.509A-100000@mirkwood.dummy.home>
	<Pine.LNX.3.95.981216171905.2111A-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>


--JicA824Y4A
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

On Wed, 16 Dec 1998 17:24:05 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> On Tue, 1 Dec 1998, Rik van Riel wrote:
>> 
>> --- ./mm/vmscan.c.orig	Thu Nov 26 11:26:50 1998
>> +++ ./mm/vmscan.c	Tue Dec  1 07:12:28 1998
>> @@ -431,6 +431,8 @@
>> kmem_cache_reap(gfp_mask);
>> 
>> if (buffer_over_borrow() || pgcache_over_borrow())
>> +		state = 0;		
>> +	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
>> shrink_mmap(i, gfp_mask);
>> 
>> switch (state) {

> I really hate the above tests that make no sense at all from a conceptual
> view, and are fairly obviously just something to correct for a more basic
> problem. 

Agreed: I've been saying this for several years now. :)

Linus, I've had a test with your 132-pre2 patch, and the performance is
really disappointing in some important cases.  Particular effects I can
reproduce with it include:

* Extra file IO activity

  Doing a kernel build on a full (lots of applications have been loaded)
  but otherwise idle 64MB machine results in sustained 50 to 200kb/sec
  IO block read rates according to vmstat.  I've never seen this with
  older kernels, and it results in  a drop of about 10% in the cpu
  utilisation sustained over the entire kernel build.  I've had
  independent confirmation of this effect from other people.

* Poor swapout performance

  On my main development box, I've been able to sustain about 3MB/sec to
  swap quite easily when the VM got busy on most recent kernels since
  2.1.130 (including all the late ac* patches with my VM changes in).
  Swap out peaks at a little under 4MB/sec, and I can sustain about
  3MB/sec combined read+write traffic too.  It streams to/from swap very
  well indeed.

  The 132-pre2 peaks at about 800kb/sec to swap, and sustains between
  300 and 400. 

* Swap fragmentation

  The reduced swap streaming means that swap does seem to get much more
  fragmented than under, say, ac11.  In particular, this appears to have
  two side effects: it defeats the swap clustered readin code in ac11
  (which I have ported forward to 132-pre2), resulting in much slower
  swapping behaviour if I start up more applications than I have ram for
  and swap between them; and, especially on low memory, the swap
  fragmentation appears to make successive compilation runs in 8MB ever
  more slow as bits of my background tasks (https, cron) scatter
  themselves over swap.

The problem that we have with the strict state-driven logic in
do_try_to_free_page is that, for prolonged periods, it can bypass the
normal shrink_mmap() loop which we _do_ want to keep active even while
swapping.  However, I think that the 132-pre2 cure is worse than the
disease, because it penalises swap to such an extent that we lose the
substantial performance benefit that comes from being able to stream
both to and from swap rapidly.

The VM in 2.1.131-ac11+ seems to work incredibly well.  On my own 64MB
box it feels as if the memory has doubled.  I've had similar feedback
from other people, including reports of 300% performance improvement
over 2.0 in 4MB memory (!).  Alan reports a huge increase in the uptake
of his ac patches since the new VM stuff went in there.  

I've tried to port the best bits of that VM to 132-pre2, preserving your
do_try_to_free_page state change, but so far I have not been able find a
combination which gives anywhere near the overall performance of ac11
for all of my test cases (although it works reasonably well on low
memory at first, until we start to fragment swap).

The patch below is the best I have so far against 132-pre2.  You will
find that it has absolutely no references to the borrow percentages, and
although it does honour the buffer/pgcache min percentages, those
default to 1%.

Andrea, I know you've seen odd behaviours since 2.1.131, although I'm
not quite sure exactly which VMs you've been testing on.  The one change
I've found which does have a significant effect on predictability here
is in do_try_to_free_page:

	if (current != kswapd_task)
		if (shrink_mmap(6, gfp_mask))
			return 1;

which means that even if kswapd is busy swapping, we can _still_ bypass
the swap and go straight to the cache shrinking if we need more memory.
The overall effect I observe is that large IO-bound tasks _can_ still
grow the cache, and I don't see any excessive input IO during a kernel
build, but that kswapd itself can still stream efficiently out to swap.

The patch also includes a few extra performance counters in
/proc/swapstats, and adds back the heuristic from a while ago that the
kswap wakeup has a hysteresis behaviour between freepages.high and
freepages.med: kswapd will remain inactive until nr_free_pages reaches
freepages.med, and will then swap until it is brought back up to
freepages.high.  Any failure of shrink_mmap immediately kicks kswapd
into action, though.  To be honest, I haven't been able to measure a
huge difference from this, but it's in my current tree so you are
welcome to it.

Finally, the patch includes the swap and mmap clustered read logic.
That is entirely responsible for my being able to sustain 2MB/sec or
more swapin performance, and disk performance (5MB/sec) when doing a
mmap-based grep.

Tested on 8MB, 64MB and with high filesystem and VM load.  Doing an
anonymous-page stress test (basically a memset on a region 3 times
physical memory) it sustains 1.5M/sec to swap (and about 150K/sec from
swap) for a couple of minutes until completion.  Performance sucks
during this, but X is still usable (although switching windows is slow),
vmstat 1" in an xterm didn't miss a tick, and all the swapped-out
applications swapped back within a couple of seconds after the test was
complete.


Please test and comment.  Note that I'll be mostly offline until the new
year, so don't expect me to test it too much more until then.  However,
this VM is mostly equivalent to the one in ac11, except without the
messy borrow percentage rules and with the extra shrink_mmap for
foreground page stealing in do_try_to_free_page.


--Stephen


--JicA824Y4A
Content-Type: text/plain
Content-Description: Clustered pagin/balancing patch to 2.1.132-pre2
Content-Disposition: inline;
	filename="pagin-clusters.132-pre2.v2.diff"
Content-Transfer-Encoding: 7bit

--- fs/proc/array.c.~1~	Sat Dec 19 00:44:22 1998
+++ fs/proc/array.c	Sat Dec 19 14:40:16 1998
@@ -60,6 +60,7 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
+#include <linux/swapctl.h>
 #include <linux/io_trace.h>
 #include <linux/slab.h>
 #include <linux/smp.h>
@@ -415,6 +416,28 @@
 		i.freeswap >> 10);
 }
 
+static int get_swapstats(char * buffer)
+{
+	unsigned long *w = swapstats.kswap_wakeups;
+	
+	return sprintf(buffer,
+		       "ProcFreeTry:    %8lu\n"
+		       "ProcFreeSucc:   %8lu\n"
+		       "ProcShrinkTry:  %8lu\n"
+		       "ProcShrinkSucc: %8lu\n"
+		       "KswapFreeTry:   %8lu\n"
+		       "KswapFreeSucc:  %8lu\n"
+		       "KswapWakeups:	%8lu %lu %lu %lu\n",
+		       swapstats.gfp_freepage_attempts,
+		       swapstats.gfp_freepage_successes,
+		       swapstats.gfp_shrink_attempts,
+		       swapstats.gfp_shrink_successes,
+		       swapstats.kswap_freepage_attempts,
+		       swapstats.kswap_freepage_successes,
+		       w[0], w[1], w[2], w[3]
+		       );
+}
+
 static int get_version(char * buffer)
 {
 	extern char *linux_banner;
@@ -1301,6 +1324,9 @@
 		case PROC_MEMINFO:
 			return get_meminfo(page);
 
+		case PROC_SWAPSTATS:
+			return get_swapstats(page);
+
 #ifdef CONFIG_PCI_OLD_PROC
   	        case PROC_PCI:
 			return get_pci_list(page);
@@ -1386,7 +1412,7 @@
 static int process_unauthorized(int type, int pid)
 {
 	struct task_struct *p;
-	uid_t euid;	/* Save the euid keep the lock short */
+	uid_t euid=0;	/* Save the euid keep the lock short */
 		
 	read_lock(&tasklist_lock);
 	
--- fs/proc/root.c.~1~	Sat Dec 19 00:44:22 1998
+++ fs/proc/root.c	Sat Dec 19 13:10:27 1998
@@ -494,6 +494,11 @@
 	S_IFREG | S_IRUGO, 1, 0, 0,
 	0, &proc_array_inode_operations
 };
+static struct proc_dir_entry proc_root_swapstats = {
+	PROC_SWAPSTATS, 9, "swapstats",
+	S_IFREG | S_IRUGO, 1, 0, 0,
+	0, &proc_array_inode_operations
+};
 static struct proc_dir_entry proc_root_kmsg = {
 	PROC_KMSG, 4, "kmsg",
 	S_IFREG | S_IRUSR, 1, 0, 0,
@@ -654,6 +659,7 @@
 	proc_register(&proc_root, &proc_root_loadavg);
 	proc_register(&proc_root, &proc_root_uptime);
 	proc_register(&proc_root, &proc_root_meminfo);
+	proc_register(&proc_root, &proc_root_swapstats);
 	proc_register(&proc_root, &proc_root_kmsg);
 	proc_register(&proc_root, &proc_root_version);
 	proc_register(&proc_root, &proc_root_cpuinfo);
--- include/linux/mm.h.~1~	Fri Nov 27 12:36:29 1998
+++ include/linux/mm.h	Sat Dec 19 15:05:14 1998
@@ -11,6 +11,7 @@
 extern unsigned long max_mapnr;
 extern unsigned long num_physpages;
 extern void * high_memory;
+extern int page_cluster;
 
 #include <asm/page.h>
 #include <asm/atomic.h>
--- include/linux/proc_fs.h.~1~	Sat Dec 19 00:55:10 1998
+++ include/linux/proc_fs.h	Sat Dec 19 15:20:25 1998
@@ -53,7 +53,8 @@
 	PROC_STRAM,
 	PROC_SOUND,
 	PROC_MTRR, /* whether enabled or not */
-	PROC_FS
+	PROC_FS,
+	PROC_SWAPSTATS
 };
 
 enum pid_directory_inos {
--- include/linux/swap.h.~1~	Sat Dec 19 00:42:54 1998
+++ include/linux/swap.h	Sat Dec 19 13:57:47 1998
@@ -61,6 +61,15 @@
 extern unsigned long page_cache_size;
 extern int buffermem;
 
+struct swap_stats 
+{
+	long	proc_freepage_attempts;
+	long	proc_freepage_successes;
+	long	kswap_freepage_attempts;
+	long	kswap_freepage_successes;
+};
+extern struct swap_stats swap_stats;
+
 /* Incomplete types for prototype declarations: */
 struct task_struct;
 struct vm_area_struct;
@@ -69,8 +78,12 @@
 /* linux/ipc/shm.c */
 extern int shm_swap (int, int);
 
+/* linux/mm/swap.c */
+extern void swap_setup (void);
+
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(unsigned int gfp_mask, int count);
+extern void try_to_shrink_cache(int);
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, unsigned long, char *, int);
@@ -87,6 +100,7 @@
 extern int add_to_swap_cache(struct page *, unsigned long);
 extern int swap_duplicate(unsigned long);
 extern int swap_check_entry(unsigned long);
+struct page * lookup_swap_cache(unsigned long);
 extern struct page * read_swap_cache_async(unsigned long, int);
 #define read_swap_cache(entry) read_swap_cache_async(entry, 1);
 extern int FASTCALL(swap_count(unsigned long));
--- include/linux/swapctl.h~	Sat Dec 19 00:55:55 1998
+++ include/linux/swapctl.h	Sat Dec 19 16:19:20 1998
@@ -22,11 +22,19 @@
 
 typedef struct swapstat_v1
 {
-	unsigned int	wakeups;
-	unsigned int	pages_reclaimed;
-	unsigned int	pages_shm;
-	unsigned int	pages_mmap;
-	unsigned int	pages_swap;
+	unsigned long	wakeups;
+	unsigned long	pages_reclaimed;
+	unsigned long	pages_shm;
+	unsigned long	pages_mmap;
+	unsigned long	pages_swap;
+
+	unsigned long	gfp_freepage_attempts;
+	unsigned long	gfp_freepage_successes;
+	unsigned long	gfp_shrink_attempts;
+	unsigned long	gfp_shrink_successes;
+	unsigned long	kswap_freepage_attempts;
+	unsigned long	kswap_freepage_successes;
+	unsigned long	kswap_wakeups[4];
 } swapstat_v1;
 typedef swapstat_v1 swapstat_t;
 extern swapstat_t swapstats;
--- include/linux/sysctl.h.~1~	Sat Dec 19 00:44:22 1998
+++ include/linux/sysctl.h	Sat Dec 19 00:45:09 1998
@@ -103,7 +103,8 @@
 	VM_BUFFERMEM=6,		/* struct: Set buffer memory thresholds */
 	VM_PAGECACHE=7,		/* struct: Set cache memory thresholds */
 	VM_PAGERDAEMON=8,	/* struct: Control kswapd behaviour */
-	VM_PGT_CACHE=9		/* struct: Set page table cache parameters */
+	VM_PGT_CACHE=9,		/* struct: Set page table cache parameters */
+	VM_PAGE_CLUSTER=10	/* int: set number of pages to swap together */
 };
 
 
--- kernel/sysctl.c.~1~	Fri Nov 27 12:36:42 1998
+++ kernel/sysctl.c	Sat Dec 19 00:45:09 1998
@@ -216,6 +216,8 @@
 	 &pager_daemon, sizeof(pager_daemon_t), 0644, NULL, &proc_dointvec},
 	{VM_PGT_CACHE, "pagetable_cache", 
 	 &pgt_cache_water, 2*sizeof(int), 0600, NULL, &proc_dointvec},
+	{VM_PAGE_CLUSTER, "page-cluster", 
+	 &page_cluster, sizeof(int), 0600, NULL, &proc_dointvec},
 	{0}
 };
 
--- mm/filemap.c.~1~	Sat Dec 19 00:43:23 1998
+++ mm/filemap.c	Sat Dec 19 13:37:37 1998
@@ -200,7 +200,11 @@
 	struct page * page;
 	int count;
 
+#if 0
 	count = (limit<<1) >> (priority);
+#else
+	count = (limit<<2) >> (priority);
+#endif
 
 	page = mem_map + clock;
 	do {
@@ -212,13 +216,26 @@
 		
 		if (shrink_one_page(page, gfp_mask))
 			return 1;
+		/* 
+		 * If the page we looked at was recyclable but we didn't
+		 * reclaim it (presumably due to PG_referenced), don't
+		 * count it as scanned.  This way, the more referenced
+		 * page cache pages we encounter, the more rapidly we
+		 * will age them. 
+		 */
+
+#if 1
+		if (atomic_read(&page->count) != 1 ||
+		    (!page->inode && !page->buffers))
+#endif
+			count--;
 		page++;
 		clock++;
 		if (clock >= max_mapnr) {
 			clock = 0;
 			page = mem_map;
 		}
-	} while (--count >= 0);
+	} while (count >= 0);
 	return 0;
 }
 
@@ -962,7 +979,7 @@
 	struct file * file = area->vm_file;
 	struct dentry * dentry = file->f_dentry;
 	struct inode * inode = dentry->d_inode;
-	unsigned long offset;
+	unsigned long offset, reada, i;
 	struct page * page, **hash;
 	unsigned long old_page, new_page;
 
@@ -1023,7 +1040,19 @@
 	return new_page;
 
 no_cached_page:
-	new_page = __get_free_page(GFP_USER);
+	/*
+	 * Try to read in an entire cluster at once.
+	 */
+	reada   = offset;
+	reada >>= PAGE_SHIFT;
+	reada   = (reada / page_cluster) * page_cluster;
+	reada <<= PAGE_SHIFT;
+
+	for (i=0; i<page_cluster; i++, reada += PAGE_SIZE)
+		new_page = try_to_read_ahead(file, reada, new_page);
+
+	if (!new_page)
+		new_page = __get_free_page(GFP_USER);
 	if (!new_page)
 		goto no_page;
 
@@ -1047,11 +1076,6 @@
 	if (inode->i_op->readpage(file, page) != 0)
 		goto failure;
 
-	/*
-	 * Do a very limited read-ahead if appropriate
-	 */
-	if (PageLocked(page))
-		new_page = try_to_read_ahead(file, offset + PAGE_SIZE, 0);
 	goto found_page;
 
 page_locked_wait:
@@ -1625,7 +1649,7 @@
 	if (!page) {
 		if (!new)
 			goto out;
-		page_cache = get_free_page(GFP_KERNEL);
+		page_cache = get_free_page(GFP_USER);
 		if (!page_cache)
 			goto out;
 		page = mem_map + MAP_NR(page_cache);
--- mm/page_alloc.c.~1~	Fri Nov 27 12:36:42 1998
+++ mm/page_alloc.c	Sat Dec 19 15:14:23 1998
@@ -241,7 +241,17 @@
 			goto nopage;
 		}
 
-		if (freepages.min > nr_free_pages) {
+		/* Try this if you want, but it seems to result in too
+		 * much IO activity during builds, and does not
+		 * substantially reduce the number of times we invoke
+		 * kswapd.  --sct */
+#if 0
+		if (nr_free_pages < freepages.high &&
+		    !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
+			try_to_shrink_cache(gfp_mask);
+#endif
+						
+		if (nr_free_pages < freepages.min) {
 			int freed;
 			freed = try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX);
 			/*
@@ -359,6 +369,37 @@
 	return start_mem;
 }
 
+/* 
+ * Primitive swap readahead code. We simply read an aligned block of
+ * (page_cluster) entries in the swap area. This method is chosen
+ * because it doesn't cost us any seek time.  We also make sure to queue
+ * the 'original' request together with the readahead ones...  
+ */
+void swapin_readahead(unsigned long entry) {
+        int i;
+        struct page *new_page;
+	unsigned long offset = SWP_OFFSET(entry);
+	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
+	
+	offset = (offset/page_cluster) * page_cluster;
+	
+	for (i = 0; i < page_cluster; i++) {
+	      if (offset >= swapdev->max
+		              || nr_free_pages - atomic_read(&nr_async_pages) <
+			      (freepages.high + freepages.low)/2)
+		      return;
+	      if (!swapdev->swap_map[offset] ||
+		  swapdev->swap_map[offset] == SWAP_MAP_BAD ||
+		  test_bit(offset, swapdev->swap_lockmap))
+		      continue;
+	      new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
+	      if (new_page != NULL)
+                      __free_page(new_page);
+	      offset++;
+	}
+	return;
+}
+
 /*
  * The tests may look silly, but it essentially makes sure that
  * no other process did a swap-in on us just as we were waiting.
@@ -370,10 +411,12 @@
 	pte_t * page_table, unsigned long entry, int write_access)
 {
 	unsigned long page;
-	struct page *page_map;
-	
-	page_map = read_swap_cache(entry);
+	struct page *page_map = lookup_swap_cache(entry);
 
+	if (!page_map) {
+                swapin_readahead(entry);
+		page_map = read_swap_cache(entry);
+	}
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
 			free_page_and_swap_cache(page_address(page_map));
--- mm/page_io.c.~1~	Fri Nov 27 12:36:42 1998
+++ mm/page_io.c	Sat Dec 19 00:45:09 1998
@@ -60,7 +60,7 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
 		wait = 1;
 
 	p = &swap_info[type];
--- mm/swap.c.~1~	Sat Dec 19 00:42:55 1998
+++ mm/swap.c	Sat Dec 19 12:49:51 1998
@@ -39,6 +39,9 @@
 	144	/* freepages.high */
 };
 
+/* How many pages do we try to swap or page in/out together? */
+int page_cluster = 16; /* Default value modified in swap_setup() */
+
 /* We track the number of pages currently being asynchronously swapped
    out, so that we don't try to swap TOO many pages out at once */
 atomic_t nr_async_pages = ATOMIC_INIT(0);
@@ -61,13 +64,13 @@
 swapstat_t swapstats = {0};
 
 buffer_mem_t buffer_mem = {
-	5,	/* minimum percent buffer */
+	1,	/* minimum percent buffer */
 	10,	/* borrow percent buffer */
 	60	/* maximum percent buffer */
 };
 
 buffer_mem_t page_cache = {
-	5,	/* minimum percent page cache */
+	1,	/* minimum percent page cache */
 	15,	/* borrow percent page cache */
 	75	/* maximum */
 };
@@ -77,3 +80,19 @@
 	SWAP_CLUSTER_MAX,	/* minimum number of tries */
 	SWAP_CLUSTER_MAX,	/* do swap I/O in clusters of this size */
 };
+
+
+/*
+ * Perform any setup for the swap system
+ */
+
+void __init swap_setup(void)
+{
+	/* Use a smaller cluster for memory <16MB or <32MB */
+	if (num_physpages < ((16 * 1024 * 1024) >> PAGE_SHIFT))
+		page_cluster = 4;
+	else if (num_physpages < ((32 * 1024 * 1024) >> PAGE_SHIFT))
+		page_cluster = 8;
+	else
+		page_cluster = 16;
+}
--- mm/swap_state.c.~1~	Fri Nov 27 12:36:42 1998
+++ mm/swap_state.c	Sat Dec 19 13:35:07 1998
@@ -258,7 +258,7 @@
  * incremented.
  */
 
-static struct page * lookup_swap_cache(unsigned long entry)
+struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
 	
@@ -305,7 +305,7 @@
 	if (found_page)
 		goto out;
 
-	new_page_addr = __get_free_page(GFP_KERNEL);
+	new_page_addr = __get_free_page(GFP_USER);
 	if (!new_page_addr)
 		goto out;	/* Out of memory */
 	new_page = mem_map + MAP_NR(new_page_addr);
--- mm/vmscan.c.~1~	Sat Dec 19 00:43:24 1998
+++ mm/vmscan.c	Sat Dec 19 14:58:49 1998
@@ -25,6 +25,11 @@
  */
 static struct task_struct * kswapd_task = NULL;
 
+/*
+ * Flag to start low-priorty background kswapping
+ */
+static int kswap_default_wakeup;
+
 static void init_swap_timer(void);
 
 /*
@@ -424,21 +429,36 @@
  */
 static int do_try_to_free_page(int gfp_mask)
 {
+	static int state = 0;
 	int i=6;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
-
-	do {
-		if (shrink_mmap(i, gfp_mask))
-			return 1;
-		if (shm_swap(i, gfp_mask))
-			return 1;
-		if (swap_out(i, gfp_mask))
+	
+	if (current != kswapd_task)
+		if (shrink_mmap(6, gfp_mask))
 			return 1;
-		shrink_dcache_memory(i, gfp_mask);
+
+	switch (state) {
+		do {
+		case 0:
+			if (shrink_mmap(i, gfp_mask))
+				return 1;
+			state = 1;
+		case 1:
+			if (shm_swap(i, gfp_mask))
+				return 1;
+			state = 2;
+		case 2:
+			if (swap_out(i, gfp_mask))
+				return 1;
+			state = 3;
+		case 3:
+			shrink_dcache_memory(i, gfp_mask);
+			state = 0;
 		i--;
-	} while (i >= 0);
+		} while (i >= 0);
+	}
 	return 0;
 }
 
@@ -453,6 +473,8 @@
        int i;
        char *revision="$Revision: 1.5 $", *s, *e;
 
+       swap_setup();
+       
        if ((s = strchr(revision, ':')) &&
            (e = strchr(s, '$')))
                s++, i = e - s;
@@ -514,9 +536,11 @@
 		/* max one hundreth of a second */
 		end_time = jiffies + (HZ-1)/100;
 		do {
+			swapstats.kswap_freepage_attempts++;
 			if (!do_try_to_free_page(0))
 				break;
-			if (nr_free_pages > freepages.high + SWAP_CLUSTER_MAX)
+			swapstats.kswap_freepage_successes++;
+			if (nr_free_pages > freepages.high + pager_daemon.swap_cluster)
 				break;
 		} while (time_before_eq(jiffies,end_time));
 	}
@@ -544,9 +568,11 @@
 	if (!(current->flags & PF_MEMALLOC)) {
 		current->flags |= PF_MEMALLOC;
 		do {
+			swapstats.gfp_freepage_attempts++;
 			retval = do_try_to_free_page(gfp_mask);
 			if (!retval)
 				break;
+			swapstats.gfp_freepage_successes++;
 			count--;
 		} while (count > 0);
 		current->flags &= ~PF_MEMALLOC;
@@ -556,6 +582,24 @@
 }
 
 /*
+ * Try to shrink the page cache slightly, on low-priority memory
+ * allocation.  If this fails, it's a hint that maybe kswapd might want
+ * to start doing something useful.
+ */
+void try_to_shrink_cache(int gfp_mask)
+{
+	int i;
+	for (i = 0; i < 16; i++) {
+		swapstats.gfp_shrink_attempts++;
+		if (shrink_mmap(6, gfp_mask))
+			swapstats.gfp_shrink_successes++;
+		else
+			kswap_default_wakeup = 1;
+	}
+}
+
+
+/*
  * Wake up kswapd according to the priority
  *	0 - no wakeup
  *	1 - wake up as a low-priority process
@@ -598,15 +642,22 @@
 		 * that we'd better give kswapd a realtime
 		 * priority.
 		 */
+
 		want_wakeup = 0;
 		pages = nr_free_pages;
 		if (pages < freepages.high)
-			want_wakeup = 1;
-		if (pages < freepages.low)
+			want_wakeup = kswap_default_wakeup;
+		if (pages < freepages.low) {
 			want_wakeup = 2;
+			kswap_default_wakeup = 1;
+		}
 		if (pages < freepages.min)
 			want_wakeup = 3;
-	
+
+		/* If you increase the maximum want_wakeup, expand the
+                   swapstats.kswap_wakeups[] table in swapctl.h */
+		swapstats.kswap_wakeups[want_wakeup]++;
+
 		kswapd_wakeup(p,want_wakeup);
 	}
 

--JicA824Y4A--
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
