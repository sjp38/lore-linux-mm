Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 336AD6B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 23:20:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l87so3705612pfj.3
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 20:20:58 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g14si1532759pln.252.2017.08.28.20.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 20:20:57 -0700 (PDT)
Message-ID: <59A4DE48.9030206@intel.com>
Date: Tue, 29 Aug 2017 11:23:52 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v15 4/5] mm: support reporting free page blocks
References: <1503914913-28893-1-git-send-email-wei.w.wang@intel.com> <1503914913-28893-5-git-send-email-wei.w.wang@intel.com> <20170828133326.GN17097@dhcp22.suse.cz>
In-Reply-To: <20170828133326.GN17097@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 08/28/2017 09:33 PM, Michal Hocko wrote:
> On Mon 28-08-17 18:08:32, Wei Wang wrote:
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
> OK, looks much better. I still have few nits.
>
>> +extern void walk_free_mem_block(void *opaque,
>> +				int min_order,
>> +				bool (*report_page_block)(void *, unsigned long,
>> +							  unsigned long));
>> +
> please add names to arguments of the prototype
>
>>   /*
>>    * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>>    * into the buddy system. The freed pages will be poisoned with pattern
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6d00f74..81eedc7 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4762,6 +4762,71 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>>   	show_swap_cache_info();
>>   }
>>   
>> +/**
>> + * walk_free_mem_block - Walk through the free page blocks in the system
>> + * @opaque: the context passed from the caller
>> + * @min_order: the minimum order of free lists to check
>> + * @report_page_block: the callback function to report free page blocks
> page_block has meaning in the core MM which doesn't strictly match its
> usage here. Moreover we are reporting pfn ranges rather than struct page
> range. So report_pfn_range would suit better.
>
> [...]
>> +	for_each_populated_zone(zone) {
>> +		for (order = MAX_ORDER - 1; order >= min_order; order--) {
>> +			for (mt = 0; !stop && mt < MIGRATE_TYPES; mt++) {
>> +				spin_lock_irqsave(&zone->lock, flags);
>> +				list = &zone->free_area[order].free_list[mt];
>> +				list_for_each_entry(page, list, lru) {
>> +					pfn = page_to_pfn(page);
>> +					stop = report_page_block(opaque, pfn,
>> +								 1 << order);
>> +					if (stop)
>> +						break;
> 					if (stop) {
> 						spin_unlock_irqrestore(&zone->lock, flags);
> 						return;
> 					}
>
> would be both easier and less error prone. E.g. You wouldn't pointlessly
> iterate over remaining orders just to realize there is nothing to be
> done for those...
>

Yes, that's better, thanks. I will take other suggestions as well.

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
