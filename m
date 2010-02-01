Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E98CA6B0071
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 07:23:27 -0500 (EST)
Date: Mon, 1 Feb 2010 20:22:02 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [Patch - Resend v4] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel
Message-ID: <20100201122202.GA2021@shaohui>
References: <20100201041253.GA1028@shaohui>
 <20100201044124.GA29097@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Content-Disposition: inline
In-Reply-To: <20100201044124.GA29097@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, haveblue@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, ak@linux.intel.com, hpa@kernel.org, haicheng.li@intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 01, 2010 at 12:41:24PM +0800, Wu Fengguang wrote:
> Shaohui,
> 
> Some style nitpicks..
> 
> >  #ifdef CONFIG_MEMORY_HOTPLUG
> > +/**
> 
> Should use /* here. 
Agree.
> 
> > + * After memory hotplug, the variable max_pfn, max_low_pfn and high_memory will
> > + * be affected, it will be updated in this function.
> > + */
> > +static inline void __meminit update_end_of_memory_vars(u64 start,
> 
> The "inline" and "__meminit" are both redundant here.
will remove both.
> 
> > +		max_low_pfn = max_pfn = end_pfn;
> 
> One assignment per line is preferred.
will change to 2 statements.
> 
> Thanks,
> Fengguang

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
index 5198b9b..e1c9202 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -49,6 +49,7 @@
 #include <asm/numa.h>
 #include <asm/cacheflush.h>
 #include <asm/init.h>
+#include <linux/bootmem.h>
 
 static unsigned long dma_reserve __initdata;
 
@@ -616,6 +617,21 @@ void __init paging_init(void)
  */
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
+ * After memory hotplug, the variables max_pfn, max_low_pfn and high_memory will
+ * be affected, they will be updated in this function.
+ */
+static void  update_end_of_memory_vars(u64 start, u64 size)
+{
+	unsigned long end_pfn = PFN_UP(start + size);
+
+	if (end_pfn > max_pfn) {
+		max_pfn = end_pfn;
+		max_low_pfn = end_pfn;
+		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
+	}
+}
+
+/*
  * Memory is added always to NORMAL zone. This means you will never get
  * additional DMA/DMA32 memory.
  */
@@ -634,6 +650,9 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
 
+	/* update max_pfn, max_low_pfn and high_memory */
+	update_end_of_memory_vars(start, size);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(arch_add_memory);
-- 
Thanks & Regards,
Shaohui


--/04w6evG8XlLl3ft
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="memory-hotplug-fix-the-bug-on-interface-dev-mem-v5.patch"

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
index 5198b9b..e1c9202 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -49,6 +49,7 @@
 #include <asm/numa.h>
 #include <asm/cacheflush.h>
 #include <asm/init.h>
+#include <linux/bootmem.h>
 
 static unsigned long dma_reserve __initdata;
 
@@ -616,6 +617,21 @@ void __init paging_init(void)
  */
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
+ * After memory hotplug, the variables max_pfn, max_low_pfn and high_memory will
+ * be affected, they will be updated in this function.
+ */
+static void  update_end_of_memory_vars(u64 start, u64 size)
+{
+	unsigned long end_pfn = PFN_UP(start + size);
+
+	if (end_pfn > max_pfn) {
+		max_pfn = end_pfn;
+		max_low_pfn = end_pfn;
+		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
+	}
+}
+
+/*
  * Memory is added always to NORMAL zone. This means you will never get
  * additional DMA/DMA32 memory.
  */
@@ -634,6 +650,9 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
 
+	/* update max_pfn, max_low_pfn and high_memory */
+	update_end_of_memory_vars(start, size);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(arch_add_memory);

--/04w6evG8XlLl3ft--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
