Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 94BF66B0036
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:17:06 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so9195703pde.37
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:17:06 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 1/2] mm: Set N_CPU to node_states during boot
Date: Tue, 15 Oct 2013 11:12:55 -0600
Message-Id: <1381857176-22999-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1381857176-22999-1-git-send-email-toshi.kani@hp.com>
References: <1381857176-22999-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, Toshi Kani <toshi.kani@hp.com>

After a system booted, N_CPU is not set to any node as
has_cpu shows an empty line.

  # cat /sys/devices/system/node/has_cpu
  (show-empty-line)

setup_vmstat() registers its CPU notifier callback,
vmstat_cpuup_callback(), which marks N_CPU to a node when
a CPU is put into online.  However, setup_vmstat() is
called after all CPUs are launched in the boot sequence.

Changed setup_vmstat() to mark N_CPU to the nodes with
online CPUs at boot, which is consistent with other
operations in vmstat_cpuup_callback(), i.e. start_cpu_timer()
and refresh_zone_stat_thresholds().

Also added get_online_cpus() to protect the
for_each_online_cpu() loop.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/vmstat.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9bb3145..0a1f7de 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1276,8 +1276,12 @@ static int __init setup_vmstat(void)
 
 	register_cpu_notifier(&vmstat_notifier);
 
-	for_each_online_cpu(cpu)
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
 		start_cpu_timer(cpu);
+		node_set_state(cpu_to_node(cpu), N_CPU);
+	}
+	put_online_cpus();
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
