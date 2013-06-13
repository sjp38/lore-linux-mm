Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 56AE0900016
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:11 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 09/22] x86, ACPI: Find acpi tables in initrd early from head_32.S/head64.c
Date: Thu, 13 Jun 2013 21:02:56 +0800
Message-Id: <1371128589-8953-10-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Jacob Shin <jacob.shin@amd.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>

head64.c could use #PF handler setup page table to access initrd before
init mem mapping and initrd relocating.

head_32.S could use 32bit flat mode to access initrd before init mem
mapping initrd relocating.

This patch introduces x86_acpi_override_find(), which is called from
head_32.S/head64.c, to replace acpi_initrd_override_find(). So that we
can makes 32bit and 64 bit more consistent.

-v2: use inline function in header file instead according to tj.
     also still need to keep #idef head_32.S to avoid compiling error.
-v3: need to move down reserve_initrd() after acpi_initrd_override_copy(),
     to make sure we are using right address.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Jacob Shin <jacob.shin@amd.com>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org
Tested-by: Thomas Renninger <trenn@suse.de>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/setup.h |    6 ++++++
 arch/x86/kernel/head64.c     |    2 ++
 arch/x86/kernel/head_32.S    |    4 ++++
 arch/x86/kernel/setup.c      |   34 ++++++++++++++++++++++++++++++----
 4 files changed, 42 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
index 4f71d48..6f885b7 100644
--- a/arch/x86/include/asm/setup.h
+++ b/arch/x86/include/asm/setup.h
@@ -42,6 +42,12 @@ extern void visws_early_detect(void);
 static inline void visws_early_detect(void) { }
 #endif
 
+#ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
+void x86_acpi_override_find(void);
+#else
+static inline void x86_acpi_override_find(void) { }
+#endif
+
 extern unsigned long saved_video_mode;
 
 extern void reserve_standard_io_resources(void);
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 55b6761..229b281 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -175,6 +175,8 @@ void __init x86_64_start_kernel(char * real_mode_data)
 	if (console_loglevel == 10)
 		early_printk("Kernel alive\n");
 
+	x86_acpi_override_find();
+
 	clear_page(init_level4_pgt);
 	/* set init_level4_pgt kernel high mapping*/
 	init_level4_pgt[511] = early_level4_pgt[511];
diff --git a/arch/x86/kernel/head_32.S b/arch/x86/kernel/head_32.S
index 73afd11..ca08f0e 100644
--- a/arch/x86/kernel/head_32.S
+++ b/arch/x86/kernel/head_32.S
@@ -149,6 +149,10 @@ ENTRY(startup_32)
 	call load_ucode_bsp
 #endif
 
+#ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
+	call x86_acpi_override_find
+#endif
+
 /*
  * Initialize page tables.  This creates a PDE and a set of page
  * tables, which are located immediately beyond __brk_base.  The variable
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 142e042..d11b1b7 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -421,6 +421,34 @@ static void __init reserve_initrd(void)
 }
 #endif /* CONFIG_BLK_DEV_INITRD */
 
+#ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
+void __init x86_acpi_override_find(void)
+{
+	unsigned long ramdisk_image, ramdisk_size;
+	unsigned char *p = NULL;
+
+#ifdef CONFIG_X86_32
+	struct boot_params *boot_params_p;
+
+	/*
+	 * 32bit is from head_32.S, and it is 32bit flat mode.
+	 * So need to use phys address to access global variables.
+	 */
+	boot_params_p = (struct boot_params *)__pa_nodebug(&boot_params);
+	ramdisk_image = get_ramdisk_image(boot_params_p);
+	ramdisk_size  = get_ramdisk_size(boot_params_p);
+	p = (unsigned char *)ramdisk_image;
+	acpi_initrd_override_find(p, ramdisk_size, true);
+#else
+	ramdisk_image = get_ramdisk_image(&boot_params);
+	ramdisk_size  = get_ramdisk_size(&boot_params);
+	if (ramdisk_image)
+		p = __va(ramdisk_image);
+	acpi_initrd_override_find(p, ramdisk_size, false);
+#endif
+}
+#endif
+
 static void __init parse_setup_data(void)
 {
 	struct setup_data *data;
@@ -1117,12 +1145,10 @@ void __init setup_arch(char **cmdline_p)
 	/* Allocate bigger log buffer */
 	setup_log_buf(1);
 
-	reserve_initrd();
-
-	acpi_initrd_override_find((void *)initrd_start,
-					initrd_end - initrd_start, false);
 	acpi_initrd_override_copy();
 
+	reserve_initrd();
+
 	reserve_crashkernel();
 
 	vsmp_init();
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
