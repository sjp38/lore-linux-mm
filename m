Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C51CC6B00D1
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 10:18:27 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so17551755pab.5
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 07:18:27 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id kl11si28657792pbd.55.2014.11.14.07.18.25
        for <linux-mm@kvack.org>;
        Fri, 14 Nov 2014 07:18:26 -0800 (PST)
Subject: [PATCH 06/11] x86, mpx: introduce VM_MPX to indicate that a VMA is MPX specific
From: Dave Hansen <dave@sr71.net>
Date: Fri, 14 Nov 2014 07:18:25 -0800
References: <20141114151816.F56A3072@viggo.jf.intel.com>
In-Reply-To: <20141114151816.F56A3072@viggo.jf.intel.com>
Message-Id: <20141114151825.565625B3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

MPX-enabled applications using large swaths of memory can
potentially have large numbers of bounds tables in process
address space to save bounds information. These tables can take
up huge swaths of memory (as much as 80% of the memory on the
system) even if we clean them up aggressively. In the worst-case
scenario, the tables can be 4x the size of the data structure
being tracked. IOW, a 1-page structure can require 4 bounds-table
pages.

Being this huge, our expectation is that folks using MPX are
going to be keen on figuring out how much memory is being
dedicated to it. So we need a way to track memory use for MPX.

If we want to specifically track MPX VMAs we need to be able to
distinguish them from normal VMAs, and keep them from getting
merged with normal VMAs. A new VM_ flag set only on MPX VMAs does
both of those things. With this flag, MPX bounds-table VMAs can
be distinguished from other VMAs, and userspace can also walk
/proc/$pid/smaps to get memory usage for MPX.

In addition to this flag, we also introduce a special ->vm_ops
specific to MPX VMAs (see the patch "add MPX specific mmap
interface"), but currently different ->vm_ops do not by
themselves prevent VMA merging, so we still need this flag.

We understand that VM_ flags are scarce and are open to other
options.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/fs/proc/task_mmu.c |    3 +++
 b/include/linux/mm.h |    6 ++++++
 2 files changed, 9 insertions(+)

diff -puN fs/proc/task_mmu.c~mpx-v11-introduce-VM-MPX-to-indicate-that-a-VMA-is-MPX-specific fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~mpx-v11-introduce-VM-MPX-to-indicate-that-a-VMA-is-MPX-specific	2014-11-14 07:06:22.670627067 -0800
+++ b/fs/proc/task_mmu.c	2014-11-14 07:06:22.676627338 -0800
@@ -552,6 +552,9 @@ static void show_smap_vma_flags(struct s
 		[ilog2(VM_GROWSDOWN)]	= "gd",
 		[ilog2(VM_PFNMAP)]	= "pf",
 		[ilog2(VM_DENYWRITE)]	= "dw",
+#ifdef CONFIG_X86_INTEL_MPX
+		[ilog2(VM_MPX)]		= "mp",
+#endif
 		[ilog2(VM_LOCKED)]	= "lo",
 		[ilog2(VM_IO)]		= "io",
 		[ilog2(VM_SEQ_READ)]	= "sr",
diff -puN include/linux/mm.h~mpx-v11-introduce-VM-MPX-to-indicate-that-a-VMA-is-MPX-specific include/linux/mm.h
--- a/include/linux/mm.h~mpx-v11-introduce-VM-MPX-to-indicate-that-a-VMA-is-MPX-specific	2014-11-14 07:06:22.672627157 -0800
+++ b/include/linux/mm.h	2014-11-14 07:06:22.676627338 -0800
@@ -128,6 +128,7 @@ extern unsigned int kobjsize(const void
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
+#define VM_ARCH_2	0x02000000
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
@@ -155,6 +156,11 @@ extern unsigned int kobjsize(const void
 # define VM_MAPPED_COPY	VM_ARCH_1	/* T if mapped copy of data (nommu mmap) */
 #endif
 
+#if defined(CONFIG_X86)
+/* MPX specific bounds table or bounds directory */
+# define VM_MPX		VM_ARCH_2
+#endif
+
 #ifndef VM_GROWSUP
 # define VM_GROWSUP	VM_NONE
 #endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
