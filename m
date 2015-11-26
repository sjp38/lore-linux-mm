Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id D86EC6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 11:40:41 -0500 (EST)
Received: by lfs39 with SMTP id 39so100732307lfs.3
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 08:40:41 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 196si19214936lfa.27.2015.11.26.08.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 08:40:40 -0800 (PST)
Subject: Re: [PATCH RFT] arm64: kasan: Make KASAN work with 16K pages + 48 bit
 VA
References: <1448543686-31869-1-git-send-email-aryabinin@virtuozzo.com>
 <20151126144859.GE32343@leverpostej> <56572998.9070102@virtuozzo.com>
 <20151126162117.GH32343@leverpostej>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <56573615.8030604@virtuozzo.com>
Date: Thu, 26 Nov 2015 19:40:53 +0300
MIME-Version: 1.0
In-Reply-To: <20151126162117.GH32343@leverpostej>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>

On 11/26/2015 07:21 PM, Mark Rutland wrote:
> On Thu, Nov 26, 2015 at 06:47:36PM +0300, Andrey Ryabinin wrote:
>>
>>
>> On 11/26/2015 05:48 PM, Mark Rutland wrote:
>>> Hi,
>>>
>>> On Thu, Nov 26, 2015 at 04:14:46PM +0300, Andrey Ryabinin wrote:
>>>> Currently kasan assumes that shadow memory covers one or more entire PGDs.
>>>> That's not true for 16K pages + 48bit VA space, where PGDIR_SIZE is bigger
>>>> than the whole shadow memory.
>>>>
>>>> This patch tries to fix that case.
>>>> clear_page_tables() is a new replacement of clear_pgs(). Instead of always
>>>> clearing pgds it clears top level page table entries that entirely belongs
>>>> to shadow memory.
>>>> In addition to 'tmp_pg_dir' we now have 'tmp_pud' which is used to store
>>>> puds that now might be cleared by clear_page_tables.
>>>>
>>>> Reported-by: Suzuki K. Poulose <Suzuki.Poulose@arm.com>
>>>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>>> ---
>>>>
>>>>  *** THIS is not tested with 16k pages ***
>>>>
>>>>  arch/arm64/mm/kasan_init.c | 87 ++++++++++++++++++++++++++++++++++++++++------
>>>>  1 file changed, 76 insertions(+), 11 deletions(-)
>>>>
>>>> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
>>>> index cf038c7..ea9f92a 100644
>>>> --- a/arch/arm64/mm/kasan_init.c
>>>> +++ b/arch/arm64/mm/kasan_init.c
>>>> @@ -22,6 +22,7 @@
>>>>  #include <asm/tlbflush.h>
>>>>  
>>>>  static pgd_t tmp_pg_dir[PTRS_PER_PGD] __initdata __aligned(PGD_SIZE);
>>>> +static pud_t tmp_pud[PAGE_SIZE/sizeof(pud_t)] __initdata __aligned(PAGE_SIZE);
>>>>  
>>>>  static void __init kasan_early_pte_populate(pmd_t *pmd, unsigned long addr,
>>>>  					unsigned long end)
>>>> @@ -92,20 +93,84 @@ asmlinkage void __init kasan_early_init(void)
>>>>  {
>>>>  	BUILD_BUG_ON(KASAN_SHADOW_OFFSET != KASAN_SHADOW_END - (1UL << 61));
>>>>  	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_START, PGDIR_SIZE));
>>>> -	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
>>>> +	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PUD_SIZE));
>>>
>>> We also assume that even in the shared PUD case, the shadow region falls
>>> within the same PGD entry, or we would need more than a single tmp_pud.
>>>
>>> It would be good to test for that.
>>>
>>
>> Something like this:
>>
>> 	#define KASAN_SHADOW_SIZE (KASAN_SHADOW_END - KASAN_SHADOW_START)
>>
>> 	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGD_SIZE)
>> 			 && !((PGDIR_SIZE > KASAN_SHADOW_SIZE)
>> 				 && IS_ALIGNED(KASAN_SHADOW_END, PUD_SIZE)));
> 
> I was thinking something more like:
> 
> 	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PUD_SIZE);
> 	BUILD_BUG_ON(KASAN_SHADOW_START >> PGDIR_SHIFT !=
> 		     KASAN_SHADOW_END >> PGDIR_SHIFT);
> 
>>>> +		if (!pud_none(*pud))
>>>> +			clear_pmds(pud, addr, next);
>>>
>>> I don't understand this. The KASAN shadow region is PUD_SIZE aligned at
>>> either end, so KASAN should never own a partial pud entry like this.
>>>
>>> Regardless, were this case to occur, surely we'd be clearing pmd entries
>>> in the active page tables? We didn't copy anything at the pmd level.
>>>
>>> That doesn't seem right.
>>>
>>
>> Just take a look at p?d_clear() macroses, under CONFIG_PGTABLE_LEVELS=2 for example.
>> pgd_clear() and pud_clear() is nops, and pmd_clear() is actually clears pgd.
> 
> I see. Thanks for pointing that out.
> 
> I detest the weird folding behaviour we have in the p??_* macros. It
> violates least surprise almost every time.
> 
>> I could replace p?d_clear() with set_p?d(p?d, __p?d(0)).
>> In that case going down to pmds is not needed, set_p?d() macro will do it for us.
> 
> I think it would be simpler to rely on the fact that we only use puds
> with 4 levels of table (and hence the p??_* macros will operate at the
> levels their names imply).
> 

It's not only about puds.
E.g. if we need to clear PGD with 2-level page tables, than we need to call pmd_clear().

So we should either leave this code as is, or switch to set_pgd/set_pud.


> We can verify that at build time with:
> 
> BUILD_BUG_ON(CONFIG_PGTABLE_LEVELS != 4 &&
> 	     (!IS_ALIGNED(KASAN_SHADOW_START, PGDIR_SIZE) ||
> 	      !IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE)));
> 
>>>> +static void copy_pagetables(void)
>>>> +{
>>>> +	pgd_t *pgd = tmp_pg_dir + pgd_index(KASAN_SHADOW_START);
>>>> +
>>>> +	memcpy(tmp_pg_dir, swapper_pg_dir, sizeof(tmp_pg_dir));
>>>> +
>>>>  	/*
>>>> -	 * Remove references to kasan page tables from
>>>> -	 * swapper_pg_dir. pgd_clear() can't be used
>>>> -	 * here because it's nop on 2,3-level pagetable setups
>>>> +	 * If kasan shadow shares PGD with other mappings,
>>>> +	 * clear_page_tables() will clear puds instead of pgd,
>>>> +	 * so we need temporary pud table to keep early shadow mapped.
>>>>  	 */
>>>> -	for (; start < end; start += PGDIR_SIZE)
>>>> -		set_pgd(pgd_offset_k(start), __pgd(0));
>>>> +	if (PGDIR_SIZE > KASAN_SHADOW_END - KASAN_SHADOW_START) {
>>>> +		pud_t *pud;
>>>> +		pmd_t *pmd;
>>>> +		pte_t *pte;
>>>> +
>>>> +		memcpy(tmp_pud, pgd_page_vaddr(*pgd), sizeof(tmp_pud));
>>>> +
>>>> +		pgd_populate(&init_mm, pgd, tmp_pud);
>>>> +		pud = pud_offset(pgd, KASAN_SHADOW_START);
>>>> +		pmd = pmd_offset(pud, KASAN_SHADOW_START);
>>>> +		pud_populate(&init_mm, pud, pmd);
>>>> +		pte = pte_offset_kernel(pmd, KASAN_SHADOW_START);
>>>> +		pmd_populate_kernel(&init_mm, pmd, pte);
>>>
>>> I don't understand why we need to do anything below the pud level here.
>>> We only copy down to the pud level, and we already initialised the
>>> shared ptes and pmds earlier.
>>>
>>> Regardless of this patch, we currently initialise the shared tables
>>> repeatedly, which is redundant after the first time we initialise them.
>>> We could improve that.
>>>
>>
>> Sure, just pgd_populate() will work here, because this code is only for 16K+48-bit,
>> which has 4-level pagetables.
>> But it wouldn't work if 16k+48-bit would have > 4-level.
>> Because pgd_populate() in nop in such case, so we need to go down to actually set 'tmp_pud'
> 
> I don't follow.
> 
> 16K + 48-bit will always require 4 levels given the page table format.
> We never have more than 4 levels.
> 

Oh, it should be '< 4' of course.
Yes, 16K + 48-bit is always 4-levels, but I tried to not rely on this here.

But since we can rely on 4-levels here, I'm gonna leave only pgd_populate() and add you BUILD_BUG_ON().


> Thanks,
> Mark.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
