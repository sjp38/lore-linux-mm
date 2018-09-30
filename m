Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B20708E0001
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 05:34:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id v16-v6so8525266eds.1
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 02:34:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e46-v6sor10187901eda.24.2018.09.30.02.34.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Sep 2018 02:34:11 -0700 (PDT)
MIME-Version: 1.0
References: <1537944728-18036-1-git-send-email-kernelfans@gmail.com>
 <0100016616a8e4ba-fb8d5b4e-27cf-4f4f-b86c-a37d4e08a759-000000@email.amazonses.com>
 <CAFgQCTtUGs6LkJBiZnH-kiOBUCuFpGEDX+ExvJbRTY6W5-Rh6g@mail.gmail.com>
In-Reply-To: <CAFgQCTtUGs6LkJBiZnH-kiOBUCuFpGEDX+ExvJbRTY6W5-Rh6g@mail.gmail.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Sun, 30 Sep 2018 17:33:59 +0800
Message-ID: <CAFgQCTtXQkiyr5GJuw1u8J0aW-B8ig_=PKyZCknktYB_rj4TEA@mail.gmail.com>
Subject: Re: [PATCH] mm/slub: disallow obj's allocation on page with
 mismatched pfmemalloc purpose
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 27, 2018 at 9:15 PM Pingfan Liu <kernelfans@gmail.com> wrote:
>
> On Thu, Sep 27, 2018 at 12:14 AM Christopher Lameter <cl@linux.com> wrote:
> >
> > On Wed, 26 Sep 2018, Pingfan Liu wrote:
> >
> > > -
> > >       if (unlikely(!freelist)) {
> > >               slab_out_of_memory(s, gfpflags, node);
> > >               return NULL;
> > >       }
> > >
> > > +     VM_BUG_ON(!pfmemalloc_match(page, gfpflags));
> > >       page = c->page;
> > > -     if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
> > > +     if (likely(!kmem_cache_debug(s))
> > >               goto load_freelist;
> > >
> > >       /* Only entered in the debug case */
> > > -     if (kmem_cache_debug(s) &&
> > > -                     !alloc_debug_processing(s, page, freelist, addr))
> > > +     if (!alloc_debug_processing(s, page, freelist, addr))
> > >               goto new_slab;  /* Slab failed checks. Next slab needed */
> > > -
> > > -     deactivate_slab(s, page, get_freepointer(s, freelist), c);
> >
> > In the debug case the slab needs to be deactivated. Otherwise the
> > slowpath will not be used and debug checks on the following objects will
> > not be done.
> >
After taking a more closely look at the debug code, I consider whether
the alloc_debug_processing() can be also called after get_freelist(s,
page), then deactivate_slab() is not required . My justification is
the debug code will take the same code path as the non-debug,  hence
the page will experience the same transition on different list like
the non-debug code, and help to detect the bug, also it will improve
scalability on SMP.
Besides this, I found the debug code is not scalable well, is it worth
to work on it?

Thanks,
Pingfan
