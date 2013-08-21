Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 3647E6B0082
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 06:17:09 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 8/8] x86, acpi: Do acpi_initrd_override() earlier in head_32.S/head64.c.
Date: Wed, 21 Aug 2013 18:15:43 +0800
Message-Id: <1377080143-28455-9-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Introduce x86_acpi_initrd_override() to do acpi table override job. This function
can be called before or after paging is enabled. On 32bit, it will be called before
paging is enabled. On 64bit, it will be called after paging is enabled but before
direct mapping page tables are setup.

Originally-From: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/setup.h |    6 +++++
 arch/x86/kernel/head64.c     |    4 +++
 arch/x86/kernel/head_32.S    |    4 +++
 arch/x86/kernel/setup.c      |   51 ++++++++++++++++++++++++++++++++---------
 4 files changed, 54 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
index 96d00da..9f32cb4 100644
--- a/arch/x86/include/asm/setup.h
+++ b/arch/x86/include/asm/setup.h
@@ -42,6 +42,12 @@ extern void visws_early_detect(void);
 static inline void visws_early_detect(void) { }
 #endif
 
+#ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
+void x86_acpi_initrd_override(void);
+#else
+static inline void x86_acpi_initrd_override(void) { }
+#endif	/* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
+
 extern unsigned long saved_video_mode;
 
 extern void reserve_standard_io_resources(void);
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 55b6761..88e19b4 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -175,6 +175,10 @@ void __init x86_64_start_kernel(char * real_mode_data)
 	if (console_loglevel == 10)
 		early_printk("Kernel alive\n");
 
+#if defined(CONFIG_ACPI) && defined(CONFIG_BLK_DEV_INITRD)
+	x86_acpi_initrd_override();
+#endif
+
 	clear_page(init_level4_pgt);
 	/* set init_level4_pgt kernel high mapping*/
 	init_level4_pgt[511] = early_level4_pgt[511];
diff --git a/arch/x86/kernel/head_32.S b/arch/x86/kernel/head_32.S
index 5dd87a8..e04e13b 100644
--- a/arch/x86/kernel/head_32.S
+++ b/arch/x86/kernel/head_32.S
@@ -149,6 +149,10 @@ ENTRY(startup_32)
 	call load_ucode_bsp
 #endif
 
+#if defined(CONFIG_ACPI) && defined(CONFIG_BLK_DEV_INITRD)
+	call x86_acpi_initrd_override
+#endif
+
 /*
  * Initialize page tables.  This creates a PDE and a set of page
  * tables, which are located immediately beyond __brk_base.  The variable
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 5729cd2..b48a0ff 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -833,7 +833,46 @@ static void __init trim_low_memory_range(void)
 {
 	memblock_reserve(0, ALIGN(reserve_low, PAGE_SIZE));
 }
-	
+
+#ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
+/**
+ * x86_acpi_initrd_override - Find all acpi override tables in initrd, and copy
+ *                            them to acpi_tables_addr.
+ *
+ * On 32bit platform, this function is call in head_32.S, before paging is
+ * enabled. So we have to use physical address.
+ *
+ * On 64bit platform, this function is call in head_64.c, after paging is
+ * enabled but before direct mapping page tables are set up. Since we have an
+ * early page fault handler on 64bit, so it is OK to use virtual address.
+ */
+void __init x86_acpi_initrd_override(void)
+{
+	unsigned long ramdisk_image, ramdisk_size;
+	void *p = NULL;
+
+#ifdef CONFIG_X86_32
+	struct boot_params *boot_params_p;
+
+	boot_params_p = (struct boot_params *)__pa(&boot_params);
+	ramdisk_image = get_ramdisk_image(boot_params_p);
+	ramdisk_size  = get_ramdisk_size(boot_params_p);
+	p = (void *)ramdisk_image;
+
+	early_alloc_acpi_override_tables_buf(true);
+	acpi_initrd_override(p, ramdisk_size, true);
+#else
+	ramdisk_image = get_ramdisk_image(&boot_params);
+	ramdisk_size  = get_ramdisk_size(&boot_params);
+	if (ramdisk_image)
+		p = (void *)__va(ramdisk_image);
+
+	early_alloc_acpi_override_tables_buf(false);
+	acpi_initrd_override(p, ramdisk_size, false);
+#endif	/* CONFIG_X86_32 */
+}
+#endif	/* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
+
 /*
  * Determine if we were loaded by an EFI loader.  If so, then we have also been
  * passed the efi memmap, systab, etc., so we should use these data structures
@@ -1069,11 +1108,6 @@ void __init setup_arch(char **cmdline_p)
 
 	early_alloc_pgt_buf();
 
-#if defined(CONFIG_ACPI) && defined(CONFIG_BLK_DEV_INITRD)
-	/* Allocate buffer to store acpi override tables in brk. */
-	early_alloc_acpi_override_tables_buf(false);
-#endif
-
 	/*
 	 * Need to conclude brk, before memblock_x86_fill()
 	 *  it could use memblock_find_in_range, could overlap with
@@ -1132,11 +1166,6 @@ void __init setup_arch(char **cmdline_p)
 
 	reserve_initrd();
 
-#if defined(CONFIG_ACPI) && defined(CONFIG_BLK_DEV_INITRD)
-	acpi_initrd_override((void *)initrd_start, initrd_end - initrd_start,
-			     false);
-#endif
-
 	reserve_crashkernel();
 
 	vsmp_init();
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
