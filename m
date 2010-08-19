Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA066B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 03:46:19 -0400 (EDT)
Date: Thu, 19 Aug 2010 08:46:02 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100819074602.GW19797@csn.ul.ie>
References: <325E0A25FE724BA18190186F058FF37E@rainbow> <20100817111018.GQ19797@csn.ul.ie> <4385155269B445AEAF27DC8639A953D7@rainbow> <20100818154130.GC9431@localhost> <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 04:09:38PM +0900, Iram Shahzad wrote:
>> The loop should be waiting for the _other_ processes (doing direct
>> reclaims) to proceed.  When there are _lots of_ ongoing page
>> allocations/reclaims, it makes sense to wait for them to calm down a bit?
>
> I have noticed that if I run other process, it helps the loop to exit.
> So is this (ie hanging until other process helps) intended behaviour?
>

No, it's not but I'm not immediately seeing how it would occur either.
too_many_isolated() should only be true when there are multiple
processes running that are isolating pages be it due to reclaim or
compaction. These should be finishing their work after some time so
while a process may stall in too_many_isolated(), it should not stay
there forever.

The loop around isolate_migratepages() puts back LRU pages it failed to
migrate so it's not the case that the compacting process is isolating a
large number of pages and then calling too_many_isolated() against itself.

> Also, the other process does help the loop to exit, but again it enters
> the loop and the compaction is never finished. That is, the process
> looks like hanging. Is this intended behaviour?

Infinite loops are never intended behaviour.

> What will improve this situation?

What is your test scenario? Who or what has these pages isolated that is
allowing too_many_isolated() to be true?

I'm not seeing how processes could isolate a large number of pages and
hold onto them for a long time but knowing the test scenario might help.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
