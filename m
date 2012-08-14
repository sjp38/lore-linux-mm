Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id DB7106B0068
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 16:24:33 -0400 (EDT)
Date: Tue, 14 Aug 2012 20:24:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common11r [05/20] Move list_add() to slab_common.c
In-Reply-To: <CAAmzW4MkR8Bug8QNtPH4ghiXUYtL7UwTAt9EEYUm7_dUybF88w@mail.gmail.com>
Message-ID: <0000013926cf2193-d83b8a33-676e-4118-8659-a8318f863d20-000000@email.amazonses.com>
References: <20120809135623.574621297@linux.com> <20120809135634.298829888@linux.com> <CAAmzW4MkR8Bug8QNtPH4ghiXUYtL7UwTAt9EEYUm7_dUybF88w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Wed, 15 Aug 2012, JoonSoo Kim wrote:

> 2012/8/9 Christoph Lameter <cl@linux.com>:
> > Move the code to append the new kmem_cache to the list of slab caches to
> > the kmem_cache_create code in the shared code.
> >
> > This is possible now since the acquisition of the mutex was moved into
> > kmem_cache_create().
> >
> > V1->V2:
> >         - SLOB: Add code to remove the slab from list
> >          (will be removed a couple of patches down when we also move the
> >          list_del to common code).
>
> There is no code for "SLOB: Add code to remove the slab from list

Seems to have fallen through the cracks when the patches were rearranged.

Updated version (which also requires the next patch to be refreshed).
See the git tree at

	git://gentwo.org/christoph common

for the full update.



Subject: Move list_add() to slab_common.c

Move the code to append the new kmem_cache to the list of slab caches to
the kmem_cache_create code in the shared code.

This is possible now since the acquisition of the mutex was moved into
kmem_cache_create().

V1->V2:
	- SLOB: Add code to remove the slab from list
	 (will be removed a couple of patches down when we also move the
	 list_del to common code).

Acked-by: David Rientjes <rientjes@google.com>
Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-08-14 15:02:07.088212361 -0500
+++ linux/mm/slab_common.c	2012-08-14 15:02:10.104265294 -0500
@@ -96,6 +96,13 @@ struct kmem_cache *kmem_cache_create(con
 	if (!s)
 		err = -ENOSYS; /* Until __kmem_cache_create returns code */

+	/*
+	 * Check if the slab has actually been created and if it was a
+	 * real instatiation. Aliases do not belong on the list
+	 */
+	if (s && s->refcount == 1)
+		list_add(&s->list, &slab_caches);
+
 #ifdef CONFIG_DEBUG_VM
 out_locked:
 #endif
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-08-14 15:00:25.958437482 -0500
+++ linux/mm/slab.c	2012-08-14 15:02:10.104265294 -0500
@@ -1687,6 +1687,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);

+	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
 	if (INDEX_AC != INDEX_L3) {
 		sizes[INDEX_L3].cs_cachep =
 			__kmem_cache_create(names[INDEX_L3].name,
@@ -1694,6 +1695,7 @@ void __init kmem_cache_init(void)
 				ARCH_KMALLOC_MINALIGN,
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 				NULL);
+		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
 	}

 	slab_early_init = 0;
@@ -1712,6 +1714,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
+			list_add(&sizes->cs_cachep->list, &slab_caches);
 		}
 #ifdef CONFIG_ZONE_DMA
 		sizes->cs_dmacachep = __kmem_cache_create(
@@ -1721,6 +1724,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL);
+		list_add(&sizes->cs_dmacachep->list, &slab_caches);
 #endif
 		sizes++;
 		names++;
@@ -2590,6 +2594,7 @@ __kmem_cache_create (const char *name, s
 	}
 	cachep->ctor = ctor;
 	cachep->name = name;
+	cachep->refcount = 1;

 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
@@ -2606,8 +2611,6 @@ __kmem_cache_create (const char *name, s
 		slab_set_debugobj_lock_classes(cachep);
 	}

-	/* cache setup completed, link it into the list */
-	list_add(&cachep->list, &slab_caches);
 	return cachep;
 }

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-08-14 15:02:03.768154057 -0500
+++ linux/mm/slub.c	2012-08-14 15:02:10.108265363 -0500
@@ -3968,7 +3968,6 @@ struct kmem_cache *__kmem_cache_create(c
 				size, align, flags, ctor)) {
 			int r;

-			list_add(&s->list, &slab_caches);
 			mutex_unlock(&slab_mutex);
 			r = sysfs_slab_add(s);
 			mutex_lock(&slab_mutex);
@@ -3976,7 +3975,6 @@ struct kmem_cache *__kmem_cache_create(c
 			if (!r)
 				return s;

-			list_del(&s->list);
 			kmem_cache_close(s);
 		}
 		kmem_cache_free(kmem_cache, s);
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2012-08-14 15:00:25.958437482 -0500
+++ linux/mm/slob.c	2012-08-14 15:04:48.471045614 -0500
@@ -540,6 +540,10 @@ struct kmem_cache *__kmem_cache_create(c

 void kmem_cache_destroy(struct kmem_cache *c)
 {
+	mutex_lock(&slab_mutex);
+	list_del(&c->list);
+	mutex_unlock(&slab_mutex);
+
 	kmemleak_free(c);
 	if (c->flags & SLAB_DESTROY_BY_RCU)
 		rcu_barrier();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
