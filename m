Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0BC56B0390
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 14:26:11 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n76so28743955ioe.1
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 11:26:11 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id n2si3423339itn.120.2017.03.31.11.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 11:26:10 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id 190so2797859itm.3
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 11:26:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL7MGNut_izksDKJHNJjPZqvu_84GBwHjqVeRbjDJyMWw@mail.gmail.com>
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk> <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
 <20170331171724.nm22iqiellfsvj5z@codemonkey.org.uk> <CAGXu5jL7MGNut_izksDKJHNJjPZqvu_84GBwHjqVeRbjDJyMWw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 31 Mar 2017 11:26:09 -0700
Message-ID: <CA+55aFwOCnhSF4Tyk8x0+EpcWmaDd9X5bi1w=O1aReEK53OY8A@mail.gmail.com>
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Dave Jones <davej@codemonkey.org.uk>, Tommi Rantala <tommi.t.rantala@nokia.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On Fri, Mar 31, 2017 at 10:32 AM, Kees Cook <keescook@chromium.org> wrote:
>
> How is ffff880000090000 both in the direct mapping and a slab object?

I think this is just very regular /dev/mem behavior, that is hidden by
the fact that the *normal* case for /dev/mem is all to reserved RAM,
which will never be a slab object.

And this is all hidden with STRICT_DEVMEM, which pretty much everybody
has enabled, but Tommi for some reason did not.

> It would need to pass all of these checks, and be marked as PageSlab
> before it could be evaluated by __check_heap_object:

It trivially passes those checks, because it's a normal kernel address
for a page that is just used for kernel stuff.

I think we have two options:

 - just get rid of STRICT_DEVMEM and make that unconditional

 - make the read_mem/write_mem code use some non-checking copy
routines, since they are obviously designed to access any memory
location (including kernel memory) unless STRICT_DEVMEM is set.

Hmm. Thinking more about this, we do allow access to the first 1MB of
physical memory unconditionally (see devmem_is_allowed() in
arch/x86/mm/init.c). And I think we only _reserve_ the first 64kB or
something. So I guess even STRICT_DEVMEM isn't actually all that
strict.

So this should be visible even *with* STRICT_DEVMEM.

Does a simple

     sudo dd if=/dev/mem of=/dev/null bs=4096 count=256

also show the same issue? Maybe regardless of STRICT_DEVMEM?

Maybe we should change devmem_is_allowed() to return a ternary value,
and then have it be "allow access" (for reserved pages), "disallow
access" (for various random stuff), and "just read zero" (for pages in
the low 1M that aren't marked reserved).

That way things like that read the low 1M (like x86info) will
hopefully not be unhappy, but also won't be reading random kernel
data.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
