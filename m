Date: Mon, 1 Dec 2008 08:00:41 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC] another crazy idea to get rid of mmap_sem in faults
In-Reply-To: <1227886959.4454.4421.camel@twins>
Message-ID: <Pine.LNX.4.64.0812010747100.11954@quilx.com>
References: <1227886959.4454.4421.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, hugh <hugh@veritas.com>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Nov 2008, Peter Zijlstra wrote:

> Pagefault concurrency with mmap() is undefined at best (any sane
> application will start using memory after its been mmap'ed and stop
> using it before it unmaps it).

mmap_sem in pagefaults is mainly used to serialize various
modifications to the address space structures while faults are processed.
This is of course all mmap related but stuff like forking can
occur concurrently in a multithreaded application. The COW mechanism is
tied up with this too.

> If we do not freeze the vm map like we normally do but use a lockless
> vma lookup we're left with the unmap race (you're unlikely to find the
> vma before insertion anyway).

Then you will need to use RCU for the vmas in general. We already use
RCU for the anonymous vma. Extend that to all vmas?

> I think we can close that race by marking a vma 'dead' before we do the
> pte unmap, this means that once we have the pte lock in the fault
> handler we can validate the vma (it cannot go away after all, because
> the unmap will block on it).

The anonymous VMAs already have refcounts and vm_area_struct also for the
!MM case. So maybe you could get to the notion of a "dead" vma easily.

> Therefore, we can do the fault optimistically with any sane vma we get
> until the point we want to insert the PTE, at which point we have to
> take the PTL and validate the vma is still good.

How would this sync with other operations that need to take mmap_sem?

> I'm sure there are many fun details to work out, even if the above idea
> is found solid, amongst them is extending srcu to provide call_srcu(),
> and implement an RCU friendly tree structure.

srcu may have too much of an overhead for this.

> [ hmm, while writing this it occurred to me this might mean we have to
>   srcu free the page table pages :/ ]

The page tables cannot be immediately be reused then (quicklists etc).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
