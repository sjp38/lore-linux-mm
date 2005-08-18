Date: Thu, 18 Aug 2005 21:16:58 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <20050817174359.0efc7a6a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, clameter@engr.sgi.com, piggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Aug 2005, Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > I have vague feelings of ickiness with the patches wrt:
> > 
> >  a) general increase of complexity
> > 
> >  b) the fact that they only partially address the problem: anonymous page
> >     faults are addressed, but lots of other places aren't.
> > 
> >  c) the fact that they address one particular part of one particular
> >     workload on exceedingly rare machines.
> 
> d) the fact that some architectures will be using atomic pte ops and
>    others will be using page_table_lock in core MM code.
> 
>    Using different locking/atomicity schemes in different architectures
>    has obvious complexity and test coverage drawbacks.
> 
>    Is it still the case that some architectures must retain the
>    page_table_lock approach because they use it to lock other arch-internal
>    things?

With the addition of (d) you've got a good summary of my objections,
without my having to write a word - thank you.

I'll add scattered observations here.
Towards the end, I do have a constructive alternative (*).

There's a lot about atomic pte ops in this thread, but it's a pte
cmpxchg which do_anonymous_page has to do - if I remember PaulMcK's
bogroll rightly, cmpxchgs are extra bad news.

Christoph and Nick are keen to go further, deeper into the atomics
and cmpxchgs, away from the page table lock.  Is that sensible when
we have batch operations like zap_pte_range and copy_pte_range?

Christoph's current patch does _not_ increase the need for atomics
in those two (except for rss and anon_rss, but we'd do well to batch
those updates anyway - zap_pte_range's tlb stuff half does it).  It
does have to ptep_cmpxchg in mprotect and ptep_xchg in try_to_unmap,
but I guess neither of those is a serious worry.

Nobody (except me, in the last few days) has actually been testing
whether these patches do anything for page fault scalability since
they went into -mm.  Proof: if that's what you're testing, you very
soon hit the BUG_ON(mm->nr_ptes...) at the end of exit_mmap.  And
once you've worked your way through the architectural maze, you
realize that nr_ptes used to be protected by page_table_lock but
is currently unprotected when CONFIG_ATOMIC_TABLE_OPS.  (I fixed
that here by adding back page_table_lock around it, but Christoph
will probably prefer to go atomic with it; for people just testing
the scalability, it's okay to remove that BUG_ON for the moment.)

Christoph likes to assure us "No this is a general fix for anonymous
page faults on SMP machines.  As noted at the KS, other are seeing
similar performance problems".  Perhaps, but if so, they should be
speaking up, telling us Christoph's patches solve their problems,
and providing patches to convert their architectures over.

How many architectures have been converted to ATOMIC_TABLE_OPS
(could we call that ATOMIC_PAGE_TABLE_OPS?): just ia64, x86_64
and i386.  i386 being a joke, since it's only the non-PAE case
which is converted, yet surely anyone getting into a serious
number of cpus on i386 will be using PAE?

I may well be to blame for this.  Perhaps my hostility has
discouraged others from doing the work to add to what's there.
Certainly it was me who advised Christoph to drop the i386 PAE
support he originally had, since it was too ugly and buggy.

And it was probably my resistance to the per-task rss patch which
has led him to hold that back for now.  I think wisely, that is a
separate issue.  But from what Linus says, it does rather look like
we can't sensibly go forward with anonymous pte cmpxchging, without
a matching rss solution.

My resistance to the rss patch (then, haven't seen a recent) was all
this infrastructure for a just couple of counts which don't really
matter.  (There were three places in rmap.c which avoided rss 0 mms,
but that was a historic necessity: I've deleted those checks from the
rmap.c waiting in -mm.)  Can't we just let them be racy?

Plus, fear of tools looking into /proc for the rss of one of Christoph's
512-threaded processes, and each lookup of each thread of the process
examining every other task_struct of the process?  We need somehow to
prevent that, to look no further than the mm_struct in most cases.

(*) I realized that the time was coming to decide one way or the other
on these page fault scalability patches in -mm.  So I've spent the
last few days prototyping an alternative, to see how well it compares.

The thing I really like in Christoph's patches is not the cmpxchging,
but the narrowing of the page table lock.  There is very little need
to be holding it across the pgd->pud->pmd->pt traversals: in general
you can enter the do_..._page functions without acquiring page table
lock at all, entering them with a "speculative" entry which need only
be confirmed by pte_same once new page has been allocated.  (The
PAE case does need to be more careful about it, though it can still
avoid preliminary page table lock at least in do_anonymous_page case.)

This advantage applies to all architectures, though a few will need
a bit more research and care (the question you ask in your (d)).  In
most of the loops, it's mainly a matter of removing page_table_lock
from the outer level, and inserting it at the inner pte level (which
pleases the low latency people too).  It satisfies Linus' desire to
reduce the locking in the simple anonymous case, on all architectures.

Perhaps it was Nick who first pointed this out to me, or was it me to
him, I forget?  we simply have to be careful to unlink a vma from its
prio_tree and from its anon_vma in free_pgtables, before any page
tables are freed - that way, vmscan's rmap functions cannot reach
page tables on their way to being freed.

With the page table lock moved inward, we can then easily choose to
use a per-pagetable lock, to handle the page fault scalability issue
without departing far from our existing locking conventions.  Indeed,
I have a working prototype for that, but I don't have equipment to test
scalability on SGI's scale, and on my 2*HT*Xeons the best results are
coming from just narrowing the page table lock, not from splitting it.

I'm not ready.  The patches, as I say, are currently just prototypes,
and mix in the usual tidyups I cannot resist when hacking (e.g. why
does almost every do_..._page have its arguments in a different order?).
I was intent on getting numbers, hoping to find that the numbers which
emerge from this would be clearly better than with Christoph's patches.
But no, they're comparable (on my puny machines), in some cases one
or the other better (of course mine do work out better for PAE, and
presumably for any non-ATOMIC_TABLE_OPS-architetures, but you could
say I loaded the dice against Christoph there).

I find proceeding in this way easier to understand, and would myself
prefer Christoph's patches removed from -mm, so we can build the
narrower page_table_lock solution there, then see what works best
as a scalability solution on top - per-pagetable locking, or pte
cmpxchging.  But we all find our own ways easier to understand.

You might like me to post my patch for testing (not for merging into
any tree at this stage): please give me a couple of days to jiggle
around with it first.

Nick (if you've got this far), you mention in one of your mails of this
thread, that you remove page_table_lock from around the tlb mmu_gather
stuff: yes, me too, but I did it with less awareness, and your comment
makes me realize it needs a little more care.  Did you actually find
a problem with that (beyond needing preempt_disable, which ought to go
into them anyway) on some architecture, or were you just voicing caution?

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
