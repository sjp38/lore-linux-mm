From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080118153609.12646.97784.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/2] Allow any x86 sub-architecture type to set CONFIG_NUMA
Date: Fri, 18 Jan 2008 15:36:09 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

While there are a limited number of x86 sub-architecture types that can
really support NUMA, there is nothing stopping other machines booting that
type of kernel. The fact that X86_GENERICARCH can set NUMA currently is an
indicator of that. This restriction only limits potential testing coverage.
This patch allows any sub-architecture to set CONFIG_NUMA if they wish.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 arch/x86/Kconfig          |    2 +-
 include/asm-x86/acpi_32.h |    1 +
 include/linux/acpi.h      |    1 -
 3 files changed, 2 insertions(+), 2 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-005_non64GB/arch/x86/Kconfig linux-2.6.24-rc8-010_any32bit_x86/arch/x86/Kconfig
--- linux-2.6.24-rc8-005_non64GB/arch/x86/Kconfig	2008-01-17 18:22:26.000000000 +0000
+++ linux-2.6.24-rc8-010_any32bit_x86/arch/x86/Kconfig	2008-01-17 18:22:37.000000000 +0000
@@ -817,7 +817,7 @@ config X86_PAE
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support (EXPERIMENTAL)"
 	depends on SMP
-	depends on X86_64 || (X86_32 && (X86_NUMAQ || (X86_SUMMIT || X86_GENERICARCH) && ACPI) && EXPERIMENTAL)
+	depends on X86_64 || (X86_32 && ACPI && EXPERIMENTAL)
 	default n if X86_PC
 	default y if (X86_NUMAQ || X86_SUMMIT)
 	help
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-005_non64GB/include/asm-x86/acpi_32.h linux-2.6.24-rc8-010_any32bit_x86/include/asm-x86/acpi_32.h
--- linux-2.6.24-rc8-005_non64GB/include/asm-x86/acpi_32.h	2008-01-16 04:22:48.000000000 +0000
+++ linux-2.6.24-rc8-010_any32bit_x86/include/asm-x86/acpi_32.h	2008-01-17 18:22:37.000000000 +0000
@@ -84,6 +84,7 @@ int __acpi_release_global_lock(unsigned 
 extern void early_quirks(void);
 
 #ifdef CONFIG_ACPI
+#define NR_NODE_MEMBLKS MAX_NUMNODES
 extern int acpi_lapic;
 extern int acpi_ioapic;
 extern int acpi_noirq;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-005_non64GB/include/linux/acpi.h linux-2.6.24-rc8-010_any32bit_x86/include/linux/acpi.h
--- linux-2.6.24-rc8-005_non64GB/include/linux/acpi.h	2008-01-16 04:22:48.000000000 +0000
+++ linux-2.6.24-rc8-010_any32bit_x86/include/linux/acpi.h	2008-01-17 18:22:37.000000000 +0000
@@ -94,7 +94,6 @@ void acpi_table_print_madt_entry (struct
 
 /* the following four functions are architecture-dependent */
 #ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
-#define NR_NODE_MEMBLKS MAX_NUMNODES
 #define acpi_numa_slit_init(slit) do {} while (0)
 #define acpi_numa_processor_affinity_init(pa) do {} while (0)
 #define acpi_numa_memory_affinity_init(ma) do {} while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
