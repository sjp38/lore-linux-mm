Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 668376B0092
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:26 -0400 (EDT)
Message-Id: <20101005185821.068309361@linux.com>
Date: Tue, 05 Oct 2010 13:57:41 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 16/16] slub: Add stats for alien allocation slowpath
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_alien_slow
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Add counters and consistently count alien allocations that
have to go to the page allocator.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    2 ++
 mm/slub.c                |    7 ++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-10-05 13:40:04.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-10-05 13:40:14.000000000 -0500
@@ -19,12 +19,14 @@ enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu queue */
 	ALLOC_SHARED,		/* Allocation caused a shared cache transaction */
 	ALLOC_ALIEN,		/* Allocation from alien cache */
+	ALLOC_ALIEN_SLOW,	/* Alien allocation from partial */
 	ALLOC_DIRECT,		/* Allocation bypassing queueing */
 	ALLOC_SLOWPATH,		/* Allocation required refilling of queue */
 	FREE_FASTPATH,		/* Free to cpu queue */
 	FREE_SHARED,		/* Free caused a shared cache transaction */
 	FREE_DIRECT,		/* Free bypassing queues */
 	FREE_ALIEN,		/* Free to alien node */
+	FREE_ALIEN_SLOW,	/* Alien free had to drain cache */
 	FREE_SLOWPATH,		/* Required pushing objects out of the queue */
 	FREE_ADD_PARTIAL,	/* Freeing moved slab to partial list */
 	FREE_REMOVE_PARTIAL,	/* Freeing removed from partial list */
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-05 13:40:11.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-05 13:40:14.000000000 -0500
@@ -2021,6 +2021,7 @@ redo:
 		}
 	}
 
+	stat(s, ALLOC_ALIEN_SLOW);
 	spin_lock(&n->lock);
 	if (!list_empty(&n->partial)) {
 
@@ -2108,7 +2109,7 @@ static void slab_free_alien(struct kmem_
 		if (touched)
 			stat(s, FREE_ALIEN);
 		else
-			stat(s, FREE_SLOWPATH);
+			stat(s, FREE_ALIEN_SLOW);
 
 	} else {
 		/* Direct free to the slab */
@@ -5430,11 +5431,13 @@ SLAB_ATTR(text);						\
 STAT_ATTR(ALLOC_FASTPATH, alloc_fastpath);
 STAT_ATTR(ALLOC_SHARED, alloc_shared);
 STAT_ATTR(ALLOC_ALIEN, alloc_alien);
+STAT_ATTR(ALLOC_ALIEN_SLOW, alloc_alien_slow);
 STAT_ATTR(ALLOC_DIRECT, alloc_direct);
 STAT_ATTR(ALLOC_SLOWPATH, alloc_slowpath);
 STAT_ATTR(FREE_FASTPATH, free_fastpath);
 STAT_ATTR(FREE_SHARED, free_shared);
 STAT_ATTR(FREE_ALIEN, free_alien);
+STAT_ATTR(FREE_ALIEN_SLOW, free_alien_slow);
 STAT_ATTR(FREE_DIRECT, free_direct);
 STAT_ATTR(FREE_SLOWPATH, free_slowpath);
 STAT_ATTR(FREE_ADD_PARTIAL, free_add_partial);
@@ -5494,9 +5497,11 @@ static struct attribute *slab_attrs[] = 
 	&alloc_alien_attr.attr,
 	&alloc_direct_attr.attr,
 	&alloc_slowpath_attr.attr,
+	&alloc_alien_slow_attr.attr,
 	&free_fastpath_attr.attr,
 	&free_shared_attr.attr,
 	&free_alien_attr.attr,
+	&free_alien_slow_attr.attr,
 	&free_direct_attr.attr,
 	&free_slowpath_attr.attr,
 	&free_add_partial_attr.attr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
