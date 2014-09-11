Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 000B26B0037
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:54:05 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so12846127pdj.6
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:54:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id v3si274639pds.170.2014.09.11.01.54.04
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 01:54:05 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v8 01/10] x86, mpx: introduce VM_MPX to indicate that a VMA is MPX specific
Date: Thu, 11 Sep 2014 16:46:41 +0800
Message-Id: <1410425210-24789-2-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qiaowei Ren <qiaowei.ren@intel.com>

MPX-enabled application will possibly create a lot of bounds tables
in process address space to save bounds information. These tables
can take up huge swaths of memory (as much as 80% of the memory on
the system) even if we clean them up aggressively. Being this huge,
we need a way to track their memory use. If we want to track them,
we essentially have two options:

1. walk the multi-GB (in virtual space) bounds directory to locate
   all the VMAs and walk them
2. Find a way to distinguish MPX bounds-table VMAs from normal
   anonymous VMAs and use some existing mechanism to walk them

We expect (1) will be prohibitively expensive. For (2), we only
need a single bit, and we've chosen to use a VM_ flag.  We understand
that they are scarce and are open to other options.

There is one potential hybrid approach: check the bounds directory
entry for any anonymous VMA that could possibly contain a bounds table.
This is less expensive than (1), but still requires reading a pointer
out of userspace for every VMA that we iterate over.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 fs/proc/task_mmu.c |    1 +
 include/linux/mm.h |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfc791c..cc31520 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -549,6 +549,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_GROWSDOWN)]	= "gd",
 		[ilog2(VM_PFNMAP)]	= "pf",
 		[ilog2(VM_DENYWRITE)]	= "dw",
+		[ilog2(VM_MPX)]		= "mp",
 		[ilog2(VM_LOCKED)]	= "lo",
 		[ilog2(VM_IO)]		= "io",
 		[ilog2(VM_SEQ_READ)]	= "sr",
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc8..942be8a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -127,6 +127,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
+#define VM_ARCH_2	0x02000000
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
@@ -154,6 +155,11 @@ extern unsigned int kobjsize(const void *objp);
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
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
