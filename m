Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC7946B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 02:31:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o82so24373182pfj.11
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 23:31:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m1si460144pld.69.2017.08.07.23.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 23:31:46 -0700 (PDT)
Message-ID: <59895B71.7050709@intel.com>
Date: Tue, 08 Aug 2017 14:34:25 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v13 4/5] mm: support reporting free page
 blocks
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com> <1501742299-4369-5-git-send-email-wei.w.wang@intel.com> <20170803091151.GF12521@dhcp22.suse.cz> <59895668.9090104@intel.com>
In-Reply-To: <59895668.9090104@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 08/08/2017 02:12 PM, Wei Wang wrote:
> On 08/03/2017 05:11 PM, Michal Hocko wrote:
>> On Thu 03-08-17 14:38:18, Wei Wang wrote:
>> This is just too ugly and wrong actually. Never provide struct page
>> pointers outside of the zone->lock. What I've had in mind was to simply
>> walk free lists of the suitable order and call the callback for each 
>> one.
>> Something as simple as
>>
>>     for (i = 0; i < MAX_NR_ZONES; i++) {
>>         struct zone *zone = &pgdat->node_zones[i];
>>
>>         if (!populated_zone(zone))
>>             continue;
>
> Can we directly use for_each_populated_zone(zone) here?
>
>
>> spin_lock_irqsave(&zone->lock, flags);
>>         for (order = min_order; order < MAX_ORDER; ++order) {
>
>
> This appears to be covered by for_each_migratetype_order(order, mt) 
> below.
>
>
>>             struct free_area *free_area = &zone->free_area[order];
>>             enum migratetype mt;
>>             struct page *page;
>>
>>             if (!free_area->nr_pages)
>>                 continue;
>>
>>             for_each_migratetype_order(order, mt) {
>>                 list_for_each_entry(page,
>>                         &free_area->free_list[mt], lru) {
>>
>>                     pfn = page_to_pfn(page);
>>                     visit(opaque2, prn, 1<<order);
>>                 }
>>             }
>>         }
>>
>>         spin_unlock_irqrestore(&zone->lock, flags);
>>     }
>>
>> [...]
>>
>
> What do you think if we further simply the above implementation like 
> this:
>
> for_each_populated_zone(zone) {
>                 for_each_migratetype_order_decend(1, order, mt) {

here it will be min_order (passed by the caller), instead of "1",
that is, for_each_migratetype_order_decend(min_order, order, mt)


> spin_lock_irqsave(&zone->lock, flags);
>                         list_for_each_entry(page,
> &zone->free_area[order].free_list[mt], lru) {
>                                 pfn = page_to_pfn(page);
>                                 visit(opaque1, pfn, 1 << order);
>                         }
>                         spin_unlock_irqrestore(&zone->lock, flags);
>                 }
>         }
>
>


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
