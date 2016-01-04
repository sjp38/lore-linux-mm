Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id D2ABD6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 17:29:29 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id 18so353364384obc.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 14:29:29 -0800 (PST)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id t63si28111813oie.59.2016.01.04.14.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 14:29:29 -0800 (PST)
Received: by mail-oi0-x22f.google.com with SMTP id l9so236121828oia.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 14:29:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160104210228.GR22941@pd.tnic>
References: <cover.1451869360.git.tony.luck@intel.com> <968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
 <20160104120751.GG22941@pd.tnic> <CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
 <CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com> <20160104210228.GR22941@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 4 Jan 2016 14:29:09 -0800
Message-ID: <CALCETrVOF9P3YFKMeShp0FYX15cqppkWhhiOBi6pxfu6k+XDmA@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@gmail.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Mon, Jan 4, 2016 at 1:02 PM, Borislav Petkov <bp@alien8.de> wrote:
> On Mon, Jan 04, 2016 at 10:08:43AM -0800, Andy Lutomirski wrote:
>> All of that's correct, including the part where it's confusing.  The
>> comments aren't the best.
>>
>> How about adding a comment like:
>>
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
> Yeah, that makes more sense, thanks.
>
> That nasty "." current position thing stays in the way to do it cleanly. :-)
>
> Anyway, ok, I see it now. It still feels a bit hacky to me. I probably
> would've added the third int to the exception table instead. It would've
> been much more straightforward and clean this way and I'd gladly pay the
> additional 6K growth.

Josh will argue with you if he sees that :)

We could maybe come up with a way to compress the table and get that
space and more back, but maybe that should be a follow-up that someone
else can do if they're inspired.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
