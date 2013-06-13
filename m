Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 0631B90001C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:11 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 06/22] x86, ACPI: Split acpi_initrd_override() into find/copy two steps
Date: Thu, 13 Jun 2013 21:02:53 +0800
Message-Id: <1371128589-8953-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Jacob Shin <jacob.shin@amd.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>

To parse SRAT before memblock starts to work, we need to move acpi table
probing procedure earlier. But acpi_initrd_table_override procedure must
be executed before acpi table probing. So we need to move it earlier too,
which means to move acpi_initrd_table_override procedure before memblock
starts to work.

But acpi_initrd_table_override procedure needs memblock to allocate buffer
for ACPI tables. To solve this problem, we need to split acpi_initrd_override()
procedure into two steps: finding and copying.
Find should be as early as possible. Copy should be after memblock is ready.

Currently, acpi_initrd_table_override procedure is executed after
init_mem_mapping() and relocate_initrd(), so it can scan initrd and copy
acpi tables with kernel virtual addresses of initrd.

Once we split it into finding and copying steps, it could be done like the
following:

Finding could be done in head_32.S and head64.c, just like microcode early
scanning. In head_32.S, it is 32bit flat mode, we don't need to setup page
table to access it. In head64.c, #PF set page table could help us to access
initrd with kernel low mapping addresses.

Copying need to be done just after memblock is ready, because it needs to
allocate buffer for new acpi tables with memblock.
Also it should be done before probing acpi tables, and we need early_ioremap
to access source and target ranges, as init_mem_mapping is not called yet.

While a dummy version of acpi_initrd_override() was defined when
!CONFIG_ACPI_INITRD_TABLE_OVERRIDE, the prototype and dummy version were
conditionalized inside CONFIG_ACPI. This forced setup_arch() to have its own
#ifdefs around acpi_initrd_override() as otherwise build would fail when
!CONFIG_ACPI. Move the prototypes and dummy implementations of the newly
split functions out of CONFIG_ACPI block in acpi.h so that we can throw away
the #ifdefs from its users.

-v2: Split one patch out according to tj.
     also don't pass table_nr around.
-v3: Add Tj's changelog about moving down to #idef in acpi.h to
     avoid #idef in setup.c

Signed-off-by: Yinghai <yinghai@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Jacob Shin <jacob.shin@amd.com>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org
Acked-by: Tejun Heo <tj@kernel.org>
Tested-by: Thomas Renninger <trenn@suse.de>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/kernel/setup.c |    6 +++---
 drivers/acpi/osl.c      |   18 +++++++++++++-----
 include/linux/acpi.h    |   16 ++++++++--------
 3 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 6ca5f2c..42f584c 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1119,9 +1119,9 @@ void __init setup_arch(char **cmdline_p)
 
 	reserve_initrd();
 
-#if defined(CONFIG_ACPI) && defined(CONFIG_BLK_DEV_INITRD)
-	acpi_initrd_override((void *)initrd_start, initrd_end - initrd_start);
-#endif
+	acpi_initrd_override_find((void *)initrd_start,
+					initrd_end - initrd_start);
+	acpi_initrd_override_copy();
 
 	reserve_crashkernel();
 
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 53dd490..6ab6c54 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -572,14 +572,13 @@ static const char * const table_sigs[] = {
 #define ACPI_OVERRIDE_TABLES 64
 static struct cpio_data __initdata acpi_initrd_files[ACPI_OVERRIDE_TABLES];
 
-void __init acpi_initrd_override(void *data, size_t size)
+void __init acpi_initrd_override_find(void *data, size_t size)
 {
-	int sig, no, table_nr = 0, total_offset = 0;
+	int sig, no, table_nr = 0;
 	long offset = 0;
 	struct acpi_table_header *table;
 	char cpio_path[32] = "kernel/firmware/acpi/";
 	struct cpio_data file;
-	char *p;
 
 	if (data == NULL || size == 0)
 		return;
@@ -620,7 +619,14 @@ void __init acpi_initrd_override(void *data, size_t size)
 		acpi_initrd_files[table_nr].size = file.size;
 		table_nr++;
 	}
-	if (table_nr == 0)
+}
+
+void __init acpi_initrd_override_copy(void)
+{
+	int no, total_offset = 0;
+	char *p;
+
+	if (!all_tables_size)
 		return;
 
 	/* under 4G at first, then above 4G */
@@ -652,9 +658,11 @@ void __init acpi_initrd_override(void *data, size_t size)
 	 * tables at one time, we will hit the limit. So we need to map tables
 	 * one by one during copying.
 	 */
-	for (no = 0; no < table_nr; no++) {
+	for (no = 0; no < ACPI_OVERRIDE_TABLES; no++) {
 		phys_addr_t size = acpi_initrd_files[no].size;
 
+		if (!size)
+			break;
 		p = early_ioremap(acpi_tables_addr + total_offset, size);
 		memcpy(p, acpi_initrd_files[no].data, size);
 		early_iounmap(p, size);
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 17b5b59..8dd917b 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -79,14 +79,6 @@ typedef int (*acpi_tbl_table_handler)(struct acpi_table_header *table);
 typedef int (*acpi_tbl_entry_handler)(struct acpi_subtable_header *header,
 				      const unsigned long end);
 
-#ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
-void acpi_initrd_override(void *data, size_t size);
-#else
-static inline void acpi_initrd_override(void *data, size_t size)
-{
-}
-#endif
-
 char * __acpi_map_table (unsigned long phys_addr, unsigned long size);
 void __acpi_unmap_table(char *map, unsigned long size);
 int early_acpi_boot_init(void);
@@ -476,6 +468,14 @@ static inline bool acpi_driver_match_device(struct device *dev,
 
 #endif	/* !CONFIG_ACPI */
 
+#ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
+void acpi_initrd_override_find(void *data, size_t size);
+void acpi_initrd_override_copy(void);
+#else
+static inline void acpi_initrd_override_find(void *data, size_t size) { }
+static inline void acpi_initrd_override_copy(void) { }
+#endif
+
 #ifdef CONFIG_ACPI
 void acpi_os_set_prepare_sleep(int (*func)(u8 sleep_state,
 			       u32 pm1a_ctrl,  u32 pm1b_ctrl));
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
