Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B01886B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 20:34:00 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3R0Y0ZQ026000
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Apr 2010 09:34:01 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E09C45DE51
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:34:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E02E45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:34:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 446431DB803B
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:34:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9E371DB8038
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:33:59 +0900 (JST)
Date: Tue, 27 Apr 2010 09:30:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the  wrong VMA information
Message-Id: <20100427093001.dfb21e2a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <z2y28c262361004261605ha101b4aek7116f7a6a1d5b92@mail.gmail.com>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
	<1272321478-28481-3-git-send-email-mel@csn.ul.ie>
	<z2y28c262361004261605ha101b4aek7116f7a6a1d5b92@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010 08:05:26 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

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
> > A mm/ksm.c A | A  13 +++++++++++++
> > A mm/mmap.c | A  A 6 ++++++
> > A mm/rmap.c | A  22 +++++++++++++++++++---
> > A 3 files changed, 38 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index 3666d43..baa5b4d 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -1674,9 +1674,22 @@ again:
> > A  A  A  A  A  A  A  A spin_lock(&anon_vma->lock);
> > A  A  A  A  A  A  A  A list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
> > A  A  A  A  A  A  A  A  A  A  A  A vma = vmac->vma;
> > +
> > + A  A  A  A  A  A  A  A  A  A  A  /* See comment in mm/rmap.c#rmap_walk_anon on locking */
> > + A  A  A  A  A  A  A  A  A  A  A  if (anon_vma != vma->anon_vma) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (!spin_trylock(&vma->anon_vma->lock)) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  spin_unlock(&anon_vma->lock);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  goto again;
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  A  A  A  A  }
> > +
> > A  A  A  A  A  A  A  A  A  A  A  A if (rmap_item->address < vma->vm_start ||
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A rmap_item->address >= vma->vm_end)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A continue;
> > +
> > + A  A  A  A  A  A  A  A  A  A  A  if (anon_vma != vma->anon_vma)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  spin_unlock(&vma->anon_vma->lock);
> > +
> > A  A  A  A  A  A  A  A  A  A  A  A /*
> > A  A  A  A  A  A  A  A  A  A  A  A  * Initially we examine only the vma which covers this
> > A  A  A  A  A  A  A  A  A  A  A  A  * rmap_item; but later, if there is still work to do,
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index f90ea92..61d6f1d 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -578,6 +578,9 @@ again: A  A  A  A  A  A  A  A  A  A  A remove_next = 1 + (end > next->vm_end);
> > A  A  A  A  A  A  A  A }
> > A  A  A  A }
> >
> > + A  A  A  if (vma->anon_vma)
> > + A  A  A  A  A  A  A  spin_lock(&vma->anon_vma->lock);
> > +
> > A  A  A  A if (root) {
> > A  A  A  A  A  A  A  A flush_dcache_mmap_lock(mapping);
> > A  A  A  A  A  A  A  A vma_prio_tree_remove(vma, root);
> > @@ -620,6 +623,9 @@ again: A  A  A  A  A  A  A  A  A  A  A remove_next = 1 + (end > next->vm_end);
> > A  A  A  A if (mapping)
> > A  A  A  A  A  A  A  A spin_unlock(&mapping->i_mmap_lock);
> >
> > + A  A  A  if (vma->anon_vma)
> > + A  A  A  A  A  A  A  spin_unlock(&vma->anon_vma->lock);
> > +
> > A  A  A  A if (remove_next) {
> > A  A  A  A  A  A  A  A if (file) {
> > A  A  A  A  A  A  A  A  A  A  A  A fput(file);
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 85f203e..bc313a6 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1368,15 +1368,31 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
> > A  A  A  A  * are holding mmap_sem. Users without mmap_sem are required to
> > A  A  A  A  * take a reference count to prevent the anon_vma disappearing
> > A  A  A  A  */
> > +retry:
> > A  A  A  A anon_vma = page_anon_vma(page);
> > A  A  A  A if (!anon_vma)
> > A  A  A  A  A  A  A  A return ret;
> > A  A  A  A spin_lock(&anon_vma->lock);
> > A  A  A  A list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
> > A  A  A  A  A  A  A  A struct vm_area_struct *vma = avc->vma;
> > - A  A  A  A  A  A  A  unsigned long address = vma_address(page, vma);
> > - A  A  A  A  A  A  A  if (address == -EFAULT)
> > - A  A  A  A  A  A  A  A  A  A  A  continue;
> > + A  A  A  A  A  A  A  unsigned long address;
> > +
> > + A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A * Guard against deadlocks by not spinning against
> > + A  A  A  A  A  A  A  A * vma->anon_vma->lock. If contention is found, release our
> > + A  A  A  A  A  A  A  A * lock and try again until VMA list can be traversed without
> > + A  A  A  A  A  A  A  A * contention.
> > + A  A  A  A  A  A  A  A */
> > + A  A  A  A  A  A  A  if (anon_vma != vma->anon_vma) {
> > + A  A  A  A  A  A  A  A  A  A  A  if (!spin_trylock(&vma->anon_vma->lock)) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  spin_unlock(&anon_vma->lock);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  goto retry;
> > + A  A  A  A  A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  address = vma_address(page, vma);
> > + A  A  A  A  A  A  A  if (anon_vma != vma->anon_vma)
> > + A  A  A  A  A  A  A  A  A  A  A  spin_unlock(&vma->anon_vma->lock);
> > +
> 
> if (address == -EFAULT)
>         continue;
> 
yes. thank you for pointing out.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
