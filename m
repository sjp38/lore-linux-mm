Subject: Re: [RFC/PATCH] Use mmu_gather for fork() instead of flush_tlb_mm()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <46920B7D.5090100@yahoo.com.au>
References: <1183952874.3388.349.camel@localhost.localdomain>
	 <1183962981.5961.3.camel@localhost.localdomain>
	 <1183963544.5961.6.camel@localhost.localdomain>
	 <4691E64F.5070506@yahoo.com.au>
	 <1183972349.5961.25.camel@localhost.localdomain>
	 <4691FFDC.5020808@yahoo.com.au>
	 <1183974458.5961.42.camel@localhost.localdomain>
	 <46920A0C.3040400@yahoo.com.au>  <46920B7D.5090100@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 09 Jul 2007 22:37:08 +1000
Message-Id: <1183984629.5961.68.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> To elaborate on this one... I realise for this one that in the kernel
> where this is currently used everything is non-preemptible anyway
> because of the ptl. And I also realise that -rt kernel issues don't
> really have a bearing on mainline kernel.. but the generic
> implementation of this API is fundamentally used to operate on a
> per-cpu data structure that is only required when tearing down page
> tables. That makes this necessarily non-preemptible.
> 
> Which shows that it adds more restrictions that may not otherwise be
> required.

Yes, it's a bit annoying but not necessarily that bad. In fact, we don't
have to make it non-preemptible, we did it because it was easier that way
I strongly suspect. In fact, the batch could actually be attached to the
mm rather than the CPU for that matter, no ? Or is there a fudamental
reason I'm not seeing why it -has- to be per-cpu ?

> > has to look in there and touch the cacheline. You're also having to
> > do more work when unlocking/relocking the ptl etc.
> > 
> > 
> >> I really think it's the right API
> 
> OK, the *form* of the API is fine, I have no arguments. I just don't
> know why you have to reuse the same thing. If you provided a new set of
> names then you can trivially do a generic implementation which compiles
> to exactly the same code for all architectures right now. That seems to
> me like the right way to go...

But that means two different APIs for almost the same thing. I'm trying
to clean up the mess, not add more :-) Beside, that "other" API would
have overall much of the same issues no ? Or do you want to have that
"other" API not actually provide a percpu "mmu_gather" type structure at
all in asm-generic (but basically just boil down to an empty inline for
creating the "other" batch and flush_tlb_mm() for finishing it with an
empty inline for "adding" a PTE to the list of invalidation targets ?)

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
