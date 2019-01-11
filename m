Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57D558E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:13:49 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i3so9496837pfj.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:13:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b36sor54771245pgl.8.2019.01.10.21.13.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 21:13:47 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 4/7] x86/setup: parse acpi to get hotplug info before init_mem_mapping()
Date: Fri, 11 Jan 2019 13:12:54 +0800
Message-Id: <1547183577-20309-5-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

At present, memblock bottom-up allocation can help us against staining over
movable node in very high probability. But if the hotplug info has already
been parsed, the memblock allocator can step around the movable node by
itself. This patch pushes the parsing step forward, just ahead of where,
the memblock allocator can work. About how memblock allocator steps around
the movable node, referring to the cond check on memblock_is_hotpluggable()
in __next_mem_range().
Later in this series, the bottom-up allocation style can be removed on x86_64.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: x86@kernel.org
Cc: linux-acpi@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/x86/kernel/setup.c | 39 ++++++++++++++++++++++++++++++---------
 include/linux/acpi.h    |  1 +
 2 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index a0122cd..9b57e01 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -804,6 +804,35 @@ dump_kernel_offset(struct notifier_block *self, unsigned long v, void *p)
 	return 0;
 }
 
+static void early_acpi_parse(void)
+{
+	phys_addr_t start, end, orig_start, orig_end;
+	bool enforcing;
+
+	enforcing = memblock_get_current_limit(&orig_start, &orig_end);
+	/* find a 16MB slot for temporary usage by the following routines. */
+	start = memblock_find_in_range(ISA_END_ADDRESS,
+			max_pfn, 1 << 24, 1);
+	end = start + 1 + (1 << 24);
+	memblock_set_current_limit(start, end, true);
+#ifdef CONFIG_BLK_DEV_INITRD
+	if (get_ramdisk_size())
+		acpi_table_upgrade(__va(get_ramdisk_image()),
+			get_ramdisk_size());
+#endif
+	/*
+	 * Parse the ACPI tables for possible boot-time SMP configuration.
+	 */
+	acpi_boot_table_init();
+	early_acpi_boot_init();
+	initmem_init();
+	/* check whether memory is returned or not */
+	start = memblock_find_in_range(start, end, 1<<24, 1);
+	if (!start)
+		pr_warn("the above acpi routines change and consume memory\n");
+	memblock_set_current_limit(orig_start, orig_end, enforcing);
+}
+
 /*
  * Determine if we were loaded by an EFI loader.  If so, then we have also been
  * passed the efi memmap, systab, etc., so we should use these data structures
@@ -1129,6 +1158,7 @@ void __init setup_arch(char **cmdline_p)
 	if (movable_node_is_enabled())
 		memblock_set_bottom_up(true);
 #endif
+	early_acpi_parse();
 	init_mem_mapping();
 	memblock_set_current_limit(0, get_max_mapped(), false);
 
@@ -1173,21 +1203,12 @@ void __init setup_arch(char **cmdline_p)
 	reserve_initrd();
 
 
-	acpi_table_upgrade((void *)initrd_start, initrd_end - initrd_start);
 	vsmp_init();
 
 	io_delay_init();
 
 	early_platform_quirks();
 
-	/*
-	 * Parse the ACPI tables for possible boot-time SMP configuration.
-	 */
-	acpi_boot_table_init();
-
-	early_acpi_boot_init();
-
-	initmem_init();
 	dma_contiguous_reserve(max_pfn_mapped << PAGE_SHIFT);
 
 	/*
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 0b6e0b6..4f6b391 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -235,6 +235,7 @@ int acpi_mps_check (void);
 int acpi_numa_init (void);
 
 int acpi_table_init (void);
+void acpi_tb_terminate(void);
 int acpi_table_parse(char *id, acpi_tbl_table_handler handler);
 int __init acpi_table_parse_entries(char *id, unsigned long table_size,
 			      int entry_id,
-- 
2.7.4
