From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 06/25] mm/page_alloc: Convert to hotplug state machine
Date: Thu,  3 Nov 2016 15:50:02 +0100
Message-ID: <20161103145021.28528-7-bigeasy@linutronix.de>
References: <20161103145021.28528-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161103145021.28528-1-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>
List-Id: linux-mm.kvack.org

Install the callbacks via the state machine.

Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 mm/page_alloc.c            | 49 +++++++++++++++++++++++-------------------=
----
 2 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 89310fb1031d..31c58f6ec3c6 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -35,6 +35,7 @@ enum cpuhp_state {
 	CPUHP_MM_MEMCQ_DEAD,
 	CPUHP_PERCPU_CNT_DEAD,
 	CPUHP_RADIX_DEAD,
+	CPUHP_PAGE_ALLOC_DEAD,
 	CPUHP_WORKQUEUE_PREP,
 	CPUHP_POWER_NUMA_PREPARE,
 	CPUHP_HRTIMERS_PREPARE,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fd42aa7c4bd..68873a164cc0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6491,38 +6491,39 @@ void __init free_area_init(unsigned long *zones_siz=
e)
 			__pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
 }
=20
-static int page_alloc_cpu_notify(struct notifier_block *self,
-				 unsigned long action, void *hcpu)
+static int page_alloc_cpu_dead(unsigned int cpu)
 {
-	int cpu =3D (unsigned long)hcpu;
=20
-	if (action =3D=3D CPU_DEAD || action =3D=3D CPU_DEAD_FROZEN) {
-		lru_add_drain_cpu(cpu);
-		drain_pages(cpu);
+	lru_add_drain_cpu(cpu);
+	drain_pages(cpu);
=20
-		/*
-		 * Spill the event counters of the dead processor
-		 * into the current processors event counters.
-		 * This artificially elevates the count of the current
-		 * processor.
-		 */
-		vm_events_fold_cpu(cpu);
+	/*
+	 * Spill the event counters of the dead processor
+	 * into the current processors event counters.
+	 * This artificially elevates the count of the current
+	 * processor.
+	 */
+	vm_events_fold_cpu(cpu);
=20
-		/*
-		 * Zero the differential counters of the dead processor
-		 * so that the vm statistics are consistent.
-		 *
-		 * This is only okay since the processor is dead and cannot
-		 * race with what we are doing.
-		 */
-		cpu_vm_stats_fold(cpu);
-	}
-	return NOTIFY_OK;
+	/*
+	 * Zero the differential counters of the dead processor
+	 * so that the vm statistics are consistent.
+	 *
+	 * This is only okay since the processor is dead and cannot
+	 * race with what we are doing.
+	 */
+	cpu_vm_stats_fold(cpu);
+	return 0;
 }
=20
 void __init page_alloc_init(void)
 {
-	hotcpu_notifier(page_alloc_cpu_notify, 0);
+	int ret;
+
+	ret =3D cpuhp_setup_state_nocalls(CPUHP_PAGE_ALLOC_DEAD,
+					"mm/page_alloc:dead", NULL,
+					page_alloc_cpu_dead);
+	WARN_ON(ret < 0);
 }
=20
 /*
--=20
2.10.2
