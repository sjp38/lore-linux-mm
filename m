Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4077D6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 03:20:18 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id k16so21581876qke.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 00:20:18 -0700 (PDT)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id d12si18867487qkg.156.2016.07.19.00.20.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 00:20:17 -0700 (PDT)
Message-ID: <578DD44F.3040507@huawei.com>
Date: Tue, 19 Jul 2016 15:18:39 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in, alloc_migrate_target()
References: <57884EAA.9030603@huawei.com> <20160718055150.GF9460@js1304-P5Q-DELUXE> <578C8C8A.8000007@huawei.com> <7ce4a7ac-07aa-6a81-48c2-91c4a9355778@suse.cz> <578C93CF.50509@huawei.com> <20160719065042.GC17479@js1304-P5Q-DELUXE>
In-Reply-To: <20160719065042.GC17479@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/7/19 14:50, Joonsoo Kim wrote:

> On Mon, Jul 18, 2016 at 04:31:11PM +0800, Xishi Qiu wrote:
>> On 2016/7/18 16:05, Vlastimil Babka wrote:
>>
>>> On 07/18/2016 10:00 AM, Xishi Qiu wrote:
>>>> On 2016/7/18 13:51, Joonsoo Kim wrote:
>>>>
>>>>> On Fri, Jul 15, 2016 at 10:47:06AM +0800, Xishi Qiu wrote:
>>>>>> alloc_migrate_target() is called from migrate_pages(), and the page
>>>>>> is always from user space, so we can add __GFP_HIGHMEM directly.
>>>>>
>>>>> No, all migratable pages are not from user space. For example,
>>>>> blockdev file cache has __GFP_MOVABLE and migratable but it has no
>>>>> __GFP_HIGHMEM and __GFP_USER.
>>>>>
>>>>
>>>> Hi Joonsoo,
>>>>
>>>> So the original code "gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;"
>>>> is not correct?
>>>
>>> It's not incorrect. GFP_USER just specifies some reclaim flags, and may perhaps restrict allocation through __GFP_HARDWALL, where the original
>>> page could have been allocated without the restriction. But it doesn't put the place in an unexpected address range, as placing a non-highmem page into highmem could. __GFP_MOVABLE then just controls a heuristic for placement within a zone.
>>>
>>>>> And, zram's memory isn't GFP_HIGHUSER_MOVABLE but has __GFP_MOVABLE.
>>>>>
>>>>
>>>> Can we distinguish __GFP_MOVABLE or GFP_HIGHUSER_MOVABLE when doing
>>>> mem-hotplug?
>>>
>>> I don't understand the question here, can you rephrase with more detail? Thanks.
>>>
>>
>> Hi Joonsoo,
> 
> Above is answered by Vlastimil. :)
> 
>> When we do memory offline, and the zone is movable zone,
>> can we use "alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);" to alloc a
>> new page? the nid is the next node.
> 
> I don't know much about memory offline, but, AFAIK, memory offline
> could happen on non-movable zone like as ZONE_NORMAL. Perhaps, you can add
> "if zone of the page is movable zone then alloc with GFP_HIGHUSER_MOVABLE".
> 
> Thanks.
> 

Hi Joonsoo and Vlastimil,

Memory offline could happen on both movable zone and non-movable zone, and we
can offline the whole node if the zone is movable_zone(the node only has one
movable_zone), and if the zone is normal_zone, we cannot offline the whole node,
because some kernel memory can't be migrated.

So how about change alloc_migrate_target() to alloc memory from the next node
with GFP_HIGHUSER_MOVABLE, if the offline zone is movable_zone.

And if the offline zone is normal_zone, we don't change anything, that means
the new page may be from the same node.

Thanks,
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
