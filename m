Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 969576B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 00:18:13 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id u45-v6so10738328uau.14
        for <linux-mm@kvack.org>; Thu, 31 May 2018 21:18:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h1-v6sor16239166vkg.108.2018.05.31.21.18.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 21:18:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzjt27tDoxU=iVo7N3cR_nVSRm5+nvTZg=+t2A4k_yNwA@mail.gmail.com>
References: <20180601004233.37822-1-keescook@chromium.org> <CA+55aFzjt27tDoxU=iVo7N3cR_nVSRm5+nvTZg=+t2A4k_yNwA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 31 May 2018 21:18:10 -0700
Message-ID: <CAGXu5jJeHD4Ouo9icjHk8oTCQLxjBvugVqQoZ7euDtLNtWCJ-A@mail.gmail.com>
Subject: Re: [PATCH v3 00/16] Provide saturating helpers for allocation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Thu, May 31, 2018 at 5:54 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, May 31, 2018 at 7:43 PM Kees Cook <keescook@chromium.org> wrote:
>>
>> So, while nothing does:
>>     kmalloc_array(a, b, ...) -> kmalloc(array_size(a, b), ...)
>> the treewide changes DO perform changes like this:
>>     kmalloc(a * b, ...) -> kmalloc(array_size(a, b), ...)
>
> Ugh. I really really still absolutely despise this.

Heh. Yeah, I called this out specifically because I wasn't sure if
this was going to be okay. :P

> Why can't you just have a separate set of coccinelle scripts that do
> the simple and clean cases?
>
> So *before* doing any array_size() conversions, just do
>
>     kzalloc(a*b, ...) -> kcalloc(a, b, ...)
>     kmalloc(a*b,..) -> kmalloc_array(a,b, ...)
>
> and the obvious variations on that (devm_xyz() has all the same helpers).

Yup. I'll get started on it. I did have a version of a python script
that generated coccinelle scripts, but I started losing my mind. I'll
double-check if I can find a way to do some internal-to-Coccinelle
python to handle some of the variation directly, etc.

For those interested in the details: the complexity for me is in how
Coccinelle handles expressions (or my understanding of it's handling).
There's nothing in between "expression" and "identifier", so
"thing->field" is an expression not an identifier ("thing" is an
identifier), but "foo * bar" is _also_ an expression, so I have to
slowly peel away the "easy" stuff (sizeof, constants, etc) before
expressions to avoid collapsing factors into the wrong arguments (e.g.
kzalloc(a * b * c, ...) -> kcalloc(a * b, c, ...) is not desirable),
so there end up being a LOT of rules... I was able to compress
allocation families into a a regex, but without that, I'll end up with
the sizeof/const/etc rules times the family times the kalloc and
_array rules.

> Only after doing the ones that don't have the nice obvious helpers, do
> the remaining ones with array_size(), ie
>
>     *alloc(a*b, ..) -> *alloc(array_size(a,b), ...)
>
> because that really makes for much less legible code.
>
> Hmm?

Sounds good. Thanks!

-Kees

-- 
Kees Cook
Pixel Security
