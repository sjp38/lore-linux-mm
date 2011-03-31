Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 910268D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:24:02 -0400 (EDT)
From: "Zhang, Yang Z" <yang.z.zhang@intel.com>
Date: Thu, 31 Mar 2011 22:23:17 +0800
Subject: [PATCH 5/7,v10] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-ID: <749B9D3DBF0F054390025D9EAFF47F224A3D6C41@shsmsx501.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "Kleen, Andi" <andi.kleen@intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "mingo@elte.hu" <mingo@elte.hu>, "lenb@kernel.org" <lenb@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "Li, Xin" <xin.li@intel.com>

CPU physical hot-add/hot-remove are supported on some hardwares, and it
was already supported in current linux kernel. NUMA Hotplug Emulator provid=
es
a mechanism to emulate the process with software method. It can be used for
testing or debuging purpose.

CPU physical hotplug is different with logical CPU online/offline. Logical
online/offline is controled by interface /sys/device/cpu/cpuX/online. CPU
hotplug emulator uses probe/release interface. It becomes possible to do cp=
u
hotplug automation and stress

Add cpu interface probe/release under sysfs for x86_64. User can use this
interface to emulate the cpu hot-add and hot-remove process.

Directive:
*) Reserve CPU thru grub parameter like:
        maxcpus=3D4

the rest CPUs will not be initiliazed.

*) Probe CPU
we can use the probe interface to hot-add new CPUs:
        echo nid > /sys/devices/system/cpu/probe

*) Release a CPU
        echo cpu > /sys/devices/system/cpu/release

A reserved CPU will be hot-added to the specified node.
1) nid =3D=3D 0, the CPU will be added to the real node which the CPU
should be in
2) nid !=3D 0, add the CPU to node nid even through it is a fake node.

CC: Ingo Molnar <mingo@elte.hu>
CC: Len Brown <len.brown@intel.com>
CC: Yinghai Lu <Yinghai.Lu@Sun.COM>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Yang Zhang <yang.z.zhang@intel.com>
---
 Documentation/x86/x86_64/boot-options.txt |    5 ++
 arch/x86/kernel/acpi/boot.c               |   31 +++++++++++
 arch/x86/kernel/smpboot.c                 |    2 -
 arch/x86/kernel/topology.c                |   81 +++++++++++++++++++++++++=
+++-
 arch/x86/mm/numa_64.c                     |   15 +++++
 drivers/acpi/processor_driver.c           |    9 +++
 drivers/base/cpu.c                        |    8 +++-
 include/linux/acpi.h                      |    1 +
 include/linux/cpu.h                       |    4 ++
 9 files changed, 151 insertions(+), 5 deletions(-)

diff --git a/Documentation/x86/x86_64/boot-options.txt linux-hpe4/Documenta=
tion/x86/x86_64/boot-options.txt
index d8d5bf9..82fb04d 100644
--- a/Documentation/x86/x86_64/boot-options.txt
+++ linux-hpe4/Documentation/x86/x86_64/boot-options.txt
@@ -311,3 +311,8 @@ Miscellaneous
                Do not use GB pages for kernel direct mappings.
        gbpages
                Use GB pages for kernel direct mappings.
+       cpu_hpe=3Don/off
+               Enable/disable CPU hotplug emulation with software method. =
When cpu_hpe=3Don,
+               sysfs provides probe/release interface to hot add/remove CP=
Us dynamically.
+               We can use maxcpus=3D<N> to reserve CPUs.
+               This option is disabled by default.
diff --git a/arch/x86/kernel/acpi/boot.c linux-hpe4/arch/x86/kernel/acpi/bo=
ot.c
index 9a966c5..cd3a896 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ linux-hpe4/arch/x86/kernel/acpi/boot.c
@@ -680,8 +680,39 @@ int __ref acpi_map_lsapic(acpi_handle handle, int *pcp=
u)
 }
 EXPORT_SYMBOL(acpi_map_lsapic);

+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+static void acpi_map_cpu2node_emu(int cpu, int physid, int nid)
+{
+#ifdef CONFIG_ACPI_NUMA
+       set_apicid_to_node(physid, nid);
+       numa_set_node(cpu, nid);
+#endif
+}
+
+static u16 cpu_to_apicid_saved[CONFIG_NR_CPUS];
+int __ref acpi_map_lsapic_emu(int pcpu, int nid)
+{
+       /* backup cpu apicid to array cpu_to_apicid_saved */
+       if (cpu_to_apicid_saved[pcpu] =3D=3D 0 &&
+               per_cpu(x86_cpu_to_apicid, pcpu) !=3D BAD_APICID)
+               cpu_to_apicid_saved[pcpu] =3D per_cpu(x86_cpu_to_apicid, pc=
pu);
+
+       per_cpu(x86_cpu_to_apicid, pcpu) =3D cpu_to_apicid_saved[pcpu];
+       acpi_map_cpu2node_emu(pcpu, per_cpu(x86_cpu_to_apicid, pcpu), nid);
+
+       return pcpu;
+}
+EXPORT_SYMBOL(acpi_map_lsapic_emu);
+#endif
+
 int acpi_unmap_lsapic(int cpu)
 {
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+       /* backup cpu apicid to array cpu_to_apicid_saved */
+       if (cpu_to_apicid_saved[cpu] =3D=3D 0 &&
+               per_cpu(x86_cpu_to_apicid, cpu) !=3D BAD_APICID)
+               cpu_to_apicid_saved[cpu] =3D per_cpu(x86_cpu_to_apicid, cpu=
);
+#endif
        per_cpu(x86_cpu_to_apicid, cpu) =3D -1;
        set_cpu_present(cpu, false);
        num_processors--;
diff --git a/arch/x86/kernel/smpboot.c linux-hpe4/arch/x86/kernel/smpboot.c
index c2871d3..f98122e 100644
--- a/arch/x86/kernel/smpboot.c
+++ linux-hpe4/arch/x86/kernel/smpboot.c
@@ -104,8 +104,6 @@ void cpu_hotplug_driver_unlock(void)
         mutex_unlock(&x86_cpu_hotplug_driver_mutex);
 }

-ssize_t arch_cpu_probe(const char *buf, size_t count) { return -1; }
-ssize_t arch_cpu_release(const char *buf, size_t count) { return -1; }
 #else
 static struct task_struct *idle_thread_array[NR_CPUS] __cpuinitdata ;
 #define get_idle_for_cpu(x)      (idle_thread_array[(x)])
diff --git a/arch/x86/kernel/topology.c linux-hpe4/arch/x86/kernel/topology=
.c
index 1e53227..ab62c94 100644
--- a/arch/x86/kernel/topology.c
+++ linux-hpe4/arch/x86/kernel/topology.c
@@ -30,6 +30,9 @@
 #include <linux/init.h>
 #include <linux/smp.h>
 #include <asm/cpu.h>
+#include <linux/cpu.h>
+#include <linux/topology.h>
+#include <linux/acpi.h>

 static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);

@@ -66,6 +69,74 @@ void arch_unregister_cpu(int num)
        unregister_cpu(&per_cpu(cpu_devices, num).cpu);
 }
 EXPORT_SYMBOL(arch_unregister_cpu);
+
+ssize_t arch_cpu_probe(const char *buf, size_t count)
+{
+       int nid =3D 0;
+       int num =3D 0, selected =3D 0;
+
+       /* check parameters */
+       if (!buf || count < 2)
+               return -EPERM;
+
+       nid =3D simple_strtoul(buf, NULL, 0);
+       printk(KERN_DEBUG "Add a cpu to node : %d\n", nid);
+
+       if (nid < 0 || nid > nr_node_ids - 1) {
+               printk(KERN_ERR "Invalid NUMA node id: %d (0 <=3D nid < %d)=
.\n",
+                       nid, nr_node_ids);
+               return -EPERM;
+       }
+
+       if (!node_online(nid)) {
+               printk(KERN_ERR "NUMA node %d is not online, give up.\n", n=
id);
+               return -EPERM;
+       }
+
+       /* find first uninitialized cpu */
+       for_each_present_cpu(num) {
+               if (per_cpu(cpu_sys_devices, num) =3D=3D NULL) {
+                       selected =3D num;
+                       break;
+               }
+       }
+
+       if (selected >=3D num_possible_cpus()) {
+               printk(KERN_ERR "No free cpu, give up cpu probing.\n");
+               return -EPERM;
+       }
+
+       /* register cpu */
+       arch_register_cpu_node(selected, nid);
+       acpi_map_lsapic_emu(selected, nid);
+
+       return count;
+}
+EXPORT_SYMBOL(arch_cpu_probe);
+
+ssize_t arch_cpu_release(const char *buf, size_t count)
+{
+       int cpu =3D 0;
+
+       cpu =3D  simple_strtoul(buf, NULL, 0);
+       /* cpu 0 is not hotplugable */
+       if (cpu =3D=3D 0) {
+               printk(KERN_ERR "can not release cpu 0.\n");
+               return -EPERM;
+       }
+
+       if (cpu_online(cpu)) {
+               printk(KERN_DEBUG "offline cpu %d.\n", cpu);
+               cpu_down(cpu);
+       }
+
+       arch_unregister_cpu(cpu);
+       acpi_unmap_lsapic(cpu);
+
+       return count;
+}
+EXPORT_SYMBOL(arch_cpu_release);
+
 #else /* CONFIG_HOTPLUG_CPU */

 static int __init arch_register_cpu(int num)
@@ -83,8 +154,14 @@ static int __init topology_init(void)
                register_one_node(i);
 #endif

-       for_each_present_cpu(i)
-               arch_register_cpu(i);
+       /*
+        * when cpu hotplug emulation enabled, register the online cpu only=
,
+        * the rests are reserved for cpu probe.
+        */
+       for_each_present_cpu(i) {
+               if ((cpu_hpe_on && cpu_online(i)) || !cpu_hpe_on)
+                       arch_register_cpu(i);
+       }

        return 0;
 }
diff --git a/arch/x86/mm/numa_64.c linux-hpe4/arch/x86/mm/numa_64.c
index c3f8050..d13b5b8 100644
--- a/arch/x86/mm/numa_64.c
+++ linux-hpe4/arch/x86/mm/numa_64.c
@@ -14,6 +14,7 @@
 #include <linux/nodemask.h>
 #include <linux/sched.h>
 #include <linux/acpi.h>
+#include <linux/cpu.h>

 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -665,3 +666,17 @@ int __cpuinit numa_cpu_node(int cpu)
                return __apicid_to_node[apicid];
        return NUMA_NO_NODE;
 }
+
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+static __init int cpu_hpe_setup(char *opt)
+{
+       if (!opt)
+               return -EINVAL;
+
+       if (!strncmp(opt, "on", 2) || !strncmp(opt, "1", 1))
+               cpu_hpe_on =3D 1;
+
+       return 0;
+}
+early_param("cpu_hpe", cpu_hpe_setup);
+#endif  /* CONFIG_ARCH_CPU_PROBE_RELEASE */
diff --git a/drivers/acpi/processor_driver.c linux-hpe4/drivers/acpi/proces=
sor_driver.c
index 360a74e..e6da38a 100644
--- a/drivers/acpi/processor_driver.c
+++ linux-hpe4/drivers/acpi/processor_driver.c
@@ -492,6 +492,14 @@ static int __cpuinit acpi_processor_add(struct acpi_de=
vice *device)
        per_cpu(processors, pr->id) =3D pr;

        sysdev =3D get_cpu_sysdev(pr->id);
+       /*
+        * Reserve cpu for hotplug emulation, the reserved cpu can be hot-a=
dded
+        * throu the cpu probe interface. Return directly.
+        */
+       if (sysdev =3D=3D NULL) {
+               goto out;
+       }
+
        if (sysfs_create_link(&device->dev.kobj, &sysdev->kobj, "sysdev")) =
{
                result =3D -EFAULT;
                goto err_free_cpumask;
@@ -532,6 +540,7 @@ static int __cpuinit acpi_processor_add(struct acpi_dev=
ice *device)
                goto err_remove_sysfs;
        }

+out:
        return 0;

 err_remove_sysfs:
diff --git a/drivers/base/cpu.c linux-hpe4/drivers/base/cpu.c
index 6b791ae..87be7a9 100644
--- a/drivers/base/cpu.c
+++ linux-hpe4/drivers/base/cpu.c
@@ -22,9 +22,15 @@ struct sysdev_class cpu_sysdev_class =3D {
 };
 EXPORT_SYMBOL(cpu_sysdev_class);

-static DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
+DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);

 #ifdef CONFIG_HOTPLUG_CPU
+/*
+ * cpu_hpe_on is a switch to enable/disable cpu hotplug emulation. it is
+ * disabled in default, we can enable it throu grub parameter cpu_hpe=3Don
+ */
+int cpu_hpe_on;
+
 static ssize_t show_online(struct sys_device *dev, struct sysdev_attribute=
 *attr,
                           char *buf)
 {
diff --git a/include/linux/acpi.h linux-hpe4/include/linux/acpi.h
index a2e910e..9cd5676 100644
--- a/include/linux/acpi.h
+++ linux-hpe4/include/linux/acpi.h
@@ -102,6 +102,7 @@ void acpi_numa_arch_fixup(void);
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /* Arch dependent functions for cpu hotplug support */
 int acpi_map_lsapic(acpi_handle handle, int *pcpu);
+int acpi_map_lsapic_emu(int pcpu, int nid);
 int acpi_unmap_lsapic(int cpu);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */

diff --git a/include/linux/cpu.h linux-hpe4/include/linux/cpu.h
index 014856d..a4258ba 100644
--- a/include/linux/cpu.h
+++ linux-hpe4/include/linux/cpu.h
@@ -25,6 +25,8 @@ struct cpu {
        struct sys_device sysdev;
 };

+DECLARE_PER_CPU(struct sys_device *, cpu_sys_devices);
+
 extern int register_cpu_node(struct cpu *cpu, int num, int nid);

 static inline int register_cpu(struct cpu *cpu, int num)
@@ -144,6 +146,7 @@ extern void put_online_cpus(void);
 #define register_hotcpu_notifier(nb)   register_cpu_notifier(nb)
 #define unregister_hotcpu_notifier(nb) unregister_cpu_notifier(nb)
 int cpu_down(unsigned int cpu);
+extern int cpu_hpe_on;

 #ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
 extern void cpu_hotplug_driver_lock(void);
@@ -166,6 +169,7 @@ static inline void cpu_hotplug_driver_unlock(void)
 /* These aren't inline functions due to a GCC bug. */
 #define register_hotcpu_notifier(nb)   ({ (void)(nb); 0; })
 #define unregister_hotcpu_notifier(nb) ({ (void)(nb); })
+static int cpu_hpe_on;
 #endif         /* CONFIG_HOTPLUG_CPU */

 #ifdef CONFIG_PM_SLEEP_SMP
--
1.7.1.1
---
best regards
yang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
