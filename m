Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 562956B02EE
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 14:09:48 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h18so11253303ita.9
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:09:48 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id q199si166665itb.41.2017.04.27.11.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 11:09:47 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id 70so3095419ita.2
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:09:47 -0700 (PDT)
Subject: Re: [PATCH v2 3/3] arm64: Silence first allocation with
 CONFIG_ARM64_MODULE_PLTS=y
References: <20170427173900.2538-1-f.fainelli@gmail.com>
 <20170427173900.2538-4-f.fainelli@gmail.com>
 <C103C078-3462-43D9-AEF5-5DEC3A74CA7E@linaro.org>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <53d960d0-e44c-3a8d-17fd-a3895ecee858@gmail.com>
Date: Thu, 27 Apr 2017 11:09:45 -0700
MIME-Version: 1.0
In-Reply-To: <C103C078-3462-43D9-AEF5-5DEC3A74CA7E@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On 04/27/2017 11:07 AM, Ard Biesheuvel wrote:
> 
>> On 27 Apr 2017, at 18:39, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>
>> When CONFIG_ARM64_MODULE_PLTS is enabled, the first allocation using the
>> module space fails, because the module is too big, and then the module
>> allocation is attempted from vmalloc space. Silence the first allocation
>> failure in that case by setting __GFP_NOWARN.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> arch/arm64/kernel/module.c | 7 ++++++-
>> 1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/arm64/kernel/module.c b/arch/arm64/kernel/module.c
>> index 7f316982ce00..58bd5cfdd544 100644
>> --- a/arch/arm64/kernel/module.c
>> +++ b/arch/arm64/kernel/module.c
>> @@ -32,11 +32,16 @@
>>
>> void *module_alloc(unsigned long size)
>> {
>> +    gfp_t gfp_mask = GFP_KERNEL;
>>    void *p;
>>
>> +#if IS_ENABLED(CONFIG_ARM64_MODULE_PLTS)
>> +    /* Silence the initial allocation */
>> +    gfp_mask |= __GFP_NOWARN;
>> +#endif
> 
> Please use IS_ENABLED() instead here

How do you mean?

if (IS_ENABLED()) vs. #if IS_ENABLED()?

> 
>>    p = __vmalloc_node_range(size, MODULE_ALIGN, module_alloc_base,
>>                module_alloc_base + MODULES_VSIZE,
>> -                GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
>> +                gfp_mask, PAGE_KERNEL_EXEC, 0,
>>                NUMA_NO_NODE, __builtin_return_address(0));
>>
>>    if (!p && IS_ENABLED(CONFIG_ARM64_MODULE_PLTS) &&
>> -- 
>> 2.9.3
>>
> 
> Other than that, and with Michal's nit addressed:
> 
> Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> 


-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
