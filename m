Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0A146B0268
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:31:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z80so387615pff.11
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:31:59 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o11si2599032pgd.473.2017.10.31.15.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:31:58 -0700 (PDT)
Subject: [PATCH 06/23] x86, kaiser: introduce user-mapped percpu areas
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:31:58 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223158.A60B4068@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


These patches are based on work from a team at Graz University of
Technology posted here: https://github.com/IAIK/KAISER

The KAISER approach keeps two copies of the page tables: one for running
in the kernel and one for running userspace.  But, there are a few
structures that are needed for switching in and out of the kernel and
a good subset of *those* are per-cpu data.

This patch creates a new kind of per-cpu data that is mapped and can be
used no matter which copy of the page tables we are using.

Thanks to Hugh Dickins for cleanups to this code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/desc.h       |    2 +-
 b/arch/x86/include/asm/hw_irq.h     |    2 +-
 b/arch/x86/include/asm/processor.h  |    2 +-
 b/arch/x86/kernel/cpu/common.c      |    4 ++--
 b/arch/x86/kernel/irqinit.c         |    2 +-
 b/arch/x86/kernel/process.c         |    2 +-
 b/include/asm-generic/vmlinux.lds.h |    7 +++++++
 b/include/linux/percpu-defs.h       |   32 +++++++++++++++++++++++++++++++-
 8 files changed, 45 insertions(+), 8 deletions(-)

diff -puN arch/x86/include/asm/desc.h~kaiser-prep-user-mapped-percpu arch/x86/include/asm/desc.h
--- a/arch/x86/include/asm/desc.h~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.046146272 -0700
+++ b/arch/x86/include/asm/desc.h	2017-10-31 15:03:51.066147217 -0700
@@ -45,7 +45,7 @@ struct gdt_page {
 	struct desc_struct gdt[GDT_ENTRIES];
 } __attribute__((aligned(PAGE_SIZE)));
 
-DECLARE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page);
+DECLARE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct gdt_page, gdt_page);
 
 /* Provide the original GDT */
 static inline struct desc_struct *get_cpu_gdt_rw(unsigned int cpu)
diff -puN arch/x86/include/asm/hw_irq.h~kaiser-prep-user-mapped-percpu arch/x86/include/asm/hw_irq.h
--- a/arch/x86/include/asm/hw_irq.h~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.048146366 -0700
+++ b/arch/x86/include/asm/hw_irq.h	2017-10-31 15:03:51.066147217 -0700
@@ -160,7 +160,7 @@ extern char irq_entries_start[];
 #define VECTOR_RETRIGGERED	((void *)~0UL)
 
 typedef struct irq_desc* vector_irq_t[NR_VECTORS];
-DECLARE_PER_CPU(vector_irq_t, vector_irq);
+DECLARE_PER_CPU_USER_MAPPED(vector_irq_t, vector_irq);
 
 #endif /* !ASSEMBLY_ */
 
diff -puN arch/x86/include/asm/processor.h~kaiser-prep-user-mapped-percpu arch/x86/include/asm/processor.h
--- a/arch/x86/include/asm/processor.h~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.051146508 -0700
+++ b/arch/x86/include/asm/processor.h	2017-10-31 15:03:51.067147264 -0700
@@ -348,7 +348,7 @@ struct tss_struct {
 
 } ____cacheline_aligned;
 
-DECLARE_PER_CPU_SHARED_ALIGNED(struct tss_struct, cpu_tss);
+DECLARE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct tss_struct, cpu_tss);
 
 /*
  * sizeof(unsigned long) coming from an extra "long" at the end
diff -puN arch/x86/kernel/cpu/common.c~kaiser-prep-user-mapped-percpu arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.053146603 -0700
+++ b/arch/x86/kernel/cpu/common.c	2017-10-31 15:03:51.067147264 -0700
@@ -98,7 +98,7 @@ static const struct cpu_dev default_cpu
 
 static const struct cpu_dev *this_cpu = &default_cpu;
 
-DEFINE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page) = { .gdt = {
+DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct gdt_page, gdt_page) = { .gdt = {
 #ifdef CONFIG_X86_64
 	/*
 	 * We need valid kernel segments for data and code in long mode too
@@ -1345,7 +1345,7 @@ static const unsigned int exception_stac
 	  [DEBUG_STACK - 1]			= DEBUG_STKSZ
 };
 
-static DEFINE_PER_CPU_PAGE_ALIGNED(char, exception_stacks
+DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(char, exception_stacks
 	[(N_EXCEPTION_STACKS - 1) * EXCEPTION_STKSZ + DEBUG_STKSZ]);
 
 /* May not be marked __init: used by software suspend */
diff -puN arch/x86/kernel/irqinit.c~kaiser-prep-user-mapped-percpu arch/x86/kernel/irqinit.c
--- a/arch/x86/kernel/irqinit.c~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.055146697 -0700
+++ b/arch/x86/kernel/irqinit.c	2017-10-31 15:03:51.068147312 -0700
@@ -51,7 +51,7 @@ static struct irqaction irq2 = {
 	.flags = IRQF_NO_THREAD,
 };
 
-DEFINE_PER_CPU(vector_irq_t, vector_irq) = {
+DEFINE_PER_CPU_USER_MAPPED(vector_irq_t, vector_irq) = {
 	[0 ... NR_VECTORS - 1] = VECTOR_UNUSED,
 };
 
diff -puN arch/x86/kernel/process.c~kaiser-prep-user-mapped-percpu arch/x86/kernel/process.c
--- a/arch/x86/kernel/process.c~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.057146792 -0700
+++ b/arch/x86/kernel/process.c	2017-10-31 15:03:51.068147312 -0700
@@ -46,7 +46,7 @@
  * section. Since TSS's are completely CPU-local, we want them
  * on exact cacheline boundaries, to eliminate cacheline ping-pong.
  */
-__visible DEFINE_PER_CPU_SHARED_ALIGNED(struct tss_struct, cpu_tss) = {
+__visible DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct tss_struct, cpu_tss) = {
 	.x86_tss = {
 		.sp0 = TOP_OF_INIT_STACK,
 #ifdef CONFIG_X86_32
diff -puN include/asm-generic/vmlinux.lds.h~kaiser-prep-user-mapped-percpu include/asm-generic/vmlinux.lds.h
--- a/include/asm-generic/vmlinux.lds.h~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.059146886 -0700
+++ b/include/asm-generic/vmlinux.lds.h	2017-10-31 15:03:51.068147312 -0700
@@ -807,7 +807,14 @@
  */
 #define PERCPU_INPUT(cacheline)						\
 	VMLINUX_SYMBOL(__per_cpu_start) = .;				\
+	VMLINUX_SYMBOL(__per_cpu_user_mapped_start) = .;		\
 	*(.data..percpu..first)						\
+	. = ALIGN(cacheline);						\
+	*(.data..percpu..user_mapped)					\
+	*(.data..percpu..user_mapped..shared_aligned)			\
+	. = ALIGN(PAGE_SIZE);						\
+	*(.data..percpu..user_mapped..page_aligned)			\
+	VMLINUX_SYMBOL(__per_cpu_user_mapped_end) = .;			\
 	. = ALIGN(PAGE_SIZE);						\
 	*(.data..percpu..page_aligned)					\
 	. = ALIGN(cacheline);						\
diff -puN include/linux/percpu-defs.h~kaiser-prep-user-mapped-percpu include/linux/percpu-defs.h
--- a/include/linux/percpu-defs.h~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.062147028 -0700
+++ b/include/linux/percpu-defs.h	2017-10-31 15:03:51.069147359 -0700
@@ -35,6 +35,12 @@
 
 #endif
 
+#ifdef CONFIG_KAISER
+#define USER_MAPPED_SECTION "..user_mapped"
+#else
+#define USER_MAPPED_SECTION ""
+#endif
+
 /*
  * Base implementations of per-CPU variable declarations and definitions, where
  * the section in which the variable is to be placed is provided by the
@@ -115,6 +121,12 @@
 #define DEFINE_PER_CPU(type, name)					\
 	DEFINE_PER_CPU_SECTION(type, name, "")
 
+#define DECLARE_PER_CPU_USER_MAPPED(type, name)				\
+	DECLARE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION)
+
+#define DEFINE_PER_CPU_USER_MAPPED(type, name)				\
+	DEFINE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION)
+
 /*
  * Declaration/definition used for per-CPU variables that must come first in
  * the set of variables.
@@ -144,6 +156,14 @@
 	DEFINE_PER_CPU_SECTION(type, name, PER_CPU_SHARED_ALIGNED_SECTION) \
 	____cacheline_aligned_in_smp
 
+#define DECLARE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(type, name)		\
+	DECLARE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION PER_CPU_SHARED_ALIGNED_SECTION) \
+	____cacheline_aligned_in_smp
+
+#define DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(type, name)		\
+	DEFINE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION PER_CPU_SHARED_ALIGNED_SECTION) \
+	____cacheline_aligned_in_smp
+
 #define DECLARE_PER_CPU_ALIGNED(type, name)				\
 	DECLARE_PER_CPU_SECTION(type, name, PER_CPU_ALIGNED_SECTION)	\
 	____cacheline_aligned
@@ -162,11 +182,21 @@
 #define DEFINE_PER_CPU_PAGE_ALIGNED(type, name)				\
 	DEFINE_PER_CPU_SECTION(type, name, "..page_aligned")		\
 	__aligned(PAGE_SIZE)
+/*
+ * Declaration/definition used for per-CPU variables that must be page aligned and need to be mapped in user mode.
+ */
+#define DECLARE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(type, name)		\
+	DECLARE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION"..page_aligned") \
+	__aligned(PAGE_SIZE)
+
+#define DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(type, name)		\
+	DEFINE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION"..page_aligned") \
+	__aligned(PAGE_SIZE)
 
 /*
  * Declaration/definition used for per-CPU variables that must be read mostly.
  */
-#define DECLARE_PER_CPU_READ_MOSTLY(type, name)			\
+#define DECLARE_PER_CPU_READ_MOSTLY(type, name)				\
 	DECLARE_PER_CPU_SECTION(type, name, "..read_mostly")
 
 #define DEFINE_PER_CPU_READ_MOSTLY(type, name)				\
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
