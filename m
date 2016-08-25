Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9B8683093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 04:36:12 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so69469232pab.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 01:36:12 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ro7si14440841pab.37.2016.08.25.01.36.10
        for <linux-mm@kvack.org>;
        Thu, 25 Aug 2016 01:36:11 -0700 (PDT)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH v12 3/7] x86, acpi, cpu-hotplug: Introduce cpuid_to_apicid[] array to store persistent cpuid <-> apicid mapping.
Date: Thu, 25 Aug 2016 16:35:16 +0800
Message-ID: <1472114120-3281-4-git-send-email-douly.fnst@cn.fujitsu.com>
In-Reply-To: <1472114120-3281-1-git-send-email-douly.fnst@cn.fujitsu.com>
References: <1472114120-3281-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org
Cc: x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dou Liyang <douly.fnst@cn.fujitsu.com>

From: Gu Zheng <guz.fnst@cn.fujitsu.com>

The whole patch-set aims at making cpuid <-> nodeid mapping persistent. So that,
when node online/offline happens, cache based on cpuid <-> nodeid mapping such as
wq_numa_possible_cpumask will not cause any problem.
It contains 4 steps:
1. Enable apic registeration flow to handle both enabled and disabled cpus.
2. Introduce a new array storing all possible cpuid <-> apicid mapping.
3. Enable _MAT and MADT relative apis to return non-presnet or disabled cpus' apicid.
4. Establish all possible cpuid <-> nodeid mapping.

This patch finishes step 2.

In this patch, we introduce a new static array named cpuid_to_apicid[],
which is large enough to store info for all possible cpus.

And then, we modify the cpuid calculation. In generic_processor_info(),
it simply finds the next unused cpuid. And it is also why the cpuid <-> nodeid
mapping changes with node hotplug.

After this patch, we find the next unused cpuid, map it to an apicid,
and store the mapping in cpuid_to_apicid[], so that cpuid <-> apicid
mapping will be persistent.

And finally we will use this array to make cpuid <-> nodeid persistent.

cpuid <-> apicid mapping is established at local apic registeration time.
But non-present or disabled cpus are ignored.

In this patch, we establish all possible cpuid <-> apicid mapping when
registering local apic.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 arch/x86/include/asm/mpspec.h |  1 +
 arch/x86/kernel/acpi/boot.c   |  7 +----
 arch/x86/kernel/apic/apic.c   | 61 ++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 60 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/mpspec.h b/arch/x86/include/asm/mpspec.h
index b07233b..db902d8 100644
--- a/arch/x86/include/asm/mpspec.h
+++ b/arch/x86/include/asm/mpspec.h
@@ -86,6 +86,7 @@ static inline void early_reserve_e820_mpc_new(void) { }
 #endif
 
 int generic_processor_info(int apicid, int version);
+int __generic_processor_info(int apicid, int version, bool enabled);
 
 #define PHYSID_ARRAY_SIZE	BITS_TO_LONGS(MAX_LOCAL_APIC)
 
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 90d84c3..abd939c 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -176,15 +176,10 @@ static int acpi_register_lapic(int id, u32 acpiid, u8 enabled)
 		return -EINVAL;
 	}
 
-	if (!enabled) {
-		++disabled_cpus;
-		return -EINVAL;
-	}
-
 	if (boot_cpu_physical_apicid != -1U)
 		ver = apic_version[boot_cpu_physical_apicid];
 
-	cpu = generic_processor_info(id, ver);
+	cpu = __generic_processor_info(id, ver, enabled);
 	if (cpu >= 0)
 		early_per_cpu(x86_cpu_to_acpiid, cpu) = acpiid;
 
diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
index e5612a9..7aa9863 100644
--- a/arch/x86/kernel/apic/apic.c
+++ b/arch/x86/kernel/apic/apic.c
@@ -2024,7 +2024,53 @@ void disconnect_bsp_APIC(int virt_wire_setup)
 	apic_write(APIC_LVT1, value);
 }
 
-static int __generic_processor_info(int apicid, int version, bool enabled)
+/*
+ * The number of allocated logical CPU IDs. Since logical CPU IDs are allocated
+ * contiguously, it equals to current allocated max logical CPU ID plus 1.
+ * All allocated CPU ID should be in [0, nr_logical_cpuidi), so the maximum of
+ * nr_logical_cpuids is nr_cpu_ids.
+ *
+ * NOTE: Reserve 0 for BSP.
+ */
+static int nr_logical_cpuids = 1;
+
+/*
+ * Used to store mapping between logical CPU IDs and APIC IDs.
+ */
+static int cpuid_to_apicid[] = {
+	[0 ... NR_CPUS - 1] = -1,
+};
+
+/*
+ * Should use this API to allocate logical CPU IDs to keep nr_logical_cpuids
+ * and cpuid_to_apicid[] synchronized.
+ */
+static int allocate_logical_cpuid(int apicid)
+{
+	int i;
+
+	/*
+	 * cpuid <-> apicid mapping is persistent, so when a cpu is up,
+	 * check if the kernel has allocated a cpuid for it.
+	 */
+	for (i = 0; i < nr_logical_cpuids; i++) {
+		if (cpuid_to_apicid[i] == apicid)
+			return i;
+	}
+
+	/* Allocate a new cpuid. */
+	if (nr_logical_cpuids >= nr_cpu_ids) {
+		WARN_ONCE(1, "Only %d processors supported."
+			     "Processor %d/0x%x and the rest are ignored.\n",
+			     nr_cpu_ids - 1, nr_logical_cpuids, apicid);
+		return -1;
+	}
+
+	cpuid_to_apicid[nr_logical_cpuids] = apicid;
+	return nr_logical_cpuids++;
+}
+
+int __generic_processor_info(int apicid, int version, bool enabled)
 {
 	int cpu, max = nr_cpu_ids;
 	bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
@@ -2099,8 +2145,17 @@ static int __generic_processor_info(int apicid, int version, bool enabled)
 		 * for BSP.
 		 */
 		cpu = 0;
-	} else
-		cpu = cpumask_next_zero(-1, cpu_present_mask);
+
+		/* Logical cpuid 0 is reserved for BSP. */
+		cpuid_to_apicid[0] = apicid;
+	} else {
+		cpu = allocate_logical_cpuid(apicid);
+		if (cpu < 0) {
+
+			disabled_cpus++;
+			return -EINVAL;
+		}
+	}
 
 	/*
 	 * This can happen on physical hotplug. The sanity check at boot time
-- 
2.5.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
