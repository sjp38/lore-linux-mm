Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFB66B0254
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 15:36:42 -0400 (EDT)
Received: by qgt47 with SMTP id 47so15970366qgt.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 12:36:42 -0700 (PDT)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com. [209.85.220.180])
        by mx.google.com with ESMTPS id f47si22747850qge.78.2015.09.29.12.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 12:36:41 -0700 (PDT)
Received: by qkas79 with SMTP id s79so8032467qka.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 12:36:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.20.1509291511440.11346@knanqh.ubzr>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150826012735.8851.49787.stgit@dwillia2-desk3.amr.corp.intel.com>
	<alpine.LFD.2.20.1509291511440.11346@knanqh.ubzr>
Date: Tue, 29 Sep 2015 12:36:36 -0700
Message-ID: <CANMBJr7Su2Gw_4oUj11grO-GMP-+tP0yp52zYB8KA3s5vo76VA@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] mm: move __phys_to_pfn and __pfn_to_phys to asm/generic/memory_model.h
From: Tyler Baker <tyler.baker@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Russell King <linux@arm.linux.org.uk>, linux-nvdimm@lists.01.org, Boaz Harrosh <boaz@plexistor.com>, david <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Ingo Molnar <mingo@kernel.org>

On 29 September 2015 at 12:21, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> On Tue, 25 Aug 2015, Dan Williams wrote:
>
>> From: Christoph Hellwig <hch@lst.de>
>>
>> Three architectures already define these, and we'll need them genericly
>> soon.
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  arch/arm/include/asm/memory.h       |    6 ------
>>  arch/arm64/include/asm/memory.h     |    6 ------
>>  arch/unicore32/include/asm/memory.h |    6 ------
>>  include/asm-generic/memory_model.h  |    6 ++++++
>>  4 files changed, 6 insertions(+), 18 deletions(-)
>>
>> diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
>> index b7f6fb462ea0..98d58bb04ac5 100644
>> --- a/arch/arm/include/asm/memory.h
>> +++ b/arch/arm/include/asm/memory.h
>> @@ -119,12 +119,6 @@
>>  #endif
>>
>>  /*
>> - * Convert a physical address to a Page Frame Number and back
>> - */
>> -#define      __phys_to_pfn(paddr)    ((unsigned long)((paddr) >> PAGE_SHIFT))
>> -#define      __pfn_to_phys(pfn)      ((phys_addr_t)(pfn) << PAGE_SHIFT)
>> -
>> -/*
>>   * Convert a page to/from a physical address
>>   */
>>  #define page_to_phys(page)   (__pfn_to_phys(page_to_pfn(page)))
>
> [...]
>
>> diff --git a/include/asm-generic/memory_model.h b/include/asm-generic/memory_model.h
>> index 14909b0b9cae..f20f407ce45d 100644
>> --- a/include/asm-generic/memory_model.h
>> +++ b/include/asm-generic/memory_model.h
>> @@ -69,6 +69,12 @@
>>  })
>>  #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
>>
>> +/*
>> + * Convert a physical address to a Page Frame Number and back
>> + */
>> +#define      __phys_to_pfn(paddr)    ((unsigned long)((paddr) >> PAGE_SHIFT))
>> +#define      __pfn_to_phys(pfn)      ((pfn) << PAGE_SHIFT)
>> +
>
> This patch, currently in mainline as commit 012dcef3f0, breaks LPAE on
> ARM32 with more than 4GB of RAM. The phys_addr_t cast in the original
> ARM definition is important when LPAE is enabled as phys_addr_t is 64
> bits while longs are 32 bits.

Dan sent my fix above to Linus already, which is in mainline as commit
ae4f97696889.

Cheers,

Tyler

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
