Date: Thu, 14 Aug 2008 14:35:46 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: dirty page accounting race fix
Message-ID: <20080814123546.GA29727@wotan.suse.de>
References: <20080814094537.GA741@wotan.suse.de> <Pine.LNX.4.64.0808141210200.4398@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808141210200.4398@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 14, 2008 at 12:55:46PM +0100, Hugh Dickins wrote:
> On Thu, 14 Aug 2008, Nick Piggin wrote:

> > -	pte = page_check_address(page, mm, address, &ptl);
> > +	pte = page_check_address(page, mm, address, &ptl, 0);
> >  	if (!pte)
> >  		goto out;
> >  
> > 
> 
> I'm not against this if it really turns out to be the answer,
> it's simple enough and it sounds like a very good find; but
> I'm still not convinced that you've got to the bottom of it.
> 
> Am I confused, or is your "do_wp_page calls ptep_clear_flush_notify"
> example a very bad one?  The page it's dealing with there doesn't
> go back into the page table (its COW does), and the dirty_accounting
> case doesn't even get down there, it's dealt with in the reuse case
> above, which uses ptep_set_access_flags.  Now, I think that one may

Oh you're right definitely. Thanks.

Actually, the bug I am running into is not with a vanilla kernel...
I am making several of my own required changes to solve other races
I need to plug, so I'm sorry the changelog might be misleading...
I have not actually reproduced a problem with the vanilla kernel.


> well behave as you suggest on some arches (though it's extending
> permissions not restricting them, so maybe not); but please check
> that out and improve your example.
> 
> Even if it does, it's not clear to me that your fix is the answer.
> That may well be because the whole of dirty page accounting grew too
> subtle for me!  But holding the page table lock on one pte of the
> page doesn't guarantee much about the integrity of the whole dance:
> do_wp_page does its set_page_dirty_balance for this case, you'd
> need to spell out the bad sequence more to convince me.
 

Hmm, no even in that case I think we get away with it because of
the wait_on_page_locked which ensures clearing the page dirty
bit before do_wp_page sets the page dirty...



> Sorry, that may be a lot of work, to get it through my skull!
> And I may be lazily asking you to do my thinking for me.

Maybe I've found another one: ppc64's set_pte_at seems to clear
the pte, and lots of pte accessors are implemented with set_pte_at.
mprotect's modify_prot_commit for example.

Even if I'm wrong and we happen to be safe everywhere, it seems
really fragile to ask that no architectures ever allow transient
!pte_present in cases  where it matters, and no generic code
emit the wrong sequence either. Or is there some reason I'm missing
that makes this more robust?


> But I got a bit distracted: mprotect's change_pte_range is
> traditionally where the pte_modify operation has been split up into
> stages on some arches, that really can be restricting permissions
> and needs to tread carefully.  Now I go to look there, I see its
> 		/*
> 		 * Avoid taking write faults for pages we know to be
> 		 * dirty.
> 		 */
> 		if (dirty_accountable && pte_dirty(ptent))
> 			ptent = pte_mkwrite(ptent);
> 
> and get rather worried: isn't that likely to be giving write permission
> to a pte in a vma we are precisely taking write permission away from?
> That's a different issue, of course; but perhaps it's even relevant.

Hmm, vma_wants_writenotify is only true if VM_WRITE, and in that
case we might be OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
