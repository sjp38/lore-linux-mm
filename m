Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA19075
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 18:20:31 -0500
Date: Mon, 23 Mar 1998 15:20:11 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Lazy page reclamation on SMP machines: memory barriers
In-Reply-To: <199803232249.WAA02431@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980323151332.431D-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org, linux-smp@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>



On Mon, 23 Mar 1998, Stephen C. Tweedie wrote:
>
> Are there barrier constructs available to do this?  I believe the answer
> to be no, based on the recent thread concerning the use of inline asm
> cpuid instructions as a barrier on Intel machines.  Alternatively, does
> Intel provide any ordering guarantees which may help?

Intel only gives you total ordering across certain instructions (cpuid
being one of them, and the only one that is easily usable under all
circumstances). 

> Finally, I looked quickly at the kernel's spinlock primitives, and they
> also seem unprotected by memory barriers on Intel.  Is this really safe?

Yes. Intel guarantees total ordering around any locked instruction, so the
spinlocks themselves act as the barriers. This is why "unlock" is a slow

	lock ; btrl $0,(mem) 

instead of the much faster

	movl $0,(mem) 

because the latter doesn't imply any ordering, and there are no faster
ways to do it (cpuid is fairly slow, so trying to do a "movl + cpuid" 
doesn't help either). 

The intel ordering is really nasty, because there is no good fast
synchronization. "cpuid" trashes half the register set, and all the other
synchronizing instructions have other even nastier side effects. And there
is nothing like the alpha (and others) "write memory barrier" instruction
that does only a one-way barrier.

(To be fair, the alpha for example has very nice primitives for SMP, but
sometimes the implementation of them is horribly slow. For example, the
"load-and-protect" thing always seems to go to the bus even when the CPU
has exclusive ownership, which makes atomic sequences much more expensive
than they should be. I think DEC fixed this in their later alpha's, but
the point being that even when you have the right concepts you can mess up
with having a bad implementation ;) 

		Linus
