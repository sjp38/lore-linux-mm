Message-Id: <20080113183454.815670000@sgi.com>
References: <20080113183453.973425000@sgi.com>
Date: Sun, 13 Jan 2008 10:34:59 -0800
From: travis@sgi.com
Subject: [PATCH 06/10] x86: Change NR_CPUS arrays in topology
Content-Disposition: inline; filename=NR_CPUS-arrays-in-topology
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the following static arrays sized by NR_CPUS to
per_cpu data variables:

	i386_cpu cpu_devices[NR_CPUS];

(And change the struct name to x86_cpu.)

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
 arch/x86/kernel/topology.c |    8 ++++----
 include/asm-x86/cpu.h      |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

--- a/arch/x86/kernel/topology.c
+++ b/arch/x86/kernel/topology.c
@@ -31,7 +31,7 @@
 #include <linux/mmzone.h>
 #include <asm/cpu.h>
 
-static struct i386_cpu cpu_devices[NR_CPUS];
+static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
 
 int __cpuinit arch_register_cpu(int num)
 {
@@ -46,16 +46,16 @@ int __cpuinit arch_register_cpu(int num)
 	 */
 #ifdef CONFIG_HOTPLUG_CPU
 	if (num)
-		cpu_devices[num].cpu.hotpluggable = 1;
+		per_cpu(cpu_devices, num).cpu.hotpluggable = 1;
 #endif
 
-	return register_cpu(&cpu_devices[num].cpu, num);
+	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
 void arch_unregister_cpu(int num)
 {
-	return unregister_cpu(&cpu_devices[num].cpu);
+	return unregister_cpu(&per_cpu(cpu_devices, num).cpu);
 }
 EXPORT_SYMBOL(arch_register_cpu);
 EXPORT_SYMBOL(arch_unregister_cpu);
--- a/include/asm-x86/cpu.h
+++ b/include/asm-x86/cpu.h
@@ -7,7 +7,7 @@
 #include <linux/nodemask.h>
 #include <linux/percpu.h>
 
-struct i386_cpu {
+struct x86_cpu {
 	struct cpu cpu;
 };
 extern int arch_register_cpu(int num);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
