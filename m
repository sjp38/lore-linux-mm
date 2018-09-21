Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACE7E8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 16:03:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id h1-v6so1877939pld.21
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 13:03:46 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c8-v6si1076184pgm.447.2018.09.21.13.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 13:03:45 -0700 (PDT)
Subject: Re: [PATCH v4 3/5] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
References: <20180920215824.19464.8884.stgit@localhost.localdomain>
 <20180920222758.19464.83992.stgit@localhost.localdomain>
 <2254cfe1-5cd3-eedc-1f24-8e011dcf3575@microsoft.com>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <f4d5ace6-9657-746b-9448-064a4b7cfb8d@linux.intel.com>
Date: Fri, 21 Sep 2018 13:03:44 -0700
MIME-Version: 1.0
In-Reply-To: <2254cfe1-5cd3-eedc-1f24-8e011dcf3575@microsoft.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "logang@deltatee.com" <logang@deltatee.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>



On 9/21/2018 12:50 PM, Pasha Tatashin wrote:
> 
> 
> On 9/20/18 6:29 PM, Alexander Duyck wrote:
>> The ZONE_DEVICE pages were being initialized in two locations. One was with
>> the memory_hotplug lock held and another was outside of that lock. The
>> problem with this is that it was nearly doubling the memory initialization
>> time. Instead of doing this twice, once while holding a global lock and
>> once without, I am opting to defer the initialization to the one outside of
>> the lock. This allows us to avoid serializing the overhead for memory init
>> and we can instead focus on per-node init times.
>>
>> One issue I encountered is that devm_memremap_pages and
>> hmm_devmmem_pages_create were initializing only the pgmap field the same
>> way. One wasn't initializing hmm_data, and the other was initializing it to
>> a poison value. Since this is something that is exposed to the driver in
>> the case of hmm I am opting for a third option and just initializing
>> hmm_data to 0 since this is going to be exposed to unknown third party
>> drivers.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
>> +void __ref memmap_init_zone_device(struct zone *zone,
>> +				   unsigned long start_pfn,
>> +				   unsigned long size,
>> +				   struct dev_pagemap *pgmap)
>> +{
>> +	unsigned long pfn, end_pfn = start_pfn + size;
>> +	struct pglist_data *pgdat = zone->zone_pgdat;
>> +	unsigned long zone_idx = zone_idx(zone);
>> +	unsigned long start = jiffies;
>> +	int nid = pgdat->node_id;
>> +
>> +	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
>> +		return;
>> +
>> +	/*
>> +	 * The call to memmap_init_zone should have already taken care
>> +	 * of the pages reserved for the memmap, so we can just jump to
>> +	 * the end of that region and start processing the device pages.
>> +	 */
>> +	if (pgmap->altmap_valid) {
>> +		struct vmem_altmap *altmap = &pgmap->altmap;
>> +
>> +		start_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
>> +		size = end_pfn - start_pfn;
>> +	}
>> +
>> +	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>> +		struct page *page = pfn_to_page(pfn);
>> +
>> +		__init_single_page(page, pfn, zone_idx, nid);
>> +
>> +		/*
>> +		 * Mark page reserved as it will need to wait for onlining
>> +		 * phase for it to be fully associated with a zone.
>> +		 *
>> +		 * We can use the non-atomic __set_bit operation for setting
>> +		 * the flag as we are still initializing the pages.
>> +		 */
>> +		__SetPageReserved(page);
>> +
>> +		/*
>> +		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
>> +		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
>> +		 * page is ever freed or placed on a driver-private list.
>> +		 */
>> +		page->pgmap = pgmap;
>> +		page->hmm_data = 0;
> 
> __init_single_page()
>    mm_zero_struct_page()
> 
> Takes care of zeroing, no need to do another store here.

The problem is __init_singe_page also calls INIT_LIST_HEAD which I 
believe sets the prev pointer which overlaps with hmm_data.

> 
> Looks good otherwise.
> 
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> 

Thanks for the review.
