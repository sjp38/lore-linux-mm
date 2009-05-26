Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 567AC6B0062
	for <linux-mm@kvack.org>; Tue, 26 May 2009 06:12:40 -0400 (EDT)
Date: Tue, 26 May 2009 11:12:45 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Determine if mapping is MAP_SHARED using VM_MAYSHARE
	and not VM_SHARED in hugetlbfs
Message-ID: <20090526101245.GA4345@csn.ul.ie>
References: <20090519083619.GD19146@csn.ul.ie> <Pine.LNX.4.64.0905252122370.8557@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905252122370.8557@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: npiggin@suse.de, apw@shadowen.org, agl@us.ibm.com, ebmunson@us.ibm.com, andi@firstfloor.org, david@gibson.dropbear.id.au, kenchen@google.com, wli@holomorphy.com, akpm@linux-foundation.org, starlight@binnacle.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 25, 2009 at 10:09:43PM +0100, Hugh Dickins wrote:
> On Tue, 19 May 2009, Mel Gorman wrote:
> 
> > hugetlbfs reserves huge pages and accounts for them differently depending
> > on whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. However, the
> > check made against VMA->vm_flags is sometimes VM_SHARED and not VM_MAYSHARE.
> > For file-backed mappings, such as hugetlbfs, VM_SHARED is set only if the
> > mapping is MAP_SHARED *and* it is read-write. For example, if a shared
> > memory mapping was created read-write with shmget() for populating of data
> > and mapped SHM_RDONLY by other processes, then hugetlbfs gets the accounting
> > wrong and reservations leak.
> > 
> > This patch alters mm/hugetlb.c and replaces VM_SHARED with VM_MAYSHARE when
> > the intent of the code was to check whether the VMA was mapped MAP_SHARED
> > or MAP_PRIVATE.
> > 
> > The patch needs wider review as there are places where we really mean
> > VM_SHARED and not VM_MAYSHARE. I believe I got all the right places, but a
> > second opinion is needed. When/if this patch passes review, it'll be needed
> > for 2.6.30 and -stable as it partially addresses the problem reported in
> > http://bugzilla.kernel.org/show_bug.cgi?id=13302 and
> > http://bugzilla.kernel.org/show_bug.cgi?id=12134.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> After another session looking at this one, Mel, I'm dubious about it.
> 

That doesn't surprise me. The patch is a lot less clear cut which is why
I wanted more people to think about it.

> Let's make clear that I never attempted to understand hugetlb reservations
> and hugetlb private mappings at the time they went in; and after a little
> while gazing at the code, I wouldn't pretend to understand them now.  It
> would be much better to hear from Adam and Andy about this than me.
> 

For what it's worth, I wrote chunks of the reservation code, particularly
with respect to the private reservations. It wasn't complete enough though
which Andy fixed up as I was off for two weeks holiday at the time bugs
came to light (thanks Andy!). Adam was active in hugetlbfs when the shared
reservations were first implemented. Thing is, Adam is not active in kernel
work at all any more and while Andy still is, it's not in this area. Hopefully
they'll respond, but they might not.

> You're right to say that VM_MAYSHARE reflects MAP_SHARED, where VM_SHARED
> does not.  But your description of VM_SHARED isn't quite clear: VM_SHARED
> is used if the file was opened read-write and its mapping is MAP_SHARED,
> even when the mapping is not PROT_WRITE (since the file was opened read-
> write, the mapping is eligible for an mprotect to PROT_WRITE later on).
> 

Very true, I've cleared that up in the description. For anyone watching,
the relevant code is

                        vm_flags |= VM_SHARED | VM_MAYSHARE;
                        if (!(file->f_mode & FMODE_WRITE))
                                vm_flags &= ~(VM_MAYWRITE | VM_SHARED);


> Yes, mm/hugetlb.c uses VM_SHARED throughout, rather than VM_MAYSHARE;
> and that means that its reservations behaviour won't quite follow the
> MAP_SHARED/MAP_PRIVATE split; but does that actually matter, so long
> as it remains consistent with itself? 

It needs to be consistent with itself at minimum. The purpose of the
reservations in hugetlbfs is so that future faults will succeed for the
process that called mmap(). It's not going to be a perfect match to the core
VM although as always, I'd like to bring it as close as possible.

> It would be nicer if it did
> follow that split, but I wouldn't want us to change its established
> behaviour around now without better reason.
> 
> You suggest that you're fixing an inconsistency in the reservations
> behaviour, but you don't actually say what; and I don't see any
> confirmation from Starlight that it fixes actual anomalies seen.
> I'm all for fixing the bugs, but it's not self-evident that this
> patch does fix any: please explain in more detail.
> 

Minimally, this patch fixes a testcase I added to libhugetlbfs
specifically for this problem. It's in the "next" branch of libhugetlbfs
and should be released as part of 2.4.

# git clone git://libhugetlbfs.git.sourceforge.net/gitroot/libhugetlbfs
# cd libhugetlbfs
# git checkout origin/next -b origin-next
# make
# ./obj/hugeadm --create-global-mounts
# ./obj/hugeadm --pool-pages-min 2M:128
# make func

The test that this patch fixes up is shm-perms. It can be run directly
with just

# ./tests/obj32/shm-perms

Does this help explain the problem any better?

======
hugetlbfs reserves huge pages and accounts for them differently depending on
whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. For MAP_SHARED
mappings, hugepages are reserved when mmap() is first called and are
tracked based on information associated with the inode. MAP_PRIVATE track
the reservations based on the VMA created as part of the mmap() operation.

However, the check hugetlbfs makes when determining if a VMA is MAP_SHARED
is with the VM_SHARED flag and not VM_MAYSHARE.  For file-backed mappings,
such as hugetlbfs, VM_SHARED is set only if the mapping is MAP_SHARED
and the file was opened read-write. If a shared memory mapping was mapped
shared-read-write for populating of data and mapped shared-read-only by
other processes, then hugetlbfs gets inconsistent on how it accounts for
the creation of reservations and how they are consumed.
======

> I've ended up worrying about the VM_SHAREDs you've left behind in
> mm/hugetlb.c: unless you can pin down exactly what you're fixing
> with this patch, my worry is that you're unbalancing the existing
> reservation assumptions.  Certainly the patch shouldn't go in
> without libhugetlbfs testing by libhugetlbfs experts.
> 

libhugetlbfs experts are thin on the ground. Currently, there are only two
that are active in its development - Eric Munson and myself. The previous
maintainer, Nish Aravamudan, moved away from hugepage development some time
ago. I did run though the tests and didn't spot additional regressions.

Best, I go through the remaining VM_SHARED and see what they are used
for and what the expectation is.

copy_hugetlb_page_range
	Here, it's used to determine if COW is happening. In that case
	it wants to know that the mapping it's dealing with is shared
	and read-write so I think that's ok.

hugetlb_no_page
	Here, we are checking if COW should be broken early and then 
	it's checking for the right write attribute for the page tables.
	Think that's ok too.

follow_hugetlb_page
	This is checking of the zero page can be shared or not. Crap,
	this one looks like it should have been converted to VM_MAYSHARE
	as well.

V2 is below which converts follow_hugetlb_page() as well.

> Something I've noticed, to confirm that I can't really expect
> to understand how hugetlb works these days.  I experimented by
> creating a hugetlb file, opening read-write, mmap'ing one page
> shared read-write (but not faulting it in);

At this point, one hugepage is reserved for the mapping but is not
faulted and does not exist in the hugetlbfs page cache.

> opening read-only,
> mmap'ing the one page read-only (shared or private, doesn't matter),
> faulting it in (contains zeroes of course);

Of course.

> writing ffffffff to
> the one page through the read-write mapping,

So, now a hugepage has been allocated and inserted into the page cache.

> then looking at the
> read-only mapping - still contains zeroes, whereas with any
> normal file and mapping it should contain ffffffff, whether
> the read-only mapping was shared or private.
> 

I think the critical difference is that a normal file exists on a physical
medium so both processes share the same data source. How would the normal
file mapping behave on tmpfs for example? If tmpfs behaves correctly, I'll
try and get hugetlbfs to match.

There is one potential problem in there. I would have expected the pages
to be shared if the second process was mapping MAP_SHARED because the
page should have been in the page cache when the read-write process
faulted. I'll check it out.

> And to fix that would need more than just a VM_SHARED to VM_MAYSHARE
> change, wouldn't it?  It may well not be something fixable: perhaps
> there cannot be a reasonable private reservations strategy without
> that non-standard behaviour.
> 
> But it does tell me not to trust my own preconceptions around here.
> 

I'll have a look at that behaviour after this bug gets cleared up and see what
I can find. My expectation is that anything I find in that area though will be
more than the VM_SHARED vs VM_MAYSHARE though.

Here is V2 of the patch. Starlight, can you confirm this patch fixes
your problem for 2.6.29.4? Eric, can you confirm this passes
libhugetlbfs tests and not screw something else up?

Thanks

==== CUT HERE ====
