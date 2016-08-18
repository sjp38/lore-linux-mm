Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 799458308C
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 08:58:20 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k135so12038294lfb.2
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:58:20 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id rv14si1755450wjb.235.2016.08.18.05.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 05:58:19 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 04/16] slub: Convert to hotplug state machine
Date: Thu, 18 Aug 2016 14:57:19 +0200
Message-Id: <20160818125731.27256-5-bigeasy@linutronix.de>
In-Reply-To: <20160818125731.27256-1-bigeasy@linutronix.de>
References: <20160818125731.27256-1-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, rt@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Install the callbacks via the state machine.

Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 mm/slub.c                  | 65 +++++++++++++++-------------------------------
 2 files changed, 22 insertions(+), 44 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index c2cf14953abc..82ee32107dff 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -15,6 +15,7 @@ enum cpuhp_state {
 	CPUHP_X86_HPET_DEAD,
 	CPUHP_X86_APB_DEAD,
 	CPUHP_VIRT_NET_DEAD,
+	CPUHP_SLUB_DEAD,
 	CPUHP_WORKQUEUE_PREP,
 	CPUHP_POWER_NUMA_PREPARE,
 	CPUHP_HRTIMERS_PREPARE,
diff --git a/mm/slub.c b/mm/slub.c
index 30e5a0f0e191..1db4d5304ceb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -194,10 +194,6 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
 #define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
 
-#ifdef CONFIG_SMP
-static struct notifier_block slab_notifier;
-#endif
-
 /*
  * Tracking user of a slab.
  */
@@ -2288,6 +2284,25 @@ static void flush_all(struct kmem_cache *s)
 }
 
 /*
+ * Use the cpu notifier to insure that the cpu slabs are flushed when
+ * necessary.
+ */
+static int slub_cpu_dead(unsigned int cpu)
+{
+	struct kmem_cache *s;
+	unsigned long flags;
+
+	mutex_lock(&slab_mutex);
+	list_for_each_entry(s, &slab_caches, list) {
+		local_irq_save(flags);
+		__flush_cpu_slab(s, cpu);
+		local_irq_restore(flags);
+	}
+	mutex_unlock(&slab_mutex);
+	return 0;
+}
+
+/*
  * Check if the objects in a per cpu structure fit numa
  * locality expectations.
  */
@@ -4127,9 +4142,8 @@ void __init kmem_cache_init(void)
 	/* Setup random freelists for each cache */
 	init_freelist_randomization();
 
-#ifdef CONFIG_SMP
-	register_cpu_notifier(&slab_notifier);
-#endif
+	cpuhp_setup_state_nocalls(CPUHP_SLUB_DEAD, "SLUB_DEAD", NULL,
+				  slub_cpu_dead);
 
 	pr_info("SLUB: HWalign=%d, Order=%d-%d, MinObjects=%d, CPUs=%d, Nodes=%d\n",
 		cache_line_size(),
@@ -4193,43 +4207,6 @@ int __kmem_cache_create(struct kmem_cache *s, unsigned long flags)
 	return err;
 }
 
-#ifdef CONFIG_SMP
-/*
- * Use the cpu notifier to insure that the cpu slabs are flushed when
- * necessary.
- */
-static int slab_cpuup_callback(struct notifier_block *nfb,
-		unsigned long action, void *hcpu)
-{
-	long cpu = (long)hcpu;
-	struct kmem_cache *s;
-	unsigned long flags;
-
-	switch (action) {
-	case CPU_UP_CANCELED:
-	case CPU_UP_CANCELED_FROZEN:
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		mutex_lock(&slab_mutex);
-		list_for_each_entry(s, &slab_caches, list) {
-			local_irq_save(flags);
-			__flush_cpu_slab(s, cpu);
-			local_irq_restore(flags);
-		}
-		mutex_unlock(&slab_mutex);
-		break;
-	default:
-		break;
-	}
-	return NOTIFY_OK;
-}
-
-static struct notifier_block slab_notifier = {
-	.notifier_call = slab_cpuup_callback
-};
-
-#endif
-
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 {
 	struct kmem_cache *s;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
