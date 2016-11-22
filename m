Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A55586B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:02:56 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so12012049pgq.7
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:02:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p62si26382678pfl.255.2016.11.21.21.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 21:02:55 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAM4weX1141611
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:02:55 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26veh1228g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:02:55 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 22 Nov 2016 15:02:52 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 08A8D3578053
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:02:51 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAM52pBX35979454
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:02:51 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAM52oGf008753
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:02:50 +1100
Subject: Re: [HMM v13 04/18] mm/ZONE_DEVICE/free-page: callback when page is
 freed
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-5-git-send-email-jglisse@redhat.com>
 <5832AF9A.8020808@linux.vnet.ibm.com> <20161121123451.GD2392@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 22 Nov 2016 10:32:48 +0530
MIME-Version: 1.0
In-Reply-To: <20161121123451.GD2392@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <5833D178.9080300@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/21/2016 06:04 PM, Jerome Glisse wrote:
> On Mon, Nov 21, 2016 at 01:56:02PM +0530, Anshuman Khandual wrote:
>> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
>>> When a ZONE_DEVICE page refcount reach 1 it means it is free and nobody
>>> is holding a reference on it (only device to which the memory belong do).
>>> Add a callback and call it when that happen so device driver can implement
>>> their own free page management.
>>>
>>> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>>> ---
>>>  include/linux/memremap.h | 4 ++++
>>>  kernel/memremap.c        | 8 ++++++++
>>>  2 files changed, 12 insertions(+)
>>>
>>> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>>> index fe61dca..469c88d 100644
>>> --- a/include/linux/memremap.h
>>> +++ b/include/linux/memremap.h
>>> @@ -37,17 +37,21 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>>>  
>>>  /**
>>>   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
>>> + * @free_devpage: free page callback when page refcount reach 1
>>>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>>>   * @res: physical address range covered by @ref
>>>   * @ref: reference count that pins the devm_memremap_pages() mapping
>>>   * @dev: host device of the mapping for debug
>>> + * @data: privata data pointer for free_devpage
>>>   * @flags: memory flags (look for MEMORY_FLAGS_NONE in memory_hotplug.h)
>>>   */
>>>  struct dev_pagemap {
>>> +	void (*free_devpage)(struct page *page, void *data);
>>>  	struct vmem_altmap *altmap;
>>>  	const struct resource *res;
>>>  	struct percpu_ref *ref;
>>>  	struct device *dev;
>>> +	void *data;
>>>  	int flags;
>>>  };
>>>  
>>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>>> index 438a73aa2..3d28048 100644
>>> --- a/kernel/memremap.c
>>> +++ b/kernel/memremap.c
>>> @@ -190,6 +190,12 @@ EXPORT_SYMBOL(get_zone_device_page);
>>>  
>>>  void put_zone_device_page(struct page *page)
>>>  {
>>> +	/*
>>> +	 * If refcount is 1 then page is freed and refcount is stable as nobody
>>> +	 * holds a reference on the page.
>>> +	 */
>>> +	if (page->pgmap->free_devpage && page_count(page) == 1)
>>> +		page->pgmap->free_devpage(page, page->pgmap->data);
>>>  	put_dev_pagemap(page->pgmap);
>>>  }
>>>  EXPORT_SYMBOL(put_zone_device_page);
>>> @@ -326,6 +332,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>>>  	pgmap->ref = ref;
>>>  	pgmap->res = &page_map->res;
>>>  	pgmap->flags = flags | MEMORY_DEVICE;
>>> +	pgmap->free_devpage = NULL;
>>> +	pgmap->data = NULL;
>>
>> When is the driver expected to load up pgmap->free_devpage ? I thought
>> this function is one of the right places. Though as all the pages in
>> the same hotplug operation point to the same dev_pagemap structure this
>> loading can be done at later point of time as well.
>>
> 
> I wanted to avoid adding more argument to devm_memremap_pages() as it already
> has a long list. Hence why i let the caller set those afterward.

IMHO we should still pass it through this function argument so that
by the time the function returns we will have device memory properly
setup through ZONE_DEVICE with all bells and whistles enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
