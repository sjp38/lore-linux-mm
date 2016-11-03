From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 03/25] mm/memcg: Convert to hotplug state machine
Date: Thu,  3 Nov 2016 15:49:59 +0100
Message-ID: <20161103145021.28528-4-bigeasy@linutronix.de>
References: <20161103145021.28528-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161103145021.28528-1-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>
List-Id: linux-mm.kvack.org

Install the callbacks via the state machine.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 mm/memcontrol.c            | 24 ++++++++----------------
 2 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 4174083280d7..c622ab349af3 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -32,6 +32,7 @@ enum cpuhp_state {
 	CPUHP_BLK_MQ_DEAD,
 	CPUHP_FS_BUFF_DEAD,
 	CPUHP_PRINTK_DEAD,
+	CPUHP_MM_MEMCQ_DEAD,
 	CPUHP_WORKQUEUE_PREP,
 	CPUHP_POWER_NUMA_PREPARE,
 	CPUHP_HRTIMERS_PREPARE,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0f870ba43942..6c2043509fb5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1816,22 +1816,13 @@ static void drain_all_stock(struct mem_cgroup *root=
_memcg)
 	mutex_unlock(&percpu_charge_mutex);
 }
=20
-static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
-					unsigned long action,
-					void *hcpu)
+static int memcg_hotplug_cpu_dead(unsigned int cpu)
 {
-	int cpu =3D (unsigned long)hcpu;
 	struct memcg_stock_pcp *stock;
=20
-	if (action =3D=3D CPU_ONLINE)
-		return NOTIFY_OK;
-
-	if (action !=3D CPU_DEAD && action !=3D CPU_DEAD_FROZEN)
-		return NOTIFY_OK;
-
 	stock =3D &per_cpu(memcg_stock, cpu);
 	drain_stock(stock);
-	return NOTIFY_OK;
+	return 0;
 }
=20
 static void reclaim_high(struct mem_cgroup *memcg,
@@ -5774,16 +5765,17 @@ __setup("cgroup.memory=3D", cgroup_memory);
 /*
  * subsys_initcall() for memory controller.
  *
- * Some parts like hotcpu_notifier() have to be initialized from this cont=
ext
- * because of lock dependencies (cgroup_lock -> cpu hotplug) but basically
- * everything that doesn't depend on a specific mem_cgroup structure should
- * be initialized from here.
+ * Some parts like memcg_hotplug_cpu_dead() have to be initialized from th=
is
+ * context because of lock dependencies (cgroup_lock -> cpu hotplug) but
+ * basically everything that doesn't depend on a specific mem_cgroup struc=
ture
+ * should be initialized from here.
  */
 static int __init mem_cgroup_init(void)
 {
 	int cpu, node;
=20
-	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
+	cpuhp_setup_state_nocalls(CPUHP_MM_MEMCQ_DEAD, "mm/memctrl:dead", NULL,
+				  memcg_hotplug_cpu_dead);
=20
 	for_each_possible_cpu(cpu)
 		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,
--=20
2.10.2
