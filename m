Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA1D6B005D
	for <linux-mm@kvack.org>; Tue, 26 May 2009 20:48:21 -0400 (EDT)
Date: Wed, 27 May 2009 01:48:59 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Determine if mapping is MAP_SHARED using VM_MAYSHARE
	and not VM_SHARED in hugetlbfs
Message-ID: <20090527004859.GB6189@csn.ul.ie>
References: <20090519083619.GD19146@csn.ul.ie> <Pine.LNX.4.64.0905252122370.8557@sister.anvils> <20090526101245.GA4345@csn.ul.ie> <Pine.LNX.4.64.0905262056150.958@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905262056150.958@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, npiggin@suse.de, apw@shadowen.org, agl@us.ibm.com, ebmunson@us.ibm.com, andi@firstfloor.org, david@gibson.dropbear.id.au, kenchen@google.com, wli@holomorphy.com, akpm@linux-foundation.org, starlight@binnacle.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 26, 2009 at 09:51:19PM +0100, Hugh Dickins wrote:
> On Tue, 26 May 2009, Mel Gorman wrote:
> > On Mon, May 25, 2009 at 10:09:43PM +0100, Hugh Dickins wrote:
> > ...
> > > Let's make clear that I never attempted to understand hugetlb reservations
> > > and hugetlb private mappings at the time they went in; and after a little
> > > while gazing at the code, I wouldn't pretend to understand them now.  It
> > > would be much better to hear from Adam and Andy about this than me.
> > 
> > For what it's worth, I wrote chunks of the reservation code, particularly
> > with respect to the private reservations.
> 
> Ah, I hadn't realized you were so involved in it from the start: good.
> 
> > It wasn't complete enough though
> > which Andy fixed up as I was off for two weeks holiday at the time bugs
> > came to light (thanks Andy!). Adam was active in hugetlbfs when the shared
> > reservations were first implemented. Thing is, Adam is not active in kernel
> > work at all any more
> 
> And I hadn't realized that either (I did notice you'd left Adam off
> this thread, but he was on the other, so I added him to this too).
> 

Cool.

> > and while Andy still is, it's not in this area. Hopefully
> > they'll respond, but they might not.
> 
> ...
> > Minimally, this patch fixes a testcase I added to libhugetlbfs
> > specifically for this problem. It's in the "next" branch of libhugetlbfs
> > and should be released as part of 2.4.
> > 
> > # git clone git://libhugetlbfs.git.sourceforge.net/gitroot/libhugetlbfs
> > # cd libhugetlbfs
> > # git checkout origin/next -b origin-next
> > # make
> > # ./obj/hugeadm --create-global-mounts
> > # ./obj/hugeadm --pool-pages-min 2M:128
> > # make func
> 
> Originally I was going to say that I was sorry you pointed me there;
> because doing that "make func" a second time did nasty things for me,
> hung and eventually quite froze my machines (and not in shm-perms).
> 

Crap, yes, I should have warned you. I've been on a bit of a search for
bugs in hugetlbfs recently. For problems encountered, I added a testcase
to libhugetlbfs so it'd be caught in distros if backports were needed.
Some of those tests can really hurt a vunerable kernel. Sorry :(

> But that was before applying your hugetlb.c patch: the good news
> is that your patch appears to fix all that nastiness.
> 

Nice, good to know.

> > 
> > The test that this patch fixes up is shm-perms. It can be run directly
> > with just
> > 
> > # ./tests/obj32/shm-perms
> > 
> > Does this help explain the problem any better?
> 
> I'm an ingrate: no, it doesn't help much.  I'd have liked to hear how
> to reproduce "gets inconsistent on how it accounts for the creation
> of reservations and how they are consumed", what /proc/meminfo
> looks like in the end. 

Ok, I see the problem with my first description now. This is my fault :(.
I was working on two patches at the same time. One where the hugepage_total
count and hugepage_total free would get out of sync and the second where
the reservations are getting doubled. This patch fixes the latter problem
but I described the reservations as "leaking" which is very misleading.

> I didn't see any such inconsistency when
> I was messing around, and I don't see shm-perms testing for any
> such inconsistency (just testing for whether something you think
> ought to work, does work).
> 

The inconsistency is with hugetlbfs making the reservations. For
MAP_SHARED mappings, one reservation is made that is shared between
processes. Once the first mapping succeeds, future mappings should also
succeed.

For MAP_SHARED-read-write mapping, hugetlbfs is making the reservation
and associating it with the inode correctly.

For MAP_SHARED-read-only mappings, hugetlbfs is maping the reservation
as if it was MAP_PRIVATE - i.e. requiring a full reservation for each
process mapping.

What the test case is checking is that a large number of processes can
map the same mapping multiple times correctly. If the hugepage pool
happened to be particularly massive

> But now I've found your patch fixes my freezes from libhugetlbfs
> testing, I'm much happier with it; and see below for why I'm even
> happier.
> 
> > 
> > ======
> > hugetlbfs reserves huge pages and accounts for them differently depending on
> > whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. For MAP_SHARED
> > mappings, hugepages are reserved when mmap() is first called and are
> > tracked based on information associated with the inode. MAP_PRIVATE track
> > the reservations based on the VMA created as part of the mmap() operation.
> > 
> > However, the check hugetlbfs makes when determining if a VMA is MAP_SHARED
> > is with the VM_SHARED flag and not VM_MAYSHARE.  For file-backed mappings,
> > such as hugetlbfs, VM_SHARED is set only if the mapping is MAP_SHARED
> > and the file was opened read-write. If a shared memory mapping was mapped
> > shared-read-write for populating of data and mapped shared-read-only by
> > other processes, then hugetlbfs gets inconsistent on how it accounts for
> > the creation of reservations and how they are consumed.
> > ======
> 
> ...
> > 
> > Best, I go through the remaining VM_SHARED and see what they are used
> > for and what the expectation is.
> > 
> > copy_hugetlb_page_range
> > 	Here, it's used to determine if COW is happening. In that case
> > 	it wants to know that the mapping it's dealing with is shared
> > 	and read-write so I think that's ok.
> 
> Yes, that test is copied from mm/memory.c and should be okay.
> It's an odd test and could be written in other ways, I think
> 	cow = !(vma->vm_flags & VM_SHARED)
> would be sufficient, wouldn't it? but perhaps that requires
> too much knowledge of how the flags work. 

It should be sufficient. Writing either statement requires a lot of
knowledge of how the flags work unfortunately :/.

> Anyway, no reason
> to change it; though equally you could change it to VM_MAYSHARE.
> 
> > 
> > hugetlb_no_page
> > 	Here, we are checking if COW should be broken early and then 
> > 	it's checking for the right write attribute for the page tables.
> > 	Think that's ok too.
> 
> These were the ones which worried me, since reservation checks (which
> you did change) are called conditional upon them.  But in the end I
> agree with you, they don't need changing: because they're checked
> along with write_access (or VM_WRITE), and you cannot write to
> an area on which VM_SHARED and VM_MAYSHARE differ.
> 

Yep.

> > 
> > follow_hugetlb_page
> > 	This is checking of the zero page can be shared or not. Crap,
> > 	this one looks like it should have been converted to VM_MAYSHARE
> > 	as well.
> 
> Now, what makes you say that?
> 
> I really am eager to understand, because I don't comprehend
> that VM_SHARED at all. 

I think I understand it, but I keep changing my mind on whether
VM_SHARED is sufficient or not.

In this specific case, the zeropage must not be used by process A where
it's possible that process B has populated it with data. when I said "Crap"
earlier, the scenario I imagined went something like;

o Process A opens a hugetlbfs file read/write but does not map the file
o Process B opens the same hugetlbfs read-only and maps it
  MAP_SHARED. hugetlbfs allows mmaps to files that have not been ftruncate()
  so it can fault pages without SIGBUS
o Process A writes the file - currently this is impossible as hugetlbfs
  does not support write() but lets pretend it was possible
o Process B calls mlock() which calls into follow_hugetlb_page().
  VM_SHARED is not set because it's a read-only mapping and it returns
  the wrong page.

This last step is where I went wrong. As process 2 had no PTE for that
location, it would have faulted the page as normal and gotten the correct
page and never considered the zero page so VM_SHARED was ok after all.

But this is sufficiently difficult that I'm worried that there is some other
scenario where Process B uses the zero page when it shouldn't. Testing for
VM_MAYSHARE would prevent the zero page being used incorrectly whether the
mapping is read-only or read-write but maybe that's too paranoid.

Kosaki, can you comment on what impact (if any) testing for VM_MAYSHARE
would have here with respect to core-dumping?

> I believe Kosaki-san's 4b2e38ad simply
> copied it from Linus's 672ca28e to mm/memory.c.  But even back
> when that change was made, I confessed to having lost the plot
> on it: so far as I can see, putting a VM_SHARED test in there
> just happened to prevent some VMware code going the wrong way,
> but I don't see the actual justification for it.
> 

Having no idea how vmware broke exactly, I'm not sure what exactly was
fixed. Maybe by not checking VM_SHARED, it was possible that a caller of
get_user_pages() would not see updates made by a parallel writer.

> So, given that I don't understand it in the first place,
> I can't really support changing that VM_SHARED to VM_MAYSHARE.
> 

Lets see what Kosaki says. If he's happy with VM_SHARED, I'll leave it
alone.

> > > Something I've noticed, to confirm that I can't really expect
> > > to understand how hugetlb works these days.  I experimented by
> > > creating a hugetlb file, opening read-write, mmap'ing one page
> > > shared read-write (but not faulting it in);
> > 
> > At this point, one hugepage is reserved for the mapping but is not
> > faulted and does not exist in the hugetlbfs page cache.
> > 
> > > opening read-only,
> > > mmap'ing the one page read-only (shared or private, doesn't matter),
> > > faulting it in (contains zeroes of course);
> > 
> > Of course.
> > 
> > > writing ffffffff to
> > > the one page through the read-write mapping,
> > 
> > So, now a hugepage has been allocated and inserted into the page cache.
> > 
> > > then looking at the
> > > read-only mapping - still contains zeroes, whereas with any
> > > normal file and mapping it should contain ffffffff, whether
> > > the read-only mapping was shared or private.
> > > 
> > 
> > I think the critical difference is that a normal file exists on a physical
> > medium so both processes share the same data source. How would the normal
> > file mapping behave on tmpfs for example? If tmpfs behaves correctly, I'll
> > try and get hugetlbfs to match.
> 
> tmpfs and ramfs behave just as if there were a normal file existing on
> a physical medium, they behave just like every(?) other filesystem than
> hugetlbfs: a page in a MAP_PRIVATE mapping is shared with the underlying
> object (or other mappings) until it gets modified.
> 

Ok, I'll look at what's involved at making hugetlbfs do the same thing.

> > 
> > There is one potential problem in there. I would have expected the pages
> > to be shared if the second process was mapping MAP_SHARED because the
> > page should have been in the page cache when the read-write process
> > faulted. I'll check it out.
> 
> The big reason why I do now like your patch (modulo your additional
> change to follow_huge_page) is that it seems to fix this for MAP_SHARED.
> It's not quite obvious how it fixes it (you claim to be correcting the
> accounting rather than the actual sharing/COWing of pages), but it does
> seem to do so.
> 

In this case, it's the accounting we are caring about, not the sharing.
>From the point of view of sharing, VM_SHARED vs VM_MAYSHARE may be fine
but the double reservations mean MAP_SHARED fails when it shouldn't.

> (I say "seem to" because I've managed to confuse myself with thoroughly
> erratic results here, but now putting it down to forgetting to remove my
> old test file sometimes, so picking up cached pages from earlier tests;
> or getting in a muddle between my readwrite and readonly fds.  Please
> check it out for yourself, before and after your patch.)
> 

I'll investigate it more and see can I find something new that breaks as
a result of the patch.

> And while I dislike hugetlbfs's behaviour on the MAP_PRIVATE pages,
> I willingly concede that it's much more important that it behave
> correctly on the MAP_SHARED ones (as it stood before, "shared memory"
> was not necessarily getting shared).
> 

Thanks. I'll see what I can do about bringing it closer in line with expected
behaviour in the future.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
