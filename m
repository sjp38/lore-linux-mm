Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5946B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 13:16:26 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so72482761igb.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 10:16:26 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id cy5si7842726igc.53.2015.04.09.10.16.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 10:16:25 -0700 (PDT)
Date: Thu, 9 Apr 2015 12:16:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: slub: bulk allocation from per cpu partial pages
In-Reply-To: <alpine.DEB.2.11.1504090859560.19278@gentwo.org>
Message-ID: <alpine.DEB.2.11.1504091215330.18198@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org> <20150408155304.4480f11f16b60f09879c350d@linux-foundation.org> <alpine.DEB.2.11.1504090859560.19278@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: brouer@redhat.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

Next step: cover all of the per cpu objects available.


Expand the bulk allocation support to drain the per cpu partial
pages while interrupts are off.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -2771,15 +2771,45 @@ bool kmem_cache_alloc_bulk(struct kmem_c
 		while (size) {
 			void *object = c->freelist;

-			if (!object)
-				break;
+			if (unlikely(!object)) {
+				/*
+				 * Check if there remotely freed objects
+				 * availalbe in the page.
+				 */
+				object = get_freelist(s, c->page);
+
+				if (!object) {
+					/*
+					 * All objects in use lets check if
+					 * we have other per cpu partial
+					 * pages that have available
+					 * objects.
+					 */
+					c->page = c->partial;
+					if (!c->page) {
+						/* No per cpu objects left */
+						c->freelist = NULL;
+						break;
+					}
+
+					/* Next per cpu partial page */
+					c->partial = c->page->next;
+					c->freelist = get_freelist(s,
+							c->page);
+					continue;
+				}
+
+			}
+

-			c->freelist = get_freepointer(s, object);
 			*p++ = object;
 			size--;

 			if (unlikely(flags & __GFP_ZERO))
 				memset(object, 0, s->object_size);
+
+			c->freelist = get_freepointer(s, object);
+
 		}
 		c->tid = next_tid(c->tid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
