Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA18729
	for <linux-mm@kvack.org>; Thu, 10 Dec 1998 14:22:45 -0500
Date: Thu, 10 Dec 1998 19:22:30 GMT
Message-Id: <199812101922.TAA17817@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Tiny one-line fix to swap readahead
In-Reply-To: <199812082259.WAA00875@dax.scot.redhat.com>
References: <199812082259.WAA00875@dax.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <number6@the-village.bc.nu>, linux-mm@kvack.org, Rik van Riel <H.H.vanRiel@fys.ruu.nl>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 8 Dec 1998 22:59:09 GMT, "Stephen C. Tweedie" <sct@redhat.com>
said:

> I just noticed this when experimenting with a slightly different swapin
> optimisation: swapping in entire 64k aligned blocks rather than doing
> strict readahead.  

Right, that optimisation now seems to be running happily, including
aligned pagein of mmap()ed regions as well as aligned cluster swapin.
The patch below is against 2.1.131-ac7.  The principle behind swapping
in aligned clusters is that we can rapidly page in entire large blocks
of a vm without having to worry about small holes between the regions we
read in when we are doing random access reads.

Performance is *markedly* improved, even against ac7, which was itself
the fastest vm I have ever benchmarked.  4MB boots comfortably.  8MB
compiles defrag over NFS in under four minutes: ac7 took 4:30 and even
2.0 took over 5 minutes.  Application startup is improved across the
board and even in 64MB, switching between X desktops is much faster than
before.

The default pagein cluster size is 16k (4 pages) for 16MB memory or
less; 32k for 32MB or less; otherwise 64MB.  This is tunable via
/proc/sys/vm/swap_cluster. 

This patch also includes the swap readahead bugfix to avoid touching
SWAP_MAP_BAD swap pages.

Enjoy,
  Stephen.

----------------------------------------------------------------
--- include/linux/mm.h.~1~	Thu Dec 10 16:38:41 1998
+++ include/linux/mm.h	Thu Dec 10 16:47:17 1998
@@ -11,6 +11,7 @@
 extern unsigned long max_mapnr;
 extern unsigned long num_physpages;
 extern void * high_memory;
+extern int swap_cluster;
 
 #include <asm/page.h>
 #include <asm/atomic.h>
--- include/linux/swap.h.~1~	Thu Dec 10 16:38:42 1998
+++ include/linux/swap.h	Thu Dec 10 16:47:25 1998
@@ -69,6 +69,9 @@
 /* linux/ipc/shm.c */
 extern int shm_swap (int, int);
 
+/* linux/mm/swap.c */
+extern void swap_setup (void);
+
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(unsigned int gfp_mask, int count);
 
--- include/linux/sysctl.h.~1~	Thu Dec 10 16:38:42 1998
+++ include/linux/sysctl.h	Thu Dec 10 16:43:29 1998
@@ -111,7 +111,8 @@
 	VM_BUFFERMEM=6,		/* struct: Set buffer memory thresholds */
 	VM_PAGECACHE=7,		/* struct: Set cache memory thresholds */
 	VM_PAGERDAEMON=8,	/* struct: Control kswapd behaviour */
-	VM_PGT_CACHE=9		/* struct: Set page table cache parameters */
+	VM_PGT_CACHE=9,		/* struct: Set page table cache parameters */
+	VM_SWAP_CLUSTER=10	/* int: set number of pages to swap together */
 };
 
 
--- kernel/sysctl.c.~1~	Thu Dec 10 16:38:43 1998
+++ kernel/sysctl.c	Thu Dec 10 17:04:19 1998
@@ -242,6 +242,8 @@
 	 &pager_daemon, sizeof(pager_daemon_t), 0644, NULL, &proc_dointvec},
 	{VM_PGT_CACHE, "pagetable_cache", 
 	 &pgt_cache_water, 2*sizeof(int), 0600, NULL, &proc_dointvec},
+	{VM_SWAP_CLUSTER, "swap_cluster", 
+	 &swap_cluster, sizeof(int), 0600, NULL, &proc_dointvec},
 	{0}
 };
 
--- mm/filemap.c.~1~	Thu Dec 10 16:38:10 1998
+++ mm/filemap.c	Thu Dec 10 16:43:29 1998
@@ -231,6 +231,7 @@
 			page = mem_map;
 		}
 	} while (count_max > 0 && count_min > 0);
+	schedule();
 	return 0;
 }
 
@@ -974,7 +975,7 @@
 	struct file * file = area->vm_file;
 	struct dentry * dentry = file->f_dentry;
 	struct inode * inode = dentry->d_inode;
-	unsigned long offset;
+	unsigned long offset, reada, i;
 	struct page * page, **hash;
 	unsigned long old_page, new_page;
 
@@ -1035,7 +1036,19 @@
 	return new_page;
 
 no_cached_page:
-	new_page = __get_free_page(GFP_USER);
+	/*
+	 * Try to read in an entire cluster at once.
+	 */
+	reada   = offset;
+	reada >>= PAGE_SHIFT;
+	reada   = (reada / swap_cluster) * swap_cluster;
+	reada <<= PAGE_SHIFT;
+
+	for (i=0; i<swap_cluster; i++, reada += PAGE_SIZE)
+		new_page = try_to_read_ahead(file, reada, new_page);
+
+	if (!new_page)
+		new_page = __get_free_page(GFP_USER);
 	if (!new_page)
 		goto no_page;
 
@@ -1059,11 +1072,6 @@
 	if (inode->i_op->readpage(file, page) != 0)
 		goto failure;
 
-	/*
-	 * Do a very limited read-ahead if appropriate
-	 */
-	if (PageLocked(page))
-		new_page = try_to_read_ahead(file, offset + PAGE_SIZE, 0);
 	goto found_page;
 
 page_locked_wait:
--- mm/page_alloc.c.~1~	Thu Dec 10 16:38:43 1998
+++ mm/page_alloc.c	Thu Dec 10 16:44:51 1998
@@ -359,27 +359,28 @@
 	return start_mem;
 }
 
-/*
- * Primitive swap readahead code. We simply read the
- * next 8 entries in the swap area. This method is
- * chosen because it doesn't cost us any seek time.
- * We also make sure to queue the 'original' request
- * together with the readahead ones...
+/* 
+ * Primitive swap readahead code. We simply read an aligned block of
+ * (swap_cluster) entries in the swap area. This method is chosen
+ * because it doesn't cost us any seek time.  We also make sure to queue
+ * the 'original' request together with the readahead ones...  
  */
 void swapin_readahead(unsigned long entry) {
         int i;
         struct page *new_page;
 	unsigned long offset = SWP_OFFSET(entry);
 	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
-
-	for (i = 0; i < 8; i++) {
+	
+	offset = (offset/swap_cluster) * swap_cluster;
+	
+	for (i = 0; i < swap_cluster; i++) {
 	      if (offset >= swapdev->max
 		              || nr_free_pages - atomic_read(&nr_async_pages) <
 			      (freepages.high + freepages.low)/2)
 		      return;
 	      if (!swapdev->swap_map[offset] ||
 		  swapdev->swap_map[offset] == SWAP_MAP_BAD ||
-                  test_bit(offset, swapdev->swap_lockmap))
+		  test_bit(offset, swapdev->swap_lockmap))
 		      continue;
 	      new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
 	      if (new_page != NULL)
--- mm/swap.c.~1~	Thu Dec 10 16:38:43 1998
+++ mm/swap.c	Thu Dec 10 16:44:09 1998
@@ -39,6 +39,9 @@
 	144	/* freepages.high */
 };
 
+/* How many pages do we try to swap or page in/out together? */
+int swap_cluster = 16; /* Default value modified in swap_setup() */
+
 /* We track the number of pages currently being asynchronously swapped
    out, so that we don't try to swap TOO many pages out at once */
 atomic_t nr_async_pages = ATOMIC_INIT(0);
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
+		swap_cluster = 4;
+	else if (num_physpages < ((32 * 1024 * 1024) >> PAGE_SHIFT))
+		swap_cluster = 8;
+	else
+		swap_cluster = 16;
+}
--- mm/vmscan.c.~1~	Thu Dec 10 16:38:43 1998
+++ mm/vmscan.c	Thu Dec 10 16:43:29 1998
@@ -469,6 +469,8 @@
        int i;
        char *revision="$Revision: 1.5 $", *s, *e;
 
+       swap_setup();
+       
        if ((s = strchr(revision, ':')) &&
            (e = strchr(s, '$')))
                s++, i = e - s;
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
