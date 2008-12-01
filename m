Subject: Re: [RFC] another crazy idea to get rid of mmap_sem in faults
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0812010747100.11954@quilx.com>
References: <1227886959.4454.4421.camel@twins>
	 <Pine.LNX.4.64.0812010747100.11954@quilx.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 01 Dec 2008 15:48:15 +0100
Message-Id: <1228142895.7140.43.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, hugh <hugh@veritas.com>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 08:00 -0600, Christoph Lameter wrote:
> On Fri, 28 Nov 2008, Peter Zijlstra wrote:
> 
> > Pagefault concurrency with mmap() is undefined at best (any sane
> > application will start using memory after its been mmap'ed and stop
> > using it before it unmaps it).
> 
> mmap_sem in pagefaults is mainly used to serialize various
> modifications to the address space structures while faults are processed.

Well, yeah, mainly the vmas, right? We need to ensure the vma we fault
into doesn't go away or change under us.

Does mmap_sem protect more than the vma's and their RB tree?

> This is of course all mmap related but stuff like forking can
> occur concurrently in a multithreaded application. The COW mechanism is
> tied up with this too.

Hohumm, fork().. good point.

I'll ponder the COW stuff, but since that too holds on to the PTL I
think we're good.

> > If we do not freeze the vm map like we normally do but use a lockless
> > vma lookup we're left with the unmap race (you're unlikely to find the
> > vma before insertion anyway).
> 
> Then you will need to use RCU for the vmas in general. We already use
> RCU for the anonymous vma. Extend that to all vmas?

RCU cannot be used, since we need to be able to sleep in a fault in
order to do IO. So we need to extend SRCU - but since we have all the
experience of preemptible RCU to draw from I think that should not be an
issue.

> > I think we can close that race by marking a vma 'dead' before we do the
> > pte unmap, this means that once we have the pte lock in the fault
> > handler we can validate the vma (it cannot go away after all, because
> > the unmap will block on it).
> 
> The anonymous VMAs already have refcounts and vm_area_struct also for the
> !MM case. So maybe you could get to the notion of a "dead" vma easily.

!MMU case?, yes I was thinking to abuse that ;-)

> > Therefore, we can do the fault optimistically with any sane vma we get
> > until the point we want to insert the PTE, at which point we have to
> > take the PTL and validate the vma is still good.
> 
> How would this sync with other operations that need to take mmap_sem?

What other ops? mmap/munmap/mremap/madvise etc.?

The idea is that any change to a vma (which would require exclusive
mmap_sem) will replace the vma - marking the old one dead and SRCU free
it.

All non-exclusive users can already handle others.

Stuff like merge/split is interesting because that might invalidate a
vma while the fault stays valid.

This means we have to have a more complex vma validation, something
along the lines of:

/*
 * Finds a valid vma
 */
struct vm_area_struct *find_vma(mm, addr)
{
again:
	rcu_read_lock(); /* solely for the lookup structure */
	vma = tree_lookup(&mm->vma_tree, addr); /* vma is srcu guarded */
	rcu_read_unlock();
	if (vma && vma_is_dead(vma))
		goto again;

	return vma;
}

/*
 * validates if a previously obtained vma is still valid,
 * synchronizes with vma against PTL.
 */
int validate_vma(mm, vma, addr)
{
	ASSERT_PTL_LOCKED(mm, addr);

	if (!vma_is_dead(vma))
		return 1;

	vma2 = find_vma(mm, addr);

	if (/*old vma fault is still valid in vma2*/)
		return 1

	return 0;
}

Merge:

  mark both vmas dead
  grow the left to cover both
  remove the right
  replace the left with a new alive one

  (Munge PTEs)

Split:

  mark the vma dead
  insert the new fragment (always the right-most)
  replace the left with a new smaller.

  (Munge PTEs)

Where we basically use the re-try in the lookup to wait for a valid vma
to appear while never having the lookup return NULL (which would make
the fault fail and sigbus).

> > I'm sure there are many fun details to work out, even if the above idea
> > is found solid, amongst them is extending srcu to provide call_srcu(),
> > and implement an RCU friendly tree structure.
> 
> srcu may have too much of an overhead for this.

Then we need to fix that ;-) But surely SRCU is cheaper than mmap_sem.

> > [ hmm, while writing this it occurred to me this might mean we have to
> >   srcu free the page table pages :/ ]
> 
> The page tables cannot be immediately be reused then (quicklists etc).

I think I was wrong there, we don't do speculative PTE locks, so we
should be good here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
