Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 460136B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 11:55:43 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o202so8766547itc.14
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 08:55:43 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id e90si479019iod.99.2017.07.06.08.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 08:55:42 -0700 (PDT)
Date: Thu, 6 Jul 2017 10:55:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: Add SLUB free list pointer obfuscation
In-Reply-To: <CAGXu5jKHkKgF90LXbFvrc3fa2PAaaaYHvCbiBM-9aN16TrHL=g@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org>
References: <20170706002718.GA102852@beast> <alpine.DEB.2.20.1707060841170.23867@east.gentwo.org> <CAGXu5jKHkKgF90LXbFvrc3fa2PAaaaYHvCbiBM-9aN16TrHL=g@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, 6 Jul 2017, Kees Cook wrote:

> On Thu, Jul 6, 2017 at 6:43 AM, Christoph Lameter <cl@linux.com> wrote:
> > On Wed, 5 Jul 2017, Kees Cook wrote:
> >
> >> @@ -3536,6 +3565,9 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
> >>  {
> >>       s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
> >>       s->reserved = 0;
> >> +#ifdef CONFIG_SLAB_FREELIST_HARDENED
> >> +     s->random = get_random_long();
> >> +#endif
> >>
> >>       if (need_reserve_slab_rcu && (s->flags & SLAB_TYPESAFE_BY_RCU))
> >>               s->reserved = sizeof(struct rcu_head);
> >>
> >
> > So if an attacker knows the internal structure of data then he can simply
> > dereference page->kmem_cache->random to decode the freepointer.
>
> That requires a series of arbitrary reads. This is protecting against
> attacks that use an adjacent slab object write overflow to write the
> freelist pointer. This internal structure is very reliable, and has
> been the basis of freelist attacks against the kernel for a decade.

These reads are not arbitrary. You can usually calculate the page struct
address easily from the address and then do a couple of loads to get
there.

Ok so you get rid of the old attacks because we did not have that
hardening in effect when they designed their approaches?

> It is a probabilistic defense, but then so is the stack protector.
> This is a similar defense; while not perfect it makes the class of
> attack much more difficult to mount.

Na I am not convinced of the "much more difficult". Maybe they will just
have to upgrade their approaches to fetch the proper values to decode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
