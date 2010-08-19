Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5185E6B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:38:07 -0400 (EDT)
Date: Thu, 19 Aug 2010 16:31:26 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup3 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008191627100.5611@router.home>
References: <20100819203324.549566024@linux.com> <20100819203438.745611155@linux.com> <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, David Rientjes wrote:

> Since sysfs_slab_add() has been removed for kmem_cache and kmem_cache_node
> here, they apparently don't need the __SYSFS_ADD_DEFERRED flag even though
> we're waiting for the sysfs initcall since there's nothing that checks for
> it.  That bit can be removed, the last users of it were the dynamic DMA
> cache support that was dropped in patch 2.

Correct. Then we also do not need the sysfs_slab_add in
create_kmalloc_cache.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-19 16:28:40.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-19 16:30:39.000000000 -0500
@@ -148,7 +148,6 @@ static inline int kmem_cache_debug(struc

 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
-#define __SYSFS_ADD_DEFERRED	0x40000000UL /* Not yet visible via sysfs */
 #define __ALIEN_CACHE		0x20000000UL /* Slab has alien caches */

 static inline int aliens(struct kmem_cache *s)
@@ -3123,9 +3122,7 @@ static struct kmem_cache *__init create_
 		goto panic;

 	list_add(&s->list, &slab_caches);
-
-	if (!sysfs_slab_add(s))
-		return s;
+	return s;

 panic:
 	panic("Creation of kmalloc slab %s size=%d failed.\n", name, size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
