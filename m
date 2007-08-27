Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070827013525.GA23894@wotan.suse.de>
References: <20070823041137.GH18788@wotan.suse.de>
	 <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de>
Content-Type: text/plain
Date: Mon, 27 Aug 2007 10:34:07 -0400
Message-Id: <1188225247.5952.41.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-27 at 03:35 +0200, Nick Piggin wrote:
> On Fri, Aug 24, 2007 at 04:43:38PM -0400, Lee Schermerhorn wrote:
> > Nick:
> > 
> > For your weekend reading pleasure [:-)]
> > 
> > I have reworked your "move mlocked pages off LRU" atop my "noreclaim
> > infrastructure" that keeps non-reclaimable pages [mlocked, swap-backed
> > but no swap space, excessively long anon_vma list] on a separate
> > noreclaim LRU list--more or less ignored by vmscan.  To do this, I had
> > to <mumble>add<mumble>a new<mumble>mlock_count member<mumble>to
> > the<mumble>page struct.  This brings the size of the page struct to a
> > nice, round 64 bytes.  The mlock_count member and [most of] the
> > noreclaim-mlocked-pages work now depends on CONFIG_NORECLAIM_MLOCK which
> > depends on CONFIG_NORECLAIM.  Currently,  the entire noreclaim
> > infrastructure is only supported on 64bit archs because I'm using a
> > higher order bit [~30] for the PG_noreclaim flag.
> 
> Can you keep the old system of removing mlocked pages completely, and
> keeping the mlock count in one of the lru pointers? That should avoid
> the need to have a new mlock_count, I think, because none of the other
> noreclaim types should need a refcount?

Well, keeping the mlock count in the lru pointer more or less defeats
the purpose of this exercise for me--that is, a unified mechanism for
tracking "non-reclaimable" pages.  I wanted to maintain the ability to
use the zone lru_lock and isolate_lru_page() to arbitrate access to
pages for migration, etc. w/o having to temporarily put the pages back
on the lru during migration.   

And, by using another LRU list for non-reclaimable pages, the
non-reclaimable nature of locked, un-swappable, ... pages becomes
transparent to much of the rest of VM.  vmscan and try_to_unmap*() still
have to handle lazy culling of non-reclaimable pages.  If/when you do
get a chance to look at the patches, you'll see that I separated the
culling of non-reclaimable pages in the fault path into a separate
patch.  We could eliminate this overhead in the fault path in favor of
lazy culling in vmscan.  Vmscan would only have to deal with these pages
once to move them to the noreclaim list.

> 
> I do approve of bringing struct page to a nice round 64 bytes ;), but I
> think I would rather we used up those 8 bytes by making count and
> mapcount 8 bytes each.

I knew the new page struct member would be controversial, at best, but
it allows me to prototype and test this approach.  I'd like to find
somewhere else to put the mlock count, but the page struct it pretty
tight as it is.  It occurred to me that while anon and other swap-backed
pages are mlocked, I might be able to use the private field as the mlock
count.  I don't understand the interaction of vm with file systems to
know if we could do the same for file-backed pages.  Maybe a separate
PG_mlock flag would allow one to move the page's private contents to an
external structure along with the mlock count?  Or maybe just with
PG_noreclaim, externalize the private info?

Another approach that I've seen used elsewhere, IFF we can find a
smaller bit field for the mlock count:  maintain a mlock count in a bit
field that is too small to contain max possible lock count.  [Probably
don't need all 64-bits, in any case.]  Clip the count at maximum that
the field can contain [like SWAP_MAP_MAX] and fail mlock attempts if the
count won't accommodate the additional lock.  I haven't investigated
this enough to determine what additional complications it would involve.
It would probably complicate inheriting locks across fork(), if we ever
want to do that [I do!].

Any thoughts on restricting this to 64-bit archs?

> 
> 
> > Using the noreclaim infrastructure does seem to simplify the "keep
> > mlocked pages off the LRU" code tho'.  All of the isolate_lru_page(),
> > move_to_lru(), ... functions have been taught about the noreclaim list,
> > so many places don't need changes.  That being said, I really not sure
> > I've covered all of the bases here...
> > 
> > Now, mlocked pages come back off the noreclaim list nicely when the last
> > mlock reference goes away--assuming I have the counting correct.
> > However, pages marked non-reclaimable for other reasons--no swap
> > available, excessive anon_vma ref count--can languish there
> > indefinitely.   At some point, perhaps vmscan could be taught to do a
> > slow background scan of the noreclaim list [making it more like
> > "slo-reclaim"--but we already have that :-)] when swap is added and we
> > have unswappable pages on the list.  Currently, I don't keep track of
> > the various reasons for the no-reclaim pages, but that could be added.  
> > 
> > Rik Van Riel mentions, on his VM wiki page that a background scan might
> > be useful to age pages actively [clock hand, anyone?], so I might be
> > able to piggyback on that, or even prototype it at some point.   In the
> > meantime, I'm going to add a scan of the noreclaim list manually
> > triggered by a temporary sysctl.
> 
> Yeah, I think the basic slow simple clock would be a reasonable starting
> point. You may end up wanting to introduce some feedback from near-OOM
> condition and/or free swap accounting to speed up the scanning rate.

Yep.   It's all those little details that have prevented me from diving
into this yet.  Still cogitating on that, as a background task.

> 
> I haven't had much look at the patches yet, but I'm glad to see the old
> mlocked patch come to something ;)

Given the issues we've encountered in the field with a large number
[millions] of non-reclaimable pages on the LRU lists, the idea of hiding
nonreclaimable pages from vmscan is appealing.  I'm hoping we can find
some acceptable way of doing this in the long run.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
