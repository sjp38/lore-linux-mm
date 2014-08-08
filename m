Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 45AAF6B0036
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 19:26:02 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so7650570pdj.26
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 16:26:01 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id gp1si7134524pbd.145.2014.08.08.16.26.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Aug 2014 16:26:01 -0700 (PDT)
Message-ID: <53E55C86.3040705@codeaurora.org>
Date: Fri, 08 Aug 2014 16:25:58 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv6 3/5] common: dma-mapping: Introduce common remapping
 functions
References: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org> <1407529397-6642-3-git-send-email-lauraa@codeaurora.org> <20140808154556.11c7bf68d1bcf2714c148e3b@linux-foundation.org>
In-Reply-To: <20140808154556.11c7bf68d1bcf2714c148e3b@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Riley <davidriley@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thierry Reding <thierry.reding@gmail.com>, Ritesh Harjain <ritesh.harjani@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

On 8/8/2014 3:45 PM, Andrew Morton wrote:
> On Fri,  8 Aug 2014 13:23:15 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:
> 
>>
>> For architectures without coherent DMA, memory for DMA may
>> need to be remapped with coherent attributes. Factor out
>> the the remapping code from arm and put it in a
>> common location to reduce code duplication.
>>
>> As part of this, the arm APIs are now migrated away from
>> ioremap_page_range to the common APIs which use map_vm_area for remapping.
>> This should be an equivalent change and using map_vm_area is more
>> correct as ioremap_page_range is intended to bring in io addresses
>> into the cpu space and not regular kernel managed memory.
>>
>> ...
>>
>> @@ -267,3 +269,68 @@ int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
>>  	return ret;
>>  }
>>  EXPORT_SYMBOL(dma_common_mmap);
>> +
>> +/*
>> + * remaps an allocated contiguous region into another vm_area.
>> + * Cannot be used in non-sleeping contexts
>> + */
>> +
>> +void *dma_common_contiguous_remap(struct page *page, size_t size,
>> +			unsigned long vm_flags,
>> +			pgprot_t prot, const void *caller)
>> +{
>> +	int i;
>> +	struct page **pages;
>> +	void *ptr;
>> +
>> +	pages = kmalloc(sizeof(struct page *) << get_order(size), GFP_KERNEL);
>> +	if (!pages)
>> +		return NULL;
>> +
>> +	for (i = 0; i < (size >> PAGE_SHIFT); i++)
>> +		pages[i] = page + i;
> 
> Assumes a single mem_map[] array.  That's not the case for sparsemem
> (at least).
> 
> 

Good point. I guess the best option is to increment via pfn and call
pfn_to_page. Either that or go back to slightly abusing
ioremap_page_range to remap normal memory.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
