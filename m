Date: Tue, 1 Jul 2008 20:07:41 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [problem] raid performance loss with 2.6.26-rc8 on 32-bit x86 (bisected)
Message-ID: <20080701190741.GB16501@csn.ul.ie>
References: <1214877439.7885.40.camel@dwillia2-linux.ch.intel.com> <20080701080910.GA10865@csn.ul.ie> <20080701175855.GI32727@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080701175855.GI32727@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, cl@linux-foundation.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On (01/07/08 18:58), Andy Whitcroft didst pronounce:
> On Tue, Jul 01, 2008 at 09:09:11AM +0100, Mel Gorman wrote:
> > (Christoph's address corrected and Andys added to cc)
> > 
> > On (30/06/08 18:57), Dan Williams didst pronounce:
> > > Hello,
> > > 
> > > Prompted by a report from a user I have bisected a performance loss
> > > apparently introduced by commit 54a6eb5c (mm: use two zonelist that are
> > > filtered by GFP mask).  The test is simple sequential writes to a 4 disk
> > > raid5 array.  Performance should be about 20% greater than 2.6.25 due to
> > > commit 8b3e6cdc (md: introduce get_priority_stripe() to improve raid456
> > > write performance).  The sample data below shows sporadic performance
> > > starting at 54a6eb5c.  The '+' indicates where I hand applied 8b3e6cdc.
> > > 
> > > revision   2.6.25.8-fc8 2.6.25.9+ dac1d27b+ 18ea7e71+ 54a6eb5c+ 2.6.26-rc1 2.6.26-rc8
> > >            138          168       169       167       177       149        144
> > >            140          168       172       170       109       138        142
> > >            142          165       169       164       119       138        129
> > >            144          168       169       171       120       139        135
> > >            142          165       174       166       165       122        154
> > > MB/s (avg) 141          167       171       168       138       137        141
> > > % change   0%           18%       21%       19%       -2%       -3%        0%
> > > result     base         good      good      good      [bad]     bad        bad
> > > 
> > 
> > That is not good at all as this patch is not a straight-forward revert but
> > the second time it's come under suspicion.
> > 
> > > Notable observations:
> > > 1/ This problem does not reproduce when ARCH=x86_64, i.e. 2.6.26-rc8 and
> > > 54a6eb5c show consistent performance at 170MB/s.
> > 
> > I'm very curious as to why this doesn't affect x86_64. HIGHMEM is one
> > possibility if GFP_KERNEL is a major factor and it has to scan over the
> > unusable zone a lot. However, another remote possibility is that many function
> > calls are more expensive on x86 than on x86_64 (this is a wild guess based
> > on the registers available). Spectulative patch is below.
> > 
> > If 8b3e6cdc is reverted from 2.6.26-rc8, what do the figures look like?
> > i.e. is the zonelist filtering looking like a performance regression or is
> > it just somehow negating the benefits of the raid patch?
> > 
> > > 2/ Single drive performance appears to be unaffected
> > > 3/ A quick test shows that raid0 performance is also sporadic:
> > >    2147483648 bytes (2.1 GB) copied, 7.72408 s, 278 MB/s
> > >    2147483648 bytes (2.1 GB) copied, 7.78478 s, 276 MB/s
> > >    2147483648 bytes (2.1 GB) copied, 11.0323 s, 195 MB/s
> > >    2147483648 bytes (2.1 GB) copied, 8.41244 s, 255 MB/s
> > >    2147483648 bytes (2.1 GB) copied, 30.7649 s, 69.8 MB/s
> > > 
> > 
> > Are these synced writes? i.e. is it possible the performance at the end
> > is dropped because memory becomes full of dirty pages at that point?
> > 
> > > System/Test configuration:
> > > (2) Intel(R) Xeon(R) CPU 5150
> > > mem=1024M
> > > CONFIG_HIGHMEM4G=y (full config attached)
> > > mdadm --create /dev/md0 /dev/sd[b-e] -n 4 -l 5 --assume-clean
> > > for i in `seq 1 5`; do dd if=/dev/zero of=/dev/md0 bs=1024k count=2048; done
> > > 
> > > Neil suggested CONFIG_NOHIGHMEM=y, I will give that a shot tomorrow.
> > > Other suggestions / experiments?
> > > 
> 
> Looking at the commit in question (54a6eb5c) there is one slight anomoly
> in the conversion.  When nr_free_zone_pages() was converted to the new
> iterators it started using the offset parameter to limit the zones
> traversed; which is not unreasonable as that appears to be the
> parameters purpose.  However, if we look at the original implementation
> of this function (reproduced below) we can see it actually did nothing
> with this parameter:
> 
> static unsigned int nr_free_zone_pages(int offset)
> {
> 	/* Just pick one node, since fallback list is circular */
> 	unsigned int sum = 0;
> 
> 	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
> 	struct zone **zonep = zonelist->zones;
> 	struct zone *zone;
> 
> 	for (zone = *zonep++; zone; zone = *zonep++) {
> 		unsigned long size = zone->present_pages;
> 		unsigned long high = zone->pages_high;
> 		if (size > high)
> 			sum += size - high;
> 	}
> 
> 	return sum;
> }
> 

This looks kinda promising and depends heavily on how this patch was
tested in isolation. Dan, can you post the patch you use on 2.6.25
because the commit in question should not have applied cleanly please?

To be clear, 2.6.25 used the offset parameter correctly to get a zonelist with
the right zones in it. However, with two-zonelist, there is only one that
gets filtered so using GFP_KERNEL to find a zone is equivilant as it gets
filtered based on offset.  However, if this patch was tested in isolation,
it could result in bogus values of vm_total_pages. Dan, can you confirm
in your dmesg logs that the line like the following has similar values
please?

Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 258544

Right now though 2.6.26-rc8 and 2.6.25 report the same values for "Total
pages" in the dmesg at least under qemu running with 1GB. If
vm_total_pages was wrong, that value would be broken.

> This version of the routine would only ever accumulate the free space as
> found on zones in the GFP_KERNEL zonelist, all zones other than HIGHMEM,
> regardless of its parameters.
> 
> Looking at its callers, there are only two:
> 
>     unsigned int nr_free_buffer_pages(void)
>     {
> 	return nr_free_zone_pages(gfp_zone(GFP_USER));
>     }
>     unsigned int nr_free_pagecache_pages(void)
>     {
> 	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
>     }
> 
> Before this commit both would return the same value.  Following it,
> nr_free_pagecache_pages() would now contain the number of pages in
> HIGHMEM as well.  This is used to initialise vm_total_pages, which is
> used in a number of the heuristics related to reclaim.
> 
>         vm_total_pages = nr_free_pagecache_pages();
> 
> If the issue was low memory pressure (which would not be an unreasonable
> conjecture given the large number of internal I/O's we may generate
> with RAID) we may well make different reclaim decisions before and after
> this commit.  It should also be noted that as this discrepancy would only
> appear where there is HIGHMEM we might expect different behaviour on i386
> either side of this commit but not so on x86_64.
> 
> All that said, the simple way to confirm/eliminate this would be to
> test at the first bad commit, with the patch below.  This patch 'fixes'
> nr_free_pagecache_pages to return the original value.  It is not clear
> whether this is the right behaviour, but worth testing to see if this
> the root cause or not.
> 
> -apw
> 
> === 8< ===
> debug raid slowdown
> 
> There is a small difference in the calculations leading to the value of
> vm_total_pages once two zone lists is applied on i386 architectures with
> HIGHMEM present.  Bodge nr_free_pagecache_pages() to return the (arguably
> incorrect) value it did before this change.
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2f55295..5ceef27 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1745,7 +1745,7 @@ EXPORT_SYMBOL_GPL(nr_free_buffer_pages);
>   */
>  unsigned int nr_free_pagecache_pages(void)
>  {
> -	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
> +	return nr_free_zone_pages(gfp_zone(GFP_USER));
>  }
>  
>  static inline void show_node(struct zone *zone)
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
