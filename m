Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14AA46B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:36:24 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k190so88164871pge.9
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:36:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z3si3706525pgs.149.2017.08.10.00.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 00:36:23 -0700 (PDT)
Message-ID: <598C0D7A.9060909@intel.com>
Date: Thu, 10 Aug 2017 15:38:34 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v13 4/5] mm: support reporting free page
 blocks
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com> <1501742299-4369-5-git-send-email-wei.w.wang@intel.com> <20170803091151.GF12521@dhcp22.suse.cz> <59895668.9090104@intel.com> <59895B71.7050709@intel.com> <20170810070517.GB23863@dhcp22.suse.cz>
In-Reply-To: <20170810070517.GB23863@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 08/10/2017 03:05 PM, Michal Hocko wrote:
> On Tue 08-08-17 14:34:25, Wei Wang wrote:
>> On 08/08/2017 02:12 PM, Wei Wang wrote:
>>> On 08/03/2017 05:11 PM, Michal Hocko wrote:
>>>> On Thu 03-08-17 14:38:18, Wei Wang wrote:
>>>> This is just too ugly and wrong actually. Never provide struct page
>>>> pointers outside of the zone->lock. What I've had in mind was to simply
>>>> walk free lists of the suitable order and call the callback for each
>>>> one.
>>>> Something as simple as
>>>>
>>>>     for (i = 0; i < MAX_NR_ZONES; i++) {
>>>>         struct zone *zone = &pgdat->node_zones[i];
>>>>
>>>>         if (!populated_zone(zone))
>>>>             continue;
>>> Can we directly use for_each_populated_zone(zone) here?
> yes, my example couldn't because I was still assuming per-node API
>
>>>> spin_lock_irqsave(&zone->lock, flags);
>>>>         for (order = min_order; order < MAX_ORDER; ++order) {
>>>
>>> This appears to be covered by for_each_migratetype_order(order, mt) below.
> yes but
> #define for_each_migratetype_order(order, type) \
> 	for (order = 0; order < MAX_ORDER; order++) \
> 		for (type = 0; type < MIGRATE_TYPES; type++)
>
> so you would have to skip orders < min_order

Yes, that's why we have a new macro

#define for_each_migratetype_order_decend(min_order, order, type) \
  for (order = MAX_ORDER - 1; order < MAX_ORDER && order >= min_order; \
  order--) \
     for (type = 0; type < MIGRATE_TYPES; type++)

If you don't like the macro, we can also directly use it in the code.

I think it would be better to report the larger free page block first, since
the callback has an opportunity (though just a theoretical possibility, 
good to
take that into consideration if possible) to skip reporting the given 
free page
block to the hypervisor as the ring gets full. Losing the small block is 
better
than losing the larger one, in terms of the optimization work.


Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
