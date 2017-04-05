Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E5F126B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 20:22:29 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id n130so202999ita.15
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 17:22:29 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id m2si12081306itg.45.2017.04.04.17.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 17:22:29 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id f103so50558ioi.2
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 17:22:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzSzemLt+GeynyavM7HzsOjGBrG=_S6XMFV=Xc1mn-UGA@mail.gmail.com>
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk> <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
 <20170331171724.nm22iqiellfsvj5z@codemonkey.org.uk> <CAGXu5jL7MGNut_izksDKJHNJjPZqvu_84GBwHjqVeRbjDJyMWw@mail.gmail.com>
 <CA+55aFwOCnhSF4Tyk8x0+EpcWmaDd9X5bi1w=O1aReEK53OY8A@mail.gmail.com>
 <a6543d13-6247-08de-903e-f4d1bbb52881@nokia.com> <CAGXu5jJAd9Qg4gkXE=1+8q6Ej=8boiH4ovkzX5n+PbhkBrnt5g@mail.gmail.com>
 <CA+55aFzSzemLt+GeynyavM7HzsOjGBrG=_S6XMFV=Xc1mn-UGA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 4 Apr 2017 17:22:27 -0700
Message-ID: <CA+55aFwv8QPBD4SMLw2Y7qkV4JceMc9NdOujbVM7PfcBpkhm3Q@mail.gmail.com>
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Tommi Rantala <tommi.t.rantala@nokia.com>, Dave Jones <davej@codemonkey.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On Tue, Apr 4, 2017 at 3:55 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I already explained what the likely fix is: make devmem_is_allowed()
> return a ternary value, so that those things that *do* read the BIOS
> area can just continue to do so, but they see zeroes for the parts
> that the kernel has taken over.

Actually, a simpler solution might be to

 (a) keep the binary value

 (b) remove the test for the low 1M

 (c) to avoid breakage, don't return _error_, but just always read zero

that also removes (or at least makes it much more expensive) a signal
of which pages are kernel allocated vs BIOS allocated.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
