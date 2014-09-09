Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA7E6B008C
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 12:16:24 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ex7so4619351wid.2
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 09:16:24 -0700 (PDT)
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
        by mx.google.com with ESMTPS id qk7si17844961wjc.81.2014.09.09.09.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 09:16:23 -0700 (PDT)
Received: by mail-wg0-f52.google.com with SMTP id x13so3662407wgg.23
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 09:16:22 -0700 (PDT)
Message-ID: <540F27D4.3000709@plexistor.com>
Date: Tue, 09 Sep 2014 19:16:20 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 9/9] prd: Add support for page struct mapping
References: <53EB5536.8020702@gmail.com> <53EB5960.50200@plexistor.com> <53F75562.7040100@intel.com>
In-Reply-To: <53F75562.7040100@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On 08/22/2014 05:36 PM, Dave Hansen wrote:
> On 08/13/2014 05:26 AM, Boaz Harrosh wrote:
>> +#ifdef CONFIG_BLK_DEV_PMEM_USE_PAGES
>> +static int prd_add_page_mapping(phys_addr_t phys_addr, size_t total_size,
>> +				void **o_virt_addr)
>> +{
>> +	int nid = memory_add_physaddr_to_nid(phys_addr);
>> +	unsigned long start_pfn = phys_addr >> PAGE_SHIFT;
>> +	unsigned long nr_pages = total_size >> PAGE_SHIFT;
>> +	unsigned int start_sec = pfn_to_section_nr(start_pfn);
>> +	unsigned int end_sec = pfn_to_section_nr(start_pfn + nr_pages - 1);
> 
> Nit: any chance you'd change this to be an exclusive end?  In the mm
> code, we usually do:
> 
> 	unsigned int end_sec = pfn_to_section_nr(start_pfn + nr_pages);
> 
> so the for loops end up <end_sec instead of <=end_sec.
> 

Done, thanks please see new patches I CCed you as well

>> +	unsigned long phys_start_pfn;
>> +	struct page **page_array, **mapped_page_array;
>> +	unsigned long i;
>> +	struct vm_struct *vm_area;
>> +	void *virt_addr;
>> +	int ret = 0;
> 
> This is a philosophical thing, but I don't see *ANY* block-specific code
> in here.  Seems like this belongs in mm/ to me.
> 

Yes, as suggested by Toshi as well, I have moved it there and fixed
bugs.

> Is there a reason you don't just do this at boot and have to use hotplug
> at runtime for it?  

This is a plug and play thing. This memory region is not reached via memory
controller, it is on the ACPI/SBUS device with physical address/size specified
there. On load of block-device this will be called. Also a block device can
be unloaded and should be able to cleanup.

> What are the ratio of pmem to RAM?  Is it possible
> to exhaust all of RAM with 'struct page's for pmem?

Yes! in the not very distant future there will be systems that have only pmem.
yes no RAM. This is because once available some pmem has much better power
efficiency then DRAM, because of the no refresh thing. So even cellphones and
embedded system first.

At which point the pmem management system will need to set aside an area for the
Kernel's volatile usage. This here makes a distinction that though the addressed
region is persistent the managing page-struct section is volatile and renewed on
boot.

The way I see it is that the Admin/setup will need to partition its storage with
setting up a partition "as ram", this will just be the "swap" partition. And the
system will run directly from the SWAP partition.
Note that the fact that this is persistent memory is not lost. The
hibernate/de-hibernate will then see that this is persistent memory and will do nothing.
(swapd will not run of course)

So the Admin/setup will need to calculate and configure the proper ratio of
volatile vs non-volatile portions of its system for proper usage.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
