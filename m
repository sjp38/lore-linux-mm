Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 529796B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 06:11:16 -0400 (EDT)
Date: Tue, 7 Jul 2009 18:54:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
Message-ID: <20090707105452.GB20778@localhost>
References: <20090705211739.091D.A69D9226@jp.fujitsu.com> <20090705130200.GA6585@localhost> <20090707102106.0C66.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707102106.0C66.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 09:22:48AM +0800, KOSAKI Motohiro wrote:
> > On Sun, Jul 05, 2009 at 08:21:20PM +0800, KOSAKI Motohiro wrote:
> > > > On Sun, Jul 05, 2009 at 05:26:18PM +0800, KOSAKI Motohiro wrote:
> > > > > Subject: [PATCH] add NR_ANON_PAGES to OOM log
> > > > > 
> > > > > show_free_areas can display NR_FILE_PAGES, but it can't display
> > > > > NR_ANON_PAGES.
> > > > > 
> > > > > this patch fix its inconsistency.
> > > > > 
> > > > > 
> > > > > Reported-by: Wu Fengguang <fengguang.wu@gmail.com>
> > > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > ---
> > > > >  mm/page_alloc.c |    1 +
> > > > >  1 file changed, 1 insertion(+)
> > > > > 
> > > > > Index: b/mm/page_alloc.c
> > > > > ===================================================================
> > > > > --- a/mm/page_alloc.c
> > > > > +++ b/mm/page_alloc.c
> > > > > @@ -2216,6 +2216,7 @@ void show_free_areas(void)
> > > > >  		printk("= %lukB\n", K(total));
> > > > >  	}
> > > > >  
> > > > > +	printk("%ld total anon pages\n", global_page_state(NR_ANON_PAGES));
> > > > >  	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
> > > > 
> > > > Can we put related items together, ie. this looks more friendly:
> > > > 
> > > >         Anon:XXX active_anon:XXX inactive_anon:XXX
> > > >         File:XXX active_file:XXX inactive_file:XXX
> > > 
> > > hmmm. Actually NR_ACTIVE_ANON + NR_INACTIVE_ANON != NR_ANON_PAGES.
> > > tmpfs pages are accounted as FILE, but it is stay in anon lru.
> > 
> > Right, that's exactly the reason I propose to put them together: to
> > make the number of tmpfs pages obvious.
> 
> How about this?
> 
> ==================================================
> Subject: [PATCH] add shmem vmstat
> 
> Recently, We faced several OOM problem by plenty GEM cache. and generally,
> plenty Shmem/Tmpfs potentially makes memory shortage problem.
> 
> Then, End-user want to know how much memory used by shmem.

Thanks for doing this. I think it's convenient to export shmem/tmpfs
pages in the /proc interfaces.

I noticed that you ignored migrate_page_move_mapping() which may move
the file page from one zone to another. Another question is, why you
choose to maintain one more ZVC counter instead of computing it from
the existing counters? Ie. Minchan's equation tmpfs/shmem =
(NR_ACTIVE_ANON + NR_INACTIVE_ANON + isolate(anon)) - NR_ANON_PAGES.
The reason should at least be mentioned in the changelog.

Thanks,
Fengguang

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  drivers/base/node.c    |    2 ++
>  fs/proc/meminfo.c      |    2 ++
>  include/linux/mmzone.h |    1 +
>  mm/filemap.c           |    4 ++++
>  mm/page_alloc.c        |    9 ++++++---
>  mm/vmstat.c            |    1 +
>  6 files changed, 16 insertions(+), 3 deletions(-)
> 
> Index: b/drivers/base/node.c
> ===================================================================
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -87,6 +87,7 @@ static ssize_t node_read_meminfo(struct 
>  		       "Node %d FilePages:      %8lu kB\n"
>  		       "Node %d Mapped:         %8lu kB\n"
>  		       "Node %d AnonPages:      %8lu kB\n"
> +		       "Node %d Shmem:          %8lu kB\n"
>  		       "Node %d KernelStack:    %8lu kB\n"
>  		       "Node %d PageTables:     %8lu kB\n"
>  		       "Node %d NFS_Unstable:   %8lu kB\n"
> @@ -121,6 +122,7 @@ static ssize_t node_read_meminfo(struct 
>  		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
>  		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
>  		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
> +		       nid, K(node_page_state(nid, NR_SHMEM)),
>  		       nid, node_page_state(nid, NR_KERNEL_STACK) *
>  				THREAD_SIZE / 1024,
>  		       nid, K(node_page_state(nid, NR_PAGETABLE)),
> Index: b/fs/proc/meminfo.c
> ===================================================================
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -83,6 +83,7 @@ static int meminfo_proc_show(struct seq_
>  		"Writeback:      %8lu kB\n"
>  		"AnonPages:      %8lu kB\n"
>  		"Mapped:         %8lu kB\n"
> +		"Shmem:          %8lu kB\n"
>  		"Slab:           %8lu kB\n"
>  		"SReclaimable:   %8lu kB\n"
>  		"SUnreclaim:     %8lu kB\n"
> @@ -129,6 +130,7 @@ static int meminfo_proc_show(struct seq_
>  		K(global_page_state(NR_WRITEBACK)),
>  		K(global_page_state(NR_ANON_PAGES)),
>  		K(global_page_state(NR_FILE_MAPPED)),
> +		K(global_page_state(NR_SHMEM)),
>  		K(global_page_state(NR_SLAB_RECLAIMABLE) +
>  				global_page_state(NR_SLAB_UNRECLAIMABLE)),
>  		K(global_page_state(NR_SLAB_RECLAIMABLE)),
> Index: b/include/linux/mmzone.h
> ===================================================================
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -102,6 +102,7 @@ enum zone_stat_item {
>  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
>  	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
>  	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> +	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
>  #ifdef CONFIG_NUMA
>  	NUMA_HIT,		/* allocated in intended node */
>  	NUMA_MISS,		/* allocated in non intended node */
> Index: b/mm/filemap.c
> ===================================================================
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -120,6 +120,8 @@ void __remove_from_page_cache(struct pag
>  	page->mapping = NULL;
>  	mapping->nrpages--;
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
> +	if (PageSwapBacked(page))
> +		__dec_zone_page_state(page, NR_SHMEM);
>  	BUG_ON(page_mapped(page));
>  
>  	/*
> @@ -476,6 +478,8 @@ int add_to_page_cache_locked(struct page
>  		if (likely(!error)) {
>  			mapping->nrpages++;
>  			__inc_zone_page_state(page, NR_FILE_PAGES);
> +			if (PageSwapBacked(page))
> +				__inc_zone_page_state(page, NR_SHMEM);
>  			spin_unlock_irq(&mapping->tree_lock);
>  		} else {
>  			page->mapping = NULL;
> Index: b/mm/vmstat.c
> ===================================================================
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -646,6 +646,7 @@ static const char * const vmstat_text[] 
>  	"nr_writeback_temp",
>  	"nr_isolated_anon",
>  	"nr_isolated_file",
> +	"nr_shmem",
>  #ifdef CONFIG_NUMA
>  	"numa_hit",
>  	"numa_miss",
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2118,9 +2118,9 @@ void show_free_areas(void)
>  	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
>  		" inactive_file:%lu unevictable:%lu\n"
>  		" isolated_anon:%lu isolated_file:%lu\n"
> -		" dirty:%lu writeback:%lu buffer:%lu unstable:%lu\n"
> +		" dirty:%lu writeback:%lu buffer:%lu shmem:%lu\n"
>  		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> -		" mapped:%lu pagetables:%lu bounce:%lu\n",
> +		" mapped:%lu pagetables:%lu unstable:%lu bounce:%lu\n",
>  		global_page_state(NR_ACTIVE_ANON),
>  		global_page_state(NR_ACTIVE_FILE),
>  		global_page_state(NR_INACTIVE_ANON),
> @@ -2131,12 +2131,13 @@ void show_free_areas(void)
>  		global_page_state(NR_FILE_DIRTY),
>  		global_page_state(NR_WRITEBACK),
>  		nr_blockdev_pages(),
> -		global_page_state(NR_UNSTABLE_NFS),
> +		global_page_state(NR_SHMEM),
>  		global_page_state(NR_FREE_PAGES),
>  		global_page_state(NR_SLAB_RECLAIMABLE),
>  		global_page_state(NR_SLAB_UNRECLAIMABLE),
>  		global_page_state(NR_FILE_MAPPED),
>  		global_page_state(NR_PAGETABLE),
> +		global_page_state(NR_UNSTABLE_NFS),
>  		global_page_state(NR_BOUNCE));
>  
>  	for_each_populated_zone(zone) {
> @@ -2160,6 +2161,7 @@ void show_free_areas(void)
>  			" dirty:%lukB"
>  			" writeback:%lukB"
>  			" mapped:%lukB"
> +			" shmem:%lukB"
>  			" slab_reclaimable:%lukB"
>  			" slab_unreclaimable:%lukB"
>  			" kernel_stack:%lukB"
> @@ -2187,6 +2189,7 @@ void show_free_areas(void)
>  			K(zone_page_state(zone, NR_FILE_DIRTY)),
>  			K(zone_page_state(zone, NR_WRITEBACK)),
>  			K(zone_page_state(zone, NR_FILE_MAPPED)),
> +			K(zone_page_state(zone, NR_SHMEM)),
>  			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
>  			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
>  			zone_page_state(zone, NR_KERNEL_STACK) *
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
