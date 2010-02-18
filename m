Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 34D8F6B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 04:39:37 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1I9dXLS015593
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Feb 2010 18:39:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FBEC45DE50
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 18:39:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D432D45DE4F
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 18:39:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA4041DB8038
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 18:39:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 398951DB8040
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 18:39:32 +0900 (JST)
Date: Thu, 18 Feb 2010 18:36:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kernel panic due to page migration accessing memory holes
Message-Id: <20100218183604.95ee8c77.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B7CF8C0.4050105@codeaurora.org>
References: <4B7C8DC2.3060004@codeaurora.org>
	<20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com>
	<4B7CF8C0.4050105@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Bohan <mbohan@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, 18 Feb 2010 00:22:24 -0800
Michael Bohan <mbohan@codeaurora.org> wrote:

> On 2/17/2010 5:03 PM, KAMEZAWA Hiroyuki wrote:
> > On Wed, 17 Feb 2010 16:45:54 -0800
> > Michael Bohan<mbohan@codeaurora.org>  wrote:
> >> As a temporary fix, I added some code to move_freepages_block() that
> >> inspects whether the range exceeds our first memory bank -- returning 0
> >> if it does.  This is not a clean solution, since it requires exporting
> >> the ARM specific meminfo structure to extract the bank information.
> >>
> >>      
> > Hmm, my first impression is...
> >
> > - Using FLATMEM, memmap is created for the number of pages and memmap should
> >    not have aligned size.
> > - Using SPARSEMEM, memmap is created for aligned number of pages.
> >
> > Then, the range [zone->start_pfn ... zone->start_pfn + zone->spanned_pages]
> > should be checked always.
> >
> >
> >   803 static int move_freepages_block(struct zone *zone, struct page *page,
> >   804                                 int migratetype)
> >   805 {
> >   816         if (start_pfn<  zone->zone_start_pfn)
> >   817                 start_page = page;
> >   818         if (end_pfn>= zone->zone_start_pfn + zone->spanned_pages)
> >   819                 return 0;
> >   820
> >   821         return move_freepages(zone, start_page, end_page, migratetype);
> >   822 }
> >
> > "(end_pfn>= zone->zone_start_pfn + zone->spanned_pages)" is checked.
> > What zone->spanned_pages is set ? The zone's range is
> > [zone->start_pfn ... zone->start_pfn+zone->spanned_pages], so this
> > area should have initialized memmap. I wonder zone->spanned_pages is too big.
> >    
> 
> In the block of code above running on my target, the zone_start_pfn is 
> is 0x200 and the spanned_pages is 0x44100.  This is consistent with the 
> values shown from the zoneinfo file below.  It is also consistent with 
> my memory map:
> 
> bank0:
>      start: 0x00200000
>      size:  0x07B00000
> 
> bank1:
>      start: 0x40000000
>      size:  0x04300000
> 
> Thus, spanned_pages here is the highest address reached minus the start 
> address of the lowest bank (eg. 0x40000000 + 0x04300000 - 0x00200000).
> 
> Both of these banks exist in the same zone.  This means that the check 
> in move_freepages_block() will never be satisfied for cases that overlap 
> with the prohibited pfns, since the zone spans invalid pfns.  Should 
> each bank be associated with its own zone?
> 

Hmm. okay then..(CCing Mel.)

 [Fact]
 - There are 2 banks of memory and a memory hole on your machine.
   As
         0x00200000 - 0x07D00000
         0x40000000 - 0x43000000

 - Each bancks are in the same zone.
 - You use FLATMEM.
 - You see panic in move_freepages().
 - Your host's MAX_ORDER=11....buddy allocator's alignment is 0x400000
   Then, it seems 1st bank is not algined.
 - You see panic in move_freepages().
 - When you added special range check for bank0 in move_freepages(), no panic.
   So, it seems the kernel see somehing bad at accessing memmap for a memory 
   hole between bank0 and bank1.


When you use FLATMEM, memmap/migrate-type-bitmap should be allocated for
the whole range of [start_pfn....max_pfn) regardless of memory holes. 
Then, I think you have memmap even for a memory hole [0x07D00000...0x40000000)

Then, the question is why move_freepages() panic at accessing *unused* memmaps
for memory hole. All memmap(struct page) are initialized in 
  memmap_init()
	-> memmap_init_zone()
		-> ....
  Here, all page structs are initialized (page->flags, page->lru are initialized.)

Then, looking back into move_freepages().
 ==
 778         for (page = start_page; page <= end_page;) {
 779                 /* Make sure we are not inadvertently changing nodes */
 780                 VM_BUG_ON(page_to_nid(page) != zone_to_nid(zone));
 781 
 782                 if (!pfn_valid_within(page_to_pfn(page))) {
 783                         page++;
 784                         continue;
 785                 }
 786 
 787                 if (!PageBuddy(page)) {
 788                         page++;
 789                         continue;
 790                 }
 791 
 792                 order = page_order(page);
 793                 list_del(&page->lru);
 794                 list_add(&page->lru,
 795                         &zone->free_area[order].free_list[migratetype]);
 796                 page += 1 << order;
 797                 pages_moved += 1 << order;
 798         }
 ==
Assume an access to page struct itself doesn't cause panic.
Touching page struct's member of page->lru at el to cause panic,
So, PageBuddy should be set.

Then, there are 2 chances.
  1. page_to_nid(page) != zone_to_nid(zone).
  2. PageBuddy() is set by mistake.
     (PG_reserved page never be set PG_buddy.)

For both, something corrupted in unused memmap area.
There are 2 possibility.
 (1) memmap for memory hole was not initialized correctly.
 (2) something wrong currupt memmap. (by overwrite.)

I doubt (2) rather than (1).

One of difficulty here is that your kernel is 2.6.29. Can't you try 2.6.32 and
reproduce trouble ? Or could you check page flags for memory holes ?
For holes, nid should be zero and PG_buddy shouldn't be set and PG_reserved
should be set...

And checking memmap initialization of memory holes in memmap_init_zone() 
may be good start point for debug, I guess.


Off topic:
BTW, memory hole seems huge for your size of memory....using SPARSEMEM
is a choice.

Regards,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
