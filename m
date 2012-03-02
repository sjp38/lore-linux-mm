Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 04BD16B00EB
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 02:18:49 -0500 (EST)
Date: Fri, 2 Mar 2012 15:18:47 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH] mm: don't treat anonymous pages as dirtyable pages
Message-ID: <20120302071847.GA15654@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144747.523705338@intel.com>
 <20120302065947.GA9583@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120302065947.GA9583@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The test results:

With the below heavy memory usage and one file copy from sparse file
to USB key under way,

root@snb /home/wfg/memcg-dirty/snb# free
             total       used       free     shared    buffers     cached
Mem:          6801       6750         50          0          0        893
-/+ buffers/cache:       5857        944
Swap:        51106         34      51072

There are no single reclaim waits:

/debug/vm/nr_reclaim_throttle_clean:0
/debug/vm/nr_reclaim_throttle_kswapd:0
/debug/vm/nr_reclaim_throttle_recent_write:0
/debug/vm/nr_reclaim_throttle_write:0
/debug/vm/nr_reclaim_wait_congested:0
/debug/vm/nr_reclaim_wait_writeback:0
/debug/vm/nr_migrate_wait_writeback:0

and only occasionally increase of

        /debug/vm/nr_congestion_wait (from kswapd)
        nr_vmscan_write
        allocstall

And the most visible thing: windows switching remains swiftly fast:

 time         window title
-----------------------------------------------------------------------------
 3024.91    A LibreOffice 3.4
 3024.97    A Restore Session - Iceweasel
 3024.98    A System Settings
 3025.13    A urxvt
 3025.14    A xeyes
 3025.15    A snb:/home/wfg - ZSH
 3025.16    A snb:/home/wfg - ZSH
 3025.17    A Xpdf: /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
 3025.18    A OpenOffice.org
 3025.23    A OpenOffice.org
 3025.25    A OpenOffice.org
 3025.26    A OpenOffice.org
 3025.27    A OpenOffice.org
 3025.28    A Chess
 3025.29    A Dictionary
 3025.31    A System Monitor
 3025.35    A snb:/home/wfg - ZSH
 3025.41    A Desktop Help
 3025.43    A Mines
 3025.49    A Tetravex
 3025.54    A Iagno
 3025.55    A Four-in-a-row
 3025.60    A Mahjongg - Easy
 3025.64    A Klotski
 3025.66    A Five or More
 3025.68    A Tali
 3025.69    A Robots
 3025.71    A Klondike
 3025.79    A Home
 3025.82    A Home
 3025.86    A *Unsaved Document 1 - gedit
 3025.87    A Sudoku
 3025.93    A LibreOffice 3.4
 3025.98    A Restore Session - Iceweasel
 3025.99    A System Settings
 3026.13    A urxvt

Thanks,
Fengguang

> Assume a mem=1GB desktop (swap enabled) with 800MB anonymous pages and
> 200MB file pages.  When the user starts a heavy dirtier task, the file
> LRU lists may be mostly filled with dirty pages since the global dirty
> limit is calculated as
> 
> 	(anon+file) * 20% = 1GB * 20% = 200MB
> 
> This makes the file LRU lists hard to reclaim, which in turn increases
> the scan rate of the anon LRU lists and lead to a lot of swapping. This
> is probably one big reason why some desktop users see bad responsiveness
> during heavy file copies once the swap is enabled.
> 
> The heavy swapping could mostly be avoided by calculating the global
> dirty limit as
> 
> 	file * 20% = 200MB * 20% = 40MB
> 
> The side effect would be that users feel longer file copy time because
> the copy task is throttled earlier than before. However typical users
> should be much more sensible to interactive performance rather than the
> copy task which may well be leaved in the background.
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  include/linux/vmstat.h |    1 -
>  mm/page-writeback.c    |   10 ++++++----
>  mm/vmscan.c            |   14 --------------
>  3 files changed, 6 insertions(+), 19 deletions(-)
> 
> --- linux.orig/include/linux/vmstat.h	2012-03-02 13:55:28.569749568 +0800
> +++ linux/include/linux/vmstat.h	2012-03-02 13:56:06.585750471 +0800
> @@ -139,7 +139,6 @@ static inline unsigned long zone_page_st
>  	return x;
>  }
>  
> -extern unsigned long global_reclaimable_pages(void);
>  extern unsigned long zone_reclaimable_pages(struct zone *zone);
>  
>  #ifdef CONFIG_NUMA
> --- linux.orig/mm/page-writeback.c	2012-03-02 13:55:28.549749567 +0800
> +++ linux/mm/page-writeback.c	2012-03-02 13:56:26.257750938 +0800
> @@ -181,8 +181,7 @@ static unsigned long highmem_dirtyable_m
>  		struct zone *z =
>  			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
>  
> -		x += zone_page_state(z, NR_FREE_PAGES) +
> -		     zone_reclaimable_pages(z) - z->dirty_balance_reserve;
> +		x += zone_dirtyable_memory(z);
>  	}
>  	/*
>  	 * Make sure that the number of highmem pages is never larger
> @@ -206,7 +205,9 @@ unsigned long global_dirtyable_memory(vo
>  {
>  	unsigned long x;
>  
> -	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages() -
> +	x = global_page_state(NR_FREE_PAGES) +
> +	    global_page_state(NR_ACTIVE_FILE) +
> +	    global_page_state(NR_INACTIVE_FILE) -
>  	    dirty_balance_reserve;
>  
>  	if (!vm_highmem_is_dirtyable)
> @@ -275,7 +276,8 @@ unsigned long zone_dirtyable_memory(stru
>  	 * care about vm_highmem_is_dirtyable here.
>  	 */
>  	return zone_page_state(zone, NR_FREE_PAGES) +
> -	       zone_reclaimable_pages(zone) -
> +	       zone_page_state(zone, NR_ACTIVE_FILE) +
> +	       zone_page_state(zone, NR_INACTIVE_FILE) -
>  	       zone->dirty_balance_reserve;
>  }
>  
> --- linux.orig/mm/vmscan.c	2012-03-02 13:55:28.561749567 +0800
> +++ linux/mm/vmscan.c	2012-03-02 13:56:06.585750471 +0800
> @@ -3315,20 +3315,6 @@ void wakeup_kswapd(struct zone *zone, in
>   * - mapped pages, which may require several travels to be reclaimed
>   * - dirty pages, which is not "instantly" reclaimable
>   */
> -unsigned long global_reclaimable_pages(void)
> -{
> -	int nr;
> -
> -	nr = global_page_state(NR_ACTIVE_FILE) +
> -	     global_page_state(NR_INACTIVE_FILE);
> -
> -	if (nr_swap_pages > 0)
> -		nr += global_page_state(NR_ACTIVE_ANON) +
> -		      global_page_state(NR_INACTIVE_ANON);
> -
> -	return nr;
> -}
> -
>  unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
>  	int nr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
