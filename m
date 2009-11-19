Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 362496B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 09:22:57 -0500 (EST)
Date: Thu, 19 Nov 2009 14:22:51 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] prevent deadlock in __unmap_hugepage_range() when
	alloc_huge_page() fails.
Message-ID: <20091119142250.GC22738@csn.ul.ie>
References: <1257872456.3227.2.camel@dhcp-100-19-198.bos.redhat.com> <20091116121253.d86920a0.akpm@linux-foundation.org> <20091117160922.GB29804@csn.ul.ie> <Pine.LNX.4.64.0911181602430.29205@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0911181602430.29205@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Larry Woodman <lwoodman@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Adam Litke <agl@us.ibm.com>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 18, 2009 at 04:27:01PM +0000, Hugh Dickins wrote:
> On Tue, 17 Nov 2009, Mel Gorman wrote:
> > On Mon, Nov 16, 2009 at 12:12:53PM -0800, Andrew Morton wrote:
> > > On Tue, 10 Nov 2009 12:00:56 -0500
> > > Larry Woodman <lwoodman@redhat.com> wrote:
> > > 
> > > > hugetlb_fault() takes the mm->page_table_lock spinlock then calls
> > > > hugetlb_cow().  If the alloc_huge_page() in hugetlb_cow() fails due to
> > > > an insufficient huge page pool it calls unmap_ref_private() with the
> > > > mm->page_table_lock held.  unmap_ref_private() then calls
> > > > unmap_hugepage_range() which tries to acquire the mm->page_table_lock.
> > > 
> > > Confused.
> > > 
> > > That code is very old, alloc_huge_page() failures are surely common and
> > > afaict the bug will lead to an instantly dead box.  So why haven't
> > > people hit this bug before now?
> > > 
> > 
> > Failures like that can happen when the workload is calling fork() with
> > MAP_PRIVATE and the child is writing with a small hugepage pool. I reran the
> > tests used at the time the code was written and they don't trigger warnings or
> > problems in the normal case other than the note that the child got killed. It
> > required PROVE_LOCKING to be set which is not set on the default configs I
> > normally use when I don't suspect locking problems.
> > 
> > I can confirm that with PROVE_LOCKING set that the warnings do trigger but
> > the machine doesn't lockup and I see in dmesg. Bit of a surprise really,
> > you'd think a double taking of a spinlock would result in damage.
> 
> It would be a surprise if it were the same mm->page_table_lock being
> taken in both cases. 

Good point, it should be impossible in fact. A MAP_PRIVATE VMA common to
two processes will be sharing an ancestary - minimally parent/child. For
this case to trigger, it must be two MM.

> But isn't it unmap_ref_private()'s job to go
> looking through the _other_ vmas (typically other mms) mapping the same
> hugetlbfs file, operating on them?

Yes. When the function returns, the only reference to the page should
belong to the process that reserved the hugepage in the first place.

> So PROVE_LOCKING complains about
> a possible ABBA deadlock, rather than a straight AA deadlock.
> 
> > 
> > [  111.031795] PID 2876 killed due to inadequate hugepage pool
> > 
> > Applying the patch does fix that problem but there is a very similar
> > problem remaining in the same path. More on this later.
> > 
> > > > This can be fixed by dropping the mm->page_table_lock around the call 
> > > > to unmap_ref_private() if alloc_huge_page() fails, its dropped right below
> > > > in the normal path anyway:
> > > > 
> > > 
> > > Why is that safe?  What is the page_table_lock protecting in here?
> > > 
> > 
> > The lock is there from 2005 and it was to protect against against concurrent
> > PTE updates. However, it is probably unnecessary protection as this whole
> > path should be protected by the hugetlb_instantiation_mutex. There was locking
> > that was left behind that may be unnecessary after that mutex was introducted
> > but is left in place for the day someone decides to tackle that mutex.
> 
> Yes, we all hoped the instantiation_mutex would go away, and some things
> will remain doubly protected because of it.  The page_table_lock is what
> _should_ be protecting the PTEs, but without delving deeper, I can't
> point to what it is absolutely needed for here and now.
> 

There are a few places that the locking could be removed because of the
mutex. However, I still hold out hope that one day I (or someone else)
will have the time to break the mutex again and having allegedly correct
fine-grained locking already in place will make it easier.

> I was going to refer to fork() duplicating the pagetables at an awkward
> point, protecting against that.  But dup_mmap() does down_write() of
> mmap_sem, so there won't be any faults concurrent with it.  Umm, umm...
> 

Right there shouldn't be. It should be protected against trouble there
by both the hugetlb mutex and down_read on mmap_sem.

> > 
> > I don't think this patch solves everything with the page_table_lock in
> > that path because it's also possible from the COW path to enter the buddy
> > allocator with the spinlock still held with setups like
> > 
> > 1. create a mapping of 3 huge pages
> > 2. allow the system to dynamically allocate 6 huge pages
> > 3. fork() and fault in the child
> > 	with preempt and DEBUG_SPINLOCK_SLEEP set, a different
> > 	warning can still trigger
> > 
> > Here is alternative patch below which extends Larry's patch to drop the
> > spinlock earlier and retake as required. Because it involves page table
> > updates, I've added Hugh to the cc because he knows all the rules and
> > gotchas backwards.
> 
> I am deeply flattered by your touching but misplaced faith ;)

You malign yourself :)

> I did get involved when hugetlb faulting first came in, but
> haven't looked here for a long time.
> 
> Certainly your new patch looks even better than the first:

It also cleans up the very real possibility of going to sleep with a
spinlock held.

> I think originally hugetlb_fault() (maybe called something different
> back then) was designed to be sure that no allocations could possibly
> be made while holding that spinlock, but things have evolved since then.
> 

Yeah, dynamic hugepage pool resizing means we can enter the page
allocator now. If there isn't anything obviously wrong with the patch,
I'd like to go with this version rather than Larry's to clean that up.

> But I notice something else that worries me more: no need to fix it in
> the same patch, but what locking does unmap_ref_private() think it has,
> for it to do that vma_prio_tree_foreach() safely? 

the mutex again, but that doesn't protect against an unexpected munmap()
does it? It is possible if a bad failing fault occured at the same time
as another process was unmapping (or even exiting) that this would run
into trouble?

> Unless there's
> another instantiation_mutex-like trick protecting it, surely it
> needs the i_mmap_lock for that?  Which unmap_hugepage_range() grabs
> for each vma before calling __unmap_hugepage_range(), so it should
> be easy to move that up around the whole loop.  But as it stands,
> it looks to me like the whole prio_tree could shift around like
> quicksand underneath unmap_ref_private().
> 

I think you're right. I'll investigate more but it looks like that needs
a spin_lock(&mapping->i_mmap_lock) around the vma_prio_tree_foreach().
Well spotted!

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
