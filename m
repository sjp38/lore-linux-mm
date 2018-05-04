Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87D1C6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 03:43:05 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n83-v6so1670385itg.2
        for <linux-mm@kvack.org>; Fri, 04 May 2018 00:43:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e198-v6sor562944itc.35.2018.05.04.00.43.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 00:43:04 -0700 (PDT)
MIME-Version: 1.0
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org>
In-Reply-To: <20180214182618.14627-3-willy@infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 04 May 2018 07:42:52 +0000
Message-ID: <CA+55aFzLgES5qTAt2szDKcRtoUP5X--UPCoYX-38ea67cRFHxQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Feb 14, 2018 at 8:27 AM Matthew Wilcox <willy@infradead.org> wrote:
> +static inline __must_check
> +void *kvmalloc_ab_c(size_t n, size_t size, size_t c, gfp_t gfp)
> +{
> +       if (size != 0 && n > (SIZE_MAX - c) / size)
> +               return NULL;
> +
> +       return kvmalloc(n * size + c, gfp);

Ok, so some more bikeshedding:

  - I really don't want to encourage people to use kvmalloc().

In fact, the conversion I saw was buggy. You can *not* convert a GFP_ATOMIC
user of kmalloc() to use kvmalloc.

  - that divide is really really expensive on many architectures.

Note that these issues kind of go hand in hand.

Normal kernel allocations are *limited*. It's simply not ok to allocate
megabytes (or gigabytes) of mmory in general. We have serious limits, and
we *should* have serious limits. If people worry about the multiply
overflowing because a user is controlling the size valus, then dammit, such
a user should not be able to do a huge gigabyte vmalloc() that exhausts
memory and then spends time clearing it all!

So the whole notion that "overflows are dangerous, let's get rid of them"
somehow fixes a bug is BULLSHIT. You literally introduced a *new* bug by
removing the normal kmalloc() size limit because you thought that pverflows
are the only problem.

So stop doing things like this. We should not do a stupid divide, because
we damn well know that it is NOT VALID to allocate arrays that have
hundreds of fthousands of elements,  or where the size of one element is
very big.

So get rid of the stupid divide, and make the limits be much stricter. Like
saying "the array element size had better be smaller than one page"
(because honestly, bigger elements are not valid in the kernel), and "the
size of the array cannot be more than "pick-some-number-out-of-your-ass".

So just make the divide go the hell away, a and check the size for validity.

Something like

      if (size > PAGE_SIZE)
           return NULL;
      if (elem > 65535)
           return NULL;
      if (offset > PAGE_SIZE)
           return NULL;
      return kzalloc(size*elem+offset);

and now you (a) guarantee it can't overflow and (b) don't make people use
crazy vmalloc() allocations when they damn well shouldn't.

And yeah, if  somebody has a page size bigger than 64k, then the above can
still overflow. I'm sorry, that architecture s broken shit.

Are there  cases where vmalloc() is ok? Yes. But they should be rare, and
they should have a good reason for them. And honestly, even then the above
limits really really sound quite reasonable. There is no excuse for
million-entry arrays in the kernel. You are doing something seriously wrong
if you do those.

             Linus
