Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7FF6B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:35:39 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s2-v6so13015613ioa.22
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:35:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r100-v6sor8623744ioi.17.2018.05.04.08.35.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 08:35:37 -0700 (PDT)
MIME-Version: 1.0
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org>
 <CA+55aFzLgES5qTAt2szDKcRtoUP5X--UPCoYX-38ea67cRFHxQ@mail.gmail.com> <20180504131441.GA24691@bombadil.infradead.org>
In-Reply-To: <20180504131441.GA24691@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 04 May 2018 15:35:26 +0000
Message-ID: <CA+55aFy8DSRoUvtiuu5w+XGOK6tYvtJGBH-i8i-y7aiUD2EGLA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Fri, May 4, 2018 at 3:14 AM Matthew Wilcox <willy@infradead.org> wrote:

> > In fact, the conversion I saw was buggy. You can *not* convert a
GFP_ATOMIC
> > user of kmalloc() to use kvmalloc.

> Not sure which conversion you're referring to; not one of mine, I hope?

I was thinking of the coccinelle patch in this thread, but just realized
that that actually only did it for GFP_KERNEL, so I guess it would work,
apart from the "oops, now it doesn't enforce the kmalloc limits any more"
issue.

> >   - that divide is really really expensive on many architectures.

> 'c' and 'size' are _supposed_ to be constant and get evaluated at
> compile-time.  ie you should get something like this on x86:

I guess that willalways  be true of the 'kvzalloc_struct() version that
will always use a sizeof(). I was more thinking of any bare kvalloc_ab_c()
cases, but maybe we'd discourage that to ever be used as such?

Because we definitely have things like that, ie a quick grep finds

    f = kmalloc (sizeof (*f) + size*num, GFP_KERNEL);

where 'size' is not obviously a constant. There may be others, but I didn't
really try to grep any further.

Maybe they aren't common, and maybe the occasional divide doesn't matter,
but particularly if we use scripting to then catch and convert users, I
really hate the idea of "let's introduce something that is potentially much
more expensive than it needs to be".

(And the automated coccinelle scripting it's also something where we must
very much avoid then subtly lifting allocation size limits)

> > Something like
> >
> >       if (size > PAGE_SIZE)
> >            return NULL;
> >       if (elem > 65535)
> >            return NULL;
> >       if (offset > PAGE_SIZE)
> >            return NULL;
> >       return kzalloc(size*elem+offset);
> >
> > and now you (a) guarantee it can't overflow and (b) don't make people
use
> > crazy vmalloc() allocations when they damn well shouldn't.

> I find your faith in the size of structs in the kernel touching ;-)

I *really* hope some of those examples of yours aren't allocated with
kmalloc using this pattern..

But yes, I may be naive on the sizes.

> We really have two reasons for using vmalloc -- one is "fragmentation
> currently makes it impossible to allocate enough contiguous memory
> to satisfy your needs" and the other is "this request is for too much
> memory to satisfy through the buddy allocator".  kvmalloc is normally
> (not always; see file descriptor example above) for the first kind of
> problem, but I wonder if kvmalloc() shouldn't have the same limit as
> kmalloc (2048 pages), then add a kvmalloc_large() which will not impose
> that limit check.

That would definitely solve at least one worry.

We do potentially have users which use kmalloc optimistically and do not
want to fall back to vmalloc (they'll fall back to smaller allocations
entirely), but I guess if fwe make sure to not convert any
__GFP_NOWARN/NORETRY users, that should all be ok.

But honestly, I'd rather see just kmalloc users stay as kmalloc users.

If instread of "kzvmalloc_ab_c()" you introduce the "struct size
calculation" part as a "saturating non-overflow calculation", then it
should be fairly easy to just do

   #define kzalloc_struct(p, member, n, gfp) \
      kzalloc(struct_size(p, member, n, gfp)

and you basically *know* that the only thing you changed was purely the
overflow semantics.

That also would take care of my diide worry, because now there  wouldn't be
any ab_c() calculations that might take a non-constant size. The
"struct_size()" thing would always do the sizeof.

So you'd have something like

   /* 'b' and 'c' are always constants */
   static inline sizeof_t __ab_c_saturating(size_t a, size_t b, size_t c)
   {
     if (b && n > (SIZE_MAX -c) / size)
         return SIZE_MAX;
     return a*b+c;
   }
   #define struct_size(p, member, n) \
       __ab_c_saturating(n, \
             sizeof(*(p)->member) + __must_be_array((p)->member), \
             offsetof(typeof(*(p)), member))

and then that kzalloc_struct() wrapper define above should just work.

The above is entirely untested, but it *looks* sane, and avoids all
semantic changes outside of the overflow protection. And nobody would use
that __ab_c_saturating() by mistake, I hope.

No?

               Linus
