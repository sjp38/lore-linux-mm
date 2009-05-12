Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F10936B0098
	for <linux-mm@kvack.org>; Tue, 12 May 2009 12:55:01 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 474C382CD9C
	for <linux-mm@kvack.org>; Tue, 12 May 2009 13:08:25 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Hjzi8iWuhkdB for <linux-mm@kvack.org>;
	Tue, 12 May 2009 13:08:25 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 349E182CDD7
	for <linux-mm@kvack.org>; Tue, 12 May 2009 13:08:17 -0400 (EDT)
Date: Tue, 12 May 2009 16:54:21 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
In-Reply-To: <20090512120002.D616.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905121650090.14226@qirst.com>
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025246.GC7518@localhost> <20090512120002.D616.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

All these expiration modifications do not take into account that a desktop
may sit idle for hours while some other things run in the background (like
backups at night or updatedb and other maintenance things). This still
means that the desktop will be usuable in the morning.

I have had some success with a patch that protects a pages in the file
cache from being unmapped if the mapped pages are below a certain
percentage of the file cache. Its another VM knob to define the percentage
though.


Subject: Do not evict mapped pages

It is quite annoying when important executable pages of the user interface
are evicted from memory because backup or some other function runs and no one
is clicking any buttons for awhile. Once you get back to the desktop and
try to click a link one is in for a surprise. It can take quite a long time
for the desktop to recover from the swap outs.

This patch ensures that mapped pages in the file cache are not evicted if there
are a sufficient number of unmapped pages present. A similar technique is
already in use under NUMA for zone reclaim. The same method can be used to
protect mapped pages from reclaim.

The percentage of file backed pages protected is set via
/proc/sys/vm/file_mapped_ratio. This defaults to 20%.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 Documentation/sysctl/vm.txt |   14 ++++++++++++++
 include/linux/swap.h        |    1 +
 kernel/sysctl.c             |   13 ++++++++++++-
 mm/vmscan.c                 |   32 ++++++++++++++++++++++++++++----
 4 files changed, 55 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2009-05-11 21:37:15.397876418 -0500
+++ linux-2.6/mm/vmscan.c	2009-05-11 21:37:23.287875742 -0500
@@ -585,7 +585,8 @@ void putback_lru_page(struct page *page)
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
-					enum pageout_io sync_writeback)
+					enum pageout_io sync_writeback,
+					int unmap_mapped)
 {
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
@@ -616,7 +617,7 @@ static unsigned long shrink_page_list(st
 		if (unlikely(!page_evictable(page, NULL)))
 			goto cull_mlocked;

-		if (!sc->may_unmap && page_mapped(page))
+		if (!unmap_mapped && page_mapped(page))
 			goto keep_locked;

 		/* Double the slab pressure for mapped and swapcache pages */
@@ -1047,6 +1048,12 @@ int isolate_lru_page(struct page *page)
 }

 /*
+ * Percentage of pages of the file lru necessary for unmapping of
+ * pages to occur during reclaim.
+ */
+int sysctl_file_unmap_ratio = 20;
+
+/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
@@ -1059,10 +1066,26 @@ static unsigned long shrink_inactive_lis
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	int unmap_mapped = 0;

 	pagevec_init(&pvec, 1);

 	lru_add_drain();
+
+	/*
+	 * Only allow unmapping of file backed pages if the amount of file
+	 * mapped page becomes greater than a certain percentage of the file
+	 * lru (+ free memory in order to avoid useless unmaps before memory
+	 * fills up).
+	 */
+	if (sc->may_unmap && (!file ||
+		zone_page_state(zone, NR_FILE_MAPPED) * 100 >
+			(zone_page_state(zone, NR_FREE_PAGES) +
+			zone_page_state(zone, NR_ACTIVE_FILE) +
+			zone_page_state(zone, NR_INACTIVE_FILE))
+				* sysctl_file_unmap_ratio))
+					unmap_mapped = 1;
+
 	spin_lock_irq(&zone->lru_lock);
 	do {
 		struct page *page;
@@ -1111,7 +1134,8 @@ static unsigned long shrink_inactive_lis
 		spin_unlock_irq(&zone->lru_lock);

 		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
+									unmap_mapped);

 		/*
 		 * If we are direct reclaiming for contiguous pages and we do
@@ -1131,7 +1155,7 @@ static unsigned long shrink_inactive_lis
 			count_vm_events(PGDEACTIVATE, nr_active);

 			nr_freed += shrink_page_list(&page_list, sc,
-							PAGEOUT_IO_SYNC);
+						PAGEOUT_IO_SYNC, unmap_mapped);
 		}

 		nr_reclaimed += nr_freed;
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h	2009-05-11 21:37:15.417879047 -0500
+++ linux-2.6/include/linux/swap.h	2009-05-11 21:37:23.287875742 -0500
@@ -221,6 +221,7 @@ extern unsigned long shrink_all_memory(u
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern long vm_total_pages;
+extern int sysctl_file_unmap_ratio;

 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c	2009-05-11 21:37:15.467877848 -0500
+++ linux-2.6/kernel/sysctl.c	2009-05-11 21:37:23.307877270 -0500
@@ -92,7 +92,6 @@ extern int rcutorture_runnable;

 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_DETECT_SOFTLOCKUP
-static int sixty = 60;
 static int neg_one = -1;
 #endif

@@ -100,6 +99,7 @@ static int zero;
 static int __maybe_unused one = 1;
 static int __maybe_unused two = 2;
 static unsigned long one_ul = 1;
+static int sixty = 60;
 static int one_hundred = 100;
 static int one_thousand = 1000;

@@ -1141,6 +1141,17 @@ static struct ctl_table vm_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &min_percpu_pagelist_fract,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "file_mapped_ratio",
+		.data		= &sysctl_file_unmap_ratio,
+		.maxlen		= sizeof(sysctl_file_unmap_ratio),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &sixty,
+	},
 #ifdef CONFIG_MMU
 	{
 		.ctl_name	= VM_MAX_MAP_COUNT,
Index: linux-2.6/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.orig/Documentation/sysctl/vm.txt	2009-05-11 21:45:43.937878597 -0500
+++ linux-2.6/Documentation/sysctl/vm.txt	2009-05-11 21:52:57.217874275 -0500
@@ -26,6 +26,7 @@ Currently, these files are in /proc/sys/
 - dirty_ratio
 - dirty_writeback_centisecs
 - drop_caches
+- file_mapped_ratio
 - hugepages_treat_as_movable
 - hugetlb_shm_group
 - laptop_mode
@@ -140,6 +141,19 @@ user should run `sync' first.

 ==============================================================

+file_mapped_ratio
+
+A percentage of the file backed pages in memory. If there are more
+mapped pages than this percentage then reclaim will unmap pages
+from the memory of processes.
+
+The main function of this ratio is to protect pags in use
+by proceses from streaming I/O and other operations that
+put a lot of churn on the page cache and would usually evict
+most pages.
+
+==============================================================
+
 hugepages_treat_as_movable

 This parameter is only useful when kernelcore= is specified at boot time to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
