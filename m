Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA02001
	for <linux-mm@kvack.org>; Tue, 18 Aug 1998 17:38:49 -0400
From: Linus Torvalds <torvalds@transmeta.com>
Date: Tue, 18 Aug 1998 14:38:07 -0700
Message-Id: <199808182138.OAA00489@penguin.transmeta.com>
Subject: Re: Notebooks
References: <19980814115843.43989@orci.com> <m0z88bh-000aNFC@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
To: alan@lxorguk.ukuu.org.uk, davem@dm.cobaltmicro.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In article <m0z88bh-000aNFC@the-village.bc.nu>,
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>> We really gotta stop calling them "unstable" as they're not.  They're
>> developemental.  Miy firewall's running 2.1.10X and it's been up amost
>> 2 months I think.  My desktop is 2.1.115 and the only reason I rebootyed
>> it was to install that instead of 2.1.110...
>
>Squid on 2.1.115 (with or without ac1) lasts 60 seconds on my soak test
>before it explodes. Ditto a lot of other high load tests that touch I/O
>or VM hard. (Note Im guessing where it dies here). Some of 2.1.x is rock
>solid, and some bits of it are solid in non extreme use, but 2.1.x is
>not remotely stable for real world hard use yet. Its getting there bit
>by bit

Ok, I found this.

Once more, it was the slab stuff that broke badly.  I'm going to
consider just throwing out the slabs for v2.2 unless somebody is willing
to stand up and fix it - the multi-page allocation stuff just breaks too
horribly. 

In this case, TCP wanted to allocate a single skb, and due to slabs this
got turned into a multi-page request even though it fit perfectly fine
into one page.  Thus a critical allocation could fail, and the TCP layer
started looping - and kswapd could never even try to fix it up because
the TCP code held the kernel lock. 

I'm going to fix this particular case even with slabs, but this isn't
the first time the slabs "optimizations" have just broken code that used
to work fine by making it a high-order allocation.  Essentially, the
slabsified kmalloc() is just a lot more fragile than the original
kmalloc() was. 

(This also shows a particularly nasty inefficiency - the TCP code
explicitly tries to have a "good" MTU for loopback, and it's meant to
fit in a single page.  The slab code makes it fail miserably in that
objective). 

All sane architectures are moving to at least 2-way caches and the good
ones are 4-way or more. As such, slabs optimizes for the wrong case.

			Linus
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
