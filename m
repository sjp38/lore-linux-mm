Message-Id: <20080503152801.230247205@symbol.fehenstaub.lan>
References: <20080503152502.191599824@symbol.fehenstaub.lan>
Date: Sat, 03 May 2008 17:25:04 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 2/2] x86: Enable rootmem allocator on X86_32
Content-Disposition: inline; filename=rootmem-migrate-x86_32.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Quick & dirty hack to use rootmem on the author's computer.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

Index: linux-2.6/arch/x86/kernel/setup_32.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/setup_32.c
+++ linux-2.6/arch/x86/kernel/setup_32.c
@@ -29,7 +29,7 @@
 #include <linux/acpi.h>
 #include <linux/apm_bios.h>
 #include <linux/initrd.h>
-#include <linux/bootmem.h>
+#include <linux/rootmem.h>
 #include <linux/seq_file.h>
 #include <linux/console.h>
 #include <linux/mca.h>
@@ -641,7 +641,9 @@ void __init setup_bootmem_allocator(void
 	/*
 	 * Initialize the boot-time allocator (with low memory only):
 	 */
-	bootmap_size = init_bootmem(min_low_pfn, max_low_pfn);
+	rootmem_register_node(0, 0, max_low_pfn);
+	bootmap_size = rootmem_map_pages() << PAGE_SHIFT;
+	rootmem_setup(min_low_pfn);
 
 	register_bootmem_low_pages(max_low_pfn);
 
Index: linux-2.6/arch/x86/mm/init_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/init_32.c
+++ linux-2.6/arch/x86/mm/init_32.c
@@ -585,7 +585,7 @@ void __init mem_init(void)
 	}
 #endif
 	/* this will put all low memory onto the freelists */
-	totalram_pages += free_all_bootmem();
+	totalram_pages += rootmem_release_node(0);
 
 	reservedpages = 0;
 	for (tmp = 0; tmp < max_low_pfn; tmp++)
Index: linux-2.6/arch/x86/Kconfig
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig
+++ linux-2.6/arch/x86/Kconfig
@@ -24,6 +24,7 @@ config X86
 	select HAVE_KRETPROBES
 	select HAVE_KVM if ((X86_32 && !X86_VOYAGER && !X86_VISWS && !X86_NUMAQ) || X86_64)
 	select HAVE_ARCH_KGDB if !X86_VOYAGER
+	select HAVE_ROOTMEM if X86_32
 
 config DEFCONFIG_LIST
 	string

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
