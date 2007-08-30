Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070829043803.GD25335@wotan.suse.de>
References: <20070823041137.GH18788@wotan.suse.de>
	 <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de>
	 <1188225247.5952.41.camel@localhost> <20070828000648.GB14109@wotan.suse.de>
	 <1188312766.5079.77.camel@localhost> <20070829043803.GD25335@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 30 Aug 2007 12:34:45 -0400
Message-Id: <1188491685.5794.96.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-29 at 06:38 +0200, Nick Piggin wrote:
> On Tue, Aug 28, 2007 at 10:52:46AM -0400, Lee Schermerhorn wrote:
> > On Tue, 2007-08-28 at 02:06 +0200, Nick Piggin wrote:
> > > 
> > > I don't have a problem with having a more unified approach, although if
> > > we did that, then I'd prefer just to do it more simply and don't special
> > > case mlocked pages _at all_. Ie. just slowly try to reclaim them and
> > > eventually when everybody unlocks them, you will notice sooner or later.
> > 
> > I didn't think I was special casing mlocked pages.  I wanted to treat
> > all !page_reclaimable() pages the same--i.e., put them on the noreclaim
> > list.
> 
> But you are keeping track of the mlock count? Why not simply call
> try_to_unmap and see if they are still mlocked?

We may be talking past each other here.  So, let me try this:

We're trying to hide nonreclaimable, including mlock'ed, pages from
vmscan to the extent possible--to make reclaim as efficient as possible.
Sometimes, to avoid races [as in your comment in __mlock_pages_range()
regarding anonymous pages], we may end up putting mlock'ed pages on the
normal lru list.  That's OK.  We can cull them in shrink_*_list().  Now,
if we have an mlock lock count in a dedicated field or a page flag
indicating mlock'ed state [perhaps with a count in an overloaded field],
we can easily cull the mlock'ed pages w/o access to any vma so that it
never gets to shrink_page_list() where try_to_unmap() would be called.

IMO, try_to_unmap() is/can be a fairly heavy hammer, walking the entire
rmap, as it does.  And, we only get to try_to_unmap() after already
walking the entire rmap in page_referenced() [hmmm, maybe cull mlock'ed
pages in page_referenced()--before even checking page table for ref?].
So, I'd like to cull them early by just looking at the page.  If a page
occasionally makes it through, like only the first time for anon pages?,
we only take the hit once.

Now you may be thinking that, in general, reverse maps are not all that
large.  But, I've seen live locks on the i_mmap_lock with heavy Oracle
loads [I think I already mentioned this].  On large servers, we can see
hundreds or thousands of tasks mapping the data base executables,
libraries and shared memory areas--just the types of regions one might
want to mlock.  Further, the shared memory areas can get quite
large--10s, 100s, even 1000s of GB.  That's a lot of pages to be running
through page_referenced/try_to_unmap too often.  

> 
> 
> > > But once you do the code for mlock refcounting, that's most of the hard
> > > part done so you may as well remove them completely from the LRU, no?
> > > Then they become more or less transparent to the rest of the VM as well.
> > 
> > Well, no.  Depending on the reason for !reclaimable, the page would go
> > on the noreclaim list or just be dropped--special handling.  More
> > importantly [for me], we still have to handle them specially in
> > migration, dumping them back onto the LRU so that we can arbitrate
> > access.  If I'm ever successful in getting automatic/lazy page migration
> > +replication accepted, I don't want that overhead in
> > auto-migration/replication.
> 
> Oh OK. I don't know if there should be a whole lot of overhead involved
> with that, though. I can't remember exactly what the problems were here
> with my mlock patch, but I think it could have been made more optimal.

The basic issue was that one can't migrate pages [nor unmap them for
lazy migration/replication] if check_range() can't find them on and
successfully isolate them from the lru.  In a respin of the patch, you
dumped the pages back on to the LRU so that they could be migrated.
Then, later, they'll need to be lazily culled back off the lru.  Could
be a lot of pages for some regions.   With the noreclaim lru list, this
isn't necessary.  It works just like the [in]active lists from
migration's perspective.

I guess the overhead depends on the size of the regions being migrated.
It occurs to me that we probably need a way to exempt some regions--like
huge shared memory areas--from auto-migration/replication.

> 
> 
> > > Could be possible. Tricky though. Probably take less code to use
> > > ->lru ;)


> > 
> > Oh, certainly less code to use any separate field.  But the lru list
> > field is the only link we have in the page struct, and a lot of VM
> > depends on being able to pass around lists of pages.  I'd hate to lose
> > that for mlocked pages, or to have to dump the lock count and
> > reestablish it in those cases, like migration, where we need to put the
> > page on a list.
> 
> Hmm, yes. Migration could possibly use a single linked list.
> But I'm only saying it _could_ be possible to do mlocked accounting
> efficiently with one of the LRU pointers -- 

I agree, that we don't want to keep the pages on an lru list or want to
use some other list type for migration and such, the accounting in one
of the lru pointers is no[t much] more overhead, timewise, than a
dedicated field.  The dedicated file increases space overhead, tho'.

> I would prefer the idea
> of just using a single bit for example, if that is sufficient. It
> should cut down on code.
 
I've been thinking about how to eliminate the mlock count entirely and
just use a single page flag and "lazy culling"--i.e., try to unmap.
But, one scenario I want to avoid is where tasks come and go, attaching
to a shared memory area/executable with an mlock'ed vma.  When they
detach, without a count, we'd just drop the mlock flag, moving the pages
back to the normal lru lists, and let vmscan cull them if some vma still
have them mlock'ed.  Again, I'd like to avoid the flood of pages between
normal lru and noreclaim lists in my model.

Perhaps the "flood" can be eliminated for shared memory areas--likely to
be the largest source of mlock'ed pages--by not unlocking pages in shmem
areas that have the VM_LOCKED flag set in the shmem_inode_info flags
field [SHM_LOCKED regions].  I don't see any current interaction of that
flag with the vm_flags when attaching to a SHM_LOCKED region.  Such
interaction is not required to prevent swap out--that's handled in
shmem_writepage.  But, to keep those pages off the LRU, we probably need
to consult the shmem_inode_info flags in the modified mlock code.  Maybe
pull the flag into the vm_flags on attach?  This way, try_to_unmap()
will see it w/o having to consult vm_file->...  I'm looking into this.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
