Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 962C06B01FD
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 05:48:28 -0400 (EDT)
Date: Fri, 2 Apr 2010 10:48:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding
	page->lru?
Message-ID: <20100402094805.GA12886@csn.ul.ie>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com> <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com> <20100402135955.645F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100402135955.645F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: TAO HU <tghk48@motorola.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2010 at 02:03:23PM +0900, KOSAKI Motohiro wrote:
> Cc to Mel,
> 
> > 2 patches related to page_alloc.c were applied.
> > Does anyone see a connection between the 2 patches and the panic?
> > NOTE: the full patches are attached.
> 
> I think your attached two patches are perfectly unrelated your problem.
> 

Agreed. It's unlikely that there is a race as such in the page
allocator. In buffered_rmqueue that you initially talk about, the lists
being manipulated are per-cpu lists. About the only way to corrupt them
is if you had a NMI hander that called the page allocator. I really hope
your platform is not doing anything like that.

A double free of page->lru is a possibility. You could try reproducing
the problem with CONFIG_DEBUG_LIST enabled to see if anything falls out.

> "mm: Add min_free_order_shift tunable." seems makes zero sense. I don't think this patch
> need to be merge.
> 

It makes a marginal amount of sense. Basically what it does is allowing
high-order allocations to go much further below their watermarks than is
currently allowed. If the platform in question is doing a lot of high-order
allocations, this patch could be seen to "fix" the problem but you wouldn't
touch mainline with it with a barge pole. It would be more stable to fix
the drivers to not use high order allocations or use a mempool.

It is inconceivable this patch is related to the problem though.

> but "mm: Check if any page in a pageblock is reserved before marking it MIGRATE_RESERVE"
> treat strange hardware correctly, I think. If Mel ack this, I hope merge it. 
> Mel, Can we hear your opinion?
> 

This patch is interesting and I am surprised it is required. Is it really the
case that page blocks near the start of a zone are dominated with PageReserved
pages but the first one happen to be free? I guess it's conceivable on ARM
where memmap can be freed at boot time.

There is a theoritical problem with the patch but it is easily resolved.
A PFN walker like this must call pfn_valid_within() before calling
pfn_to_page(). If they do not, it's possible to get complete garbage
for the page and result in a bad dereference. In this particular case,
it would be a kernel oops rather than memory corruption though.

If that was fixed, I'd see no problem with Acking the patch.

It is also inconceivable this patch is related to the problem.

> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index a596bfd..34a29e2 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2551,6 +2551,20 @@ static inline unsigned long
> > wait_table_bits(unsigned long size)
> >  #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
> > 
> >  /*
> > + * Check if a pageblock contains reserved pages
> > + */
> > +static int pageblock_is_reserved(unsigned long start_pfn)
> > +{
> > +	unsigned long end_pfn = start_pfn + pageblock_nr_pages;
> > +	unsigned long pfn;
> > +
> > +	for (pfn = start_pfn; pfn < end_pfn; pfn++)
> > +		if (PageReserved(pfn_to_page(pfn)))
> > +			return 1;
> > +	return 0;
> > +}
> > +
> > +/*
> >   * Mark a number of pageblocks as MIGRATE_RESERVE. The number
> >   * of blocks reserved is based on zone->pages_min. The memory within the
> >   * reserve will tend to store contiguous free pages. Setting min_free_kbytes
> > @@ -2579,7 +2593,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
> >  			continue;
> > 
> >  		/* Blocks with reserved pages will never free, skip them. */
> > -		if (PageReserved(page))
> > +		if (pageblock_is_reserved(pfn))
> >  			continue;
> > 
> >  		block_migratetype = get_pageblock_migratetype(page);
> > -- 
> > 1.5.4.3
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 5c44ed4..a596bfd 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -119,6 +119,7 @@ static char * const zone_names[MAX_NR_ZONES] = {
> >  };
> > 
> >  int min_free_kbytes = 1024;
> > +int min_free_order_shift = 1;
> > 
> >  unsigned long __meminitdata nr_kernel_pages;
> >  unsigned long __meminitdata nr_all_pages;
> > @@ -1256,7 +1257,7 @@ int zone_watermark_ok(struct zone *z, int order,
> > unsigned long mark,
> >  		free_pages -= z->free_area[o].nr_free << o;
> > 
> >  		/* Require fewer higher order pages to be free */
> > -		min >>= 1;
> > +		min >>= min_free_order_shift;
> > 
> >  		if (free_pages <= min)
> >  			return 0;
> > -- 
> > 
> > 
> > On Thu, Apr 1, 2010 at 12:05 PM, TAO HU <tghk48@motorola.com> wrote:
> > > Hi, all
> > >
> > > We got a panic on our ARM (OMAP) based HW.
> > > Our code is based on 2.6.29 kernel (last commit for mm/page_alloc.c is
> > > cc2559bccc72767cb446f79b071d96c30c26439b)
> > >
> > > It appears to crash while going through pcp->list in
> > > buffered_rmqueue() of mm/page_alloc.c after checking vmlinux.
> > > "00100100" implies LIST_POISON1 that suggests a race condition between
> > > list_add() and list_del() in my personal view.
> > > However we not yet figure out locking problem regarding page.lru.
> > >
> > > Any known issues about race condition in mm/page_alloc.c?
> > > And other hints are highly appreciated.
> > >
> > >  /* Find a page of the appropriate migrate type */
> > >                if (cold) {
> > >                   ... ...
> > >                } else {
> > >                        list_for_each_entry(page, &pcp->list, lru)
> > >                                if (page_private(page) == migratetype)
> > >                                        break;
> > >                }
> > >
> > > <1>[120898.805267] Unable to handle kernel paging request at virtual
> > > address 00100100
> > > <1>[120898.805633] pgd = c1560000
> > > <1>[120898.805786] [00100100] *pgd=897b3031, *pte=00000000, *ppte=00000000
> > > <4>[120898.806457] Internal error: Oops: 17 [#1] PREEMPT
> > > ... ...
> > > <4>[120898.807861] CPU: 0    Not tainted  (2.6.29-omap1 #1)
> > > <4>[120898.808044] PC is at get_page_from_freelist+0x1d0/0x4b0
> > > <4>[120898.808227] LR is at get_page_from_freelist+0xc8/0x4b0
> > > <4>[120898.808563] pc : [<c00a600c>]    lr : [<c00a5f04>]    psr: 800000d3
> > > <4>[120898.808563] sp : c49fbd18  ip : 00000000  fp : c49fbd74
> > > <4>[120898.809020] r10: 00000000  r9 : 001000e8  r8 : 00000002
> > > <4>[120898.809204] r7 : 001200d2  r6 : 60000053  r5 : c0507c4c  r4 : c49fa000
> > > <4>[120898.809509] r3 : 001000e8  r2 : 00100100  r1 : c0507c6c  r0 : 00000001
> > > <4>[120898.809844] Flags: Nzcv  IRQs off  FIQs off  Mode SVC_32  ISA
> > > ARM  Segment kernel
> > > <4>[120898.810028] Control: 10c5387d  Table: 82160019  DAC: 00000017
> > > <4>[120898.948425] Backtrace:
> > > <4>[120898.948760] [<c00a5e3c>] (get_page_from_freelist+0x0/0x4b0)
> > > from [<c00a6398>] (__alloc_pages_internal+0xac/0x3e8)
> > > <4>[120898.949554] [<c00a62ec>] (__alloc_pages_internal+0x0/0x3e8)
> > > from [<c00b461c>] (handle_mm_fault+0x16c/0xbac)
> > > <4>[120898.950347] [<c00b44b0>] (handle_mm_fault+0x0/0xbac) from
> > > [<c00b51d0>] (__get_user_pages+0x174/0x2b4)
> > > <4>[120898.951019] [<c00b505c>] (__get_user_pages+0x0/0x2b4) from
> > > [<c00b534c>] (get_user_pages+0x3c/0x44)
> > > <4>[120898.951812] [<c00b5310>] (get_user_pages+0x0/0x44) from
> > > [<c00caf9c>] (get_arg_page+0x50/0xa4)
> > > <4>[120898.952636] [<c00caf4c>] (get_arg_page+0x0/0xa4) from
> > > [<c00cb1ec>] (copy_strings+0x108/0x210)
> > > <4>[120898.953430]  r7:beffffe4 r6:00000ffc r5:00000000 r4:00000018
> > > <4>[120898.954223] [<c00cb0e4>] (copy_strings+0x0/0x210) from
> > > [<c00cb330>] (copy_strings_kernel+0x3c/0x74)
> > > <4>[120898.955047] [<c00cb2f4>] (copy_strings_kernel+0x0/0x74) from
> > > [<c00cc778>] (do_execve+0x18c/0x2b0)
> > > <4>[120898.955841]  r5:0001e240 r4:0001e224
> > > <4>[120898.956329] [<c00cc5ec>] (do_execve+0x0/0x2b0) from
> > > [<c00400e4>] (sys_execve+0x3c/0x5c)
> > > <4>[120898.957153] [<c00400a8>] (sys_execve+0x0/0x5c) from
> > > [<c003ce80>] (ret_fast_syscall+0x0/0x2c)
> > > <4>[120898.957946]  r7:0000000b r6:0001e270 r5:00000000 r4:0001d580
> > > <4>[120898.958740] Code: e1530008 0a000006 e2429018 e1a03009 (e5b32018)
> > >
> > >
> > >
> > > --
> > > Best Regards
> > > Hu Tao
> > >
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
