Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC376B000C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 07:39:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s16so2819989pfm.1
        for <linux-mm@kvack.org>; Mon, 07 May 2018 04:39:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h190-v6si11491808pgc.663.2018.05.07.04.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 04:39:04 -0700 (PDT)
Date: Mon, 7 May 2018 04:39:02 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: *alloc API changes
Message-ID: <20180507113902.GC18116@bombadil.infradead.org>
References: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
 <20180505034646.GA20495@bombadil.infradead.org>
 <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Fri, May 04, 2018 at 09:24:56PM -0700, Kees Cook wrote:
> On Fri, May 4, 2018 at 8:46 PM, Matthew Wilcox <willy@infradead.org> wrote:
> The only fear I have with the saturating helpers is that we'll end up
> using them in places that don't recognize SIZE_MAX. Like, say:
> 
> size = mul(a, b) + 1;
> 
> then *poof* size == 0. Now, I'd hope that code would use add(mul(a,
> b), 1), but still... it makes me nervous.

That's reasonable.  So let's add:

#define ALLOC_TOO_BIG	(PAGE_SIZE << MAX_ORDER)

(there's a presumably somewhat obsolete CONFIG_FORCE_MAX_ZONEORDER on some
architectures which allows people to configure MAX_ORDER all the way up
to 64.  That config option needs to go away, or at least be limited to
a much lower value).

On x86, that's 4k << 11 = 8MB.  On PPC, that might be 64k << 9 == 32MB.
Those values should be relatively immune to further arithmetic causing
an additional overflow.

> Good point. Though it does kind of creep me out to let a known-bad
> size float around in the allocator until it decides to reject it. I
> would think an early:
> 
> if (unlikely(size == SIZE_MAX))
>     return NULL;
> 
> would have virtually no cycle count difference...

I don't think it should go in the callers though ... where it goes in
the allocator is up to the allocator maintainers ;-)

> > I'd rather have a mul_ab(), mul_abc(), mul_ab_add_c(), etc. than nest
> > calls to mult().
> 
> Agreed. I think having exactly those would cover almost everything,
> and the two places where a 4-factor product is needed could just nest
> them. (bikeshed: the very common mul_ab() should just be mul(), IMO.)
> 
> > Nono, Linus had the better proposal, struct_size(p, member, n).
> 
> Oh, yes! I totally missed that in the threads.

so we're agreed on struct_size().  I think rather than the explicit 'mul',
perhaps we should have array_size() and array3_size().

> Right, no. I think if we can ditch *calloc() and _array() by using
> saturating helpers, we'll have the API in a much better form:
> 
> kmalloc(foo * bar, GFP_KERNEL);
> into
> kmalloc_array(foo, bar, GFP_KERNEL);
> into
> kmalloc(mul(foo, bar), GFP_KERNEL);

kmalloc(array_size(foo, bar), GFP_KERNEL);

> and the fun
> 
> kzalloc(sizeof(*header) + count * sizeof(*header->element), GFP_KERNEL);
> into
> kzalloc(struct_size(header, element, count), GFP_KERNEL);
> 
> modulo all *alloc* families...
> 
> ?

I think we're broadly in agreement here!
