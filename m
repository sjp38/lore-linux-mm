Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 614C66B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 16:08:51 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so7712005pbb.20
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 13:08:50 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] mm: Set N_CPU to node_states during boot
Date: Mon, 14 Oct 2013 14:04:56 -0600
Message-Id: <1381781096-13168-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

After a system booted, N_CPU is not set to any node as has_cpu
shows an empty line.

  # cat /sys/devices/system/node/has_cpu
  (show-empty-line)

setup_vmstat() registers its CPU notifier callback,
vmstat_cpuup_callback(), which marks N_CPU to a node when
a CPU is put into online.  However, setup_vmstat() is called
after all CPUs are launched in the boot sequence.

Change setup_vmstat() to mark N_CPU to the nodes with online
CPUs at boot.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/vmstat.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9bb3145..c464a22 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1276,8 +1276,10 @@ static int __init setup_vmstat(void)
 
 	register_cpu_notifier(&vmstat_notifier);
 
-	for_each_online_cpu(cpu)
+	for_each_online_cpu(cpu) {
 		start_cpu_timer(cpu);
+		node_set_state(cpu_to_node(cpu), N_CPU);
+	}
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
