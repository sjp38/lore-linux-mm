Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32AE26B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:04:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z80so3191725pff.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 01:04:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36si10938776ple.401.2017.10.11.01.04.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 01:04:43 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
References: <20170918070834.13083-1-mhocko@kernel.org>
 <20170918070834.13083-2-mhocko@kernel.org>
 <87bmlfw6mj.fsf@concordia.ellerman.id.au>
 <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz>
 <87infmz9xd.fsf@concordia.ellerman.id.au>
 <20171011065123.e7jvoftmtso3vcha@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d29b6788-da1b-23e9-090c-d43428deb97d@suse.cz>
Date: Wed, 11 Oct 2017 10:04:39 +0200
MIME-Version: 1.0
In-Reply-To: <20171011065123.e7jvoftmtso3vcha@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/11/2017 08:51 AM, Michal Hocko wrote:
> On Wed 11-10-17 13:37:50, Michael Ellerman wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>>
>>> On Tue 10-10-17 23:05:08, Michael Ellerman wrote:
>>>> Michal Hocko <mhocko@kernel.org> writes:
>>>>
>>>>> From: Michal Hocko <mhocko@suse.com>
>>>>>
>>>>> Memory offlining can fail just too eagerly under a heavy memory pressure.
>>>>>
>>>>> [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
>>>>> [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
>>>>> [ 5410.336811] page dumped because: isolation failed
>>>>> [ 5410.336813] page->mem_cgroup:ffff8801cd662000
>>>>> [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
>>>>>
>>>>> Isolation has failed here because the page is not on LRU. Most probably
>>>>> because it was on the pcp LRU cache or it has been removed from the LRU
>>>>> already but it hasn't been freed yet. In both cases the page doesn't look
>>>>> non-migrable so retrying more makes sense.
>>>>
>>>> This breaks offline for me.
>>>>
>>>> Prior to this commit:
>>>>   /sys/devices/system/memory/memory0# time echo 0 > online
>>>>   -bash: echo: write error: Device or resource busy

Well, that means offline didn't actually work for that block even before
this patch, right? Is it even a movable_node block? I guess not?

>>>>   real	0m0.001s
>>>>   user	0m0.000s
>>>>   sys	0m0.001s
>>>>
>>>> After:
>>>>   /sys/devices/system/memory/memory0# time echo 0 > online
>>>>   -bash: echo: write error: Device or resource busy
>>>>   
>>>>   real	2m0.009s
>>>>   user	0m0.000s
>>>>   sys	1m25.035s
>>>>
>>>>
>>>> There's no way that block can be removed, it contains the kernel text,
>>>> so it should instantly fail - which it used to.

Ah, right. So your complain is really about that the failure is not
instant anymore for blocks that can't be offlined.

>>> OK, that means that start_isolate_page_range should have failed but it
>>> hasn't for some reason. I strongly suspect has_unmovable_pages is doing
>>> something wrong. Is the kernel text marked somehow? E.g. PageReserved?
>>
>> I'm not sure how the text is marked, will have to dig into that.
>>
>>> In other words, does the diff below helps?
>>
>> No that doesn't help.
> 
> This is really strange! As you write in other email the page is
> reserved. That means that some of the earlier checks 
> 	if (zone_idx(zone) == ZONE_MOVABLE)
> 		return false;
> 	mt = get_pageblock_migratetype(page);
> 	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))

The MIGRATE_MOVABLE check is indeed bogus, because that doesn't
guarantee there are no unmovable pages in the block (CMA block OTOH
should be a guarantee).

> 		return false;
> has bailed out early. I would be quite surprised if the kernel text was
> sitting in the zone movable. The migrate type check is more fishy
> AFAICS. I can imagine that the kernel text can share the movable or CMA
> mt block. I am not really familiar with this function but it looks
> suspicious. So does it help to remove this check?
> --- 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3badcedf96a7..5b4d85ae445c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7355,9 +7355,6 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	 */
>  	if (zone_idx(zone) == ZONE_MOVABLE)
>  		return false;
> -	mt = get_pageblock_migratetype(page);
> -	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
> -		return false;
>  
>  	pfn = page_to_pfn(page);
>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
> @@ -7368,6 +7365,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  
>  		page = pfn_to_page(check);
>  
> +		if (PageReserved(page))
> +			return true;
> +
>  		/*
>  		 * Hugepages are not in LRU lists, but they're movable.
>  		 * We need not scan over tail pages bacause we don't
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
