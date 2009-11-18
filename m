Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CD08D6B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 11:27:18 -0500 (EST)
Date: Wed, 18 Nov 2009 16:27:01 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] prevent deadlock in __unmap_hugepage_range() when
 alloc_huge_page() fails.
In-Reply-To: <20091117160922.GB29804@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0911181602430.29205@sister.anvils>
References: <1257872456.3227.2.camel@dhcp-100-19-198.bos.redhat.com>
 <20091116121253.d86920a0.akpm@linux-foundation.org> <20091117160922.GB29804@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Larry Woodman <lwoodman@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Adam Litke <agl@us.ibm.com>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 2009, Mel Gorman wrote:
> On Mon, Nov 16, 2009 at 12:12:53PM -0800, Andrew Morton wrote:
> > On Tue, 10 Nov 2009 12:00:56 -0500
> > Larry Woodman <lwoodman@redhat.com> wrote:
> > 
> > > hugetlb_fault() takes the mm->page_table_lock spinlock then calls
> > > hugetlb_cow().  If the alloc_huge_page() in hugetlb_cow() fails due to
> > > an insufficient huge page pool it calls unmap_ref_private() with the
> > > mm->page_table_lock held.  unmap_ref_private() then calls
> > > unmap_hugepage_range() which tries to acquire the mm->page_table_lock.
> > 
> > Confused.
> > 
> > That code is very old, alloc_huge_page() failures are surely common and
> > afaict the bug will lead to an instantly dead box.  So why haven't
> > people hit this bug before now?
> > 
> 
> Failures like that can happen when the workload is calling fork() with
> MAP_PRIVATE and the child is writing with a small hugepage pool. I reran the
> tests used at the time the code was written and they don't trigger warnings or
> problems in the normal case other than the note that the child got killed. It
> required PROVE_LOCKING to be set which is not set on the default configs I
> normally use when I don't suspect locking problems.
> 
> I can confirm that with PROVE_LOCKING set that the warnings do trigger but
> the machine doesn't lockup and I see in dmesg. Bit of a surprise really,
> you'd think a double taking of a spinlock would result in damage.

It would be a surprise if it were the same mm->page_table_lock being
taken in both cases.  But isn't it unmap_ref_private()'s job to go
looking through the _other_ vmas (typically other mms) mapping the same
hugetlbfs file, operating on them?  So PROVE_LOCKING complains about
a possible ABBA deadlock, rather than a straight AA deadlock.

> 
> [  111.031795] PID 2876 killed due to inadequate hugepage pool
> 
> Applying the patch does fix that problem but there is a very similar
> problem remaining in the same path. More on this later.
> 
> > > This can be fixed by dropping the mm->page_table_lock around the call 
> > > to unmap_ref_private() if alloc_huge_page() fails, its dropped right below
> > > in the normal path anyway:
> > > 
> > 
> > Why is that safe?  What is the page_table_lock protecting in here?
> > 
> 
> The lock is there from 2005 and it was to protect against against concurrent
> PTE updates. However, it is probably unnecessary protection as this whole
> path should be protected by the hugetlb_instantiation_mutex. There was locking
> that was left behind that may be unnecessary after that mutex was introducted
> but is left in place for the day someone decides to tackle that mutex.

Yes, we all hoped the instantiation_mutex would go away, and some things
will remain doubly protected because of it.  The page_table_lock is what
_should_ be protecting the PTEs, but without delving deeper, I can't
point to what it is absolutely needed for here and now.

I was going to refer to fork() duplicating the pagetables at an awkward
point, protecting against that.  But dup_mmap() does down_write() of
mmap_sem, so there won't be any faults concurrent with it.  Umm, umm...

> 
> I don't think this patch solves everything with the page_table_lock in
> that path because it's also possible from the COW path to enter the buddy
> allocator with the spinlock still held with setups like
> 
> 1. create a mapping of 3 huge pages
> 2. allow the system to dynamically allocate 6 huge pages
> 3. fork() and fault in the child
> 	with preempt and DEBUG_SPINLOCK_SLEEP set, a different
> 	warning can still trigger
> 
> Here is alternative patch below which extends Larry's patch to drop the
> spinlock earlier and retake as required. Because it involves page table
> updates, I've added Hugh to the cc because he knows all the rules and
> gotchas backwards.

I am deeply flattered by your touching but misplaced faith ;)
I did get involved when hugetlb faulting first came in, but
haven't looked here for a long time.

Certainly your new patch looks even better than the first:
I think originally hugetlb_fault() (maybe called something different
back then) was designed to be sure that no allocations could possibly
be made while holding that spinlock, but things have evolved since then.

But I notice something else that worries me more: no need to fix it in
the same patch, but what locking does unmap_ref_private() think it has,
for it to do that vma_prio_tree_foreach() safely?  Unless there's
another instantiation_mutex-like trick protecting it, surely it
needs the i_mmap_lock for that?  Which unmap_hugepage_range() grabs
for each vma before calling __unmap_hugepage_range(), so it should
be easy to move that up around the whole loop.  But as it stands,
it looks to me like the whole prio_tree could shift around like
quicksand underneath unmap_ref_private().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
