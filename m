Date: Wed, 31 Jan 2007 14:48:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] not to disturb page LRU state when unmapping memory
 range
Message-Id: <20070131144855.8fe255ff.akpm@osdl.org>
In-Reply-To: <1170282300.10924.50.camel@lappy>
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
	<Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>
	<1170279811.10924.32.camel@lappy>
	<20070131140450.09f174e9.akpm@osdl.org>
	<1170282300.10924.50.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hugh@veritas.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jan 2007 23:25:00 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Wed, 2007-01-31 at 14:04 -0800, Andrew Morton wrote:
> 
> > > Andrew, any strong opinions?
> > 
> > Not really.  If we change something in there, some workloads will get
> > better, some will get worse and most will be unaffected and any regressions
> > we cause won't be known until six months later.  The usual deal.
> > 
> > Remember that all this info is supposed to be estimating what is likely to
> > happen to this page in the future - we're not interested in what happened
> > in the past, per-se.
> > 
> > I'd have thought that if multiple processes are touching the same
> > page, this is a reason to think that the page will be required again in the
> > immediate future.  But you seem to think otherwise?
> 
> Yes, why would unmapping a range make the pages more likely to be used
> in the immediate future than otherwise indicated by their individual
> young bits?
> 
> Even the opposite was suggested, that unmapping a range makes it less
> likely to be used again.

Ah, yes, well, that's different.

Our handling of page referenced information is basically random: we had
something in place in 2.4.midway, then use-once went in and churned things
around, then we turned VM upside-down in 2.5 and I basically tried to keep
what we then had in an unaltered state in the fond belief that someone
would one day get down and actually apply some design and thought to what
we're doing.  That has yet to happen.

Take a simple mmap+pagefault+munmap path.  The initial fault will leave the
page pte-referenced+PageReferenced+!PageActive.  If the vm scanner sees the
page it will become !pte-referenced+!PageReferenced+PageActive.  If it gets
unmapped it becomes !PageReferenced+PageActive.

These things at least seem to be somewhat consistent.  But I'm not sure
there's any logic behind it.

Perhaps we're approaching this from the wrong direction.  Rather than
looking at the code and saying "hey, we should change that", we should be
looking at workloads and seeing how they can be improved.  Perhaps.

In the above (simple, common) scenario the proposed
s/mark_page_accessed/SetPageReferenced/ change will cause the page to end
up PageReferenced+!PageActive.  ie: it ends up on the inactive list and not
the active list.  <tests it, confirms>.  That's a substantial change in
behaviour: inactive-list pages are considerably more reclaimable than
active-list ones and we might well alter things for people my making this
change.  Whether that alteration is net-good or net-bad is unknown ;)


> > > If only I could come up with a proper set of tests that covers all
> > > this...
> > 
> > Well yes, that's rather a sore point.  It's tough.  I wonder what $OTHER_OS
> > developers have done.  Probably their tests are priority ordered by
> > $market_share of their user's applications :(
> 
> Still requires them to set up and run said programs. If we could get a
> suite of programs that we consider interesting....
> 
> Just hoping, I seem to be stuck with quite a lot of code without means
> of evaluation.

We don't _have_ to use live applications.  Often they are hard to set up,
and do complex things and are hard to understand.  A more controllable and
ultimately more useful result could be achieved by defining *workloads*:
particular scenarios for the VM.  Then write simple and easily observeable
testcases for each scenario.  That's basically what people do, I think, but
it's all a bit ad-hoc and uncoordinated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
