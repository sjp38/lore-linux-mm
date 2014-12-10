Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C79526B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:44:46 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so1732131pad.38
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:44:46 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id jf9si4349693pbd.143.2014.12.09.17.44.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:44:45 -0800 (PST)
Message-ID: <5487A471.30005@huawei.com>
Date: Wed, 10 Dec 2014 09:40:01 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] x86/mm: Fix zone ranges boot printout
References: <54866C18.1050203@huawei.com> <20141209145038.6253a2b99379bfb1255fa95e@linux-foundation.org>
In-Reply-To: <20141209145038.6253a2b99379bfb1255fa95e@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, dave@sr71.net, Rik van Riel <riel@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2014/12/10 6:50, Andrew Morton wrote:

> On Tue, 9 Dec 2014 11:27:20 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> Changelog:
>> V2:
>> 	-fix building warnings of min(...).
>>
>> ...
>>
>> --- a/arch/x86/mm/init.c
>> +++ b/arch/x86/mm/init.c
>> @@ -674,10 +674,12 @@ void __init zone_sizes_init(void)
>>  	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
>>  
>>  #ifdef CONFIG_ZONE_DMA
>> -	max_zone_pfns[ZONE_DMA]		= MAX_DMA_PFN;
>> +	max_zone_pfns[ZONE_DMA]		= min_t(unsigned long,
>> +						max_low_pfn, MAX_DMA_PFN);
> 
> MAX_DMA_PFN has type int.
> 
>>  #endif
>>  #ifdef CONFIG_ZONE_DMA32
>> -	max_zone_pfns[ZONE_DMA32]	= MAX_DMA32_PFN;
>> +	max_zone_pfns[ZONE_DMA32]	= min_t(unsigned long,
>> +						max_low_pfn, MAX_DMA32_PFN);
> 
> MAX_DMA32_PFN has type UL (I think?) so there's no need for min_t here.
> 
>>  #endif
>>  	max_zone_pfns[ZONE_NORMAL]	= max_low_pfn;
>>  #ifdef CONFIG_HIGHMEM
> 
> 
> Let's try to get the types correct, rather than hacking around fixing
> up fallout from earlier incorrect type choices?
> 
> What is the type of a pfn?  Unsigned long, generally, when we bother
> thinking about it.
> 
> So how about we make MAX_DMA_PFN have type UL?  I assume that fixes the
> warning?
> 
> If we do this, we should also be able to undo the min_t hackery in
> arch/x86/kernel/e820.c:memblock_find_dma_reserve().
> 

Hi Andrew,

Thanks for your suggestion, I'll resend V3.

Thanks,
Xishi Qiu

> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
