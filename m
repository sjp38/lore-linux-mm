Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D791F440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:45 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s11so3765406pgc.13
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:45 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h1si9064025pgc.417.2017.11.10.11.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:44 -0800 (PST)
Subject: [PATCH 12/30] x86, kaiser: map GDT into user page tables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:25 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193125.EBF58596@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The GDT is used to control the x86 segmentation mechanism.  It
must be virtually mapped when switching segments or at IRET
time when switching between userspace and kernel.

The original KAISER patch did not do this.  I have no idea how
it ever worked.

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

 b/arch/x86/kernel/cpu/common.c |   15 +++++++++++++++
 b/arch/x86/mm/kaiser.c         |   10 ++++++++++
 2 files changed, 25 insertions(+)

diff -puN arch/x86/kernel/cpu/common.c~kaiser-user-map-gdt-pages arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~kaiser-user-map-gdt-pages	2017-11-10 11:22:11.559244943 -0800
+++ b/arch/x86/kernel/cpu/common.c	2017-11-10 11:22:11.564244943 -0800
@@ -5,6 +5,7 @@
 #include <linux/export.h>
 #include <linux/percpu.h>
 #include <linux/string.h>
+#include <linux/kaiser.h>
 #include <linux/ctype.h>
 #include <linux/delay.h>
 #include <linux/sched/mm.h>
@@ -487,6 +488,20 @@ static inline void setup_fixmap_gdt(int
 #endif
 
 	__set_fixmap(get_cpu_gdt_ro_index(cpu), get_cpu_gdt_paddr(cpu), prot);
+
+	/* CPU 0's mapping is done in kaiser_init() */
+	if (cpu) {
+		int ret;
+
+		ret = kaiser_add_mapping((unsigned long) get_cpu_gdt_ro(cpu),
+					 PAGE_SIZE, __PAGE_KERNEL_RO);
+		/*
+		 * We do not have a good way to fail CPU bringup.
+		 * Just WARN about it and hope we boot far enough
+		 * to get a good log out.
+		 */
+		WARN_ON(ret);
+	}
 }
 
 /* Load the original GDT from the per-cpu structure */
diff -puN arch/x86/mm/kaiser.c~kaiser-user-map-gdt-pages arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-user-map-gdt-pages	2017-11-10 11:22:11.560244943 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-10 11:22:11.565244943 -0800
@@ -372,6 +372,16 @@ void __init kaiser_init(void)
 	kaiser_add_user_map_early((void *)idt_descr.address,
 				  sizeof(gate_desc) * NR_VECTORS,
 				  __PAGE_KERNEL_RO | _PAGE_GLOBAL);
+
+	/*
+	 * We could theoretically do this in setup_fixmap_gdt().
+	 * But, we would need to rewrite the above page table
+	 * allocation code to use the bootmem allocator.  The
+	 * buddy allocator is not available at the time that we
+	 * call setup_fixmap_gdt() for CPU 0.
+	 */
+	kaiser_add_user_map_early(get_cpu_gdt_ro(0), PAGE_SIZE,
+				  __PAGE_KERNEL_RO | _PAGE_GLOBAL);
 }
 
 int kaiser_add_mapping(unsigned long addr, unsigned long size,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
