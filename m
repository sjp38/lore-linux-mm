Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50F656B02C3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:01:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v9so117162741pfk.5
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 20:01:15 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id b8si2614862pge.432.2017.06.19.20.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 20:01:14 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id e187so4354096pgc.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 20:01:14 -0700 (PDT)
Date: Mon, 19 Jun 2017 20:01:12 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm: Add SLUB free list pointer obfuscation
Message-ID: <20170620030112.GA140256@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

This SLUB free list pointer obfuscation code is modified from Brad
Spengler/PaX Team's code in the last public patch of grsecurity/PaX based
on my understanding of the code. Changes or omissions from the original
code are mine and don't reflect the original grsecurity/PaX code.

This adds a per-cache random value to SLUB caches that is XORed with
their freelist pointers. This adds nearly zero overhead and frustrates the
very common heap overflow exploitation method of overwriting freelist
pointers. A recent example of the attack is written up here:
http://cyseclabs.com/blog/cve-2016-6187-heap-off-by-one-exploit

This is based on patches by Daniel Micay, and refactored to avoid lots
of #ifdef code.

Suggested-by: Daniel Micay <danielmicay@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/slub_def.h |  4 ++++
 init/Kconfig             | 10 ++++++++++
 mm/slub.c                | 32 +++++++++++++++++++++++++++-----
 3 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 07ef550c6627..0258d6d74e9c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -93,6 +93,10 @@ struct kmem_cache {
 #endif
 #endif
 
+#ifdef CONFIG_SLAB_HARDENED
+	unsigned long random;
+#endif
+
 #ifdef CONFIG_NUMA
 	/*
 	 * Defragmentation by allocating from a remote node.
diff --git a/init/Kconfig b/init/Kconfig
index 1d3475fc9496..eb91082546bf 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1900,6 +1900,16 @@ config SLAB_FREELIST_RANDOM
 	  security feature reduces the predictability of the kernel slab
 	  allocator against heap overflows.
 
+config SLAB_HARDENED
+	bool "Harden slab cache infrastructure"
+	default y
+	depends on SLAB_FREELIST_RANDOM && SLUB
+	help
+	  Many kernel heap attacks try to target slab cache metadata and
+	  other infrastructure. This options makes minor performance
+	  sacrifies to harden the kernel slab allocator against common
+	  exploit methods.
+
 config SLUB_CPU_PARTIAL
 	default y
 	depends on SLUB && SMP
diff --git a/mm/slub.c b/mm/slub.c
index 57e5156f02be..ffede2e0c5c1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -34,6 +34,7 @@
 #include <linux/stacktrace.h>
 #include <linux/prefetch.h>
 #include <linux/memcontrol.h>
+#include <linux/random.h>
 
 #include <trace/events/kmem.h>
 
@@ -238,30 +239,50 @@ static inline void stat(const struct kmem_cache *s, enum stat_item si)
  * 			Core slab cache functions
  *******************************************************************/
 
+#ifdef CONFIG_SLAB_HARDENED
+# define initialize_random(s)					\
+		do {						\
+			s->random = get_random_long();		\
+		} while (0)
+# define FREEPTR_VAL(ptr, ptr_addr, s)	\
+		(void *)((unsigned long)(ptr) ^ s->random ^ (ptr_addr))
+#else
+# define initialize_random(s)		do { } while (0)
+# define FREEPTR_VAL(ptr, addr, s)	((void *)(ptr))
+#endif
+#define FREELIST_ENTRY(ptr_addr, s)				\
+		FREEPTR_VAL(*(unsigned long *)(ptr_addr),	\
+			    (unsigned long)ptr_addr, s)
+
 static inline void *get_freepointer(struct kmem_cache *s, void *object)
 {
-	return *(void **)(object + s->offset);
+	return FREELIST_ENTRY(object + s->offset, s);
 }
 
 static void prefetch_freepointer(const struct kmem_cache *s, void *object)
 {
-	prefetch(object + s->offset);
+	if (object)
+		prefetch(FREELIST_ENTRY(object + s->offset, s));
 }
 
 static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
 {
+	unsigned long freepointer_addr;
 	void *p;
 
 	if (!debug_pagealloc_enabled())
 		return get_freepointer(s, object);
 
-	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
-	return p;
+	freepointer_addr = (unsigned long)object + s->offset;
+	probe_kernel_read(&p, (void **)freepointer_addr, sizeof(p));
+	return FREEPTR_VAL(p, freepointer_addr, s);
 }
 
 static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 {
-	*(void **)(object + s->offset) = fp;
+	unsigned long freeptr_addr = (unsigned long)object + s->offset;
+
+	*(void **)freeptr_addr = FREEPTR_VAL(fp, freeptr_addr, s);
 }
 
 /* Loop over all objects in a slab */
@@ -3536,6 +3557,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 {
 	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
 	s->reserved = 0;
+	initialize_random(s);
 
 	if (need_reserve_slab_rcu && (s->flags & SLAB_TYPESAFE_BY_RCU))
 		s->reserved = sizeof(struct rcu_head);
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
