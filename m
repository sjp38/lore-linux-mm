Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA19162
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 18:37:30 -0500
Date: Mon, 23 Mar 1998 15:37:08 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Lazy page reclamation on SMP machines: memory barriers
In-Reply-To: <199803232249.WAA02431@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980323152209.431E-100000@penguin.transmeta.com>
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

Just a quick follow-up with more intel-specific information in case people
care. The serializing instructions (intel-speak for "read and write memory
barrier") are:

Privileged (and all of these are too slow to really consider):
 - mov to control register
 - mov to debug register
 - wrmsr, invd, invlpg, winvd, lgdt, lldt, lidt, ltr

Non-privileged:
 - CPUID, IRET, RSM (and only CPUID is really usable for serialization)

In addition, any locked instruction (or xchg, which is implicitly locked) 
will "wait for all previous instructions to complete, and for the store
buffer to drain to memory". That, together with the rule that reads cannot
pass locked instructions, essentially makes all locked instructions
serialized (they _are_ serialized as far as memory ordering goes, but
intel seems to use the term "serialized" for both memory ordering and for
"internal CPU behaviour": in intel-speak a "real" serializing instruction
will apparently also wait for the CPU pipeline to drain). 

The cheapest way (considering register usage etc) to get a serializing
instruction _seems_ to be to use something like

	lock ; add $0,0(%esp)

which will act as a read and write barrier, but won't actually drain the
pipe completely (and won't trash any registers - and the stack is likely
to be dirty and cached, so it won't generate any extra memory traffic
except on a Pentium where the "lock" thing cannot work on the cache).

		Linus
