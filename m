Date: Thu, 12 Jul 2007 17:42:01 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: mmu_gather changes & generalization
In-Reply-To: <1184195933.6059.111.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0707121715500.4887@blonde.wat.veritas.com>
References: <1184046405.6059.17.camel@localhost.localdomain>
 <Pine.LNX.4.64.0707112100050.16237@blonde.wat.veritas.com>
 <1184195933.6059.111.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jul 2007, Benjamin Herrenschmidt wrote:
> > 
> > What I had was the small stack based data structure, with a small
> > fallback array of struct page pointers built in, and attempts to
> > allocate a full page atomically when this array not big enough -
> > just go slower with the small array when that allocation fails.
> > There may be cleverer approaches, but it seems good enough.
> 
> Yes, that's what Nick described. I had in mind an incremental approach,
> starting with just splitting the batch into the stack based structure
> and the page list and keeping the per-cpu page list, and then, letting
> you change that too separately, but we can do it the other way around.

Oh, whatever I send, you just take it forward if it does look useful
to you, or forget it if it's just getting in your way, or mixing what
you'd prefer to be separate steps, or more trouble to follow someone
else's than do your own: no problems.

There is an overlap of cleanup between what I have and what you're
intending (e.g. **tlb -> *tlb), but it's hardly beyond your capability
to do that without my patch ;)

> BTW, talking about MMU interfaces.... I've had a quick look yesterday
> and there's a load of stuff in the various pgtable.h imeplemtations that
> isn't used at all anymore ! For example, ptep_test_and_clear_dirty() is
> no longer used by rmap, and there's a whole lot of others like that.
> 
> Also, there are some archs whose implementation is identical to
> asm-generic for some of these.
> 
> I was thinking about doing pass through the whole tree getting rid of
> everything that's not used or duplicate of asm-generic while at it,
> unless you have reasons not to do that or you know somebody already
> doing it.

If you wait for next -mm, I think you'll find Martin Schwidefsky has
done a little cleanup (including removing ptep_test_and_clear_dirty,
which did indeed pose some problem when it had no examples of use);
and Jan Beulich some other cleanups already in the last -mm (removing
some unused macros like pte_exec).  But it sounds like you want to go
a lot further.

Hmm, well, if your cross-building environment is good enough that you
won't waste any of Andrew's time with the results, I guess go ahead.

Personally, I'm not in favour of removing every last unused macro:
if only from a debugging or learning point of view, it can be useful
to see what pte_exec is on each architecture, and it might be needed
again tomorrow.  But I am very much in favour of reducing the spread
of unnecessary difference between architectures, the quantity of
evidence you have to wade through when considering them for changes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
