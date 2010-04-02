Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E6066B01F3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 01:08:23 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3258K3p003245
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 2 Apr 2010 14:08:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E8BAE45DE4C
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 14:08:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D017345DE4E
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 14:08:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B58341DB8012
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 14:08:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 64E4AE08005
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 14:08:16 +0900 (JST)
Date: Fri, 2 Apr 2010 14:04:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding
 page->lru?
Message-Id: <20100402140406.d3d7f18e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
	<g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: TAO HU <tghk48@motorola.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Apr 2010 11:51:33 +0800
TAO HU <tghk48@motorola.com> wrote:

> 2 patches related to page_alloc.c were applied.
> Does anyone see a connection between the 2 patches and the panic?
> NOTE: the full patches are attached.
> 

I don't think there are relationship between patches and your panic.

BTW, there is other case about the backlog rather than race in alloc_pages()
itself. If someone list_del(&page->lru) and the page is already freed,
you'll see the same backlog later.
Then, I doubt use-after-free case rather than complicated races.

Thanks,
-Kame


> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a596bfd..34a29e2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2551,6 +2551,20 @@ static inline unsigned long
> wait_table_bits(unsigned long size)
>  #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
> 
>  /*
> + * Check if a pageblock contains reserved pages
> + */
> +static int pageblock_is_reserved(unsigned long start_pfn)
> +{
> +	unsigned long end_pfn = start_pfn + pageblock_nr_pages;
> +	unsigned long pfn;
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn++)
> +		if (PageReserved(pfn_to_page(pfn)))
> +			return 1;
> +	return 0;
> +}
> +
> +/*
>   * Mark a number of pageblocks as MIGRATE_RESERVE. The number
>   * of blocks reserved is based on zone->pages_min. The memory within the
>   * reserve will tend to store contiguous free pages. Setting min_free_kbytes
> @@ -2579,7 +2593,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
>  			continue;
> 
>  		/* Blocks with reserved pages will never free, skip them. */
> -		if (PageReserved(page))
> +		if (pageblock_is_reserved(pfn))
>  			continue;
> 
>  		block_migratetype = get_pageblock_migratetype(page);
> -- 
> 1.5.4.3
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5c44ed4..a596bfd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -119,6 +119,7 @@ static char * const zone_names[MAX_NR_ZONES] = {
>  };
> 
>  int min_free_kbytes = 1024;
> +int min_free_order_shift = 1;
> 
>  unsigned long __meminitdata nr_kernel_pages;
>  unsigned long __meminitdata nr_all_pages;
> @@ -1256,7 +1257,7 @@ int zone_watermark_ok(struct zone *z, int order,
> unsigned long mark,
>  		free_pages -= z->free_area[o].nr_free << o;
> 
>  		/* Require fewer higher order pages to be free */
> -		min >>= 1;
> +		min >>= min_free_order_shift;
> 
>  		if (free_pages <= min)
>  			return 0;
> -- 
> 
> 
> On Thu, Apr 1, 2010 at 12:05 PM, TAO HU <tghk48@motorola.com> wrote:
> > Hi, all
> >
> > We got a panic on our ARM (OMAP) based HW.
> > Our code is based on 2.6.29 kernel (last commit for mm/page_alloc.c is
> > cc2559bccc72767cb446f79b071d96c30c26439b)
> >
> > It appears to crash while going through pcp->list in
> > buffered_rmqueue() of mm/page_alloc.c after checking vmlinux.
> > "00100100" implies LIST_POISON1 that suggests a race condition between
> > list_add() and list_del() in my personal view.
> > However we not yet figure out locking problem regarding page.lru.
> >
> > Any known issues about race condition in mm/page_alloc.c?
> > And other hints are highly appreciated.
> >
> > A /* Find a page of the appropriate migrate type */
> > A  A  A  A  A  A  A  A if (cold) {
> > A  A  A  A  A  A  A  A  A  ... ...
> > A  A  A  A  A  A  A  A } else {
> > A  A  A  A  A  A  A  A  A  A  A  A list_for_each_entry(page, &pcp->list, lru)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A if (page_private(page) == migratetype)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A break;
> > A  A  A  A  A  A  A  A }
> >
> > <1>[120898.805267] Unable to handle kernel paging request at virtual
> > address 00100100
> > <1>[120898.805633] pgd = c1560000
> > <1>[120898.805786] [00100100] *pgd=897b3031, *pte=00000000, *ppte=00000000
> > <4>[120898.806457] Internal error: Oops: 17 [#1] PREEMPT
> > ... ...
> > <4>[120898.807861] CPU: 0 A  A Not tainted A (2.6.29-omap1 #1)
> > <4>[120898.808044] PC is at get_page_from_freelist+0x1d0/0x4b0
> > <4>[120898.808227] LR is at get_page_from_freelist+0xc8/0x4b0
> > <4>[120898.808563] pc : [<c00a600c>] A  A lr : [<c00a5f04>] A  A psr: 800000d3
> > <4>[120898.808563] sp : c49fbd18 A ip : 00000000 A fp : c49fbd74
> > <4>[120898.809020] r10: 00000000 A r9 : 001000e8 A r8 : 00000002
> > <4>[120898.809204] r7 : 001200d2 A r6 : 60000053 A r5 : c0507c4c A r4 : c49fa000
> > <4>[120898.809509] r3 : 001000e8 A r2 : 00100100 A r1 : c0507c6c A r0 : 00000001
> > <4>[120898.809844] Flags: Nzcv A IRQs off A FIQs off A Mode SVC_32 A ISA
> > ARM A Segment kernel
> > <4>[120898.810028] Control: 10c5387d A Table: 82160019 A DAC: 00000017
> > <4>[120898.948425] Backtrace:
> > <4>[120898.948760] [<c00a5e3c>] (get_page_from_freelist+0x0/0x4b0)
> > from [<c00a6398>] (__alloc_pages_internal+0xac/0x3e8)
> > <4>[120898.949554] [<c00a62ec>] (__alloc_pages_internal+0x0/0x3e8)
> > from [<c00b461c>] (handle_mm_fault+0x16c/0xbac)
> > <4>[120898.950347] [<c00b44b0>] (handle_mm_fault+0x0/0xbac) from
> > [<c00b51d0>] (__get_user_pages+0x174/0x2b4)
> > <4>[120898.951019] [<c00b505c>] (__get_user_pages+0x0/0x2b4) from
> > [<c00b534c>] (get_user_pages+0x3c/0x44)
> > <4>[120898.951812] [<c00b5310>] (get_user_pages+0x0/0x44) from
> > [<c00caf9c>] (get_arg_page+0x50/0xa4)
> > <4>[120898.952636] [<c00caf4c>] (get_arg_page+0x0/0xa4) from
> > [<c00cb1ec>] (copy_strings+0x108/0x210)
> > <4>[120898.953430] A r7:beffffe4 r6:00000ffc r5:00000000 r4:00000018
> > <4>[120898.954223] [<c00cb0e4>] (copy_strings+0x0/0x210) from
> > [<c00cb330>] (copy_strings_kernel+0x3c/0x74)
> > <4>[120898.955047] [<c00cb2f4>] (copy_strings_kernel+0x0/0x74) from
> > [<c00cc778>] (do_execve+0x18c/0x2b0)
> > <4>[120898.955841] A r5:0001e240 r4:0001e224
> > <4>[120898.956329] [<c00cc5ec>] (do_execve+0x0/0x2b0) from
> > [<c00400e4>] (sys_execve+0x3c/0x5c)
> > <4>[120898.957153] [<c00400a8>] (sys_execve+0x0/0x5c) from
> > [<c003ce80>] (ret_fast_syscall+0x0/0x2c)
> > <4>[120898.957946] A r7:0000000b r6:0001e270 r5:00000000 r4:0001d580
> > <4>[120898.958740] Code: e1530008 0a000006 e2429018 e1a03009 (e5b32018)
> >
> >
> >
> > --
> > Best Regards
> > Hu Tao
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
