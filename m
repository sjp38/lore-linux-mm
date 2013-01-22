Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id A699F6B000C
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:46:50 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 3/5] cpu-hotplug, memory-hotplug: try offline the node when hotremoving a cpu
Date: Tue, 22 Jan 2013 19:45:54 +0800
Message-Id: <1358855156-6126-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358855156-6126-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358855156-6126-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rjw@sisk.pl, len.brown@intel.com, mingo@redhat.com, tglx@linutronix.de, minchan.kim@gmail.com, rientjes@google.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, Jiang Liu <liuj97@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Peter Zijlstra <peterz@infradead.org>

From: Wen Congyang <wency@cn.fujitsu.com>

The node will be offlined when all memory/cpu on the node is hotremoved.
So we should try offline the node when hotremoving a cpu on the node.

Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/acpi/processor_driver.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index a24ee43..81745f1 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -45,6 +45,7 @@
 #include <linux/cpuidle.h>
 #include <linux/slab.h>
 #include <linux/acpi.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/io.h>
 #include <asm/cpu.h>
@@ -641,6 +642,7 @@ static int acpi_processor_remove(struct acpi_device *device, int type)
 
 	per_cpu(processors, pr->id) = NULL;
 	per_cpu(processor_device_array, pr->id) = NULL;
+	try_offline_node(cpu_to_node(pr->id));
 
 free:
 	free_cpumask_var(pr->throttling.shared_cpu_map);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
