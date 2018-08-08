Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE016B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 21:38:40 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u2-v6so455029pls.7
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 18:38:40 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 1-v6si2166776plj.411.2018.08.07.18.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 18:38:39 -0700 (PDT)
Subject: Re: [PATCH V2 2/4] mm: introduce memory type MEMORY_DEVICE_DEV_DAX
References: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
 <7e20d862f96662e1a7736dbb747a71949933dcd4.1531241281.git.yi.z.zhang@linux.intel.com>
 <20180807091120.ybne44o2fy2mxcch@quack2.suse.cz>
From: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Message-ID: <60a42f73-1772-24eb-26f0-efd892b0487c@linux.intel.com>
Date: Wed, 8 Aug 2018 17:22:42 +0800
MIME-Version: 1.0
In-Reply-To: <20180807091120.ybne44o2fy2mxcch@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, hch@lst.de, yu.c.zhang@intel.com, linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com



On 2018a1'08ae??07ae?JPY 17:11, Jan Kara wrote:
> On Wed 11-07-18 01:01:59, Zhang Yi wrote:
>> Currently, NVDIMM pages will be marked 'PageReserved'. However, unlike
>> other reserved PFNs, pages on NVDIMM shall still behave like normal ones
>> in many cases, i.e. when used as backend memory of KVM guest. This patch
>> introduces a new memory type, MEMORY_DEVICE_DEV_DAX. And set this flag
>> while dax driver hotplug the device memory.
>>
>> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
>> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
>> ---
>>  drivers/dax/pmem.c       | 1 +
>>  include/linux/memremap.h | 9 +++++++++
>>  2 files changed, 10 insertions(+)
>>
>> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
>> index fd49b24..fb3f363 100644
>> --- a/drivers/dax/pmem.c
>> +++ b/drivers/dax/pmem.c
>> @@ -111,6 +111,7 @@ static int dax_pmem_probe(struct device *dev)
>>  		return rc;
>>  
>>  	dax_pmem->pgmap.ref = &dax_pmem->ref;
>> +	dax_pmem->pgmap.type = MEMORY_DEVICE_DEV_DAX;
>>  	addr = devm_memremap_pages(dev, &dax_pmem->pgmap);
>>  	if (IS_ERR(addr))
>>  		return PTR_ERR(addr);
>> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>> index 5ebfff6..a36bce8 100644
>> --- a/include/linux/memremap.h
>> +++ b/include/linux/memremap.h
>> @@ -53,11 +53,20 @@ struct vmem_altmap {
>>   * wakeup event whenever a page is unpinned and becomes idle. This
>>   * wakeup is used to coordinate physical address space management (ex:
>>   * fs truncate/hole punch) vs pinned pages (ex: device dma).
>> + *
>> + * MEMORY_DEVICE_DEV_DAX:
>> + * DAX driver hotplug the device memory and move it to memory zone, these
>> + * pages will be marked reserved flag. However, some other kernel componet
>> + * will misconceive these pages are reserved mmio (ex: we map these dev_dax
>> + * or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
>> + * MEMORY_DEVICE_FS_DAX, we can differentiate the pages on NVDIMM with the
>> + * normal reserved pages.
> So I believe the description should be in terms of what kind of memory is
> the MEMORY_DEVICE_DEV_DAX type, not how users use this type. See comments
> for other memory types...
>
> 								Honza
Yes, agree, thanks for your kindly review. Jan.
>
>>   */
>>  enum memory_type {
>>  	MEMORY_DEVICE_PRIVATE = 1,
>>  	MEMORY_DEVICE_PUBLIC,
>>  	MEMORY_DEVICE_FS_DAX,
>> +	MEMORY_DEVICE_DEV_DAX,
>>  };
>>  
>>  /*
>> -- 
>> 2.7.4
>>
