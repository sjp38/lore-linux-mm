Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 478B06B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:54:31 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id c10-v6so19274490iob.11
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:54:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p66-v6sor9256097iof.86.2018.05.31.17.54.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 17:54:30 -0700 (PDT)
MIME-Version: 1.0
References: <20180601004233.37822-1-keescook@chromium.org>
In-Reply-To: <20180601004233.37822-1-keescook@chromium.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 May 2018 19:54:18 -0500
Message-ID: <CA+55aFzjt27tDoxU=iVo7N3cR_nVSRm5+nvTZg=+t2A4k_yNwA@mail.gmail.com>
Subject: Re: [PATCH v3 00/16] Provide saturating helpers for allocation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Thu, May 31, 2018 at 7:43 PM Kees Cook <keescook@chromium.org> wrote:
>
> So, while nothing does:
>     kmalloc_array(a, b, ...) -> kmalloc(array_size(a, b), ...)
> the treewide changes DO perform changes like this:
>     kmalloc(a * b, ...) -> kmalloc(array_size(a, b), ...)

Ugh. I really really still absolutely despise this.

Why can't you just have a separate set of coccinelle scripts that do
the simple and clean cases?

So *before* doing any array_size() conversions, just do

    kzalloc(a*b, ...) -> kcalloc(a, b, ...)
    kmalloc(a*b,..) -> kmalloc_array(a,b, ...)

and the obvious variations on that (devm_xyz() has all the same helpers).

Only after doing the ones that don't have the nice obvious helpers, do
the remaining ones with array_size(), ie

    *alloc(a*b, ..) -> *alloc(array_size(a,b), ...)

because that really makes for much less legible code.

Hmm?

            Linus
