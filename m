Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE8FA6B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 21:26:09 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b2so29377871pgc.6
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 18:26:09 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id z13si2869242plh.261.2017.02.22.18.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 18:26:09 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 1so2743754pgz.2
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 18:26:09 -0800 (PST)
Subject: Re: [RFC PATCH] mm/vmscan: fix high cpu usage of kswapd if there
References: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
 <20170222114105.GI5753@dhcp22.suse.cz>
 <e07c7437-37e4-3630-0bd9-3f225412fd52@gmail.com>
 <20170222154845.jz7l7ubhmeaejwn2@dhcp22.suse.cz>
From: hejianet <hejianet@gmail.com>
Message-ID: <7b51aa3f-b6da-b77c-72ef-9bf16495a78b@gmail.com>
Date: Thu, 23 Feb 2017 10:25:56 +0800
MIME-Version: 1.0
In-Reply-To: <20170222154845.jz7l7ubhmeaejwn2@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Hi Michal

On 22/02/2017 11:48 PM, Michal Hocko wrote:
> On Wed 22-02-17 22:31:50, hejianet wrote:
>> Hi Michal
>>
>> On 22/02/2017 7:41 PM, Michal Hocko wrote:
>>> On Wed 22-02-17 17:04:48, Jia He wrote:
>>>> When I try to dynamically allocate the hugepages more than system total
>>>> free memory:
>>>> e.g. echo 4000 >/proc/sys/vm/nr_hugepages
>>>
>>> I assume that the command has terminated with less huge pages allocated
>>> than requested but
>>>
>> Yes, at last the allocated hugepages are less than 4000
>> HugePages_Total:    1864
>> HugePages_Free:     1864
>> HugePages_Rsvd:        0
>> HugePages_Surp:        0
>> Hugepagesize:      16384 kB
>>
>> In the bad case, although kswapd takes 100% cpu, the number of
>> HugePages_Total is not increase at all.
>>
>>>> Node 3, zone      DMA
>>> [...]
>>>>   pages free     2951
>>>>         min      2821
>>>>         low      3526
>>>>         high     4231
>>>
>>> it left the zone below high watermark with
>>>
>>>>    node_scanned  0
>>>>         spanned  245760
>>>>         present  245760
>>>>         managed  245388
>>>>       nr_free_pages 2951
>>>>       nr_zone_inactive_anon 0
>>>>       nr_zone_active_anon 0
>>>>       nr_zone_inactive_file 0
>>>>       nr_zone_active_file 0
>>>
>>> no pages reclaimable, so kswapd will not go to sleep. It would be quite
>>> easy and comfortable to call it a misconfiguration but it seems that
>>> it might be quite easy to hit with NUMA machines which have large
>>> differences in the node sizes. I guess it makes sense to back off
>>> the kswapd rather than burning CPU without any way to make forward
>>> progress.
>>
>> agree.
>
> please make sure that this information is in the changelog
>
> [...]
>>>> @@ -3502,6 +3503,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>>>>  {
>>>>  	pg_data_t *pgdat;
>>>>  	int z;
>>>> +	int node_has_relaimable_pages = 0;
>>>>
>>>>  	if (!managed_zone(zone))
>>>>  		return;
>>>> @@ -3522,8 +3524,15 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>>>>
>>>>  		if (zone_balanced(zone, order, classzone_idx))
>>>>  			return;
>>>> +
>>>> +		if (!zone_reclaimable_pages(zone))
>>>> +			node_has_relaimable_pages = 1;
>>>
>>> What, this doesn't make any sense? Did you mean if (zone_reclaimable_pages)?
>>
>> I mean, if any one zone has reclaimable pages, then this zone's *node* has
>> reclaimable pages. Thus, the kswapN for this node should be waken up.
>> e.g. node 1 has 2 zones.
>> zone A has no reclaimable pages but zone B has.
>> Thus node 1 has reclaimable pages, and kswapd1 will be waken up.
>> I use node_has_relaimable_pages in the loop to check all the zones' reclaimable
>> pages number. So I prefer the name node_has_relaimable_pages instead of
>> zone_has_relaimable_pages
>
> I still do not understand. This code starts with
> node_has_relaimable_pages = 0. If you see a zone with no reclaimable
> pages then you make it node_has_relaimable_pages = 1 which means that
>
>>>> +	/* Dont wake kswapd if no reclaimable pages */
>>>> +	if (!node_has_relaimable_pages)
>>>> +		return;
>
> this will not hold and we will wake up the kswapd. I believe what
> you want instead, is to skip the wake up if _all_ zones have
> !zone_reclaimable_pages() Or I am missing your point. This means that
> you want
> 	if (zone_reclaimable_pages(zone)
> 		node_has_relaimable_pages = 1;	
You are right, will send v2 soon after testing it
B.R.
Jia
>
>>>> +
>>>>  	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
>>>>  	wake_up_interruptible(&pgdat->kswapd_wait);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
