Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0356B02C3
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 21:50:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e26so28987333pfk.12
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:50:14 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id a14si2501651plt.8.2017.06.22.18.50.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 18:50:13 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id 132so15191820pgb.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:50:13 -0700 (PDT)
Date: Thu, 22 Jun 2017 18:50:10 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2] mm: Add SLUB free list pointer obfuscation
Message-ID: <20170623015010.GA137429@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@redhat.com>, Daniel Micay <danielmicay@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
v2:
- renamed Kconfig to SLAB_FREELIST_HARDENED; labbott.
---
 include/linux/slub_def.h |  4 ++++
 init/Kconfig             |  9 +++++++++
 mm/slub.c                | 32 +++++++++++++++++++++++++++-----
 3 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 07ef550c6627..d7990a83b416 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -93,6 +93,10 @@ struct kmem_cache {
 #endif
 #endif
 
+#ifdef CONFIG_SLAB_FREELIST_HARDENED
+	unsigned long random;
+#endif
+
 #ifdef CONFIG_NUMA
 	/*
 	 * Defragmentation by allocating from a remote node.
diff --git a/init/Kconfig b/init/Kconfig
index 1d3475fc9496..04ee3e507b9e 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1900,6 +1900,15 @@ config SLAB_FREELIST_RANDOM
 	  security feature reduces the predictability of the kernel slab
 	  allocator against heap overflows.
 
+config SLAB_FREELIST_HARDENED
+	bool "Harden slab freelist metadata"
+	depends on SLUB
+	help
+	  Many kernel heap attacks try to target slab cache metadata and
+	  other infrastructure. This options makes minor performance
+	  sacrifies to harden the kernel slab allocator against common
+	  freelist exploit methods.
+
 config SLUB_CPU_PARTIAL
 	default y
 	depends on SLUB && SMP
diff --git a/mm/slub.c b/mm/slub.c
index 57e5156f02be..590e7830aaed 100644
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
 
+#ifdef CONFIG_SLAB_FREELIST_HARDENED
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
