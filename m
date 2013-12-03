Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 614C06B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 10:22:31 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so9969416yha.25
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 07:22:31 -0800 (PST)
Received: from a9-62.smtp-out.amazonses.com (a9-62.smtp-out.amazonses.com. [54.240.9.62])
        by mx.google.com with ESMTP id b7si51371385yhm.85.2013.12.03.07.22.29
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 07:22:30 -0800 (PST)
Date: Tue, 3 Dec 2013 15:22:29 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: netfilter: active obj WARN when cleaning up
In-Reply-To: <20131202222208.GB13034@kroah.com>
Message-ID: <00000142b90da700-19f6b465-ff15-4b2b-9bcd-b91d71958b7f-000000@email.amazonses.com>
References: <20131127233415.GB19270@kroah.com> <00000142b4282aaf-913f5e4c-314c-4351-9d24-615e66928157-000000@email.amazonses.com> <20131202164039.GA19937@kroah.com> <00000142b4514eb5-2e8f675d-0ecc-423b-9906-58c5f383089b-000000@email.amazonses.com>
 <20131202172615.GA4722@kroah.com> <00000142b4aeca89-186fc179-92b8-492f-956c-38a7c196d187-000000@email.amazonses.com> <20131202190814.GA2267@kroah.com> <00000142b4d4360c-5755af87-b9b0-4847-b5fa-7a9dd13b49c5-000000@email.amazonses.com> <20131202212235.GA1297@kroah.com>
 <00000142b54f6694-c51e81b1-f1a2-483b-a1ce-a2d4cb6b155c-000000@email.amazonses.com> <20131202222208.GB13034@kroah.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2 Dec 2013, Greg KH wrote:

> Your release function had 2 tabs for the lines, not one.

Ah ok. Fixed.

> > > > Index: linux/include/linux/slub_def.h
> > > > ===================================================================
> > > > --- linux.orig/include/linux/slub_def.h	2013-12-02 13:31:07.395905824 -0600
> > > > +++ linux/include/linux/slub_def.h	2013-12-02 13:31:07.385906101 -0600
> > > > @@ -98,4 +98,8 @@ struct kmem_cache {
> > > >  	struct kmem_cache_node *node[MAX_NUMNODES];
> > > >  };
> > > >
> > > > +#ifdef CONFIG_SYSFS
> > > > +#define SLAB_SUPPORTS_SYSFS
> > >
> > > Why even define this?  Why not just use CONFIG_SYSFS?
> >
> > Because not all slab allocators currently support SYSFS and there is the
> > need to have different code now in slab_common.c depending on the
> > configuration of the allocator.
>
> But you are defining something that you only ever check once, why not
> just use CONFIG_SYSFS instead as it makes more sense, not the other way
> around.

We cannot use CONFIG_SYSFS otherwise it would break SLAB since some of
the code modified is shared between allocators. SLAB currently does not
support sysfs. When we add that then we can get rid of the #define.

Subject: slub: use sysfs'es release mechanism for kmem_cache

Sysfs has a release mechanism. Use that to release the kmem_cache structure
if CONFIG_SYSFS is enabled.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-12-03 09:19:26.214666210 -0600
+++ linux/include/linux/slub_def.h	2013-12-03 09:19:26.214666210 -0600
@@ -98,4 +98,8 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };

+#ifdef CONFIG_SYSFS
+#define SLAB_SUPPORTS_SYSFS
+#endif
+
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2013-12-03 09:19:26.214666210 -0600
+++ linux/mm/slab.h	2013-12-03 09:19:26.214666210 -0600
@@ -57,6 +57,7 @@ struct mem_cgroup;
 struct kmem_cache *
 __kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
 		   size_t align, unsigned long flags, void (*ctor)(void *));
+void sysfs_slab_remove(struct kmem_cache *);
 #else
 static inline struct kmem_cache *
 __kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
@@ -91,6 +92,7 @@ __kmem_cache_alias(struct mem_cgroup *me
 #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)

 int __kmem_cache_shutdown(struct kmem_cache *);
+void slab_kmem_cache_release(struct kmem_cache *);

 struct seq_file;
 struct file;
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2013-12-03 09:19:26.214666210 -0600
+++ linux/mm/slab_common.c	2013-12-03 09:19:54.373883727 -0600
@@ -251,6 +251,12 @@ kmem_cache_create(const char *name, size
 }
 EXPORT_SYMBOL(kmem_cache_create);

+void slab_kmem_cache_release(struct kmem_cache *s)
+{
+	kfree(s->name);
+	kmem_cache_free(kmem_cache, s);
+}
+
 void kmem_cache_destroy(struct kmem_cache *s)
 {
 	/* Destroy all the children caches if we aren't a memcg cache */
@@ -268,8 +274,12 @@ void kmem_cache_destroy(struct kmem_cach
 				rcu_barrier();

 			memcg_release_cache(s);
-			kfree(s->name);
-			kmem_cache_free(kmem_cache, s);
+#ifdef SLAB_SUPPORTS_SYSFS
+			sysfs_slab_remove(s);
+#else
+			slab_kmem_cache_release();
+
+#endif
 		} else {
 			list_add(&s->list, &slab_caches);
 			mutex_unlock(&slab_mutex);
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2013-12-03 09:19:26.214666210 -0600
+++ linux/mm/slub.c	2013-12-03 09:19:26.214666210 -0600
@@ -210,7 +210,6 @@ enum track_item { TRACK_ALLOC, TRACK_FRE
 #ifdef CONFIG_SYSFS
 static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
-static void sysfs_slab_remove(struct kmem_cache *);
 static void memcg_propagate_slab_attrs(struct kmem_cache *s);
 #else
 static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
@@ -3208,23 +3207,7 @@ static inline int kmem_cache_close(struc

 int __kmem_cache_shutdown(struct kmem_cache *s)
 {
-	int rc = kmem_cache_close(s);
-
-	if (!rc) {
-		/*
-		 * We do the same lock strategy around sysfs_slab_add, see
-		 * __kmem_cache_create. Because this is pretty much the last
-		 * operation we do and the lock will be released shortly after
-		 * that in slab_common.c, we could just move sysfs_slab_remove
-		 * to a later point in common code. We should do that when we
-		 * have a common sysfs framework for all allocators.
-		 */
-		mutex_unlock(&slab_mutex);
-		sysfs_slab_remove(s);
-		mutex_lock(&slab_mutex);
-	}
-
-	return rc;
+	return kmem_cache_close(s);
 }

 /********************************************************************
@@ -5073,6 +5056,11 @@ static void memcg_propagate_slab_attrs(s
 #endif
 }

+static void kmem_cache_release(struct kobject *k)
+{
+	slab_kmem_cache_release(to_slab(k));
+}
+
 static const struct sysfs_ops slab_sysfs_ops = {
 	.show = slab_attr_show,
 	.store = slab_attr_store,
@@ -5080,6 +5068,7 @@ static const struct sysfs_ops slab_sysfs

 static struct kobj_type slab_ktype = {
 	.sysfs_ops = &slab_sysfs_ops,
+	.release = kmem_cache_release,
 };

 static int uevent_filter(struct kset *kset, struct kobject *kobj)
@@ -5184,7 +5173,7 @@ static int sysfs_slab_add(struct kmem_ca
 	return 0;
 }

-static void sysfs_slab_remove(struct kmem_cache *s)
+void sysfs_slab_remove(struct kmem_cache *s)
 {
 	if (slab_state < FULL)
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
