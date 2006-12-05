Date: Tue, 5 Dec 2006 22:10:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] vmemmap on sparsemem v2 [5/5] optimzied pfn_valid
 support for ia64
Message-Id: <20061205221034.6bed736c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

USE_OPT_PFN_VALID support for ia64.
Because ia64 already has its own VIRTUAL_MEM_MAP handling,
This patch is simple.

When porting other archs, you have to add hook in page fault handler
and write a func like mapped_kernel_page_is_present() (ia64).

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 arch/ia64/Kconfig    |    4 ++++
 arch/ia64/mm/fault.c |    4 ++--
 2 files changed, 6 insertions(+), 2 deletions(-)

Index: devel-2.6.19-rc6-mm2/arch/ia64/Kconfig
===================================================================
--- devel-2.6.19-rc6-mm2.orig/arch/ia64/Kconfig	2006-12-05 20:41:55.000000000 +0900
+++ devel-2.6.19-rc6-mm2/arch/ia64/Kconfig	2006-12-05 20:45:34.000000000 +0900
@@ -349,6 +349,10 @@
 	def_bool y
 	depends on ARCH_SPARSEMEM_ENABLE
 
+config USE_OPT_PFN_VALID
+	def_bool y
+	depends on SPARSEMEM_VMEMMAP
+
 config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB)
 	depends on ARCH_DISCONTIGMEM_ENABLE
Index: devel-2.6.19-rc6-mm2/arch/ia64/mm/fault.c
===================================================================
--- devel-2.6.19-rc6-mm2.orig/arch/ia64/mm/fault.c	2006-12-05 20:41:55.000000000 +0900
+++ devel-2.6.19-rc6-mm2/arch/ia64/mm/fault.c	2006-12-05 20:45:34.000000000 +0900
@@ -103,7 +103,7 @@
 	if (in_atomic() || !mm)
 		goto no_context;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_USE_OPT_PFN_VALID)
 	/*
 	 * If fault is in region 5 and we are in the kernel, we may already
 	 * have the mmap_sem (pfn_valid macro is called during mmap). There
@@ -211,7 +211,7 @@
 
   bad_area:
 	up_read(&mm->mmap_sem);
-#ifdef CONFIG_VIRTUAL_MEM_MAP
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_SPARSEMEM_VMEMMAP)
   bad_area_no_up:
 #endif
 	if ((isr & IA64_ISR_SP)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
