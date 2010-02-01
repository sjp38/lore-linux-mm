Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CC6B86B0083
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 23:13:15 -0500 (EST)
Date: Mon, 1 Feb 2010 12:12:53 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: [Patch - Resend v4] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel
Message-ID: <20100201041253.GA1028@shaohui>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, haveblue@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, ak@linux.intel.com, fengguang.wu@intel.com, hpa@kernel.org, haicheng.li@intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Send the v4 patch to mailing list.

changelog:
v1: add memory range to e820 table, and update the varibles max_pfn/max_low_pfn/high_memory
	Peter[hpa]: memory hotplug make sense on 32-bit kernel for virtual environment.
	Andi[ak]: No VM supports it currently, and 64bit is the important part for hotplug 
	Fengguang[wfg]: some review comments on function naming
v2: rename function update_pfn to update_end_of_memory_vars
	KAMEZAWA[kame]: e820map is considerted to be stable, read-only after boot.
	Fengguang[wfg]: rewrite function page_is_ram, make it friendly for hotplug.
v3: keep the old e820map, update the varible max_pfn, high_memory only
	KAMEZAWA[kame]: suggest to use memory hotplug notifier. If it's allowed, it will
					be cleaner.
	Fengguang[wfg]: notifier is for _outsider_ subsystems. It smells a bit overkill to do 
					notifier _inside_ the hotplug code.
	Fengguang[wfg]: suggest to update max_pfn/max_low_pfn/high_memory in arch/x86/mm/init_64.c:
					arch_add_memory() now, for X86_64.  
					Later on we can add code to arch/x86/mm/init_32.c:arch_add_memory() for X86_32.
v4: update max_pfn/max_low_pfn/high_memory in arch/x86/mm/init_64.c:arch_add_memory() for x86_64,
	 and resent it to mailing list, since fengguang's page_is_ram patch was accepted,


Memory-Hotplug: Fix the bug on interface /dev/mem for 64-bit kernel

The new added memory can not be access by interface /dev/mem, because we do not
 update the variables high_memory, max_pfn and max_low_pfn.

Add a function update_end_of_memory_vars to update these variables for 64-bit 
kernel.

CC: Andi Kleen <ak@linux.intel.com>
CC: Li Haicheng <haicheng.li@intel.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 5a4398a..acfc01a 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -49,6 +49,7 @@
 #include <asm/numa.h>
 #include <asm/cacheflush.h>
 #include <asm/init.h>
+#include <linux/bootmem.h>
 
 static unsigned long dma_reserve __initdata;
 
@@ -614,6 +615,21 @@ void __init paging_init(void)
  * Memory hotplug specific functions
  */
 #ifdef CONFIG_MEMORY_HOTPLUG
+/**
+ * After memory hotplug, the variable max_pfn, max_low_pfn and high_memory will
+ * be affected, it will be updated in this function.
+ */
+static inline void __meminit update_end_of_memory_vars(u64 start,
+		u64 size)
+{
+	unsigned long end_pfn = PFN_UP(start + size);
+
+	if (end_pfn > max_pfn) {
+		max_low_pfn = max_pfn = end_pfn;
+		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
+	}
+}
+
 /*
  * Memory is added always to NORMAL zone. This means you will never get
  * additional DMA/DMA32 memory.
@@ -633,6 +649,9 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
-- 
Thanks & Regards,
Shaohuki


--BOKacYhQ+x31HxR3
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="memory-hotplug-fix-the-bug-on-interface-dev-mem-v4.patch"

Memory-Hotplug: Fix the bug on interface /dev/mem for 64-bit kernel

The new added memory can not be access by interface /dev/mem, because we do not
 update the variables high_memory, max_pfn and max_low_pfn.

Add a function update_end_of_memory_vars to update these variables for 64-bit 
kernel.

CC: Andi Kleen <ak@linux.intel.com>
CC: Li Haicheng <haicheng.li@intel.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 5a4398a..acfc01a 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -49,6 +49,7 @@
 #include <asm/numa.h>
 #include <asm/cacheflush.h>
 #include <asm/init.h>
+#include <linux/bootmem.h>
 
 static unsigned long dma_reserve __initdata;
 
@@ -614,6 +615,21 @@ void __init paging_init(void)
  * Memory hotplug specific functions
  */
 #ifdef CONFIG_MEMORY_HOTPLUG
+/**
+ * After memory hotplug, the variable max_pfn, max_low_pfn and high_memory will
+ * be affected, it will be updated in this function.
+ */
+static inline void __meminit update_end_of_memory_vars(u64 start,
+		u64 size)
+{
+	unsigned long end_pfn = PFN_UP(start + size);
+
+	if (end_pfn > max_pfn) {
+		max_low_pfn = max_pfn = end_pfn;
+		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
+	}
+}
+
 /*
  * Memory is added always to NORMAL zone. This means you will never get
  * additional DMA/DMA32 memory.
@@ -633,6 +649,9 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
 
+	/* update max_pfn, max_low_pfn and high_memory */
+	update_end_of_memory_vars(start, size);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(arch_add_memory);

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
