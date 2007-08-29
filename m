Date: Wed, 29 Aug 2007 06:38:03 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
Message-ID: <20070829043803.GD25335@wotan.suse.de>
References: <20070823041137.GH18788@wotan.suse.de> <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de> <1188225247.5952.41.camel@localhost> <20070828000648.GB14109@wotan.suse.de> <1188312766.5079.77.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1188312766.5079.77.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 28, 2007 at 10:52:46AM -0400, Lee Schermerhorn wrote:
> On Tue, 2007-08-28 at 02:06 +0200, Nick Piggin wrote:
> > 
> > I don't have a problem with having a more unified approach, although if
> > we did that, then I'd prefer just to do it more simply and don't special
> > case mlocked pages _at all_. Ie. just slowly try to reclaim them and
> > eventually when everybody unlocks them, you will notice sooner or later.
> 
> I didn't think I was special casing mlocked pages.  I wanted to treat
> all !page_reclaimable() pages the same--i.e., put them on the noreclaim
> list.

But you are keeping track of the mlock count? Why not simply call
try_to_unmap and see if they are still mlocked?


> > But once you do the code for mlock refcounting, that's most of the hard
> > part done so you may as well remove them completely from the LRU, no?
> > Then they become more or less transparent to the rest of the VM as well.
> 
> Well, no.  Depending on the reason for !reclaimable, the page would go
> on the noreclaim list or just be dropped--special handling.  More
> importantly [for me], we still have to handle them specially in
> migration, dumping them back onto the LRU so that we can arbitrate
> access.  If I'm ever successful in getting automatic/lazy page migration
> +replication accepted, I don't want that overhead in
> auto-migration/replication.

Oh OK. I don't know if there should be a whole lot of overhead involved
with that, though. I can't remember exactly what the problems were here
with my mlock patch, but I think it could have been made more optimal.


> > Could be possible. Tricky though. Probably take less code to use
> > ->lru ;)
> 
> Oh, certainly less code to use any separate field.  But the lru list
> field is the only link we have in the page struct, and a lot of VM
> depends on being able to pass around lists of pages.  I'd hate to lose
> that for mlocked pages, or to have to dump the lock count and
> reestablish it in those cases, like migration, where we need to put the
> page on a list.

Hmm, yes. Migration could possibly use a single linked list.
But I'm only saying it _could_ be possible to do mlocked accounting
efficiently with one of the LRU pointers -- I would prefer the idea
of just using a single bit for example, if that is sufficient. It
should cut down on code.


> > I don't know. I'd have thought efficient mlock handling might be useful
> > for realtime systems, probably many of which would be 32-bit.
> 
> I agree.  I just wonder if those systems have a sufficient number of
> pages that they're suffering from the long lru lists with a large
> fraction of unreclaimable pages...  If we do want to support keeping
> nonreclaimable pages off the [in]active lists for these systems, we'll
> need to find a place for the flag[s].

That's true, they will have a lot less pages (and probably won't
be using highmem).


> > Are you seeing mlock pinning heaps of memory in the field?
> 
> It is a common usage to mlock() large shared memory areas, as well as
> entire tasks [MLOCK_CURRENT|MLOCK_FUTURE].  I think it would be even
> more frequent if one could inherit MLOCK_FUTURE across fork and exec.
> Then one could write/enhance a prefix command, like numactl and taskset,
> to enable locking of unmodified applications.  I prototyped this once,
> but never updated it to do the mlock accounting [e.g., down in
> copy_page_range() during fork()] for your patch.
> 
> What we see more of is folks just figuring that they've got sufficient
> memory [100s of GB] for their apps and shared memory areas, so they
> don't add enough swap to back all of the anon and shmem regions.  Then,
> when they get under memory pressure--e.g., the old "backup ate my
> pagecache" scenario--the system more or less live-locks in vmscan
> shuffling non-reclaimable [unswappable] pages.  A large number of
> mlocked pages on the LRU produces the same symptom; as do excessively
> long anon_vma lists and huge i_mmap trees--the latter seen with some
> large Oracle workloads.

OK, thanks for the background.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
