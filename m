Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1640C8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:22:07 -0400 (EDT)
From: "Zhang, Yang Z" <yang.z.zhang@intel.com>
Date: Thu, 31 Mar 2011 22:21:44 +0800
Subject: [PATCH 4/7,v10] NUMA Hotplug Emulator: Abstract cpu register
 functions
Message-ID: <749B9D3DBF0F054390025D9EAFF47F224A3D6C3E@shsmsx501.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "Kleen, Andi" <andi.kleen@intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "mingo@elte.hu" <mingo@elte.hu>, "lenb@kernel.org" <lenb@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "Li, Xin" <xin.li@intel.com>

From: Shaohui Zheng <shaohui.zheng@intel.com>

Abstract cpu register functions, provide a more flexible interface
register_cpu_node, the new interface provides convenience to add cpu
to a specified node, we can use it to add a cpu to a fake node.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Yang Zhang <yang.z.zhang@Intel.com>
---
 arch/x86/include/asm/cpu.h |    1 +
 arch/x86/kernel/topology.c |    9 +++++++++
 drivers/base/cpu.c         |    9 +++++----
 include/linux/cpu.h        |    8 +++++++-
 4 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/cpu.h linux-hpe4/arch/x86/include/asm/cpu=
.h
index 4564c8e..cbb062f 100644
--- a/arch/x86/include/asm/cpu.h
+++ linux-hpe4/arch/x86/include/asm/cpu.h
@@ -27,6 +27,7 @@ struct x86_cpu {

 #ifdef CONFIG_HOTPLUG_CPU
 extern int arch_register_cpu(int num);
+extern int arch_register_cpu_node(int num, int nid);
 extern void arch_unregister_cpu(int);
 #endif

diff --git a/arch/x86/kernel/topology.c linux-hpe4/arch/x86/kernel/topology=
.c
index 7e45159..1e53227 100644
--- a/arch/x86/kernel/topology.c
+++ linux-hpe4/arch/x86/kernel/topology.c
@@ -52,6 +52,15 @@ int __ref arch_register_cpu(int num)
 }
 EXPORT_SYMBOL(arch_register_cpu);

+int __ref arch_register_cpu_node(int num, int nid)
+{
+       if (num)
+               per_cpu(cpu_devices, num).cpu.hotpluggable =3D 1;
+
+       return register_cpu_node(&per_cpu(cpu_devices, num).cpu, num, nid);
+}
+EXPORT_SYMBOL(arch_register_cpu_node);
+
 void arch_unregister_cpu(int num)
 {
        unregister_cpu(&per_cpu(cpu_devices, num).cpu);
diff --git a/drivers/base/cpu.c linux-hpe4/drivers/base/cpu.c
index 251acea..6b791ae 100644
--- a/drivers/base/cpu.c
+++ linux-hpe4/drivers/base/cpu.c
@@ -208,17 +208,18 @@ static ssize_t print_cpus_offline(struct sysdev_class=
 *class,
 static SYSDEV_CLASS_ATTR(offline, 0444, print_cpus_offline, NULL);

 /*
- * register_cpu - Setup a sysfs device for a CPU.
+ * register_cpu_node - Setup a sysfs device for a CPU.
  * @cpu - cpu->hotpluggable field set to 1 will generate a control file in
  *       sysfs for this CPU.
  * @num - CPU number to use when creating the device.
+ * @nid - Node ID to use, if any.
  *
  * Initialize and register the CPU device.
  */
-int __cpuinit register_cpu(struct cpu *cpu, int num)
+int __cpuinit register_cpu_node(struct cpu *cpu, int num, int nid)
 {
        int error;
-       cpu->node_id =3D cpu_to_node(num);
+       cpu->node_id =3D nid;
        cpu->sysdev.id =3D num;
        cpu->sysdev.cls =3D &cpu_sysdev_class;

@@ -229,7 +230,7 @@ int __cpuinit register_cpu(struct cpu *cpu, int num)
        if (!error)
                per_cpu(cpu_sys_devices, num) =3D &cpu->sysdev;
        if (!error)
-               register_cpu_under_node(num, cpu_to_node(num));
+               register_cpu_under_node(num, nid);

 #ifdef CONFIG_KEXEC
        if (!error)
diff --git a/include/linux/cpu.h linux-hpe4/include/linux/cpu.h
index 5f09323..014856d 100644
--- a/include/linux/cpu.h
+++ linux-hpe4/include/linux/cpu.h
@@ -25,7 +25,13 @@ struct cpu {
        struct sys_device sysdev;
 };

-extern int register_cpu(struct cpu *cpu, int num);
+extern int register_cpu_node(struct cpu *cpu, int num, int nid);
+
+static inline int register_cpu(struct cpu *cpu, int num)
+{
+       return register_cpu_node(cpu, num, cpu_to_node(num));
+}
+
 extern struct sys_device *get_cpu_sysdev(unsigned cpu);

 extern int cpu_add_sysdev_attr(struct sysdev_attribute *attr);
--
1.7.1.1
--
best regards
yang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
