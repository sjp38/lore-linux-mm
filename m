Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1F64F6B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 20:12:11 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so4587483pab.15
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 17:12:10 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id vd9si7680964pab.148.2014.07.31.17.12.07
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 17:12:09 -0700 (PDT)
Message-ID: <53DADB56.3050103@lge.com>
Date: Fri, 01 Aug 2014 09:12:06 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2] CMA/HOTPLUG: clear buffer-head lru before page migration
References: <53D9A86B.20208@lge.com> <20140731155703.a8bc3b77af913c8b3a63090a@linux-foundation.org>
In-Reply-To: <20140731155703.a8bc3b77af913c8b3a63090a@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?B?J+q5gOykgOyImCc=?= <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Laura Abbott <lauraa@codeaurora.org>, Michal Nazarewicz <mina86@mina86.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ????????? <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>



2014-08-01 i??i ? 7:57, Andrew Morton i?' e,?:
> On Thu, 31 Jul 2014 11:22:35 +0900 Gioh Kim <gioh.kim@lge.com> wrote:
>
>> The previous PATCH inserts invalidate_bh_lrus() only into CMA code.
>> HOTPLUG needs also dropping bh of lru.
>> So v2 inserts invalidate_bh_lrus() into both of CMA and HOTPLUG.
>>
>>
>> ---------------------------- 8< ----------------------------
>> The bh must be free to migrate a page at which bh is mapped.
>> The reference count of bh is increased when it is installed
>> into lru so that the bh of lru must be freed before migrating the page.
>>
>> This frees every bh of lru. We could free only bh of migrating page.
>> But searching lru sometimes costs more than invalidating entire lru.
>>
>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>> ---
>>   mm/memory_hotplug.c |    1 +
>>   mm/page_alloc.c     |    2 ++
>>   2 files changed, 3 insertions(+)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index a3797d3..1c5454f 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1672,6 +1672,7 @@ repeat:
>>                  lru_add_drain_all();
>>                  cond_resched();
>>                  drain_all_pages();
>> +               invalidate_bh_lrus();
>
> Both of these calls should have a comment explaining why
> invalidate_bh_lrus() is being called.
>
>>          }
>>
>>          pfn = scan_movable_pages(start_pfn, end_pfn);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index b99643d4..c00dedf 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6369,6 +6369,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>>          if (ret)
>>                  return ret;
>>
>> +       invalidate_bh_lrus();
>> +
>>          ret = __alloc_contig_migrate_range(&cc, start, end);
>>          if (ret)
>>                  goto done;
>
> I do feel that this change is likely to be beneficial, but I don't want
> to apply such a patch until I know what its effects are upon all
> alloc_contig_range() callers.  Especially hugetlb.

I'm very sorry to hear that.
How can I check the effects?


> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
