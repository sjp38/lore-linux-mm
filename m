Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3196B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 07:10:34 -0400 (EDT)
Date: Tue, 17 Aug 2010 12:10:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100817111018.GQ19797@csn.ul.ie>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <325E0A25FE724BA18190186F058FF37E@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 08:08:54PM +0900, Iram Shahzad wrote:
> Hi
>
> I am trying to understand the following code in isolate_migratepages
> function. I have a question regarding this.
>
> ---
> while (unlikely(too_many_isolated(zone))) {
>  congestion_wait(BLK_RW_ASYNC, HZ/10);
>
>  if (fatal_signal_pending(current))
>   return 0;
> }
>
> ---
>
> I have seen that in some cases this while loop never exits
> because too_many_isolated keeps returning true for ever.
> And hence the process hangs. Is this intended behaviour?

No. Under what circumstances does it get stuck forever. It's similar
logic to what's in page reclaim except there parallel processes such as
kswapd or direct reclaimers would eventually release isolated pages.

> What is it that is supposed to change the "too_many_isolated" situation?

Parallel reclaimers or compaction processes releasing the pages they
have isolated from the LRU.

> In other words, what is it that is supposed to increase the "inactive"
> or decrease the "isolated" so that isolated > inactive becomes false?
>

See places that update the NR_ISOLATED_ANON and NR_ISOLATED_FILE
counters.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
