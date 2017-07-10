Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id CEBAB44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 16:07:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q4so385759oif.2
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:07:36 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a138si8614624oii.134.2017.07.10.13.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 13:07:35 -0700 (PDT)
Received: from mail-ua0-f181.google.com (mail-ua0-f181.google.com [209.85.217.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0FCE922BE3
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 20:07:35 +0000 (UTC)
Received: by mail-ua0-f181.google.com with SMTP id j53so61429684uaa.2
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:07:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170710184704.realchrhzpblqqlk@node.shutemov.name>
References: <CACT4Y+YyFWg3fbj4ta3tSKoeBaw7hbL2YoBatAFiFB1_cMg9=Q@mail.gmail.com>
 <71e11033-f95c-887f-4e4e-351bcc3df71e@virtuozzo.com> <CACT4Y+bSTOeJtDDZVmkff=qqJFesA_b6uTG__EAn4AvDLw0jzQ@mail.gmail.com>
 <c4f11000-6138-c6ab-d075-2c4bd6a14943@virtuozzo.com> <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
 <bc95be68-8c68-2a45-c530-acbc6c90a231@virtuozzo.com> <20170710123346.7y3jnftqgpingim3@node.shutemov.name>
 <CACT4Y+aRbC7_wvDv8ahH_JwY6P6SFoLg-kdwWHJx5j1stX_P_w@mail.gmail.com>
 <20170710141713.7aox3edx6o7lrrie@node.shutemov.name> <03A6D7ED-300C-4431-9EB5-67C7A3EA4A2E@amacapital.net>
 <20170710184704.realchrhzpblqqlk@node.shutemov.name>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 10 Jul 2017 13:07:13 -0700
Message-ID: <CALCETrVJQ_u-agPm8fFHAW1UJY=VLowdbM+gXyjFCb586r0V3g@mail.gmail.com>
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Mon, Jul 10, 2017 at 11:47 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Mon, Jul 10, 2017 at 08:56:37AM -0700, Andy Lutomirski wrote:
>>
>>
>> > On Jul 10, 2017, at 7:17 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
>> >
>> >> On Mon, Jul 10, 2017 at 02:43:17PM +0200, Dmitry Vyukov wrote:
>> >> On Mon, Jul 10, 2017 at 2:33 PM, Kirill A. Shutemov
>> >> <kirill@shutemov.name> wrote:
>> >>> On Thu, Jun 01, 2017 at 05:56:30PM +0300, Andrey Ryabinin wrote:
>> >>>>> On 05/29/2017 03:46 PM, Andrey Ryabinin wrote:
>> >>>>> On 05/29/2017 02:45 PM, Andrey Ryabinin wrote:
>> >>>>>>>>>> Looks like KASAN will be a problem for boot-time paging mode switching.
>> >>>>>>>>>> It wants to know CONFIG_KASAN_SHADOW_OFFSET at compile-time to pass to
>> >>>>>>>>>> gcc -fasan-shadow-offset=. But this value varies between paging modes...
>> >>>>>>>>>>
>> >>>>>>>>>> I don't see how to solve it. Folks, any ideas?
>> >>>>>>>>>
>> >>>>>>>>> +kasan-dev
>> >>>>>>>>>
>> >>>>>>>>> I wonder if we can use the same offset for both modes. If we use
>> >>>>>>>>> 0xFFDFFC0000000000 as start of shadow for 5 levels, then the same
>> >>>>>>>>> offset that we use for 4 levels (0xdffffc0000000000) will also work
>> >>>>>>>>> for 5 levels. Namely, ending of 5 level shadow will overlap with 4
>> >>>>>>>>> level mapping (both end at 0xfffffbffffffffff), but 5 level mapping
>> >>>>>>>>> extends towards lower addresses. The current 5 level start of shadow
>> >>>>>>>>> is actually close -- 0xffd8000000000000 and it seems that the required
>> >>>>>>>>> space after it is unused at the moment (at least looking at mm.txt).
>> >>>>>>>>> So just try to move it to 0xFFDFFC0000000000?
>> >>>>>>>>>
>> >>>>>>>>
>> >>>>>>>> Yeah, this should work, but note that 0xFFDFFC0000000000 is not PGDIR aligned address. Our init code
>> >>>>>>>> assumes that kasan shadow stars and ends on the PGDIR aligned address.
>> >>>>>>>> Fortunately this is fixable, we'd need two more pages for page tables to map unaligned start/end
>> >>>>>>>> of the shadow.
>> >>>>>>>
>> >>>>>>> I think we can extend the shadow backwards (to the current address),
>> >>>>>>> provided that it does not affect shadow offset that we pass to
>> >>>>>>> compiler.
>> >>>>>>
>> >>>>>> I thought about this. We can round down shadow start to 0xffdf000000000000, but we can't
>> >>>>>> round up shadow end, because in that case shadow would end at 0xffffffffffffffff.
>> >>>>>> So we still need at least one more page to cover unaligned end.
>> >>>>>
>> >>>>> Actually, I'm wrong here. I assumed that we would need an additional page to store p4d entries,
>> >>>>> but in fact we don't need it, as such page should already exist. It's the same last pgd where kernel image
>> >>>>> is mapped.
>> >>>>>
>> >>>>
>> >>>>
>> >>>> Something like bellow might work. It's just a proposal to demonstrate the idea, so some code might look ugly.
>> >>>> And it's only build-tested.
>> >>>
>> >>> [Sorry for loong delay.]
>> >>>
>> >>> The patch works for me for legacy boot. But it breaks EFI boot with
>> >>> 5-level paging. And I struggle to understand why.
>> >>>
>> >>> What I see is many page faults at mm/kasan/kasan.c:758 --
>> >>> "DEFINE_ASAN_LOAD_STORE(4)". Handling one of them I get double-fault at
>> >>> arch/x86/kernel/head_64.S:298 -- "pushq %r14", which ends up with triple
>> >>> fault.
>> >>>
>> >>> Any ideas?
>> >>
>> >>
>> >> Just playing the role of the rubber duck:
>> >> - what is the fault address?
>> >> - is it within the shadow range?
>> >> - was the shadow mapped already?
>> >
>> > I misread trace. The initial fault is at arch/x86/kernel/head_64.S:270,
>> > which is ".endr" in definition of early_idt_handler_array.
>> >
>> > The fault address for all three faults is 0xffffffff7ffffff8, which is
>> > outside shadow range. It's just before kernel text mapping.
>> >
>> > Codewise, it happens in load_ucode_bsp() -- after kasan_early_init(), but
>> > before kasan_init().
>>
>> My theory is that, in 5 level mode, the early IDT code isn't all mapped
>> in the page tables.  This could sometimes be papered over by lazy page
>> table setup, but lazy setup can't handle faults in the page fault code
>> or data structures.
>>
>> EFI sometimes uses separate page tables, which could contribute.
>
> As far as I can see all involved code is within the same page:
>
> (gdb) p/x &x86_64_start_kernel
> $1 = 0xffffffff84bad2ae
> (gdb) p/x &early_idt_handler_array
> $2 = 0xffffffff84bad000
> (gdb) p/x &early_idt_handler_common
> $3 = 0xffffffff84bad120
> (gdb) p/x &early_make_pgtable
> $4 = 0xffffffff84bad3b4
>

Can you give the disassembly of the backtrace lines?  Blaming the
.endr doesn't make much sense to me.

Or maybe Andrey will figure it out quickly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
