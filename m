Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 97C1F82F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:24:33 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so85373099pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:24:33 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pg2si30752755pbb.36.2015.09.28.12.18.24
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:25 -0700 (PDT)
Subject: [PATCH 18/25] x86, pkeys: dump PTE pkey in /proc/pid/smaps
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:24 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191824.891DA5DC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


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
--- a/arch/x86/kernel/setup.c~pkeys-40-smaps	2015-09-28 11:39:49.106326520 -0700
+++ b/arch/x86/kernel/setup.c	2015-09-28 11:39:49.111326748 -0700
@@ -111,6 +111,7 @@
 #include <asm/mce.h>
 #include <asm/alternative.h>
 #include <asm/prom.h>
+#include <asm/special_insns.h>
 
 /*
  * max_low_pfn_mapped: highest direct mapped pfn under 4GB
@@ -1264,3 +1265,11 @@ static int __init register_kernel_offset
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
--- a/fs/proc/task_mmu.c~pkeys-40-smaps	2015-09-28 11:39:49.107326566 -0700
+++ b/fs/proc/task_mmu.c	2015-09-28 11:39:49.112326793 -0700
@@ -625,6 +625,10 @@ static void show_smap_vma_flags(struct s
 	seq_putc(m, '\n');
 }
 
+void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
+{
+}
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
@@ -674,6 +678,7 @@ static int show_smap(struct seq_file *m,
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
