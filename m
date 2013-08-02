Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id BEEE16B003A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 05:16:15 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 RESEND 10/18] x86, acpi: Try to find if SRAT is overrided earlier.
Date: Fri, 2 Aug 2013 17:14:29 +0800
Message-Id: <1375434877-20704-11-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Linux cannot migrate pages used by the kernel due to the direct mapping
(va = pa + PAGE_OFFSET), any memory used by the kernel cannot be hot-removed.
So when using memory hotplug, we have to prevent the kernel from using
hotpluggable memory.

The ACPI table SRAT (System Resource Affinity Table) contains info to specify
which memory is hotpluggble. After SRAT is parsed, we are aware of which
memory is hotpluggable.

At the early time when system is booting, SRAT has not been parsed. The boot
memory allocator memblock will allocate any memory to the kernel. So we need
SRAT parsed before memblock starts to work.

In this patch, we are going to parse SRAT earlier, right after memblock is ready.

Generally speaking, tables such as SRAT are provided by firmware. But
ACPI_INITRD_TABLE_OVERRIDE functionality allows users to customize their own
tables in initrd, and override the ones from firmware. So if we want to parse
SRAT earlier, we also need to do SRAT override earlier.

First, we introduce early_acpi_override_srat() to check if SRAT will be overridden
from initrd.

Second, we introduce find_hotpluggable_memory() to reserve hotpluggable memory,
which will firstly call early_acpi_override_srat() to find out which memory is
hotpluggable in the override SRAT.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/kernel/setup.c        |   10 ++++++
 drivers/acpi/osl.c             |   61 ++++++++++++++++++++++++++++++++++++++++
 include/linux/acpi.h           |   14 ++++++++-
 include/linux/memory_hotplug.h |    2 +
 mm/memory_hotplug.c            |   25 +++++++++++++++-
 5 files changed, 109 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index b2ce0dc..c23e6a7 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1058,6 +1058,16 @@ void __init setup_arch(char **cmdline_p)
 	/* Initialize ACPI global root table list. */
 	early_acpi_boot_table_init();
 
+#ifdef CONFIG_ACPI_NUMA
+	/*
+	 * Linux kernel cannot migrate kernel pages, as a result, memory used
+	 * by the kernel cannot be hot-removed. Find and mark hotpluggable
+	 * memory in memblock to prevent memblock from allocating hotpluggable
+	 * memory for the kernel.
+	 */
+	find_hotpluggable_memory();
+#endif
+
 	/*
 	 * The EFI specification says that boot service code won't be called
 	 * after ExitBootServices(). This is, in fact, a lie.
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 0043e9f..dcbca3e 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -48,6 +48,7 @@
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
+#include <asm/setup.h>
 
 #include <acpi/acpi.h>
 #include <acpi/acpi_bus.h>
@@ -631,6 +632,66 @@ int __init acpi_verify_table(struct cpio_data *file,
 	return 0;
 }
 
+#ifdef CONFIG_ACPI_NUMA
+/*******************************************************************************
+ *
+ * FUNCTION:    early_acpi_override_srat
+ *
+ * RETURN:      Phys addr of SRAT on success, 0 on error.
+ *
+ * DESCRIPTION: Try to get the phys addr of SRAT in initrd.
+ *              The ACPI_INITRD_TABLE_OVERRIDE procedure is able to use tables
+ *              in initrd file to override the ones provided by firmware. This
+ *              function checks if there is a SRAT in initrd at early time. If
+ *              so, return the phys addr of the SRAT.
+ *
+ ******************************************************************************/
+phys_addr_t __init early_acpi_override_srat(void)
+{
+	int i;
+	u32 length;
+	long offset;
+	void *ramdisk_vaddr;
+	struct acpi_table_header *table;
+	struct cpio_data file;
+	unsigned long map_step = NR_FIX_BTMAPS << PAGE_SHIFT;
+	phys_addr_t ramdisk_image = get_ramdisk_image();
+	char cpio_path[32] = "kernel/firmware/acpi/";
+
+	if (!ramdisk_image || !get_ramdisk_size())
+		return 0;
+
+	/* Try to find if SRAT is overridden */
+	for (i = 0; i < ACPI_OVERRIDE_TABLES; i++) {
+		ramdisk_vaddr = early_ioremap(ramdisk_image, map_step);
+
+		file = find_cpio_data(cpio_path, ramdisk_vaddr,
+				      map_step, &offset);
+		if (!file.data) {
+			early_iounmap(ramdisk_vaddr, map_step);
+			return 0;
+		}
+
+		table = file.data;
+		length = table->length;
+
+		if (acpi_verify_table(&file, cpio_path, ACPI_SIG_SRAT)) {
+			ramdisk_image += offset;
+			early_iounmap(ramdisk_vaddr, map_step);
+			continue;
+		}
+
+		/* Found SRAT */
+		early_iounmap(ramdisk_vaddr, map_step);
+		ramdisk_image = ramdisk_image + offset - length;
+
+		break;
+	}
+
+	return ramdisk_image;
+}
+#endif	/* CONFIG_ACPI_NUMA */
+
 void __init acpi_initrd_override(void *data, size_t size)
 {
 	int no, table_nr = 0, total_offset = 0;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index b722183..d86455a 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -81,11 +81,21 @@ typedef int (*acpi_tbl_entry_handler)(struct acpi_subtable_header *header,
 
 #ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
 void acpi_initrd_override(void *data, size_t size);
-#else
+
+#ifdef CONFIG_ACPI_NUMA
+phys_addr_t early_acpi_override_srat(void);
+#endif	/* CONFIG_ACPI_NUMA */
+
+#else	/* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
 static inline void acpi_initrd_override(void *data, size_t size)
 {
 }
-#endif
+
+static inline phys_addr_t early_acpi_override_srat(void)
+{
+	return 0;
+}
+#endif	/* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
 
 char * __acpi_map_table (unsigned long phys_addr, unsigned long size);
 void __acpi_unmap_table(char *map, unsigned long size);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index dd38e62..463efa9 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -104,6 +104,7 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
+extern void find_hotpluggable_memory(void);
 
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
@@ -181,6 +182,7 @@ static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
 {
 }
 #endif
+
 extern void put_page_bootmem(struct page *page);
 extern void get_page_bootmem(unsigned long ingo, struct page *page,
 			     unsigned long type);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ca1dd3a..2a57888 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -30,6 +30,7 @@
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
 #include <linux/stop_machine.h>
+#include <linux/acpi.h>
 
 #include <asm/tlbflush.h>
 
@@ -62,7 +63,6 @@ void unlock_memory_hotplug(void)
 	mutex_unlock(&mem_hotplug_mutex);
 }
 
-
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
@@ -91,6 +91,29 @@ static void release_memory_resource(struct resource *res)
 	return;
 }
 
+#ifdef CONFIG_ACPI_NUMA
+/**
+ * find_hotpluggable_memory - Find out hotpluggable memory from ACPI SRAT.
+ *
+ * This function did the following:
+ * 1. Try to find if there is a SRAT in initrd file used to override the one
+ *    provided by firmware. If so, get its phys addr.
+ * 2. If there is no override SRAT, get the phys addr of the SRAT in firmware.
+ * 3. Parse SRAT, find out which memory is hotpluggable.
+ */
+void __init find_hotpluggable_memory(void)
+{
+	phys_addr_t srat_paddr;
+
+	/* Try to find if SRAT is overridden */
+	srat_paddr = early_acpi_override_srat();
+	if (!srat_paddr)
+		return;
+
+	/* Will parse SRAT and find out hotpluggable memory here */
+}
+#endif	/* CONFIG_ACPI_NUMA */
+
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
 void get_page_bootmem(unsigned long info,  struct page *page,
 		      unsigned long type)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
