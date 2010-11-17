Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A55458D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:45:37 -0500 (EST)
Message-Id: <20101117021000.479272928@intel.com>
References: <20101117020759.016741414@intel.com>
Date: Wed, 17 Nov 2010 10:08:00 +0800
From: shaohui.zheng@intel.com
Subject: [1/8,v3] NUMA Hotplug Emulator: add function to hide memory region via e820 table.
Content-Disposition: inline; filename=001-hotplug-emulator-x86-add-function-to-hide-memory-region-via-e820.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Shaohui Zheng <shaohui.zheng@intel.com>
List-ID: <linux-mm.kvack.org>

From: Haicheng Li <haicheng.li@intel.com>

NUMA hotplug emulator needs to hide memory regions at the very
beginning of kernel booting. Then emulator will use these
memory regions to fake offlined numa nodes.

CC: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
 arch/x86/include/asm/e820.h |    1 +
 arch/x86/kernel/e820.c      |   19 ++++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletions(-)

Index: linux-hpe4/arch/x86/include/asm/e820.h
===================================================================
--- linux-hpe4.orig/arch/x86/include/asm/e820.h	2010-11-15 17:13:02.483461667 +0800
+++ linux-hpe4/arch/x86/include/asm/e820.h	2010-11-15 17:13:07.083461581 +0800
@@ -129,6 +129,7 @@
 extern void e820_register_active_regions(int nid, unsigned long start_pfn,
 					 unsigned long end_pfn);
 extern u64 e820_hole_size(u64 start, u64 end);
+extern u64 e820_hide_mem(u64 mem_size);
 extern void finish_e820_parsing(void);
 extern void e820_reserve_resources(void);
 extern void e820_reserve_resources_late(void);
Index: linux-hpe4/arch/x86/kernel/e820.c
===================================================================
--- linux-hpe4.orig/arch/x86/kernel/e820.c	2010-11-15 17:13:02.483461667 +0800
+++ linux-hpe4/arch/x86/kernel/e820.c	2010-11-15 17:13:07.083461581 +0800
@@ -971,6 +971,7 @@
 }
 
 static int userdef __initdata;
+static u64 max_mem_size __initdata = ULLONG_MAX;
 
 /* "mem=nopentium" disables the 4MB page tables. */
 static int __init parse_memopt(char *p)
@@ -989,12 +990,28 @@
 
 	userdef = 1;
 	mem_size = memparse(p, &p);
-	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
+	e820_remove_range(mem_size, max_mem_size - mem_size, E820_RAM, 1);
+	max_mem_size = mem_size;
 
 	return 0;
 }
 early_param("mem", parse_memopt);
 
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+u64 __init e820_hide_mem(u64 mem_size)
+{
+	u64 start, end_pfn;
+
+	userdef = 1;
+	end_pfn = e820_end_of_ram_pfn();
+	start = (end_pfn << PAGE_SHIFT) - mem_size;
+	e820_remove_range(start, max_mem_size - start, E820_RAM, 1);
+	max_mem_size = start;
+
+	return start;
+}
+#endif
+
 static int __init parse_memmap_opt(char *p)
 {
 	char *oldp;

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
