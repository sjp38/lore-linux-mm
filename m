From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070424180052.22005.61762.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070424180032.22005.82088.sendpatchset@skynet.skynet.ie>
References: <20070424180032.22005.82088.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/2] Handle kernelcore= boot parameter in common code to avoid boot problem on IA64
Date: Tue, 24 Apr 2007 19:00:52 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, y-goto@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

When "kernelcore" boot option is specified, kernel can't boot up on ia64
because of an infinite loop.  In addition, the parsing code can be handled
in an architecture-independent manner.

This patch patches uses common code to handle the kernelcore= parameter.
It is only available to architectures that support arch-independent
zone-sizing (i.e. define CONFIG_ARCH_POPULATES_NODE_MAP). Other architectures
will ignore the boot parameter.

This effectively removes the following arch-specific patches;

ia64-specify-amount-of-kernel-memory-at-boot-time.patch
ppc-and-powerpc-specify-amount-of-kernel-memory-at-boot-time.patch
x86_64-specify-amount-of-kernel-memory-at-boot-time.patch
x86-specify-amount-of-kernel-memory-at-boot-time.patch


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 arch/i386/kernel/setup.c   |    1 -
 arch/ia64/kernel/efi.c     |    2 --
 arch/powerpc/kernel/prom.c |    1 -
 arch/ppc/mm/init.c         |    2 --
 arch/x86_64/kernel/e820.c  |    1 -
 include/linux/mm.h         |    1 -
 mm/page_alloc.c            |    4 +++-
 7 files changed, 3 insertions(+), 9 deletions(-)

Index: kernelcore/arch/ia64/kernel/efi.c
===================================================================
--- kernelcore.orig/arch/ia64/kernel/efi.c	2007-04-24 15:09:37.000000000 +0900
+++ kernelcore/arch/ia64/kernel/efi.c	2007-04-24 15:25:22.000000000 +0900
@@ -423,8 +423,6 @@ efi_init (void)
 			mem_limit = memparse(cp + 4, &cp);
 		} else if (memcmp(cp, "max_addr=", 9) == 0) {
 			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
-		} else if (memcmp(cp, "kernelcore=",11) == 0) {
-			cmdline_parse_kernelcore(cp+11);
 		} else if (memcmp(cp, "min_addr=", 9) == 0) {
 			min_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
 		} else {
Index: kernelcore/arch/i386/kernel/setup.c
===================================================================
--- kernelcore.orig/arch/i386/kernel/setup.c	2007-04-24 15:29:20.000000000 +0900
+++ kernelcore/arch/i386/kernel/setup.c	2007-04-24 15:29:39.000000000 +0900
@@ -195,7 +195,6 @@ static int __init parse_mem(char *arg)
 	return 0;
 }
 early_param("mem", parse_mem);
-early_param("kernelcore", cmdline_parse_kernelcore);
 
 #ifdef CONFIG_PROC_VMCORE
 /* elfcorehdr= specifies the location of elf core header
Index: kernelcore/arch/powerpc/kernel/prom.c
===================================================================
--- kernelcore.orig/arch/powerpc/kernel/prom.c	2007-04-24 15:04:47.000000000 +0900
+++ kernelcore/arch/powerpc/kernel/prom.c	2007-04-24 15:30:25.000000000 +0900
@@ -431,7 +431,6 @@ static int __init early_parse_mem(char *
 	return 0;
 }
 early_param("mem", early_parse_mem);
-early_param("kernelcore", cmdline_parse_kernelcore);
 
 /*
  * The device tree may be allocated below our memory limit, or inside the
Index: kernelcore/arch/ppc/mm/init.c
===================================================================
--- kernelcore.orig/arch/ppc/mm/init.c	2007-04-24 15:04:47.000000000 +0900
+++ kernelcore/arch/ppc/mm/init.c	2007-04-24 15:30:56.000000000 +0900
@@ -214,8 +214,6 @@ void MMU_setup(void)
 	}
 }
 
-early_param("kernelcore", cmdline_parse_kernelcore);
-
 /*
  * MMU_init sets up the basic memory mappings for the kernel,
  * including both RAM and possibly some I/O regions,
Index: kernelcore/arch/x86_64/kernel/e820.c
===================================================================
--- kernelcore.orig/arch/x86_64/kernel/e820.c	2007-04-24 15:04:47.000000000 +0900
+++ kernelcore/arch/x86_64/kernel/e820.c	2007-04-24 15:34:02.000000000 +0900
@@ -604,7 +604,6 @@ static int __init parse_memopt(char *p)
 	return 0;
 } 
 early_param("mem", parse_memopt);
-early_param("kernelcore", cmdline_parse_kernelcore);
 
 static int userdef __initdata;
 
Index: kernelcore/include/linux/mm.h
===================================================================
--- kernelcore.orig/include/linux/mm.h	2007-04-24 15:09:37.000000000 +0900
+++ kernelcore/include/linux/mm.h	2007-04-24 15:35:52.000000000 +0900
@@ -1051,7 +1051,6 @@ extern unsigned long find_max_pfn_with_a
 extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
-extern int cmdline_parse_kernelcore(char *p);
 #ifndef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
 extern int early_pfn_to_nid(unsigned long pfn);
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
Index: kernelcore/mm/page_alloc.c
===================================================================
--- kernelcore.orig/mm/page_alloc.c	2007-04-24 15:09:37.000000000 +0900
+++ kernelcore/mm/page_alloc.c	2007-04-24 16:00:21.000000000 +0900
@@ -3728,6 +3728,9 @@ int __init cmdline_parse_kernelcore(char
 
 	return 0;
 }
+
+early_param("kernelcore", cmdline_parse_kernelcore);
+
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
 /**


-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
