Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BAA26B0697
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 07:24:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k190so11165455pge.9
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 04:24:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e39si22270014plg.499.2017.08.03.04.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 04:24:38 -0700 (PDT)
Message-ID: <59830897.2060203@intel.com>
Date: Thu, 03 Aug 2017 19:27:19 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 4/5] mm: support reporting free page blocks
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com> <1501742299-4369-5-git-send-email-wei.w.wang@intel.com> <20170803091151.GF12521@dhcp22.suse.cz> <5982FE07.3040207@intel.com> <20170803104417.GI12521@dhcp22.suse.cz>
In-Reply-To: <20170803104417.GI12521@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 08/03/2017 06:44 PM, Michal Hocko wrote:
> On Thu 03-08-17 18:42:15, Wei Wang wrote:
>> On 08/03/2017 05:11 PM, Michal Hocko wrote:
>>> On Thu 03-08-17 14:38:18, Wei Wang wrote:
> [...]
>>>> +static int report_free_page_block(struct zone *zone, unsigned int order,
>>>> +				  unsigned int migratetype, struct page **page)
>>> This is just too ugly and wrong actually. Never provide struct page
>>> pointers outside of the zone->lock. What I've had in mind was to simply
>>> walk free lists of the suitable order and call the callback for each one.
>>> Something as simple as
>>>
>>> 	for (i = 0; i < MAX_NR_ZONES; i++) {
>>> 		struct zone *zone = &pgdat->node_zones[i];
>>>
>>> 		if (!populated_zone(zone))
>>> 			continue;
>>> 		spin_lock_irqsave(&zone->lock, flags);
>>> 		for (order = min_order; order < MAX_ORDER; ++order) {
>>> 			struct free_area *free_area = &zone->free_area[order];
>>> 			enum migratetype mt;
>>> 			struct page *page;
>>>
>>> 			if (!free_area->nr_pages)
>>> 				continue;
>>>
>>> 			for_each_migratetype_order(order, mt) {
>>> 				list_for_each_entry(page,
>>> 						&free_area->free_list[mt], lru) {
>>>
>>> 					pfn = page_to_pfn(page);
>>> 					visit(opaque2, prn, 1<<order);
>>> 				}
>>> 			}
>>> 		}
>>>
>>> 		spin_unlock_irqrestore(&zone->lock, flags);
>>> 	}
>>>
>>> [...]
>>
>> I think the above would take the lock for too long time. That's why we
>> prefer to take one free page block each time, and taking it one by one
>> also doesn't make a difference, in terms of the performance that we
>> need.
> I think you should start with simple approach and impove incrementally
> if this turns out to be not optimal. I really detest taking struct pages
> outside of the lock. You never know what might happen after the lock is
> dropped. E.g. can you race with the memory hotremove?


The caller won't use pages returned from the function, so I think there
shouldn't be an issue or race if the returned pages are used (i.e. not free
anymore) or simply gone due to hotremove.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
