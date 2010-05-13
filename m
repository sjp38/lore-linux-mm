Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D688E6B020F
	for <linux-mm@kvack.org>; Thu, 13 May 2010 07:46:19 -0400 (EDT)
Date: Thu, 13 May 2010 19:41:36 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: [RFC,1/7] NUMA Hotplug emulator
Message-ID: <20100513114136.GB2169@shaohui>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

x86/E820: add function to hide memory region via e820 table.

NUMA hotplug emulator needs to hide memory regions at the very
beginning of kernel booting. Then emulator will use these
memory regions to fake offlined numa nodes.

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
 arch/x86/include/asm/e820.h |    1 +
 arch/x86/kernel/e820.c      |   19 ++++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/e820.h b/arch/x86/include/asm/e820.h
index 0e22296..027bbb1 100644
--- a/arch/x86/include/asm/e820.h
+++ b/arch/x86/include/asm/e820.h
@@ -124,6 +124,7 @@ extern int e820_find_active_region(const struct e820entry *ei,
 extern void e820_register_active_regions(int nid, unsigned long start_pfn,
 					 unsigned long end_pfn);
 extern u64 e820_hole_size(u64 start, u64 end);
+extern u64 e820_hide_mem(u64 mem_size);
 extern void finish_e820_parsing(void);
 extern void e820_reserve_resources(void);
 extern void e820_reserve_resources_late(void);
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 7bca3c6..1993275 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -971,6 +971,7 @@ static void early_panic(char *msg)
 }
 
 static int userdef __initdata;
+static u64 max_mem_size __initdata = ULLONG_MAX;
 
 /* "mem=nopentium" disables the 4MB page tables. */
 static int __init parse_memopt(char *p)
@@ -989,12 +990,28 @@ static int __init parse_memopt(char *p)
 
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
1.6.0.rc1

-- 
Thanks & Regards,
Shaohui


--zYM0uCDKw75PZbzx
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="001-hotplug-emulator-x86-add-function-to-hide-memory-region-via-e820.patch"

x86/E820: add function to hide memory region via e820 table.

NUMA hotplug emulator needs to hide memory regions at the very
beginning of kernel booting. Then emulator will use these
memory regions to fake offlined numa nodes.

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
 arch/x86/include/asm/e820.h |    1 +
 arch/x86/kernel/e820.c      |   19 ++++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/e820.h b/arch/x86/include/asm/e820.h
index 0e22296..027bbb1 100644
--- a/arch/x86/include/asm/e820.h
+++ b/arch/x86/include/asm/e820.h
@@ -124,6 +124,7 @@ extern int e820_find_active_region(const struct e820entry *ei,
 extern void e820_register_active_regions(int nid, unsigned long start_pfn,
 					 unsigned long end_pfn);
 extern u64 e820_hole_size(u64 start, u64 end);
+extern u64 e820_hide_mem(u64 mem_size);
 extern void finish_e820_parsing(void);
 extern void e820_reserve_resources(void);
 extern void e820_reserve_resources_late(void);
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 7bca3c6..1993275 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -971,6 +971,7 @@ static void early_panic(char *msg)
 }
 
 static int userdef __initdata;
+static u64 max_mem_size __initdata = ULLONG_MAX;
 
 /* "mem=nopentium" disables the 4MB page tables. */
 static int __init parse_memopt(char *p)
@@ -989,12 +990,28 @@ static int __init parse_memopt(char *p)
 
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
1.6.0.rc1


--zYM0uCDKw75PZbzx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
