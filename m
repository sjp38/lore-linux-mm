Date: Wed, 17 Aug 2005 16:31:11 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <Pine.LNX.4.58.0508171619260.3553@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0508171624190.19528@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508171619260.3553@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Aug 2005, Linus Torvalds wrote:

> On Wed, 17 Aug 2005, Christoph Lameter wrote:
> >
> > We have no problems if the lock are not contended. Then we just reduce the 
> > overhead by eliminating one semaphore instruction.
> 
> We _do_ have a problem.

Ok. Thats even better :-)

> Do a kernel benchmark on UP vs SMP, and realize that the cost of just
> uncontended spinlocks is about 20% on some kernel loads. That's with
> purely single-threaded benchmarks, tied to one CPU - the cost of atomic
> ops really is that high. The only difference is the spinlock/unlock.
> 
> (Now, the page fault case may not be that bad, but the point remains: 
> locking and atomic ops are bad. The anonymous page thing is one of the 
> hottest pieces of code in the kernel under perfectly normal loads, and 
> getting rid of spinlocks there is worth it).

Right.
 
> The thing is, I personally don't care very much at all about 5000 threads
> doing page faults in the same VM at the same time. I care about _one_
> thread doing page faults in the same VM, and the fact that your patch, if
> done right, could help that. That's why I like the patch. Not because of 
> your scalability numbers ;)

I will submit the list rss stuff later but there are several 
modifications to mm management that will cause additional large scale 
changes. Andrew is already complaining so I did not want to risk more 
invasive patches than this. The rss counter management is already handled 
through macros (due to the first page fault scalability patch that was 
accepted in January) so that it will be easy to substitute alternate 
implementions in order to avoid atomic operations.

The list rss patches give another threefold improvement in page fault 
numbers on our large scale systems.

> So we're coming from two different angles here.

I thought we were on the same page?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
