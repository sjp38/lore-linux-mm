Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76E18440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o7so9928317pgc.23
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:31 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u10si8985120pgr.576.2017.11.10.11.31.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:29 -0800 (PST)
Subject: [PATCH 07/30] x86, kaiser: mark per-cpu data structures required for entry/exit
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:10 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193110.FE358CF5@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


These patches are based on work from a team at Graz University of
Technology posted here: https://github.com/IAIK/KAISER

The KAISER approach keeps two copies of the page tables: one for running
in the kernel and one for running userspace.  But, there are a few
structures that are needed for switching in and out of the kernel and
a good subset of *those* are per-cpu data.

Here's a short summary of the things mapped to userspace:
 * The gdt_page's virtual address is pointed to by the LGDT instruction.
   It is needed to define the segments.  Deeply required by CPU to run.
 * cpu_tss tells the CPU, among other things, where the new stacks are
   after user<->kernel transitions.  Needed by the CPU to make ring
   transitions.
 * exception_stacks are needed at interrupt and exception entry
   so that there is storage for, among other things, some temporary
   space to permit clobbering a register to load the kernel CR3.

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

 b/arch/x86/include/asm/desc.h      |    2 +-
 b/arch/x86/include/asm/processor.h |    2 +-
 b/arch/x86/kernel/cpu/common.c     |    4 ++--
 b/arch/x86/kernel/process.c        |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff -puN arch/x86/include/asm/desc.h~kaiser-prep-x86-percpu-user-mapped arch/x86/include/asm/desc.h
--- a/arch/x86/include/asm/desc.h~kaiser-prep-x86-percpu-user-mapped	2017-11-10 11:22:08.376244951 -0800
+++ b/arch/x86/include/asm/desc.h	2017-11-10 11:22:08.385244951 -0800
@@ -45,7 +45,7 @@ struct gdt_page {
 	struct desc_struct gdt[GDT_ENTRIES];
 } __attribute__((aligned(PAGE_SIZE)));
 
-DECLARE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page);
+DECLARE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct gdt_page, gdt_page);
 
 /* Provide the original GDT */
 static inline struct desc_struct *get_cpu_gdt_rw(unsigned int cpu)
diff -puN arch/x86/include/asm/processor.h~kaiser-prep-x86-percpu-user-mapped arch/x86/include/asm/processor.h
--- a/arch/x86/include/asm/processor.h~kaiser-prep-x86-percpu-user-mapped	2017-11-10 11:22:08.378244951 -0800
+++ b/arch/x86/include/asm/processor.h	2017-11-10 11:22:08.386244951 -0800
@@ -346,7 +346,7 @@ struct tss_struct {
 	unsigned long		SYSENTER_stack[64];
 } ____cacheline_aligned;
 
-DECLARE_PER_CPU_SHARED_ALIGNED(struct tss_struct, cpu_tss);
+DECLARE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct tss_struct, cpu_tss);
 
 /*
  * sizeof(unsigned long) coming from an extra "long" at the end
diff -puN arch/x86/kernel/cpu/common.c~kaiser-prep-x86-percpu-user-mapped arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~kaiser-prep-x86-percpu-user-mapped	2017-11-10 11:22:08.380244951 -0800
+++ b/arch/x86/kernel/cpu/common.c	2017-11-10 11:22:08.386244951 -0800
@@ -98,7 +98,7 @@ static const struct cpu_dev default_cpu
 
 static const struct cpu_dev *this_cpu = &default_cpu;
 
-DEFINE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page) = { .gdt = {
+DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct gdt_page, gdt_page) = { .gdt = {
 #ifdef CONFIG_X86_64
 	/*
 	 * We need valid kernel segments for data and code in long mode too
@@ -1343,7 +1343,7 @@ static const unsigned int exception_stac
 	  [DEBUG_STACK - 1]			= DEBUG_STKSZ
 };
 
-static DEFINE_PER_CPU_PAGE_ALIGNED(char, exception_stacks
+DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(char, exception_stacks
 	[(N_EXCEPTION_STACKS - 1) * EXCEPTION_STKSZ + DEBUG_STKSZ]);
 
 /* May not be marked __init: used by software suspend */
diff -puN arch/x86/kernel/process.c~kaiser-prep-x86-percpu-user-mapped arch/x86/kernel/process.c
--- a/arch/x86/kernel/process.c~kaiser-prep-x86-percpu-user-mapped	2017-11-10 11:22:08.382244951 -0800
+++ b/arch/x86/kernel/process.c	2017-11-10 11:22:08.387244951 -0800
@@ -46,7 +46,7 @@
  * section. Since TSS's are completely CPU-local, we want them
  * on exact cacheline boundaries, to eliminate cacheline ping-pong.
  */
-__visible DEFINE_PER_CPU_SHARED_ALIGNED(struct tss_struct, cpu_tss) = {
+__visible DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct tss_struct, cpu_tss) = {
 	.x86_tss = {
 		/*
 		 * .sp0 is only used when entering ring 0 from a lower
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
