Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070828000648.GB14109@wotan.suse.de>
References: <20070823041137.GH18788@wotan.suse.de>
	 <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de>
	 <1188225247.5952.41.camel@localhost> <20070828000648.GB14109@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 28 Aug 2007 10:52:46 -0400
Message-Id: <1188312766.5079.77.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-28 at 02:06 +0200, Nick Piggin wrote:
> On Mon, Aug 27, 2007 at 10:34:07AM -0400, Lee Schermerhorn wrote:
> > On Mon, 2007-08-27 at 03:35 +0200, Nick Piggin wrote:
> > > On Fri, Aug 24, 2007 at 04:43:38PM -0400, Lee Schermerhorn wrote:
> > > > Nick:
> > > > 
> > > > For your weekend reading pleasure [:-)]
> > > > 
> > > > I have reworked your "move mlocked pages off LRU" atop my "noreclaim
> > > > infrastructure" that keeps non-reclaimable pages [mlocked, swap-backed
> > > > but no swap space, excessively long anon_vma list] on a separate
> > > > noreclaim LRU list--more or less ignored by vmscan.  To do this, I had
> > > > to <mumble>add<mumble>a new<mumble>mlock_count member<mumble>to
> > > > the<mumble>page struct.  This brings the size of the page struct to a
> > > > nice, round 64 bytes.  The mlock_count member and [most of] the
> > > > noreclaim-mlocked-pages work now depends on CONFIG_NORECLAIM_MLOCK which
> > > > depends on CONFIG_NORECLAIM.  Currently,  the entire noreclaim
> > > > infrastructure is only supported on 64bit archs because I'm using a
> > > > higher order bit [~30] for the PG_noreclaim flag.
> > > 
> > > Can you keep the old system of removing mlocked pages completely, and
> > > keeping the mlock count in one of the lru pointers? That should avoid
> > > the need to have a new mlock_count, I think, because none of the other
> > > noreclaim types should need a refcount?
> > 
> > Well, keeping the mlock count in the lru pointer more or less defeats
> > the purpose of this exercise for me--that is, a unified mechanism for
> > tracking "non-reclaimable" pages.  I wanted to maintain the ability to
> > use the zone lru_lock and isolate_lru_page() to arbitrate access to
> > pages for migration, etc. w/o having to temporarily put the pages back
> > on the lru during migration.   
> > 
> > And, by using another LRU list for non-reclaimable pages, the
> > non-reclaimable nature of locked, un-swappable, ... pages becomes
> > transparent to much of the rest of VM.  vmscan and try_to_unmap*() still
> > have to handle lazy culling of non-reclaimable pages.  If/when you do
> > get a chance to look at the patches, you'll see that I separated the
> > culling of non-reclaimable pages in the fault path into a separate
> > patch.  We could eliminate this overhead in the fault path in favor of
> > lazy culling in vmscan.  Vmscan would only have to deal with these pages
> > once to move them to the noreclaim list.
> 
> I don't have a problem with having a more unified approach, although if
> we did that, then I'd prefer just to do it more simply and don't special
> case mlocked pages _at all_. Ie. just slowly try to reclaim them and
> eventually when everybody unlocks them, you will notice sooner or later.

I didn't think I was special casing mlocked pages.  I wanted to treat
all !page_reclaimable() pages the same--i.e., put them on the noreclaim
list.

> 
> But once you do the code for mlock refcounting, that's most of the hard
> part done so you may as well remove them completely from the LRU, no?
> Then they become more or less transparent to the rest of the VM as well.

Well, no.  Depending on the reason for !reclaimable, the page would go
on the noreclaim list or just be dropped--special handling.  More
importantly [for me], we still have to handle them specially in
migration, dumping them back onto the LRU so that we can arbitrate
access.  If I'm ever successful in getting automatic/lazy page migration
+replication accepted, I don't want that overhead in
auto-migration/replication.

> 
> 
> > > I do approve of bringing struct page to a nice round 64 bytes ;), but I
> > > think I would rather we used up those 8 bytes by making count and
> > > mapcount 8 bytes each.
> > 
> > I knew the new page struct member would be controversial, at best, but
> > it allows me to prototype and test this approach.  I'd like to find
> > somewhere else to put the mlock count, but the page struct it pretty
> > tight as it is.  It occurred to me that while anon and other swap-backed
> > pages are mlocked, I might be able to use the private field as the mlock
> > count.  I don't understand the interaction of vm with file systems to
> > know if we could do the same for file-backed pages.  Maybe a separate
> > PG_mlock flag would allow one to move the page's private contents to an
> > external structure along with the mlock count?  Or maybe just with
> > PG_noreclaim, externalize the private info?
>  
> Could be possible. Tricky though. Probably take less code to use
> ->lru ;)

Oh, certainly less code to use any separate field.  But the lru list
field is the only link we have in the page struct, and a lot of VM
depends on being able to pass around lists of pages.  I'd hate to lose
that for mlocked pages, or to have to dump the lock count and
reestablish it in those cases, like migration, where we need to put the
page on a list.

> 
> 
> > Another approach that I've seen used elsewhere, IFF we can find a
> > smaller bit field for the mlock count:  maintain a mlock count in a bit
> > field that is too small to contain max possible lock count.  [Probably
> > don't need all 64-bits, in any case.]  Clip the count at maximum that
> > the field can contain [like SWAP_MAP_MAX] and fail mlock attempts if the
> > count won't accommodate the additional lock.  I haven't investigated
> > this enough to determine what additional complications it would involve.
> > It would probably complicate inheriting locks across fork(), if we ever
> > want to do that [I do!].
> 
> Well instead of failing further mlocks, you could just have MLOCK_MAX
> signal that counting is disabled, and require a full rmap scan in order
> to reclaim it. 

Yeah.  But, rather than totally disabling the counting, I'd suggest to
go ahead and decrement the count [! < 0, of course] on unmap/unlock.
If it's infrequent, we could just let try_to_unmap*() cull pages in
VM_LOCKED vmas when it's already doing the full rmap scan, and have
shrink_page_list() put it on noreclaim list when try_to_unmap() returns
SWAP_LOCK.

This does mean that we won't be able to cull the mlocked pages early in
shrink_[in]active_list() via !page_reclaimable().  So, we still have to
do the complete rmap scan for page_referenced() [why do we do this?
don't trust mapcount?]  and then again for try_to_unmap().    We'd
probably also want to cull new pages in the fault path, where the vma is
available.  This would reduce the number of mlocked pages encountered on
the LRU lists by vmscan.

If we're willing to live with this [increased rmap scans on mlocked
pages], we might be able to dispense with the mlock count altogether.
Just a single flag [somewhere--doesn't need to be in page flags member]
to indicate mlocked for page_reclaimable().  munmap()/munlock() could
reset the bit and put the page back on the [in]active list.  If some
other vma has it locked, we'll catch it on next attempt to unmap.

> 
> 
> > Any thoughts on restricting this to 64-bit archs?
> 
> I don't know. I'd have thought efficient mlock handling might be useful
> for realtime systems, probably many of which would be 32-bit.

I agree.  I just wonder if those systems have a sufficient number of
pages that they're suffering from the long lru lists with a large
fraction of unreclaimable pages...  If we do want to support keeping
nonreclaimable pages off the [in]active lists for these systems, we'll
need to find a place for the flag[s].

> 
> Are you seeing mlock pinning heaps of memory in the field?

It is a common usage to mlock() large shared memory areas, as well as
entire tasks [MLOCK_CURRENT|MLOCK_FUTURE].  I think it would be even
more frequent if one could inherit MLOCK_FUTURE across fork and exec.
Then one could write/enhance a prefix command, like numactl and taskset,
to enable locking of unmodified applications.  I prototyped this once,
but never updated it to do the mlock accounting [e.g., down in
copy_page_range() during fork()] for your patch.

What we see more of is folks just figuring that they've got sufficient
memory [100s of GB] for their apps and shared memory areas, so they
don't add enough swap to back all of the anon and shmem regions.  Then,
when they get under memory pressure--e.g., the old "backup ate my
pagecache" scenario--the system more or less live-locks in vmscan
shuffling non-reclaimable [unswappable] pages.  A large number of
mlocked pages on the LRU produces the same symptom; as do excessively
long anon_vma lists and huge i_mmap trees--the latter seen with some
large Oracle workloads.

> 
>  
> > > I haven't had much look at the patches yet, but I'm glad to see the old
> > > mlocked patch come to something ;)
> > 
> > Given the issues we've encountered in the field with a large number
> > [millions] of non-reclaimable pages on the LRU lists, the idea of hiding
> > nonreclaimable pages from vmscan is appealing.  I'm hoping we can find
> > some acceptable way of doing this in the long run.
> 
> Oh yeah I think that's a good idea, especially for less transient
> conditions like mlock and out-of-swap.

This is all still a work in progress.  I'll keep it up to date, run
occasional benchmarks to measure effects and track the other page
reclaim activity on the lists and see where it goes...

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
