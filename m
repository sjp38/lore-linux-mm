Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5D29C6B0007
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 14:05:34 -0500 (EST)
Received: by mail-oi0-f53.google.com with SMTP id y66so261001840oig.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 11:05:34 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id l10si81591oeu.78.2016.01.04.11.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 11:05:33 -0800 (PST)
Received: by mail-ob0-x22b.google.com with SMTP id bx1so229424769obb.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 11:05:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbJwsXoUQQc=N33pYJUR0xf7CmtgJ3kZTjN984sWLvQQfg@mail.gmail.com>
References: <cover.1451869360.git.tony.luck@intel.com> <968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
 <20160104120751.GG22941@pd.tnic> <CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
 <CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com> <CA+8MBbJwsXoUQQc=N33pYJUR0xf7CmtgJ3kZTjN984sWLvQQfg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 4 Jan 2016 11:05:14 -0800
Message-ID: <CALCETrXeYfERb6hUPmJnj=5KL7ffOjKgVO9cS_4eO+eUp8fx0w@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Mon, Jan 4, 2016 at 10:59 AM, Tony Luck <tony.luck@gmail.com> wrote:
>> ----- begin comment -----
>>
>> The offset to the fixup is signed, and we're trying to use the high
>> bits for a different purpose.  In C, we could just do:
>>
>> u32 class_and_offset = ((target - here) & 0x3fffffff) | class;
>>
>> Then, to decode it, we'd mask off the class and sign-extend to recover
>> the offset.
>>
>> In asm, we can't do that, because this all gets laundered through the
>> linker, and there's no relocation type that supports this chicanery.
>> Instead we cheat a bit.  We first add a large number to the offset
>> (0x20000000).  The result is still nominally signed, but now it's
>> always positive, and the two high bits are always clear.  We can then
>> set high bits by ordinary addition or subtraction instead of using
>> bitwise operations.  As far as the linker is concerned, all we're
>> doing is adding a large constant to the difference between here (".")
>> and the target, and that's a valid relocation type.
>>
>> In the C code, we just mask off the class bits and subtract 0x20000000
>> to get the offset.
>>
>> ----- end comment -----
>
> But presumably those constants get folded together, so the linker
> is dealing with only one offset.  It doesn't (I assume) know that our
> source code added 0x20000000 and then added/subtracted some
> more.

Yes, indeed.

>
> It looks like we could just use:
> class0: +0x40000000
> class1: +0x80000000 (or subtract ... whatever doesn't make the linker cranky)
> class2: -0x40000000
> class3: don't add/subtract anything
>
> ex_class() stays the same (just looks at bit31/bit30)
> ex_fixup_addr() has to use ex_class() to decide what to add/subtract
> (if anything).
>
> Would that work?  Would it be more or less confusing?

That probably works, but to me, at least, it's a bit more confusing.
It also means that you need a table or some branches to compute the
offset, whereas the "mask top two bits and add a constant" approach is
straightforward, short, and fast.

Also, I'm not 100% convinced that the 0x80000000 case can ever work
reliably.  I don't know exactly what the condition that triggers the
warning is, but the logical one would be to warn if the actual offset
plus or minus the addend, as appropriate, overflows in a signed sense.
Whether it overflows depends on the sign of the offset, and *that*
depends on the actual layout of all the sections.

Mine avoids this issue by being shifted by 0x20000000, so nothing ends
up right on the edge.

--Andy



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
