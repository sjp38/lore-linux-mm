Date: Sun, 2 May 2004 09:42:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: rmap spin_trylock success rates
In-Reply-To: <20040501005408.1cd77796.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0405020922520.14500-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 May 2004, Andrew Morton wrote:
> 
> I applied the appended patch to determine the spin_trylock success rate in
> rmap.c.

Good, thank you, this needed doing.
I think you want to extend it to the spin_trylocks on i_shared_lock too.

> The machine is a single P4-HT pseudo-2-way.  256MB of memory and
> the workload is a straightforward `usemem -m 400': allocate and touch 400MB
> of memory.
> 
> page_referenced_one_miss = 4027
> page_referenced_one_hit = 212605
> try_to_unmap_one_miss = 3257
> try_to_unmap_one_hit = 61153
> 
> That's a 5% failure rate in try_to_unmap_one()'s spin_trylock().

Considerably better than I feared.

> I suspect this is the reason for the problem which Martin Schwidefsky
> reported a while back: this particular workload only achieves half the disk
> bandwidth on SMP when compared with UP.  I poked around with that a bit at
> the time and determined that it was due to poor I/O submission patterns. 
> Increasing the disk queue from 128 slots to 1024 fixed it completely
> because the request queue fixed up the bad I/O submission patterns.

Well, I'm glad you can make such connections!  My understanding went so
far as to wonder whether you'd cut'n'pasted that paragraph in by mistake!

> With `./qsbench -p 4 -m 96':
> 
> page_referenced_one_miss = 401
> page_referenced_one_hit = 1224748
> try_to_unmap_one_miss = 103
> try_to_unmap_one_hit = 339944
> 
> That's negligible.
> 
> I don't think we really need to do anything about this - the
> everything-in-one-mm case isn't the most interesting situation.

Yes, nothing to worry about in these particular figures.
But probably somewhere out there is an app with a feedback
effect which really makes them bad.  Later on I would like
to go back and see what can be done about missed trylocks.

> In a way it's an argument for serialising the whole page reclaim path.
> 
> It'd be nice of we can reduce the page_table_lock hold times in there.
> 
> hm, now I'm confused.  We're running try_to_unmap_one() under anonhd->lock,
> so why is there any contention for page_table_lock at all with this
> workload?  It must be contending with page_referenced_one().  Taking
> anonhd->lock in page_referenced_one() also might fix this up.

page_referenced_anon does already take the anonhd->lock.  If try_to_unmap
is actually unmapping pages, won't that workload want to fault them back
in again later, hence page_table_lock contention with faulting?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
