Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CF9626B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:06:49 -0400 (EDT)
Date: Sun, 5 Jul 2009 20:10:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
Message-ID: <20090705121003.GB5252@localhost>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com> <20090705182451.08FF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090705182451.08FF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 05, 2009 at 05:25:32PM +0800, KOSAKI Motohiro wrote:
> Subject: [PATCH] add isolate pages vmstat
> 
> If the system have plenty threads or processes, concurrent reclaim can
> isolate very much pages.
> Unfortunately, current /proc/meminfo and OOM log can't show it.
> 
> This patch provide the way of showing this information.
>
> 
> reproduce way
> -----------------------
> % ./hackbench 140 process 1000
>    => couse OOM
> 
> Active_anon:4419 active_file:120 inactive_anon:1418
>  inactive_file:61 unevictable:0 isolated:45311
>                                          ^^^^^
>  dirty:0 writeback:580 unstable:0
>  free:27 slab_reclaimable:297 slab_unreclaimable:4050
>  mapped:221 kernel_stack:5758 pagetables:28219 bounce:0
> 
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  drivers/base/node.c    |    2 ++
>  fs/proc/meminfo.c      |    2 ++
>  include/linux/mmzone.h |    1 +
>  mm/page_alloc.c        |    6 ++++--
>  mm/vmscan.c            |    4 ++++
>  mm/vmstat.c            |    2 +-
>  6 files changed, 14 insertions(+), 3 deletions(-)
> 
> Index: b/fs/proc/meminfo.c
> ===================================================================
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -65,6 +65,7 @@ static int meminfo_proc_show(struct seq_
>  		"Active(file):   %8lu kB\n"
>  		"Inactive(file): %8lu kB\n"
>  		"Unevictable:    %8lu kB\n"
> +		"IsolatedPages:  %8lu kB\n"
>  		"Mlocked:        %8lu kB\n"
>  #ifdef CONFIG_HIGHMEM
>  		"HighTotal:      %8lu kB\n"
> @@ -109,6 +110,7 @@ static int meminfo_proc_show(struct seq_
>  		K(pages[LRU_ACTIVE_FILE]),
>  		K(pages[LRU_INACTIVE_FILE]),
>  		K(pages[LRU_UNEVICTABLE]),
> +		K(global_page_state(NR_ISOLATED)),

Glad to see you renamed it to NR_ISOLATED :)
But for the user visible name, how about IsolatedLRU?

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

>  		K(global_page_state(NR_MLOCK)),
>  #ifdef CONFIG_HIGHMEM
>  		K(i.totalhigh),
> Index: b/include/linux/mmzone.h
> ===================================================================
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -100,6 +100,7 @@ enum zone_stat_item {
>  	NR_BOUNCE,
>  	NR_VMSCAN_WRITE,
>  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> +	NR_ISOLATED,		/* Temporary isolated pages from lru */
>  #ifdef CONFIG_NUMA
>  	NUMA_HIT,		/* allocated in intended node */
>  	NUMA_MISS,		/* allocated in non intended node */
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2116,8 +2116,7 @@ void show_free_areas(void)
>  	}
>  
>  	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
> -		" inactive_file:%lu"
> -		" unevictable:%lu"
> +		" inactive_file:%lu unevictable:%lu isolated:%lu\n"
>  		" dirty:%lu writeback:%lu buffer:%lu unstable:%lu\n"
>  		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>  		" mapped:%lu pagetables:%lu bounce:%lu\n",
> @@ -2126,6 +2125,7 @@ void show_free_areas(void)
>  		global_page_state(NR_INACTIVE_ANON),
>  		global_page_state(NR_INACTIVE_FILE),
>  		global_page_state(NR_UNEVICTABLE),
> +		global_page_state(NR_ISOLATED),
>  		global_page_state(NR_FILE_DIRTY),
>  		global_page_state(NR_WRITEBACK),
>  		K(nr_blockdev_pages()),
> @@ -2151,6 +2151,7 @@ void show_free_areas(void)
>  			" active_file:%lukB"
>  			" inactive_file:%lukB"
>  			" unevictable:%lukB"
> +			" isolated:%lukB"
>  			" present:%lukB"
>  			" mlocked:%lukB"
>  			" dirty:%lukB"
> @@ -2176,6 +2177,7 @@ void show_free_areas(void)
>  			K(zone_page_state(zone, NR_ACTIVE_FILE)),
>  			K(zone_page_state(zone, NR_INACTIVE_FILE)),
>  			K(zone_page_state(zone, NR_UNEVICTABLE)),
> +			K(zone_page_state(zone, NR_ISOLATED)),
>  			K(zone->present_pages),
>  			K(zone_page_state(zone, NR_MLOCK)),
>  			K(zone_page_state(zone, NR_FILE_DIRTY)),
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1082,6 +1082,7 @@ static unsigned long shrink_inactive_lis
>  						-count[LRU_ACTIVE_ANON]);
>  		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
>  						-count[LRU_INACTIVE_ANON]);
> +		__mod_zone_page_state(zone, NR_ISOLATED, nr_taken);
>  
>  		if (scanning_global_lru(sc))
>  			zone->pages_scanned += nr_scan;
> @@ -1131,6 +1132,7 @@ static unsigned long shrink_inactive_lis
>  			goto done;
>  
>  		spin_lock(&zone->lru_lock);
> +		__mod_zone_page_state(zone, NR_ISOLATED, -nr_taken);
>  		/*
>  		 * Put back any unfreeable pages.
>  		 */
> @@ -1232,6 +1234,7 @@ static void move_active_pages_to_lru(str
>  		}
>  	}
>  	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> +	__mod_zone_page_state(zone, NR_ISOLATED, -pgmoved);
>  	if (!is_active_lru(lru))
>  		__count_vm_events(PGDEACTIVATE, pgmoved);
>  }
> @@ -1267,6 +1270,7 @@ static void shrink_active_list(unsigned 
>  		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
>  	else
>  		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
> +	__mod_zone_page_state(zone, NR_ISOLATED, pgmoved);
>  	spin_unlock_irq(&zone->lru_lock);
>  
>  	pgmoved = 0;  /* count referenced (mapping) mapped pages */
> Index: b/mm/vmstat.c
> ===================================================================
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -644,7 +644,7 @@ static const char * const vmstat_text[] 
>  	"nr_bounce",
>  	"nr_vmscan_write",
>  	"nr_writeback_temp",
> -
> +	"nr_isolated_pages",
>  #ifdef CONFIG_NUMA
>  	"numa_hit",
>  	"numa_miss",
> Index: b/drivers/base/node.c
> ===================================================================
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -73,6 +73,7 @@ static ssize_t node_read_meminfo(struct 
>  		       "Node %d Active(file):   %8lu kB\n"
>  		       "Node %d Inactive(file): %8lu kB\n"
>  		       "Node %d Unevictable:    %8lu kB\n"
> +		       "Node %d IsolatedPages:  %8lu kB\n"
>  		       "Node %d Mlocked:        %8lu kB\n"
>  #ifdef CONFIG_HIGHMEM
>  		       "Node %d HighTotal:      %8lu kB\n"
> @@ -105,6 +106,7 @@ static ssize_t node_read_meminfo(struct 
>  		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
>  		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
>  		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
> +		       nid, K(node_page_state(nid, NR_ISOLATED)),
>  		       nid, K(node_page_state(nid, NR_MLOCK)),
>  #ifdef CONFIG_HIGHMEM
>  		       nid, K(i.totalhigh),
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
