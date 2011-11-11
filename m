Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DED316B0072
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:37 -0500 (EST)
Message-Id: <20111111200734.418163913@linux.com>
Date: Fri, 11 Nov 2011 14:07:25 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 14/18] slub: Decomplicate the get_pointer_safe call and fixup statistics
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=stats_and_co
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-10 14:06:58.436231549 -0600
+++ linux-2.6/mm/slub.c	2011-11-10 14:33:21.465160604 -0600
@@ -2349,6 +2349,8 @@ redo:
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
+		void *next = get_freepointer_safe(s, object);
+
 		/*
 		 * The cmpxchg will only match if there was no additional
 		 * operation and if we are on the right processor.
@@ -2364,7 +2366,7 @@ redo:
 		if (unlikely(!irqsafe_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				object, tid,
-				get_freepointer_safe(s, object), next_tid(tid)))) {
+				next, next_tid(tid)))) {
 
 			note_cmpxchg_failure("slab_alloc", s, tid);
 			goto redo;
@@ -4506,12 +4508,13 @@ static ssize_t show_slab_objects(struct
 			if (!c || !c->page)
 				continue;
 
-			node = page_to_nid(c->page);
-			if (c->page) {
+			page = virt_to_head_page(c->freelist);
+			node = page_to_nid(page);
+			if (page) {
 					if (flags & SO_TOTAL)
-						x = c->page->objects;
+						x = page->objects;
 				else if (flags & SO_OBJECTS)
-					x = c->page->inuse;
+					x = page->inuse;
 				else
 					x = 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
