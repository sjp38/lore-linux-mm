Date: Sun, 19 Oct 2008 04:53:37 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081019025337.GB16562@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810172300280.30871@blonde.site> <alpine.LFD.2.00.0810171549310.3438@nehalem.linux-foundation.org> <Pine.LNX.4.64.0810180045370.8995@blonde.site> <20081018015323.GA11149@wotan.suse.de> <18681.20241.347889.843669@cargo.ozlabs.ibm.com> <20081018054916.GB26472@wotan.suse.de> <alpine.LFD.2.00.0810180921140.3438@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0810180921140.3438@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Paul Mackerras <paulus@samba.org>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 18, 2008 at 10:00:30AM -0700, Linus Torvalds wrote:
> 
> 
> On Sat, 18 Oct 2008, Nick Piggin wrote:
> > 
> > I think it can be called transitive. Basically (assumememory starts off zeroed)
> 
> Alpha is transitive. It has a notion of "processor issue order" and 
> "location access order", and the ordering those two creates is a 
> transitive "before" and "after" ordering.
> 
> The issue with alpha is not that it wouldn't be transitive - the issue is 
> that *local* read dependencies do not cause a "processor issue order"!

That's fine. That's not so different to most other weakly ordered processor
having control dependencies not appearing in-order. So long as stores
propogate according to causality.

 
> So this creates a "location access" event on 'x' on alpha, call it "event 
> A".
> 
> > CPU1
> > if (x == 1) {
> >   fence
> >   y := 1
> > }
> 
> This has two events: let's call the read of 'x' "B", and "C" is the write 
> to 'y'.
> 
> And according to the alpha rules, we now have:
> 
>  - A << B
> 
>    Because we saw a '1' in B, we now have a "location access ordering" 
>    on the _same_ variable between A and B.
> 
>  - B < C
> 
>    Because we have the fence in between the read and the write, we now 
>    have a "processor issue order" between B and C (despite the fact that 
>    they are different variables).
> 
> And now, the alpha definition of "before" means that we can declare that A 
> is before C.
> 
> But on alpha, we really do need that fence, even if the address of 'y' was 
> somehow directly data-dependent on 'x'. THAT is what makes alpha special, 
> not any odd ordering rules.
> 
> > CPU2
> > if (y == 1) {
> >   fence
> >   assert(x == 1)
> > }
> 
> So again, we now have two events: the access of 'y' is "D", and the access 
> of x is "E". And again, according to the alpha rules, we have two 
> orderings:
> 
>  - C << D
> 
>    Because we saw a '1' in D, we have another "location access ordering" 
>    on the variably 'y' between C and D.
> 
>  - D < E
> 
>    Because of the fence, we have a "processor issue ordering" between D 
>    and E.
> 
> And for the same reason as above, we now get that C is "before" E 
> according to the alpha ordering rules. And because the definition of 
> "before" is transitive, then A is before E.
> 
> And that, in turn, means that that assert() can never trigger, because if 
> it triggered, then by the access ordering rules that would imply that E << 
> A, which would mean that E is "before" A, which in turn would violate the 
> whole chain we just got to.
> 
> So while the alpha architecture manual doesn't have the exact sequence 
> mentioned above (it only has nine so-called "Litmus tests"), it's fairly 
> close to Litmus test 3, and the ordering on alpha is very clear: it's all 
> transitive and causal (ie "before" can never be "after").

OK, good.

 
> > Apparently pairwise ordering is more interesting than just a theoretical
> > thing, and not just restricted to Alpha's funny caches.
> 
> Nobody does just pairwise ordering, afaik. It's an insane model. Everybody 
> does some form of transitive ordering.
 
We were chatting with Andy Glew a while back, and he said it actually can
be quite beneficial for HW designers (but I imagine that is the same as a
lot of "insane" things) ;)

I remember though that you said Linux should be pairwise-safe. I think
that's wrong (for more reasons than this anon-vma race), which is why
I got concerned and started off this subthread.

I think Linux probably has a lot of problems in a pairwise consistency
model, so I'd just like to check if we acutally attempt to supportany
architecture where that is the case.

x86, powerpc, alpha are good ;) That gives me hope.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
