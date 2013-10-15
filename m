Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id DE99E6B0036
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:17:09 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so9202649pdj.29
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:17:09 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 2/2] mm: Clear N_CPU from node_states at CPU offline
Date: Tue, 15 Oct 2013 11:12:56 -0600
Message-Id: <1381857176-22999-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1381857176-22999-1-git-send-email-toshi.kani@hp.com>
References: <1381857176-22999-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, Toshi Kani <toshi.kani@hp.com>

vmstat_cpuup_callback() is a CPU notifier callback, which
marks N_CPU to a node at CPU online event.  However, it
does not update this N_CPU info at CPU offline event.

Changed vmstat_cpuup_callback() to clear N_CPU when the last
CPU in the node is put into offline, i.e. the node no longer
has any online CPU.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/vmstat.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0a1f7de..b6d17ed 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1229,6 +1229,20 @@ static void start_cpu_timer(int cpu)
 	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
 }
 
+static void vmstat_cpu_dead(int node)
+{
+	int cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu)
+		if (cpu_to_node(cpu) == node)
+			goto end;
+
+	node_clear_state(node, N_CPU);
+end:
+	put_online_cpus();
+}
+
 /*
  * Use the cpu notifier to insure that the thresholds are recalculated
  * when necessary.
@@ -1258,6 +1272,7 @@ static int vmstat_cpuup_callback(struct notifier_block *nfb,
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
 		refresh_zone_stat_thresholds();
+		vmstat_cpu_dead(cpu_to_node(cpu));
 		break;
 	default:
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
