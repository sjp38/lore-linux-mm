From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070404230624.20292.32311.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
References: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/4] x86_64: SPARSE_VIRTUAL 2M page size support
Date: Wed,  4 Apr 2007 16:06:24 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Dave Hansen <hansendc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

x86_64 implement SPARSE_VIRTUAL

x86_64 is using 2M page table entries to map its 1-1 kernel space.
We implement the virtual memmap also using 2M page table entries.
So there is no difference at all to FLATMEM. Both schemes require
a page table and a TLB for each 2MB. FLATMEM still references memory
since the mem_map pointer itself a variable. SPARSE_VIRTUAL uses a
constant for vmemmap. Thus no memory reference. SPARSE_VIRTUAL should
be superior to even FLATMEM.

With this SPARSEMEM becomes the most efficient way of handling
virt_to_page, pfn_to_page and friends for UP, SMP and NUMA on
x86_64.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm4/include/asm-x86_64/page.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-x86_64/page.h	2007-04-03 18:41:06.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-x86_64/page.h	2007-04-03 18:41:59.000000000 -0700
@@ -128,6 +128,7 @@ extern unsigned long phys_base;
 	 VM_READ | VM_WRITE | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
 
 #define __HAVE_ARCH_GATE_AREA 1	
+#define vmemmap ((struct page *)0xffffe20000000000UL)
 
 #include <asm-generic/memory_model.h>
 #include <asm-generic/page.h>
Index: linux-2.6.21-rc5-mm4/Documentation/x86_64/mm.txt
===================================================================
--- linux-2.6.21-rc5-mm4.orig/Documentation/x86_64/mm.txt	2007-04-03 18:41:06.000000000 -0700
+++ linux-2.6.21-rc5-mm4/Documentation/x86_64/mm.txt	2007-04-03 18:41:59.000000000 -0700
@@ -9,6 +9,7 @@ ffff800000000000 - ffff80ffffffffff (=40
 ffff810000000000 - ffffc0ffffffffff (=46 bits) direct mapping of all phys. memory
 ffffc10000000000 - ffffc1ffffffffff (=40 bits) hole
 ffffc20000000000 - ffffe1ffffffffff (=45 bits) vmalloc/ioremap space
+ffffe20000000000 - ffffe2ffffffffff (=40 bits) virtual memory map
 ... unused hole ...
 ffffffff80000000 - ffffffff82800000 (=40 MB)   kernel text mapping, from phys 0
 ... unused hole ...
Index: linux-2.6.21-rc5-mm4/arch/x86_64/Kconfig
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/x86_64/Kconfig	2007-04-03 18:41:06.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/x86_64/Kconfig	2007-04-03 18:41:59.000000000 -0700
@@ -392,6 +392,12 @@ config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on (NUMA || EXPERIMENTAL)
 
+config SPARSE_VIRTUAL
+	def_bool y
+
+config ARCH_SUPPORTS_PMD_MAPPING
+	def_bool y
+
 config ARCH_MEMORY_PROBE
 	def_bool y
 	depends on MEMORY_HOTPLUG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
