Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 52F3B4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 11:11:52 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id w5so43673537oie.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:11:52 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id v18si4053340oif.44.2016.02.05.08.11.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 08:11:51 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id wb13so93701340obb.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:11:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
	<20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
Date: Sat, 6 Feb 2016 01:11:51 +0900
Message-ID: <CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-05 9:49 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
> On Thu,  4 Feb 2016 15:19:35 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
>
>> There is a performance drop report due to hugepage allocation and in there
>> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
>> In that workload, compaction is triggered to make hugepage but most of
>> pageblocks are un-available for compaction due to pageblock type and
>> skip bit so compaction usually fails. Most costly operations in this case
>> is to find valid pageblock while scanning whole zone range. To check
>> if pageblock is valid to compact, valid pfn within pageblock is required
>> and we can obtain it by calling pageblock_pfn_to_page(). This function
>> checks whether pageblock is in a single zone and return valid pfn
>> if possible. Problem is that we need to check it every time before
>> scanning pageblock even if we re-visit it and this turns out to
>> be very expensive in this workload.
>>
>> Although we have no way to skip this pageblock check in the system
>> where hole exists at arbitrary position, we can use cached value for
>> zone continuity and just do pfn_to_page() in the system where hole doesn't
>> exist. This optimization considerably speeds up in above workload.
>>
>> Before vs After
>> Max: 1096 MB/s vs 1325 MB/s
>> Min: 635 MB/s 1015 MB/s
>> Avg: 899 MB/s 1194 MB/s
>>
>> Avg is improved by roughly 30% [2].
>>
>> [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
>> [2]: https://lkml.org/lkml/2015/12/9/23
>>
>> ...
>>
>> --- a/include/linux/memory_hotplug.h
>> +++ b/include/linux/memory_hotplug.h
>> @@ -196,6 +196,9 @@ void put_online_mems(void);
>>  void mem_hotplug_begin(void);
>>  void mem_hotplug_done(void);
>>
>> +extern void set_zone_contiguous(struct zone *zone);
>> +extern void clear_zone_contiguous(struct zone *zone);
>> +
>>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>>  /*
>>   * Stub functions for when hotplug is off
>
> Was it really intended that these declarations only exist if
> CONFIG_MEMORY_HOTPLUG?  Seems unrelated.

These are called for caching memory layout whether it is contiguous
or not. So, they are always called in memory initialization. Then,
hotplug could change memory layout so they should be called
there, too. So, they are defined in page_alloc.c and exported only
if CONFIG_MEMORY_HOTPLUG.

> The i386 allnocofnig build fails in preditable ways so I fixed that up
> as below, but it seems wrong.

Yeah, it seems wrong to me. :)
Here goes fix.

----------->8------------
