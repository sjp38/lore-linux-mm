Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 9D04D6B0044
	for <linux-mm@kvack.org>; Sun,  8 Apr 2012 22:04:41 -0400 (EDT)
Message-ID: <4F82443F.9000804@kernel.org>
Date: Mon, 09 Apr 2012 11:06:55 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: swap on eMMC and other flash
References: <201203301744.16762.arnd@arndb.de> <CAEwNFnA2GeOayw2sJ_KXv4qOdC50_Nt2KoK796YmQF+YV1GiEA@mail.gmail.com> <201204061616.11716.arnd@arndb.de>
In-Reply-To: <201204061616.11716.arnd@arndb.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, android-kernel@googlegroups.com, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>

2012-04-07 i??i ? 1:16, Arnd Bergmann i?' e,?:

> On Friday 06 April 2012, Minchan Kim wrote:
>> On Sat, Mar 31, 2012 at 2:44 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>>
>>> We've had a discussion in the Linaro storage team (Saugata, Venkat and me,
>>> with Luca joining in on the discussion) about swapping to flash based media
>>> such as eMMC. This is a summary of what we found and what we think should
>>> be done. If people agree that this is a good idea, we can start working
>>> on it.
>>>
>>> The basic problem is that Linux without swap is sort of crippled and some
>>> things either don't work at all (hibernate) or not as efficient as they
>>> should (e.g. tmpfs). At the same time, the swap code seems to be rather
>>> inappropriate for the algorithms used in most flash media today, causing
>>> system performance to suffer drastically, and wearing out the flash
>>> hardware
>>> much faster than necessary. In order to change that, we would be
>>> implementing the following changes:
>>>
>>> 1) Try to swap out multiple pages at once, in a single write request. My
>>> reading of the current code is that we always send pages one by one to
>>> the swap device, while most flash devices have an optimum write size of
>>> 32 or 64 kb and some require an alignment of more than a page. Ideally
>>> we would try to write an aligned 64 kb block all the time. Writing aligned
>>> 64 kb chunks often gives us ten times the throughput of linear 4kb writes,
>>> and going beyond 64 kb usually does not give any better performance.
>>>
>>
>> It does make sense.
>> I think we can batch will-be-swapped-out pages in shrink_page_list if they
>> are located by contiguous swap slots.
> 
> But would that guarantee that all writes are the same size? While writing


Of course, not.

> larger chunks would generally be helpful, in order to guarantee that we
> the drive doesn't do any garbage collection, we would have to do all writes


And we should guarantee for avoiding unnecessary swapout, even OOM killing.

> in aligned chunks. It would probably be enough to do this in 8kb or
> 16kb units for most devices over the next few years, but implementing it
> for 64kb should be the same amount of work and will get us a little bit
> further.


I understand it's best for writing 64K in your statement.
What the 8K, 16K? Could you elaborate relation between 8K, 16K and 64K?

> 
> I'm not sure what we would do when there are less than 64kb available
> for pageout on the inactive list. The two choices I can think of are
> either not writing anything, or wasting the swap slots and filling


No wrtite will cause unnecessary many pages to swap out by next prioirty
of scanning and we can't gaurantee how long we wait to queue up to 64KB
in anon pages. It might take longer than GC time so we need some deadline.


> up the data with zeroes.


Zero padding would be a good solution but I have a concern on WAP so we
need smart policy.

To be honest, I think swapout is normally asynchonous operation so that
it should not affect system latency rather than swap read which is
synchronous operation. So if system is low memory pressure, we can queue
swap out pages up to 64KB and then batch write-out in empty cluster. If
we don't have any empty cluster in low memory pressure, we should write
out it in partial cluster. Maybe it doesn't affect system latency
severely in low memory pressure.

If system memory pressure is high(and It shoud be not frequent),
swap-out B/W would be more important. So we can reserve some clusters
for it and I think we can use page padding you mentioned in this case
for reducing latency if we can queue it up to 64KB within threshold time.

Swap-read is also important. We have to investigate fragmentation of
swap slots because we disable swap readahead in non-rotation device. It
can make lots of hole in swap cluster and it makes to find empty
cluster. So for it, it might be better than enable swap-read in
non-rotation devices, too.


> 
>>> 2) Make variable sized swap clusters. Right now, the swap space is
>>> organized in clusters of 256 pages (1MB), which is less than the typical
>>> erase block size of 4 or 8 MB. We should try to make the swap cluster
>>> aligned to erase blocks and have the size match to avoid garbage collection
>>> in the drive. The cluster size would typically be set by mkswap as a new
>>> option and interpreted at swapon time.
>>>
>>
>> If we can find such big contiguous swap slots easily, it would be good.
>> But I am not sure how often we can get such big slots. And maybe we have to
>> improve search method for getting such big empty cluster.
> 
> As long as there are clusters available, we should try to find them. When
> free space is too fragmented to find any unused cluster, we can pick one
> that has very little data in it, so that we reduce the time it takes to
> GC that erase block in the drive. While we could theoretically do active
> garbage collection of swap data in the kernel, it won't get more efficient
> than the GC inside of the drive. If we do this, it unfortunately means that
> we can't just send a discard for the entire erase block.


Might need some compaction during idle time but WAP concern raises again. :(

> 
> 	Arnd
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
