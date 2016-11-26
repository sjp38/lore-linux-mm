Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E37796B0069
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 18:14:25 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id bk3so14645206wjc.4
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 15:14:25 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id sw3si48706579wjb.110.2016.11.26.15.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 26 Nov 2016 15:14:24 -0800 (PST)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 07/22] mm/vmstat: Drop get_online_cpus() from init_cpu_node_state/vmstat_cpu_dead()
Date: Sun, 27 Nov 2016 00:13:35 +0100
Message-Id: <20161126231350.10321-8-bigeasy@linutronix.de>
In-Reply-To: <20161126231350.10321-1-bigeasy@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, tglx@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Both functions are called with protection against cpu hotplug already so
*_online_cpus() could be dropped.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/vmstat.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 604f26a4f696..0b63ffb5c407 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1722,24 +1722,19 @@ static void __init init_cpu_node_state(void)
 {
 	int cpu;
=20
-	get_online_cpus();
 	for_each_online_cpu(cpu)
 		node_set_state(cpu_to_node(cpu), N_CPU);
-	put_online_cpus();
 }
=20
 static void vmstat_cpu_dead(int node)
 {
 	int cpu;
=20
-	get_online_cpus();
 	for_each_online_cpu(cpu)
 		if (cpu_to_node(cpu) =3D=3D node)
-			goto end;
+			return;
=20
 	node_clear_state(node, N_CPU);
-end:
-	put_online_cpus();
 }
=20
 /*
--=20
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
