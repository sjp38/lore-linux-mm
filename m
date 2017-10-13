Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB706B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 07:42:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so8259432pfk.0
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 04:42:57 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 69si494423pfh.27.2017.10.13.04.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Oct 2017 04:42:54 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
In-Reply-To: <d29b6788-da1b-23e9-090c-d43428deb97d@suse.cz>
References: <20170918070834.13083-1-mhocko@kernel.org> <20170918070834.13083-2-mhocko@kernel.org> <87bmlfw6mj.fsf@concordia.ellerman.id.au> <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz> <87infmz9xd.fsf@concordia.ellerman.id.au> <20171011065123.e7jvoftmtso3vcha@dhcp22.suse.cz> <d29b6788-da1b-23e9-090c-d43428deb97d@suse.cz>
Date: Fri, 13 Oct 2017 22:42:46 +1100
Message-ID: <87bmlbtgsp.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Vlastimil Babka <vbabka@suse.cz> writes:
> On 10/11/2017 08:51 AM, Michal Hocko wrote:
>> On Wed 11-10-17 13:37:50, Michael Ellerman wrote:
>>> Michal Hocko <mhocko@kernel.org> writes:
>>>> On Tue 10-10-17 23:05:08, Michael Ellerman wrote:
>>>>> Michal Hocko <mhocko@kernel.org> writes:
>>>>>> From: Michal Hocko <mhocko@suse.com>
>>>>>>
>>>>>> Memory offlining can fail just too eagerly under a heavy memory pressure.
...
>>>>>
>>>>> This breaks offline for me.
>>>>>
>>>>> Prior to this commit:
>>>>>   /sys/devices/system/memory/memory0# time echo 0 > online
>>>>>   -bash: echo: write error: Device or resource busy
>
> Well, that means offline didn't actually work for that block even before
> this patch, right? Is it even a movable_node block? I guess not?

Correct. It should fail.

>>>>> After:
>>>>>   /sys/devices/system/memory/memory0# time echo 0 > online
>>>>>   -bash: echo: write error: Device or resource busy
>>>>>   
>>>>>   real	2m0.009s
>>>>>   user	0m0.000s
>>>>>   sys	1m25.035s
>>>>>
>>>>> There's no way that block can be removed, it contains the kernel text,
>>>>> so it should instantly fail - which it used to.
>
> Ah, right. So your complain is really about that the failure is not
> instant anymore for blocks that can't be offlined.

Yes. Previously it failed instantly, now it doesn't fail, and loops
infinitely (once the 2 minute limit is removed).

>> This is really strange! As you write in other email the page is
>> reserved. That means that some of the earlier checks 
>> 	if (zone_idx(zone) == ZONE_MOVABLE)
>> 		return false;
>> 	mt = get_pageblock_migratetype(page);
>> 	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
>
> The MIGRATE_MOVABLE check is indeed bogus, because that doesn't
> guarantee there are no unmovable pages in the block (CMA block OTOH
> should be a guarantee).

OK I'll try that and get back to you.

cheers


>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3badcedf96a7..5b4d85ae445c 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7355,9 +7355,6 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>>  	 */
>>  	if (zone_idx(zone) == ZONE_MOVABLE)
>>  		return false;
>> -	mt = get_pageblock_migratetype(page);
>> -	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
>> -		return false;
>>  
>>  	pfn = page_to_pfn(page);
>>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
>> @@ -7368,6 +7365,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>>  
>>  		page = pfn_to_page(check);
>>  
>> +		if (PageReserved(page))
>> +			return true;
>> +
>>  		/*
>>  		 * Hugepages are not in LRU lists, but they're movable.
>>  		 * We need not scan over tail pages bacause we don't
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
