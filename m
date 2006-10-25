Date: Wed, 25 Oct 2006 20:09:29 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
Message-ID: <20061025100929.GA11040@localhost.localdomain>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com> <Pine.LNX.4.64.0610250335530.30678@blonde.wat.veritas.com> <20061025062610.GB2330@localhost.localdomain> <Pine.LNX.4.64.0610250841250.8576@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610250841250.8576@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 25, 2006 at 09:39:10AM +0100, Hugh Dickins wrote:
> On Wed, 25 Oct 2006, David Gibson wrote:
> > On Wed, Oct 25, 2006 at 03:38:24AM +0100, Hugh Dickins wrote:
> > > If you truncated an mmap'ed hugetlbfs file, then faulted on the truncated
> > > area, /proc/meminfo's HugePages_Rsvd wrapped hugely "negative".  Reinstate
> > > my preliminary i_size check before attempting to allocate the page (though
> > > this only fixes the most obvious case: more work will be needed here).
> > > 
> > > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> > > ___
> > > 
> > > This is not a complete solution (what if hugetlb_no_page is actually
> > > racing with truncate_hugepages?), and there are several other accounting
> > > anomalies in here (private versus shared pages, hugetlbfs quota handling);
> > > but those all need more thought.  It'll probably make sense to use i_mutex
> > > instead of hugetlb_instantiation_mutex, so locking out truncation
> > > and mmap.
> > 
> > Ah, yes.  I also encountered this one a few days ago - I found it in
> > the context of deserializing the hugepage fault path, which makes the
> > problem worse, and forgot to consider if there was also a problem in
> > the original case.
> > 
> > In fact, there's a second problem with the current location of the
> > i_size check.  As well as wrapping the reserved count, if there's a
> > fault on a truncated area and the hugepage pool is also empty, we can
> > get an OOM SIGKILL instead of the correct SIGBUS.
> 
> That's exactly why I put in the preliminary i_size check originally,
> which you guys then decided was unnecessary.

We did?  That was silly of us..

> But it wasn't worth
> arguing over which particular error manifested in that case.

> > I don't things are quite as bad as you fear, though:  I believe the
> > page lock protects us against racing concurrent truncations (this is
> > one reason we have find_lock_page() here, rather than the
> > find_get_page() which appears in the analagous normal page path).
> 
> The page lock protects once you've got it.  But when getting a new
> page, there's a sequence of operations before getting the page lock,
> where a racing truncate may occur, and then we may add a page to cache
> beyond the i_size.  And not remove it until the file is retruncated
> or deleted or mount unmounted: not the worst of leaks, but not what
> we want either.

Ah.  Yes.  Indeed.

Possibly we need to duplicate the truncate_count logic from the normal
page path.

> > I suggest the slightly revised patch below, which doesn't duplicate
> > the i_size test, and cleans up the backout path (removing a
> > no-longer-useful goto label) in the process.
> 
> I don't see the advantage of that version: I'd rather stick with my
> clearly-not-worse two-liner for 2.6.19, and work on fixing it all up
> properly later.

Yeah, I guess so.

> I was only trying to fix the prio_tree issue (which had led me to
> mislead Ken on his prio_tree use - thankfully he ignored me and stuck
> with what worked): but each time I tested something I found something
> else wrong, right now must switch away, so posting the obvious bits.
> 
> To expand a little on the other problems here: the hugetlb_get_quota
> and hugetlb_put_quota calls are suspect but hard to get right, and
> the resv_huge_pages-- in alloc_huge_page a problem too I think.
> Cached versus private pages seems confused (private pages should
> not be counted out of the superblock quota).
> 
> It would probably straighten out if hugetlb_no_page just dealt with
> with page cache pages (no VM_SHARED versus not path), and left the
> private pages to hugetlb_cow; but that would be wasteful.

In some cases exceedingly wasteful.  I don't think we can do this.

> And almost(?) all the backtracking could be taken out if i_mutex
> were held; hugetlbfs_file_mmap is already taking i_mutex within
> mmap_sem (contrary to usual mm lock ordering, but probably okay
> since hugetlbfs has no read/write, though lockdep may need teaching).
> Though serializing these faults at all is regrettable.

Um, yes.  Especially when I was in the middle of attempting to
de-serialize it.  Christoph Lameter has userspace stuff to do hugepage
initialization (clearing mostly), in parallal, which obviously won't
work with the serialization.  I have a tentative patch to address it,
which replaces the hugetlb_instantiation_mutex with a table of
mutexes, hashed on address_space and offset (or struct mm and address
for MAP_PRIVATE).  Originally I tried to simply remove the mutex, and
just retry faults when we got an OOM but a race was detected.  After
several variants each on 2 or 3 basic approaches, each of which turned
out to be less race-free than I originally thought, I gave up and went
with the hashed mutexes.  Either way though, there will still be
i_size issues to sort out.

I'm also not sure that i_mutex will work in any case.  I'm pretty sure
I looked for a suitable existing lock, before I created
hugetlb_instantiation_mutex.  I'm not at all sure, but I have a nasty
suspicion there's some not-immediately-obvious lock-ordering
constraint that means we can't take i_mutex across the fault.

> Things may not be as bad as I fear, but I've certainly not yet
> emerged into the light on it all.
> 
> Hugh
> 

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
