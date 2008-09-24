Subject: Re: PTE access rules & abstraction
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <48DAB7E2.5030009@goop.org>
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>
	 <1222117551.12085.39.camel@pasglop>
	 <Pine.LNX.4.64.0809241919520.575@blonde.site>
	 <1222291248.8277.90.camel@pasglop>  <48DAB7E2.5030009@goop.org>
Content-Type: text/plain
Date: Thu, 25 Sep 2008 08:07:21 +1000
Message-Id: <1222294041.8277.104.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Chubb <peterc@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

> What do you propose then?  Ideally one would like to get something that
> works for powerpc, s390, all the wacky ia64 modes as well as x86.  The
> ia64 folks proposed something, but I've not looked at it closely.  From
> an x86 virtualization perspective, something that's basically x86 with
> as much scope for batching and deferring as possible would be fine.

That's where things get interesting. I liked Nick ideas of doing
something transactional that could encompass the lock, bach and flushing
but that may be too much at this stage...

> As a start, what's the state machine for a pte?  What states can it be
> in, and how does it move from state to state?  It sounds like powerpc
> has at least one extra state above x86 (hashed, with the hash key stored
> in the pte itself?).

We store in the PTE whether it was hashed, and the location within a
hash bucket. (For each hash value, there's 8 buckets, or rather 16 if
you count our secondary hashing).

We must never write a new valid PTE after we cleared a hashed one
without having a flush in between.

On 32 bits we have less state (only the 'hashed' bit) but the problem is
similar, though we handle it differently: we never clear the hash bit
until we flush the hash, ie, pte_clear doesn't clear the hash bit. On
64-bit we do things differently, we do clear PTEs and pile up in a
per-cpu batch what needs to be flushed, the flush then happens when
leaving lazy mode.

> ptep_get_and_clear() is not batchable anyway, because the x86
> implementation requires an atomic xchg on the pte, which will likely
> result in some sort of trap (and if it doesn't then it doesn't need
> batching).

Well, ptep_get_and_clear() used to be used by zap_pte_range() which I
_HOPE_ was batchable on x86 :-)

Nowadays, there's this new ptep_get_and_clear_full() (yet another
totally meaningless name for an ad-hoc API added for some random special
purpose) that zap_pte_range() uses. Maybe that one is now subtly
different such as it can be used to batch on x86 ?

In any case, powerpc batches -everything- (unless it's called *_flush in
which case the flush is immediate) in a private per-cpu batch and
flushes the hash when leaving lazy mode.

>   The start/commit API was specifically so that we can do the
> mprotect (and fork COW updates) in a batchable way (in Xen its
> implemented with a pte update hypercall which updates the pte without
> affecting the A/D bits).

I think we have different ideas of what batch means but yeah, we do
batch everything including these on powerpc without the new start/commit
interface.

Ben.

>     J
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
