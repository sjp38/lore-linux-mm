Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 46C688E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:15:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t24-v6so1004324eds.12
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:15:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1-v6sor3525938edf.9.2018.09.27.06.15.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 06:15:41 -0700 (PDT)
MIME-Version: 1.0
References: <1537944728-18036-1-git-send-email-kernelfans@gmail.com> <0100016616a8e4ba-fb8d5b4e-27cf-4f4f-b86c-a37d4e08a759-000000@email.amazonses.com>
In-Reply-To: <0100016616a8e4ba-fb8d5b4e-27cf-4f4f-b86c-a37d4e08a759-000000@email.amazonses.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 27 Sep 2018 21:15:29 +0800
Message-ID: <CAFgQCTtUGs6LkJBiZnH-kiOBUCuFpGEDX+ExvJbRTY6W5-Rh6g@mail.gmail.com>
Subject: Re: [PATCH] mm/slub: disallow obj's allocation on page with
 mismatched pfmemalloc purpose
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 27, 2018 at 12:14 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Wed, 26 Sep 2018, Pingfan Liu wrote:
>
> > -
> >       if (unlikely(!freelist)) {
> >               slab_out_of_memory(s, gfpflags, node);
> >               return NULL;
> >       }
> >
> > +     VM_BUG_ON(!pfmemalloc_match(page, gfpflags));
> >       page = c->page;
> > -     if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
> > +     if (likely(!kmem_cache_debug(s))
> >               goto load_freelist;
> >
> >       /* Only entered in the debug case */
> > -     if (kmem_cache_debug(s) &&
> > -                     !alloc_debug_processing(s, page, freelist, addr))
> > +     if (!alloc_debug_processing(s, page, freelist, addr))
> >               goto new_slab;  /* Slab failed checks. Next slab needed */
> > -
> > -     deactivate_slab(s, page, get_freepointer(s, freelist), c);
>
> In the debug case the slab needs to be deactivated. Otherwise the
> slowpath will not be used and debug checks on the following objects will
> not be done.
>
Got it.

Thanks,
Pingfan
