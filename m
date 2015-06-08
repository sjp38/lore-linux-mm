Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f43.google.com (mail-vn0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 69EC36B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 06:16:49 -0400 (EDT)
Received: by vnbg1 with SMTP id g1so16734308vnb.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 03:16:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id if6si4070619vdb.58.2015.06.08.03.16.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 03:16:48 -0700 (PDT)
Date: Mon, 8 Jun 2015 12:16:39 +0200
From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Corruption with MMOTS
 slub-bulk-allocation-from-per-cpu-partial-pages.patch
Message-ID: <20150608121639.3d9ce2aa@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>


It seems the patch from (inserted below):
 http://ozlabs.org/~akpm/mmots/broken-out/slub-bulk-allocation-from-per-cpu-partial-pages.patch

Is not protecting access to c->partial "enough" (section is under
local_irq_disable/enable).  When exercising bulk API I can make it
crash/corrupt memory when compiled with CONFIG_SLUB_CPU_PARTIAL=y

First I suspected:
 object = get_freelist(s, c->page); 
But the problem goes way with CONFIG_SLUB_CPU_PARTIAL=n


From: Christoph Lameter <cl@linux.com>
Subject: slub: bulk allocation from per cpu partial pages

Cover all of the per cpu objects available.

Expand the bulk allocation support to drain the per cpu partial pages
while interrupts are off.

Signed-off-by: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/slub.c |   36 +++++++++++++++++++++++++++++++++---
 1 file changed, 33 insertions(+), 3 deletions(-)

diff -puN mm/slub.c~slub-bulk-allocation-from-per-cpu-partial-pages mm/slub.c
--- a/mm/slub.c~slub-bulk-allocation-from-per-cpu-partial-pages
+++ a/mm/slub.c
@@ -2769,15 +2769,45 @@ bool kmem_cache_alloc_bulk(struct kmem_c
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
 
_


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
