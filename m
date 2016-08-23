Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3783E6B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:53:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so84646684wml.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 05:53:34 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q140si3461468wme.33.2016.08.23.05.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 05:53:32 -0700 (PDT)
Date: Tue, 23 Aug 2016 14:53:19 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 03/16 v2] slab: Convert to hotplug state machine
Message-ID: <20160823125319.abeapfjapf2kfezp@linutronix.de>
References: <20160818125731.27256-1-bigeasy@linutronix.de>
 <20160818125731.27256-4-bigeasy@linutronix.de>
 <20160818170819.pubp6ywvzkf5u3dg@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20160818170819.pubp6ywvzkf5u3dg@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, rt@linutronix.de, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Install the callbacks via the state machine.

Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Reviewed-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Richard Weinberger <richard@nod.at>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1=E2=80=A6v2: remove debug pr_err()

 include/linux/cpuhotplug.h |   1 +
 include/linux/slab.h       |   8 ++++
 kernel/cpu.c               |   7 ++-
 mm/slab.c                  | 116 ++++++++++++++++++++---------------------=
----
 4 files changed, 67 insertions(+), 65 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 4c79f40fcebc..c2cf14953abc 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -22,6 +22,7 @@ enum cpuhp_state {
 	CPUHP_X2APIC_PREPARE,
 	CPUHP_SMPCFD_PREPARE,
 	CPUHP_RELAY_PREPARE,
+	CPUHP_SLAB_PREPARE,
 	CPUHP_RCUTREE_PREP,
 	CPUHP_NOTIFY_PREPARE,
 	CPUHP_TIMERS_DEAD,
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 4293808d8cfb..084b12bad198 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -650,4 +650,12 @@ static inline void *kzalloc_node(size_t size, gfp_t fl=
ags, int node)
 unsigned int kmem_cache_size(struct kmem_cache *s);
 void __init kmem_cache_init_late(void);
=20
+#if defined(CONFIG_SMP) && defined(CONFIG_SLAB)
+int slab_prepare_cpu(unsigned int cpu);
+int slab_dead_cpu(unsigned int cpu);
+#else
+#define slab_prepare_cpu	NULL
+#define slab_dead_cpu		NULL
+#endif
+
 #endif	/* _LINUX_SLAB_H */
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 2a11381d5997..82bf61c67316 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -24,6 +24,7 @@
 #include <linux/irq.h>
 #include <linux/smpboot.h>
 #include <linux/relay.h>
+#include <linux/slab.h>
=20
 #include <trace/events/power.h>
 #define CREATE_TRACE_POINTS
@@ -1273,6 +1274,11 @@ static struct cpuhp_step cpuhp_bp_states[] =3D {
 		.startup =3D relay_prepare_cpu,
 		.teardown =3D NULL,
 	},
+	[CPUHP_SLAB_PREPARE] =3D {
+		.name =3D "SLAB prepare",
+		.startup =3D slab_prepare_cpu,
+		.teardown =3D slab_dead_cpu,
+	},
 	[CPUHP_RCUTREE_PREP] =3D {
 		.name =3D "RCU-tree prepare",
 		.startup =3D rcutree_prepare_cpu,
@@ -1376,7 +1382,6 @@ static struct cpuhp_step cpuhp_ap_states[] =3D {
 		.startup =3D rcutree_online_cpu,
 		.teardown =3D rcutree_offline_cpu,
 	},
-
 	/*
 	 * Online/down_prepare notifiers. Will be removed once the notifiers
 	 * are converted to states.
diff --git a/mm/slab.c b/mm/slab.c
index 0eb6691ae6fc..1cecd9fe23e3 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -887,6 +887,7 @@ static int init_cache_node(struct kmem_cache *cachep, i=
nt node, gfp_t gfp)
 	return 0;
 }
=20
+#if (defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)) || defined(CO=
NFIG_SMP)
 /*
  * Allocates and initializes node for a node on each slab cache, used for
  * either memory or cpu hotplug.  If memory is being hot-added, the kmem_c=
ache_node
@@ -909,6 +910,7 @@ static int init_cache_node_node(int node)
=20
 	return 0;
 }
+#endif
=20
 static int setup_kmem_cache_node(struct kmem_cache *cachep,
 				int node, gfp_t gfp, bool force_change)
@@ -976,6 +978,8 @@ static int setup_kmem_cache_node(struct kmem_cache *cac=
hep,
 	return ret;
 }
=20
+#ifdef CONFIG_SMP
+
 static void cpuup_canceled(long cpu)
 {
 	struct kmem_cache *cachep;
@@ -1076,65 +1080,54 @@ static int cpuup_prepare(long cpu)
 	return -ENOMEM;
 }
=20
-static int cpuup_callback(struct notifier_block *nfb,
-				    unsigned long action, void *hcpu)
+int slab_prepare_cpu(unsigned int cpu)
 {
-	long cpu =3D (long)hcpu;
-	int err =3D 0;
+	int err;
=20
-	switch (action) {
-	case CPU_UP_PREPARE:
-	case CPU_UP_PREPARE_FROZEN:
-		mutex_lock(&slab_mutex);
-		err =3D cpuup_prepare(cpu);
-		mutex_unlock(&slab_mutex);
-		break;
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		start_cpu_timer(cpu);
-		break;
-#ifdef CONFIG_HOTPLUG_CPU
-  	case CPU_DOWN_PREPARE:
-  	case CPU_DOWN_PREPARE_FROZEN:
-		/*
-		 * Shutdown cache reaper. Note that the slab_mutex is
-		 * held so that if cache_reap() is invoked it cannot do
-		 * anything expensive but will only modify reap_work
-		 * and reschedule the timer.
-		*/
-		cancel_delayed_work_sync(&per_cpu(slab_reap_work, cpu));
-		/* Now the cache_reaper is guaranteed to be not running. */
-		per_cpu(slab_reap_work, cpu).work.func =3D NULL;
-  		break;
-  	case CPU_DOWN_FAILED:
-  	case CPU_DOWN_FAILED_FROZEN:
-		start_cpu_timer(cpu);
-  		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		/*
-		 * Even if all the cpus of a node are down, we don't free the
-		 * kmem_cache_node of any cache. This to avoid a race between
-		 * cpu_down, and a kmalloc allocation from another cpu for
-		 * memory from the node of the cpu going down.  The node
-		 * structure is usually allocated from kmem_cache_create() and
-		 * gets destroyed at kmem_cache_destroy().
-		 */
-		/* fall through */
-#endif
-	case CPU_UP_CANCELED:
-	case CPU_UP_CANCELED_FROZEN:
-		mutex_lock(&slab_mutex);
-		cpuup_canceled(cpu);
-		mutex_unlock(&slab_mutex);
-		break;
-	}
-	return notifier_from_errno(err);
+	mutex_lock(&slab_mutex);
+	err =3D cpuup_prepare(cpu);
+	mutex_unlock(&slab_mutex);
+	return err;
 }
=20
-static struct notifier_block cpucache_notifier =3D {
-	&cpuup_callback, NULL, 0
-};
+/*
+ * This is called for a failed online attempt and for a successful
+ * offline.
+ *
+ * Even if all the cpus of a node are down, we don't free the
+ * kmem_list3 of any cache. This to avoid a race between cpu_down, and
+ * a kmalloc allocation from another cpu for memory from the node of
+ * the cpu going down.  The list3 structure is usually allocated from
+ * kmem_cache_create() and gets destroyed at kmem_cache_destroy().
+ */
+int slab_dead_cpu(unsigned int cpu)
+{
+	mutex_lock(&slab_mutex);
+	cpuup_canceled(cpu);
+	mutex_unlock(&slab_mutex);
+	return 0;
+}
+#endif
+
+static int slab_online_cpu(unsigned int cpu)
+{
+	start_cpu_timer(cpu);
+	return 0;
+}
+
+static int slab_offline_cpu(unsigned int cpu)
+{
+	/*
+	 * Shutdown cache reaper. Note that the slab_mutex is held so
+	 * that if cache_reap() is invoked it cannot do anything
+	 * expensive but will only modify reap_work and reschedule the
+	 * timer.
+	 */
+	cancel_delayed_work_sync(&per_cpu(slab_reap_work, cpu));
+	/* Now the cache_reaper is guaranteed to be not running. */
+	per_cpu(slab_reap_work, cpu).work.func =3D NULL;
+	return 0;
+}
=20
 #if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
 /*
@@ -1337,12 +1330,6 @@ void __init kmem_cache_init_late(void)
 	/* Done! */
 	slab_state =3D FULL;
=20
-	/*
-	 * Register a cpu startup notifier callback that initializes
-	 * cpu_cache_get for all new cpus
-	 */
-	register_cpu_notifier(&cpucache_notifier);
-
 #ifdef CONFIG_NUMA
 	/*
 	 * Register a memory hotplug callback that initializes and frees
@@ -1359,13 +1346,14 @@ void __init kmem_cache_init_late(void)
=20
 static int __init cpucache_init(void)
 {
-	int cpu;
+	int ret;
=20
 	/*
 	 * Register the timers that return unneeded pages to the page allocator
 	 */
-	for_each_online_cpu(cpu)
-		start_cpu_timer(cpu);
+	ret =3D cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "SLAB online",
+				slab_online_cpu, slab_offline_cpu);
+	WARN_ON(ret < 0);
=20
 	/* Done! */
 	slab_state =3D FULL;
--=20
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
