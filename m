Date: Sat, 18 Oct 2008 10:00:30 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081018054916.GB26472@wotan.suse.de>
Message-ID: <alpine.LFD.2.00.0810180921140.3438@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810172300280.30871@blonde.site> <alpine.LFD.2.00.0810171549310.3438@nehalem.linux-foundation.org> <Pine.LNX.4.64.0810180045370.8995@blonde.site> <20081018015323.GA11149@wotan.suse.de>
 <18681.20241.347889.843669@cargo.ozlabs.ibm.com> <20081018054916.GB26472@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Paul Mackerras <paulus@samba.org>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sat, 18 Oct 2008, Nick Piggin wrote:
> 
> I think it can be called transitive. Basically (assumememory starts off zeroed)

Alpha is transitive. It has a notion of "processor issue order" and 
"location access order", and the ordering those two creates is a 
transitive "before" and "after" ordering.

The issue with alpha is not that it wouldn't be transitive - the issue is 
that *local* read dependencies do not cause a "processor issue order"!

So the real issue with alpha is not about any big pair-wise ordering vs 
transitive thing, the big issue is that alpha's totally _local_ and 
per-core orderings are so totally screwed up, and are defined to be very 
loose - because back when alpha was designed, loose memory ordering was 
thought to be a good thing for performance.

They were wrong, but that was mainly because the alpha designers lived in 
a time when threading wasn't really even an issue. They were optimizing 
purely for the case where memory ordering doesn't matter, and considered 
locking etc to be one of those non-RISCy rare operations that can be 
basically ignored.

> CPU0
> x := 1

So this creates a "location access" event on 'x' on alpha, call it "event 
A".

> CPU1
> if (x == 1) {
>   fence
>   y := 1
> }

This has two events: let's call the read of 'x' "B", and "C" is the write 
to 'y'.

And according to the alpha rules, we now have:

 - A << B

   Because we saw a '1' in B, we now have a "location access ordering" 
   on the _same_ variable between A and B.

 - B < C

   Because we have the fence in between the read and the write, we now 
   have a "processor issue order" between B and C (despite the fact that 
   they are different variables).

And now, the alpha definition of "before" means that we can declare that A 
is before C.

But on alpha, we really do need that fence, even if the address of 'y' was 
somehow directly data-dependent on 'x'. THAT is what makes alpha special, 
not any odd ordering rules.

> CPU2
> if (y == 1) {
>   fence
>   assert(x == 1)
> }

So again, we now have two events: the access of 'y' is "D", and the access 
of x is "E". And again, according to the alpha rules, we have two 
orderings:

 - C << D

   Because we saw a '1' in D, we have another "location access ordering" 
   on the variably 'y' between C and D.

 - D < E

   Because of the fence, we have a "processor issue ordering" between D 
   and E.

And for the same reason as above, we now get that C is "before" E 
according to the alpha ordering rules. And because the definition of 
"before" is transitive, then A is before E.

And that, in turn, means that that assert() can never trigger, because if 
it triggered, then by the access ordering rules that would imply that E << 
A, which would mean that E is "before" A, which in turn would violate the 
whole chain we just got to.

So while the alpha architecture manual doesn't have the exact sequence 
mentioned above (it only has nine so-called "Litmus tests"), it's fairly 
close to Litmus test 3, and the ordering on alpha is very clear: it's all 
transitive and causal (ie "before" can never be "after").

> Apparently pairwise ordering is more interesting than just a theoretical
> thing, and not just restricted to Alpha's funny caches.

Nobody does just pairwise ordering, afaik. It's an insane model. Everybody 
does some form of transitive ordering.

The real (and only really odd) issue with alpha is that for everybody 
else, if you have

	read x -> data dependency -> read y

(ie you read a pointer and dereference it, or you read an index and 
dereference an array through it), then on all other architectures that 
will imply a local processor ordering, which in turn will be part of the 
whole transitive order of operations. 

On alpha, it doesn't. You can think of it as alpha doing value speculation 
(ie allowing speculative reads even across data dependencies), so on 
alpha, you could imagine a CPU doing address speculation, and turning the 
two reads into a sequence of

 (a) read off speculative pointer '*p'
 (b) read x
 (c) verify that that x == p

and THAT is what "smp_read_barrier_depends()" will basically stop on 
alpha. Nothing else. Other CPU's will always basically do

 (a) read x
 (b) read *x

so they have an implied read barrier between those two events thanks to 
simply the causal relationship.

Some more notes:

 - The reason that alpha has this odd thing is not actually that any alpha 
   implementation does value speculation, but the way the caches are 
   invalidated, the invalidates can be delayed and re-ordered almost 
   arbitrarily on the local CPU, and in the absense of a memory barrier 
   the second read (that does happen "after" the first read in some local 
   internal CPU sense and wasn't really speculative in that way) can get 
   stale data because one cacheline has been updated before another one 
   has.

   So while you can think of it a value speculation, the underlying cause 
   is actually not some fancy speculation infrastructure, just an internal 
   implementation issue.

 - The _data_ dependency is important, because other architectures _will_ 
   still speculatively move memory operations around across other "causal" 
   relationships, notably across control dependencies. IOW, if you have

	if (read(x))
		read(y)

   then there is NOT necessarily any real orderign between the reads, 
   because the conditional ends up being speculated, and you may well see 
   "y" being read before "x", and you really need a smp_rmb() on other 
   architectures than alpha too. So in this sense, alpha is very 
   "consistent" - for alpha, _no_ amount of local causality matters, and 
   only accesses to the *same* variable are implicitly locally ordered.

 - On x86, the new memory ordering semantics means that _all_ local causal 
   relationships are honored, so x86, like alpha, is very consistent. It 
   will consider both the data-dependency and the control dependency to be 
   100% the same. It just does it differently than alpha: for alpha, 
   neither matters for ordering, for x86, both matter.

Of course, even on x86, the local causal relationships still do allow 
loads to pass stores, so x86 isn't _totally_ ordered. x86 obviously still 
does need the smp_mb().

So alpha is "more consistent" in the respect of really having very clear 
rules. The fact that those "clear rules" are totally insane and very 
inconvenient for threading (and weren't the big performance advantage that 
people used to think they would be) is a separate matter.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
