Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC836B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:32:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u69so25891724ita.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 07:32:29 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0065.outbound.protection.outlook.com. [104.47.33.65])
        by mx.google.com with ESMTPS id o124si2373164itc.71.2017.03.17.07.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 07:32:27 -0700 (PDT)
Subject: Re: [RFC PATCH v2 08/32] x86: Use PAGE_KERNEL protection for ioremap
 of memory page
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846761276.2349.4899767672892365544.stgit@brijesh-build-machine>
 <20170307145954.l2fqy5s5h65wbtyz@pd.tnic>
 <413f12e9-818a-745d-374b-3dbc439e972c@amd.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <0a7de265-1352-6327-ef3a-4287bfca732d@amd.com>
Date: Fri, 17 Mar 2017 09:32:15 -0500
MIME-Version: 1.0
In-Reply-To: <413f12e9-818a-745d-374b-3dbc439e972c@amd.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On 3/16/2017 3:04 PM, Tom Lendacky wrote:
> On 3/7/2017 8:59 AM, Borislav Petkov wrote:
>> On Thu, Mar 02, 2017 at 10:13:32AM -0500, Brijesh Singh wrote:
>>> From: Tom Lendacky <thomas.lendacky@amd.com>
>>>
>>> In order for memory pages to be properly mapped when SEV is active, we
>>> need to use the PAGE_KERNEL protection attribute as the base protection.
>>> This will insure that memory mapping of, e.g. ACPI tables, receives the
>>> proper mapping attributes.
>>>
>>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>>> ---
>>
>>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>>> index c400ab5..481c999 100644
>>> --- a/arch/x86/mm/ioremap.c
>>> +++ b/arch/x86/mm/ioremap.c
>>> @@ -151,7 +151,15 @@ static void __iomem
>>> *__ioremap_caller(resource_size_t phys_addr,
>>>                 pcm = new_pcm;
>>>         }
>>>
>>> +       /*
>>> +        * If the page being mapped is in memory and SEV is active then
>>> +        * make sure the memory encryption attribute is enabled in the
>>> +        * resulting mapping.
>>> +        */
>>>         prot = PAGE_KERNEL_IO;
>>> +       if (sev_active() && page_is_mem(pfn))
>>
>> Hmm, a resource tree walk per ioremap call. This could get expensive for
>> ioremap-heavy workloads.
>>
>> __ioremap_caller() gets called here during boot 55 times so not a whole
>> lot but I wouldn't be surprised if there were some nasty use cases which
>> ioremap a lot.
>>
>> ...
>>
>>> diff --git a/kernel/resource.c b/kernel/resource.c
>>> index 9b5f044..db56ba3 100644
>>> --- a/kernel/resource.c
>>> +++ b/kernel/resource.c
>>> @@ -518,6 +518,46 @@ int __weak page_is_ram(unsigned long pfn)
>>>  }
>>>  EXPORT_SYMBOL_GPL(page_is_ram);
>>>
>>> +/*
>>> + * This function returns true if the target memory is marked as
>>> + * IORESOURCE_MEM and IORESOUCE_BUSY and described as other than
>>> + * IORES_DESC_NONE (e.g. IORES_DESC_ACPI_TABLES).
>>> + */
>>> +static int walk_mem_range(unsigned long start_pfn, unsigned long
>>> nr_pages)
>>> +{
>>> +    struct resource res;
>>> +    unsigned long pfn, end_pfn;
>>> +    u64 orig_end;
>>> +    int ret = -1;
>>> +
>>> +    res.start = (u64) start_pfn << PAGE_SHIFT;
>>> +    res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
>>> +    res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>>> +    orig_end = res.end;
>>> +    while ((res.start < res.end) &&
>>> +        (find_next_iomem_res(&res, IORES_DESC_NONE, true) >= 0)) {
>>> +        pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
>>> +        end_pfn = (res.end + 1) >> PAGE_SHIFT;
>>> +        if (end_pfn > pfn)
>>> +            ret = (res.desc != IORES_DESC_NONE) ? 1 : 0;
>>> +        if (ret)
>>> +            break;
>>> +        res.start = res.end + 1;
>>> +        res.end = orig_end;
>>> +    }
>>> +    return ret;
>>> +}
>>
>> So the relevant difference between this one and walk_system_ram_range()
>> is this:
>>
>> -            ret = (*func)(pfn, end_pfn - pfn, arg);
>> +            ret = (res.desc != IORES_DESC_NONE) ? 1 : 0;
>>
>> so it seems to me you can have your own *func() pointer which does that
>> IORES_DESC_NONE comparison. And then you can define your own workhorse
>> __walk_memory_range() which gets called by both walk_mem_range() and
>> walk_system_ram_range() instead of almost duplicating them.
>>
>> And looking at walk_system_ram_res(), that one looks similar too except
>> the pfn computation. But AFAICT the pfn/end_pfn things are computed from
>> res.start and res.end so it looks to me like all those three functions
>> are crying for unification...
>
> I'll take a look at what it takes to consolidate these with a pre-patch.
> Then I'll add the new support.

It looks pretty straight forward to combine walk_iomem_res_desc() and
walk_system_ram_res(). The walk_system_ram_range() function would fit
easily into this, also, except for the fact that the callback function
takes unsigned longs vs the u64s of the other functions.  Is it worth
modifying all of the callers of walk_system_ram_range() (which are only
about 8 locations) to change the callback functions to accept u64s in
order to consolidate the walk_system_ram_range() function, too?

Thanks,
Tom

>
> Thanks,
> Tom
>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
