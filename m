Message-Id: <20070912015646.938985912@sgi.com>
References: <20070912015644.927677070@sgi.com>
Date: Tue, 11 Sep 2007 18:56:51 -0700
From: travis@sgi.com
Subject: [PATCH 07/10] x86: acpi-use-cpu_physical_id (v3)
Content-Disposition: inline; filename=acpi-use-cpu_physical_id
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is from an earlier message from Christoph Lameter:

    processor_core.c currently tries to determine the apicid by special casing
    for IA64 and x86. The desired information is readily available via

	    cpu_physical_id()

    on IA64, i386 and x86_64.

    Signed-off-by: Christoph Lameter <clameter@sgi.com>

Additionally, boot_cpu_id needed to be exported to fix compile errors in
dma code when !CONFIG_SMP.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86_64/kernel/mpparse.c  |    2 ++
 drivers/acpi/processor_core.c |    8 +-------
 2 files changed, 3 insertions(+), 7 deletions(-)

--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -419,12 +419,6 @@
 	return 0;
 }
 
-#ifdef CONFIG_IA64
-#define arch_cpu_to_apicid 	ia64_cpu_to_sapicid
-#else
-#define arch_cpu_to_apicid 	x86_cpu_to_apicid
-#endif
-
 static int map_madt_entry(u32 acpi_id)
 {
 	unsigned long madt_end, entry;
@@ -498,7 +492,7 @@
 		return apic_id;
 
 	for (i = 0; i < NR_CPUS; ++i) {
-		if (arch_cpu_to_apicid[i] == apic_id)
+		if (cpu_physical_id(i) == apic_id)
 			return i;
 	}
 	return -1;
--- a/arch/x86_64/kernel/mpparse.c
+++ b/arch/x86_64/kernel/mpparse.c
@@ -57,6 +57,8 @@
 
 /* Processor that is doing the boot up */
 unsigned int boot_cpu_id = -1U;
+EXPORT_SYMBOL(boot_cpu_id);
+
 /* Internal processor count */
 unsigned int num_processors __cpuinitdata = 0;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
