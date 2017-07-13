Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53D06440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 00:01:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w15so72139wra.9
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 21:01:54 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id 54si3316620wru.27.2017.07.12.21.01.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 21:01:52 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id u23so2515881wma.2
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 21:01:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jpBRF=pC6fuHeWC0mVKBbvkPRRGGTdB0H=qmoveBTLbQ@mail.gmail.com>
References: <1499842660-10665-1-git-send-email-geert@linux-m68k.org> <CAPcyv4jpBRF=pC6fuHeWC0mVKBbvkPRRGGTdB0H=qmoveBTLbQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jul 2017 21:01:51 -0700
Message-ID: <CAA9_cmctDq1x5k=eL8Mki61esecMLVnOORXQG5bDeJEoKeWKtg@mail.gmail.com>
Subject: Re: [PATCH] mm: Mark create_huge_pmd() inline to prevent build failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 12, 2017 at 5:29 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Tue, Jul 11, 2017 at 11:57 PM, Geert Uytterhoeven
> <geert@linux-m68k.org> wrote:
>> With gcc 4.1.2:
>>
>>     mm/memory.o: In function `create_huge_pmd':
>>     memory.c:(.text+0x93e): undefined reference to `do_huge_pmd_anonymous_page'
>>
>> Converting transparent_hugepage_enabled() from a macro to a static
>> inline function reduced the ability of the compiler to remove unused
>> code.
>>
>> Fix this by marking create_huge_pmd() inline.
>>
>> Fixes: 16981d763501c0e0 ("mm: improve readability of transparent_hugepage_enabled()")
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> ---
>> Interestingly, create_huge_pmd() is emitted in the assembler output, but
>> never called.
>> ---
>>  mm/memory.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index cbb57194687e393a..0e517be91a89e162 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3591,7 +3591,7 @@ static int do_numa_page(struct vm_fault *vmf)
>>         return 0;
>>  }
>>
>> -static int create_huge_pmd(struct vm_fault *vmf)
>> +static inline int create_huge_pmd(struct vm_fault *vmf)
>>  {
>
> This seems fragile, what if the kernel decides

...of course I meant *compiler* instead of 'kernel' here

>  to ignore the inline
> hint? If it must be inlined to avoid compile errors then it should be
> __always_inline, right?
>
> I also wonder if it's enough to just specify __always_inline to
> transparent_hugepage_enabled(), i.e. in case the compiler is making an
> uninlined copy of transparent_hugepage_enabled() in mm/memory.c.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
