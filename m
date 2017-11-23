Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6F7C6B026B
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:35:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q187so1384130pga.6
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:35:53 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b5si14373512pgr.120.2017.11.22.16.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:35:52 -0800 (PST)
Subject: [PATCH 04/23] x86, kaiser: mark per-cpu data structures required for entry/exit
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:34:45 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003445.DF9EA351@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

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
--- a/arch/x86/include/asm/desc.h~kaiser-prep-x86-percpu-user-mapped	2017-11-22 15:45:45.913619747 -0800
+++ b/arch/x86/include/asm/desc.h	2017-11-22 15:45:45.923619747 -0800
@@ -46,7 +46,7 @@ struct gdt_page {
 	struct desc_struct gdt[GDT_ENTRIES];
 } __attribute__((aligned(PAGE_SIZE)));
 
-DECLARE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page);
+DECLARE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct gdt_page, gdt_page);
 
 /* Provide the original GDT */
 static inline struct desc_struct *get_cpu_gdt_rw(unsigned int cpu)
diff -puN arch/x86/include/asm/processor.h~kaiser-prep-x86-percpu-user-mapped arch/x86/include/asm/processor.h
--- a/arch/x86/include/asm/processor.h~kaiser-prep-x86-percpu-user-mapped	2017-11-22 15:45:45.915619747 -0800
+++ b/arch/x86/include/asm/processor.h	2017-11-22 15:45:45.923619747 -0800
@@ -356,7 +356,7 @@ struct tss_struct {
 	unsigned long		io_bitmap[IO_BITMAP_LONGS + 1];
 } __attribute__((__aligned__(PAGE_SIZE)));
 
-DECLARE_PER_CPU_PAGE_ALIGNED(struct tss_struct, cpu_tss);
+DECLARE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct tss_struct, cpu_tss);
 
 /*
  * sizeof(unsigned long) coming from an extra "long" at the end
diff -puN arch/x86/kernel/cpu/common.c~kaiser-prep-x86-percpu-user-mapped arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~kaiser-prep-x86-percpu-user-mapped	2017-11-22 15:45:45.917619747 -0800
+++ b/arch/x86/kernel/cpu/common.c	2017-11-22 15:45:45.924619747 -0800
@@ -98,7 +98,7 @@ static const struct cpu_dev default_cpu
 
 static const struct cpu_dev *this_cpu = &default_cpu;
 
-DEFINE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page) = { .gdt = {
+DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct gdt_page, gdt_page) = { .gdt = {
 #ifdef CONFIG_X86_64
 	/*
 	 * We need valid kernel segments for data and code in long mode too
@@ -517,7 +517,7 @@ static const unsigned int exception_stac
 	  [DEBUG_STACK - 1]			= DEBUG_STKSZ
 };
 
-static DEFINE_PER_CPU_PAGE_ALIGNED(char, exception_stacks
+DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(char, exception_stacks
 	[(N_EXCEPTION_STACKS - 1) * EXCEPTION_STKSZ + DEBUG_STKSZ]);
 #endif
 
diff -puN arch/x86/kernel/process.c~kaiser-prep-x86-percpu-user-mapped arch/x86/kernel/process.c
--- a/arch/x86/kernel/process.c~kaiser-prep-x86-percpu-user-mapped	2017-11-22 15:45:45.919619747 -0800
+++ b/arch/x86/kernel/process.c	2017-11-22 15:45:45.924619747 -0800
@@ -47,7 +47,7 @@
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
