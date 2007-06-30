Date: Sat, 30 Jun 2007 14:16:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/5] avoid tlb gather restarts.
In-Reply-To: <1183151984.13635.16.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706301406001.12517@blonde.wat.veritas.com>
References: <20070629135530.912094590@de.ibm.com>  <20070629141527.557443600@de.ibm.com>
  <Pine.LNX.4.64.0706291927260.1509@blonde.wat.veritas.com>
 <1183151984.13635.16.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jun 2007, Martin Schwidefsky wrote:
> On Fri, 2007-06-29 at 19:56 +0100, Hugh Dickins wrote:
> > I don't dare comment on your page_mkclean_one patch (5/5),
> > that dirty page business has grown too subtle for me.
> 
> Oh yes, the dirty handling is tricky....

I'll move that discussion over to 5/5 and Cc Peter
(sorry I was too lazy to do so in the first place).

> > On Fri, 29 Jun 2007, Martin Schwidefsky wrote:
> > You think you're just moving the finish/gather to where they're
> > actually necessary; but the thing is, that per-cpu struct mmu_gather
> > is liable to accumulate a lot of unpreemptible work for the future
> > tlb_finish_mmu, particularly when anon pages are associated with swap.
> 
> Hmm, ok, so you are saying that we should do a flush at the end of each
> vma.

I think of it as doing a flush every ZAP_BLOCK_SIZE, with the imperfect
structure of the loop forcing perhaps an early flush at the end of each
vma: I seem to assume large vmas, and you to assume small ones.

IIRC, the common case for doing multiple vmas here is exit, when it
ends up that the TLB flush can often be skipped because already done
by the switch from exiting task; so the premature flush per vma doesn't
matter much.  But treat that claim with maximum scepticism: I've not
rechecked it, several aspects may be wrong.  What I do remember is
that (at least on i386) there's a lot less actual TLB flushing done
here than it appears from the outside.

> > So although there may be no need to resched right now, if we keep on
> > gathering more and more without flushing, we'll be very unresponsive
> > when a resched is needed later on.  Hence Ingo's ZAP_BLOCK_SIZE to
> > split it up, small when CONFIG_PREEMPT, more reasonable but still
> > limited when not.
> 
> Would it be acceptable to call tlb_flush_mmu instead of the
> tlb_finish_mmu / tlb_gather_mmu pair if the condition around
> cond_resched evaluates to false?

That sounds a good idea, yes, that should be fine.  But beware,
tlb_flush_mmu is an internal detail of the asm-generic/tlb.h method
and perhaps some others, it currently doesn't exist on some arches.

I think you just need to add a simple one to arm & arm26, and take
the "ia64_" off the ia64 one.  powerpc and sparc64 go about it all 
a bit differently, but it should be easy to give them one too.
There may be some others missing.

> The background for this change is that I'm working on another patch that
> will change the tlb flushing for s390 quite a bit. We won't have
> anything to flush with tlb_finish_mmu because we will either flush all
> tlbs with tlb_gather_mmu or each pte seperatly. The pages will always be
> freed immediatly. If we are forced to restart the tlb gather then we'll
> do multiple flush_tlb_mm because the information that we already flushed
> everything is lost with tlb_finish_mmu.

Thanks for the info.  Sounds like we may have trouble ahead when
rearranging this stuff, easy to forget s390 from our assumptions:
keep watch!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
