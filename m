Message-ID: <48DAC285.80507@goop.org>
Date: Wed, 24 Sep 2008 15:43:17 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: PTE access rules & abstraction
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>	 <1222117551.12085.39.camel@pasglop>	 <Pine.LNX.4.64.0809241919520.575@blonde.site>	 <1222291248.8277.90.camel@pasglop>  <48DAB7E2.5030009@goop.org> <1222294041.8277.104.camel@pasglop>
In-Reply-To: <1222294041.8277.104.camel@pasglop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Chubb <peterc@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
>> What do you propose then?  Ideally one would like to get something that
>> works for powerpc, s390, all the wacky ia64 modes as well as x86.  The
>> ia64 folks proposed something, but I've not looked at it closely.  From
>> an x86 virtualization perspective, something that's basically x86 with
>> as much scope for batching and deferring as possible would be fine.
>>     
>
> That's where things get interesting. I liked Nick ideas of doing
> something transactional that could encompass the lock, bach and flushing
> but that may be too much at this stage...
>   

Yes, that sounds fine in principle, but the practise gets tricky.  The
trouble with that kind of interface is that it can be fairly heavyweight
unless you amortise the cost of the transaction setup/commit with
multiple operations.

>> ptep_get_and_clear() is not batchable anyway, because the x86
>> implementation requires an atomic xchg on the pte, which will likely
>> result in some sort of trap (and if it doesn't then it doesn't need
>> batching).
>>     
>
> Well, ptep_get_and_clear() used to be used by zap_pte_range() which I
> _HOPE_ was batchable on x86 :-)
>
> Nowadays, there's this new ptep_get_and_clear_full() (yet another
> totally meaningless name for an ad-hoc API added for some random special
> purpose) that zap_pte_range() uses. Maybe that one is now subtly
> different such as it can be used to batch on x86 ?
>   

Yeah.  zap_pte_range isn't great when doing a munmap, but the _full gunk
lets it special-case process teardown and it ends up not being a
performance problem (in the Xen case, we've already switch to another
pagetable at that point, so it isn't really a pagetable any more and
needs no hypercalls).

> In any case, powerpc batches -everything- (unless it's called *_flush in
> which case the flush is immediate) in a private per-cpu batch and
> flushes the hash when leaving lazy mode.
>   

Are you using the lazy_mmu hooks we put in, or something else?

>>   The start/commit API was specifically so that we can do the
>> mprotect (and fork COW updates) in a batchable way (in Xen its
>> implemented with a pte update hypercall which updates the pte without
>> affecting the A/D bits).
>>     
>
> I think we have different ideas of what batch means but yeah, we do
> batch everything including these on powerpc without the new start/commit
> interface.

Likely; it's one of those overused generic words.  The specific meaning
I'm using is "we can roll a bunch of updates into a single hypercall". 
Operations which do atomic RMW  or fetch-set are typically not batchable
because the caller wants the result *now* and can't wait for a deferred
result.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
