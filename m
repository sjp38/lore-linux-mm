Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFFB66B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:35:21 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id o2so11387150pls.10
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:35:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 43-v6si3364888pla.70.2018.02.14.11.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 11:35:20 -0800 (PST)
Date: Wed, 14 Feb 2018 11:35:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180214193517.GA20627@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <20180214182618.14627-3-willy@infradead.org>
 <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Julia Lawall <julia.lawall@lip6.fr>, cocci@systeme.lip6.fr

On Wed, Feb 14, 2018 at 11:22:38AM -0800, Kees Cook wrote:
> > +/**
> > + * kvmalloc_ab_c() - Allocate memory.
> 
> Longer description, maybe? "Allocate a *b + c bytes of memory"?

Done!

> > + * @n: Number of elements.
> > + * @size: Size of each element (should be constant).
> > + * @c: Size of header (should be constant).
> 
> If these should be constant, should we mark them as "const"? Or WARN
> if __builtin_constant_p() isn't true?

It's only less efficient if they're not const.  Theoretically they could be
variable ... and I've been bitten by __builtin_constant_p() recently
(gcc bug 83653 which I still don't really understand).

> > + * @gfp: Memory allocation flags.
> > + *
> > + * Use this function to allocate @n * @size + @c bytes of memory.  This
> > + * function is safe to use when @n is controlled from userspace; it will
> > + * return %NULL if the required amount of memory cannot be allocated.
> > + * Use kvfree() to free the allocated memory.
> > + *
> > + * The kvzalloc_hdr_arr() function is easier to use as it has typechecking
> 
> renaming typo? Should this be "kvzalloc_struct()"?

Urgh, yes.  I swear I searched for it ... must've typoed my search string.
Anyway, fixed, because kvzalloc_hdr_arr() wasn't a good name.

> > +#define kvzalloc_ab_c(a, b, c, gfp)    kvmalloc_ab_c(a, b, c, gfp | __GFP_ZERO)
> 
> Nit: "(gfp) | __GFP_ZERO" just in case of insane usage.

Fixed!

> It might be nice to include another patch that replaces some of the
> existing/common uses of a*b+c with the new function...

Sure!  I have a few examples in my tree, I just didn't want to complicate
things by sending a patch that crossed dozens of maintainer trees.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
