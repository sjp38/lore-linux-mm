Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 50C2C6B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:41:19 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so1717663pdj.7
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:41:19 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id nt1si4267919pbc.196.2014.12.09.17.41.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:41:17 -0800 (PST)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2E4313EE1AB
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 10:41:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 42B2DAC046B
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 10:41:14 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3508E08002
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 10:41:13 +0900 (JST)
Message-ID: <5487A418.4060800@jp.fujitsu.com>
Date: Wed, 10 Dec 2014 10:38:32 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone
References: <1418153696-167580-1-git-send-email-jcuster@sgi.com>,<54878D56.4030508@jp.fujitsu.com> <E0FB9EDDBE1AAD4EA62C90D3B6E4783B739E643B@P-EXMB2-DC21.corp.sgi.com>
In-Reply-To: <E0FB9EDDBE1AAD4EA62C90D3B6E4783B739E643B@P-EXMB2-DC21.corp.sgi.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Custer <jcuster@sgi.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Russ Anderson <rja@sgi.com>, Derek Fults <dfults@sgi.com>

(2014/12/10 9:14), James Custer wrote:
> It is exactly the same if CONFIG_HOLES_IN_NODE is set, but if CONFIG_HOLES_IN_NODE is not set, then pfn_valid_within is always 1.

Why don't you set CONFIG_HOLES_IN_ZONE? This BUG is occrred by hole in zone.
CONFIG_HOLE_IN_ZONE is propered for the system.

I think your patch fixes the BUG. But even if fixing the BUG, other issues
will be occurred by hole in zone.

Thanks,
Yasuaki Ishimatsu

>
> From: https://lkml.org/lkml/2007/3/21/272
>
> "Generally we work under the assumption that memory the mem_map
> array is contigious and valid out to MAX_ORDER_NR_PAGES block
> of pages, ie. that if we have validated any page within this
> MAX_ORDER_NR_PAGES block we need not check any other.  This is not
> true when CONFIG_HOLES_IN_ZONE is set and we must check each and
> every reference we make from a pfn.
>
> Add a pfn_valid_within() helper which should be used when scanning
> pages within a MAX_ORDER_NR_PAGES block when we have already
> checked the validility of the block normally with pfn_valid().
> This can then be optimised away when we do not have holes within
> a MAX_ORDER_NR_PAGES block of pages."
>
> So, since we're iterating over a pageblock there must be a valid pfn to be able to use pfn_valid_within (which makes sense since if CONFIG_HOLES_IN_NODE is not set, it is always 1).
>
> I'm just going off of the documentation there and what makes sense to me based off that documentation. Does that explanation help?
>
> Regards,
> James Custer
> ________________________________________
> From: Yasuaki Ishimatsu [isimatu.yasuaki@jp.fujitsu.com]
> Sent: Tuesday, December 09, 2014 6:01 PM
> To: James Custer; linux-kernel@vger.kernel.org; linux-mm@kvack.org; akpm@linux-foundation.org; kamezawa.hiroyu@jp.fujitsu.com
> Cc: Russ Anderson; Derek Fults
> Subject: Re: [PATCH] mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone
>
> (2014/12/10 4:34), James Custer wrote:
>> Offlining memory by 'echo 0 > /sys/devices/system/memory/memory#/online'
>> or reading valid_zones 'cat /sys/devices/system/memory/memory#/valid_zones'
>
>> causes BUG: unable to handle kernel paging request due to invalid use of
>> pfn_valid_within. This is due to a bug in test_pages_in_a_zone.
>
> The information is not enough to understand what happened on your system.
> Could you show full BUG messages?
>
>>
>> In order to use pfn_valid_within within a MAX_ORDER_NR_PAGES block of pages,
>> a valid pfn within the block must first be found. There only needs to be
>> one valid pfn found in test_pages_in_a_zone in the first place. So the
>> fix is to replace pfn_valid_within with pfn_valid such that the first
>> valid pfn within the pageblock is found (if it exists). This works
>> independently of CONFIG_HOLES_IN_ZONE.
>>
>> Signed-off-by: James Custer <jcuster@sgi.com>
>> ---
>>    mm/memory_hotplug.c | 11 ++++++-----
>>    1 file changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 1bf4807..304c187 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1331,7 +1331,7 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>>    }
>>
>>    /*
>> - * Confirm all pages in a range [start, end) is belongs to the same zone.
>> + * Confirm all pages in a range [start, end) belong to the same zone.
>>     */
>>    int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>>    {
>> @@ -1342,10 +1342,11 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>>        for (pfn = start_pfn;
>>             pfn < end_pfn;
>>             pfn += MAX_ORDER_NR_PAGES) {
>
>> -             i = 0;
>> -             /* This is just a CONFIG_HOLES_IN_ZONE check.*/
>> -             while ((i < MAX_ORDER_NR_PAGES) && !pfn_valid_within(pfn + i))
>> -                     i++;
>> +             /* Find the first valid pfn in this pageblock */
>> +             for (i = 0; i < MAX_ORDER_NR_PAGES; i++) {
>> +                     if (pfn_valid(pfn + i))
>> +                             break;
>> +             }
>
> If CONFIG_HOLES_IN_NODE is set, there is no difference. Am I making a mistake?
>
> Thanks,
> Yasuaki Ishimatsu
>
>
>>                if (i == MAX_ORDER_NR_PAGES)
>>                        continue;
>>                page = pfn_to_page(pfn + i);
>>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
