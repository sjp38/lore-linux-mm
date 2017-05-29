Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C531D6B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 08:44:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p74so63673713pfd.11
        for <linux-mm@kvack.org>; Mon, 29 May 2017 05:44:58 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30131.outbound.protection.outlook.com. [40.107.3.131])
        by mx.google.com with ESMTPS id 12si10272073pfn.27.2017.05.29.05.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 May 2017 05:44:58 -0700 (PDT)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <20170525203334.867-8-kirill.shutemov@linux.intel.com>
 <20170526221059.o4kyt3ijdweurz6j@node.shutemov.name>
 <CACT4Y+YyFWg3fbj4ta3tSKoeBaw7hbL2YoBatAFiFB1_cMg9=Q@mail.gmail.com>
 <71e11033-f95c-887f-4e4e-351bcc3df71e@virtuozzo.com>
 <CACT4Y+bSTOeJtDDZVmkff=qqJFesA_b6uTG__EAn4AvDLw0jzQ@mail.gmail.com>
 <c4f11000-6138-c6ab-d075-2c4bd6a14943@virtuozzo.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
Date: Mon, 29 May 2017 15:46:47 +0300
MIME-Version: 1.0
In-Reply-To: <c4f11000-6138-c6ab-d075-2c4bd6a14943@virtuozzo.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On 05/29/2017 02:45 PM, Andrey Ryabinin wrote:
>>>>> Looks like KASAN will be a problem for boot-time paging mode switching.
>>>>> It wants to know CONFIG_KASAN_SHADOW_OFFSET at compile-time to pass to
>>>>> gcc -fasan-shadow-offset=. But this value varies between paging modes...
>>>>>
>>>>> I don't see how to solve it. Folks, any ideas?
>>>>
>>>> +kasan-dev
>>>>
>>>> I wonder if we can use the same offset for both modes. If we use
>>>> 0xFFDFFC0000000000 as start of shadow for 5 levels, then the same
>>>> offset that we use for 4 levels (0xdffffc0000000000) will also work
>>>> for 5 levels. Namely, ending of 5 level shadow will overlap with 4
>>>> level mapping (both end at 0xfffffbffffffffff), but 5 level mapping
>>>> extends towards lower addresses. The current 5 level start of shadow
>>>> is actually close -- 0xffd8000000000000 and it seems that the required
>>>> space after it is unused at the moment (at least looking at mm.txt).
>>>> So just try to move it to 0xFFDFFC0000000000?
>>>>
>>>
>>> Yeah, this should work, but note that 0xFFDFFC0000000000 is not PGDIR aligned address. Our init code
>>> assumes that kasan shadow stars and ends on the PGDIR aligned address.
>>> Fortunately this is fixable, we'd need two more pages for page tables to map unaligned start/end
>>> of the shadow.
>>
>> I think we can extend the shadow backwards (to the current address),
>> provided that it does not affect shadow offset that we pass to
>> compiler.
> 
> I thought about this. We can round down shadow start to 0xffdf000000000000, but we can't
> round up shadow end, because in that case shadow would end at 0xffffffffffffffff.
> So we still need at least one more page to cover unaligned end.

Actually, I'm wrong here. I assumed that we would need an additional page to store p4d entries,
but in fact we don't need it, as such page should already exist. It's the same last pgd where kernel image
is mapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
