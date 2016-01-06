Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 577BF828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 15:18:04 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id 1so182945191ion.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 12:18:04 -0800 (PST)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id c18si15454999igr.94.2016.01.06.12.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 12:18:03 -0800 (PST)
Received: by mail-io0-x22c.google.com with SMTP id g73so31230211ioe.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 12:18:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGxmjF-_ZZFwtaxZsXN9g7J2sn6O0L+pBiPdARsKC_644g@mail.gmail.com>
References: <1452095687-18136-1-git-send-email-ard.biesheuvel@linaro.org>
	<CAPAsAGxmjF-_ZZFwtaxZsXN9g7J2sn6O0L+pBiPdARsKC_644g@mail.gmail.com>
Date: Wed, 6 Jan 2016 21:18:03 +0100
Message-ID: <CAKv+Gu9b_2WWYhgQmdnAUk0G0W3dwWXdWmpEmMtKW+=-KaJYgw@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan: map KASAN zero page read only
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, mingo <mingo@kernel.org>

On 6 January 2016 at 20:48, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> 2016-01-06 18:54 GMT+03:00 Ard Biesheuvel <ard.biesheuvel@linaro.org>:
>> The original x86_64-only version of KASAN mapped its zero page
>> read-only, but this got lost when the code was generalised and
>> ported to arm64, since, at the time, the PAGE_KERNEL_RO define
>> did not exist. It has been added to arm64 in the mean time, so
>> let's use it.
>>
>
> Read-only wasn't lost. Just look at the next line:
>      zero_pte = pte_wrprotect(zero_pte);
>
> PAGE_KERNEL_RO is not available on all architectures, thus it would be better
> to not use it in generic code.
>

OK, I didn't see that. For some reason, it is not working for me on
arm64, though.
I will investigate.

-- 
Ard.


>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> ---
>>  mm/kasan/kasan_init.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
>> index 3f9a41cf0ac6..8726a92604ad 100644
>> --- a/mm/kasan/kasan_init.c
>> +++ b/mm/kasan/kasan_init.c
>> @@ -49,7 +49,7 @@ static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
>>         pte_t *pte = pte_offset_kernel(pmd, addr);
>>         pte_t zero_pte;
>>
>> -       zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
>> +       zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL_RO);
>>         zero_pte = pte_wrprotect(zero_pte);
>>
>>         while (addr + PAGE_SIZE <= end) {
>> --
>> 2.5.0
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
