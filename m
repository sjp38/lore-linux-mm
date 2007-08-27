Date: Mon, 27 Aug 2007 03:35:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
Message-ID: <20070827013525.GA23894@wotan.suse.de>
References: <20070823041137.GH18788@wotan.suse.de> <1187988218.5869.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187988218.5869.64.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 24, 2007 at 04:43:38PM -0400, Lee Schermerhorn wrote:
> Nick:
> 
> For your weekend reading pleasure [:-)]
> 
> I have reworked your "move mlocked pages off LRU" atop my "noreclaim
> infrastructure" that keeps non-reclaimable pages [mlocked, swap-backed
> but no swap space, excessively long anon_vma list] on a separate
> noreclaim LRU list--more or less ignored by vmscan.  To do this, I had
> to <mumble>add<mumble>a new<mumble>mlock_count member<mumble>to
> the<mumble>page struct.  This brings the size of the page struct to a
> nice, round 64 bytes.  The mlock_count member and [most of] the
> noreclaim-mlocked-pages work now depends on CONFIG_NORECLAIM_MLOCK which
> depends on CONFIG_NORECLAIM.  Currently,  the entire noreclaim
> infrastructure is only supported on 64bit archs because I'm using a
> higher order bit [~30] for the PG_noreclaim flag.

Can you keep the old system of removing mlocked pages completely, and
keeping the mlock count in one of the lru pointers? That should avoid
the need to have a new mlock_count, I think, because none of the other
noreclaim types should need a refcount?

I do approve of bringing struct page to a nice round 64 bytes ;), but I
think I would rather we used up those 8 bytes by making count and
mapcount 8 bytes each.


> Using the noreclaim infrastructure does seem to simplify the "keep
> mlocked pages off the LRU" code tho'.  All of the isolate_lru_page(),
> move_to_lru(), ... functions have been taught about the noreclaim list,
> so many places don't need changes.  That being said, I really not sure
> I've covered all of the bases here...
> 
> Now, mlocked pages come back off the noreclaim list nicely when the last
> mlock reference goes away--assuming I have the counting correct.
> However, pages marked non-reclaimable for other reasons--no swap
> available, excessive anon_vma ref count--can languish there
> indefinitely.   At some point, perhaps vmscan could be taught to do a
> slow background scan of the noreclaim list [making it more like
> "slo-reclaim"--but we already have that :-)] when swap is added and we
> have unswappable pages on the list.  Currently, I don't keep track of
> the various reasons for the no-reclaim pages, but that could be added.  
> 
> Rik Van Riel mentions, on his VM wiki page that a background scan might
> be useful to age pages actively [clock hand, anyone?], so I might be
> able to piggyback on that, or even prototype it at some point.   In the
> meantime, I'm going to add a scan of the noreclaim list manually
> triggered by a temporary sysctl.

Yeah, I think the basic slow simple clock would be a reasonable starting
point. You may end up wanting to introduce some feedback from near-OOM
condition and/or free swap accounting to speed up the scanning rate.

I haven't had much look at the patches yet, but I'm glad to see the old
mlocked patch come to something ;)

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
