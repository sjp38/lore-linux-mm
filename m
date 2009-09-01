Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 73A456B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 09:46:58 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090831102642.GA30264@linux-sh.org>
References: <20090831102642.GA30264@linux-sh.org> <20090831074842.GA28091@linux-sh.org> <84144f020908310308i48790f78g5a7d73a60ea854f8@mail.gmail.com>
Subject: Re: page allocator regression on nommu
Date: Tue, 01 Sep 2009 14:46:45 +0100
Message-ID: <12589.1251812805@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: dhowells@redhat.com, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Mundt <lethal@linux-sh.org> wrote:

> Yeah, that looks a bit suspect. __put_nommu_region() is safe to be called
> without a call to add_nommu_region(), but we happen to trip over the
> BUG_ON() in this case because we've never made a single addition to the
> region tree.
> 
> We probably ought to just up_write() and return if nommu_region_tree ==
> RB_ROOT, which is what I'll do unless David objects.

I think that's the wrong thing to do.  I think we're better moving the call to
add_nommu_region() to above the "/* set up the mapping */" comment.  We hold
the region semaphore at this point, so the fact that it winds up in the tree
briefly won't cause a race, and it means __put_nommu_region() can be used with
impunity to correctly clean up.

See attached patch.

David
---
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NOMMU: Fix error handling in do_mmap_pgoff()

Fix the error handling in do_mmap_pgoff().  If do_mmap_shared_file() or
do_mmap_private() fail, we jump to the error_put_region label at which point we
cann __put_nommu_region() on the region - but we haven't yet added the region
to the tree, and so __put_nommu_region() may BUG because the region tree is
empty or it may corrupt the region tree.

To get around this, we can afford to add the region to the region tree before
calling do_mmap_shared_file() or do_mmap_private() as we keep nommu_region_sem
write-locked, so no-one can race with us by seeing a transient region.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 mm/nommu.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)


diff --git a/mm/nommu.c b/mm/nommu.c
index 7466c7a..aabe86c 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1347,6 +1347,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 	}
 
 	vma->vm_region = region;
+	add_nommu_region(region);
 
 	/* set up the mapping */
 	if (file && vma->vm_flags & VM_SHARED)
@@ -1356,8 +1357,6 @@ unsigned long do_mmap_pgoff(struct file *file,
 	if (ret < 0)
 		goto error_put_region;
 
-	add_nommu_region(region);
-
 	/* okay... we have a mapping; now we have to register it */
 	result = vma->vm_start;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
