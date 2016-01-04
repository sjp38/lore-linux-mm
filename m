Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A76706B0003
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 12:26:54 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so181527238wmf.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 09:26:54 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id rx8si121622401wjb.204.2016.01.04.09.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 09:26:53 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id f206so29580860wmf.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 09:26:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160104120751.GG22941@pd.tnic>
References: <cover.1451869360.git.tony.luck@intel.com>
	<968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
	<20160104120751.GG22941@pd.tnic>
Date: Mon, 4 Jan 2016 09:26:53 -0800
Message-ID: <CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Mon, Jan 4, 2016 at 4:07 AM, Borislav Petkov <bp@alien8.de> wrote:
>> + * (target - here) + (class) + 0x20000000
>
> I still don't understand that bit 29 thing.
>
> Because the offset is negative?

I think so.  The .fixup section is placed in the end of .text, and the ex_table
itself is pretty much right after.  So all the "fixup" offsets will be
small negative
numbers (the "insn" ones are also negative, but will be bigger since they
potentially need to reach all the way to the start of .text).

Adding 0x20000000 makes everything positive (so our legacy exception
table entries have bit31==bit30==0) and perhaps makes it fractionally clearer
how we manipulate the top bits for the other classes ... but only
slightly. I got
very confused by it too).

It is all made more complex because these values need to be something
that "ld" can relocate when vmlinux is put together from all the ".o" files.
So we can't just use "x | BIT(30)" etc.


>> +#define _EXTABLE_CLASS_EX    0x80000000      /* uaccess + set uaccess_err */
>
>                                 BIT(31) is more readable.

Not to the assembler :-(

> Why not simply:
>
>         .long (to) - . + (bias) ;
>
> and
>
>         " .long (" #to ") - . + "(" #bias ") "\n"
>
> below and get rid of that _EXPAND_EXTABLE_BIAS()?

Andy - this part is your code and I'm not sure what the trick is here.

>>  ex_fixup_addr(const struct exception_table_entry *x)
>>  {
>> -     return (unsigned long)&x->fixup + x->fixup;
>> +     long offset = (long)((u32)x->fixup & 0x3fffffff) - (long)0x20000000;
>
> So basically:
>
>         x->fixup & 0x1fffffff
>
> Why the explicit subtraction of bit 29?

We added it to begin with ... need to subtract to get back to the
original offset.

> IOW, I was expecting something simpler for the whole scheme like:
>
> ex_class:
>
>         return x->fixup & 0xC0000000;

ex_class (after part2) is just "(u32)x->fixup >> 30" (because I wanted
a result in [0..3])

> ex_fixup_addr:
>
>         return x->fixup | 0xC0000000;
>
> Why can't it be done this way?

Because relocations ... the linker can only add/subtract values when
making vmlinux ... it can't OR bits in.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
