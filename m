Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 96E286B01EF
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 05:18:05 -0400 (EDT)
Date: Tue, 27 Apr 2010 10:17:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100427091744.GC4895@csn.ul.ie>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie> <1272321478-28481-3-git-send-email-mel@csn.ul.ie> <z2y28c262361004261605ha101b4aek7116f7a6a1d5b92@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <z2y28c262361004261605ha101b4aek7116f7a6a1d5b92@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 27, 2010 at 08:05:26AM +0900, Minchan Kim wrote:
> On Tue, Apr 27, 2010 at 7:37 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > vma_adjust() is updating anon VMA information without any locks taken.
> > In contrast, file-backed mappings use the i_mmap_lock and this lack of
> > locking can result in races with page migration. During rmap_walk(),
> > vma_address() can return -EFAULT for an address that will soon be valid.
> > This leaves a dangling migration PTE behind which can later cause a BUG_ON
> > to trigger when the page is faulted in.
> >
> > With the recent anon_vma changes, there can be more than one anon_vma->lock
> > that can be taken in a anon_vma_chain but a second lock cannot be spinned
> > upon in case of deadlock. Instead, the rmap walker tries to take locks of
> > different anon_vma's. If the attempt fails, the operation is restarted.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/ksm.c  |   13 +++++++++++++
> >  mm/mmap.c |    6 ++++++
> >  mm/rmap.c |   22 +++++++++++++++++++---
> >  3 files changed, 38 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index 3666d43..baa5b4d 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -1674,9 +1674,22 @@ again:
> >                spin_lock(&anon_vma->lock);
> >                list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
> >                        vma = vmac->vma;
> > +
> > +                       /* See comment in mm/rmap.c#rmap_walk_anon on locking */
> > +                       if (anon_vma != vma->anon_vma) {
> > +                               if (!spin_trylock(&vma->anon_vma->lock)) {
> > +                                       spin_unlock(&anon_vma->lock);
> > +                                       goto again;
> > +                               }
> > +                       }
> > +
> >                        if (rmap_item->address < vma->vm_start ||
> >                            rmap_item->address >= vma->vm_end)
> >                                continue;
> > +
> > +                       if (anon_vma != vma->anon_vma)
> > +                               spin_unlock(&vma->anon_vma->lock);
> > +
> >                        /*
> >                         * Initially we examine only the vma which covers this
> >                         * rmap_item; but later, if there is still work to do,
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index f90ea92..61d6f1d 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -578,6 +578,9 @@ again:                      remove_next = 1 + (end > next->vm_end);
> >                }
> >        }
> >
> > +       if (vma->anon_vma)
> > +               spin_lock(&vma->anon_vma->lock);
> > +
> >        if (root) {
> >                flush_dcache_mmap_lock(mapping);
> >                vma_prio_tree_remove(vma, root);
> > @@ -620,6 +623,9 @@ again:                      remove_next = 1 + (end > next->vm_end);
> >        if (mapping)
> >                spin_unlock(&mapping->i_mmap_lock);
> >
> > +       if (vma->anon_vma)
> > +               spin_unlock(&vma->anon_vma->lock);
> > +
> >        if (remove_next) {
> >                if (file) {
> >                        fput(file);
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 85f203e..bc313a6 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1368,15 +1368,31 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
> >         * are holding mmap_sem. Users without mmap_sem are required to
> >         * take a reference count to prevent the anon_vma disappearing
> >         */
> > +retry:
> >        anon_vma = page_anon_vma(page);
> >        if (!anon_vma)
> >                return ret;
> >        spin_lock(&anon_vma->lock);
> >        list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
> >                struct vm_area_struct *vma = avc->vma;
> > -               unsigned long address = vma_address(page, vma);
> > -               if (address == -EFAULT)
> > -                       continue;
> > +               unsigned long address;
> > +
> > +               /*
> > +                * Guard against deadlocks by not spinning against
> > +                * vma->anon_vma->lock. If contention is found, release our
> > +                * lock and try again until VMA list can be traversed without
> > +                * contention.
> > +                */
> > +               if (anon_vma != vma->anon_vma) {
> > +                       if (!spin_trylock(&vma->anon_vma->lock)) {
> > +                               spin_unlock(&anon_vma->lock);
> > +                               goto retry;
> > +                       }
> > +               }
> > +               address = vma_address(page, vma);
> > +               if (anon_vma != vma->anon_vma)
> > +                       spin_unlock(&vma->anon_vma->lock);
> > +
> 
> if (address == -EFAULT)
>         continue;
> 

Correct. Thanks.

> >                ret = rmap_one(page, vma, address, arg);
> >                if (ret != SWAP_AGAIN)
> >                        break;
> > --
> > 1.6.5
> >
> >
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
