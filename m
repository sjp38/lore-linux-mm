Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4326B6B0003
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:20:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i11so10668809pgq.10
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 23:20:44 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m13si418651pgc.35.2018.03.26.23.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 23:20:43 -0700 (PDT)
Message-ID: <5AB9E377.30900@intel.com>
Date: Tue, 27 Mar 2018 14:23:51 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v29 1/4] mm: support reporting free page blocks
References: <1522031994-7246-1-git-send-email-wei.w.wang@intel.com>	<1522031994-7246-2-git-send-email-wei.w.wang@intel.com> <20180326142254.c4129c3a54ade686ee2a5e21@linux-foundation.org>
In-Reply-To: <20180326142254.c4129c3a54ade686ee2a5e21@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On 03/27/2018 05:22 AM, Andrew Morton wrote:
> On Mon, 26 Mar 2018 10:39:51 +0800 Wei Wang <wei.w.wang@intel.com> wrote:
>
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
>> ...
>>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4912,6 +4912,102 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>>   	show_swap_cache_info();
>>   }
>>   
>> +/*
>> + * Walk through a free page list and report the found pfn range via the
>> + * callback.
>> + *
>> + * Return 0 if it completes the reporting. Otherwise, return the non-zero
>> + * value returned from the callback.
>> + */
>> +static int walk_free_page_list(void *opaque,
>> +			       struct zone *zone,
>> +			       int order,
>> +			       enum migratetype mt,
>> +			       int (*report_pfn_range)(void *,
>> +						       unsigned long,
>> +						       unsigned long))
>> +{
>> +	struct page *page;
>> +	struct list_head *list;
>> +	unsigned long pfn, flags;
>> +	int ret = 0;
>> +
>> +	spin_lock_irqsave(&zone->lock, flags);
>> +	list = &zone->free_area[order].free_list[mt];
>> +	list_for_each_entry(page, list, lru) {
>> +		pfn = page_to_pfn(page);
>> +		ret = report_pfn_range(opaque, pfn, 1 << order);
>> +		if (ret)
>> +			break;
>> +	}
>> +	spin_unlock_irqrestore(&zone->lock, flags);
>> +
>> +	return ret;
>> +}
>> +
>> +/**
>> + * walk_free_mem_block - Walk through the free page blocks in the system
>> + * @opaque: the context passed from the caller
>> + * @min_order: the minimum order of free lists to check
>> + * @report_pfn_range: the callback to report the pfn range of the free pages
>> + *
>> + * If the callback returns a non-zero value, stop iterating the list of free
>> + * page blocks. Otherwise, continue to report.
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
> I don't see how walk_free_mem_block() can sleep.

OK, it would be better to remove this sentence for the current version. 
But I think we could probably keep it if we decide to add cond_resched() 
below.

>
>> + * In general low orders tend to be very volatile and so it makes more
>> + * sense to query larger ones first for various optimizations which like
>> + * ballooning etc... This will reduce the overhead as well.
>> + *
>> + * Return 0 if it completes the reporting. Otherwise, return the non-zero
>> + * value returned from the callback.
>> + */
>> +int walk_free_mem_block(void *opaque,
>> +			int min_order,
>> +			int (*report_pfn_range)(void *opaque,
>> +			unsigned long pfn,
>> +			unsigned long num))
>> +{
>> +	struct zone *zone;
>> +	int order;
>> +	enum migratetype mt;
>> +	int ret;
>> +
>> +	for_each_populated_zone(zone) {
>> +		for (order = MAX_ORDER - 1; order >= min_order; order--) {
>> +			for (mt = 0; mt < MIGRATE_TYPES; mt++) {
>> +				ret = walk_free_page_list(opaque, zone,
>> +							  order, mt,
>> +							  report_pfn_range);
>> +				if (ret)
>> +					return ret;
>> +			}
==>
>> +		}
>> +	}
>> +
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(walk_free_mem_block);
> This looks like it could take a long time.  Will we end up needing to
> add cond_resched() in there somewhere?

OK. How about adding cond_resched at the above place "==>" (i.e. every 
order)?


Best,
Wei
