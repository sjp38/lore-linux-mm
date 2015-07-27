Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2109003C7
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 13:53:33 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so55547122pdb.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 10:53:33 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id y5si45738558pas.76.2015.07.27.10.53.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 10:53:32 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS500K2HR149N50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jul 2015 18:53:28 +0100 (BST)
Message-id: <55B67016.6090402@samsung.com>
Date: Mon, 27 Jul 2015 20:53:26 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v4 5/7] arm64: add KASAN support
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
 <1437756119-12817-6-git-send-email-a.ryabinin@samsung.com>
 <20150727155922.GB350@e104818-lin.cambridge.arm.com>
In-reply-to: <20150727155922.GB350@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On 07/27/2015 06:59 PM, Catalin Marinas wrote:
> On Fri, Jul 24, 2015 at 07:41:57PM +0300, Andrey Ryabinin wrote:
>> diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
>> index 4d2a925..2cacf55 100644
>> --- a/arch/arm64/Makefile
>> +++ b/arch/arm64/Makefile
>> @@ -40,6 +40,12 @@ else
>>  TEXT_OFFSET := 0x00080000
>>  endif
>>  
>> +# KASAN_SHADOW_OFFSET = VA_START + (1 << (VA_BITS - 3)) - (1 << 61)
>> +KASAN_SHADOW_OFFSET := $(shell printf "0x%x\n" $$(( \
>> +			(-1 << $(CONFIG_ARM64_VA_BITS)) \
>> +			+ (1 << ($(CONFIG_ARM64_VA_BITS) - 3)) \
>> +			- (1 << (64 - 3)) )) )
> 
> Does this work with any POSIX shell? Do we always have a 64-bit type?
> As I wasn't sure about this, I suggested awk (or perl).
>

Ok, It will be safer to use 32-bit arithmetic.
I've checked this on 32-bit bash, however this doesn't guarantee that it works with
any other version of bash or another shell.

>> +static void __init clear_pgds(unsigned long start,
>> +			unsigned long end)
>> +{
>> +	/*
>> +	 * Remove references to kasan page tables from
>> +	 * swapper_pg_dir. pgd_clear() can't be used
>> +	 * here because it's nop on 2,3-level pagetable setups
>> +	 */
>> +	for (; start && start < end; start += PGDIR_SIZE)
>> +		set_pgd(pgd_offset_k(start), __pgd(0));
>> +}
> 
> I don't think we need the "start" check, just "start < end". Do you
> expect a start == 0 (or overflow)?

Right, we don't need this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
