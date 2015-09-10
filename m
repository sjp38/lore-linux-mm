Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 428FF6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 00:34:21 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so30868729pac.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 21:34:21 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id yk2si16195258pac.192.2015.09.09.21.29.54
        for <linux-mm@kvack.org>;
        Wed, 09 Sep 2015 21:34:20 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 5/7] x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[] array to store persistent cpuid <-> apicid mapping.
Date: Thu, 10 Sep 2015 12:27:47 +0800
Message-ID: <1441859269-25831-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com
Cc: tangchen@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

From: Gu Zheng <guz.fnst@cn.fujitsu.com>

This patch finishes step2 mentioned in previous patch 4.

In this patch, we introduce a new static array named apicid_to_cpuid[],
which is large enough to store info for all possible cpus.

And then, we modify the cpuid calculation. In generic_processor_info(),
it simply finds the next unused cpuid. And it is also why the cpuid <-> nodeid
mapping changes with node hotplug.

After this patch, we find the next unused cpuid, map it to an apicid,
and store the mapping in apicid_to_cpuid[], so that cpuid <-> apicid
mapping will be persistent.

And finally we will use this array to make cpuid <-> nodeid persistent.

cpuid <-> apicid mapping is established at local apic registeration time.
But non-present or disabled cpus are ignored.

In this patch, we establish all possible cpuid <-> apicid mapping when
registering local apic.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/mpspec.h |  1 +
 arch/x86/kernel/acpi/boot.c   |  6 ++---
 arch/x86/kernel/apic/apic.c   | 53 ++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 53 insertions(+), 7 deletions(-)

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
index e49ee24..bcc85b2 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -174,15 +174,13 @@ static int acpi_register_lapic(int id, u8 enabled)
 		return -EINVAL;
 	}
 
-	if (!enabled) {
+	if (!enabled)
 		++disabled_cpus;
-		return -EINVAL;
-	}
 
 	if (boot_cpu_physical_apicid != -1U)
 		ver = apic_version[boot_cpu_physical_apicid];
 
-	return generic_processor_info(id, ver);
+	return __generic_processor_info(id, ver, enabled);
 }
 
 static int __init
diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
index a9c9830..42b2a9c 100644
--- a/arch/x86/kernel/apic/apic.c
+++ b/arch/x86/kernel/apic/apic.c
@@ -1977,7 +1977,45 @@ void disconnect_bsp_APIC(int virt_wire_setup)
 	apic_write(APIC_LVT1, value);
 }
 
-static int __generic_processor_info(int apicid, int version, bool enabled)
+/*
+ * Current allocated max logical CPU ID plus 1.
+ * All allocated CPU ID should be in [0, max_logical_cpuid),
+ * so the maximum of max_logical_cpuid is nr_cpu_ids.
+ *
+ * NOTE: Reserve 0 for BSP.
+ */
+static int max_logical_cpuid = 1;
+
+static int cpuid_to_apicid[] = {
+	[0 ... NR_CPUS - 1] = -1,
+};
+
+static int allocate_logical_cpuid(int apicid)
+{
+	int i;
+
+	/*
+	 * cpuid <-> apicid mapping is persistent, so when a cpu is up,
+	 * check if the kernel has allocated a cpuid for it.
+	 */
+	for (i = 0; i < max_logical_cpuid; i++) {
+		if (cpuid_to_apicid[i] == apicid)
+			return i;
+	}
+
+	/* Allocate a new cpuid. */
+	if (max_logical_cpuid >= nr_cpu_ids) {
+		WARN_ONCE(1, "Only %d processors supported."
+			     "Processor %d/0x%x and the rest are ignored.\n",
+			     nr_cpu_ids - 1, max_logical_cpuid, apicid);
+		return -1;
+	}
+
+	cpuid_to_apicid[max_logical_cpuid] = apicid;
+	return max_logical_cpuid++;
+}
+
+int __generic_processor_info(int apicid, int version, bool enabled)
 {
 	int cpu, max = nr_cpu_ids;
 	bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
@@ -2058,8 +2096,17 @@ static int __generic_processor_info(int apicid, int version, bool enabled)
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
+			if (enabled)
+				disabled_cpus++;
+			return -EINVAL;
+		}
+	}
 
 	/*
 	 * Validate version
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
