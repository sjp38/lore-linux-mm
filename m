Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 03F3B6B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:12:18 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:12:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [14/20] Always use the name "kmem_cache" for the slab
 cache with the kmem_cache structure.
In-Reply-To: <4FD99DE4.1080107@parallels.com>
Message-ID: <alpine.DEB.2.00.1206140908510.32075@router.home>
References: <20120613152451.465596612@linux.com> <20120613152522.780459464@linux.com> <4FD99DE4.1080107@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 14 Jun 2012, Glauber Costa wrote:

> On 06/13/2012 07:25 PM, Christoph Lameter wrote:
> > -	cache_cache.object_size = cache_cache.size;
> > -	cache_cache.size = ALIGN(cache_cache.size,
> > +	kmem_cache->size = kmem_cache->size;
>
> You actually mean kmem_cache->object_size = kmem_cache->size.
> Besides size = size making no sense, This had the effect for me to have
> allocations that were supposed to be zeroed not being so particularly in the
> edges of the objects.

Correct.

Subject: [slab] Provide correct reference to object size

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-06-14 03:10:09.002709496 -0500
+++ linux-2.6/mm/slab.c	2012-06-14 03:10:02.478709623 -0500
@@ -1496,8 +1496,8 @@ void __init kmem_cache_init(void)
 	 */
 	kmem_cache->size = offsetof(struct kmem_cache, array[nr_cpu_ids]) +
 				  nr_node_ids * sizeof(struct kmem_list3 *);
-	kmem_cache->size = kmem_cache->size;
-	kmem_cache->size = ALIGN(kmem_cache->size,
+	kmem_cache->object_size = kmem_cache->size;
+	kmem_cache->size = ALIGN(kmem_cache->object_size,
 					cache_line_size());
 	kmem_cache->reciprocal_buffer_size =
 		reciprocal_value(kmem_cache->size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
