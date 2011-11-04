Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DCD266B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 19:58:45 -0400 (EDT)
Date: Sat, 5 Nov 2011 00:56:03 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111104235603.GT18879@redhat.com>
References: <20111031171441.GD3466@redhat.com>
 <1320082040-1190-1-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Nai Xia <nai.xia@gmail.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Nov 04, 2011 at 12:31:04AM -0700, Hugh Dickins wrote:
> On Mon, 31 Oct 2011, Andrea Arcangeli wrote:
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index a65efd4..a5858dc 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -2339,7 +2339,15 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
> >  		 */
> >  		if (vma_start >= new_vma->vm_start &&
> >  		    vma_start < new_vma->vm_end)
> > +			/*
> > +			 * No need to call anon_vma_order_tail() in
> > +			 * this case because the same PT lock will
> > +			 * serialize the rmap_walk against both src
> > +			 * and dst vmas.
> > +			 */
> 
> Really?  Please convince me: I just do not see what ensures that
> the same pt lock covers both src and dst areas in this case.

Right, vma being the same for src/dst doesn't mean the PT lock is the
same, it might be if source pte entry fit in the same pagetable but
maybe not if the vma is >2M (the max a single pagetable can point to).

> >  			*vmap = new_vma;
> > +		else
> > +			anon_vma_order_tail(new_vma);
> 
> And if this puts new_vma in the right position for the normal
> move_page_tables(), as anon_vma_clone() does in the block below,
> aren't they both in exactly the wrong position for the abnormal
> move_page_tables(), called to put ptes back where they were if
> the original move_page_tables() fails?

Failure paths. Good point, they'd need to be reversed again in that
case.

> It might be possible to argue that move_page_tables() can only
> fail by failing to allocate memory for pud or pmd, and that (perhaps)
> could only happen if the task was being OOM-killed and ran out of
> reserves at this point, and if it's being OOM-killed then we don't
> mind losing a migration entry for a moment... perhaps.

Hmm no it wouldn't be ok, or I wouldn't want to risk that.

> Certainly I'd agree that it's a very rare case.  But it feels wrong
> to be attempting to fix the already unlikely issue, while ignoring
> this aspect, or relying on such unrelated implementation details.

Agreed.

> Perhaps some further anon_vma_ordering could fix it up,
> but that would look increasingly desperate.

I think what Nai didn't consider in explaining this theoretical race
that I noticed now is the anon_vma root lock taken by adjust_vma.

If the merge succeeds adjust_vma will take the lock and flush away
from all others CPUs any sign of rmap_walk before the move_page_tables
can start.

So it can't happen that you do rmap_walk, check vma1, mremap moves
stuff from vma2 to vma1 (wrong order), and then rmap_walk continues
checking vma2 where the pte won't be there anymore. It can't happen
because mremap would block in vma_merge waiting the rmap_walk to
complete. Before proceeding moving any pte. Thanks to the anon_vma
lock already taken by adjust_vma.

So the real fix for the real bug is the one already merged in kernel
v3.1 and we don't need to make any more changes because there is no
race left.

The only bug was the lack of PT lock before checking the pte that
could read the ptes while move_ptes transferred the pte from src_ptep
to kernel stack, and before writing it to dst_ptep. That is closed by
taking the PT lock in migrate before checking if the pte could be a
migrate pte (so flushing move_ptes away from all other CPUs while
migrate checks if a migrate-pte is mapped in the pte).

I don't think the ordering matters anymore, Nai theory sounded good
there was just one small detail he missed in the vma_merge internal
locking that prevents the race to trigger.

> If we were back in the days of the simple anon_vma list, I'd probably
> share your enthusiasm for the list ordering solution; but now it looks
> like a fragile and contorted way of avoiding the obvious... we just
> need to use the anon_vma_lock (but perhaps there are some common and
> easily tested conditions under which we can skip it e.g. when a single
> pt lock covers src and dst?).

Actually I thought about this one when I didn't notice yet the
vma_merge internal locking that prevents Nai's remaining race to
trigger. And my conclusion is that the anon_vma_chains aren't actually
changing anything with regard to ordering. It become a bit
multidimensional to think about it so it complicates things
incredibly, but the ordering issue could have happened before too, and
the fix would have worked for both.

Old anon_vma is like three dimensional (vma, anon_vma, page). Now it's
(vma, chain, anon_vma, page). But if you consider just a single
process execve'd without any child, it returns three dimensional. And
the moment you add childs, you can imagine the old "three dimension"
anon_vma logic to be the one of the parent. And if parent is safe with
all childs vmas in the same_anon_vma_list, then childs are sure safe
too to reorder that way. But hey it's not needed so we're faster and
we don't have to do those list searches during mremap and it's simpler
too :).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
