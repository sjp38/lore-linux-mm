Date: Sat, 6 Nov 2004 16:06:55 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Nov 2004, Christoph Lameter wrote:

> My page scalability patches need to make rss atomic and now with the
> addition of anon_rss I would also have to make that atomic.

You could remove the additional impact of anon_rss by deleting that
and replacing rss by rss[2], adjusting only rss[PageAnon(page)]:
no need to increment or decrement two counters in the one operation.

Introducing anon_rss made for a smaller patch then, but if you're
patching all those rss places, might as well separate out to rss[2].

> But when I looked at the code I found that the only significant use of
> both is in for proc statistics. There are 3 other uses in mm/rmap.c where
> the use of mm->rss may be replaced by mm->total_vm.

The tests on mm->rss in rmap.c were critical at one time (in the anonmm
objrmap, to guard against doing the wrong thing in the case of some tiny
race with dup_mmap, if I remember correctly).  They're stayed on as
vague optimizations, but I'd be perfectly happy for you to just
remove them - I'd prefer that to putting in total_vm tests.

> So I removed all uses of mm->rss and anon_rss from the kernel and
> introduced a bean counter count_vm() that is only run when the
> corresponding /proc file is used. count_vm then runs throught the vm
> and counts all the page types. This could also add additional page
> types to our statistics and solve some of the consistency issues.

You're joking!  Certainly not, as others have asserted.

But I don't know what the appropriate solution is.  My priorities
may be wrong, but I dislike the thought of a struct mm dominated
by a huge percpu array of rss longs (or cachelines?), even if the
machines on which it would be huge are ones which could well afford
the waste of memory.  It just offends my sense of proportion, when
the exact rss is of no importance.  I'm more attracted to just
leaving it unatomic, and living with the fact that it's racy
and approximate (but /proc report negatives as 0).

It might be interesting to run your anon faulting test on an SGI
monster, keeping both atomic and non-atomic counts, to see just
how likely, how much they go out of sync.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
