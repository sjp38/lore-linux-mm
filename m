Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 82CE16B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:24:13 -0400 (EDT)
Message-Id: <201106021424.p52EO91O006974@lab-17.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 2 Jun 2011 10:19:41 -0400
Subject: [PATCH] slub: always align cpu_slab to honor cmpxchg_double requirement
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On an architecture without CMPXCHG_LOCAL but with DEBUG_VM enabled,
the VM_BUG_ON() in __pcpu_double_call_return_bool() will cause an early
panic during boot unless we always align cpu_slab properly.

In principle we could remove the alignment-testing VM_BUG_ON() for
architectures that don't have CMPXCHG_LOCAL, but leaving it in means
that new code will tend not to break x86 even if it is introduced
on another platform, and it's low cost to require alignment.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
This needs to be pushed for 3.0 to allow arch/tile to boot.
I'm happy to push it but I assume it would be better coming
from an mm or percpu tree.  Thanks!

 include/linux/percpu.h |    3 +++
 mm/slub.c              |   12 ++++--------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 8b97308..9ca008f 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -259,6 +259,9 @@ extern void __bad_size_call_parameter(void);
  * Special handling for cmpxchg_double.  cmpxchg_double is passed two
  * percpu variables.  The first has to be aligned to a double word
  * boundary and the second has to follow directly thereafter.
+ * We enforce this on all architectures even if they don't support
+ * a double cmpxchg instruction, since it's a cheap requirement, and it
+ * avoids breaking the requirement for architectures with the instruction.
  */
 #define __pcpu_double_call_return_bool(stem, pcp1, pcp2, ...)		\
 ({									\
diff --git a/mm/slub.c b/mm/slub.c
index 7be0223..35f351f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2320,16 +2320,12 @@ static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
 	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
 			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu));
 
-#ifdef CONFIG_CMPXCHG_LOCAL
 	/*
-	 * Must align to double word boundary for the double cmpxchg instructions
-	 * to work.
+	 * Must align to double word boundary for the double cmpxchg
+	 * instructions to work; see __pcpu_double_call_return_bool().
 	 */
-	s->cpu_slab = __alloc_percpu(sizeof(struct kmem_cache_cpu), 2 * sizeof(void *));
-#else
-	/* Regular alignment is sufficient */
-	s->cpu_slab = alloc_percpu(struct kmem_cache_cpu);
-#endif
+	s->cpu_slab = __alloc_percpu(sizeof(struct kmem_cache_cpu),
+				     2 * sizeof(void *));
 
 	if (!s->cpu_slab)
 		return 0;
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
