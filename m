Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 446966B0268
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 18:14:39 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a20so29428226wme.5
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 15:14:39 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id ww1si48804640wjb.147.2016.11.26.15.14.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 26 Nov 2016 15:14:38 -0800 (PST)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 14/22] mm/compaction: Convert to hotplug state machine
Date: Sun, 27 Nov 2016 00:13:42 +0100
Message-Id: <20161126231350.10321-15-bigeasy@linutronix.de>
In-Reply-To: <20161126231350.10321-1-bigeasy@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, tglx@linutronix.de, Anna-Maria Gleixner <anna-maria@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

Install the callbacks via the state machine. Should the hotplug init fail t=
hen
no threads are spawned.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/compaction.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0409a4ad6ea1..0d37192d9423 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2043,33 +2043,38 @@ void kcompactd_stop(int nid)
  * away, we get changed to run anywhere: as the first one comes back,
  * restore their cpu bindings.
  */
-static int cpu_callback(struct notifier_block *nfb, unsigned long action,
-			void *hcpu)
+static int kcompactd_cpu_online(unsigned int cpu)
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
-				set_cpus_allowed_ptr(pgdat->kcompactd, mask);
-		}
+		if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
+			/* One of our CPUs online: restore mask */
+			set_cpus_allowed_ptr(pgdat->kcompactd, mask);
 	}
-	return NOTIFY_OK;
+	return 0;
 }
=20
 static int __init kcompactd_init(void)
 {
 	int nid;
+	int ret;
+
+	ret =3D cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN,
+					"mm/compaction:online",
+					kcompactd_cpu_online, NULL);
+	if (ret < 0) {
+		pr_err("kcompactd: failed to register hotplug callbacks.\n");
+		return ret;
+	}
=20
 	for_each_node_state(nid, N_MEMORY)
 		kcompactd_run(nid);
-	hotcpu_notifier(cpu_callback, 0);
 	return 0;
 }
 subsys_initcall(kcompactd_init)
--=20
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
