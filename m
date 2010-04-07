Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7B23862007E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:06:35 -0400 (EDT)
Date: Tue, 6 Apr 2010 17:06:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 11/14] Direct compact when a high-order allocation fails
Message-Id: <20100406170603.8a999dc2.akpm@linux-foundation.org>
In-Reply-To: <1270224168-14775-12-git-send-email-mel@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-12-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  2 Apr 2010 17:02:45 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Ordinarily when a high-order allocation fails, direct reclaim is entered to
> free pages to satisfy the allocation.  With this patch, it is determined if
> an allocation failed due to external fragmentation instead of low memory
> and if so, the calling process will compact until a suitable page is
> freed. Compaction by moving pages in memory is considerably cheaper than
> paging out to disk and works where there are locked pages or no swap. If
> compaction fails to free a page of a suitable size, then reclaim will
> still occur.

Does this work?

> Direct compaction returns as soon as possible. As each block is compacted,
> it is checked if a suitable page has been freed and if so, it returns.

So someone else can get in and steal it.  How is that resolved?

Please expound upon the relationship between the icky pageblock_order
and the caller's desired allocation order here.  The compaction design
seems fairly fixated upon pageblock_order - what happens if the caller
wanted something larger than pageblock_order?  The
less-than-pageblock_order case seems pretty obvious, although perhaps
wasteful?

>
> ...
>
> +static unsigned long compact_zone_order(struct zone *zone,
> +						int order, gfp_t gfp_mask)
> +{
> +	struct compact_control cc = {
> +		.nr_freepages = 0,
> +		.nr_migratepages = 0,
> +		.order = order,
> +		.migratetype = allocflags_to_migratetype(gfp_mask),
> +		.zone = zone,
> +	};

yeah, like that.

> +	INIT_LIST_HEAD(&cc.freepages);
> +	INIT_LIST_HEAD(&cc.migratepages);
> +
> +	return compact_zone(zone, &cc);
> +}
> +
> +/**
> + * try_to_compact_pages - Direct compact to satisfy a high-order allocation
> + * @zonelist: The zonelist used for the current allocation
> + * @order: The order of the current allocation
> + * @gfp_mask: The GFP mask of the current allocation
> + * @nodemask: The allowed nodes to allocate from
> + *
> + * This is the main entry point for direct page compaction.
> + */
> +unsigned long try_to_compact_pages(struct zonelist *zonelist,
> +			int order, gfp_t gfp_mask, nodemask_t *nodemask)
> +{
> +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> +	int may_enter_fs = gfp_mask & __GFP_FS;
> +	int may_perform_io = gfp_mask & __GFP_IO;
> +	unsigned long watermark;
> +	struct zoneref *z;
> +	struct zone *zone;
> +	int rc = COMPACT_SKIPPED;
> +
> +	/*
> +	 * Check whether it is worth even starting compaction. The order check is
> +	 * made because an assumption is made that the page allocator can satisfy
> +	 * the "cheaper" orders without taking special steps
> +	 */
> +	if (order <= PAGE_ALLOC_COSTLY_ORDER 

Was that a correct decision?  If we perform compaction when smaller
allocation attemtps fail, will the kernel get better, or worse?

And how do we save my order-4-allocating wireless driver?  That would
require that kswapd perform the compaction for me, perhaps?

> || !may_enter_fs || !may_perform_io)

Would be nice to add some comments explaining this a bit more. 
Compaction doesn't actually perform IO, nor enter filesystems, does it?

> +		return rc;
> +
> +	count_vm_event(COMPACTSTALL);
> +
> +	/* Compact each zone in the list */
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> +								nodemask) {
> +		int fragindex;
> +		int status;
> +
> +		/*
> +		 * Watermarks for order-0 must be met for compaction. Note
> +		 * the 2UL. This is because during migration, copies of
> +		 * pages need to be allocated and for a short time, the
> +		 * footprint is higher
> +		 */
> +		watermark = low_wmark_pages(zone) + (2UL << order);
> +		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> +			continue;

ooh, so that starts to explain split_free_page().  But
split_free_page() didn't do the 2UL thing.

Surely these things are racy?  So we'll deadlock less often :(

> +		/*
> +		 * fragmentation index determines if allocation failures are
> +		 * due to low memory or external fragmentation
> +		 *
> +		 * index of -1 implies allocations might succeed depending
> +		 * 	on watermarks
> +		 * index towards 0 implies failure is due to lack of memory
> +		 * index towards 1000 implies failure is due to fragmentation
> +		 *
> +		 * Only compact if a failure would be due to fragmentation.
> +		 */
> +		fragindex = fragmentation_index(zone, order);
> +		if (fragindex >= 0 && fragindex <= 500)
> +			continue;
> +
> +		if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0)) {
> +			rc = COMPACT_PARTIAL;
> +			break;
> +		}

Why are we doing all this handwavy stuff?  Why not just try a
compaction run and see if it worked?  That would be more
robust/reliable, surely?

> +		status = compact_zone_order(zone, order, gfp_mask);
> +		rc = max(status, rc);
> +
> +		if (zone_watermark_ok(zone, order, watermark, 0, 0))
> +			break;
> +	}
> +
> +	return rc;
> +}
> +
> +
>  /* Compact all zones within a node */
>  static int compact_node(int nid)
>  {
>
> ...
>
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -561,7 +561,7 @@ static int unusable_show(struct seq_file *m, void *arg)
>   * The value can be used to determine if page reclaim or compaction
>   * should be used
>   */
> -int fragmentation_index(unsigned int order, struct contig_page_info *info)
> +int __fragmentation_index(unsigned int order, struct contig_page_info *info)
>  {
>  	unsigned long requested = 1UL << order;
>  
> @@ -581,6 +581,14 @@ int fragmentation_index(unsigned int order, struct contig_page_info *info)
>  	return 1000 - div_u64( (1000+(div_u64(info->free_pages * 1000ULL, requested))), info->free_blocks_total);
>  }
>  
> +/* Same as __fragmentation index but allocs contig_page_info on stack */
> +int fragmentation_index(struct zone *zone, unsigned int order)
> +{
> +	struct contig_page_info info;
> +
> +	fill_contig_page_info(zone, order, &info);
> +	return __fragmentation_index(order, &info);
> +}
>  
>  static void extfrag_show_print(struct seq_file *m,
>  					pg_data_t *pgdat, struct zone *zone)
> @@ -596,7 +604,7 @@ static void extfrag_show_print(struct seq_file *m,
>  				zone->name);
>  	for (order = 0; order < MAX_ORDER; ++order) {
>  		fill_contig_page_info(zone, order, &info);
> -		index = fragmentation_index(order, &info);
> +		index = __fragmentation_index(order, &info);
>  		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
>  	}
>  
> @@ -896,6 +904,9 @@ static const char * const vmstat_text[] = {
>  	"compact_blocks_moved",
>  	"compact_pages_moved",
>  	"compact_pagemigrate_failed",
> +	"compact_stall",
> +	"compact_fail",
> +	"compact_success",

CONFIG_COMPACTION=n?

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
