Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 811A96B0272
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:36:01 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 27so15762201pft.8
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:36:01 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z13si7690654pgo.335.2017.11.22.16.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:36:00 -0800 (PST)
Subject: [PATCH 08/23] x86, kaiser: map cpu entry area
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:34:53 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003453.D4CB33A9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

There is now a special 'struct cpu_entry' area that contains all
of the data needed to enter the kernel.  It's mapped in the fixmap
area and contains:

 * The GDT (hardware segment descriptor)
 * The TSS (thread information structure that points the hardware
   to the various stacks, and contains the entry stack).
 * The entry trampoline code itself
 * The exception stacks (aka IRQ stacks)

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com> 
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/kaiser.h |    6 ++++++
 b/arch/x86/kernel/cpu/common.c  |    4 ++++
 b/arch/x86/mm/kaiser.c          |   31 +++++++++++++++++++++++++++++++
 b/include/linux/kaiser.h        |    3 +++
 4 files changed, 44 insertions(+)

diff -puN arch/x86/include/asm/kaiser.h~kaiser-user-map-cpu-entry-structure arch/x86/include/asm/kaiser.h
--- a/arch/x86/include/asm/kaiser.h~kaiser-user-map-cpu-entry-structure	2017-11-22 15:45:48.447619740 -0800
+++ b/arch/x86/include/asm/kaiser.h	2017-11-22 15:45:48.456619740 -0800
@@ -34,6 +34,12 @@ extern int kaiser_add_mapping(unsigned l
 			      unsigned long flags);
 
 /**
+ *  kaiser_add_mapping_cpu_entry - map the cpu entry area
+ *  @cpu: the CPU for which the entry area is being mapped
+ */
+extern void kaiser_add_mapping_cpu_entry(int cpu);
+
+/**
  *  kaiser_remove_mapping - remove a kernel mapping from the userpage tables
  *  @addr: the start address of the range
  *  @size: the size of the range
diff -puN arch/x86/kernel/cpu/common.c~kaiser-user-map-cpu-entry-structure arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~kaiser-user-map-cpu-entry-structure	2017-11-22 15:45:48.449619740 -0800
+++ b/arch/x86/kernel/cpu/common.c	2017-11-22 15:45:48.457619740 -0800
@@ -4,6 +4,7 @@
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/percpu.h>
+#include <linux/kaiser.h>
 #include <linux/string.h>
 #include <linux/ctype.h>
 #include <linux/delay.h>
@@ -587,6 +588,9 @@ static inline void setup_cpu_entry_area(
 	__set_fixmap(get_cpu_entry_area_index(cpu, entry_trampoline),
 		     __pa_symbol(_entry_trampoline), PAGE_KERNEL_RX);
 #endif
+ 	/* CPU 0's mapping is done in kaiser_init() */
+	if (cpu)
+		kaiser_add_mapping_cpu_entry(cpu);
 }
 
 /* Load the original GDT from the per-cpu structure */
diff -puN arch/x86/mm/kaiser.c~kaiser-user-map-cpu-entry-structure arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-user-map-cpu-entry-structure	2017-11-22 15:45:48.451619740 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-22 15:45:48.457619740 -0800
@@ -353,6 +353,26 @@ static void __init kaiser_init_all_pgds(
 	WARN_ON(__ret);							\
 } while (0)
 
+void kaiser_add_mapping_cpu_entry(int cpu)
+{
+	kaiser_add_user_map_early(get_cpu_gdt_ro(cpu), PAGE_SIZE,
+				  __PAGE_KERNEL_RO);
+
+	/* includes the entry stack */
+	kaiser_add_user_map_early(&get_cpu_entry_area(cpu)->tss,
+				  sizeof(get_cpu_entry_area(cpu)->tss),
+				  __PAGE_KERNEL | _PAGE_GLOBAL);
+
+	/* Entry code, so needs to be EXEC */
+	kaiser_add_user_map_early(&get_cpu_entry_area(cpu)->entry_trampoline,
+				  sizeof(get_cpu_entry_area(cpu)->entry_trampoline),
+				  __PAGE_KERNEL_EXEC | _PAGE_GLOBAL);
+
+	kaiser_add_user_map_early(&get_cpu_entry_area(cpu)->exception_stacks,
+				 sizeof(get_cpu_entry_area(cpu)->exception_stacks),
+				 __PAGE_KERNEL | _PAGE_GLOBAL);
+}
+
 extern char __per_cpu_user_mapped_start[], __per_cpu_user_mapped_end[];
 /*
  * If anything in here fails, we will likely die on one of the
@@ -390,6 +410,17 @@ void __init kaiser_init(void)
 	kaiser_add_user_map_early((void *)idt_descr.address,
 				  sizeof(gate_desc) * NR_VECTORS,
 				  __PAGE_KERNEL_RO | _PAGE_GLOBAL);
+
+	/*
+	 * We delay CPU 0's mappings because these structures are
+	 * created before the page allocator is up.  Deferring it
+	 * until here lets us use the plain page allocator
+	 * unconditionally in the page table code above.
+	 *
+	 * This is OK because kaiser_init() is called long before
+	 * we ever run userspace and need the KAISER mappings.
+	 */
+	kaiser_add_mapping_cpu_entry(0);
 }
 
 int kaiser_add_mapping(unsigned long addr, unsigned long size,
diff -puN include/linux/kaiser.h~kaiser-user-map-cpu-entry-structure include/linux/kaiser.h
--- a/include/linux/kaiser.h~kaiser-user-map-cpu-entry-structure	2017-11-22 15:45:48.453619740 -0800
+++ b/include/linux/kaiser.h	2017-11-22 15:45:48.458619740 -0800
@@ -25,5 +25,8 @@ static inline int kaiser_add_mapping(uns
 	return 0;
 }
 
+static inline void kaiser_add_mapping_cpu_entry(int cpu)
+{
+}
 #endif /* !CONFIG_KAISER */
 #endif /* _INCLUDE_KAISER_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
