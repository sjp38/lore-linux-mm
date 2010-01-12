Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D640E6B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:34:59 -0500 (EST)
Date: Tue, 12 Jan 2010 10:33:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel(v1)
Message-ID: <20100112023307.GA16661@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com> <20100108124851.GB6153@localhost> <DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com> <20100111124303.GA21408@localhost> <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 08:30:31AM +0800, KAMEZAWA Hiroyuki wrote:
> On Mon, 11 Jan 2010 20:43:03 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > > > +	/* if add to low memory, update max_low_pfn */
> > > > +	if (unlikely(start_pfn < limit_low_pfn)) {
> > > > +		if (end_pfn <= limit_low_pfn)
> > > > +			max_low_pfn = end_pfn;
> > > > +		else
> > > > +			max_low_pfn = limit_low_pfn;
> > > 
> > > X86_64 actually always set max_low_pfn=max_pfn, in setup_arch():
> > > [Zheng, Shaohui] there should be some misunderstanding, I read the
> > > code carefully, if the total memory is under 4G, it always
> > > max_low_pfn=max_pfn. If the total memory is larger than 4G,
> > > max_low_pfn means the end of low ram. It set
> > 
> > > max_low_pfn = e820_end_of_low_ram_pfn();.
> > 
> > The above line is very misleading.. In setup_arch(), it will be
> > overrode by the following block.
> > 
> 
> Hmmm....could you rewrite /dev/mem to use kernel/resource.c other than
> modifing e820 maps. ?
> Two reasons.
>   - e820map is considerted to be stable, read-only after boot.
>   - We don't need to add more x86 special codes.

Sure, here it is :)
---
x86: use the generic page_is_ram()

The generic resource based page_is_ram() works better with memory
hotplug/hotremove. So switch the x86 e820map based code to it.

CC: Andi Kleen <andi@firstfloor.org> 
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 arch/x86/include/asm/page_types.h |    1 
 arch/x86/mm/ioremap.c             |   37 ----------------------------
 kernel/resource.c                 |   17 ++++++++++++
 3 files changed, 17 insertions(+), 38 deletions(-)

--- linux-mm.orig/arch/x86/include/asm/page_types.h	2010-01-12 10:31:01.000000000 +0800
+++ linux-mm/arch/x86/include/asm/page_types.h	2010-01-12 10:31:44.000000000 +0800
@@ -34,19 +34,18 @@
 
 #ifdef CONFIG_X86_64
 #include <asm/page_64_types.h>
 #else
 #include <asm/page_32_types.h>
 #endif	/* CONFIG_X86_64 */
 
 #ifndef __ASSEMBLY__
 
-extern int page_is_ram(unsigned long pagenr);
 extern int devmem_is_allowed(unsigned long pagenr);
 
 extern unsigned long max_low_pfn_mapped;
 extern unsigned long max_pfn_mapped;
 
 extern unsigned long init_memory_mapping(unsigned long start,
 					 unsigned long end);
 
 extern void initmem_init(unsigned long start_pfn, unsigned long end_pfn,
--- linux-mm.orig/arch/x86/mm/ioremap.c	2010-01-12 10:31:01.000000000 +0800
+++ linux-mm/arch/x86/mm/ioremap.c	2010-01-12 10:31:44.000000000 +0800
@@ -18,55 +18,18 @@
 #include <asm/e820.h>
 #include <asm/fixmap.h>
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>
 #include <asm/pat.h>
 
 #include "physaddr.h"
 
-int page_is_ram(unsigned long pagenr)
-{
-	resource_size_t addr, end;
-	int i;
-
-	/*
-	 * A special case is the first 4Kb of memory;
-	 * This is a BIOS owned area, not kernel ram, but generally
-	 * not listed as such in the E820 table.
-	 */
-	if (pagenr == 0)
-		return 0;
-
-	/*
-	 * Second special case: Some BIOSen report the PC BIOS
-	 * area (640->1Mb) as ram even though it is not.
-	 */
-	if (pagenr >= (BIOS_BEGIN >> PAGE_SHIFT) &&
-		    pagenr < (BIOS_END >> PAGE_SHIFT))
-		return 0;
-
-	for (i = 0; i < e820.nr_map; i++) {
-		/*
-		 * Not usable memory:
-		 */
-		if (e820.map[i].type != E820_RAM)
-			continue;
-		addr = (e820.map[i].addr + PAGE_SIZE-1) >> PAGE_SHIFT;
-		end = (e820.map[i].addr + e820.map[i].size) >> PAGE_SHIFT;
-
-
-		if ((pagenr >= addr) && (pagenr < end))
-			return 1;
-	}
-	return 0;
-}
-
 /*
  * Fix up the linear direct mapping of the kernel to avoid cache attribute
  * conflicts.
  */
 int ioremap_change_attr(unsigned long vaddr, unsigned long size,
 			       unsigned long prot_val)
 {
 	unsigned long nrpages = size >> PAGE_SHIFT;
 	int err;
--- linux-mm.orig/kernel/resource.c	2010-01-12 10:31:01.000000000 +0800
+++ linux-mm/kernel/resource.c	2010-01-12 10:31:44.000000000 +0800
@@ -298,18 +298,35 @@ int walk_system_ram_range(unsigned long 
 #endif
 
 static int __is_ram(unsigned long pfn, unsigned long nr_pages, void *arg)
 {
 	return 24;
 }
 
 int __attribute__((weak)) page_is_ram(unsigned long pfn)
 {
+#ifdef CONFIG_X86
+	/*
+	 * A special case is the first 4Kb of memory;
+	 * This is a BIOS owned area, not kernel ram, but generally
+	 * not listed as such in the E820 table.
+	 */
+	if (pfn == 0)
+		return 0;
+
+	/*
+	 * Second special case: Some BIOSen report the PC BIOS
+	 * area (640->1Mb) as ram even though it is not.
+	 */
+	if (pfn >= (BIOS_BEGIN >> PAGE_SHIFT) &&
+	    pfn <  (BIOS_END   >> PAGE_SHIFT))
+		return 0;
+#endif
 	return 24 == walk_system_ram_range(pfn, 1, NULL, __is_ram);
 }
 
 /*
  * Find empty slot in the resource tree given range and alignment.
  */
 static int find_resource(struct resource *root, struct resource *new,
 			 resource_size_t size, resource_size_t min,
 			 resource_size_t max, resource_size_t align,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
