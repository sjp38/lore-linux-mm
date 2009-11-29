Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 310D26B0044
	for <linux-mm@kvack.org>; Sun, 29 Nov 2009 10:50:35 -0500 (EST)
Date: Sun, 29 Nov 2009 15:50:32 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] ksm: hold anon_vma in rmap_item fix
Message-ID: <Pine.LNX.4.64.0911291544140.14991@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KSM mem_cgroup testing oopsed on NULL pointer in mem_cgroup_from_task(),
called from the mm_match_cgroup() in page_referenced_ksm().

Right, it is inappropriate to use mm_match_cgroup() on rmap_item->mm
there: that mm could be waiting for ksmd's final mmdrop(), with its
mm->owner task long gone.

Move the mm_match_cgroup() test down into the anon_vma loop, which is
where it now should be to match page_referenced_anon().  The anon_vma
guarantees its vmas are valid, which guarantee their mms are valid.

However... although this moves the oops from easy-to-reproduce to
never-seen, I think we shall want to do more later: so far as I can
see, with or without KSM, the use of mm->owner from page_referenced()
is unsafe.  No problem when NULL, but it may have been left pointing
to a task_struct freed by now, with nonsense in mm->owner->cgroups.

But let's put this patch in while we discuss that separately: perhaps
mm_need_new_owner() should not short-circuit when mm_users <= 1, or
perhaps it should then set mm->owner to NULL, or perhaps we abandon
mm->owner as more trouble than it's worth, or... perhaps I'm wrong.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- mmotm/mm/ksm.c	2009-11-25 09:28:50.000000000 +0000
+++ linux/mm/ksm.c	2009-11-27 13:49:50.000000000 +0000
@@ -1565,9 +1565,6 @@ again:
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct vm_area_struct *vma;
 
-		if (memcg && !mm_match_cgroup(rmap_item->mm, memcg))
-			continue;
-
 		spin_lock(&anon_vma->lock);
 		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
 			if (rmap_item->address < vma->vm_start ||
@@ -1582,6 +1579,9 @@ again:
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
 				continue;
 
+			if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
+				continue;
+
 			referenced += page_referenced_one(page, vma,
 				rmap_item->address, &mapcount, vm_flags);
 			if (!search_new_forks || !mapcount)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
