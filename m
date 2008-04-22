Date: Tue, 22 Apr 2008 05:23:19 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2]: introduce fast_gup
Message-ID: <20080422032319.GB21993@wotan.suse.de>
References: <20080328025455.GA8083@wotan.suse.de> <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins> <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org> <480C81C4.8030200@qumranet.com> <1208781013.7115.173.camel@twins> <480C9619.2050201@qumranet.com> <1208788547.7115.204.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1208788547.7115.204.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Avi Kivity <avi@qumranet.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 21, 2008 at 04:35:47PM +0200, Peter Zijlstra wrote:
> On Mon, 2008-04-21 at 16:26 +0300, Avi Kivity wrote:
> > Peter Zijlstra wrote:
> > > On Mon, 2008-04-21 at 15:00 +0300, Avi Kivity wrote:
> > >   
> > >> Linus Torvalds wrote:
> > >>     
> > >>> Finally, I don't think that comment is correct in the first place. It's 
> > >>> not that simple. The thing is, even *with* the memory barrier in place, we 
> > >>> may have:
> > >>>
> > >>> 	CPU#1			CPU#2
> > >>> 	=====			=====
> > >>>
> > >>> 	fast_gup:
> > >>> 	 - read low word
> > >>>
> > >>> 				native_set_pte_present:
> > >>> 				 - set low word to 0
> > >>> 				 - set high word to new value
> > >>>
> > >>> 	 - read high word
> > >>>
> > >>> 				- set low word to new value
> > >>>
> > >>> and so you read a low word that is associated with a *different* high 
> > >>> word! Notice?
> > >>>
> > >>> So trivial memory ordering is _not_ enough.
> > >>>
> > >>> So I think the code literally needs to be something like this
> > >>>
> > >>> 	#ifdef CONFIG_X86_PAE
> > >>>
> > >>> 	static inline pte_t native_get_pte(pte_t *ptep)
> > >>> 	{
> > >>> 		pte_t pte;
> > >>>
> > >>> 	retry:
> > >>> 		pte.pte_low = ptep->pte_low;
> > >>> 		smp_rmb();
> > >>> 		pte.pte_high = ptep->pte_high;
> > >>> 		smp_rmb();
> > >>> 		if (unlikely(pte.pte_low != ptep->pte_low)
> > >>> 			goto retry;
> > >>> 		return pte;
> > >>> 	}
> > >>>
> > >>>   
> > >>>       
> > >> I think this is still broken.  Suppose that after reading pte_high 
> > >> native_set_pte() is called again on another cpu, changing pte_low back 
> > >> to the original value (but with a different pte_high).  You now have 
> > >> pte_low from second native_set_pte() but pte_high from the first 
> > >> native_set_pte().
> > >>     
> > >
> > > I think the idea was that for user pages we only use set_pte_present()
> > > which does the low=0 thing first.
> > >   
> > 
> > Doesn't matter.  The second native_set_pte() (or set_pte_present()) 
> > executes atomically:
> > 
> > 
> > 	fast_gup:
> > 	 - read low word (l0)
> > 
> > 				native_set_pte_present:
> > 				 - set low word to 0
> > 				 - set high word to new value (h1)
> > 	 			 - set low word to new value (l1)
> >  
> > 
> > 	 - read high word (h1)
> > 
> > 				native_set_pte_present:
> > 				 - set low word to 0
> > 				 - set high word to new value (h2)
> > 	 			 - set low word to new value (l2)
> > 
> >    	 - re-read low word (l2)
> > 
> > 
> > If l2 happens to be equal to l0, then the check succeeds and we have a 
> > splintered pte h1:l0.
> 
> ok, so lets use cmpxchg8.

That's horrible ;)

Anyway guys you are missing the other side of the equation -- that whenever
_PAGE_PRESENT is cleared, all CPUs where current->mm might be == mm have to
have a tlb flush. And we're holding off tlb flushes in fast_gup, that's the
whole reason why it all works.

Indeed we do need Linus's loop, though, because I wasn't thinking of the
teardown side when writing that comment it seems (teardowns under
mmu_gather can and do set the pte to some arbitrary values before the
IPI goes out -- but they will never contain _PAGE_PRESENT we can be sure).

Linus's loop I will use for PAE. I'd love to know whether the hardware
walker actually does an atomic 64-bit load or not, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
