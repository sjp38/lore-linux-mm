Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D42EE6B0036
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 00:48:23 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so4713536pad.23
        for <linux-mm@kvack.org>; Sun, 06 Jul 2014 21:48:23 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id au10si40235446pbd.14.2014.07.06.21.48.21
        for <linux-mm@kvack.org>;
        Sun, 06 Jul 2014 21:48:22 -0700 (PDT)
Date: Mon, 7 Jul 2014 13:53:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: NR_FREE_CMA_PAGES larger than total CMA size
Message-ID: <20140707045349.GB29236@js1304-P5Q-DELUXE>
References: <89813612683626448B837EE5A0B6A7CB455AEB75CF@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89813612683626448B837EE5A0B6A7CB455AEB75CF@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Jul 05, 2014 at 01:13:17AM -0700, Lisa Du wrote:
> Dear Sir
> Recently I met one issue that after system run for a long time, free cma pages recorded
> in vm_stat[NR_FREE_CMA_PAGES] are larger than total CMA size declared.
> For example, I declared 64MB CMA size, but found free cma was 70MB.
> 
> I added some trace to track how it happen, and found the reason maybe like below:
> 1) alloc_contig_range() want to allocate a range [start, end], for example [0x1e040, 0x1e050];
> 
> 2) start_isolate_page_range() will isolate the range [pfn_max_align_down(start),
>   pfn_max_align_up(end)]; for this example it's [0x1e000, 0x1e400] (MAX_ORDER is 11);
> 
> 3) drain_all_pages() would be called as follows, if there's some pages belong to the range
>   [0x1e000, 0x1e400] was freed from the pcp_list, also if the page was MIGRATE_CMA,
>   then vm_stat[NR_FREE_CMA_PAGES] would increase and also NR_FREE_PAGES;
> 
> 4) if the freed pages in #3 was not the range of [start, end], then at last undo_isolate_page_range()
>   will be called, and the pages would be calculated again as free pages in unset_migratetype_isolate(),
>   and __mod_zone_freepage_state() will increased again for these pages for both NR_FREE_CMA_PAGES
>   and NR_FREE_PAGES. 
>   The function calling flow as below, the free pages in move_freepages() was calculated again.
>   undo_isolate_page_range()
> 	--> unset_migratetype_isolate()
> 		--> move_freepages_block()
> 			--> move_freepages()
> 	--> __mod_zone_freepage_state()
> 
> Shall we add some check in move_freepages() if the page was already in CMA free list, 
> then exclude it from the pages_moved?
> 
> I found this issue in kernel v3.4, but seems there's no fix in latest kernel code base.
> Not sure if anyone else has met such issue? Anyone would help to comment? Thanks a lot!

Hello,

Maybe this bug is relevant for my recent patchset.
I don't have much time to investigate your problem, so
if you have interest on my patchset, please look at it on below link

https://lkml.org/lkml/2014/7/4/79

If they work for you, please let me know. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
