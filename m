Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [Fwd: [PATCH] slabasap-mm5_A2]
Date: Sun, 8 Sep 2002 16:33:55 -0400
References: <3D7BA76C.EF7B727@digeo.com>
In-Reply-To: <3D7BA76C.EF7B727@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209081633.56019.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On September 8, 2002 03:39 pm, Andrew Morton wrote:
> I think Ed meant to Cc linux-mm ;)

Thanks Andrew.  If anyone wants the full patch to reverse slablru for mm5 just
ask.  Its big (80K), which makes me hesitate to post it here.  

Andrew, if mm5 tests ok can we replace slablru with this code please?

TIA,
Ed

> -------- Original Message --------
> Subject: [PATCH] slabasap-mm5_A2
> Date: Sun, 8 Sep 2002 11:42:02 -0400
> From: Ed Tomlinson <tomlins@cam.org>
> Organization: me
> To: Andrew Morton <akpm@zip.com.au>
> References: <200209071006.18869.tomlins@cam.org>
>
> Hi,
>
> Here is a rewritten slablru - this time its not using the lru...  If
> changes long standing slab behavior.  Now slab.c releases pages as soon as
> possible.  This was done since we noticed that slablru was taking a long
> time to release the pages it freed - from other vm experiences this is not
> a good thing.
>
> In this patch I have tried to make as few changes as possible.   With this
> in mind I am using the percentage of the active+inactive pages reclaimed to
> recover the same percentage of the pruneable caches.  In slablru the affect
> was to age the pruneable caches by percentage of the active+inactive pages
> scanned - this could be done but required more code so I went used pages
> reclaimed.  The same choise was made about accounting of pages freed by the
> shrink_<something>_memory calls.
>
> There is also a question as to if we should only use the ZONE_DMA and
> ZONE_NORMAL to drive the cache shrinking.  Talk with Rik on irc convinced
> me to go with the choise that required less code, so we use all zones.
>
> To apply the patch to mm5 use the follow procedure:
> copy the two slablru patch and discard all but the vmscan changes.
> replace the slablru patch with the just created patches that just hit
> vmscan after applying the mm5 patches apply the following patch to adjust
> vmscan and add slabasap.
>
> This passes the normal group of tests I apply to my patches (mm4 stalled
> force watchdog to reboot).   The varient for bk linus also survives these
> tests.
>
> I have seen some unexpected messages from the kde artsd daemon when I left
> kde running all night.  This may imply we want to have slab be a little
> less aggressive freeing high order slabs. Would like to see if other have
> problems though - it could just be debian and kde 3.0.3 (which is not
> offical yet).
>
> Please let me know if you want any changes or the addition of any of the
> options mentioned.
>
> Comments?
>
> Ed
>
> -------- slablru_reverse_vmscan
> diff -Nru a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c	Sun Sep  8 11:09:14 2002
> +++ b/mm/vmscan.c	Sun Sep  8 11:09:14 2002
> @@ -115,7 +115,7 @@
>
>  static /* inline */ int
>  shrink_list(struct list_head *page_list, int nr_pages,
> -		unsigned int gfp_mask, int *max_scan, int *prunes_needed)
> +		unsigned int gfp_mask, int *max_scan)
>  {
>  	struct address_space *mapping;
>  	LIST_HEAD(ret_pages);
> @@ -135,26 +135,11 @@
>
>  		if (TestSetPageLocked(page))
>  			goto keep;
> -		BUG_ON(PageActive(page));
>
> -		/*
> -		 * For slab pages, use kmem_count_page to increment the aging
> -		 * counter for the cache and to tell us if we should try to
> -		 * free the slab.  Use kmem_shrink_slab to free the slab and
> -		 * stop if we are done.
> -		 */
> -		if (PageSlab(page)) {
> -			int ref = TestClearPageReferenced(page);
> -			if (kmem_count_page(page, ref, prunes_needed)) {
> -				if (kmem_shrink_slab(page))
> -					goto free_ref;
> -			}
> -			goto keep_locked;
> -		}
> +		BUG_ON(PageActive(page));
>
>  		may_enter_fs = (gfp_mask & __GFP_FS) ||
>  				(PageSwapCache(page) && (gfp_mask & __GFP_IO));
> -
>  		/*
>  		 * If the page is mapped into pagetables then wait on it, to
>  		 * throttle this allocator to the rate at which we can clear
> @@ -336,7 +321,6 @@
>  			__remove_from_page_cache(page);
>  			write_unlock(&mapping->page_lock);
>  		}
> -free_ref:
>  		__put_page(page);	/* The pagecache ref */
>  free_it:
>  		unlock_page(page);
> @@ -376,7 +360,7 @@
>   */
>  static /* inline */ int
>  shrink_cache(int nr_pages, struct zone *zone,
> -		unsigned int gfp_mask, int max_scan, int *prunes_needed)
> +		unsigned int gfp_mask, int max_scan)
>  {
>  	LIST_HEAD(page_list);
>  	struct pagevec pvec;
> @@ -428,7 +412,7 @@
>  		max_scan -= nr_scan;
>  		KERNEL_STAT_ADD(pgscan, nr_scan);
>  		nr_pages = shrink_list(&page_list, nr_pages, gfp_mask,
> -					&max_scan, prunes_needed);
> +					&max_scan);
>
>  		if (nr_pages <= 0 && list_empty(&page_list))
>  			goto done;
> @@ -582,7 +566,10 @@
>  	unsigned int gfp_mask, int nr_pages)
>  {
>  	unsigned long ratio;
> -	int prunes_needed = 0;
> +
> +	/* This is bogus for ZONE_HIGHMEM? */
> +	if (kmem_cache_reap(gfp_mask) >= nr_pages)
> +  		return 0;
>
>  	/*
>  	 * Try to keep the active list 2/3 of the size of the cache.  And
> @@ -603,9 +590,15 @@
>  	}
>
>  	nr_pages = shrink_cache(nr_pages, zone, gfp_mask,
> -				max_scan, &prunes_needed);
> -	if (prunes_needed)
> -		kmem_do_prunes(gfp_mask);
> +				max_scan);
> +
> +	shrink_dcache_memory(priority, gfp_mask);
> +
> +	/* After shrinking the dcache, get rid of unused inodes too .. */
> +	shrink_icache_memory(1, gfp_mask);
> +	#ifdef CONFIG_QUOTA
> +	shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
> +	#endif
>
>  	return nr_pages;
>  }
>
> -------- slabasap-mm5_A2
> # This is a BitKeeper generated patch for the following project:
> # Project Name: Linux kernel tree
> # This patch format is intended for GNU patch command version 2.5 or
> higher. # This patch includes the following deltas:
> #	           ChangeSet	1.578   -> 1.579
> #	  include/linux/mm.h	1.76    -> 1.77
> #	     mm/page_alloc.c	1.95    -> 1.96
> #	         fs/dcache.c	1.31    -> 1.32
> #	         mm/vmscan.c	1.102   -> 1.103
> #	          fs/dquot.c	1.46    -> 1.47
> #	           mm/slab.c	1.29    -> 1.30
> #	          fs/inode.c	1.69    -> 1.70
> #	include/linux/dcache.h	1.17    -> 1.18
> #
> # The following is the BitKeeper ChangeSet Log
> # --------------------------------------------
> # 02/09/08	ed@oscar.et.ca	1.579
> # slabasap_A1-mm4
> # --------------------------------------------
> #
> diff -Nru a/fs/dcache.c b/fs/dcache.c
> --- a/fs/dcache.c	Sun Sep  8 11:08:27 2002
> +++ b/fs/dcache.c	Sun Sep  8 11:08:27 2002
> @@ -573,19 +573,11 @@
>
>  /*
>   * This is called from kswapd when we think we need some
> - * more memory, but aren't really sure how much. So we
> - * carefully try to free a _bit_ of our dcache, but not
> - * too much.
> - *
> - * Priority:
> - *   1 - very urgent: shrink everything
> - *  ...
> - *   6 - base-level: try to shrink a bit.
> + * more memory.
>   */
> -int shrink_dcache_memory(int priority, unsigned int gfp_mask)
> +int shrink_dcache_memory(int ratio, unsigned int gfp_mask)
>  {
> -	int count = 0;
> -
> +	int entries = dentry_stat.nr_dentry / ratio + 1;
>  	/*
>  	 * Nasty deadlock avoidance.
>  	 *
> @@ -600,11 +592,8 @@
>  	if (!(gfp_mask & __GFP_FS))
>  		return 0;
>
> -	count = dentry_stat.nr_unused / priority;
> -
> -	prune_dcache(count);
> -	kmem_cache_shrink(dentry_cache);
> -	return 0;
> +	prune_dcache(entries);
> +	return entries;
>  }
>
>  #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
> diff -Nru a/fs/dquot.c b/fs/dquot.c
> --- a/fs/dquot.c	Sun Sep  8 11:08:27 2002
> +++ b/fs/dquot.c	Sun Sep  8 11:08:27 2002
> @@ -480,26 +480,17 @@
>
>  /*
>   * This is called from kswapd when we think we need some
> - * more memory, but aren't really sure how much. So we
> - * carefully try to free a _bit_ of our dqcache, but not
> - * too much.
> - *
> - * Priority:
> - *   1 - very urgent: shrink everything
> - *   ...
> - *   6 - base-level: try to shrink a bit.
> + * more memory
>   */
>
> -int shrink_dqcache_memory(int priority, unsigned int gfp_mask)
> +int shrink_dqcache_memory(int ratio, unsigned int gfp_mask)
>  {
> -	int count = 0;
> +	entries = dqstats.allocated_dquots / ratio + 1;
>
>  	lock_kernel();
> -	count = dqstats.free_dquots / priority;
> -	prune_dqcache(count);
> +	prune_dqcache(entries);
>  	unlock_kernel();
> -	kmem_cache_shrink(dquot_cachep);
> -	return 0;
> +	return entries;
>  }
>
>  /*
> diff -Nru a/fs/inode.c b/fs/inode.c
> --- a/fs/inode.c	Sun Sep  8 11:08:27 2002
> +++ b/fs/inode.c	Sun Sep  8 11:08:27 2002
> @@ -442,19 +442,11 @@
>
>  /*
>   * This is called from kswapd when we think we need some
> - * more memory, but aren't really sure how much. So we
> - * carefully try to free a _bit_ of our icache, but not
> - * too much.
> - *
> - * Priority:
> - *   1 - very urgent: shrink everything
> - *  ...
> - *   6 - base-level: try to shrink a bit.
> + * more memory.
>   */
> -int shrink_icache_memory(int priority, int gfp_mask)
> +int shrink_icache_memory(int ratio, unsigned int gfp_mask)
>  {
> -	int count = 0;
> -
> +	int entries = inodes_stat.nr_inodes / ratio + 1;
>  	/*
>  	 * Nasty deadlock avoidance..
>  	 *
> @@ -465,12 +457,10 @@
>  	if (!(gfp_mask & __GFP_FS))
>  		return 0;
>
> -	count = inodes_stat.nr_unused / priority;
> -
> -	prune_icache(count);
> -	kmem_cache_shrink(inode_cachep);
> -	return 0;
> +	prune_icache(entries);
> +	return entries;
>  }
> +EXPORT_SYMBOL(shrink_icache_memory);
>
>  /*
>   * Called with the inode lock held.
> diff -Nru a/include/linux/dcache.h b/include/linux/dcache.h
> --- a/include/linux/dcache.h	Sun Sep  8 11:08:27 2002
> +++ b/include/linux/dcache.h	Sun Sep  8 11:08:27 2002
> @@ -186,7 +186,7 @@
>  extern void prune_dcache(int);
>
>  /* icache memory management (defined in linux/fs/inode.c) */
> -extern int shrink_icache_memory(int, int);
> +extern int shrink_icache_memory(int, unsigned int);
>  extern void prune_icache(int);
>
>  /* quota cache memory management (defined in linux/fs/dquot.c) */
> diff -Nru a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h	Sun Sep  8 11:08:27 2002
> +++ b/include/linux/mm.h	Sun Sep  8 11:08:27 2002
> @@ -509,6 +509,7 @@
>
>  extern struct page * vmalloc_to_page(void *addr);
>  extern unsigned long get_page_cache_size(void);
> +extern unsigned int nr_used_zone_pages(void);
>
>  #endif /* __KERNEL__ */
>
> diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c	Sun Sep  8 11:08:27 2002
> +++ b/mm/page_alloc.c	Sun Sep  8 11:08:27 2002
> @@ -487,6 +487,17 @@
>  	return sum;
>  }
>
> +unsigned int nr_used_zone_pages(void)
> +{
> +	unsigned int pages = 0;
> +	struct zone *zone;
> +
> +	for_each_zone(zone)
> +		pages += zone->nr_active + zone->nr_inactive;
> +
> +	return pages;
> +}
> +
>  static unsigned int nr_free_zone_pages(int offset)
>  {
>  	pg_data_t *pgdat;
> diff -Nru a/mm/slab.c b/mm/slab.c
> --- a/mm/slab.c	Sun Sep  8 11:08:27 2002
> +++ b/mm/slab.c	Sun Sep  8 11:08:27 2002
> @@ -1500,7 +1500,11 @@
>  		if (unlikely(!--slabp->inuse)) {
>  			/* Was partial or full, now empty. */
>  			list_del(&slabp->list);
> -			list_add(&slabp->list, &cachep->slabs_free);
> +/*			list_add(&slabp->list, &cachep->slabs_free); 		*/
> +			if (unlikely(list_empty(&cachep->slabs_partial)))
> +				list_add(&slabp->list, &cachep->slabs_partial);
> +			else
> +				kmem_slab_destroy(cachep, slabp);
>  		} else if (unlikely(inuse == cachep->num)) {
>  			/* Was full. */
>  			list_del(&slabp->list);
> @@ -1969,7 +1973,7 @@
>  	}
>  	list_for_each(q,&cachep->slabs_partial) {
>  		slabp = list_entry(q, slab_t, list);
> -		if (slabp->inuse == cachep->num || !slabp->inuse)
> +		if (slabp->inuse == cachep->num)
>  			BUG();
>  		active_objs += slabp->inuse;
>  		active_slabs++;
> diff -Nru a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c	Sun Sep  8 11:08:27 2002
> +++ b/mm/vmscan.c	Sun Sep  8 11:08:27 2002
> @@ -567,10 +567,6 @@
>  {
>  	unsigned long ratio;
>
> -	/* This is bogus for ZONE_HIGHMEM? */
> -	if (kmem_cache_reap(gfp_mask) >= nr_pages)
> -  		return 0;
> -
>  	/*
>  	 * Try to keep the active list 2/3 of the size of the cache.  And
>  	 * make sure that refill_inactive is given a decent number of pages.
> @@ -592,14 +588,6 @@
>  	nr_pages = shrink_cache(nr_pages, zone, gfp_mask,
>  				max_scan);
>
> -	shrink_dcache_memory(priority, gfp_mask);
> -
> -	/* After shrinking the dcache, get rid of unused inodes too .. */
> -	shrink_icache_memory(1, gfp_mask);
> -	#ifdef CONFIG_QUOTA
> -	shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
> -	#endif
> -
>  	return nr_pages;
>  }
>
> @@ -609,6 +597,8 @@
>  {
>  	struct zone *first_classzone;
>  	struct zone *zone;
> +	int nr_pages_in = nr_pages;
> +	int pages = nr_used_zone_pages();
>
>  	first_classzone = classzone->zone_pgdat->node_zones;
>  	for (zone = classzone; zone >= first_classzone; zone--) {
> @@ -637,6 +627,28 @@
>  		nr_pages -= to_reclaim - unreclaimed;
>  		*total_scanned += max_scan;
>  	}
> +
> +	/*
> +	 * Here we assume it costs one seek to replace a lru page and that
> +	 * it also takes a seek to recreate a cache object.  With this in
> +	 * mind we age equal percentages of the lru and ageable caches.
> +	 * This should balance the seeks generated by these structures.
> +	 *
> +	 * NOTE: for now I do this for all zones.  If we find this is too
> +	 * aggressive on large boxes we may want to exculude ZONE_HIGH
> +	 */
> +	if (likely(nr_pages_in > nr_pages)) {
> +		int ratio = pages / (nr_pages_in-nr_pages);
> +
> +		shrink_dcache_memory(ratio, gfp_mask);
> +
> +		/* After aging the dcache, age inodes too .. */
> +		shrink_icache_memory(ratio, gfp_mask);
> +#ifdef CONFIG_QUOTA
> +		shrink_dqcache_memory(ratio, gfp_mask);
> +#endif
> +	}
> +
>  	return nr_pages;
>  }
>
> @@ -687,13 +699,6 @@
>  		/* Take a nap, wait for some writeback to complete */
>  		blk_congestion_wait(WRITE, HZ/4);
>  	}
> -
> -	/*
> -	 * perform full reap before concluding we are oom
> -	 */
> -	nr_pages -= kmem_cache_reap(gfp_mask);
> -	if (nr_pages <= 0)
> -		   return 1;
>
>  	if (gfp_mask & __GFP_FS)
>  		out_of_memory();
>
> --------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
