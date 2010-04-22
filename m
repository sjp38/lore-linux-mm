Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 377396B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 15:29:46 -0400 (EDT)
Date: Thu, 22 Apr 2010 20:29:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100422192923.GH30306@csn.ul.ie>
References: <20100421153421.GM30306@csn.ul.ie> <alpine.DEB.2.00.1004211038020.4959@router.home> <20100422092819.GR30306@csn.ul.ie> <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com> <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com> <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com> <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <20100422141404.GA30306@csn.ul.ie> <p2y28c262361004220718m3a5e3e2ekee1fef7ebdae8e73@mail.gmail.com> <20100422154003.GC30306@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100422154003.GC30306@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 04:40:04PM +0100, Mel Gorman wrote:
> On Thu, Apr 22, 2010 at 11:18:14PM +0900, Minchan Kim wrote:
> > On Thu, Apr 22, 2010 at 11:14 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > > On Thu, Apr 22, 2010 at 07:51:53PM +0900, KAMEZAWA Hiroyuki wrote:
> > >> On Thu, 22 Apr 2010 19:31:06 +0900
> > >> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >>
> > >> > On Thu, 22 Apr 2010 19:13:12 +0900
> > >> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > >> >
> > >> > > On Thu, Apr 22, 2010 at 6:46 PM, KAMEZAWA Hiroyuki
> > >> > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >> >
> > >> > > > Hmm..in my test, the case was.
> > >> > > >
> > >> > > > Before try_to_unmap:
> > >> > > >        mapcount=1, SwapCache, remap_swapcache=1
> > >> > > > After remap
> > >> > > >        mapcount=0, SwapCache, rc=0.
> > >> > > >
> > >> > > > So, I think there may be some race in rmap_walk() and vma handling or
> > >> > > > anon_vma handling. migration_entry isn't found by rmap_walk.
> > >> > > >
> > >> > > > Hmm..it seems this kind patch will be required for debug.
> > >> > >
> > >>
> > >> Ok, here is my patch for _fix_. But still testing...
> > >> Running well at least for 30 minutes, where I can see bug in 10minutes.
> > >> But this patch is too naive. please think about something better fix.
> > >>
> > >> ==
> > >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > >>
> > >> At adjust_vma(), vma's start address and pgoff is updated under
> > >> write lock of mmap_sem. This means the vma's rmap information
> > >> update is atoimic only under read lock of mmap_sem.
> > >>
> > >>
> > >> Even if it's not atomic, in usual case, try_to_ummap() etc...
> > >> just fails to decrease mapcount to be 0. no problem.
> > >>
> > >> But at page migration's rmap_walk(), it requires to know all
> > >> migration_entry in page tables and recover mapcount.
> > >>
> > >> So, this race in vma's address is critical. When rmap_walk meet
> > >> the race, rmap_walk will mistakenly get -EFAULT and don't call
> > >> rmap_one(). This patch adds a lock for vma's rmap information.
> > >> But, this is _very slow_.
> > >
> > > Ok wow. That is exceptionally well-spotted. This looks like a proper bug
> > > that compaction exposes as opposed to a bug that compaction introduces.
> > >
> > >> We need something sophisitcated, light-weight update for this..
> > >>
> > >
> > > In the event the VMA is backed by a file, the mapping i_mmap_lock is taken for
> > > the duration of the update and is  taken elsewhere where the VMA information
> > > is read such as rmap_walk_file()
> > >
> > > In the event the VMA is anon, vma_adjust currently talks no locks and your
> > > patch introduces a new one but why not use the anon_vma lock here? Am I
> > > missing something that requires the new lock?
> > 
> > rmap_walk_anon doesn't hold vma's anon_vma->lock.
> > It holds page->anon_vma->lock.
> > 
> 
> Of course, thank you for pointing out my error. With multiple
> anon_vma's, the locking is a bit of a mess. We cannot hold spinlocks on
> two vma's in the same list at the same time without potentially causing
> a livelock. The problem becomes how we can safely drop one anon_vma and
> acquire the other without them disappearing from under us.
> 
> See the XXX mark in the following incomplete patch for example. It's
> incomplete because the list traversal is also not safe once the lock has
> been dropped and -EFAULT is returned by vma_address.
> 

There is a simplier alternative I guess. When the vma->anon_vma is difference,
try and lock it. If the lock is uncontended, continue. If not, release the
pages anon_vma lock and start from the beginning - repeat until the list is
walked uncontended. This should avoid livelocking against other walkers.
I have the test running now for 30 minutes with no problems but will
leave it overnight and see what happens.

I tried the approach of having vma_adjust and rmap_walk always seeing
the same anon_vma but I couldn't devise a method. It doesn't seem
possible but I'm still getting to grips with the anon_vma_chain stuff.
Maybe Rik can spot a better way of doing this.

==== CUT HERE ====
mm: Take the vma anon_vma lock in vma_adjust and during rmap_walk

vma_adjust() is updating anon VMA information without any locks taken.
In constract, file-backed mappings use the i_mmap_lock. This lack of
locking can result in races with page migration. During rmap_walk(),
vma_address() can return -EFAULT for an address that will soon be valid.
This leaves a dangling migration PTE behind which can later cause a
BUG_ON to trigger when the page is faulted in.

This patch has vma_adjust() take the vma->anon_vma lock. When
rmap_walk_anon() is walking the anon_vma_chain list, it can encounter a
VMA a different anon_vma. It cannot just take this lock because
depending on the order of traversal of anon_vma_chains in other
processes, it could cause a livelock. Instead, it releases the pages
anon_vma lock it has and starts again from scratch until it can traverse
the full list uncontended.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/mmap.c |    6 ++++++
 mm/rmap.c |   21 ++++++++++++++++++++-
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f90ea92..61d6f1d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -578,6 +578,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	if (vma->anon_vma)
+		spin_lock(&vma->anon_vma->lock);
+
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -620,6 +623,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
+	if (vma->anon_vma)
+		spin_unlock(&vma->anon_vma->lock);
+
 	if (remove_next) {
 		if (file) {
 			fput(file);
diff --git a/mm/rmap.c b/mm/rmap.c
index 85f203e..59d5553 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1368,13 +1368,32 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	 * are holding mmap_sem. Users without mmap_sem are required to
 	 * take a reference count to prevent the anon_vma disappearing
 	 */
+retry:
 	anon_vma = page_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 	spin_lock(&anon_vma->lock);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
+		unsigned long address;
+
+		/*
+		 * Guard against livelocks by not spinning against
+		 * vma->anon_vma->lock. If contention is found, release our lock and
+		 * try again until VMA list can be traversed without worrying about
+		 * the details of the VMA changing underneath us.
+		 */
+		if (anon_vma != vma->anon_vma) {
+			if (!spin_trylock(&vma->anon_vma->lock)) {
+				spin_unlock(&anon_vma->lock);
+				goto retry;
+			}
+		}
+
+		address = vma_address(page, vma);
+		if (anon_vma != vma->anon_vma)
+			spin_unlock(&vma->anon_vma->lock);
+
 		if (address == -EFAULT)
 			continue;
 		ret = rmap_one(page, vma, address, arg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
