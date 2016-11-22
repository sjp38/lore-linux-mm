Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 591F56B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:15:21 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so2276853wme.5
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:15:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i7si13161735wjl.146.2016.11.21.21.15.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 21:15:20 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAM5E9kE127839
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:15:18 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26uyx4rx6e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:15:18 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 22 Nov 2016 15:15:14 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 94CD63578052
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:15:12 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAM5FCRE25755798
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:15:12 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAM5FCXB026763
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:15:12 +1100
Subject: Re: [HMM v13 02/18] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-3-git-send-email-jglisse@redhat.com>
 <5832AB21.1010606@linux.vnet.ibm.com> <20161121123316.GC2392@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 22 Nov 2016 10:45:04 +0530
MIME-Version: 1.0
In-Reply-To: <20161121123316.GC2392@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <5833D458.7020508@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/21/2016 06:03 PM, Jerome Glisse wrote:
> On Mon, Nov 21, 2016 at 01:36:57PM +0530, Anshuman Khandual wrote:
>> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
>>> This add support for un-addressable device memory. Such memory is hotpluged
>>> only so we can have struct page but should never be map. This patch add code
>>
>> struct pages inside the system RAM range unlike the vmem_altmap scheme
>> where the struct pages can be inside the device memory itself. This
>> possibility does not arise for un addressable device memory. May be we
>> will have to block the paths where vmem_altmap is requested along with
>> un addressable device memory.
> 
> I did not think checking for that explicitly was necessary, sounded like shooting
> yourself in the foot and that it would be obvious :)

dev_memremap_pages() is kind of an important interface for getting
device memory into kernel through ZONE_DEVICE. So it should actually
enforce all these checks. Also we should document these things clearly
above the function.

> 
> [...]
> 
>>> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>>> index 9341619..fe61dca 100644
>>> --- a/include/linux/memremap.h
>>> +++ b/include/linux/memremap.h
>>> @@ -41,22 +41,34 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>>>   * @res: physical address range covered by @ref
>>>   * @ref: reference count that pins the devm_memremap_pages() mapping
>>>   * @dev: host device of the mapping for debug
>>> + * @flags: memory flags (look for MEMORY_FLAGS_NONE in memory_hotplug.h)
>>
>> ^^^^^^^^^^^^^ device memory flags instead ?
> 
> Well maybe it will be use for something else than device memory in the future
> but yes for now it is only device memory so i can rename it.
> 
>>>   */
>>>  struct dev_pagemap {
>>>  	struct vmem_altmap *altmap;
>>>  	const struct resource *res;
>>>  	struct percpu_ref *ref;
>>>  	struct device *dev;
>>> +	int flags;
>>>  };
>>>  
>>>  #ifdef CONFIG_ZONE_DEVICE
>>>  void *devm_memremap_pages(struct device *dev, struct resource *res,
>>> -		struct percpu_ref *ref, struct vmem_altmap *altmap);
>>> +			  struct percpu_ref *ref, struct vmem_altmap *altmap,
>>> +			  struct dev_pagemap **ppgmap, int flags);
>>>  struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
>>> +
>>> +static inline bool is_addressable_page(const struct page *page)
>>> +{
>>> +	return ((page_zonenum(page) != ZONE_DEVICE) ||
>>> +		!(page->pgmap->flags & MEMORY_UNADDRESSABLE));
>>> +}
>>>  #else
>>>  static inline void *devm_memremap_pages(struct device *dev,
>>> -		struct resource *res, struct percpu_ref *ref,
>>> -		struct vmem_altmap *altmap)
>>> +					struct resource *res,
>>> +					struct percpu_ref *ref,
>>> +					struct vmem_altmap *altmap,
>>> +					struct dev_pagemap **ppgmap,
>>> +					int flags)
>>
>>
>> As I had mentioned before devm_memremap_pages() should be changed not
>> to accept a valid altmap along with request for un-addressable memory.
> 
> If you fear such case yes sure.
> 
> 
> [...]
> 
>>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>>> index 07665eb..438a73aa2 100644
>>> --- a/kernel/memremap.c
>>> +++ b/kernel/memremap.c
>>> @@ -246,7 +246,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
>>>  	/* pages are dead and unused, undo the arch mapping */
>>>  	align_start = res->start & ~(SECTION_SIZE - 1);
>>>  	align_size = ALIGN(resource_size(res), SECTION_SIZE);
>>> -	arch_remove_memory(align_start, align_size, MEMORY_DEVICE);
>>> +	arch_remove_memory(align_start, align_size, pgmap->flags);
>>>  	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
>>>  	pgmap_radix_release(res);
>>>  	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
>>> @@ -270,6 +270,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
>>>   * @res: "host memory" address range
>>>   * @ref: a live per-cpu reference count
>>>   * @altmap: optional descriptor for allocating the memmap from @res
>>> + * @ppgmap: pointer set to new page dev_pagemap on success
>>> + * @flags: flag for memory (look for MEMORY_FLAGS_NONE in memory_hotplug.h)
>>>   *
>>>   * Notes:
>>>   * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
>>> @@ -280,7 +282,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
>>>   *    this is not enforced.
>>>   */
>>>  void *devm_memremap_pages(struct device *dev, struct resource *res,
>>> -		struct percpu_ref *ref, struct vmem_altmap *altmap)
>>> +			  struct percpu_ref *ref, struct vmem_altmap *altmap,
>>> +			  struct dev_pagemap **ppgmap, int flags)
>>>  {
>>>  	resource_size_t key, align_start, align_size, align_end;
>>>  	pgprot_t pgprot = PAGE_KERNEL;
>>> @@ -322,6 +325,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>>>  	}
>>>  	pgmap->ref = ref;
>>>  	pgmap->res = &page_map->res;
>>> +	pgmap->flags = flags | MEMORY_DEVICE;
>>
>> So the caller of devm_memremap_pages() should not have give out MEMORY_DEVICE
>> in the flag it passed on to this function ? Hmm, else we should just check
>> that the flags contains all appropriate bits before proceeding.
> 
> Here i was just trying to be on the safe side, yes caller should already have set
> the flag but this function is only use for device memory so it did not seem like
> it would hurt to be extra safe. I can add a BUG_ON() but it seems people have mix
> feeling about BUG_ON()

We dont have to do BUG_ON(), just a check that all expected flags are
in there, else fail the call. Now this function does not return any
value to be checked inside driver, in that case we can just do a error
message print and move on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
