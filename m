Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB88830A3
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 13:42:11 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m130so68600234ioa.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:42:11 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id d42si2159425otd.273.2016.08.18.10.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 10:42:10 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id s207so4372594oie.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:42:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1471530118.2581.13.camel@redhat.com>
References: <20160817222921.GA25148@www.outflux.net> <1471530118.2581.13.camel@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 18 Aug 2016 10:42:09 -0700
Message-ID: <CA+55aFxYHn+4jJP89Pv=mKSKeKR+zkuJbZc8TSj6kORDUD1Qqw@mail.gmail.com>
Subject: Re: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kernel test robot <xiaolong.ye@intel.com>

On Thu, Aug 18, 2016 at 7:21 AM, Rik van Riel <riel@redhat.com> wrote:
>
> One big question I have for Linus is, do we want
> to allow code that does a higher order allocation,
> and then frees part of it in smaller orders, or
> individual pages, and keeps using the remainder?

Yes. We've even had people do that, afaik. IOW, if you know you're
going to allocate 16 pages, you can try to do an order-4 allocation
and just use the 16 pages directly (but still as individual pages),
and avoid extra allocation costs (and to perhaps get better access
patterns if the allocation succeeds etc etc).

That sounds odd, but it actually makes sense when you have the order-4
allocation as a optimistic path (and fall back to doing smaller orders
when a big-order allocation fails). To make that *purely* just an
optimization, you need to let the user then treat that order-4
allocation as individual pages, and free them one by one etc.

So I'm not sure anybody actually does that, but the buddy allocator
was partly designed for that case.

> From both a hardening and a simple stability
> point of view, allowing memory to be allocated
> in one size, and freed in another, seems like
> it could be asking for bugs.

Quite frankly, I'd much rather instead make a hard rule that "user
copies can never be more than one page".

There are *very* few things that actually have bigger user copies, and
we could make those explicitly loop, or mark them as such.

The single-page size limit is fairly natural because of how both our
page cache and our pathname limiting is limited to single pages.

The only thing that generally isn't a single page tends to be:

 - module loading code with vmalloc destination

   We *already* chunk that for other reasons, although we ended up
making the chunk size be 16 pages. Making it a single page wouldn't
really hurt anything.

 - we probably have networking cases that might have big socket buffer
allocations etc.

 - there could be some very strange driver, but we'd find them fairly
quickly if we just start out with making th ecopy_from/to_user()
callers just unconditionally have a

     WARN_ON_ONCE((len) > PAGE_SIZE);

  and not making it fatal, but making it easy to find.

Anyway, I think *that* would be a much easier rule to start with than
worrying about page crossing.

Yes, page crossing can be nasty, and maybe we can try to aim for that
in the future (and mark things that the FPU saving special, because it
really is very very unusual), but I'd actually prefer the 4kB rule
first because that would also allow us to just get rid of the odd
vmalloc special cases etc in the checking.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
