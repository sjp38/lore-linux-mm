Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id CF9126B00E8
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 01:59:50 -0500 (EST)
Date: Fri, 2 Mar 2012 14:59:47 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC PATCH] mm: don't treat anonymous pages as dirtyable pages
Message-ID: <20120302065947.GA9583@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144747.523705338@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120228144747.523705338@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> 5) reset counters and stress it more.
> 
> 	# usemem 1G --sleep 1000&
> 	# free
> 		     total       used       free     shared    buffers     cached
> 	Mem:          6801       6758         42          0          0        994
> 	-/+ buffers/cache:       5764       1036
> 	Swap:        51106        235      50870
> 
> It's now obviously slow, it now takes seconds or even 10+ seconds to switch to
> the other windows:
> 
>   765.30    A System Monitor
>   769.72    A Dictionary
>   772.01    A Home
>   790.79    A Desktop Help
>   795.47    A *Unsaved Document 1 - gedit
>   813.01    A ALC888.svg  (1/11)
>   819.24    A Restore Session - Iceweasel
>   827.23    A Klondike
>   853.57    A urxvt
>   862.49    A xeyes
>   868.67    A Xpdf: /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
>   869.47    A snb:/home/wfg - ZSH
> 
> And it seems that the slowness is caused by huge number of pageout()s:
> 
> /debug/vm/nr_reclaim_throttle_clean:0
> /debug/vm/nr_reclaim_throttle_kswapd:0
> /debug/vm/nr_reclaim_throttle_recent_write:0
> /debug/vm/nr_reclaim_throttle_write:307
> /debug/vm/nr_congestion_wait:0
> /debug/vm/nr_reclaim_wait_congested:0
> /debug/vm/nr_reclaim_wait_writeback:0
> /debug/vm/nr_migrate_wait_writeback:0
> nr_vmscan_write 175085
> allocstall 669671

The heavy swapping is a big problem. This patch is found to
effectively eliminate it :-)

---
Subject: mm: don't treat anonymous pages as dirtyable pages

Assume a mem=1GB desktop (swap enabled) with 800MB anonymous pages and
200MB file pages.  When the user starts a heavy dirtier task, the file
LRU lists may be mostly filled with dirty pages since the global dirty
limit is calculated as

	(anon+file) * 20% = 1GB * 20% = 200MB

This makes the file LRU lists hard to reclaim, which in turn increases
the scan rate of the anon LRU lists and lead to a lot of swapping. This
is probably one big reason why some desktop users see bad responsiveness
during heavy file copies once the swap is enabled.

The heavy swapping could mostly be avoided by calculating the global
dirty limit as

	file * 20% = 200MB * 20% = 40MB

The side effect would be that users feel longer file copy time because
the copy task is throttled earlier than before. However typical users
should be much more sensible to interactive performance rather than the
copy task which may well be leaved in the background.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/vmstat.h |    1 -
 mm/page-writeback.c    |   10 ++++++----
 mm/vmscan.c            |   14 --------------
 3 files changed, 6 insertions(+), 19 deletions(-)

--- linux.orig/include/linux/vmstat.h	2012-03-02 13:55:28.569749568 +0800
+++ linux/include/linux/vmstat.h	2012-03-02 13:56:06.585750471 +0800
@@ -139,7 +139,6 @@ static inline unsigned long zone_page_st
 	return x;
 }
 
-extern unsigned long global_reclaimable_pages(void);
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
 
 #ifdef CONFIG_NUMA
--- linux.orig/mm/page-writeback.c	2012-03-02 13:55:28.549749567 +0800
+++ linux/mm/page-writeback.c	2012-03-02 13:56:26.257750938 +0800
@@ -181,8 +181,7 @@ static unsigned long highmem_dirtyable_m
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
-		x += zone_page_state(z, NR_FREE_PAGES) +
-		     zone_reclaimable_pages(z) - z->dirty_balance_reserve;
+		x += zone_dirtyable_memory(z);
 	}
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -206,7 +205,9 @@ unsigned long global_dirtyable_memory(vo
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages() -
+	x = global_page_state(NR_FREE_PAGES) +
+	    global_page_state(NR_ACTIVE_FILE) +
+	    global_page_state(NR_INACTIVE_FILE) -
 	    dirty_balance_reserve;
 
 	if (!vm_highmem_is_dirtyable)
@@ -275,7 +276,8 @@ unsigned long zone_dirtyable_memory(stru
 	 * care about vm_highmem_is_dirtyable here.
 	 */
 	return zone_page_state(zone, NR_FREE_PAGES) +
-	       zone_reclaimable_pages(zone) -
+	       zone_page_state(zone, NR_ACTIVE_FILE) +
+	       zone_page_state(zone, NR_INACTIVE_FILE) -
 	       zone->dirty_balance_reserve;
 }
 
--- linux.orig/mm/vmscan.c	2012-03-02 13:55:28.561749567 +0800
+++ linux/mm/vmscan.c	2012-03-02 13:56:06.585750471 +0800
@@ -3315,20 +3315,6 @@ void wakeup_kswapd(struct zone *zone, in
  * - mapped pages, which may require several travels to be reclaimed
  * - dirty pages, which is not "instantly" reclaimable
  */
-unsigned long global_reclaimable_pages(void)
-{
-	int nr;
-
-	nr = global_page_state(NR_ACTIVE_FILE) +
-	     global_page_state(NR_INACTIVE_FILE);
-
-	if (nr_swap_pages > 0)
-		nr += global_page_state(NR_ACTIVE_ANON) +
-		      global_page_state(NR_INACTIVE_ANON);
-
-	return nr;
-}
-
 unsigned long zone_reclaimable_pages(struct zone *zone)
 {
 	int nr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
