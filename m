Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 006FC6B060F
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 14:06:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p20so53199818pfj.2
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 11:06:12 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id k91si11914439pld.872.2017.08.02.11.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 11:06:11 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id z129so23991210pfb.3
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 11:06:11 -0700 (PDT)
Date: Wed, 2 Aug 2017 11:06:09 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [RESEND][PATCH v4] mm: Add SLUB free list pointer obfuscation
Message-ID: <20170802180609.GA66807@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Tycho Andersen <tycho@docker.com>, Alexander Popov <alex.popov@linux.com>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

This SLUB free list pointer obfuscation code is modified from Brad
Spengler/PaX Team's code in the last public patch of grsecurity/PaX based
on my understanding of the code. Changes or omissions from the original
code are mine and don't reflect the original grsecurity/PaX code.

This adds a per-cache random value to SLUB caches that is XORed with
their freelist pointer address and value. This adds nearly zero overhead
and frustrates the very common heap overflow exploitation method of
overwriting freelist pointers. A recent example of the attack is written
up here: http://cyseclabs.com/blog/cve-2016-6187-heap-off-by-one-exploit
and there is a section dedicated to the technique the book "A Guide to
Kernel Exploitation: Attacking the Core".

This is based on patches by Daniel Micay, and refactored to minimize the
use of #ifdef.

With 200-count cycles of "hackbench -g 20 -l 1000" I saw the following
run times:

before:
	mean 10.11882499999999999995
	variance .03320378329145728642
	stdev .18221905304181911048

after:
	mean 10.12654000000000000014
	variance .04700556623115577889
	stdev .21680767106160192064

The difference gets lost in the noise, but if the above is to be taken
literally, using CONFIG_FREELIST_HARDENED is 0.07% slower.

Suggested-by: Daniel Micay <danielmicay@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Tycho Andersen <tycho@docker.com>
Cc: Alexander Popov <alex.popov@linux.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
Andrew, can you please take this for -mm? It is a simple solution to a
common heap attack, and several people have already spoken up about how
they'd also like to be using it. (This is a distinct and non-overlapping
protection separate from the double-free protection proposed, which would
just be using the same CONFIG for toggling enablement.)

v4:
- add another reference to how common this exploit technique is.
v3:
- use static inlines instead of macros (akpm).
v2:
- rename CONFIG_SLAB_HARDENED to CONFIG_FREELIST_HARDENED (labbott).
---
 include/linux/slub_def.h |  4 ++++
 init/Kconfig             |  9 +++++++++
 mm/slub.c                | 42 +++++++++++++++++++++++++++++++++++++-----
 3 files changed, 50 insertions(+), 5 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index cc0faf3a90be..0783b622311e 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -115,6 +115,10 @@ struct kmem_cache {
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
index 8514b25db21c..3dbb980cb70b 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1571,6 +1571,15 @@ config SLAB_FREELIST_RANDOM
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
index 1d3f9835f4ea..c92d6369f5e0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -34,6 +34,7 @@
 #include <linux/stacktrace.h>
 #include <linux/prefetch.h>
 #include <linux/memcontrol.h>
+#include <linux/random.h>
 
 #include <trace/events/kmem.h>
 
@@ -238,30 +239,58 @@ static inline void stat(const struct kmem_cache *s, enum stat_item si)
  * 			Core slab cache functions
  *******************************************************************/
 
+/*
+ * Returns freelist pointer (ptr). With hardening, this is obfuscated
+ * with an XOR of the address where the pointer is held and a per-cache
+ * random number.
+ */
+static inline void *freelist_ptr(const struct kmem_cache *s, void *ptr,
+				 unsigned long ptr_addr)
+{
+#ifdef CONFIG_SLAB_FREELIST_HARDENED
+	return (void *)((unsigned long)ptr ^ s->random ^ ptr_addr);
+#else
+	return ptr;
+#endif
+}
+
+/* Returns the freelist pointer recorded at location ptr_addr. */
+static inline void *freelist_dereference(const struct kmem_cache *s,
+					 void *ptr_addr)
+{
+	return freelist_ptr(s, (void *)*(unsigned long *)(ptr_addr),
+			    (unsigned long)ptr_addr);
+}
+
 static inline void *get_freepointer(struct kmem_cache *s, void *object)
 {
-	return *(void **)(object + s->offset);
+	return freelist_dereference(s, object + s->offset);
 }
 
 static void prefetch_freepointer(const struct kmem_cache *s, void *object)
 {
-	prefetch(object + s->offset);
+	if (object)
+		prefetch(freelist_dereference(s, object + s->offset));
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
+	return freelist_ptr(s, p, freepointer_addr);
 }
 
 static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 {
-	*(void **)(object + s->offset) = fp;
+	unsigned long freeptr_addr = (unsigned long)object + s->offset;
+
+	*(void **)freeptr_addr = freelist_ptr(s, fp, freeptr_addr);
 }
 
 /* Loop over all objects in a slab */
@@ -3563,6 +3592,9 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 {
 	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
 	s->reserved = 0;
+#ifdef CONFIG_SLAB_FREELIST_HARDENED
+	s->random = get_random_long();
+#endif
 
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
