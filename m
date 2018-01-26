Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEE416B0007
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 22:26:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a9so7557684pff.0
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 19:26:46 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a61-v6si3028364pla.248.2018.01.25.19.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 19:26:45 -0800 (PST)
Message-ID: <5A6AA08B.2080508@intel.com>
Date: Fri, 26 Jan 2018 11:29:15 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v24 1/2] mm: support reporting free page blocks
References: <1516790562-37889-1-git-send-email-wei.w.wang@intel.com> <1516790562-37889-2-git-send-email-wei.w.wang@intel.com> <20180125152933-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180125152933-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/25/2018 09:41 PM, Michael S. Tsirkin wrote:
> On Wed, Jan 24, 2018 at 06:42:41PM +0800, Wei Wang wrote:
>> This patch adds support to walk through the free page blocks in the
>> system and report them via a callback function. Some page blocks may
>> leave the free list after zone->lock is released, so it is the caller's
>> responsibility to either detect or prevent the use of such pages.
>>
>> One use example of this patch is to accelerate live migration by skipping
>> the transfer of free pages reported from the guest. A popular method used
>> by the hypervisor to track which part of memory is written during live
>> migration is to write-protect all the guest memory. So, those pages that
>> are reported as free pages but are written after the report function
>> returns will be captured by the hypervisor, and they will be added to the
>> next round of memory transfer.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Signed-off-by: Liang Li <liang.z.li@intel.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Acked-by: Michal Hocko <mhocko@kernel.org>
>> ---
>>   include/linux/mm.h |  6 ++++
>>   mm/page_alloc.c    | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 97 insertions(+)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index ea818ff..b3077dd 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1938,6 +1938,12 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
>>   		unsigned long zone_start_pfn, unsigned long *zholes_size);
>>   extern void free_initmem(void);
>>   
>> +extern void walk_free_mem_block(void *opaque,
>> +				int min_order,
>> +				bool (*report_pfn_range)(void *opaque,
>> +							 unsigned long pfn,
>> +							 unsigned long num));
>> +
>>   /*
>>    * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>>    * into the buddy system. The freed pages will be poisoned with pattern
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 76c9688..705de22 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4899,6 +4899,97 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>>   	show_swap_cache_info();
>>   }
>>   
>> +/*
>> + * Walk through a free page list and report the found pfn range via the
>> + * callback.
>> + *
>> + * Return false if the callback requests to stop reporting. Otherwise,
>> + * return true.
>> + */
>> +static bool walk_free_page_list(void *opaque,
>> +				struct zone *zone,
>> +				int order,
>> +				enum migratetype mt,
>> +				bool (*report_pfn_range)(void *,
>> +							 unsigned long,
>> +							 unsigned long))
>> +{
>> +	struct page *page;
>> +	struct list_head *list;
>> +	unsigned long pfn, flags;
>> +	bool ret;
>> +
>> +	spin_lock_irqsave(&zone->lock, flags);
>> +	list = &zone->free_area[order].free_list[mt];
>> +	list_for_each_entry(page, list, lru) {
>> +		pfn = page_to_pfn(page);
>> +		ret = report_pfn_range(opaque, pfn, 1 << order);
>> +		if (!ret)
>> +			break;
>> +	}
>> +	spin_unlock_irqrestore(&zone->lock, flags);
>> +
>> +	return ret;
>> +}
> There are two issues with this API. One is that it is not
> restarteable: if you return false, you start from the
> beginning. So no way to drop lock, do something slow
> and then proceed.
>
> Another is that you are using it to report free page hints. Presumably
> the point is to drop these pages - keeping them near head of the list
> and reusing the reported ones will just make everything slower
> invalidating the hint.
>
> How about rotating these pages towards the end of the list?
> Probably not on each call, callect reported pages and then
> move them to tail when we exit.


I'm not sure how this would help. For example, we have a list of 2M free 
page blocks:
A-->B-->C-->D-->E-->F-->G--H

After reporting A and B, and put them to the end and exit, when the 
caller comes back,
1) if the list remains unchanged, then it will be
C-->D-->E-->F-->G-->H-->A-->B

2) If worse, all the blocks have been split into smaller blocks and used 
after the caller comes back.

where could we continue?


The reason to think about "restart" is the worry about the virtqueue is 
full, right? But we've agreed that losing some hints to report isn't 
important, and in practice, the virtqueue won't be full as the host side 
is faster.

I'm concerned that actions on the free list may cause more controversy 
though it might be safe to do from some aspect, and would be hard to end 
debating. If possible, we could go with the most prudent approach for 
now, and have more discussions in future improvement patches. What would 
you think?



>
>
>> +
>> +/**
>> + * walk_free_mem_block - Walk through the free page blocks in the system
>> + * @opaque: the context passed from the caller
>> + * @min_order: the minimum order of free lists to check
>> + * @report_pfn_range: the callback to report the pfn range of the free pages
>> + *
>> + * If the callback returns false, stop iterating the list of free page blocks.
>> + * Otherwise, continue to report.
>> + *
>> + * Please note that there are no locking guarantees for the callback and
>> + * that the reported pfn range might be freed or disappear after the
>> + * callback returns so the caller has to be very careful how it is used.
>> + *
>> + * The callback itself must not sleep or perform any operations which would
>> + * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
>> + * or via any lock dependency. It is generally advisable to implement
>> + * the callback as simple as possible and defer any heavy lifting to a
>> + * different context.
>> + *
>> + * There is no guarantee that each free range will be reported only once
>> + * during one walk_free_mem_block invocation.
>> + *
>> + * pfn_to_page on the given range is strongly discouraged and if there is
>> + * an absolute need for that make sure to contact MM people to discuss
>> + * potential problems.
>> + *
>> + * The function itself might sleep so it cannot be called from atomic
>> + * contexts.
>> + *
>> + * In general low orders tend to be very volatile and so it makes more
>> + * sense to query larger ones first for various optimizations which like
>> + * ballooning etc... This will reduce the overhead as well.
>> + */
>> +void walk_free_mem_block(void *opaque,
>> +			 int min_order,
>> +			 bool (*report_pfn_range)(void *opaque,
>> +						  unsigned long pfn,
>> +						  unsigned long num))
>> +{
>> +	struct zone *zone;
>> +	int order;
>> +	enum migratetype mt;
>> +	bool ret;
>> +
>> +	for_each_populated_zone(zone) {
>> +		for (order = MAX_ORDER - 1; order >= min_order; order--) {
>> +			for (mt = 0; mt < MIGRATE_TYPES; mt++) {
>> +				ret = walk_free_page_list(opaque, zone,
>> +							  order, mt,
>> +							  report_pfn_range);
>> +				if (!ret)
>> +					return;
>> +			}
>> +		}
>> +	}
>> +}
>> +EXPORT_SYMBOL_GPL(walk_free_mem_block);
>> +
> I think callers need a way to
> 1. distinguish between completion and exit on error

The first one here has actually been achieved by v25, where 
walk_free_mem_block returns 0 on completing the reporting, or a non-zero 
value which is returned from the callback.
So the caller will detect errors via letting the callback to return 
something.

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
