Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0E86B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 22:08:33 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 81so55426394iog.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 19:08:33 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id p187si7300351itd.7.2016.12.14.19.08.31
        for <linux-mm@kvack.org>;
        Wed, 14 Dec 2016 19:08:32 -0800 (PST)
Subject: Re: [PATCH] arm64: mm: Fix NOMAP page initialization
References: <1481307042-29773-1-git-send-email-rrichter@cavium.com>
 <83d6e6d0-cfb3-ec8b-241b-ec6a50dc2aa9@huawei.com>
 <9168b603-04aa-4302-3197-00f17fb336bd@huawei.com>
 <20161214094542.GE5588@rric.localdomain>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <4bc9df75-1b67-2428-184e-ce52b5f95528@huawei.com>
Date: Thu, 15 Dec 2016 11:01:04 +0800
MIME-Version: 1.0
In-Reply-To: <20161214094542.GE5588@rric.localdomain>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <robert.richter@cavium.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, David Daney <david.daney@cavium.com>, Mark
 Rutland <mark.rutland@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, James
 Morse <james.morse@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>

hi Robert,

On 2016/12/14 17:45, Robert Richter wrote:
> On 12.12.16 17:53:02, Yisheng Xie wrote:
>> It seems that memblock_is_memory() is also too strict for early_pfn_valid,
>> so what about this patch, which use common pfn_valid as early_pfn_valid
>> when CONFIG_HAVE_ARCH_PFN_VALID=y:
>> ------------
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 0f088f3..9d596f3 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -1200,7 +1200,17 @@ static inline int pfn_present(unsigned long pfn)
>>  #define pfn_to_nid(pfn)                (0)
>>  #endif
>>
>> +#ifdef CONFIG_HAVE_ARCH_PFN_VALID
>> +static inline int early_pfn_valid(unsigned long pfn)
>> +{
>> +       if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
>> +               return 0;
>> +       return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
>> +}
> 
> I sent a V2 patch that uses pfn_present(). This only initilizes
> sections with memory.
hmmi 1/4 ? maybe I do not quite catch what your mean, but I do not think
pfn_present is right for this case.

IMO, The valid_section() means the section with mem_map, not section with memory.

And:
    pfn_present
        -> present_section
which means the section is present but may not have mem_map, so it may not
have page struct at all for that section.

Please let me know, if I miss anything.

Thanks,
Yisheng Xie.


> 
> -Robert
> 
>> +#define early_pfn_valid early_pfn_valid
>> +#else
>>  #define early_pfn_valid(pfn)   pfn_valid(pfn)
>> +#endif
>>  void sparse_init(void);
>>  #else
>>  #define sparse_init()  do {} while (0)
>>
>>
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
