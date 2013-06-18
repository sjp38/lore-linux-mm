Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id B31D46B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 13:02:35 -0400 (EDT)
Date: Tue, 18 Jun 2013 17:02:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [3.11 3/4] Move kmalloc_node functions to common code
In-Reply-To: <CAOJsxLHPWJdc6Qy9e7-s-7+KWPOgbs8ZR+JpxWb9sykyC9Um8A@mail.gmail.com>
Message-ID: <0000013f583ce865-d803292b-f217-4fb7-a8c2-4366334cb425-000000@email.amazonses.com>
References: <20130614195500.373711648@linux.com> <0000013f444bf6e9-d535ba8b-df9e-4053-9ed4-eaba75e2cfd2-000000@email.amazonses.com> <CAOJsxLHPWJdc6Qy9e7-s-7+KWPOgbs8ZR+JpxWb9sykyC9Um8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="376175846-1273279216-1371574961=:4219"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--376175846-1273279216-1371574961=:4219
Content-Type: TEXT/PLAIN; charset=windows-1252
Content-Transfer-Encoding: 8BIT

On Tue, 18 Jun 2013, Pekka Enberg wrote:

> I'm seeing this after "make defconfig" on x86-64:
>
>   CC      mm/slub.o
> mm/slub.c:2445:7: error: conflicting types for i? 1/2 kmem_cache_alloc_node_tracei? 1/2 
> include/linux/slab.h:311:14: note: previous declaration of
> i? 1/2 kmem_cache_alloc_node_tracei? 1/2  was here
> mm/slub.c:2455:1: error: conflicting types for i? 1/2 kmem_cache_alloc_node_tracei? 1/2 
> include/linux/slab.h:311:14: note: previous declaration of
> i? 1/2 kmem_cache_alloc_node_tracei? 1/2  was here
> make[1]: *** [mm/slub.o] Error 1
> make: *** [mm/slub.o] Error 2

Gosh I dropped the size_t parameter from these functions. CONFIG_TRACING
needs these.


Subject: Fix kmem_cache_alloc*_trace parameters

The size parameter is needed.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2013-06-18 11:45:22.472313944 -0500
+++ linux/include/linux/slab.h	2013-06-18 11:53:29.816926981 -0500
@@ -313,12 +313,12 @@ static __always_inline void *kmem_cache_
 #ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 					   gfp_t gfpflags,
-					   int node);
+					   int node, size_t size);
 #else
 static __always_inline void *
 kmem_cache_alloc_node_trace(struct kmem_cache *s,
 			      gfp_t gfpflags,
-			      int node)
+			      int node, size_t size)
 {
 	return kmem_cache_alloc_node(s, gfpflags, node);
 }
@@ -360,10 +360,10 @@ static __always_inline void *kmalloc_lar
 }

 #ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t);
+extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t);
 #else
 static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
-		gfp_t flags)
+		gfp_t flags, size_t size)
 {
 	return kmem_cache_alloc(s, flags);
 }
@@ -390,7 +390,7 @@ static __always_inline void *kmalloc(siz
 				return ZERO_SIZE_PTR;

 			return kmem_cache_alloc_trace(kmalloc_caches[index],
-					flags);
+					flags, size);
 		}
 #endif
 	}
@@ -428,7 +428,7 @@ static __always_inline void *kmalloc_nod
 			return ZERO_SIZE_PTR;

 		return kmem_cache_alloc_node_trace(kmalloc_caches[i],
-			       			flags, node);
+			       			flags, node, size);
 	}
 #endif
 	return __kmalloc_node(size, flags, node);
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2013-06-18 11:45:15.984199533 -0500
+++ linux/mm/slab.c	2013-06-18 11:54:23.857883936 -0500
@@ -3681,7 +3681,7 @@ __do_kmalloc_node(size_t size, gfp_t fla
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return kmem_cache_alloc_node_trace(cachep, flags, node);
+	return kmem_cache_alloc_node_trace(cachep, flags, node, size);
 }

 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
--376175846-1273279216-1371574961=:4219--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
