Message-ID: <480C81C4.8030200@qumranet.com>
Date: Mon, 21 Apr 2008 15:00:04 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2]: introduce fast_gup
References: <20080328025455.GA8083@wotan.suse.de>  <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins> <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> Finally, I don't think that comment is correct in the first place. It's 
> not that simple. The thing is, even *with* the memory barrier in place, we 
> may have:
>
> 	CPU#1			CPU#2
> 	=====			=====
>
> 	fast_gup:
> 	 - read low word
>
> 				native_set_pte_present:
> 				 - set low word to 0
> 				 - set high word to new value
>
> 	 - read high word
>
> 				- set low word to new value
>
> and so you read a low word that is associated with a *different* high 
> word! Notice?
>
> So trivial memory ordering is _not_ enough.
>
> So I think the code literally needs to be something like this
>
> 	#ifdef CONFIG_X86_PAE
>
> 	static inline pte_t native_get_pte(pte_t *ptep)
> 	{
> 		pte_t pte;
>
> 	retry:
> 		pte.pte_low = ptep->pte_low;
> 		smp_rmb();
> 		pte.pte_high = ptep->pte_high;
> 		smp_rmb();
> 		if (unlikely(pte.pte_low != ptep->pte_low)
> 			goto retry;
> 		return pte;
> 	}
>
>   

I think this is still broken.  Suppose that after reading pte_high 
native_set_pte() is called again on another cpu, changing pte_low back 
to the original value (but with a different pte_high).  You now have 
pte_low from second native_set_pte() but pte_high from the first 
native_set_pte().

You could use cmpxchg8b to atomically load the pte, but at the expense 
of taking the cacheline for exclusive access.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
