Date: Sat, 6 Nov 2004 08:52:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.58.0411060847100.25584@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Nov 2004, Hugh Dickins wrote:

> > So I removed all uses of mm->rss and anon_rss from the kernel and
> > introduced a bean counter count_vm() that is only run when the
> > corresponding /proc file is used. count_vm then runs throught the vm
> > and counts all the page types. This could also add additional page
> > types to our statistics and solve some of the consistency issues.
>
> You're joking!  Certainly not, as others have asserted.

Nope. If you lock the vm properly then the bean counter approach will
result in an accurate count. Incrementing and decrementing rss in various
places may have issues that lead to inaccuracies. The bean counter
approach will at least not propagate these any further.

> But I don't know what the appropriate solution is.  My priorities
> may be wrong, but I dislike the thought of a struct mm dominated
> by a huge percpu array of rss longs (or cachelines?), even if the
> machines on which it would be huge are ones which could well afford
> the waste of memory.  It just offends my sense of proportion, when
> the exact rss is of no importance.  I'm more attracted to just
> leaving it unatomic, and living with the fact that it's racy
> and approximate (but /proc report negatives as 0).

I also thought about the percpu approach but its rather unappealing given
also the larger and large cpucounts.

Simply living with the inaccuracies is certainly the easiest
solution. Thanks.

> It might be interesting to run your anon faulting test on an SGI
> monster, keeping both atomic and non-atomic counts, to see just
> how likely, how much they go out of sync.

Ok. We can try that.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
