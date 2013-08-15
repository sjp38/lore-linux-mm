Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 11EEB6B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 00:00:14 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 15 Aug 2013 09:23:44 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 00777E004F
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 09:30:22 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7F41Jrd40566916
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 09:31:19 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7F3xvUl008988
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 09:29:58 +0530
Date: Thu, 15 Aug 2013 11:59:56 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130815035956.GA30820@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <520B0B75.4030708@huawei.com>
 <20130814085711.GK2296@suse.de>
 <20130814155205.GA2706@gmail.com>
 <20130814161642.GM2296@suse.de>
 <20130814163921.GC2706@gmail.com>
 <20130814180012.GO2296@suse.de>
 <520C3DD2.8010905@huawei.com>
 <20130815024427.GA2718@gmail.com>
 <520C4EFF.8040305@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520C4EFF.8040305@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 15, 2013 at 11:46:07AM +0800, Xishi Qiu wrote:
>On 2013/8/15 10:44, Minchan Kim wrote:
>
>> Hi Xishi,
>> 
>> On Thu, Aug 15, 2013 at 10:32:50AM +0800, Xishi Qiu wrote:
>>> On 2013/8/15 2:00, Mel Gorman wrote:
>>>
>>>>>> Even if the page is still page buddy, there is no guarantee that it's
>>>>>> the same page order as the first read. It could have be currently
>>>>>> merging with adjacent buddies for example. There is also a really
>>>>>> small race that a page was freed, allocated with some number stuffed
>>>>>> into page->private and freed again before the second PageBuddy check.
>>>>>> It's a bit of a hand grenade. How much of a performance benefit is there
>>>>>
>>>>> 1. Just worst case is skipping pageblock_nr_pages
>>>>
>>>> No, the worst case is that page_order returns a number that is
>>>> completely garbage and low_pfn goes off the end of the zone
>>>>
>>>>> 2. Race is really small
>>>>> 3. Higher order page allocation customer always have graceful fallback.
>>>>>
>>>
>>> Hi Minchan, 
>>> I think in this case, we may get the wrong value from page_order(page).
>>>
>>> 1. page is in page buddy
>>>
>>>> if (PageBuddy(page)) {
>>>
>>> 2. someone allocated the page, and set page->private to another value
>>>
>>>> 	int nr_pages = (1 << page_order(page)) - 1;
>>>
>>> 3. someone freed the page
>>>
>>>> 	if (PageBuddy(page)) {
>>>
>>> 4. we will skip wrong pages
>> 
>> So, what's the result by that?
>> As I said, it's just skipping (pageblock_nr_pages -1) at worst case
>
>Hi Minchan,
>I mean if the private is set to a large number, it will skip 2^private 
>pages, not (pageblock_nr_pages -1). I find somewhere will use page->private, 
>such as fs. Here is the comment about parivate.

There is PageBuddy() check. 

>/* Mapping-private opaque data:
> * usually used for buffer_heads
> * if PagePrivate set; used for
> * swp_entry_t if PageSwapCache;
> * indicates order in the buddy
> * system if PG_buddy is set.
> */
>Thanks,
>Xishi Qiu
>
>> and the case you mentioned is right academically and I and Mel
>> already pointed out that. But how often could that happen in real
>> practice? I believe such is REALLY REALLY rare.
>> So, as Mel said, if you have some workloads to see the benefit
>> from this patch, I think we could accept the patch.
>> Could you try and respin with the number?
>> I guess big contigous memory range or memory-hotplug which are
>> full of free pages in embedded CPU which is rather slower than server
>> or desktop side could have benefit.
>> 
>> Thanks.
>> 
>>>
>>>> 		nr_pages = min(nr_pages, MAX_ORDER_NR_PAGES - 1);
>>>> 		low_pfn += nr_pages;
>>>> 		continue;
>>>> 	}
>>>> }
>>>>
>>>> It's still race-prone meaning that it really should be backed by some
>>>> performance data justifying it.
>>>>
>>>
>>>
>>>
>> 
>
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
