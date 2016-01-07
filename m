Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 00C32828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:07:03 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id cy9so243321538pac.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:07:02 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rm12si3964873pab.225.2016.01.06.16.01.36
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:36 -0800 (PST)
Subject: [PATCH 22/31] x86, pkeys: dump pkey from VMA in /proc/pid/smaps
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:36 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000136.F4A284DF@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, vbabka@suse.cz


From: Dave Hansen <dave.hansen@linux.intel.com>

The protection key can now be just as important as read/write
permissions on a VMA.  We need some debug mechanism to help
figure out if it is in play.  smaps seems like a logical
place to expose it.

arch/x86/kernel/setup.c is a bit of a weirdo place to put
this code, but it already had seq_file.h and there was not
a much better existing place to put it.

We also use no #ifdef.  If protection keys is .config'd out we
will effectively get the same function as if we used the weak
generic function.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: vbabka@suse.cz
---

 b/arch/x86/kernel/setup.c |    9 +++++++++
 b/fs/proc/task_mmu.c      |   14 ++++++++++++++
 2 files changed, 23 insertions(+)

diff -puN arch/x86/kernel/setup.c~pkeys-40-smaps arch/x86/kernel/setup.c
--- a/arch/x86/kernel/setup.c~pkeys-40-smaps	2016-01-06 15:50:12.674474474 -0800
+++ b/arch/x86/kernel/setup.c	2016-01-06 15:50:12.679474700 -0800
@@ -112,6 +112,7 @@
 #include <asm/alternative.h>
 #include <asm/prom.h>
 #include <asm/microcode.h>
+#include <asm/mmu_context.h>
 
 /*
  * max_low_pfn_mapped: highest direct mapped pfn under 4GB
@@ -1282,3 +1283,11 @@ static int __init register_kernel_offset
 	return 0;
 }
 __initcall(register_kernel_offset_dumper);
+
+void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
+{
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return;
+
+	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
+}
diff -puN fs/proc/task_mmu.c~pkeys-40-smaps fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~pkeys-40-smaps	2016-01-06 15:50:12.675474519 -0800
+++ b/fs/proc/task_mmu.c	2016-01-06 15:50:12.679474700 -0800
@@ -615,11 +615,20 @@ static void show_smap_vma_flags(struct s
 		[ilog2(VM_MERGEABLE)]	= "mg",
 		[ilog2(VM_UFFD_MISSING)]= "um",
 		[ilog2(VM_UFFD_WP)]	= "uw",
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+		/* These come out via ProtectionKey: */
+		[ilog2(VM_PKEY_BIT0)]	= "",
+		[ilog2(VM_PKEY_BIT1)]	= "",
+		[ilog2(VM_PKEY_BIT2)]	= "",
+		[ilog2(VM_PKEY_BIT3)]	= "",
+#endif
 	};
 	size_t i;
 
 	seq_puts(m, "VmFlags: ");
 	for (i = 0; i < BITS_PER_LONG; i++) {
+		if (!mnemonics[i][0])
+			continue;
 		if (vma->vm_flags & (1UL << i)) {
 			seq_printf(m, "%c%c ",
 				   mnemonics[i][0], mnemonics[i][1]);
@@ -657,6 +666,10 @@ static int smaps_hugetlb_range(pte_t *pt
 }
 #endif /* HUGETLB_PAGE */
 
+void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
+{
+}
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
@@ -713,6 +726,7 @@ static int show_smap(struct seq_file *m,
 		   (vma->vm_flags & VM_LOCKED) ?
 			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
 
+	arch_show_smap(m, vma);
 	show_smap_vma_flags(m, vma);
 	m_cache_vma(m, vma);
 	return 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
