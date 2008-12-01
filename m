Subject: Re: [RFC] another crazy idea to get rid of mmap_sem in faults
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0812010857040.15331@quilx.com>
References: <1227886959.4454.4421.camel@twins>
	 <Pine.LNX.4.64.0812010747100.11954@quilx.com>
	 <1228142895.7140.43.camel@twins>
	 <Pine.LNX.4.64.0812010857040.15331@quilx.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 01 Dec 2008 16:28:36 +0100
Message-Id: <1228145317.7070.17.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, hugh <hugh@veritas.com>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 09:06 -0600, Christoph Lameter wrote:
> On Mon, 1 Dec 2008, Peter Zijlstra wrote:
> 
> > Well, yeah, mainly the vmas, right? We need to ensure the vma we fault
> > into doesn't go away or change under us.
> >
> > Does mmap_sem protect more than the vma's and their RB tree?
> 
> It may protect portions of the mm_struct?

Maybe, I'll see what of that faults use.

> > I'll ponder the COW stuff, but since that too holds on to the PTL I
> > think we're good.
> 
> Copy pte range is called under mmap_sem when forking.

Obviously, but if we do faults without mmap_sem there's a race, we need
to do the right thing.

> > > Then you will need to use RCU for the vmas in general. We already use
> > > RCU for the anonymous vma. Extend that to all vmas?
> >
> > RCU cannot be used, since we need to be able to sleep in a fault in
> > order to do IO. So we need to extend SRCU - but since we have all the
> > experience of preemptible RCU to draw from I think that should not be an
> > issue.
> 
> Then do not hold it across sleeping portions. If you have to sleep then
> start another rcu section and recheck the situation before proceeding.

I'd prefer to start out with SRCU and maybe try that later.

> > > How would this sync with other operations that need to take mmap_sem?
> >
> > What other ops? mmap/munmap/mremap/madvise etc.?
> 
> Look for down_write operations on mmap_sem. Things like set_brk etc.

Sure, I thought you had something specific in mind. 

The only relevant thing for faults is vma's (afaict) and any operation
that changes those either fudges PTEs and thus needs the PTE lock, or
leaves the fault valid in which case the extended validation should find
it so.

> > The idea is that any change to a vma (which would require exclusive
> > mmap_sem) will replace the vma - marking the old one dead and SRCU free
> > it.
> 
> That is a classic RCU approach. The problem then is that operations may
> continue on the stale object. You need to make sure that no modifications
> can occur to the original VMA while it exists in two version.
> 
> > struct vm_area_struct *find_vma(mm, addr)
> > {
> > again:
> > 	rcu_read_lock(); /* solely for the lookup structure */
> > 	vma = tree_lookup(&mm->vma_tree, addr); /* vma is srcu guarded */
> > 	rcu_read_unlock();
> > 	if (vma && vma_is_dead(vma))
> > 		goto again;
> >
> > 	return vma;
> 
> Dont you need to check and increase the refcount in the rcu section (in
> the absence of any other locking) to make sure that the object still
> exists when you refer to it next?

/* vma is srcu guarded */

taking a ref on the vma is just as bad as using mmap_sem - we might as
well not bother with the whole ordeal in that case.

> > /*
> >  * validates if a previously obtained vma is still valid,
> >  * synchronizes with vma against PTL.
> >  */
> > int validate_vma(mm, vma, addr)
> > {
> > 	ASSERT_PTL_LOCKED(mm, addr);
> >
> > 	if (!vma_is_dead(vma))
> > 		return 1;
> >
> > 	vma2 = find_vma(mm, addr);
> >
> > 	if (/*old vma fault is still valid in vma2*/)
> > 		return 1
> >
> > 	return 0;
> > }
> 
> This can only be done while the refcount is elevated.

Like above, we're still in the one SRCU section. The basic idea is to
replace down_read/up_read with srcu_read_lock/srcu_read_unlock for
faults, since the latter scales (or can scale) but a single lock can
not.

> > > srcu may have too much of an overhead for this.
> >
> > Then we need to fix that ;-) But surely SRCU is cheaper than mmap_sem.
> 
> Holding off frees for a long time (sleeping???) is usually bad for cache
> hot behavior. It introduces cacheline refetches. Avoid if possible.

Well, what do you rather have, mmap_sem cacheline bouncing and
contention?

Do you think the small vma slab will suffer significantly on the
relatively expensive exclusive mmap_sem operations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
