From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 07/25] mm/vmscan: Convert to hotplug state machine
Date: Thu,  3 Nov 2016 15:50:03 +0100
Message-ID: <20161103145021.28528-8-bigeasy@linutronix.de>
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
 mm/vmscan.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 76fda2268148..b8404d32caf0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3556,24 +3556,21 @@ unsigned long shrink_all_memory(unsigned long nr_to=
_reclaim)
    not required for correctness.  So if the last cpu in a node goes
    away, we get changed to run anywhere: as the first one comes back,
    restore their cpu bindings. */
-static int cpu_callback(struct notifier_block *nfb, unsigned long action,
-			void *hcpu)
+static int kswapd_cpu_online(unsigned int cpu)
 {
 	int nid;
=20
-	if (action =3D=3D CPU_ONLINE || action =3D=3D CPU_ONLINE_FROZEN) {
-		for_each_node_state(nid, N_MEMORY) {
-			pg_data_t *pgdat =3D NODE_DATA(nid);
-			const struct cpumask *mask;
+	for_each_node_state(nid, N_MEMORY) {
+		pg_data_t *pgdat =3D NODE_DATA(nid);
+		const struct cpumask *mask;
=20
-			mask =3D cpumask_of_node(pgdat->node_id);
+		mask =3D cpumask_of_node(pgdat->node_id);
=20
-			if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
-				/* One of our CPUs online: restore mask */
-				set_cpus_allowed_ptr(pgdat->kswapd, mask);
-		}
+		if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
+			/* One of our CPUs online: restore mask */
+			set_cpus_allowed_ptr(pgdat->kswapd, mask);
 	}
-	return NOTIFY_OK;
+	return 0;
 }
=20
 /*
@@ -3615,12 +3612,15 @@ void kswapd_stop(int nid)
=20
 static int __init kswapd_init(void)
 {
-	int nid;
+	int nid, ret;
=20
 	swap_setup();
 	for_each_node_state(nid, N_MEMORY)
  		kswapd_run(nid);
-	hotcpu_notifier(cpu_callback, 0);
+	ret =3D cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN,
+					"mm/vmscan:online", kswapd_cpu_online,
+					NULL);
+	WARN_ON(ret < 0);
 	return 0;
 }
=20
--=20
2.10.2
