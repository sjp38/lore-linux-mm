Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CBBF36B01EE
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 13:34:37 -0400 (EDT)
Date: Wed, 28 Apr 2010 18:34:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100428173416.GJ15815@csn.ul.ie>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie> <1272403852-10479-3-git-send-email-mel@csn.ul.ie> <20100427231007.GA510@random.random> <20100428091555.GB15815@csn.ul.ie> <20100428153525.GR510@random.random> <20100428155558.GI15815@csn.ul.ie> <20100428162305.GX510@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100428162305.GX510@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 06:23:05PM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 28, 2010 at 04:55:58PM +0100, Mel Gorman wrote:
> > Frankly, I don't understand why it was safe to drop the lock either.
> > Maybe it was a mistake but I still haven't convinced myself I fully
> > understand the subtleties of the anon_vma changes.
> 
> I understand the design but I'm also unsure about the details. it's
> just this lock that gets splitted and when you update the
> vm_start/pgoff with only the vma->anon_vma->lock, the vma may be
> queued in multiple other anon_vmas, and you're only serializing
> and safe for the pages that have page_mapcount 1, and point to the
> local anon_vma == vma->anon_vma, not any other shared page.
> 
> The removal of the vma->anon_vma->lock from vma_adjust just seems an
> unrelated mistake to me too, but I don't know for sure why yet.
> Basically vma_adjust needs the anon_vma lock like expand_downards has.
> 

Well, in the easiest case, the details of the VMA (particularly vm_start
and vm_pgoff) can confuse callers of vma_address during rmap_walk. In the
case of migration, it will return other false positives or negatives.

At best I'm fuzzy on the details though.

> After you fix vma_adjust to be as safe as expand_downards you've also
> to take care of the rmap_walk that may run on a page->mapping =
> anon_vma that isn't the vma->anon_vma and you're not taking that
> anon_vma->lock of the shared page, when you change the vma
> vm_pgoff/vm_start.

Is this not what the try-lock-different-vmas-or-backoff-and-retry logic
in patch 2 is doing or am I missing something else?

> If rmap_walk finds to find a pte, becauase of that,
> migrate will crash.
> 
> > Temporarily at least until I figured out if execve was the only problem. The
> 
> For aa.git it is sure enough. And as long as you only see the migrate
> crash in execve it's also sure enough.
> 

I can only remember seeing the execve-related crash but I'd rather the
locking was correct too.

Problem is, I've seen at least one crash due to execve() even with the
check made in try_to_unmap_anon to not migrate within the temporary
stack. I'm not sure how it could have happened.

> > locking in vma_adjust didn't look like the prime reason for the crash
> > but the lack of locking there is still very odd.
> 
> And I think it needs fixing to be safe.
> 
> > 
> > > I agree dropping patch 1 but
> > > to me the having to take all the anon_vma locks for every
> > > vma->anon_vma->lock that we walk seems a must, otherwise
> > > expand_downwards and vma_adjust won't be ok, plus we need to re-add
> > > the anon_vma lock to vma_adjust, it can't be safe to alter vm_pgoff
> > > and vm_start outside of the anon_vma->lock. Or I am mistaken?
> > > 
> > 
> > No, you're not. If nothing else, vma_address can return the wrong value because
> > the VMAs vm_start and vm_pgoff were in the process of being updated but not
> > fully updated. It's hard to see how vma_address would return the wrong value
> > and miss a migration PTE as a result but it's a possibility.  It's probably
> > a lot more important for transparent hugepage support.
> 
> For the rmap_walk itself, migrate and split_huge_page are identical,
> the main problem of transparent hugepage support is that I used the
> anon_vma->lock in a wider way and taken well before the rmap_walk, so
> I'm screwed in a worse way than migrate.
> 

Ok.

> So I may have to change from anon_vma->lock to the compound_lock in
> wait_split_huge_page(). But I'll still need the restarting loop of
> anon_vma locks then inside the two rmap_walk run by split_huge_page.
> Problem is, I would have preferred to do this locking change later as
> a pure optimization than as a requirement for merging and running
> stable, as it'll make things slightly more complex.
> 
> BTW, if we were to share the lock across all anon_vmas as I mentioned
> in prev email, and just reduce the chain length, then it'd solve all
> issues for rmap_walk in migrate and also for THP completely.
> 

It might be where we end up eventually. I'm simply loathe to introduce
another set of rules to anon_vma locking if it can be at all avoided.

> > > Patch 2 wouldn't help the swapops crash we reproduced because at that
> > > point the anon_vma of the stack is the local one, it's just after
> > > execve.
> > > 
> > > vma_adjust and expand_downards would alter vm_pgoff and vm_start while
> > > taking only the vma->anon_vma->lock where the vma->anon_vma is the
> > > _local_ one of the vma. 
> > 
> > True, although in the case of expand_downwards, it's highly unlikely that
> > there is also a migration PTE to be cleaned up. It's hard to see how a
> > migration PTE would be left behind in that case but it still looks wrong to
> > be updating the VMA fields without locking.
> 
> Every time we fail to find the PTE, it can also mean try_to_unmap just
> failed to instantiate the migration pte leading to random memory
> corruption in migrate.

How so? The old PTE should have been left in place, the page count of
the page remain positive and migration not occur.

> If a task fork and the some of the stack pages
> at the bottom of the stack are shared, but the top of the stack isn't
> shared (so the vma->anon_vma->lock only protects the top and not the
> bottom) migrate should be able to silently random corrupt memory right
> now because of this.
> 
> > > But a vma in mainline can be indexed in
> > > infinite anon_vmas, so to prevent breaking migration
> > > vma_adjust/expand_downards the rmap_walk would need to take _all_
> > > anon_vma->locks for every anon_vma that the vma is indexed into.
> > 
> > I felt this would be too heavy in the common case which is why I made
> > rmap_walk() do the try-lock-or-back-off instead because rmap_walk is typically
> > in far less critical paths.
> 
> If we could take all locks, it'd make life easier as it'd already
> implement the "shared lock" but without sharing it. It won't provide
> much runtime benefit though (just rmap_walk will be even slower than
> real shared lock, and vma_adjust/expand_downards will be slightly faster).
> 

Because the list could be very large, it would make more sense to
introduce the shared lock if this is what was required.

> > > Or
> > > alternatively like you implemented rmap_walk would need to check if
> > > the vma we found in the rmap_walk is different from the original
> > > anon_vma and to take the vma->anon_vma->lock (so taking the
> > > anon_vma->lock of the local anon_vma of every vma) before it can
> > > actually read the vma->vm_pgoff/vm_start inside vma_address.
> > > 
> > 
> > To be absolutly sure, yes this is required. I don't think we've been hitting
> > this exact problem in these tests but it still is a better plan than adjusting
> > VMA details without locks.
> 
> We've not been hitting it unless somebody crashed with random
> corruption.
> 

Not that I've seen. Still just the crashes within execve.

> > > If the above is right it also means the new anon-vma changes also break
> > > the whole locking of transparent hugepage, see wait_split_huge_page,
> > > it does a spin_unlock_wait(&anon_vma->lock) thinking that waiting the
> > > "local" anon-vma is enough, when in fact the hugepage may be shared
> > > and belonging to the parent parent_vma->anon_vma and not to the local
> > > one of the last child that is waiting on the wrong lock. So I may have
> > > to rewrite this part of the thp locking to solve this. And for me it's
> > > not enough to just taking more locks inside the rmap walks inside
> > > split_huge_page as I used the anon_vma lock outside too.
> > > 
> > 
> > No fun. That potentially could be a lot of locks to take to split the
> > page.
> 
> compound_lock should be able to replace it in a more granular way, but
> it's not exactly the time I was looking to apply scalar optimization
> to THP as it may introduce other issues I can't foresee right now.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
