Date: Sun, 19 Oct 2008 04:54:44 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081019025444.GC16562@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810172300280.30871@blonde.site> <alpine.LFD.2.00.0810171549310.3438@nehalem.linux-foundation.org> <Pine.LNX.4.64.0810180045370.8995@blonde.site> <20081018015323.GA11149@wotan.suse.de> <18681.20241.347889.843669@cargo.ozlabs.ibm.com> <20081018054916.GB26472@wotan.suse.de> <alpine.LFD.2.00.0810180921140.3438@nehalem.linux-foundation.org> <20081018184405.GA26184@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081018184405.GA26184@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Paul Mackerras <paulus@samba.org>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 18, 2008 at 12:44:05PM -0600, Matthew Wilcox wrote:
> On Sat, Oct 18, 2008 at 10:00:30AM -0700, Linus Torvalds wrote:
> > > Apparently pairwise ordering is more interesting than just a theoretical
> > > thing, and not just restricted to Alpha's funny caches.
> > 
> > Nobody does just pairwise ordering, afaik. It's an insane model. Everybody 
> > does some form of transitive ordering.
> 
> I assume you're talking about CPUs in particular here, and I don't know
> of any counterexamples.

Yes, just CPUs.

 
> If you're talking about PCI devices, the model is not transitive.
> Here's the exact text from Appendix E of PCI 3.0:
> 
>   A system may have multiple Producer-Consumer pairs operating
>   simultaneously, with different data - flag-status sets located all
>   around the system. But since only one Producer can write to a single
>   data-flag set, there are no ordering requirements between different
>   masters. Writes from one master on one bus may occur in one order on
>   one bus, with respect to another master's writes, and occur in another
>   order on another bus. In this case, the rules allow for some writes
>   to be rearranged; for example, an agent on Bus 1 may see Transaction
>   A from a master on Bus 1 complete first, followed by Transaction B
>   from another master on Bus 0. An agent on Bus 0 may see Transaction
>   B complete first followed by Transaction A. Even though the actual
>   transactions complete in a different order, this causes no problem
>   since the different masters must be addressing different data-flag sets.
> 
> I seem to remember earlier versions of the spec having more clear
> language about A happening before B and B happening before C didn't
> mean that A happened before C from the perspective of a third device,
> but I can't find it right now.
> 
> Anyway, as the spec says, you're not supposed to use PCI like that,
> so it doesn't matter.

Interesting. Hopefully as you say it won't matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
