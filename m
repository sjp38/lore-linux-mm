Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 600D46B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:51:25 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id jb2so27025699wjb.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:51:25 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id hn4si55127400wjb.133.2016.11.29.06.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 06:51:24 -0800 (PST)
Date: Tue, 29 Nov 2016 15:51:14 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 08/22 v2] mm/vmstat: Avoid on each online CPU loops
Message-ID: <20161129145113.fn3lw5aazjjvdrr3@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
 <20161126231350.10321-9-bigeasy@linutronix.de>
 <20161128092800.GC14835@dhcp22.suse.cz>
 <alpine.DEB.2.20.1611291505340.4358@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <alpine.DEB.2.20.1611291505340.4358@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, rt@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Both iterations over online cpus can be replaced by the proper node
specific functions.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1=E2=80=A6v2: take into account that we may have online nodes with no CPUs.

 mm/vmstat.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0b63ffb5c407..5152cd1c490f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1720,19 +1720,21 @@ static void __init start_shepherd_timer(void)
=20
 static void __init init_cpu_node_state(void)
 {
-	int cpu;
+	int node;
=20
-	for_each_online_cpu(cpu)
-		node_set_state(cpu_to_node(cpu), N_CPU);
+	for_each_online_node(node) {
+		if (cpumask_weight(cpumask_of_node(node)) > 0)
+			node_set_state(node, N_CPU);
+	}
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
