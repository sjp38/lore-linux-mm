Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 447AA82F6E
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:14 -0500 (EST)
Received: by pfnn128 with SMTP id n128so17231193pfn.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:14 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id iw2si15475147pac.46.2015.12.03.17.14.55
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:55 -0800 (PST)
Subject: [PATCH 22/34] x86, pkeys: dump PTE pkey in /proc/pid/smaps
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:54 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011454.9E6D5829@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The protection key can now be just as important as read/write
permissions on a VMA.  We need some debug mechanism to help
figure out if it is in play.  smaps seems like a logical
place to expose it.

arch/x86/kernel/setup.c is a bit of a weirdo place to put
this code, but it already had seq_file.h and there was not
a much better existing place to put it.

We also use no #ifdef.  If protection keys is .config'd out
we will get the same function as if we used the weak generic
function.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/kernel/setup.c |    9 +++++++++
 b/fs/proc/task_mmu.c      |    5 +++++
 2 files changed, 14 insertions(+)

diff -puN arch/x86/kernel/setup.c~pkeys-40-smaps arch/x86/kernel/setup.c
--- a/arch/x86/kernel/setup.c~pkeys-40-smaps	2015-12-03 16:21:28.284791859 -0800
+++ b/arch/x86/kernel/setup.c	2015-12-03 16:21:28.289792086 -0800
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
--- a/fs/proc/task_mmu.c~pkeys-40-smaps	2015-12-03 16:21:28.285791904 -0800
+++ b/fs/proc/task_mmu.c	2015-12-03 16:21:28.290792131 -0800
@@ -657,6 +657,10 @@ static int smaps_hugetlb_range(pte_t *pt
 }
 #endif /* HUGETLB_PAGE */
 
+void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
+{
+}
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
@@ -713,6 +717,7 @@ static int show_smap(struct seq_file *m,
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
