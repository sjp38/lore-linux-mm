Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B27A46B002C
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 18:05:42 -0400 (EDT)
Date: Tue, 18 Oct 2011 00:05:34 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Message-ID: <20111017220534.GA4860@redhat.com>
References: <201110122012.33767.pluto@agmk.net>
 <alpine.LSU.2.00.1110131547550.1346@sister.anvils>
 <alpine.LSU.2.00.1110131629530.1410@sister.anvils>
 <20111016235442.GB25266@redhat.com>
 <alpine.LSU.2.00.1110171111150.2545@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1110171111150.2545@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Mon, Oct 17, 2011 at 11:51:00AM -0700, Hugh Dickins wrote:
> Thanks a lot for thinking it over.  I _almost_ agree with you, except
> there's one aspect that I forgot to highlight in the patch comment:
> remove_migration_pte() behaves as page_check_address() does by default,
> it peeks to see if what it wants is there _before_ taking ptlock.
> 
> And therefore, I think, it is possible that during mremap move, the swap
> pte is in neither of the locations it tries at the instant it peeks there.

I see what you mean, I didn't realize you were fixing that race.
mremap for a few CPU cycles (which may expand if interrupted by irq)
the migration entry will only live in the kernel stack of the process
doing mremap. So the rmap_walk may just loop quick lockless and not
see it and return while mremap holds boths PT locks (src and dst
pte).

Now getting an irq exactly at that migrate cycle and that irq doesn't
sound too easy but we still must fix this race.

Maybe who needs a 100% reliability should not go lockless looping all
over the vmas without taking PT lock that prevents serialization
against the pte "moving" functions that normally do in order
ptep_clear_flush(src_ptep); set_pet_at(dst_ptep).

For example I never thought of optimizing __split_huge_page_splitting,
that must be reliable so I never felt like it could be safe to go
lockless there.

So I think it's better to fix migrate, as there may be other places
like mremap. Who can't afford failure should do the PT locking.

But maybe it's possible to find good reasons to fix the race in the
other way too.

> We could put a stop to that: see plausible alternative patch below.
> Though I have dithered from one to the other and back, I think on the
> whole I still prefer the anon_vma locking in move_ptes(): we don't care
> too deeply about the speed of mremap, but we do care about the speed of
> exec, and this does add another lock/unlock there, but it will always
> be uncontended; whereas the patch at the migration end could be adding
> a contended and unnecessary lock.
> 
> Oh, I don't know which, you vote - if you now agree there is a problem.
> I'll sign off the migrate.c one if you prefer it.  But no hurry.

Adding more locking in migrate than in mremap fast path should be
better performance-wise. Java GC uses mremap. migrate is somewhat less
performance critical, but I guess there may be other workloads where
migrate runs more often than mremap. But it also depends on the false
positive ratio of rmap_walk, if normally that's low the patch to
migrate may actually result in an optimization, while the mremap patch
can't possibly speed anything.

In short I'm slightly more inclined on preferring the fix to migrate
and enforce all rmap-walkers who can't fail should not go lockless
speculative on the ptes but take the lock before checking if the pte
they're searching is there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
