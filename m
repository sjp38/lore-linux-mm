Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F01546B0267
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:42:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y134so307275678pfg.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:42:08 -0700 (PDT)
Received: from szxga01-in.huawei.com ([58.251.152.64])
        by mx.google.com with ESMTPS id l189si2367460pfl.125.2016.07.18.01.42.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 01:42:08 -0700 (PDT)
Message-ID: <578C93CF.50509@huawei.com>
Date: Mon, 18 Jul 2016 16:31:11 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in, alloc_migrate_target()
References: <57884EAA.9030603@huawei.com> <20160718055150.GF9460@js1304-P5Q-DELUXE> <578C8C8A.8000007@huawei.com> <7ce4a7ac-07aa-6a81-48c2-91c4a9355778@suse.cz>
In-Reply-To: <7ce4a7ac-07aa-6a81-48c2-91c4a9355778@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/7/18 16:05, Vlastimil Babka wrote:

> On 07/18/2016 10:00 AM, Xishi Qiu wrote:
>> On 2016/7/18 13:51, Joonsoo Kim wrote:
>>
>>> On Fri, Jul 15, 2016 at 10:47:06AM +0800, Xishi Qiu wrote:
>>>> alloc_migrate_target() is called from migrate_pages(), and the page
>>>> is always from user space, so we can add __GFP_HIGHMEM directly.
>>>
>>> No, all migratable pages are not from user space. For example,
>>> blockdev file cache has __GFP_MOVABLE and migratable but it has no
>>> __GFP_HIGHMEM and __GFP_USER.
>>>
>>
>> Hi Joonsoo,
>>
>> So the original code "gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;"
>> is not correct?
> 
> It's not incorrect. GFP_USER just specifies some reclaim flags, and may perhaps restrict allocation through __GFP_HARDWALL, where the original
> page could have been allocated without the restriction. But it doesn't put the place in an unexpected address range, as placing a non-highmem page into highmem could. __GFP_MOVABLE then just controls a heuristic for placement within a zone.
> 
>>> And, zram's memory isn't GFP_HIGHUSER_MOVABLE but has __GFP_MOVABLE.
>>>
>>
>> Can we distinguish __GFP_MOVABLE or GFP_HIGHUSER_MOVABLE when doing
>> mem-hotplug?
> 
> I don't understand the question here, can you rephrase with more detail? Thanks.
> 

Hi Joonsoo,

When we do memory offline, and the zone is movable zone,
can we use "alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);" to alloc a
new page? the nid is the next node.

Thanks,
Xishi Qiu

>> Thanks,
>> Xishi Qiu
>>
>>> Thanks.
>>>
>>>
>>> .
>>>
>>
>>
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
