Message-Id: <20080325021956.077543000@polaris-admin.engr.sgi.com>
References: <20080325021954.979158000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:20:01 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 07/10] cpu: change cpu_sys_devices from array to per_cpu variable
Content-Disposition: inline; filename=nr_cpus-in-cpu_c
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change cpu_sys_devices from array to per_cpu variable in
drivers/base/cpu.c.

Based on linux-2.6.25-rc5-mm1

(MAINTAINER unknown)
Signed-off-by: Mike Travis <travis@sgi.com>
---
 drivers/base/cpu.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- linux-2.6.25-rc5.orig/drivers/base/cpu.c
+++ linux-2.6.25-rc5/drivers/base/cpu.c
@@ -18,7 +18,7 @@ struct sysdev_class cpu_sysdev_class = {
 };
 EXPORT_SYMBOL(cpu_sysdev_class);
 
-static struct sys_device *cpu_sys_devices[NR_CPUS];
+static DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
 
 #ifdef CONFIG_HOTPLUG_CPU
 static ssize_t show_online(struct sys_device *dev, char *buf)
@@ -68,7 +68,7 @@ void unregister_cpu(struct cpu *cpu)
 	sysdev_remove_file(&cpu->sysdev, &attr_online);
 
 	sysdev_unregister(&cpu->sysdev);
-	cpu_sys_devices[logical_cpu] = NULL;
+	per_cpu(cpu_sys_devices, logical_cpu) = NULL;
 	return;
 }
 #else /* ... !CONFIG_HOTPLUG_CPU */
@@ -122,7 +122,7 @@ int __cpuinit register_cpu(struct cpu *c
 	if (!error && cpu->hotpluggable)
 		register_cpu_control(cpu);
 	if (!error)
-		cpu_sys_devices[num] = &cpu->sysdev;
+		per_cpu(cpu_sys_devices, num) = &cpu->sysdev;
 	if (!error)
 		register_cpu_under_node(num, cpu_to_node(num));
 
@@ -135,8 +135,8 @@ int __cpuinit register_cpu(struct cpu *c
 
 struct sys_device *get_cpu_sysdev(unsigned cpu)
 {
-	if (cpu < NR_CPUS)
-		return cpu_sys_devices[cpu];
+	if (cpu < nr_cpu_ids && cpu_possible(cpu))
+		return per_cpu(cpu_sys_devices, cpu);
 	else
 		return NULL;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
