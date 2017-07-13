Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D51D9440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 04:23:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so50474336pgj.4
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 01:23:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o6si3816056pgq.559.2017.07.13.01.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 01:23:16 -0700 (PDT)
Message-ID: <59672E8B.9040108@intel.com>
Date: Thu, 13 Jul 2017 16:25:47 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com> <1499863221-16206-7-git-send-email-wei.w.wang@intel.com> <20170713032314-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170713032314-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 07/13/2017 08:33 AM, Michael S. Tsirkin wrote:
> On Wed, Jul 12, 2017 at 08:40:19PM +0800, Wei Wang wrote:
>> This patch adds support for reporting blocks of pages on the free list
>> specified by the caller.
>>
>> As pages can leave the free list during this call or immediately
>> afterwards, they are not guaranteed to be free after the function
>> returns. The only guarantee this makes is that the page was on the free
>> list at some point in time after the function has been invoked.
>>
>> Therefore, it is not safe for caller to use any pages on the returned
>> block or to discard data that is put there after the function returns.
>> However, it is safe for caller to discard data that was in one of these
>> pages before the function was invoked.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Signed-off-by: Liang Li <liang.z.li@intel.com>
>> ---
>>   include/linux/mm.h |  5 +++
>>   mm/page_alloc.c    | 96 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 101 insertions(+)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 46b9ac5..76cb433 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1835,6 +1835,11 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
>>   		unsigned long zone_start_pfn, unsigned long *zholes_size);
>>   extern void free_initmem(void);
>>   
>> +#if IS_ENABLED(CONFIG_VIRTIO_BALLOON)
>> +extern int report_unused_page_block(struct zone *zone, unsigned int order,
>> +				    unsigned int migratetype,
>> +				    struct page **page);
>> +#endif
>>   /*
>>    * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>>    * into the buddy system. The freed pages will be poisoned with pattern
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 64b7d82..8b3c9dd 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4753,6 +4753,102 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>>   	show_swap_cache_info();
>>   }
>>   
>> +#if IS_ENABLED(CONFIG_VIRTIO_BALLOON)
>> +
>> +/*
>> + * Heuristically get a page block in the system that is unused.
>> + * It is possible that pages from the page block are used immediately after
>> + * report_unused_page_block() returns. It is the caller's responsibility
>> + * to either detect or prevent the use of such pages.
>> + *
>> + * The free list to check: zone->free_area[order].free_list[migratetype].
>> + *
>> + * If the caller supplied page block (i.e. **page) is on the free list, offer
>> + * the next page block on the list to the caller. Otherwise, offer the first
>> + * page block on the list.
>> + *
>> + * Note: it is not safe for caller to use any pages on the returned
>> + * block or to discard data that is put there after the function returns.
>> + * However, it is safe for caller to discard data that was in one of these
>> + * pages before the function was invoked.
>> + *
>> + * Return 0 when a page block is found on the caller specified free list.
> Otherwise?

Other values mean that no page block is found. I will add them.

>
>> + */
> As an alternative, we could have an API that scans free pages
> and invokes a callback under a lock. Granted, this might end up
> staying a lot of time under a lock. Is this a big issue?
> Some benchmarking will tell.
>
> It would then be up to the hypervisor to decide whether it wants to play
> tricks with the dirty bit or just wants to drop pages while VCPU is
> stopped.
>
>
>> +int report_unused_page_block(struct zone *zone, unsigned int order,
>> +			     unsigned int migratetype, struct page **page)
>> +{
>> +	struct zone *this_zone;
>> +	struct list_head *this_list;
>> +	int ret = 0;
>> +	unsigned long flags;
>> +
>> +	/* Sanity check */
>> +	if (zone == NULL || page == NULL || order >= MAX_ORDER ||
>> +	    migratetype >= MIGRATE_TYPES)
>> +		return -EINVAL;
> Why do callers this?
>
>> +
>> +	/* Zone validity check */
>> +	for_each_populated_zone(this_zone) {
>> +		if (zone == this_zone)
>> +			break;
>> +	}
> Why?  Will take a long time if there are lots of zones.
>
>> +
>> +	/* Got a non-existent zone from the caller? */
>> +	if (zone != this_zone)
>> +		return -EINVAL;
> When does this happen?

The above lines of code are just sanity check. If not
necessary, we can remove them.

>
>> +
>> +	spin_lock_irqsave(&this_zone->lock, flags);
>> +
>> +	this_list = &zone->free_area[order].free_list[migratetype];
>> +	if (list_empty(this_list)) {
>> +		*page = NULL;
>> +		ret = 1;
>
> What does this mean?

Just means the list is empty, and expects the caller to try again
in the next list.

Probably, use "-EAGAIN" is better?

>
>> +		*page = list_first_entry(this_list, struct page, lru);
>> +		ret = 0;
>> +		goto out;
>> +	}
>> +
>> +	/*
>> +	 * The page block passed from the caller is not on this free list
>> +	 * anymore (e.g. a 1MB free page block has been split). In this case,
>> +	 * offer the first page block on the free list that the caller is
>> +	 * asking for.
> This just might keep giving you same block over and over again.
> E.g.
> 	- get 1st block
> 	- get 2nd block
> 	- 2nd gets broken up
> 	- get 1st block again
>
> this way we might never make progress beyond the 1st 2 blocks

Not really. I think the pages are allocated in order. If the 2nd block 
isn't there, then
the 1st block must have gone, too. So, the call will return the 3rd one 
(which is the
new first) on the list.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
