Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B7F326B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 03:22:41 -0500 (EST)
Message-ID: <4B7CF8C0.4050105@codeaurora.org>
Date: Thu, 18 Feb 2010 00:22:24 -0800
From: Michael Bohan <mbohan@codeaurora.org>
MIME-Version: 1.0
Subject: Re: Kernel panic due to page migration accessing memory holes
References: <4B7C8DC2.3060004@codeaurora.org> <20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On 2/17/2010 5:03 PM, KAMEZAWA Hiroyuki wrote:
> On Wed, 17 Feb 2010 16:45:54 -0800
> Michael Bohan<mbohan@codeaurora.org>  wrote:
>> As a temporary fix, I added some code to move_freepages_block() that
>> inspects whether the range exceeds our first memory bank -- returning 0
>> if it does.  This is not a clean solution, since it requires exporting
>> the ARM specific meminfo structure to extract the bank information.
>>
>>      
> Hmm, my first impression is...
>
> - Using FLATMEM, memmap is created for the number of pages and memmap should
>    not have aligned size.
> - Using SPARSEMEM, memmap is created for aligned number of pages.
>
> Then, the range [zone->start_pfn ... zone->start_pfn + zone->spanned_pages]
> should be checked always.
>
>
>   803 static int move_freepages_block(struct zone *zone, struct page *page,
>   804                                 int migratetype)
>   805 {
>   816         if (start_pfn<  zone->zone_start_pfn)
>   817                 start_page = page;
>   818         if (end_pfn>= zone->zone_start_pfn + zone->spanned_pages)
>   819                 return 0;
>   820
>   821         return move_freepages(zone, start_page, end_page, migratetype);
>   822 }
>
> "(end_pfn>= zone->zone_start_pfn + zone->spanned_pages)" is checked.
> What zone->spanned_pages is set ? The zone's range is
> [zone->start_pfn ... zone->start_pfn+zone->spanned_pages], so this
> area should have initialized memmap. I wonder zone->spanned_pages is too big.
>    

In the block of code above running on my target, the zone_start_pfn is 
is 0x200 and the spanned_pages is 0x44100.  This is consistent with the 
values shown from the zoneinfo file below.  It is also consistent with 
my memory map:

bank0:
     start: 0x00200000
     size:  0x07B00000

bank1:
     start: 0x40000000
     size:  0x04300000

Thus, spanned_pages here is the highest address reached minus the start 
address of the lowest bank (eg. 0x40000000 + 0x04300000 - 0x00200000).

Both of these banks exist in the same zone.  This means that the check 
in move_freepages_block() will never be satisfied for cases that overlap 
with the prohibited pfns, since the zone spans invalid pfns.  Should 
each bank be associated with its own zone?

> Could you check ? (maybe /proc/zoneinfo can show it.)
> Dump of /proc/zoneinfo or dmesg will be helpful.
>    

Here is what I believe to be the relevant pieces from the kernel log:

<7>[    0.000000] On node 0 totalpages: 48640
<7>[    0.000000] free_area_init_node: node 0, pgdat 804875bc, 
node_mem_map 805af000
<7>[    0.000000]   Normal zone: 2178 pages used for memmap
<7>[    0.000000]   Normal zone: 0 pages reserved
<7>[    0.000000]   Normal zone: 46462 pages, LIFO batch:15
<4>[    0.000000] Built 1 zonelists in Zone order, mobility grouping 
on.  Total pages: 46462

# cat /proc/zoneinfo
Node 0, zone   Normal
   pages free     678
         min      431
         low      538
         high     646
         scanned  0 (aa: 0 ia: 0 af: 0 if: 0)
         spanned  278784
         present  46462
         mem_notify_status 0
     nr_free_pages 678
     nr_inactive_anon 8494
     nr_active_anon 8474
     nr_inactive_file 3234
     nr_active_file 2653
     nr_unevictable 71
     nr_mlock     0
     nr_anon_pages 12488
     nr_mapped    7237
     nr_file_pages 10446
     nr_dirty     0
     nr_writeback 0
     nr_slab_reclaimable 293
     nr_slab_unreclaimable 942
     nr_page_table_pages 1365
     nr_unstable  0
     nr_bounce    0
     nr_vmscan_write 0
     nr_writeback_temp 0
         protection: (0, 0)
   pagesets
     cpu: 0
               count: 42
               high:  90
               batch: 15
   all_unreclaimable: 0
   prev_priority:     12
   start_pfn:         512
   inactive_ratio:    1

Thanks,
Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
