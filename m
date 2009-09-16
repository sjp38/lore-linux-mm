Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 57D096B005C
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 23:29:45 -0400 (EDT)
Date: Wed, 16 Sep 2009 11:29:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Isolated(anon) and Isolated(file)
Message-ID: <20090916032933.GA24097@localhost>
References: <20090915114742.DB79.A69D9226@jp.fujitsu.com> <Pine.LNX.4.64.0909160047480.4234@sister.anvils> <20090916091022.DB8C.A69D9226@jp.fujitsu.com> <20090915191957.9e901c38.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090915191957.9e901c38.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 10:19:57AM +0800, Andrew Morton wrote:
> On Wed, 16 Sep 2009 11:09:54 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Subject: [PATCH] Kill Isolated field in /proc/meminfo fix
> > 
> > Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
> > It is only increased at heavy memory pressure case.
> 
> Have we made up our minds yet?
> 
> Below is what remains.  Please check that the changelog is still
> accurate and complete.  If not, please send along a new one?
> 
> 
> 
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> If the system is running a heavy load of processes then concurrent reclaim
> can isolate a large number of pages from the LRU. /proc/meminfo and the

Better to change /proc/meminfo to /proc/vmstat.

Otherwise looks good to me.

Thanks,
Fengguang

> output generated for an OOM do not show how many pages were isolated.
> 
> This has been observed during process fork bomb testing (mstctl11 in LTP).
> 
> This patch shows the information about isolated pages.
> 
> Reproduced via:
> 
> -----------------------
> % ./hackbench 140 process 1000
>    => OOM occur
> 
> active_anon:146 inactive_anon:0 isolated_anon:49245
>  active_file:79 inactive_file:18 isolated_file:113
>  unevictable:0 dirty:0 writeback:0 unstable:0 buffer:39
>  free:370 slab_reclaimable:309 slab_unreclaimable:5492
>  mapped:53 shmem:15 pagetables:28140 bounce:0
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/mmzone.h |    2 ++
>  mm/migrate.c           |   11 +++++++++++
>  mm/page_alloc.c        |   12 +++++++++---
>  mm/vmscan.c            |   12 +++++++++++-
>  mm/vmstat.c            |    2 ++
>  5 files changed, 35 insertions(+), 4 deletions(-)
> 
> diff -puN drivers/base/node.c~mm-vmstat-add-isolate-pages drivers/base/node.c
> diff -puN fs/proc/meminfo.c~mm-vmstat-add-isolate-pages fs/proc/meminfo.c
> diff -puN include/linux/mmzone.h~mm-vmstat-add-isolate-pages include/linux/mmzone.h
> --- a/include/linux/mmzone.h~mm-vmstat-add-isolate-pages
> +++ a/include/linux/mmzone.h
> @@ -100,6 +100,8 @@ enum zone_stat_item {
>  	NR_BOUNCE,
>  	NR_VMSCAN_WRITE,
>  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> +	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
> +	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
>  	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
>  #ifdef CONFIG_NUMA
>  	NUMA_HIT,		/* allocated in intended node */
> diff -puN mm/migrate.c~mm-vmstat-add-isolate-pages mm/migrate.c
> --- a/mm/migrate.c~mm-vmstat-add-isolate-pages
> +++ a/mm/migrate.c
> @@ -67,6 +67,8 @@ int putback_lru_pages(struct list_head *
>  
>  	list_for_each_entry_safe(page, page2, l, lru) {
>  		list_del(&page->lru);
> +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> +				    !!page_is_file_cache(page));
>  		putback_lru_page(page);
>  		count++;
>  	}
> @@ -698,6 +700,8 @@ unlock:
>   		 * restored.
>   		 */
>   		list_del(&page->lru);
> +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> +				    !!page_is_file_cache(page));
>  		putback_lru_page(page);
>  	}
>  
> @@ -742,6 +746,13 @@ int migrate_pages(struct list_head *from
>  	struct page *page2;
>  	int swapwrite = current->flags & PF_SWAPWRITE;
>  	int rc;
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	list_for_each_entry(page, from, lru)
> +		__inc_zone_page_state(page, NR_ISOLATED_ANON +
> +				      !!page_is_file_cache(page));
> +	local_irq_restore(flags);
>  
>  	if (!swapwrite)
>  		current->flags |= PF_SWAPWRITE;
> diff -puN mm/page_alloc.c~mm-vmstat-add-isolate-pages mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-vmstat-add-isolate-pages
> +++ a/mm/page_alloc.c
> @@ -2152,16 +2152,18 @@ void show_free_areas(void)
>  		}
>  	}
>  
> -	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
> -		" inactive_file:%lu"
> +	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
> +		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
>  		" unevictable:%lu"
>  		" dirty:%lu writeback:%lu unstable:%lu buffer:%lu\n"
>  		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>  		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
>  		global_page_state(NR_ACTIVE_ANON),
> -		global_page_state(NR_ACTIVE_FILE),
>  		global_page_state(NR_INACTIVE_ANON),
> +		global_page_state(NR_ISOLATED_ANON),
> +		global_page_state(NR_ACTIVE_FILE),
>  		global_page_state(NR_INACTIVE_FILE),
> +		global_page_state(NR_ISOLATED_FILE),
>  		global_page_state(NR_UNEVICTABLE),
>  		global_page_state(NR_FILE_DIRTY),
>  		global_page_state(NR_WRITEBACK),
> @@ -2189,6 +2191,8 @@ void show_free_areas(void)
>  			" active_file:%lukB"
>  			" inactive_file:%lukB"
>  			" unevictable:%lukB"
> +			" isolated(anon):%lukB"
> +			" isolated(file):%lukB"
>  			" present:%lukB"
>  			" mlocked:%lukB"
>  			" dirty:%lukB"
> @@ -2215,6 +2219,8 @@ void show_free_areas(void)
>  			K(zone_page_state(zone, NR_ACTIVE_FILE)),
>  			K(zone_page_state(zone, NR_INACTIVE_FILE)),
>  			K(zone_page_state(zone, NR_UNEVICTABLE)),
> +			K(zone_page_state(zone, NR_ISOLATED_ANON)),
> +			K(zone_page_state(zone, NR_ISOLATED_FILE)),
>  			K(zone->present_pages),
>  			K(zone_page_state(zone, NR_MLOCK)),
>  			K(zone_page_state(zone, NR_FILE_DIRTY)),
> diff -puN mm/vmscan.c~mm-vmstat-add-isolate-pages mm/vmscan.c
> --- a/mm/vmscan.c~mm-vmstat-add-isolate-pages
> +++ a/mm/vmscan.c
> @@ -1072,6 +1072,8 @@ static unsigned long shrink_inactive_lis
>  		unsigned long nr_active;
>  		unsigned int count[NR_LRU_LISTS] = { 0, };
>  		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
> +		unsigned long nr_anon;
> +		unsigned long nr_file;
>  
>  		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
>  			     &page_list, &nr_scan, sc->order, mode,
> @@ -1102,6 +1104,10 @@ static unsigned long shrink_inactive_lis
>  		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
>  						-count[LRU_INACTIVE_ANON]);
>  
> +		nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
> +		nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
> +		__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
> +		__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
>  
>  		reclaim_stat->recent_scanned[0] += count[LRU_INACTIVE_ANON];
>  		reclaim_stat->recent_scanned[0] += count[LRU_ACTIVE_ANON];
> @@ -1169,6 +1175,9 @@ static unsigned long shrink_inactive_lis
>  				spin_lock_irq(&zone->lru_lock);
>  			}
>  		}
> +		__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
> +		__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
> +
>    	} while (nr_scanned < max_scan);
>  
>  done:
> @@ -1279,6 +1288,7 @@ static void shrink_active_list(unsigned 
>  		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
>  	else
>  		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
> +	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
>  	spin_unlock_irq(&zone->lru_lock);
>  
>  	while (!list_empty(&l_hold)) {
> @@ -1329,7 +1339,7 @@ static void shrink_active_list(unsigned 
>  						LRU_ACTIVE + file * LRU_FILE);
>  	move_active_pages_to_lru(zone, &l_inactive,
>  						LRU_BASE   + file * LRU_FILE);
> -
> +	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
>  	spin_unlock_irq(&zone->lru_lock);
>  }
>  
> diff -puN mm/vmstat.c~mm-vmstat-add-isolate-pages mm/vmstat.c
> --- a/mm/vmstat.c~mm-vmstat-add-isolate-pages
> +++ a/mm/vmstat.c
> @@ -644,6 +644,8 @@ static const char * const vmstat_text[] 
>  	"nr_bounce",
>  	"nr_vmscan_write",
>  	"nr_writeback_temp",
> +	"nr_isolated_anon",
> +	"nr_isolated_file",
>  	"nr_shmem",
>  #ifdef CONFIG_NUMA
>  	"numa_hit",
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
