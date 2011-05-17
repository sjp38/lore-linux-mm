Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 52BDB6B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 17:29:35 -0400 (EDT)
Date: Tue, 17 May 2011 16:29:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: Remove node check for NUMA_NO_NODE in slab_free
In-Reply-To: <alpine.DEB.2.00.1105171615520.21780@router.home>
Message-ID: <alpine.DEB.2.00.1105171627380.22271@router.home>
References: <alpine.DEB.2.00.1105171615520.21780@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Argh not that simple without the ll patches. Need to deactivate slab
before setting c->page to NULL.

Subject: slub: Remove node check in slab_free

We can set the page pointing in the percpu structure to
NULL to have the same effect as setting c->node to NUMA_NO_NODE.

Gets rid of one check in slab_free() that was only used for
forcing the slab_free to the slowpath for debugging.

We still need to set c->node to NUMA_NO_NODE to force the
slab_alloc() fastpath to the slowpath in case of debugging.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-17 16:04:28.341344328 -0500
+++ linux-2.6/mm/slub.c	2011-05-17 16:22:07.621343094 -0500
@@ -1881,6 +1881,8 @@ debug:

 	page->inuse++;
 	page->freelist = get_freepointer(s, object);
+	deactivate_slab(s, c);
+	c->page = NULL;
 	c->node = NUMA_NO_NODE;
 	goto unlock_out;
 }
@@ -2112,7 +2114,7 @@ redo:
 	tid = c->tid;
 	barrier();

-	if (likely(page == c->page && c->node != NUMA_NO_NODE)) {
+	if (likely(page == c->page)) {
 		set_freepointer(s, object, c->freelist);

 		if (unlikely(!irqsafe_cpu_cmpxchg_double(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
