Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB2336B0266
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:03:49 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id u23so18656158ual.4
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:03:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l205-v6sor407649vke.114.2018.05.04.09.03.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 09:03:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy8DSRoUvtiuu5w+XGOK6tYvtJGBH-i8i-y7aiUD2EGLA@mail.gmail.com>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org>
 <CA+55aFzLgES5qTAt2szDKcRtoUP5X--UPCoYX-38ea67cRFHxQ@mail.gmail.com>
 <20180504131441.GA24691@bombadil.infradead.org> <CA+55aFy8DSRoUvtiuu5w+XGOK6tYvtJGBH-i8i-y7aiUD2EGLA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 4 May 2018 09:03:46 -0700
Message-ID: <CAGXu5j+0yTG0kJagiO8pAaMO9SuQWeGuCD01qVEu2vquM2=2fQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Fri, May 4, 2018 at 8:35 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, May 4, 2018 at 3:14 AM Matthew Wilcox <willy@infradead.org> wrote:
>
>> > In fact, the conversion I saw was buggy. You can *not* convert a
> GFP_ATOMIC
>> > user of kmalloc() to use kvmalloc.
>
>> Not sure which conversion you're referring to; not one of mine, I hope?
>
> I was thinking of the coccinelle patch in this thread, but just realized
> that that actually only did it for GFP_KERNEL, so I guess it would work,
> apart from the "oops, now it doesn't enforce the kmalloc limits any more"
> issue.

Just to be clear: the Coccinelle scripts I'm building aren't doing a
kmalloc -> kvmalloc conversion. I'm just removing all the 2-factor
multiplication and replacing it with the appropriate calls to the
allocator family's *calloc or *alloc_array(). This will get us to the
place where we can do all the sanity-checking in the allocator
functions (whatever that checking ends up being). As it turns out,
though, we have kind of a lot of allocator families. Some are
wrappers, like devm_*alloc(), etc.

All that said, the overwhelming majority of *alloc() multiplications
are just "count * sizeof()". It really feels like everything should
just be using a new *alloc_struct() which can do the type checking,
etc, etc, but we can get there. The remaining "count * size" are a
minority and could be dealt with some other way.

>> >   - that divide is really really expensive on many architectures.
>
>> 'c' and 'size' are _supposed_ to be constant and get evaluated at
>> compile-time.  ie you should get something like this on x86:
>
> I guess that willalways  be true of the 'kvzalloc_struct() version that
> will always use a sizeof(). I was more thinking of any bare kvalloc_ab_c()
> cases, but maybe we'd discourage that to ever be used as such?

Yeah, bare *alloc_ab_c() is not great. Perhaps a leading "__" can hint to that?

> Because we definitely have things like that, ie a quick grep finds
>
>     f = kmalloc (sizeof (*f) + size*num, GFP_KERNEL);
>
> where 'size' is not obviously a constant. There may be others, but I didn't
> really try to grep any further.
>
> Maybe they aren't common, and maybe the occasional divide doesn't matter,
> but particularly if we use scripting to then catch and convert users, I
> really hate the idea of "let's introduce something that is potentially much
> more expensive than it needs to be".

Yup: I'm not after that either. I just want to be able to get at the
multiplication factors before they're multiplied. :)

> (And the automated coccinelle scripting it's also something where we must
> very much avoid then subtly lifting allocation size limits)

Agreed. I think most cases are already getting lifted to size_t due to
the sizeof(). It's the "two variables" cases I want to double-check.
Another completely insane idea would be to have a macro that did type
size checking and would DTRT, but with all the alloc families, it
looks nasty. This is all RFC stage, as far as I'm concerned.

Fun example: devm_kzalloc(dev, sizeof(...) * num, gfp...)

$ git grep 'devm_kzalloc([^,]*, *sizeof([^,]*,' | egrep '\* *sizeof|\)
*\*' | wc -l
88

some are constants:
drivers/video/fbdev/au1100fb.c:         devm_kzalloc(&dev->dev,
sizeof(u32) * 16, GFP_KERNEL);

but many aren't:
sound/soc/generic/audio-graph-card.c:   dai_link  = devm_kzalloc(dev,
sizeof(*dai_link)  * num, GFP_KERNEL);

While type-checking on the non-sizeof factor would let us know if it
was safe, so would the division, and most of those could happen at
compile time. It's the size_t variables that we want to catch.

So, mainly I'm just trying to get the arguments reordered (for a
compile-time division) into the correct helpers so the existing logic
can do the right thing, and only for 2-factor products. After that,
then I'm hoping to tackle the multi-factor products, of which the
*alloc_struct() helper seems to cover the vast majority of the
remaining cases.

-Kees

-- 
Kees Cook
Pixel Security
