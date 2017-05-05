Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9157C6B02C4
	for <linux-mm@kvack.org>; Fri,  5 May 2017 17:07:33 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c28so6314259qta.8
        for <linux-mm@kvack.org>; Fri, 05 May 2017 14:07:33 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id n124si5568960qkd.170.2017.05.05.14.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 14:07:32 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id l39so2421787qtb.1
        for <linux-mm@kvack.org>; Fri, 05 May 2017 14:07:32 -0700 (PDT)
Subject: Re: [PATCH v3 3/3] arm64: Silence first allocation with
 CONFIG_ARM64_MODULE_PLTS=y
References: <20170427181902.28829-1-f.fainelli@gmail.com>
 <20170427181902.28829-4-f.fainelli@gmail.com> <20170503111814.GF8233@arm.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <3af577ca-8f01-7a1c-997c-4c04914b4633@gmail.com>
Date: Fri, 5 May 2017 14:07:28 -0700
MIME-Version: 1.0
In-Reply-To: <20170503111814.GF8233@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On 05/03/2017 04:18 AM, Will Deacon wrote:
> On Thu, Apr 27, 2017 at 11:19:02AM -0700, Florian Fainelli wrote:
>> When CONFIG_ARM64_MODULE_PLTS is enabled, the first allocation using the
>> module space fails, because the module is too big, and then the module
>> allocation is attempted from vmalloc space. Silence the first allocation
>> failure in that case by setting __GFP_NOWARN.
>>
>> Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  arch/arm64/kernel/module.c | 7 ++++++-
>>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> I'm not sure what the merge plan is for these, but the arm64 bit here
> looks fine to me:
> 
> Acked-by: Will Deacon <will.deacon@arm.com>

Thanks, not sure either, would you or Catalin want to pick this series?

> 
> Will
> 
>> diff --git a/arch/arm64/kernel/module.c b/arch/arm64/kernel/module.c
>> index 7f316982ce00..093c13541efb 100644
>> --- a/arch/arm64/kernel/module.c
>> +++ b/arch/arm64/kernel/module.c
>> @@ -32,11 +32,16 @@
>>  
>>  void *module_alloc(unsigned long size)
>>  {
>> +	gfp_t gfp_mask = GFP_KERNEL;
>>  	void *p;
>>  
>> +	/* Silence the initial allocation */
>> +	if (IS_ENABLED(CONFIG_ARM64_MODULE_PLTS))
>> +		gfp_mask |= __GFP_NOWARN;
>> +
>>  	p = __vmalloc_node_range(size, MODULE_ALIGN, module_alloc_base,
>>  				module_alloc_base + MODULES_VSIZE,
>> -				GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
>> +				gfp_mask, PAGE_KERNEL_EXEC, 0,
>>  				NUMA_NO_NODE, __builtin_return_address(0));
>>  
>>  	if (!p && IS_ENABLED(CONFIG_ARM64_MODULE_PLTS) &&
>> -- 
>> 2.9.3
>>


-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
