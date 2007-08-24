Subject: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070823041137.GH18788@wotan.suse.de>
References: <20070823041137.GH18788@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 24 Aug 2007 16:43:38 -0400
Message-Id: <1187988218.5869.64.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

For your weekend reading pleasure [:-)]

I have reworked your "move mlocked pages off LRU" atop my "noreclaim
infrastructure" that keeps non-reclaimable pages [mlocked, swap-backed
but no swap space, excessively long anon_vma list] on a separate
noreclaim LRU list--more or less ignored by vmscan.  To do this, I had
to <mumble>add<mumble>a new<mumble>mlock_count member<mumble>to
the<mumble>page struct.  This brings the size of the page struct to a
nice, round 64 bytes.  The mlock_count member and [most of] the
noreclaim-mlocked-pages work now depends on CONFIG_NORECLAIM_MLOCK which
depends on CONFIG_NORECLAIM.  Currently,  the entire noreclaim
infrastructure is only supported on 64bit archs because I'm using a
higher order bit [~30] for the PG_noreclaim flag.

Using the noreclaim infrastructure does seem to simplify the "keep
mlocked pages off the LRU" code tho'.  All of the isolate_lru_page(),
move_to_lru(), ... functions have been taught about the noreclaim list,
so many places don't need changes.  That being said, I really not sure
I've covered all of the bases here...

Now, mlocked pages come back off the noreclaim list nicely when the last
mlock reference goes away--assuming I have the counting correct.
However, pages marked non-reclaimable for other reasons--no swap
available, excessive anon_vma ref count--can languish there
indefinitely.   At some point, perhaps vmscan could be taught to do a
slow background scan of the noreclaim list [making it more like
"slo-reclaim"--but we already have that :-)] when swap is added and we
have unswappable pages on the list.  Currently, I don't keep track of
the various reasons for the no-reclaim pages, but that could be added.  

Rik Van Riel mentions, on his VM wiki page that a background scan might
be useful to age pages actively [clock hand, anyone?], so I might be
able to piggyback on that, or even prototype it at some point.   In the
meantime, I'm going to add a scan of the noreclaim list manually
triggered by a temporary sysctl.

Anyway, if anyone is interested, the patches are in a gzip'd tarball in:

http://free.linux.hp.com/~lts/Patches/Noreclaim/

Cursory functional testing with memtoy shows that it basically works.
I've started a moderately stressful workload for the weekend.  We'll see
how it goes.

Cheers,
Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
