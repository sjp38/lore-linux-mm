Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 37F046B01F4
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 10:16:12 -0400 (EDT)
Date: Thu, 22 Apr 2010 15:14:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache  pages
Message-ID: <20100422141404.GA30306@csn.ul.ie>
References: <alpine.DEB.2.00.1004211004360.4959@router.home> <20100421151417.GK30306@csn.ul.ie> <alpine.DEB.2.00.1004211027120.4959@router.home> <20100421153421.GM30306@csn.ul.ie> <alpine.DEB.2.00.1004211038020.4959@router.home> <20100422092819.GR30306@csn.ul.ie> <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com> <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com> <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com> <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 07:51:53PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 22 Apr 2010 19:31:06 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 22 Apr 2010 19:13:12 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > On Thu, Apr 22, 2010 at 6:46 PM, KAMEZAWA Hiroyuki
> > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > > Hmm..in my test, the case was.
> > > >
> > > > Before try_to_unmap:
> > > >        mapcount=1, SwapCache, remap_swapcache=1
> > > > After remap
> > > >        mapcount=0, SwapCache, rc=0.
> > > >
> > > > So, I think there may be some race in rmap_walk() and vma handling or
> > > > anon_vma handling. migration_entry isn't found by rmap_walk.
> > > >
> > > > Hmm..it seems this kind patch will be required for debug.
> > > 
> 
> Ok, here is my patch for _fix_. But still testing...
> Running well at least for 30 minutes, where I can see bug in 10minutes.
> But this patch is too naive. please think about something better fix.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> At adjust_vma(), vma's start address and pgoff is updated under
> write lock of mmap_sem. This means the vma's rmap information
> update is atoimic only under read lock of mmap_sem.
> 
> 
> Even if it's not atomic, in usual case, try_to_ummap() etc...
> just fails to decrease mapcount to be 0. no problem.
> 
> But at page migration's rmap_walk(), it requires to know all
> migration_entry in page tables and recover mapcount.
> 
> So, this race in vma's address is critical. When rmap_walk meet
> the race, rmap_walk will mistakenly get -EFAULT and don't call
> rmap_one(). This patch adds a lock for vma's rmap information. 
> But, this is _very slow_.

Ok wow. That is exceptionally well-spotted. This looks like a proper bug
that compaction exposes as opposed to a bug that compaction introduces.

> We need something sophisitcated, light-weight update for this..
> 

In the event the VMA is backed by a file, the mapping i_mmap_lock is taken for
the duration of the update and is  taken elsewhere where the VMA information
is read such as rmap_walk_file()

In the event the VMA is anon, vma_adjust currently talks no locks and your
patch introduces a new one but why not use the anon_vma lock here? Am I
missing something that requires the new lock?

For example;

==== CUT HERE ====
mm: Take the anon_vma lock in vma_adjust()

vma_adjust() is updating anon VMA information without any locks taken.
In constract, file-backed mappings use the i_mmap_lock. This lack of
locking can result in races with page migration. During rmap_walk(),
vma_address() can return -EFAULT for an address that will soon be valid.
This leaves a dangling migration PTE behind which can later cause a
BUG_ON to trigger when the page is faulted in.

This patch takes the anon_vma->lock during vma_adjust to avoid such
races.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/mmap.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
