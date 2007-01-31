Subject: Re: [patch] not to disturb page LRU state when unmapping memory
	range
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070131144855.8fe255ff.akpm@osdl.org>
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
	 <Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>
	 <1170279811.10924.32.camel@lappy> <20070131140450.09f174e9.akpm@osdl.org>
	 <1170282300.10924.50.camel@lappy>  <20070131144855.8fe255ff.akpm@osdl.org>
Content-Type: text/plain
Date: Thu, 01 Feb 2007 00:52:14 +0100
Message-Id: <1170287534.10924.103.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-01-31 at 14:48 -0800, Andrew Morton wrote:
> On Wed, 31 Jan 2007 23:25:00 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > On Wed, 2007-01-31 at 14:04 -0800, Andrew Morton wrote:
> > 
> > > > Andrew, any strong opinions?
> > > 
> > > Not really.  If we change something in there, some workloads will get
> > > better, some will get worse and most will be unaffected and any regressions
> > > we cause won't be known until six months later.  The usual deal.
> > > 
> > > Remember that all this info is supposed to be estimating what is likely to
> > > happen to this page in the future - we're not interested in what happened
> > > in the past, per-se.
> > > 
> > > I'd have thought that if multiple processes are touching the same
> > > page, this is a reason to think that the page will be required again in the
> > > immediate future.  But you seem to think otherwise?
> > 
> > Yes, why would unmapping a range make the pages more likely to be used
> > in the immediate future than otherwise indicated by their individual
> > young bits?
> > 
> > Even the opposite was suggested, that unmapping a range makes it less
> > likely to be used again.
> 
> Ah, yes, well, that's different.
> 
> Our handling of page referenced information is basically random: we had
> something in place in 2.4.midway, then use-once went in and churned things
> around, then we turned VM upside-down in 2.5 and I basically tried to keep
> what we then had in an unaltered state in the fond belief that someone
> would one day get down and actually apply some design and thought to what
> we're doing.  That has yet to happen.
> 
> Take a simple mmap+pagefault+munmap path.  The initial fault will leave the
> page pte-referenced+PageReferenced+!PageActive. 

Assuming major fault, a minor fault might well map an active page.

>  If the vm scanner sees the
> page it will become !pte-referenced+!PageReferenced+PageActive.  If it gets
> unmapped it becomes !PageReferenced+PageActive.

scanner does:

1) referenced,   inactive -> unreferenced, active
2) referenced,   active   -> unreferenced, active

3) unreferenced, active   -> unreferenced, inactive
4) unreferenced, inactive -> reclaimed

> These things at least seem to be somewhat consistent.  But I'm not sure
> there's any logic behind it.

Seems rather logical, 2 level state, each clock period you either
promote or demote depending on activity.

> Perhaps we're approaching this from the wrong direction.  Rather than
> looking at the code and saying "hey, we should change that", we should be
> looking at workloads and seeing how they can be improved.  Perhaps.

Any which way I'm turning it, it keeps being a blind shot. But I get the
idea.

> In the above (simple, common) scenario the proposed
> s/mark_page_accessed/SetPageReferenced/ change will cause the page to end
> up PageReferenced+!PageActive. 

How so, it will not demote the page to inactive. 

Now unmap could promote to active, with the change not so. Neither will
ever demote, only page reclaim will do that.

currently with mark_page_accessed:

 referenced := (pte young || PageReferenced) 

1 active pte

  referenced (pte, !PG_referenced), inactive -> referenced,   inactive
  referenced (pte ,PG_referenced),  inactive -> unreferenced, active
  *,                                active   -> referenced,   active

2 active ptes

  referenced (pte, !PG_referenced), inactive -> unreferenced, active
  referenced (pte, PG_referenced),  inactive -> referenced, active
  *,                                active   -> referenced, active

3+ active ptes

  *, * -> referenced, active

which I find quite horrid for unmap...

Or, with the proposed SetPageReferenced:

1+ active pte(s)
  referenced (pte,!PG_referenced), * -> referenced (PG_referenced), *
  referenced (pte, PG_referenced), * -> referenced (PG_referenced), *

Its actually an identity map, it just moves pte young bits into the
referenced bit, which is all the same to page_referenced().

>  ie: it ends up on the inactive list and not
> the active list.  <tests it, confirms>. 

it will stay on whatever list it was.

>  That's a substantial change in
> behaviour: inactive-list pages are considerably more reclaimable than
> active-list ones and we might well alter things for people my making this
> change.  Whether that alteration is net-good or net-bad is unknown ;)

Its quite a change indeed, but either I'm not quite parsing what you're
saying and we're in violent agreement, or I should go sleep ;-)

I hope this state machinery makes sense, I feel asleep already.

> We don't _have_ to use live applications.  Often they are hard to set up,
> and do complex things and are hard to understand.  

> A more controllable and
> ultimately more useful result could be achieved by defining *workloads*:
> particular scenarios for the VM.  

> Then write simple and easily observeable
> testcases for each scenario.  That's basically what people do, I think, but
> it's all a bit ad-hoc and uncoordinated.

I have started writing an application that can perform simple patterns,
perhaps we should discuss interesting patterns during the VM summit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
