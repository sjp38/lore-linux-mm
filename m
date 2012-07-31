Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 4E55C6B00A4
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 14:02:57 -0400 (EDT)
Date: Tue, 31 Jul 2012 13:02:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [8/9] Move duping of slab name to slab_common.c
In-Reply-To: <20120731173638.084563156@linux.com>
Message-ID: <alpine.DEB.2.00.1207311302270.5278@router.home>
References: <20120731173620.432853182@linux.com> <20120731173638.084563156@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Patch not refreshed.... Sigh... use this one:

Subject: Move duping of slab name to slab_common.c

Duping of the slabname has to be done by each slab. Moving this code
to slab_common avoids duplicate implementations.

With this patch we have common string handling for all slab allocators.
Strings passed to kmem_cache_create() are copied internally. Subsystems
can create temporary strings to create slab caches.

Slabs allocated in early states of bootstrap will never be freed (and those
can never be freed since they are essential to slab allocator operations).
During bootstrap we therefore do not have to worry about duping names.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab_common.c |   24 +++++++++++++++++-------
 mm/slub.c        |    5 -----
 2 files changed, 17 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-07-31 12:20:56.976501176 -0500
+++ linux-2.6/mm/slab_common.c	2012-07-31 13:01:46.763397315 -0500
@@ -53,6 +53,7 @@
 		unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
+	char *n;

 #ifdef CONFIG_DEBUG_VM
 	if (!name || in_interrupt() || size < sizeof(void *) ||
@@ -97,14 +98,22 @@
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
 #endif

-	s = __kmem_cache_create(name, size, align, flags, ctor);
+	n = kstrdup(name, GFP_KERNEL);
+	if (!n)
+		goto oops;

-	/*
-	 * Check if the slab has actually been created and if it was a
-	 * real instatiation. Aliases do not belong on the list
-	 */
-	if (s && s->refcount == 1)
-		list_add(&s->list, &slab_caches);
+	s = __kmem_cache_create(n, size, align, flags, ctor);
+
+	if (s) {
+		/*
+		 * Check if the slab has actually been created and if it was a
+		 * real instatiation. Aliases do not belong on the list
+		 */
+		if (s->refcount == 1)
+			list_add(&s->list, &slab_caches);
+
+	} else
+		kfree(n);

 #ifdef CONFIG_DEBUG_VM
 oops:
@@ -134,6 +143,7 @@
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();

+			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-07-31 12:20:56.976501176 -0500
+++ linux-2.6/mm/slub.c	2012-07-31 13:01:46.775397529 -0500
@@ -208,10 +208,7 @@
 static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
 static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
 							{ return 0; }
-static inline void sysfs_slab_remove(struct kmem_cache *s)
-{
-	kfree(s->name);
-}
+static inline void sysfs_slab_remove(struct kmem_cache *s) { }

 #endif

@@ -3898,7 +3895,6 @@
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
-	char *n;

 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
@@ -3917,13 +3913,9 @@
 		return s;
 	}

-	n = kstrdup(name, GFP_KERNEL);
-	if (!n)
-		return NULL;
-
 	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
 	if (s) {
-		if (kmem_cache_open(s, n,
+		if (kmem_cache_open(s, name,
 				size, align, flags, ctor)) {
 			int r;

@@ -3938,7 +3930,6 @@
 		}
 		kfree(s);
 	}
-	kfree(n);
 	return NULL;
 }

@@ -5299,7 +5290,6 @@
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);
-	kfree(s->name);
 }

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
