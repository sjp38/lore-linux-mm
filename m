Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 39CB86B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 05:14:04 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PATCH 3/5] cpu-hotplug, memory-hotplug: try offline the node when hotremoving a cpu
Date: Mon, 26 Nov 2012 18:20:25 +0800
Message-Id: <1353925227-1877-4-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
References: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-acpi@vger.kernel.org, x86@kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <len.brown@intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

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
---
 drivers/acpi/processor_driver.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index a4352b8..7fc728c7 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -44,6 +44,7 @@
 #include <linux/moduleparam.h>
 #include <linux/cpuidle.h>
 #include <linux/slab.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/io.h>
 #include <asm/cpu.h>
@@ -634,6 +635,7 @@ static int acpi_processor_remove(struct acpi_device *device, int type)
 
 	per_cpu(processors, pr->id) = NULL;
 	per_cpu(processor_device_array, pr->id) = NULL;
+	try_offline_node(cpu_to_node(pr->id));
 
 free:
 	free_cpumask_var(pr->throttling.shared_cpu_map);
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
