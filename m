Message-ID: <48DAB7E2.5030009@goop.org>
Date: Wed, 24 Sep 2008 14:57:54 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: PTE access rules & abstraction
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>	 <1222117551.12085.39.camel@pasglop>	 <Pine.LNX.4.64.0809241919520.575@blonde.site> <1222291248.8277.90.camel@pasglop>
In-Reply-To: <1222291248.8277.90.camel@pasglop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Chubb <peterc@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> Well, the current set accessor, as far as I'm concerned is a big pile of
> steaming shit that evolved from x86-specific gunk raped in different
> horrible ways to make it looks like it fits on other architectures and
> additionally mashed with goo to make it somewhat palatable by
> virtualization stuff. Yes, bugs can be fixed but it's still an horrible
> mess.
>   

What do you propose then?  Ideally one would like to get something that
works for powerpc, s390, all the wacky ia64 modes as well as x86.  The
ia64 folks proposed something, but I've not looked at it closely.  From
an x86 virtualization perspective, something that's basically x86 with
as much scope for batching and deferring as possible would be fine.

As a start, what's the state machine for a pte?  What states can it be
in, and how does it move from state to state?  It sounds like powerpc
has at least one extra state above x86 (hashed, with the hash key stored
in the pte itself?).

> Now, regarding the above bug, I'm afraid the only approaches I see that
> would work would be to have either a ptep_get_and_clear_flush(), which I
> suppose x86 virt. people will hate, or maybe to actually have a powerpc
> specific variant of the new start/commit hooks that does the flush.
>   

ptep_get_and_clear() is not batchable anyway, because the x86
implementation requires an atomic xchg on the pte, which will likely
result in some sort of trap (and if it doesn't then it doesn't need
batching).  The start/commit API was specifically so that we can do the
mprotect (and fork COW updates) in a batchable way (in Xen its
implemented with a pte update hypercall which updates the pte without
affecting the A/D bits).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
