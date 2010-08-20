Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EFE766B0338
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 10:38:33 -0400 (EDT)
Subject: Re: [RFC][PATCH 0/6] mm, highmem: kmap_atomic rework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100819143129.81274c03.akpm@linux-foundation.org>
References: <20100819201317.673172547@chello.nl>
	 <20100819143129.81274c03.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 20 Aug 2010 16:38:12 +0200
Message-ID: <1282315092.2605.1134.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-08-19 at 14:31 -0700, Andrew Morton wrote:
> On Thu, 19 Aug 2010 22:13:17 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>=20
> >=20
> > This patch-set reworks the kmap_atomic API to be a stack based, instead=
 of
> > static slot based. Some might remember this from last year, some not ;-=
)
> >=20
> > The advantage is that you no longer need to worry about KM_foo, the
> > disadvantage is that kmap_atomic/kunmap_atomic now needs to be strictly
> > nested (CONFIG_HIGHMEM_DEBUG should complain in case its not) -- and of
> > course its a big massive patch changing a widely used API.
>=20
> Nice.  That fixes the "use of irq-only slots from interrupts-on
> context" bugs which people keep adding.

Ah, I should add a:

  WARN_ON_ONCE(in_irq() && !irqs_disabled());

like check to ensure people don't use kmap_atomic() in nestable IRQ
contexts (nestable IRQ context is bad anyway) the old debug code I
deleted did something similar.

> We don't have any checks in there for the stack overflowing?

+#ifdef CONFIG_DEBUG_HIGHMEM
+       BUG_ON(idx > KM_TYPE_NR);
+#endif

Seems to be that.

> Did you add every runtime check you could possibly think of?=20
> kmap_atomic_idx_push() and pop() don't have much in there.  It'd be
> good to lard it up with runtime checks for at least a few weeks.

Right, so I currently have:

 - stack size check in push/pop
 - proper nesting check in pop (verifies that the vaddr you try to
   unmap is indeed the top most on the stack)

Aside from the proposed no irq-nesting thing to avoid unbounded
recursion I can't really come up with more creative abuse.

> Well, there's that monster conversion patch.  How's about you
> temporarily do
>=20
> #define kmap_atomic(x, arg...)  __kmap_atomic(x)
>=20
> so for a while, both kmap_atomic(a, KM_foo) and kmap_atomic(a) are
> turned into __kmap_atomic(a).  Once all the dust has settled, pull that
> out again?

Ah, that's a nifty trick, let me try that.=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
