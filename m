Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B82A56B0311
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:56:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j79so116683709pfj.9
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 08:56:41 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id m12si8257229pgt.449.2017.07.10.08.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 08:56:40 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id u62so51550139pgb.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 08:56:40 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20170710141713.7aox3edx6o7lrrie@node.shutemov.name>
Date: Mon, 10 Jul 2017 08:56:37 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <03A6D7ED-300C-4431-9EB5-67C7A3EA4A2E@amacapital.net>
References: <20170525203334.867-8-kirill.shutemov@linux.intel.com> <20170526221059.o4kyt3ijdweurz6j@node.shutemov.name> <CACT4Y+YyFWg3fbj4ta3tSKoeBaw7hbL2YoBatAFiFB1_cMg9=Q@mail.gmail.com> <71e11033-f95c-887f-4e4e-351bcc3df71e@virtuozzo.com> <CACT4Y+bSTOeJtDDZVmkff=qqJFesA_b6uTG__EAn4AvDLw0jzQ@mail.gmail.com> <c4f11000-6138-c6ab-d075-2c4bd6a14943@virtuozzo.com> <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com> <bc95be68-8c68-2a45-c530-acbc6c90a231@virtuozzo.com> <20170710123346.7y3jnftqgpingim3@node.shutemov.name> <CACT4Y+aRbC7_wvDv8ahH_JwY6P6SFoLg-kdwWHJx5j1stX_P_w@mail.gmail.com> <20170710141713.7aox3edx6o7lrrie@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>



> On Jul 10, 2017, at 7:17 AM, Kirill A. Shutemov <kirill@shutemov.name> wro=
te:
>=20
>> On Mon, Jul 10, 2017 at 02:43:17PM +0200, Dmitry Vyukov wrote:
>> On Mon, Jul 10, 2017 at 2:33 PM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>>> On Thu, Jun 01, 2017 at 05:56:30PM +0300, Andrey Ryabinin wrote:
>>>>> On 05/29/2017 03:46 PM, Andrey Ryabinin wrote:
>>>>> On 05/29/2017 02:45 PM, Andrey Ryabinin wrote:
>>>>>>>>>> Looks like KASAN will be a problem for boot-time paging mode swit=
ching.
>>>>>>>>>> It wants to know CONFIG_KASAN_SHADOW_OFFSET at compile-time to pa=
ss to
>>>>>>>>>> gcc -fasan-shadow-offset=3D. But this value varies between paging=
 modes...
>>>>>>>>>>=20
>>>>>>>>>> I don't see how to solve it. Folks, any ideas?
>>>>>>>>>=20
>>>>>>>>> +kasan-dev
>>>>>>>>>=20
>>>>>>>>> I wonder if we can use the same offset for both modes. If we use
>>>>>>>>> 0xFFDFFC0000000000 as start of shadow for 5 levels, then the same
>>>>>>>>> offset that we use for 4 levels (0xdffffc0000000000) will also wor=
k
>>>>>>>>> for 5 levels. Namely, ending of 5 level shadow will overlap with 4=

>>>>>>>>> level mapping (both end at 0xfffffbffffffffff), but 5 level mappin=
g
>>>>>>>>> extends towards lower addresses. The current 5 level start of shad=
ow
>>>>>>>>> is actually close -- 0xffd8000000000000 and it seems that the requ=
ired
>>>>>>>>> space after it is unused at the moment (at least looking at mm.txt=
).
>>>>>>>>> So just try to move it to 0xFFDFFC0000000000?
>>>>>>>>>=20
>>>>>>>>=20
>>>>>>>> Yeah, this should work, but note that 0xFFDFFC0000000000 is not PGD=
IR aligned address. Our init code
>>>>>>>> assumes that kasan shadow stars and ends on the PGDIR aligned addre=
ss.
>>>>>>>> Fortunately this is fixable, we'd need two more pages for page tabl=
es to map unaligned start/end
>>>>>>>> of the shadow.
>>>>>>>=20
>>>>>>> I think we can extend the shadow backwards (to the current address),=

>>>>>>> provided that it does not affect shadow offset that we pass to
>>>>>>> compiler.
>>>>>>=20
>>>>>> I thought about this. We can round down shadow start to 0xffdf0000000=
00000, but we can't
>>>>>> round up shadow end, because in that case shadow would end at 0xfffff=
fffffffffff.
>>>>>> So we still need at least one more page to cover unaligned end.
>>>>>=20
>>>>> Actually, I'm wrong here. I assumed that we would need an additional p=
age to store p4d entries,
>>>>> but in fact we don't need it, as such page should already exist. It's t=
he same last pgd where kernel image
>>>>> is mapped.
>>>>>=20
>>>>=20
>>>>=20
>>>> Something like bellow might work. It's just a proposal to demonstrate t=
he idea, so some code might look ugly.
>>>> And it's only build-tested.
>>>=20
>>> [Sorry for loong delay.]
>>>=20
>>> The patch works for me for legacy boot. But it breaks EFI boot with
>>> 5-level paging. And I struggle to understand why.
>>>=20
>>> What I see is many page faults at mm/kasan/kasan.c:758 --
>>> "DEFINE_ASAN_LOAD_STORE(4)". Handling one of them I get double-fault at
>>> arch/x86/kernel/head_64.S:298 -- "pushq %r14", which ends up with triple=

>>> fault.
>>>=20
>>> Any ideas?
>>=20
>>=20
>> Just playing the role of the rubber duck:
>> - what is the fault address?
>> - is it within the shadow range?
>> - was the shadow mapped already?
>=20
> I misread trace. The initial fault is at arch/x86/kernel/head_64.S:270,
> which is ".endr" in definition of early_idt_handler_array.
>=20
> The fault address for all three faults is 0xffffffff7ffffff8, which is
> outside shadow range. It's just before kernel text mapping.
>=20
> Codewise, it happens in load_ucode_bsp() -- after kasan_early_init(), but
> before kasan_init().

My theory is that, in 5 level mode, the early IDT code isn't all mapped in t=
he page tables.  This could sometimes be papered over by lazy page table set=
up, but lazy setup can't handle faults in the page fault code or data struct=
ures.

EFI sometimes uses separate page tables, which could contribute.

>=20
> --=20
> Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
