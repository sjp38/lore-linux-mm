Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 890956B01EE
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:24:18 -0400 (EDT)
Date: Wed, 28 Apr 2010 15:23:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3] Fix migration races in rmap_walk() V2
Message-ID: <20100428142356.GF15815@csn.ul.ie>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1004271723090.24133@router.home> <20100427223242.GG8860@random.random> <20100428091345.496ca4c4.kamezawa.hiroyu@jp.fujitsu.com> <20100428002056.GH510@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100428002056.GH510@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 02:20:56AM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 28, 2010 at 09:13:45AM +0900, KAMEZAWA Hiroyuki wrote:
> > Doing some check in move_ptes() after vma_adjust() is not safe.
> > IOW, when vma's information and information in page-table is incosistent...objrmap
> > is broken and migartion will cause panic.
> > 
> > Then...I think there are 2 ways.
> >   1. use seqcounter in "mm_struct" as previous patch and lock it at mremap.
> > or
> >   2. get_user_pages_fast() when do remap.
> 
> 3 take the anon_vma->lock
> 

I've been looking at ways during the day that the anon_vma lock can be held
while the page tables are being allocated. The schemes were way too hairy
just to cover a migration corner case.

As this is particular to exec, I'm wondering if Kamezawa's additional proposal
of just skipping migration of pages within the temporary stack might be the
best solution overall in terms of effectiveness and simplicity. His patch
introduced a new variable to the VMA but it shouldn't be necessary and it
altered vma_address which is unnecessary.

Here is a different version of the same basic idea to skip temporary VMAs
during migration. Maybe go with this?

(As a heads-up, I'll also be going offline in about 24 hours until Tuesday
morning. The area I'm in has zero internet access)

==== CUT HERE ====
mm,migration: Avoid race between shift_arg_pages() and rmap_walk() during migration by not migrating temporary stacks

Page migration requires rmap to be able to find all ptes mapping a page
at all times, otherwise the migration entry can be instantiated, but it
is possible to leave one behind if the second rmap_walk fails to find
the page.  If this page is later faulted, migration_entry_to_page() will
call BUG because the page is locked indicating the page was migrated by
the migration PTE not cleaned up.

There is a race between shift_arg_pages and migration that allows this
bug to trigger. A temporary stack is setup during exec and later moved. If
migration moves a page in the temporary stack and the VMA is then removed,
the migration PTE may not be found leading to a BUG when the stack is faulted.

Ideally, shift_arg_pages must run atomically with respect of rmap_walk by
holding the anon_vma lock but this is problematic as pages must be allocated
for page tables. Instead, this patch identifies when it is about to migrate
pages from a temporary stack and leaves them alone.  Memory hot-remove will
try again, sys_move_pages() wouldn't be operating during exec() time and
memory compaction will just continue to another page without concern.

[kamezawa.hiroyu@jp.fujitsu.com: Idea for having migration skip the stacks]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/rmap.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 85f203e..5aaf4df 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1141,6 +1141,21 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	return ret;
 }
 
+static bool is_vma_temporary_stack(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags != VM_STACK_FLAGS)
+		return false;
+
+	/*
+	 * Only during exec will the total VM consumed by a process
+	 * be exacly the same as the stack
+	 */
+	if (vma->vm_mm->stack_vm == 1 && vma->vm_mm->total_vm == 1)
+		return true;
+
+	return false;
+}
+
 /**
  * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
  * rmap method
@@ -1169,7 +1184,21 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
+		unsigned long address;
+
+		/*
+		 * During exec, a temporary VMA is setup and later moved.
+		 * The VMA is moved under the anon_vma lock but not the
+		 * page tables leading to a race where migration cannot
+		 * find the migration ptes. Rather than increasing the
+		 * locking requirements of exec(), migration skips
+		 * temporary VMAs until after exec() completes.
+		 */
+		if (PAGE_MIGRATION && (flags & TTU_MIGRATION) &&
+				is_vma_temporary_stack(vma))
+			continue;
+
+		address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
 		ret = try_to_unmap_one(page, vma, address, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
