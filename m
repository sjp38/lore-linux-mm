Date: Sun, 19 Oct 2008 08:07:23 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081019030325.GE16562@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0810190745420.5662@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
 <20081018013258.GA3595@wotan.suse.de> <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
 <20081018022541.GA19018@wotan.suse.de> <Pine.LNX.4.64.0810181952580.27309@blonde.site>
 <20081019030325.GE16562@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 19 Oct 2008, Nick Piggin wrote:
> On Sat, Oct 18, 2008 at 08:14:12PM +0100, Hugh Dickins wrote:
> > And Nick is right that page_lock_anon_vma() is not safe against finding
> > an anon_vma which has now been allocated for something else: but that
> > is no surprise, it's very much in the nature of SLAB_DESTROY_BY_RCU
> > (I left most of the comment in mm/slab.c, just said "tricky" here).
> > 
> > It should be no problem: having locked the right-or-perhaps-wrong
> > anon_vma, we then go on to search its list for a page which may or
> > may not be there, even when it's the right anon_vma; there's no need
> 
> OK, so it may be correct but I think that's pretty nasty if we can
> avoid it so easily. Then we have to keep in mind this special case
> throughout the code rather than just confining it to the low level
> take-a-reference function and never having to worry about it.
> 
> 
> > for special code to deal with the very unlikely case that we've now
> > got an irrelevant list, it's just that the page we're looking for
> > won't be found in it.
> 
> There is already a page_mapped check in there. I'm just going to
> propose we move that down. No extra branchesin the fastpath. OK?

That should be OK, yes.  Looking back at the history, I believe
I sited the page_mapped test where it is, partly for simpler flow,
and partly to avoid overhead of taking spinlock unnecessarily.

But that's much too rare a case to be worrying about: better
to leave you comfortable with page_lock_anon_vma() itself.
More important will be the comments you add, I'll probably
want to quibble on those!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
