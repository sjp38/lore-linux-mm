Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 139CB6B0003
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 01:16:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c23-v6so23465904oiy.3
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 22:16:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f10-v6si6748514oic.94.2018.07.08.22.16.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jul 2018 22:16:34 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w695E1Ut098689
	for <linux-mm@kvack.org>; Mon, 9 Jul 2018 01:16:33 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k40c72wat-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:16:33 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 9 Jul 2018 01:16:32 -0400
Subject: Re: [RFC PATCH 2/2] mm/pmem: Add memblock based e820 platform driver
References: <20180706082911.13405-1-aneesh.kumar@linux.ibm.com>
 <20180706082911.13405-2-aneesh.kumar@linux.ibm.com>
 <CAOSf1CH2c2MBU2TofY_TRx1jn73C75-ksR=a=H1AuSh1zxa9OA@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Mon, 9 Jul 2018 10:46:26 +0530
MIME-Version: 1.0
In-Reply-To: <CAOSf1CH2c2MBU2TofY_TRx1jn73C75-ksR=a=H1AuSh1zxa9OA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <80787c32-6a67-48b6-8f68-622280b8aa2d@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver <oohall@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 07/07/2018 01:20 PM, Oliver wrote:
> On Fri, Jul 6, 2018 at 6:29 PM, Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>> This patch steal system RAM and use that to emulate pmem device using the
>> e820 platform driver.
>>
>> This adds a new kernel command line 'pmemmap' which takes the format <size[KMG]>
>> to allocate memory early in the boot. This memory is later registered as
>> persistent memory range.
>>
>> Based on original patch from Oliver OHalloran <oliveroh@au1.ibm.com>
> 
> I use this account rather than my internal address for community
> facing stuff since
> no one deserves to have IBM email inflicted upon them. Also you left out the
> apostrophe, you monster!


:) Will switch to gmail.com address?

> 
>> Not-Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>>   drivers/nvdimm/Kconfig        |  13 ++++
>>   drivers/nvdimm/Makefile       |   1 +
>>   drivers/nvdimm/memblockpmem.c | 115 ++++++++++++++++++++++++++++++++++
>>   3 files changed, 129 insertions(+)
>>   create mode 100644 drivers/nvdimm/memblockpmem.c
>>
>> diff --git a/drivers/nvdimm/Kconfig b/drivers/nvdimm/Kconfig
>> index 50d2a33de441..cbbbcbd4506b 100644
>> --- a/drivers/nvdimm/Kconfig
>> +++ b/drivers/nvdimm/Kconfig
>> @@ -115,4 +115,17 @@ config OF_PMEM
>>   config PMEM_PLATFORM_DEVICE
>>          bool
>>
>> +config MEMBLOCK_PMEM
>> +       bool "pmemmap= parameter support"
>> +       default y
>> +       depends on HAVE_MEMBLOCK
>> +       select PMEM_PLATFORM_DEVICE
>> +       help
>> +         Add support for the pmemmap= kernel command line parameter. This is similar
>> +         to the memmap= parameter available on ACPI platforms, but it uses generic
>> +         kernel facilities (the memblock allocator) to reserve memory rather than adding
>> +         to the e820 table.
>> +
>> +         Select Y if unsure.
>> +
>>   endif
>> diff --git a/drivers/nvdimm/Makefile b/drivers/nvdimm/Makefile
>> index 94f7f29146ce..0215ce0182e9 100644
>> --- a/drivers/nvdimm/Makefile
>> +++ b/drivers/nvdimm/Makefile
>> @@ -5,6 +5,7 @@ obj-$(CONFIG_ND_BTT) += nd_btt.o
>>   obj-$(CONFIG_ND_BLK) += nd_blk.o
>>   obj-$(CONFIG_PMEM_PLATFORM_DEVICE) += nd_e820.o
>>   obj-$(CONFIG_OF_PMEM) += of_pmem.o
>> +obj-$(CONFIG_MEMBLOCK_PMEM) += memblockpmem.o
> 
> Does this work when libnvdimm is built as a module? I remember doing
> something like
> this and discovering that the early_param() stuff didn't get included
> in the vmlinux
> when libnvdimm was built as a module due to how the makefiles worked.
> It might have
> been a bug in the RHEL7 tree I was using that has since been fixed upstream.
> 


I didn't check that. Will do that in next iteration.



>>   nd_pmem-y := pmem.o
>>
>> diff --git a/drivers/nvdimm/memblockpmem.c b/drivers/nvdimm/memblockpmem.c
>> new file mode 100644
>> index 000000000000..d39772b75fcd
>> --- /dev/null
>> +++ b/drivers/nvdimm/memblockpmem.c
>> @@ -0,0 +1,115 @@
>> +// SPDX-License-Identifier: GPL-2.0+
>> +/*
>> + * Copyright (c) 2018 IBM Corporation
>> + */
>> +
>> +#define pr_fmt(fmt) "memblock pmem: " fmt
>> +
>> +#include <linux/libnvdimm.h>
>> +#include <linux/bootmem.h>
>> +#include <linux/memblock.h>
>> +#include <linux/mmzone.h>
>> +#include <linux/cpu.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/init.h>
>> +#include <linux/ioport.h>
>> +#include <linux/ctype.h>
>> +#include <linux/slab.h>
>> +
>> +/*
>> + * Align pmem reservations to the section size so we don't have issues with
>> + * memory hotplug
>> + */
>> +#ifdef CONFIG_SPARSEMEM
>> +#define BOOTPMEM_ALIGN (1UL << SECTION_SIZE_BITS)
>> +#else
>> +#define BOOTPMEM_ALIGN PFN_DEFAULT_ALIGNMENT
>> +#endif
> 
> Is aligning to the section size sufficient? IIRC I had to align it to
> the memory block
> size on some systems. Of course, that might have been a RHEL bug that has
> since been fixed upstream.
> 

Ok, I didn't face any issues. But will look more what issues we could face.



>> +
>> +static __initdata u64 pmem_size;
>> +static __initdata phys_addr_t pmem_stolen_memory;
>> +
>> +static void alloc_pmem_from_memblock(void)
>> +{
>> +
>> +       pmem_stolen_memory = memblock_alloc_base(pmem_size,
>> +                                                BOOTPMEM_ALIGN,
>> +                                                MEMBLOCK_ALLOC_ACCESSIBLE);
>> +       if (!pmem_stolen_memory) {
>> +               pr_err("Failed to allocate memory for PMEM from memblock\n");
>> +               return;
>> +       }
>> +
>> +       /*
>> +        * Remove from the memblock reserved range
>> +        */
>> +       memblock_free(pmem_stolen_memory, pmem_size);
>> +
>> +       /*
>> +        * Remove from the memblock memory range.
>> +        */
>> +       memblock_remove(pmem_stolen_memory, pmem_size);
>> +       pr_info("Allocated %ld memory at 0x%lx\n", (unsigned long)pmem_size,
>> +               (unsigned long)pmem_stolen_memory);
>> +       return;
>> +}
>> +
>> +/*
>> + * pmemmap=ss[KMG]
>> + *
>> + * This is similar to the memremap=offset[KMG]!size[KMG] paramater
>> + * for adding a legacy pmem range to the e820 map on x86, but it's
>> + * platform agnostic.
>> + *
>> + * e.g. pmemmap=16G allocates 16G pmem region
> 
> I'm not really thrilled with this and I'd rather we kept the <size>@<node id>
> format and the ability to reserve multiple regions that I had in the
> old version.
> 
> I know getting the nid allocations working is a pain in the ass since
> HAVE_MEMBLOCK_NODE_MAP doesn't specify *when* in the boot process
> the node map information is actually available, but it's useful
> functionality and
> I think the problems are resolvable.
> 


The reason I dropped the @nid is because, we do set node details in 
memblock late (memblock_set_node()). We setup our linear mapped page 
table before that. That implies, we can't steal memory from memblock and 
use that for pmem backing if we do the pmem backing allocation after 
node information is set on memblock. Since we can't use nid, I was not 
sure there is any value in doing multiple pmem region.

> It's also possible that the whole memblock approach to this is wrong and we
> should look at doing something similar to how gigantic pages are allocated
> at runtime.
> 
>> + */
>> +static int __init parse_pmemmap(char *p)
>> +{
>> +       char *old_p = p;
>> +
>> +       if (!p)
>> +               return -EINVAL;
>> +
>> +       pmem_size = memparse(p, &p);
>> +       if (p == old_p)
>> +               return -EINVAL;
>> +
>> +       alloc_pmem_from_memblock();
>> +       return 0;
>> +}
>> +early_param("pmemmap", parse_pmemmap);
>> +
>> +static __init int register_e820_pmem(void)
>> +{
>> +       struct resource *res, *conflict;
>> +        struct platform_device *pdev;
>> +
>> +       if (!pmem_stolen_memory)
>> +               return 0;
>> +
>> +       res = kzalloc(sizeof(*res), GFP_KERNEL);
>> +       if (!res)
>> +               return -1;
>> +
>> +       memset(res, 0, sizeof(*res));
>> +       res->start = pmem_stolen_memory;
>> +       res->end = pmem_stolen_memory + pmem_size - 1;
>> +       res->name = "Persistent Memory (legacy)";
>> +       res->desc = IORES_DESC_PERSISTENT_MEMORY_LEGACY;
>> +       res->flags = IORESOURCE_MEM;
>> +
>> +       conflict = insert_resource_conflict(&iomem_resource, res);
>> +       if (conflict) {
>> +               pr_err("%pR conflicts, try insert below %pR\n", res, conflict);
>> +               kfree(res);
>> +               return -1;
>> +       }
>> +       /*
>> +        * See drivers/nvdimm/e820.c for the implementation, this is
>> +        * simply here to trigger the module to load on demand.
>> +        */
>> +       pdev = platform_device_alloc("e820_pmem", -1);
>> +
>> +       return platform_device_add(pdev);
>> +}
>> +device_initcall(register_e820_pmem);
>> --

-aneesh
