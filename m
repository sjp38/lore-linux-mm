Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AA6FF6B02AD
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 12:18:10 -0400 (EDT)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o76GI6bJ016757
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 16:18:06 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o76GI1Gh868476
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 17:18:05 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o76GI0AA013769
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 17:18:01 +0100
Subject: PATCH: fix slab object alignment
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: cotte@de.ibm.com
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 06 Aug 2010 18:19:22 +0200
Message-ID: <1281111562.4843.11.camel@titan.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, arnd@arndb.de, ursula.braun@de.ibm.comUrsula Braun <ursula.braun@de.ibm.com>, Frank Blaschka <blaschka@linux.vnet.ibm.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

This patch fixes alignment of slab objects in case CONFIG_DEBUG_PAGEALLOC is
active.
Before this spot in kmem_cache_create, we have this situation:
- align contains the required alignment of the object
- cachep->obj_offset is 0 or equals align in case of CONFIG_DEBUG_SLAB
- size equals the size of the object, or object plus trailing redzone in case
  of CONFIG_DEBUG_SLAB

This spot tries to fill one page per object if the object is in certain size
limits, however setting obj_offset to PAGE_SIZE - size does break the object
alignment since size may not be aligned with the required alignment.
This patch simply adds an ALIGN(size, align) to the equation and fixes the
object size detection accordingly.

This code in drivers/s390/cio/qdio_setup_init has lead to incorrectly aligned
slab objects (sizeof(struct qdio_q) equals 1792):
	qdio_q_cache = kmem_cache_create("qdio_q", sizeof(struct qdio_q),
					 256, 0, NULL);

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
---
 mm/slab.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2331,8 +2331,8 @@ kmem_cache_create (const char *name, siz
 	}
 #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
 	if (size >= malloc_sizes[INDEX_L3 + 1].cs_size
-	    && cachep->obj_size > cache_line_size() && size < PAGE_SIZE) {
-		cachep->obj_offset += PAGE_SIZE - size;
+	    && cachep->obj_size > cache_line_size() && ALIGN(size, align) < PAGE_SIZE) {
+		cachep->obj_offset += PAGE_SIZE - ALIGN(size, align);
 		size = PAGE_SIZE;
 	}
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
