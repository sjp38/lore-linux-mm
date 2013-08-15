Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A69B46B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 07:23:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 15 Aug 2013 21:13:31 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9E4323578050
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 21:23:42 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7FBNOa47012842
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 21:23:31 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7FBNYdN008878
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 21:23:34 +1000
Date: Thu, 15 Aug 2013 19:23:32 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130815112331.GA26134@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130814163921.GC2706@gmail.com>
 <20130814180012.GO2296@suse.de>
 <520C3DD2.8010905@huawei.com>
 <20130815024427.GA2718@gmail.com>
 <520C4EFF.8040305@huawei.com>
 <20130815041736.GA2592@gmail.com>
 <20130815042434.GA3139@gmail.com>
 <520C8707.4000100@huawei.com>
 <20130815095102.GA4449@hacker.(null)>
 <520CB84D.6000306@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520CB84D.6000306@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 15, 2013 at 07:15:25PM +0800, Xishi Qiu wrote:
>On 2013/8/15 17:51, Wanpeng Li wrote:
>
>> On Thu, Aug 15, 2013 at 03:45:11PM +0800, Xishi Qiu wrote:
>>> On 2013/8/15 12:24, Minchan Kim wrote:
>>>
>>>>> Please read full thread in detail.
>>>>>
>>>>> Mel suggested following as
>>>>>
>>>>> if (PageBuddy(page)) {
>>>>>         int nr_pages = (1 << page_order(page)) - 1;
>>>>>         if (PageBuddy(page)) {
>>>>>                 nr_pages = min(nr_pages, MAX_ORDER_NR_PAGES - 1);
>>>>>                 low_pfn += nr_pages;
>>>>>                 continue;
>>>>>         }
>>>>> }
>>>>>
>>>>> min(nr_pages, xxx) removes your concern but I think Mel's version
>>>>> isn't right. It should be aligned with pageblock boundary so I 
>>>>> suggested following.
>>>>>
>>>>> if (PageBuddy(page)) {
>>>>> #ifdef CONFIG_MEMORY_ISOLATION
>>>>> 	unsigned long order = page_order(page);
>>>>> 	if (PageBuddy(page)) {
>>>>> 		low_pfn += (1 << order) - 1;
>>>>> 		low_pfn = min(low_pfn, end_pfn);
>>>>> 	}
>>>>> #endif
>>>>> 	continue;
>>>>> }
>>>>>
>>>
>>> Hi Minchan,
>>>
>>> I understand now, but why use "end_pfn" here? 
>>> Maybe like this:
>>>
>>> if (PageBuddy(page)) {
>>> 	/*
>>> 	 * page_order is racy without zone->lock but worst case
>>> 	 * by the racing is just skipping pageblock_nr_pages.
>>> 	 */
>>> 	unsigned long nr_pages = 1 << page_order(page);
>>> 	if (likely(PageBuddy(page))) {
>>> 		nr_pages = min(nr_pages, MAX_ORDER_NR_PAGES);
>> 
>> How much sense it make? nr_pages is still equal to itself since nr_pages can't 
>> larger than MAX_ORDER_NR_PAGES.
>> 
>
>Hi Wanpeng,
>
>Mel pointed "page_order cannot be used unless zone->lock is held".
>"Even if the page is still page buddy, there is no guarantee that it's
>the same page order as the first read. It could have be currently merging 
>with adjacent buddies for example."
>
>If someone use the page during the double PageBuddy check, the value
>of private may be wrong. In my opinion, just keep the code unchanged.
>

Hi Xishi,

You miss my point, I mean nr_pages = min(nr_pages, MAX_ORDER_NR_PAGES); not 
make sense since nr_pages can't larger then MAX_ORDER_NR_PAGES. 

Regards,
Wanpeng Li 

>Thanks,
>Xishi Qiu
>
>>>
>>> 		/* Align with pageblock boundary */
>>> 		if ((low_pfn & (pageblock_nr_pages - 1)) + nr_pages >
>>> 		    pageblock_nr_pages)
>>> 			low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
>>> 		else
>>> 			low_pfn += nr_pages - 1;
>>> 	}
>>> 	continue;
>>> }
>>>
>>> Thanks,
>>> Xishi Qiu
>>>
>>>>> so worst case is (pageblock_nr_pages - 1).
>>>>> but we don't need to add CONFIG_MEMORY_ISOLATION so my suggestion
>>>>> is following as.
>>>>>
>>>>> if (PageBuddy(page)) {
>>>>> 	unsigned long order = page_order(page);
>>>>> 	if (PageBuddy(page)) {
>>>>> 		low_pfn += (1 << order) - 1;
>>>>> 		low_pfn = min(low_pfn, end_pfn);
>>>>
>>>> Maybe it should be low_pfn = min(low_pfn, end_pfn - 1).
>>>>
>>>>
>>>>> 	}
>>>>> 	continue;
>>>>> }
>>>>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
