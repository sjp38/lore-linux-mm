Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9D926B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 07:44:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h76so62734605pfh.15
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:44:00 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0116.outbound.protection.outlook.com. [104.47.0.116])
        by mx.google.com with ESMTPS id g29si10236657pfa.26.2017.05.29.04.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 May 2017 04:44:00 -0700 (PDT)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <20170525203334.867-8-kirill.shutemov@linux.intel.com>
 <20170526221059.o4kyt3ijdweurz6j@node.shutemov.name>
 <CACT4Y+YyFWg3fbj4ta3tSKoeBaw7hbL2YoBatAFiFB1_cMg9=Q@mail.gmail.com>
 <71e11033-f95c-887f-4e4e-351bcc3df71e@virtuozzo.com>
 <CACT4Y+bSTOeJtDDZVmkff=qqJFesA_b6uTG__EAn4AvDLw0jzQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c4f11000-6138-c6ab-d075-2c4bd6a14943@virtuozzo.com>
Date: Mon, 29 May 2017 14:45:51 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bSTOeJtDDZVmkff=qqJFesA_b6uTG__EAn4AvDLw0jzQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>



On 05/29/2017 02:19 PM, Dmitry Vyukov wrote:
> On Mon, May 29, 2017 at 1:18 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 05/29/2017 01:02 PM, Dmitry Vyukov wrote:
>>> On Sat, May 27, 2017 at 12:10 AM, Kirill A. Shutemov
>>> <kirill@shutemov.name> wrote:
>>>> On Thu, May 25, 2017 at 11:33:33PM +0300, Kirill A. Shutemov wrote:
>>>>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>>>>> index 0bf81e837cbf..c795207d8a3c 100644
>>>>> --- a/arch/x86/Kconfig
>>>>> +++ b/arch/x86/Kconfig
>>>>> @@ -100,7 +100,7 @@ config X86
>>>>>       select HAVE_ARCH_AUDITSYSCALL
>>>>>       select HAVE_ARCH_HUGE_VMAP              if X86_64 || X86_PAE
>>>>>       select HAVE_ARCH_JUMP_LABEL
>>>>> -     select HAVE_ARCH_KASAN                  if X86_64 && SPARSEMEM_VMEMMAP
>>>>> +     select HAVE_ARCH_KASAN                  if X86_64 && SPARSEMEM_VMEMMAP && !X86_5LEVEL
>>>>>       select HAVE_ARCH_KGDB
>>>>>       select HAVE_ARCH_KMEMCHECK
>>>>>       select HAVE_ARCH_MMAP_RND_BITS          if MMU
>>>>
>>>> Looks like KASAN will be a problem for boot-time paging mode switching.
>>>> It wants to know CONFIG_KASAN_SHADOW_OFFSET at compile-time to pass to
>>>> gcc -fasan-shadow-offset=. But this value varies between paging modes...
>>>>
>>>> I don't see how to solve it. Folks, any ideas?
>>>
>>> +kasan-dev
>>>
>>> I wonder if we can use the same offset for both modes. If we use
>>> 0xFFDFFC0000000000 as start of shadow for 5 levels, then the same
>>> offset that we use for 4 levels (0xdffffc0000000000) will also work
>>> for 5 levels. Namely, ending of 5 level shadow will overlap with 4
>>> level mapping (both end at 0xfffffbffffffffff), but 5 level mapping
>>> extends towards lower addresses. The current 5 level start of shadow
>>> is actually close -- 0xffd8000000000000 and it seems that the required
>>> space after it is unused at the moment (at least looking at mm.txt).
>>> So just try to move it to 0xFFDFFC0000000000?
>>>
>>
>> Yeah, this should work, but note that 0xFFDFFC0000000000 is not PGDIR aligned address. Our init code
>> assumes that kasan shadow stars and ends on the PGDIR aligned address.
>> Fortunately this is fixable, we'd need two more pages for page tables to map unaligned start/end
>> of the shadow.
> 
> I think we can extend the shadow backwards (to the current address),
> provided that it does not affect shadow offset that we pass to
> compiler.

I thought about this. We can round down shadow start to 0xffdf000000000000, but we can't
round up shadow end, because in that case shadow would end at 0xffffffffffffffff.
So we still need at least one more page to cover unaligned end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
