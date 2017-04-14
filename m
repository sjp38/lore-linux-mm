Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 74A2D6B0038
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 22:28:49 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s85so63457040ios.1
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 19:28:49 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z136si1049926ioe.30.2017.04.13.19.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 19:28:48 -0700 (PDT)
Message-ID: <58F03443.9040202@intel.com>
Date: Fri, 14 Apr 2017 10:30:27 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 3/5] mm: function to offer a page block on the free
 list
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>	<1492076108-117229-4-git-send-email-wei.w.wang@intel.com> <20170413130217.2316b0394192d8677f5ddbdf@linux-foundation.org>
In-Reply-To: <20170413130217.2316b0394192d8677f5ddbdf@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 04/14/2017 04:02 AM, Andrew Morton wrote:
> On Thu, 13 Apr 2017 17:35:06 +0800 Wei Wang <wei.w.wang@intel.com> wrote:
>
>> Add a function to find a page block on the free list specified by the
>> caller. Pages from the page block may be used immediately after the
>> function returns. The caller is responsible for detecting or preventing
>> the use of such pages.
>>
>> ...
>>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4498,6 +4498,93 @@ void show_free_areas(unsigned int filter)
>>   	show_swap_cache_info();
>>   }
>>   
>> +/**
>> + * Heuristically get a page block in the system that is unused.
>> + * It is possible that pages from the page block are used immediately after
>> + * inquire_unused_page_block() returns. It is the caller's responsibility
>> + * to either detect or prevent the use of such pages.
>> + *
>> + * The free list to check: zone->free_area[order].free_list[migratetype].
>> + *
>> + * If the caller supplied page block (i.e. **page) is on the free list, offer
>> + * the next page block on the list to the caller. Otherwise, offer the first
>> + * page block on the list.
>> + *
>> + * Return 0 when a page block is found on the caller specified free list.
>> + */
>> +int inquire_unused_page_block(struct zone *zone, unsigned int order,
>> +			      unsigned int migratetype, struct page **page)
>> +{
> Perhaps we can wrap this in the appropriate ifdef so the kernels which
> won't be using virtio-balloon don't carry the added overhead.
>
>

OK. What do you think if we add this:

#if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE)



Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
