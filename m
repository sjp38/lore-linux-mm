Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5A0FE6B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 01:13:48 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1J6Djue014662
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Feb 2010 15:13:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AB4945DE79
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 15:13:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DAC6E45DE4D
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 15:13:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF4691DB8046
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 15:13:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D4D81DB8044
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 15:13:44 +0900 (JST)
Date: Fri, 19 Feb 2010 15:10:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kernel panic due to page migration accessing memory holes
Message-Id: <20100219151012.d430b7ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B7E2635.8010700@codeaurora.org>
References: <4B7C8DC2.3060004@codeaurora.org>
	<20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com>
	<4B7CF8C0.4050105@codeaurora.org>
	<20100218183604.95ee8c77.kamezawa.hiroyu@jp.fujitsu.com>
	<20100218100432.GA32626@csn.ul.ie>
	<4B7DEDB0.8030802@codeaurora.org>
	<20100219110003.dfe58df8.kamezawa.hiroyu@jp.fujitsu.com>
	<4B7E2635.8010700@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Bohan <mbohan@codeaurora.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Feb 2010 21:48:37 -0800
Michael Bohan <mbohan@codeaurora.org> wrote:

> On 2/18/2010 6:00 PM, KAMEZAWA Hiroyuki wrote:
> > memmap for memory holes should be marked as PG_reserved and never be freed
> > by free_bootmem(). Then, memmap for memory holes will not be in buddy allocator.
> >
> > Again, pfn_valid() just show "there is memmap", not for "there is a valid page"
> >    
> 
> ARM seems to have been freeing the memmap holes for a long time.
Ouch.

> I'm pretty sure there would be a lot of pushback if we tried to change 
> that.  For example, in my memory map running FLATMEM, I would be 
> consuming an extra ~7 MB of memory if these structures were not freed.
> 
> As a compromise, perhaps we could free everything except the first 
> 'pageblock_nr_pages' in a hole?  This would guarantee that 
> move_freepages() doesn't deference any memory that doesn't belong to the 
> memmap -- but still only waste a relatively small amount of memory.  For 
> a 4 MB page block, it should only consume an extra 32 KB per hole in the 
> memory map.
> 
No. You have to implement pfn_valid() to return correct value as
"pfn_valid() returnes true if there is memmap." even if you do that.
Otherwise, many things will go bad.

You have 2 or 3 ways.

1. re-implement pfn_valid() which returns correct value.
   maybe not difficult. but please take care of defining CONFIG_HOLES_IN_....
   etc.

2. use DISCONTIGMEM and treat each bank and NUMA node.
   There will be no waste for memmap. But other complication of CONFIG_NUMA.
   
3. use SPARSEMEM.
   You have even 2 choisce here. 
   a - Set your MAX_ORDER and SECTION_SIZE to be proper value.
   b - waste some amount of memory for memmap on the edge of section.
       (and don't free memmap for the edge.)
      
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
