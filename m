Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE5FA6B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 23:49:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f67so31281107qkc.14
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 20:49:25 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id j8si2385893qtb.37.2017.07.21.20.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 20:49:24 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id d145so3136918qkc.0
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 20:49:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170721161322.98c5cd44b5b3612be0f7fe14@linux-foundation.org>
References: <20170626063833.11094-1-oohall@gmail.com> <20170721161322.98c5cd44b5b3612be0f7fe14@linux-foundation.org>
From: Oliver <oohall@gmail.com>
Date: Sat, 22 Jul 2017 13:49:23 +1000
Message-ID: <CAOSf1CG+jc=Z64_5G4FyvhO5a9rfeOjdQXKNzgZFsKYVxramqg@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: Make __gup_device_* require THP
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Sat, Jul 22, 2017 at 9:13 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 26 Jun 2017 16:38:33 +1000 "Oliver O'Halloran" <oohall@gmail.com> wrote:
>
>> These functions are the only bits of generic code that use
>> {pud,pmd}_pfn() without checking for CONFIG_TRANSPARENT_HUGEPAGE.
>> This works fine on x86, the only arch with devmap support, since the
>> *_pfn() functions are always defined there, but this isn't true for
>> every architecture.
>>
>> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
>> ---
>>  mm/gup.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/gup.c b/mm/gup.c
>> index d9e6fddcc51f..04cf79291321 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -1287,7 +1287,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>>  }
>>  #endif /* __HAVE_ARCH_PTE_SPECIAL */
>>
>> -#ifdef __HAVE_ARCH_PTE_DEVMAP
>> +#if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
>>  static int __gup_device_huge(unsigned long pfn, unsigned long addr,
>>               unsigned long end, struct page **pages, int *nr)
>>  {
>
> (cc Kirill)
>
> Please provide a full description of the bug which is being fixed.  I
> assume it's a build error.  What are the error messages and under what
> circumstances.
>
> Etcetera.  Enough info for me (and others) to decide which kernel
> version(s) need the fix.

It fixes a build breakage that you will only ever see when enabling
the devmap pte bit for another architecture. Given it requires new
code to hit the bug I don't see much point in backporting it to 4.12,
but taking it as a fix for 4.13 wouldn't hurt.

The root problem is that the arch doesn't need to provide pmd_pfn()
and friends when THP is disabled. They're provided unconditionally by
x86 and ppc, but I did a cursory check and found that mips only
defines pmd_pfn() when THP is enabled so I figured this should be
fixed. Making each arch provide them unconditionally might be a better
idea, but that seemed like it'd be a lot of churn for a minor bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
