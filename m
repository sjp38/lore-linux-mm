Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D87296B02A7
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 05:57:58 -0400 (EDT)
Date: Fri, 30 Jul 2010 10:57:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: why depends on HUGETLB_PAGE
Message-ID: <20100730095740.GD3571@csn.ul.ie>
References: <D25878F935704D9281E62E0393CAD951@rainbow> <20100729125725.GA3571@csn.ul.ie> <545904F46F6C4026A234512CEAED30AE@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <545904F46F6C4026A234512CEAED30AE@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 11:56:25AM +0900, Iram Shahzad wrote:
> Mel Gorman wrote:
>>> My question is: why does it depend on CONFIG_HUGETLB_PAGE?
>>
>> Because as the Kconfig says "Allows the compaction of memory for the
>> allocation of huge pages.". Depending on compaction to satisfy other
>> high-order allocation types is not likely to be a winning strategy.
>
> Please could you elaborate a little more why depending on
> compaction to satisfy other high-order allocation is not good.
>

At the very least, it's not a situation that has been tested heavily and
because other high-order allocations are typically not movable. In the
worst case, if they are both frequent and long-lived they *may* eventually
encounter fragmentation-related problems. This uncertainity is why it's
not good. It gets worse if there is no swap as eventually all movable pages
will be compacted as much as possible but there still might not be enough
contiguous memory for a high-order page because other pages are pinned.

>>> Is it wrong to use it on ARM by disabling CONFIG_HUGETLB_PAGE?
>>>
>>
>> It depends on why you need compaction. If it's for some device that
>> requires high-order allocations (particularly if they are atomic), then
>> it's not likely to work very well in the long term.
>
> Would you please elaborate on this as well.
>

In the case the allocation is atomic and there isn't a suitable page
available, compaction cannot occur either. Given enough uptime, there
will be failure reports as a result. Avoid high-order allocations where
possible.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
