Date: Sun, 15 Dec 2002 09:41:02 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: freemaps
In-Reply-To: <3DFBF26B.47C04A6@digeo.com>
Message-ID: <Pine.LNX.4.44.0212150926130.1831-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Frederic Rossi (LMC)" <Frederic.Rossi@ericsson.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 14 Dec 2002, Andrew Morton wrote:

> So this is the key part.  It is a per-mm linear list of unmapped areas.

yep.

> As this is a linear list, I do not understand why it does not have
> similar failure modes to the current search.  Suppose this list
> describes 100,000 4k unmapped areas and the application requests an 8k
> mmap??

i bet because in the (artificial?) test presented the 'hole' distribution
is much nicer than the 'allocated areas' distribution. There are real-life
allocation patterns, where this scheme suffers the same kind of regression
the old scheme suffered. Eg. the one i presented originally, which
triggered a regression, the NPTL stack allocator, where there is a 4K
unmapped area between thread stacks. Under that workload the
freemap-patched kernel will suffer badly over 2.5.50.

but the hole-index might in fact be a quality improvement in a number of
cases. It wont save us in a number of other cases, but one thing is sure:
holes do not have types, allocated vmas have. So the complexity of the
hole-space will always be at least as low as the complexity of the
allocated-area-space. If there are lots of vmas of different types then
the complexity of the hole-space can be significantly lower than the
complexity of the vma-space. This happens quite often.

a hybrid approach would keep both improvements: take the hole index _plus_
the free-area cache i introduced, and if there's a cachemiss, search the
hole-list.

another approach might be to maintain some sort of tree of holes.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
