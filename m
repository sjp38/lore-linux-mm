Date: Fri, 29 Oct 2004 13:52:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
Message-ID: <20041029205255.GH12934@holomorphy.com>
References: <4181EF2D.5000407@yahoo.com.au> <41822D75.3090802@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41822D75.3090802@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2004 at 09:45:57PM +1000, Nick Piggin wrote:
> One more patch - this provides a generic framework for pte
> locks, and a basic i386 reference implementation (which just
> ifdefs out the cmpxchg version). Boots, runs, and has taken
> some stressing.
> I should have sorted this out before sending the patches for
> RFC. The generic code actually did need a few lines of changes,
> but not much as you can see. Needs some tidying up though, but
> I only just wrote it in a few minutes.
> And now before anyone gets a chance to shoot down the whole thing,
> I just have to say
> 	"look ma, no page_table_lock!"

The large major problem to address is making sure this works with
arches. Without actually examining the arches this needs to be made to
work with, it's not any kind of advance.

The only way to demonstrate that the generic API is any kind of
progress toward that end is to sweep the arches and make them work.

So, the claim of "look ma, no page_table_lock" is meaningless, as no
arches but x86(-64) have been examined, audited, etc. The most disturbing
of these is the changing of the locking surrounding tlb_finish_mmu() et
al. It's not valid to decouple the locking surrounding tlb_finish_mmu()
from pagetable updates without teaching the architecture-specific code
how to cope with this.

It's also relatively sleazy to drop this in as an enhancement for just
a few architectures (x86[-64], ia64, ppc64), and leave the others cold,
but I won't press that issue so long as the remainder are functional,
regardless of my own personal preferences.

What is unacceptable is the lack of research into the needs of arches
that has been put into this. The general core changes proposed can
never be adequate without a corresponding sweep of architecture-
specific code. While I fully endorse the concept of lockless pagetable
updates, there can be no correct implementation leaving architecture-
specific code unswept. I would encourage whoever cares to pursue this
to its logical conclusion to do the necessary reading, and audits, and
review of architecture manuals instead of designing core API's in vacuums.

I'm sorry if it sounds harsh, but I can't leave it unsaid. I've had to
spend far too much time cleaning up after core changes carried out in
similar obliviousness to the needs of architectures already, and it's
furthermore unclear that I can even accomplish a recovery of a
significant number of architectures from nonfunctionality in the face
of an incorrect patch of this kind without backing it out entirely.
Some of the burden of proof has to rest on he who makes the change;
it's not even necessarily feasible to break arches with a patch of this
kind and accomplish any kind of recovery of a significant number of them.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
