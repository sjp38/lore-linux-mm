Date: Sun, 2 May 2004 02:36:47 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: rmap spin_trylock success rates
Message-Id: <20040502023647.3866eb9c.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0405020922520.14500-100000@localhost.localdomain>
References: <20040501005408.1cd77796.akpm@osdl.org>
	<Pine.LNX.4.44.0405020922520.14500-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> On Sat, 1 May 2004, Andrew Morton wrote:
> > 
> > I applied the appended patch to determine the spin_trylock success rate in
> > rmap.c.
> 
> Good, thank you, this needed doing.
> I think you want to extend it to the spin_trylocks on i_shared_lock too.

hm.

> > The machine is a single P4-HT pseudo-2-way.  256MB of memory and
> > the workload is a straightforward `usemem -m 400': allocate and touch 400MB
> > of memory.
> > 
> > page_referenced_one_miss = 4027
> > page_referenced_one_hit = 212605
> > try_to_unmap_one_miss = 3257
> > try_to_unmap_one_hit = 61153
> > 
> > That's a 5% failure rate in try_to_unmap_one()'s spin_trylock().
> 
> Considerably better than I feared.

It's only a pretend 2-way.  Bigger machines may be worse.

But the workload isn't very interesting.

> > I suspect this is the reason for the problem which Martin Schwidefsky
> > reported a while back: this particular workload only achieves half the disk
> > bandwidth on SMP when compared with UP.  I poked around with that a bit at
> > the time and determined that it was due to poor I/O submission patterns. 
> > Increasing the disk queue from 128 slots to 1024 fixed it completely
> > because the request queue fixed up the bad I/O submission patterns.
> 
> Well, I'm glad you can make such connections!  My understanding went so
> far as to wonder whether you'd cut'n'pasted that paragraph in by mistake!

I saw the debug output.  It was blocks of 1000-odd successive writepages
followed by blobs of some tens of missed trylocks.  Those missed trylocks
result in the pages being refiled on the LRU, so we writepage them later
on, when the disk head is elsewhere.  (hm.  If we unmap the page from
swapcache on missed trylock that won't happen).

If the CPU which holds page_table_lock wanders off to service an interrupt
we'll miss the lock a lot of times in succession.

> If try_to_unmap
> is actually unmapping pages, won't that workload want to fault them back
> in again later, hence page_table_lock contention with faulting?

The workload is just a linear wipe, so it'll be faults against new pages,
yup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
