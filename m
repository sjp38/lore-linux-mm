Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2933F6B0260
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:52:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so44795910wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:52:26 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id uf7si59782618wjb.178.2016.11.29.06.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 06:52:25 -0800 (PST)
Date: Tue, 29 Nov 2016 15:52:21 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 09/22 v2] mm/vmstat: Convert to hotplug state machine
Message-ID: <20161129145221.ffc3kg3hd7lxiwj6@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
 <20161126231350.10321-10-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20161126231350.10321-10-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Install the callbacks via the state machine, but do not invoke them as we
can initialize the node state without calling the callbacks on all online
CPUs.

start_shepherd_timer() is now called outside the get_online_cpus() block
which is safe as it only operates on cpu possible mask.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
v1=E2=80=A6v2: rebase on top of PATCH 08/22 v2.

 include/linux/cpuhotplug.h |  1 +
 mm/vmstat.c                | 76 +++++++++++++++++++++---------------------=
----
 2 files changed, 36 insertions(+), 41 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 18bcfeb2463e..4ebd1bc27f8d 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -20,6 +20,7 @@ enum cpuhp_state {
 	CPUHP_VIRT_NET_DEAD,
 	CPUHP_SLUB_DEAD,
 	CPUHP_MM_WRITEBACK_DEAD,
+	CPUHP_MM_VMSTAT_DEAD,
 	CPUHP_SOFTIRQ_DEAD,
 	CPUHP_NET_MVNETA_DEAD,
 	CPUHP_CPUIDLE_DEAD,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5152cd1c490f..7c28df36f50f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1728,64 +1728,58 @@ static void __init init_cpu_node_state(void)
 	}
 }
=20
-static void vmstat_cpu_dead(int node)
+static int vmstat_cpu_online(unsigned int cpu)
+{
+	refresh_zone_stat_thresholds();
+	node_set_state(cpu_to_node(cpu), N_CPU);
+	return 0;
+}
+
+static int vmstat_cpu_down_prep(unsigned int cpu)
+{
+	cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
+	return 0;
+}
+
+static int vmstat_cpu_dead(unsigned int cpu)
 {
 	const struct cpumask *node_cpus;
+	int node;
=20
+	node =3D cpu_to_node(cpu);
+
+	refresh_zone_stat_thresholds();
 	node_cpus =3D cpumask_of_node(node);
 	if (cpumask_weight(node_cpus) > 0)
-		return;
+		return 0;
=20
 	node_clear_state(node, N_CPU);
+	return 0;
 }
=20
-/*
- * Use the cpu notifier to insure that the thresholds are recalculated
- * when necessary.
- */
-static int vmstat_cpuup_callback(struct notifier_block *nfb,
-		unsigned long action,
-		void *hcpu)
-{
-	long cpu =3D (long)hcpu;
-
-	switch (action) {
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		refresh_zone_stat_thresholds();
-		node_set_state(cpu_to_node(cpu), N_CPU);
-		break;
-	case CPU_DOWN_PREPARE:
-	case CPU_DOWN_PREPARE_FROZEN:
-		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
-		break;
-	case CPU_DOWN_FAILED:
-	case CPU_DOWN_FAILED_FROZEN:
-		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		refresh_zone_stat_thresholds();
-		vmstat_cpu_dead(cpu_to_node(cpu));
-		break;
-	default:
-		break;
-	}
-	return NOTIFY_OK;
-}
-
-static struct notifier_block vmstat_notifier =3D
-	{ &vmstat_cpuup_callback, NULL, 0 };
 #endif
=20
 static int __init setup_vmstat(void)
 {
 #ifdef CONFIG_SMP
-	cpu_notifier_register_begin();
-	__register_cpu_notifier(&vmstat_notifier);
+	int ret;
+
+	ret =3D cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
+					NULL, vmstat_cpu_dead);
+	if (ret < 0)
+		pr_err("vmstat: failed to register 'dead' hotplug state\n");
+
+	ret =3D cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN, "mm/vmstat:online",
+					vmstat_cpu_online,
+					vmstat_cpu_down_prep);
+	if (ret < 0)
+		pr_err("vmstat: failed to register 'online' hotplug state\n");
+
+	get_online_cpus();
 	init_cpu_node_state();
+	put_online_cpus();
=20
 	start_shepherd_timer();
-	cpu_notifier_register_done();
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
--=20
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
