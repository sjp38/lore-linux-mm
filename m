Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 647F26B0003
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 13:09:04 -0500 (EST)
Received: by mail-oi0-f53.google.com with SMTP id o124so259634702oia.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 10:09:04 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id qm4si25241591oeb.89.2016.01.04.10.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 10:09:03 -0800 (PST)
Received: by mail-ob0-x229.google.com with SMTP id wp13so119827903obc.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 10:09:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
References: <cover.1451869360.git.tony.luck@intel.com> <968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
 <20160104120751.GG22941@pd.tnic> <CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 4 Jan 2016 10:08:43 -0800
Message-ID: <CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Mon, Jan 4, 2016 at 9:26 AM, Tony Luck <tony.luck@gmail.com> wrote:
> On Mon, Jan 4, 2016 at 4:07 AM, Borislav Petkov <bp@alien8.de> wrote:
>>> + * (target - here) + (class) + 0x20000000
>>
>> I still don't understand that bit 29 thing.
>>
>> Because the offset is negative?
>
> I think so.  The .fixup section is placed in the end of .text, and the ex_table
> itself is pretty much right after.  So all the "fixup" offsets will be
> small negative
> numbers (the "insn" ones are also negative, but will be bigger since they
> potentially need to reach all the way to the start of .text).
>
> Adding 0x20000000 makes everything positive (so our legacy exception
> table entries have bit31==bit30==0) and perhaps makes it fractionally clearer
> how we manipulate the top bits for the other classes ... but only
> slightly. I got
> very confused by it too).
>
> It is all made more complex because these values need to be something
> that "ld" can relocate when vmlinux is put together from all the ".o" files.
> So we can't just use "x | BIT(30)" etc.

All of that's correct, including the part where it's confusing.  The
comments aren't the best.

How about adding a comment like:

----- begin comment -----

The offset to the fixup is signed, and we're trying to use the high
bits for a different purpose.  In C, we could just do:

u32 class_and_offset = ((target - here) & 0x3fffffff) | class;

Then, to decode it, we'd mask off the class and sign-extend to recover
the offset.

In asm, we can't do that, because this all gets laundered through the
linker, and there's no relocation type that supports this chicanery.
Instead we cheat a bit.  We first add a large number to the offset
(0x20000000).  The result is still nominally signed, but now it's
always positive, and the two high bits are always clear.  We can then
set high bits by ordinary addition or subtraction instead of using
bitwise operations.  As far as the linker is concerned, all we're
doing is adding a large constant to the difference between here (".")
and the target, and that's a valid relocation type.

In the C code, we just mask off the class bits and subtract 0x20000000
to get the offset.

----- end comment -----

>
>
>>> +#define _EXTABLE_CLASS_EX    0x80000000      /* uaccess + set uaccess_err */
>>
>>                                 BIT(31) is more readable.
>
> Not to the assembler :-(
>
>> Why not simply:
>>
>>         .long (to) - . + (bias) ;
>>
>> and
>>
>>         " .long (" #to ") - . + "(" #bias ") "\n"
>>
>> below and get rid of that _EXPAND_EXTABLE_BIAS()?
>
> Andy - this part is your code and I'm not sure what the trick is here.

I don't remember.  I think it was just some preprocessor crud to force
all the macros to expand fully before the assembler sees it.  If it
builds without it, feel free to delete it.

>
>>>  ex_fixup_addr(const struct exception_table_entry *x)
>>>  {
>>> -     return (unsigned long)&x->fixup + x->fixup;
>>> +     long offset = (long)((u32)x->fixup & 0x3fffffff) - (long)0x20000000;
>>
>> So basically:
>>
>>         x->fixup & 0x1fffffff
>>
>> Why the explicit subtraction of bit 29?
>
> We added it to begin with ... need to subtract to get back to the
> original offset.

Hopefully it's clearer with the comment above.

>
>> IOW, I was expecting something simpler for the whole scheme like:
>>
>> ex_class:
>>
>>         return x->fixup & 0xC0000000;
>
> ex_class (after part2) is just "(u32)x->fixup >> 30" (because I wanted
> a result in [0..3])
>
>> ex_fixup_addr:
>>
>>         return x->fixup | 0xC0000000;
>>
>> Why can't it be done this way?
>
> Because relocations ... the linker can only add/subtract values when
> making vmlinux ... it can't OR bits in.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
