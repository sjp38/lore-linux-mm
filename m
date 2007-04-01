From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
Date: Sat, 31 Mar 2007 23:10:29 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

x86_64 make SPARSE_VIRTUAL the default

x86_64 is using 2M page table entries to map its 1-1 kernel space.
We implement the virtual memmap also using 2M page table entries.
So there is no difference at all to FLATMEM. Both schemes require
a page table and a TLB.

Thus the SPARSEMEM becomes the most efficient way of handling
virt_to_page, pfn_to_page and friends for UP, SMP and NUMA.

So change the Kconfig for x86_64 to make SPARSE_VIRTUAL the
default and switch off all other memory models.

Oh. And PFN_TO_PAGE used to be out of line. Since it is now
so simple switch it back to inline.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm2/arch/x86_64/Kconfig
===================================================================
--- linux-2.6.21-rc5-mm2.orig/arch/x86_64/Kconfig	2007-03-31 23:47:58.000000000 -0700
+++ linux-2.6.21-rc5-mm2/arch/x86_64/Kconfig	2007-03-31 23:48:41.000000000 -0700
@@ -380,25 +380,29 @@ config NUMA_EMU
 	  number of nodes. This is only useful for debugging.
 
 config ARCH_DISCONTIGMEM_ENABLE
-       bool
-       depends on NUMA
-       default y
+       def_bool n
 
 config ARCH_DISCONTIGMEM_DEFAULT
-	def_bool y
-	depends on NUMA
+	def_bool n
 
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
-	depends on (NUMA || EXPERIMENTAL)
+
+config SPARSEMEM_MANUAL
+	def_bool y
+
+config ARCH_SPARSE_VIRTUAL
+	def_bool y
+
+config SELECT_MEMORY_MODEL
+	def_bool n
 
 config ARCH_MEMORY_PROBE
 	def_bool y
 	depends on MEMORY_HOTPLUG
 
 config ARCH_FLATMEM_ENABLE
-	def_bool y
-	depends on !NUMA
+	def_bool n
 
 source "mm/Kconfig"
 
@@ -411,8 +415,7 @@ config HAVE_ARCH_EARLY_PFN_TO_NID
 	depends on NUMA
 
 config OUT_OF_LINE_PFN_TO_PAGE
-	def_bool y
-	depends on DISCONTIGMEM
+	def_bool n
 
 config NR_CPUS
 	int "Maximum number of CPUs (2-255)"
Index: linux-2.6.21-rc5-mm2/include/asm-x86_64/page.h
===================================================================
--- linux-2.6.21-rc5-mm2.orig/include/asm-x86_64/page.h	2007-03-31 23:47:58.000000000 -0700
+++ linux-2.6.21-rc5-mm2/include/asm-x86_64/page.h	2007-03-31 23:48:41.000000000 -0700
@@ -135,6 +135,7 @@ typedef struct { unsigned long pgprot; }
 	 VM_READ | VM_WRITE | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
 
 #define __HAVE_ARCH_GATE_AREA 1	
+#define vmemmap ((struct page *)0xffffe20000000000UL)
 
 #include <asm-generic/memory_model.h>
 #include <asm-generic/page.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
