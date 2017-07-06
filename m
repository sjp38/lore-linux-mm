Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E68D6B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 12:16:40 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r4so10076113ith.7
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:16:40 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id m2si777439ite.9.2017.07.06.09.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 09:16:39 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id k3so1161623ita.3
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:16:39 -0700 (PDT)
Message-ID: <1499357796.1428.2.camel@gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH v3] mm: Add SLUB free list
 pointer obfuscation
From: Daniel Micay <danielmicay@gmail.com>
Date: Thu, 06 Jul 2017 12:16:36 -0400
In-Reply-To: <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org>
References: <20170706002718.GA102852@beast>
	 <alpine.DEB.2.20.1707060841170.23867@east.gentwo.org>
	 <CAGXu5jKHkKgF90LXbFvrc3fa2PAaaaYHvCbiBM-9aN16TrHL=g@mail.gmail.com>
	 <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, 2017-07-06 at 10:55 -0500, Christoph Lameter wrote:
> On Thu, 6 Jul 2017, Kees Cook wrote:
> 
> > On Thu, Jul 6, 2017 at 6:43 AM, Christoph Lameter <cl@linux.com>
> > wrote:
> > > On Wed, 5 Jul 2017, Kees Cook wrote:
> > > 
> > > > @@ -3536,6 +3565,9 @@ static int kmem_cache_open(struct
> > > > kmem_cache *s, unsigned long flags)
> > > >  {
> > > >       s->flags = kmem_cache_flags(s->size, flags, s->name, s-
> > > > >ctor);
> > > >       s->reserved = 0;
> > > > +#ifdef CONFIG_SLAB_FREELIST_HARDENED
> > > > +     s->random = get_random_long();
> > > > +#endif
> > > > 
> > > >       if (need_reserve_slab_rcu && (s->flags &
> > > > SLAB_TYPESAFE_BY_RCU))
> > > >               s->reserved = sizeof(struct rcu_head);
> > > > 
> > > 
> > > So if an attacker knows the internal structure of data then he can
> > > simply
> > > dereference page->kmem_cache->random to decode the freepointer.
> > 
> > That requires a series of arbitrary reads. This is protecting
> > against
> > attacks that use an adjacent slab object write overflow to write the
> > freelist pointer. This internal structure is very reliable, and has
> > been the basis of freelist attacks against the kernel for a decade.
> 
> These reads are not arbitrary. You can usually calculate the page
> struct
> address easily from the address and then do a couple of loads to get
> there.

You're describing an arbitrary read vulnerability: an attacker able to
read the value of an address of their choosing. Requiring a powerful
additional primitive rather than only a small fixed size overflow or a
weak use-after-free vulnerability to use a common exploit vector is
useful.

A deterministic mitigation would be better, but I don't think an extra
slab allocator for hardened kernels would be welcomed. Since there isn't
a separate allocator for that niche, SLAB or SLUB are used. The ideal
would be bitmaps in `struct page` but that implies another allocator,
using single pages for the smallest size classes and potentially needing
to bloat `struct page` even with that.

There's definitely a limit to the hardening that can be done for SLUB,
but unless forking it into a different allocator is welcome that's what
will be suggested. Similarly, the slab freelist randomization feature is
a much weaker mitigation than it could be without these constraints
placed on it. This is much lower complexity than that and higher value
though...

> Ok so you get rid of the old attacks because we did not have that
> hardening in effect when they designed their approaches?
> 
> > It is a probabilistic defense, but then so is the stack protector.
> > This is a similar defense; while not perfect it makes the class of
> > attack much more difficult to mount.
> 
> Na I am not convinced of the "much more difficult". Maybe they will
> just
> have to upgrade their approaches to fetch the proper values to decode.

To fetch the values they would need an arbitrary read vulnerability or
the ability to dump them via uninitialized slab allocations as an extra
requirement.

An attacker can similarly bypass the stack canary by reading them from
stack frames via a stack buffer read overflow or uninitialized variable
usage leaking stack data. On non-x86, at least with SMP, the stack
canary is just a global variable that remains the same after
initialization too. That doesn't make it useless, although the kernel
doesn't have many linear overflows on the stack which is the real issue
with it as a mitigation. Despite that, most people are using kernels
with stack canaries, and that has a significant performance cost unlike
these kinds of changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
