Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7VKopoh026472
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 16:50:51 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7VKopKL283730
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 14:50:51 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7VKopsU005971
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 14:50:51 -0600
Subject: Re: [RFC][PATCH 3/9] actual generic PAGE_SIZE infrastructure
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608301658130.5789@schroedinger.engr.sgi.com>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221606.40937644@localhost.localdomain>
	 <Pine.LNX.4.64.0608301658130.5789@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 31 Aug 2006 13:50:41 -0700
Message-Id: <1157057441.28577.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Here's the latest version I have, with much improved help text, thanks
to Christoph Lameter.

-----

* Add _ALIGN_UP() which we'll use now and _ALIGN_DOWN(), just for
  parity.
* Define ASM_CONST() macro to help using constants in both assembly
  and C code.  Several architectures have some form of this, and
  they will be consolidated around this one.
* Actually create PAGE_SHIFT and PAGE_SIZE macros
* For now, require that architectures enable GENERIC_PAGE_SIZE in
  order to get this new code.  This option will be removed by the
  last patch in the series, and makes the series bisect-safe.
* Note that this moves the compiler.h define outside of the
  #ifdef __KERNEL__, but that's OK because it has its own.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/asm-generic/page.h |   29 +++++++++++++++++-
 threadalloc-dave/mm/Kconfig                 |   44 ++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+), 2 deletions(-)

diff -puN include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure include/asm-generic/page.h
--- threadalloc/include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure	2006-08-31 13:48:45.000000000 -0700
+++ threadalloc-dave/include/asm-generic/page.h	2006-08-31 13:49:04.000000000 -0700
@@ -1,11 +1,36 @@
 #ifndef _ASM_GENERIC_PAGE_H
 #define _ASM_GENERIC_PAGE_H
 
+#include <linux/compiler.h>
+#include <linux/align.h>
+
 #ifdef __KERNEL__
-#ifndef __ASSEMBLY__
 
-#include <linux/compiler.h>
+#ifdef __ASSEMBLY__
+#define ASM_CONST(x) x
+#else
+#define __ASM_CONST(x) x##UL
+#define ASM_CONST(x) __ASM_CONST(x)
+#endif
+
+#ifdef CONFIG_ARCH_GENERIC_PAGE_SIZE
+
+#define PAGE_SHIFT      CONFIG_PAGE_SHIFT
+#define PAGE_SIZE       (ASM_CONST(1) << PAGE_SHIFT)
+
+/*
+ * Subtle: (1 << PAGE_SHIFT) is an int, not an unsigned long. So if we
+ * assign PAGE_MASK to a larger type it gets extended the way we want
+ * (i.e. with 1s in the high bits)
+ */
+#define PAGE_MASK      (~((1 << PAGE_SHIFT) - 1))
 
+/* to align the pointer to the (next) page boundary */
+#define PAGE_ALIGN(addr)        ALIGN(addr, PAGE_SIZE)
+
+#endif /* CONFIG_ARCH_GENERIC_PAGE_SIZE */
+
+#ifndef __ASSEMBLY__
 #ifndef CONFIG_ARCH_HAVE_GET_ORDER
 /* Pure 2^n version of get_order */
 static __inline__ __attribute_const__ int get_order(unsigned long size)
diff -puN mm/Kconfig~generic-PAGE_SIZE-infrastructure mm/Kconfig
--- threadalloc/mm/Kconfig~generic-PAGE_SIZE-infrastructure	2006-08-31 13:48:45.000000000 -0700
+++ threadalloc-dave/mm/Kconfig	2006-08-31 13:49:04.000000000 -0700
@@ -2,6 +2,50 @@ config ARCH_HAVE_GET_ORDER
 	def_bool y
 	depends on IA64 || PPC32 || XTENSA
 
+choice
+	prompt "Kernel page size"
+	depends on ARCH_GENERIC_PAGE_SIZE
+config PAGE_SIZE_4KB
+	bool "4KB"
+	help
+	  The kernel page size determines the basic chunk of memory handled
+	  by the Linux VM.  If these pages are larger, the kernel can
+	  use the same amount of physical memory with fewer data structures.
+	  This reduces the VM overhead in handling large amounts of data.
+	  Larger pages can also lead to better TLB coverage for large memory
+	  applications.
+
+	  However, larger pages also lead to memory being wasted by the
+	  kernel since all files require a minimum of one page of memory.
+	  With a 64KB page size, a 1 byte file will consume 64KB of memory.
+
+	  A 4KB pagesize is fairly standard and may be required for 32-bit
+	  compatibility on many platforms.
+
+	  It is usually not wise to select another page size than the default.
+
+config PAGE_SIZE_8KB
+	bool "8KB"
+config PAGE_SIZE_16KB
+	bool "16KB"
+config PAGE_SIZE_64KB
+	bool "64KB"
+config PAGE_SIZE_512KB
+	bool "512KB"
+config PAGE_SIZE_4MB
+	bool "4MB"
+endchoice
+
+config PAGE_SHIFT
+	int
+	depends on ARCH_GENERIC_PAGE_SIZE
+	default "13" if PAGE_SIZE_8KB
+	default "14" if PAGE_SIZE_16KB
+	default "16" if PAGE_SIZE_64KB
+	default "19" if PAGE_SIZE_512KB
+	default "22" if PAGE_SIZE_4MB
+	default "12"
+
 config SELECT_MEMORY_MODEL
 	def_bool y
 	depends on EXPERIMENTAL || ARCH_SELECT_MEMORY_MODEL
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
