Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D4B4E8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:12:30 -0500 (EST)
Date: Thu, 20 Jan 2011 11:12:26 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Slab allocators: Remove support for kmem_cache_name()
In-Reply-To: <4D3863C5.8020200@redhat.com>
Message-ID: <alpine.DEB.2.00.1101201111060.10695@router.home>
References: <4D3854AE.8060803@redhat.com> <alpine.DEB.2.00.1101200950040.10695@router.home> <4D385BFF.7060707@redhat.com> <alpine.DEB.2.00.1101201007260.10695@router.home> <4D3863C5.8020200@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Sandeen <sandeen@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2011, Eric Sandeen wrote:

> On 1/20/11 10:07 AM, Christoph Lameter wrote:
> > On Thu, 20 Jan 2011, Eric Sandeen wrote:
> >
> >> I did send a patch yesterday to stop the evil-ness ;)
> >
> > Can you give me an URL to that patch? CC me next time.
>
> Sure, sorry, didn't think of it, was in "ext4-is-broken" mode.
>
> Rather than fix up accounting I just made ext4 allocate the
> slab with a static name like everyone else.
>
> http://marc.info/?l=linux-ext4&m=129546975702198&w=2


Subject: Slab allocators: Remove support for kmem_cache_name()

The last user was ext4 and Eric Sandeen removed the call in a recent patch.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h |    1 -
 mm/slab.c            |    8 --------
 mm/slob.c            |    6 ------
 mm/slub.c            |    6 ------
 4 files changed, 21 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2011-01-20 11:07:51.000000000 -0600
+++ linux-2.6/include/linux/slab.h	2011-01-20 11:08:00.000000000 -0600
@@ -105,7 +105,6 @@ void kmem_cache_destroy(struct kmem_cach
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
-const char *kmem_cache_name(struct kmem_cache *);

 /*
  * Please use this macro to create slab caches. Simply specify the
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2011-01-20 11:08:12.000000000 -0600
+++ linux-2.6/mm/slab.c	2011-01-20 11:08:47.000000000 -0600
@@ -2147,8 +2147,6 @@ static int __init_refok setup_cpu_cache(
  *
  * @name must be valid until the cache is destroyed. This implies that
  * the module calling this has to destroy the cache before getting unloaded.
- * Note that kmem_cache_name() is not guaranteed to return the same pointer,
- * therefore applications must manage it themselves.
  *
  * The flags are
  *
@@ -3840,12 +3838,6 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);

-const char *kmem_cache_name(struct kmem_cache *cachep)
-{
-	return cachep->name;
-}
-EXPORT_SYMBOL_GPL(kmem_cache_name);
-
 /*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2011-01-20 11:08:50.000000000 -0600
+++ linux-2.6/mm/slob.c	2011-01-20 11:08:57.000000000 -0600
@@ -666,12 +666,6 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);

-const char *kmem_cache_name(struct kmem_cache *c)
-{
-	return c->name;
-}
-EXPORT_SYMBOL(kmem_cache_name);
-
 int kmem_cache_shrink(struct kmem_cache *d)
 {
 	return 0;
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-01-20 11:08:59.000000000 -0600
+++ linux-2.6/mm/slub.c	2011-01-20 11:09:05.000000000 -0600
@@ -2399,12 +2399,6 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);

-const char *kmem_cache_name(struct kmem_cache *s)
-{
-	return s->name;
-}
-EXPORT_SYMBOL(kmem_cache_name);
-
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
 							const char *text)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
