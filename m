Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 845D36B0070
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 03:34:49 -0400 (EDT)
Received: by lahd3 with SMTP id d3so4789248lah.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 00:34:47 -0700 (PDT)
Message-ID: <5045AF14.7040309@openvz.org>
Date: Tue, 04 Sep 2012 11:34:44 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [patch v4]swap: add a simple random read swapin detection
References: <20120827040037.GA8062@kernel.org> <503B8997.4040604@openvz.org> <20120830103612.GA12292@kernel.org> <20120830174223.GB2141@barrios> <20120903072137.GA26821@kernel.org> <20120903083245.GA7674@bbox> <20120903114631.GA5410@kernel.org> <5044FEE3.4050009@openvz.org> <5044FF89.5090400@redhat.com>
In-Reply-To: <5044FF89.5090400@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>

Rik van Riel wrote:
> On 09/03/2012 03:02 PM, Konstantin Khlebnikov wrote:
>> Shaohua Li wrote:
>>> On Mon, Sep 03, 2012 at 05:32:45PM +0900, Minchan Kim wrote:
>>> Subject: swap: add a simple random read swapin detection
>>>
>>> The swapin readahead does a blind readahead regardless if the swapin is
>>> sequential. This is ok for harddisk and random read, because read big
>>> size has
>>> no penality in harddisk, and if the readahead pages are garbage, they
>>> can be
>>> reclaimed fastly. But for SSD, big size read is more expensive than
>>> small size
>>> read. If readahead pages are garbage, such readahead only has overhead.
>>>
>>> This patch addes a simple random read detection like what file mmap
>>> readahead
>>> does. If random read is detected, swapin readahead will be skipped. This
>>> improves a lot for a swap workload with random IO in a fast SSD.
>>>
>>> I run anonymous mmap write micro benchmark, which will triger
>>> swapin/swapout.
>>>              runtime changes with path
>>> randwrite harddisk    -38.7%
>>> seqwrite harddisk    -1.1%
>>> randwrite SSD        -46.9%
>>> seqwrite SSD        +0.3%
>>>
>>> For both harddisk and SSD, the randwrite swap workload run time is
>>> reduced
>>> significant. sequential write swap workload hasn't chanage.
>>>
>>> Interesting is the randwrite harddisk test is improved too. This might be
>>> because swapin readahead need allocate extra memory, which further tights
>>> memory pressure, so more swapout/swapin.
>>
>> Generally speaking swapin readahread isn't usable while system is under
>> memory
>> pressure. Cache hit isn't very probable, because reclaimer allocates swap
>> entries in page-LRU order.
>>
>> But swapin readahead is very useful if system recovers from memory
>> pressure,
>> it helps to read whole swap back to memory (a sort of desktop scenario).
>>
>> So, I think we can simply disable swapin readahead while system is under
>> memory
>> pressure. For example in time-based manner -- enable it only after grace
>> period
>> after last swap_writepage().
>
> Determining "under memory pressure" is pretty hard to do.

Indeed. But swapin readahead is mostly useless if system hasn't free memory.
So condition can be simply time-based (above) or nr_free_pages()-based,
or can provide some hints from reclaimer/page-allocator.

[readahead also useful in swapoff, but it doesn't use it for now]

>
> However, Shaohua's patch provides an easy way to see whether swap
> readahead is helping (we are getting pages from the swap cache),
> or whether it is not (pages got evicted before someone faulted on
> them).
>

[
BTW we can use readahead bit in page-flags: mark readahead pages with 
SetPageReadahead() and gather these marks in do_swap_page()
if (TestClearReadahead(page))
	swap_headahead_hit(vma);
]

> In short, Shaohua's patch not only does roughly what you want, it
> does it in a simple way.
>

It disables reahahead if it is ineffective in one particular VMA,
but in recovering-case this does not important -- we really want to read
whole swap back, no matter which VMA around pages belongs to.
[BTW this case was mentioned in you patch which added skipping-over-holes]

And its metric is strange, looks like it just disables headahead for all VMAs
after hundred swapins and never enables it back. Why we cannot disable it from
the beginning and turn it on when needed? This ways is even more simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
