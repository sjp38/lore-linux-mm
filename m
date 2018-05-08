Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 674286B0297
	for <linux-mm@kvack.org>; Tue,  8 May 2018 11:00:06 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bd7-v6so1921391plb.20
        for <linux-mm@kvack.org>; Tue, 08 May 2018 08:00:06 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id y14-v6si19511453pgo.286.2018.05.08.08.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 08:00:05 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 8/8] mm/pkeys, x86, powerpc: Display pkey in smaps if arch supports pkeys
Date: Wed,  9 May 2018 00:59:48 +1000
Message-Id: <20180508145948.9492-9-mpe@ellerman.id.au>
In-Reply-To: <20180508145948.9492-1-mpe@ellerman.id.au>
References: <20180508145948.9492-1-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

From: Ram Pai <linuxram@us.ibm.com>

Currently the architecture specific code is expected to display the
protection keys in smap for a given vma. This can lead to redundant
code and possibly to divergent formats in which the key gets
displayed.

This patch changes the implementation. It displays the pkey only if
the architecture support pkeys, i.e arch_pkeys_enabled() returns true.

x86 arch_show_smap() function is not needed anymore, delete it.

Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
[mpe: Split out from larger patch, rebased on header changes]
Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/x86/kernel/setup.c | 8 --------
 fs/proc/task_mmu.c      | 8 +++-----
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 5c623dfe39d1..2f86d883dd95 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1312,11 +1312,3 @@ static int __init register_kernel_offset_dumper(void)
 	return 0;
 }
 __initcall(register_kernel_offset_dumper);
-
-void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
-{
-	if (!boot_cpu_has(X86_FEATURE_OSPKE))
-		return;
-
-	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
-}
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c2163606e6fb..93cea7b07a80 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -18,6 +18,7 @@
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
 #include <linux/uaccess.h>
+#include <linux/pkeys.h>
 
 #include <asm/elf.h>
 #include <asm/tlb.h>
@@ -730,10 +731,6 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
 }
 #endif /* HUGETLB_PAGE */
 
-void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
-{
-}
-
 #define SEQ_PUT_DEC(str, val) \
 		seq_put_decimal_ull_width(m, str, (val) >> 10, 8)
 static int show_smap(struct seq_file *m, void *v, int is_pid)
@@ -838,7 +835,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		seq_puts(m, " kB\n");
 	}
 	if (!rollup_mode) {
-		arch_show_smap(m, vma);
+		if (arch_pkeys_enabled())
+			seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
 		show_smap_vma_flags(m, vma);
 	}
 	m_cache_vma(m, vma);
-- 
2.14.1
