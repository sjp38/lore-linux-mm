Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4796B003A
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 18:41:55 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so7884683pad.23
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 15:41:55 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id sm7si7120372pab.8.2014.08.08.15.41.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Aug 2014 15:41:54 -0700 (PDT)
Message-ID: <53E5522F.10603@codeaurora.org>
Date: Fri, 08 Aug 2014 15:41:51 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv6 1/5] lib/genalloc.c: Add power aligned algorithm
References: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org> <20140808153635.36f27a4fbfbd8f715e51d15e@linux-foundation.org>
In-Reply-To: <20140808153635.36f27a4fbfbd8f715e51d15e@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On 8/8/2014 3:36 PM, Andrew Morton wrote:
> On Fri,  8 Aug 2014 13:23:13 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:
> 
>>
>> One of the more common algorithms used for allocation
>> is to align the start address of the allocation to
>> the order of size requested. Add this as an algorithm
>> option for genalloc.
>>
>> --- a/lib/genalloc.c
>> +++ b/lib/genalloc.c
>> @@ -481,6 +481,27 @@ unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
>>  EXPORT_SYMBOL(gen_pool_first_fit);
>>  
>>  /**
>> + * gen_pool_first_fit_order_align - find the first available region
>> + * of memory matching the size requirement. The region will be aligned
>> + * to the order of the size specified.
>> + * @map: The address to base the search on
>> + * @size: The bitmap size in bits
>> + * @start: The bitnumber to start searching at
>> + * @nr: The number of zeroed bits we're looking for
>> + * @data: additional data - unused
> 
> `data' is used.
> 
>> + */
>> +unsigned long gen_pool_first_fit_order_align(unsigned long *map,
>> +		unsigned long size, unsigned long start,
>> +		unsigned int nr, void *data)
>> +{
>> +	unsigned long order = (unsigned long) data;
> 
> Why pass a void*?  Why not pass "unsigned order;"?
> 
>> +	unsigned long align_mask = (1 << get_order(nr << order)) - 1;
>> +
>> +	return bitmap_find_next_zero_area(map, size, start, nr, align_mask);
>> +}
>> +EXPORT_SYMBOL(gen_pool_first_fit_order_align);
>> +
>> +/**
>>   * gen_pool_best_fit - find the best fitting region of memory
>>   * macthing the size requirement (no alignment constraint)
>>   * @map: The address to base the search on
> 

Ugh, I sent out the wrong version of this one which updated the function to
not need the parameter. I'll update with the correct version in v7.

Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
