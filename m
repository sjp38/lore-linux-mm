Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 52AAF6B0099
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 16:36:57 -0400 (EDT)
Date: Tue, 3 Jul 2012 15:36:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH powerpc 2/2] kfree the cache name  of pgtable cache if
 SLUB is used
In-Reply-To: <alpine.DEB.2.00.1207031344240.14703@router.home>
Message-ID: <alpine.DEB.2.00.1207031535330.14703@router.home>
References: <1340617984.13778.37.camel@ThinkPad-T420> <1340618099.13778.39.camel@ThinkPad-T420> <alpine.DEB.2.00.1207031344240.14703@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>

Looking through the emails it seems that there is an issue with alias
strings. That can be solved by duping the name of the slab earlier in kmem_cache_create().
Does this patch fix the issue?

Subject: slub: Dup name earlier in kmem_cache_create

Dup the name earlier in kmem_cache_create so that alias
processing is done using the copy of the string and not
the string itself.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-06-11 08:49:56.000000000 -0500
+++ linux-2.6/mm/slub.c	2012-07-03 15:17:37.000000000 -0500
@@ -3933,8 +3933,12 @@ struct kmem_cache *kmem_cache_create(con
 	if (WARN_ON(!name))
 		return NULL;

+	n = kstrdup(name, GFP_KERNEL);
+	if (!n)
+		goto out;
+
 	down_write(&slub_lock);
-	s = find_mergeable(size, align, flags, name, ctor);
+	s = find_mergeable(size, align, flags, n, ctor);
 	if (s) {
 		s->refcount++;
 		/*
@@ -3944,7 +3948,7 @@ struct kmem_cache *kmem_cache_create(con
 		s->objsize = max(s->objsize, (int)size);
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));

-		if (sysfs_slab_alias(s, name)) {
+		if (sysfs_slab_alias(s, n)) {
 			s->refcount--;
 			goto err;
 		}
@@ -3952,31 +3956,26 @@ struct kmem_cache *kmem_cache_create(con
 		return s;
 	}

-	n = kstrdup(name, GFP_KERNEL);
-	if (!n)
-		goto err;
-
 	s = kmalloc(kmem_size, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
 			list_add(&s->list, &slab_caches);
 			up_write(&slub_lock);
-			if (sysfs_slab_add(s)) {
-				down_write(&slub_lock);
-				list_del(&s->list);
-				kfree(n);
-				kfree(s);
-				goto err;
-			}
-			return s;
+			if (!sysfs_slab_add(s))
+				return s;
+
+			down_write(&slub_lock);
+			list_del(&s->list);
 		}
 		kfree(s);
 	}
-	kfree(n);
+
 err:
+	kfree(n);
 	up_write(&slub_lock);

+out:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slabcache %s\n", name);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
