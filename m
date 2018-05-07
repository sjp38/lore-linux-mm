Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C94D6B0008
	for <linux-mm@kvack.org>; Mon,  7 May 2018 16:49:16 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id y131-v6so10191231itc.5
        for <linux-mm@kvack.org>; Mon, 07 May 2018 13:49:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b123-v6si7998765iti.91.2018.05.07.13.49.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 13:49:14 -0700 (PDT)
Date: Mon, 7 May 2018 13:49:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: *alloc API changes
Message-ID: <20180507204911.GC15604@bombadil.infradead.org>
References: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
 <20180505034646.GA20495@bombadil.infradead.org>
 <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
 <20180507113902.GC18116@bombadil.infradead.org>
 <CAGXu5jKq7uZsDN8qLzKTUC2eVQT2f3ZvVbr8s9oQFeikun9NjA@mail.gmail.com>
 <20180507201945.GB15604@bombadil.infradead.org>
 <CAGXu5jL_vYWs7eKY34ews2pW24fvOqNPybmuugg9ycfR1siOLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jL_vYWs7eKY34ews2pW24fvOqNPybmuugg9ycfR1siOLA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: John Johansen <john.johansen@canonical.com>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Mon, May 07, 2018 at 01:27:38PM -0700, Kees Cook wrote:
> On Mon, May 7, 2018 at 1:19 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > Yes.  And today with kvmalloc.  However, I proposed to Linus that
> > kvmalloc() shouldn't allow it -- we should have kvmalloc_large() which
> > would, but kvmalloc wouldn't.  He liked that idea, so I'm going with it.
> 
> How would we handle size calculations for _large?

I'm not sure we should, at least initially.  The very few places which
need a large kvmalloc really are special and can do their own careful
checking.  Because, as Linus pointed out, we shouldn't be letting the
user ask us to allocate a terabyte of RAM.  We should just fail that.

let's see how those users pan out, and then see what we can offer in
terms of safety.

> > There are very, very few places which should need kvmalloc_large.
> > That's one million 8-byte pointers.  If you need more than that inside
> > the kernel, you're doing something really damn weird and should do
> > something that looks obviously different.
> 
> I'm CCing John since I remember long ago running into problems loading
> the AppArmor DFA with kmalloc and switching it to kvmalloc. John, how
> large can the DFAs for AppArmor get? Would an 8MB limit be a problem?

Great!  Opinions from people who'll use this interface are exceptionally
useful.

> And do we have any large IO or network buffers >8MB?

Not that get allocated with kvmalloc ... because you can't DMA map vmalloc
(without doing some unusual contortions).

> > but I thought of another problem with array_size.  We already have
> > ARRAY_SIZE and it means "the number of elements in the array".
> >
> > so ... struct_bytes(), array_bytes(), array3_bytes()?
> 
> Maybe "calc"? struct_calc(), array_calc(), array3_calc()? This has the
> benefit of actually saying more about what it is doing, rather than
> its return value... In the end, I don't care. :)

I don't have a strong feeling on this either.

> > Keeping our focus on allocations ... do we have plain additions (as
> > opposed to multiply-and-add?)  And subtraction?
> 
> All I've seen are just rare "weird" cases of lots of mult/add. Some
> are way worse than others:
> http://www.ozlabs.org/~akpm/mmotm/broken-out/exofs-avoid-vla-in-structures.patch
> 
> Just having the mult/add saturation would be lovely.

Ow.  My brain just oozed out of my ears.
