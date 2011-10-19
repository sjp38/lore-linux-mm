Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 48C276B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 03:43:44 -0400 (EDT)
Date: Wed, 19 Oct 2011 09:43:36 +0200
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Message-ID: <20111019074336.GB3410@suse.de>
References: <201110122012.33767.pluto@agmk.net>
 <alpine.LSU.2.00.1110131547550.1346@sister.anvils>
 <alpine.LSU.2.00.1110131629530.1410@sister.anvils>
 <20111016235442.GB25266@redhat.com>
 <alpine.LSU.2.00.1110171111150.2545@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1110171111150.2545@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Mon, Oct 17, 2011 at 11:51:00AM -0700, Hugh Dickins wrote:
> On Mon, 17 Oct 2011, Andrea Arcangeli wrote:
> > On Thu, Oct 13, 2011 at 04:30:09PM -0700, Hugh Dickins wrote:
> > > mremap's down_write of mmap_sem, together with i_mmap_mutex/lock,
> > > and pagetable locks, were good enough before page migration (with its
> > > requirement that every migration entry be found) came in; and enough
> > > while migration always held mmap_sem.  But not enough nowadays, when
> > > there's memory hotremove and compaction: anon_vma lock is also needed,
> > > to make sure a migration entry is not dodging around behind our back.
> > 
> > For things like migrate and split_huge_page, the anon_vma layer must
> > guarantee the page is reachable by rmap walk at all times regardless
> > if it's at the old or new address.
> > 
> > This shall be guaranteed by the copy_vma called by move_vma well
> > before move_page_tables/move_ptes can run.
> > 
> > copy_vma obviously takes the anon_vma lock to insert the new "dst" vma
> > into the anon_vma chains structures (vma_link does that). That before
> > any pte can be moved.
> > 
> > Because we keep two vmas mapped on both src and dst range, with
> > different vma->vm_pgoff that is valid for the page (the page doesn't
> > change its page->index) the page should always find _all_ its pte at
> > any given time.
> > 
> > There may be other variables at play like the order of insertion in
> > the anon_vma chain matches our direction of copy and removal of the
> > old pte. But I think the double locking of the PT lock should make the
> > order in the anon_vma chain absolutely irrelevant (the rmap_walk
> > obviously takes the PT lock too), and furthermore likely the
> > anon_vma_chain insertion is favorable (the dst vma is inserted last
> > and checked last). But it shouldn't matter.
> 
> Thanks a lot for thinking it over.  I _almost_ agree with you, except
> there's one aspect that I forgot to highlight in the patch comment:
> remove_migration_pte() behaves as page_check_address() does by default,
> it peeks to see if what it wants is there _before_ taking ptlock.
> 
> And therefore, I think, it is possible that during mremap move, the swap
> pte is in neither of the locations it tries at the instant it peeks there.
> 

I should have read the rest of the thread before responding :/ .

This makes more sense and is a relief in a sense. There is nothing known
wrong with the VMA locking or ordering. The correct PTE is found but it is
in the wrong state.

> We could put a stop to that: see plausible alternative patch below.
> Though I have dithered from one to the other and back, I think on the
> whole I still prefer the anon_vma locking in move_ptes(): we don't care
> too deeply about the speed of mremap, but we do care about the speed of

I still think the anon_vma lock serialises mremap and migration. If that
is correct, it could cause things like huge page collapsing stalling mremap
operations. That might cause slowdowns in JVMs during GC which is undesirable.

> exec, and this does add another lock/unlock there, but it will always
> be uncontended; whereas the patch at the migration end could be adding
> a contended and unnecessary lock.
> 
> Oh, I don't know which, you vote - if you now agree there is a problem.
> I'll sign off the migrate.c one if you prefer it.  But no hurry.
> 

My vote is with the migration change. While there are occasionally
patches to make migration go faster, I don't consider it a hot path.
mremap may be used intensively by JVMs so I'd loathe to hurt it.

Thanks Hugh.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
