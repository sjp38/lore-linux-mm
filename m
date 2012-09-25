Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 64DEF6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 07:21:13 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] slab: Ignore internal flags in cache creation
Date: Tue, 25 Sep 2012 15:17:46 +0400
Message-Id: <1348571866-31738-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

Some flags are used internally by the allocators for management
purposes. One example of that is the CFLGS_OFF_SLAB flag that slab uses
to mark that the metadata for that cache is stored outside of the slab.

No cache should ever pass those as a creation flags. We can just ignore
this bit if it happens to be passed (such as when duplicating a cache in
the kmem memcg patches)

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 include/linux/slab.h | 4 ++++
 mm/slab_common.c     | 5 +++++
 2 files changed, 9 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 0dd2dfa..437c07e 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -79,6 +79,10 @@
 /* The following flags affect the page allocator grouping pages by mobility */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
+
+/* The last flags are reserved for specific internal flags of the allocators */
+#define SLAB_INTERNAL 0xF0000000UL
+
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
  *
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 9c21725..359ef36 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -107,6 +107,11 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 	if (!kmem_cache_sanity_check(name, size) == 0)
 		goto out_locked;
 
+	/*
+	 * Clean any possible internal flags the caller may have passed.
+	 * We'll make those decisions ourselves.
+	 */
+	flags &= ~SLAB_INTERNAL;
 
 	s = __kmem_cache_alias(name, size, align, flags, ctor);
 	if (s)
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
