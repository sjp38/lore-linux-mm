Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8D6876B01F5
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 04:08:35 -0400 (EDT)
Date: Thu, 19 Aug 2010 16:08:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100819080830.GA17899@localhost>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
 <20100817111018.GQ19797@csn.ul.ie>
 <4385155269B445AEAF27DC8639A953D7@rainbow>
 <20100818154130.GC9431@localhost>
 <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
 <20100819074602.GW19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819074602.GW19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 03:46:02PM +0800, Mel Gorman wrote:
> On Thu, Aug 19, 2010 at 04:09:38PM +0900, Iram Shahzad wrote:
> >> The loop should be waiting for the _other_ processes (doing direct
> >> reclaims) to proceed.  When there are _lots of_ ongoing page
> >> allocations/reclaims, it makes sense to wait for them to calm down a bit?
> >
> > I have noticed that if I run other process, it helps the loop to exit.
> > So is this (ie hanging until other process helps) intended behaviour?
> >
> 
> No, it's not but I'm not immediately seeing how it would occur either.
> too_many_isolated() should only be true when there are multiple
> processes running that are isolating pages be it due to reclaim or
> compaction. These should be finishing their work after some time so
> while a process may stall in too_many_isolated(), it should not stay
> there forever.
> 
> The loop around isolate_migratepages() puts back LRU pages it failed to
> migrate so it's not the case that the compacting process is isolating a
> large number of pages and then calling too_many_isolated() against itself.

It seems the compaction process isolates 128MB pages at a time? That
sounds risky, too_many_isolated() can easily be true, which will stall
direct reclaim processes. I'm not seeing how exactly it makes
compaction itself stall infinitely though.

> > Also, the other process does help the loop to exit, but again it enters
> > the loop and the compaction is never finished. That is, the process
> > looks like hanging. Is this intended behaviour?
> 
> Infinite loops are never intended behaviour.

Yup.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
