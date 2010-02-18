Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DCFBB6B008C
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 20:07:03 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1I16xSR005305
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Feb 2010 10:06:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3177045DE51
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 10:06:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0327345DE4E
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 10:06:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D96FA1DB8038
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 10:06:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 82B731DB803F
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 10:06:58 +0900 (JST)
Date: Thu, 18 Feb 2010 10:03:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kernel panic due to page migration accessing memory holes
Message-Id: <20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B7C8DC2.3060004@codeaurora.org>
References: <4B7C8DC2.3060004@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Bohan <mbohan@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010 16:45:54 -0800
Michael Bohan <mbohan@codeaurora.org> wrote:

> Hi,
> 
> I have encountered a kernel panic on the ARM/msm platform in the mm 
> migration code on 2.6.29.  My memory configuration has two discontiguous 
> banks per our ATAG definition.   These banks end up on addresses that 
> are 1 MB aligned.  I am using FLATMEM (not SPARSEMEM), but my 
> understanding is that SPARSEMEM should not be necessary to support this 
> configuration.  Please correct me if I'm wrong.
> 
> The crash occurs in mm/page_alloc.c:move_freepages() when being passed a 
> start_page that corresponds to the last several megabytes of our first 
> memory bank.  The code in move_freepages_block() aligns the passed in 
> page number to pageblock_nr_pages, which corresponds to 4 MB.  It then 
> passes that aligned pfn as the beginning of a 4 MB range to 
> move_freepages().  The problem is that since our bank's end address is 
> not 4 MB aligned, the range passed to move_freepages() exceeds the end 
> of our memory bank.  The code later blows up when trying to access 
> uninitialized page structures.
> 
That should be aligned, I think.

> As a temporary fix, I added some code to move_freepages_block() that 
> inspects whether the range exceeds our first memory bank -- returning 0 
> if it does.  This is not a clean solution, since it requires exporting 
> the ARM specific meminfo structure to extract the bank information.
> 
Hmm, my first impression is...

- Using FLATMEM, memmap is created for the number of pages and memmap should
  not have aligned size.
- Using SPARSEMEM, memmap is created for aligned number of pages.

Then, the range [zone->start_pfn ... zone->start_pfn + zone->spanned_pages]
should be checked always.


 803 static int move_freepages_block(struct zone *zone, struct page *page,
 804                                 int migratetype)
 805 {
 816         if (start_pfn < zone->zone_start_pfn)
 817                 start_page = page;
 818         if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages)
 819                 return 0;
 820 
 821         return move_freepages(zone, start_page, end_page, migratetype);
 822 }

"(end_pfn >= zone->zone_start_pfn + zone->spanned_pages)" is checked. 
What zone->spanned_pages is set ? The zone's range is
[zone->start_pfn ... zone->start_pfn+zone->spanned_pages], so this
area should have initialized memmap. I wonder zone->spanned_pages is too big.

Could you check ? (maybe /proc/zoneinfo can show it.)
Dump of /proc/zoneinfo or dmesg will be helpful.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
