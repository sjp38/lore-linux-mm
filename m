Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4E26B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 05:34:56 -0400 (EDT)
Date: Mon, 20 Sep 2010 10:34:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
	file/email/web servers
Message-ID: <20100920093440.GD1998@csn.ul.ie>
References: <1284349152.15254.1394658481@webmail.messagingengine.com> <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: robm@fastmail.fm, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 07:01:32PM +0900, KOSAKI Motohiro wrote:
> Cc to linux-mm and hpc guys. and intetionally full quote.
> 
> 
> > So over the last couple of weeks, I've noticed that our shiny new IMAP
> > servers (Dual Xeon E5520 + Intel S5520UR MB) with 48G of RAM haven't
> > been performing as well as expected, and there were some big oddities.
> > Namely two things stuck out:
> > 
> > 1. There was free memory. There's 20T of data on these machines. The
> >    kernel should have used lots of memory for caching, but for some
> >    reason, it wasn't. cache ~ 2G, buffers ~ 25G, unused ~ 5G
> > 2. The machine has an SSD for very hot data. In total, there's about 16G
> >    of data on the SSD. Almost all of that 16G of data should end up
> >    being cached, so there should be little reading from the SSDs at all.
> >    Instead we saw at peak times 2k+ blocks read/s from the SSDs. Again a
> >    sign that caching wasn't working.
> > 
> > After a bunch of googling, I found this thread.
> > 
> > http://lkml.org/lkml/2009/5/12/586
> > 
> > It appears that patch never went anywhere, and zone_reclaim_mode is
> > still defaulting to 1 on our pretty standard file/email/web server type
> > machine with a NUMA kernel.
> > 
> > By changing it to 0, we saw an immediate massive change in caching
> > behaviour. Now cache ~ 27G, buffers ~ 7G and unused ~ 0.2G, and IO reads
> > from the SSD dropped to 100/s instead of 2000/s.
> > 
> > Having very little knowledge of what this actually does, I'd just
> > like to point out that from a users point of view, it's really
> > annoying for your machine to be crippled by a default kernel setting
> > that's pretty obscure.
> > 
> > I don't think our usage scenario of serving lots of files is that
> > uncommon, every file server/email server/web server will be doing pretty
> > much that and expecting a large part of their memory to be used as a
> > cache, which clearly isn't what actually happens.
> > 
> > Rob
> > Rob Mueller
> > robm@fastmail.fm
> > 
> 
> Yes, sadly intel motherboard turn on zone_reclaim_mode by default. and
> current zone_reclaim_mode doesn't fit file/web server usecase ;-)
> 
> So, I've created new proof concept patch. This doesn't disable zone_reclaim
> at all. Instead, distinguish for file cache and for anon allocation and
> only file cache doesn't use zone-reclaim.
> 
> That said, high-end hpc user often turn on cpuset.memory_spread_page and
> they avoid this issue. But, why don't we consider avoid it by default?
> 
> 
> Rob, I wonder if following patch help you. Could you please try it?
> 
> 
> Subject: [RFC] vmscan: file cache doesn't use zone_reclaim by default
> 
> ---
> Need to removed debbuging piece.
> 
>  Documentation/sysctl/vm.txt |    7 +++----
>  fs/inode.c                  |    2 +-
>  include/linux/gfp.h         |    9 +++++++--
>  include/linux/mmzone.h      |    2 ++
>  include/linux/swap.h        |    6 ++++++
>  mm/filemap.c                |    1 +
>  mm/page_alloc.c             |    8 +++++++-
>  mm/vmscan.c                 |    7 ++-----
>  mm/vmstat.c                 |    2 ++
>  9 files changed, 31 insertions(+), 13 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index b606c2c..4be569e 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -671,16 +671,15 @@ This is value ORed together of
>  1	= Zone reclaim on
>  2	= Zone reclaim writes dirty pages out
>  4	= Zone reclaim swaps pages
> +8	= Zone reclaim for file cache on
>  
>  zone_reclaim_mode is set during bootup to 1 if it is determined that pages
>  from remote zones will cause a measurable performance reduction. The
>  page allocator will then reclaim easily reusable pages (those page
>  cache pages that are currently not used) before allocating off node pages.
>  
> -It may be beneficial to switch off zone reclaim if the system is
> -used for a file server and all of memory should be used for caching files
> -from disk. In that case the caching effect is more important than
> -data locality.
> +By default, for file cache allocation doesn't use zone reclaim. But
> +It can be turned on manually.
>  
>  Allowing zone reclaim to write out pages stops processes that are
>  writing large amounts of data from dirtying pages on other nodes. Zone
> diff --git a/fs/inode.c b/fs/inode.c
> index 8646433..02a51b1 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -166,7 +166,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
>  	mapping->a_ops = &empty_aops;
>  	mapping->host = inode;
>  	mapping->flags = 0;
> -	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
> +	mapping_set_gfp_mask(mapping, GFP_FILE_CACHE);
>  	mapping->assoc_mapping = NULL;
>  	mapping->backing_dev_info = &default_backing_dev_info;
>  	mapping->writeback_index = 0;
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 975609c..f263b1f 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -84,6 +84,10 @@ struct vm_area_struct;
>  #define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
>  				 __GFP_HARDWALL | __GFP_HIGHMEM | \
>  				 __GFP_MOVABLE)
> +
> +#define GFP_FILE_CACHE	(GFP_HIGHUSER | __GFP_RECLAIMABLE | __GFP_MOVABLE)
> +

This mask of both __GFP_RECLAIMABLE and __GFP_MOVABLE makes no sense at
all in terms of fragmentation avoidance. In fact, I'm surprised it didn't
trigger the warning in allocflags_to_migratetype() during your testing.

> +
>  #define GFP_IOFS	(__GFP_IO | __GFP_FS)
>  
>  #ifdef CONFIG_NUMA
> @@ -120,11 +124,12 @@ struct vm_area_struct;
>  /* Convert GFP flags to their corresponding migrate type */
>  static inline int allocflags_to_migratetype(gfp_t gfp_flags)
>  {
> -	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> -

Ah, you deleted the check.

>  	if (unlikely(page_group_by_mobility_disabled))
>  		return MIGRATE_UNMOVABLE;
>  
> +	if ((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK)
> +		gfp_flags &= ~__GFP_RECLAIMABLE;
> +

So you delete the flag, maybe it's obvious why later.

>  	/* Group based on mobility */
>  	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
>  		((gfp_flags & __GFP_RECLAIMABLE) != 0);
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 6e6e626..2eead52 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -112,6 +112,8 @@ enum zone_stat_item {
>  	NUMA_LOCAL,		/* allocation from local node */
>  	NUMA_OTHER,		/* allocation from other node */
>  #endif
> +	NR_ZONE_CACHE_AVOID,
> +	NR_ZONE_RECLAIM,
>  	NR_VM_ZONE_STAT_ITEMS };
>  
>  /*
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 2fee51a..487bc3b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -65,6 +65,12 @@ static inline int current_is_kswapd(void)
>  #define MAX_SWAPFILES \
>  	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
>  
> +#define RECLAIM_OFF 0
> +#define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
> +#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
> +#define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
> +#define RECLAIM_CACHE (1<<3)	/* Reclaim even though file cache purpose allocation */
> +
>  /*
>   * Magic header for a swap area. The first part of the union is
>   * what the swap magic looks like for the old (limited to 128MB)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 3d4df44..97298c0 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -468,6 +468,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
>  	if (cpuset_do_page_mem_spread()) {
>  		get_mems_allowed();
>  		n = cpuset_mem_spread_node();
> +		gfp &= ~__GFP_RECLAIMABLE;
>  		page = alloc_pages_exact_node(n, gfp, 0);
>  		put_mems_allowed();
>  		return page;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8587c10..f81c28f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1646,9 +1646,15 @@ zonelist_scan:
>  				    classzone_idx, alloc_flags))
>  				goto try_this_zone;
>  
> -			if (zone_reclaim_mode == 0)
> +			if (zone_reclaim_mode == RECLAIM_OFF)
>  				goto this_zone_full;
>  
> +			if (!(zone_reclaim_mode & RECLAIM_CACHE) &&
> +			    (gfp_mask & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK) {
> +				inc_zone_state(zone, NR_ZONE_CACHE_AVOID);
> +				goto try_next_zone;
> +			}
> +

That doesn't look very nice. There has to be a better way of identifying what
sort of allocations to avoid reclaim_mode for than passing in a meaningless
combination of migrate flags. Are we out of GFP flags? Whether it is one that
specifies it's an allocation for file-backed page cache or something that
indicates reclaim_mode is unnecessary, I don't really mind but it shouldn't
be magically encoded in the migrate flags.

I don't think we will ever get the default value for this tunable right.
I would also worry that avoiding the reclaim_mode for file-backed cache
will hurt HPC applications that are dumping their data to disk and
depending on the existing default for zone_reclaim_mode to not pollute
other nodes.

The ideal would be if distribution packages for mail, web servers and
others that are heavily IO orientated would prompt for a change to the
default value of zone_reclaim_mode in sysctl.

>  			ret = zone_reclaim(zone, gfp_mask, order);
>  			switch (ret) {
>  			case ZONE_RECLAIM_NOSCAN:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c391c32..6f63eea 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2558,11 +2558,6 @@ module_init(kswapd_init)
>   */
>  int zone_reclaim_mode __read_mostly;
>  
> -#define RECLAIM_OFF 0
> -#define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
> -#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
> -#define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
> -
>  /*
>   * Priority for ZONE_RECLAIM. This determines the fraction of pages
>   * of a node considered for each zone_reclaim. 4 scans 1/16th of
> @@ -2646,6 +2641,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	};
>  	unsigned long nr_slab_pages0, nr_slab_pages1;
>  
> +	inc_zone_state(zone, NR_ZONE_RECLAIM);
> +
>  	cond_resched();
>  	/*
>  	 * We need to be able to allocate from the reserves for RECLAIM_SWAP
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index f389168..8988688 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -740,6 +740,8 @@ static const char * const vmstat_text[] = {
>  	"numa_local",
>  	"numa_other",
>  #endif
> +	"zone_cache_avoid",
> +	"zone_reclaim",
>  
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  	"pgpgin",
> -- 
> 1.6.5.2
> 
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
