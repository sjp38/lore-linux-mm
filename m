Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id B15CA6B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 09:23:21 -0400 (EDT)
Message-ID: <501BD019.70803@parallels.com>
Date: Fri, 3 Aug 2012 17:20:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [02/19] slub: Use kmem_cache for the kmem_cache structure
References: <20120802201506.266817615@linux.com> <20120802201531.490489455@linux.com>
In-Reply-To: <20120802201531.490489455@linux.com>
Content-Type: multipart/mixed;
	boundary="------------090109090703010307020905"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

--------------090109090703010307020905
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 08/03/2012 12:15 AM, Christoph Lameter wrote:
> Do not use kmalloc() but kmem_cache_alloc() for the allocation
> of the kmem_cache structures in slub.
> 
> This is the way its supposed to be. Recent merges lost
> the freeing of the kmem_cache structure and so this is also
> fixing memory leak on kmem_cache_destroy() by adding
> the missing free action to sysfs_slab_remove().

Okay. the problems I am seeing are due to to this patch.

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2012-08-01 13:02:18.897656578 -0500
> +++ linux-2.6/mm/slub.c	2012-08-01 13:06:02.673597753 -0500
> @@ -213,7 +213,7 @@
>  static inline void sysfs_slab_remove(struct kmem_cache *s)
>  {
>  	kfree(s->name);
> -	kfree(s);
> +	kmem_cache_free(kmem_cache, s);
>  }
>  
>  #endif
> @@ -3962,7 +3962,7 @@
>  	if (!n)
>  		return NULL;
>  
> -	s = kmalloc(kmem_size, GFP_KERNEL);
> +	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
>  	if (s) {
>  		if (kmem_cache_open(s, n,
>  				size, align, flags, ctor)) {
> @@ -3979,7 +3979,7 @@
>  			list_del(&s->list);
>  			kmem_cache_close(s);
>  		}
> -		kfree(s);
> +		kmem_cache_free(kmem_cache, s);
>  	}
>  	kfree(n);
>  	return NULL;
> @@ -5217,7 +5217,7 @@
>  	struct kmem_cache *s = to_slab(kobj);
>  
>  	kfree(s->name);
> -	kfree(s);
> +	kmem_cache_free(kmem_cache, s);
>  }
>  
>  static const struct sysfs_ops slab_sysfs_ops = {
> @@ -5342,6 +5342,8 @@
>  	kobject_uevent(&s->kobj, KOBJ_REMOVE);
>  	kobject_del(&s->kobj);
>  	kobject_put(&s->kobj);
> +	kfree(s->name);
> +	kmem_cache_free(kmem_cache, s);
>  }
>  
>  /*
> 

When a non-alias cache is freed, both sysfs_slab_remove and
kmem_cache_release are called.

You are freeing structures on both, so you have two double frees.

slab_sysfs_remove() is the correct place for it, so you need to remove
them from kmem_cache_release(), which becomes an empty function.

Please consider replacing your patch with the attached. Replacing your
patch by this one makes my test case work after the series is applied.

--------------090109090703010307020905
Content-Type: text/x-patch; name="cl-updated.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cl-updated.patch"

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
