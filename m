Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id F18E56B00F2
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 15:39:41 -0500 (EST)
Received: by laah2 with SMTP id h2so65628laa.2
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 12:39:40 -0800 (PST)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [PATCH v2 06/13] slab: Add kmem_cache_gfp_flags() helper function.
Date: Fri,  9 Mar 2012 12:39:09 -0800
Message-Id: <1331325556-16447-7-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: suleiman@google.com, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

This function returns the gfp flags that are always applied to
allocations of a kmem_cache.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
---
 include/linux/slab_def.h |    6 ++++++
 include/linux/slob_def.h |    6 ++++++
 include/linux/slub_def.h |    6 ++++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index fbd1117..25f9a6a 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -159,6 +159,12 @@ found:
 	return __kmalloc(size, flags);
 }
 
+static inline gfp_t
+kmem_cache_gfp_flags(struct kmem_cache *cachep)
+{
+	return cachep->gfpflags;
+}
+
 #ifdef CONFIG_NUMA
 extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
index 0ec00b3..3fa527d 100644
--- a/include/linux/slob_def.h
+++ b/include/linux/slob_def.h
@@ -34,4 +34,10 @@ static __always_inline void *__kmalloc(size_t size, gfp_t flags)
 	return kmalloc(size, flags);
 }
 
+static inline gfp_t
+kmem_cache_gfp_flags(struct kmem_cache *cachep)
+{
+	return 0;
+}
+
 #endif /* __LINUX_SLOB_DEF_H */
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a32bcfd..5911d81 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -313,4 +313,10 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 }
 #endif
 
+static inline gfp_t
+kmem_cache_gfp_flags(struct kmem_cache *cachep)
+{
+	return cachep->allocflags;
+}
+
 #endif /* _LINUX_SLUB_DEF_H */
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
