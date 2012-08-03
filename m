Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 483086B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 09:52:36 -0400 (EDT)
Date: Fri, 3 Aug 2012 08:52:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [02/19] slub: Use kmem_cache for the kmem_cache
 structure
In-Reply-To: <501BD019.70803@parallels.com>
Message-ID: <alpine.DEB.2.00.1208030851160.2332@router.home>
References: <20120802201506.266817615@linux.com> <20120802201531.490489455@linux.com> <501BD019.70803@parallels.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=------------090109090703010307020905
Content-ID: <alpine.DEB.2.00.1208030851161.2332@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--------------090109090703010307020905
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1208030851162.2332@router.home>

On Fri, 3 Aug 2012, Glauber Costa wrote:

> When a non-alias cache is freed, both sysfs_slab_remove and
> kmem_cache_release are called.
>
> You are freeing structures on both, so you have two double frees.
>
> slab_sysfs_remove() is the correct place for it, so you need to remove
> them from kmem_cache_release(), which becomes an empty function.

So this is another bug in Linus's tree.

> Please consider replacing your patch with the attached. Replacing your
> patch by this one makes my test case work after the series is applied.

Ok. In the future please send a diff of only the changes you have made. We
have various tools that generate these diffs for you. I hope you are using
some version control system like quilt or git?

--------------090109090703010307020905
Content-Type: TEXT/X-PATCH; NAME=cl-updated.patch
Content-ID: <alpine.DEB.2.00.1208030851163.2332@router.home>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=cl-updated.patch

Index: linux-slab/mm/slub.c

===================================================================

--- linux-slab.orig/mm/slub.c

+++ linux-slab/mm/slub.c

@@ -211,7 +211,7 @@ static inline int sysfs_slab_alias(struc

 static inline void sysfs_slab_remove(struct kmem_cache *s)

 {

 	kfree(s->name);

-	kfree(s);

+	kmem_cache_free(kmem_cache, s);

 }

 

 #endif

@@ -3938,7 +3938,7 @@ struct kmem_cache *__kmem_cache_create(c

 	if (!n)

 		return NULL;

 

-	s = kmalloc(kmem_size, GFP_KERNEL);

+	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);

 	if (s) {

 		if (kmem_cache_open(s, n,

 				size, align, flags, ctor)) {

@@ -3955,7 +3955,7 @@ struct kmem_cache *__kmem_cache_create(c

 			list_del(&s->list);

 			kmem_cache_close(s);

 		}

-		kfree(s);

+		kmem_cache_free(kmem_cache, s);

 	}

 	kfree(n);

 	return NULL;

@@ -5188,14 +5188,6 @@ static ssize_t slab_attr_store(struct ko

 	return err;

 }

 

-static void kmem_cache_release(struct kobject *kobj)

-{

-	struct kmem_cache *s = to_slab(kobj);

-

-	kfree(s->name);

-	kfree(s);

-}

-

 static const struct sysfs_ops slab_sysfs_ops = {

 	.show = slab_attr_show,

 	.store = slab_attr_store,

@@ -5203,7 +5195,6 @@ static const struct sysfs_ops slab_sysfs

 

 static struct kobj_type slab_ktype = {

 	.sysfs_ops = &slab_sysfs_ops,

-	.release = kmem_cache_release

 };

 

 static int uevent_filter(struct kset *kset, struct kobject *kobj)

@@ -5318,6 +5309,8 @@ static void sysfs_slab_remove(struct kme

 	kobject_uevent(&s->kobj, KOBJ_REMOVE);

 	kobject_del(&s->kobj);

 	kobject_put(&s->kobj);

+	kfree(s->name);

+	kmem_cache_free(kmem_cache, s);

 }

 

 /*


--------------090109090703010307020905--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
