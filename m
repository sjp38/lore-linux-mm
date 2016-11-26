Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92BD46B0069
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 18:14:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so29392380wmu.1
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 15:14:25 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x6si48742480wjk.170.2016.11.26.15.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 26 Nov 2016 15:14:24 -0800 (PST)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 08/22] mm/vmstat: Avoid on each online CPU loops
Date: Sun, 27 Nov 2016 00:13:36 +0100
Message-Id: <20161126231350.10321-9-bigeasy@linutronix.de>
In-Reply-To: <20161126231350.10321-1-bigeasy@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, tglx@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Both iterations over online cpus can be replaced by the proper node
specific functions.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/vmstat.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0b63ffb5c407..b96dcec7e7d7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1720,19 +1720,19 @@ static void __init start_shepherd_timer(void)
=20
 static void __init init_cpu_node_state(void)
 {
-	int cpu;
+	int node;
=20
-	for_each_online_cpu(cpu)
-		node_set_state(cpu_to_node(cpu), N_CPU);
+	for_each_online_node(node)
+		node_set_state(node, N_CPU);
 }
=20
 static void vmstat_cpu_dead(int node)
 {
-	int cpu;
+	const struct cpumask *node_cpus;
=20
-	for_each_online_cpu(cpu)
-		if (cpu_to_node(cpu) =3D=3D node)
-			return;
+	node_cpus =3D cpumask_of_node(node);
+	if (cpumask_weight(node_cpus) > 0)
+		return;
=20
 	node_clear_state(node, N_CPU);
 }
--=20
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
