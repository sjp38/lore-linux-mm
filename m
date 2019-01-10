Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C89B8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 23:41:12 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q63so6857427pfi.19
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 20:41:12 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id x6si15456994pgh.363.2019.01.09.20.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 20:41:10 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Jan 2019 10:11:10 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v8] mm/page_alloc.c: memory_hotplug: free pages as higher
 order
In-Reply-To: <54c280dbd0ff8e17a6c465778c98e2dbbbde7918.camel@linux.intel.com>
References: <1547032395-24582-1-git-send-email-arunks@codeaurora.org>
 <54c280dbd0ff8e17a6c465778c98e2dbbbde7918.camel@linux.intel.com>
Message-ID: <6b56072f634b033dea8f15281f419402@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2019-01-09 21:47, Alexander Duyck wrote:
> On Wed, 2019-01-09 at 16:43 +0530, Arun KS wrote:
>> When freeing pages are done with higher order, time spent on 
>> coalescing
>> pages by buddy allocator can be reduced.  With section size of 256MB, 
>> hot
>> add latency of a single section shows improvement from 50-60 ms to 
>> less
>> than 1 ms, hence improving the hot add latency by 60 times.  Modify
>> external providers of online callback to align with the change.
>> 
>> Signed-off-by: Arun KS <arunks@codeaurora.org>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>> ---
>> Changes since v7:
>> - Rebased to 5.0-rc1.
>> - Fixed onlined_pages accounting.
>> - Added comment for return value of online_page_callback.
>> - Renamed xen_bring_pgs_online to xen_online_pages.
> 
> As far as the renaming you should try to be consistent. If you aren't
> going to rename generic_online_page or hv_online_page I wouldn't bother
> with renaming xen_online_page. I would stick with the name
> xen_online_page since it is a single high order page that you are
> freeing.

Sure. I ll fix them.

> 
>> 
>> Changes since v6:
>> - Rebased to 4.20
>> - Changelog updated.
>> - No improvement seen on arm64, hence removed removal of prefetch.
>> 
>> Changes since v5:
>> - Rebased to 4.20-rc1.
>> - Changelog updated.
>> 
>> Changes since v4:
>> - As suggested by Michal Hocko,
>> - Simplify logic in online_pages_block() by using get_order().
>> - Seperate out removal of prefetch from __free_pages_core().
>> 
>> Changes since v3:
>> - Renamed _free_pages_boot_core -> __free_pages_core.
>> - Removed prefetch from __free_pages_core.
>> - Removed xen_online_page().
>> 
>> Changes since v2:
>> - Reuse code from __free_pages_boot_core().
>> 
>> Changes since v1:
>> - Removed prefetch().
>> 
>> Changes since RFC:
>> - Rebase.
>> - As suggested by Michal Hocko remove pages_per_block.
>> - Modifed external providers of online_page_callback.
>> 
>> v7: https://lore.kernel.org/patchwork/patch/1028908/
>> v6: https://lore.kernel.org/patchwork/patch/1007253/
>> v5: https://lore.kernel.org/patchwork/patch/995739/
>> v4: https://lore.kernel.org/patchwork/patch/995111/
>> v3: https://lore.kernel.org/patchwork/patch/992348/
>> v2: https://lore.kernel.org/patchwork/patch/991363/
>> v1: https://lore.kernel.org/patchwork/patch/989445/
>> RFC: https://lore.kernel.org/patchwork/patch/984754/
>> ---
>>  drivers/hv/hv_balloon.c        |  6 +++--
>>  drivers/xen/balloon.c          | 21 +++++++++++------
>>  include/linux/memory_hotplug.h |  2 +-
>>  mm/internal.h                  |  1 +
>>  mm/memory_hotplug.c            | 51 
>> +++++++++++++++++++++++++++++++-----------
>>  mm/page_alloc.c                |  8 +++----
>>  6 files changed, 62 insertions(+), 27 deletions(-)
>> 
>> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
>> index 5301fef..211f3fe 100644
>> --- a/drivers/hv/hv_balloon.c
>> +++ b/drivers/hv/hv_balloon.c
>> @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, 
>> unsigned long size,
>>  	}
>>  }
>> 
>> -static void hv_online_page(struct page *pg)
>> +static int hv_online_page(struct page *pg, unsigned int order)
>>  {
>>  	struct hv_hotadd_state *has;
>>  	unsigned long flags;
>> @@ -783,10 +783,12 @@ static void hv_online_page(struct page *pg)
>>  		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
>>  			continue;
>> 
>> -		hv_page_online_one(has, pg);
>> +		hv_bring_pgs_online(has, pfn, (1UL << order));
>>  		break;
>>  	}
>>  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
>> +
>> +	return 0;
>>  }
>> 
> 
> I would hold off on adding return values until you actually have code
> that uses them. It will make things easier if somebody has to backport
> this to a stable branch and avoid adding complexity until it is needed.
> 
> Also the patch description doesn't really explain that it is doing this
> so it might be better to break it off into a separate patch so you can
> call out exactly why you are adding a return value in the patch
> description.
> 
> - Alex
