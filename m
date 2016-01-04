Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 189696B0007
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 13:59:20 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id b14so198800274wmb.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 10:59:20 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id uq9si147140866wjc.17.2016.01.04.10.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 10:59:18 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id l65so56135011wmf.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 10:59:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com>
References: <cover.1451869360.git.tony.luck@intel.com>
	<968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
	<20160104120751.GG22941@pd.tnic>
	<CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
	<CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com>
Date: Mon, 4 Jan 2016 10:59:18 -0800
Message-ID: <CA+8MBbJwsXoUQQc=N33pYJUR0xf7CmtgJ3kZTjN984sWLvQQfg@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

> ----- begin comment -----
>
> The offset to the fixup is signed, and we're trying to use the high
> bits for a different purpose.  In C, we could just do:
>
> u32 class_and_offset = ((target - here) & 0x3fffffff) | class;
>
> Then, to decode it, we'd mask off the class and sign-extend to recover
> the offset.
>
> In asm, we can't do that, because this all gets laundered through the
> linker, and there's no relocation type that supports this chicanery.
> Instead we cheat a bit.  We first add a large number to the offset
> (0x20000000).  The result is still nominally signed, but now it's
> always positive, and the two high bits are always clear.  We can then
> set high bits by ordinary addition or subtraction instead of using
> bitwise operations.  As far as the linker is concerned, all we're
> doing is adding a large constant to the difference between here (".")
> and the target, and that's a valid relocation type.
>
> In the C code, we just mask off the class bits and subtract 0x20000000
> to get the offset.
>
> ----- end comment -----

But presumably those constants get folded together, so the linker
is dealing with only one offset.  It doesn't (I assume) know that our
source code added 0x20000000 and then added/subtracted some
more.

It looks like we could just use:
class0: +0x40000000
class1: +0x80000000 (or subtract ... whatever doesn't make the linker cranky)
class2: -0x40000000
class3: don't add/subtract anything

ex_class() stays the same (just looks at bit31/bit30)
ex_fixup_addr() has to use ex_class() to decide what to add/subtract
(if anything).

Would that work?  Would it be more or less confusing?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
