Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CAA56B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 18:59:56 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id z13so72250062iof.7
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:59:56 -0700 (PDT)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id o125si19612160iof.220.2017.04.04.15.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 15:59:55 -0700 (PDT)
Received: by mail-it0-x231.google.com with SMTP id e75so73565481itd.1
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:59:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzSzemLt+GeynyavM7HzsOjGBrG=_S6XMFV=Xc1mn-UGA@mail.gmail.com>
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk> <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
 <20170331171724.nm22iqiellfsvj5z@codemonkey.org.uk> <CAGXu5jL7MGNut_izksDKJHNJjPZqvu_84GBwHjqVeRbjDJyMWw@mail.gmail.com>
 <CA+55aFwOCnhSF4Tyk8x0+EpcWmaDd9X5bi1w=O1aReEK53OY8A@mail.gmail.com>
 <a6543d13-6247-08de-903e-f4d1bbb52881@nokia.com> <CAGXu5jJAd9Qg4gkXE=1+8q6Ej=8boiH4ovkzX5n+PbhkBrnt5g@mail.gmail.com>
 <CA+55aFzSzemLt+GeynyavM7HzsOjGBrG=_S6XMFV=Xc1mn-UGA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 4 Apr 2017 15:59:54 -0700
Message-ID: <CAGXu5jL3yC0ST--c6Ph7_tq95fqeWTCpw02690dEDYgUa_KgKA@mail.gmail.com>
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tommi Rantala <tommi.t.rantala@nokia.com>, Dave Jones <davej@codemonkey.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On Tue, Apr 4, 2017 at 3:55 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Apr 4, 2017 at 3:37 PM, Kees Cook <keescook@chromium.org> wrote:
>>
>> For one of my systems, I see something like this:
>>
>> 00000000-00000fff : reserved
>> 00001000-0008efff : System RAM
>> 0008f000-0008ffff : reserved
>> 00090000-0009f7ff : System RAM
>> 0009f800-0009ffff : reserved
>
> That's fairly normal.
>
>> I note that there are two "System RAM" areas below 0x100000.
>
> Yes. Traditionally the area from about 4k to 640kB is RAM. With a
> random smattering of BIOS areas.
>
>>  * On x86, access has to be given to the first megabyte of ram because that area
>>  * contains BIOS code and data regions used by X and dosemu and similar apps.
>
> Rigth. Traditionally, dosemu did one big mmap of the 1MB area to just
> get all the BIOS data in one go.
>
>> This means that it allows reads into even System RAM below 0x100000,
>> but I think that's a mistake.
>
> What you think is a "mistake" is how /dev/mem has always worked.
>
> /dev/mem gave access to all the memory of the system. That's LITERALLY
> the whole point of it. There was no "BIOS area" or anything else. It
> was access to physical memory.
>
> We've added limits to it, but those limits came later, and they came
> with the caveat that lots of programs used /dev/mem in various ways.
>
> Nobody was crazy enough to read /dev/mem one byte at a time trying to
> follow BIOS tables. No, the traditional way was to just map (or read)
> large chunks of it, and then follow the tables in the result. The
> easiest way was to just do the whole low 1MB.
>
> There's no "mistake" here. The only thing that is mistaken is you
> thinking that we can redefine reality and change history.

I'm not trying to rewrite history. :) I'm try to understand the
requirements for how the 1MB area was used, which you've explained the
history of now. (Thank you!)

> I already explained what the likely fix is: make devmem_is_allowed()
> return a ternary value, so that those things that *do* read the BIOS
> area can just continue to do so, but they see zeroes for the parts
> that the kernel has taken over.

Sounds good to me. I'll go work on that.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
