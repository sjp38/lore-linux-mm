Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 088B96B0009
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:53:13 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id l27so2613648qkj.1
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 15:53:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v68sor470937qkv.39.2018.02.21.15.53.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 15:53:12 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v12 3/3] mm, x86, powerpc: display pkey in smaps only if arch supports pkeys
Date: Wed, 21 Feb 2018 15:52:18 -0800
Message-Id: <1519257138-23797-4-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
References: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

Currently the  architecture  specific code is expected to
display  the  protection  keys  in  smap  for a given vma.
This can lead to redundant code and possibly to divergent
formats in which the key gets displayed.

This  patch  changes  the implementation. It displays the
pkey only if the architecture support pkeys, i.e
arch_pkeys_enabled() returns true.  This patch
provides x86 implementation for arch_pkeys_enabled().

x86 arch_show_smap() function is not needed anymore.
Deleting it.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Michael Ellermen <mpe@ellerman.id.au>
cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
(fixed compilation errors for x86 configs)
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/mmu_context.h |    5 -----
 arch/x86/include/asm/mmu_context.h     |    5 -----
 arch/x86/include/asm/pkeys.h           |    1 +
 arch/x86/kernel/fpu/xstate.c           |    5 +++++
 arch/x86/kernel/setup.c                |    8 --------
 fs/proc/task_mmu.c                     |   10 +++++-----
 include/linux/pkeys.h                  |    7 ++++++-
 7 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 051b3d6..566b3c2 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -203,11 +203,6 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 #define thread_pkey_regs_restore(new_thread, old_thread)
 #define thread_pkey_regs_init(thread)
 
-static inline int vma_pkey(struct vm_area_struct *vma)
-{
-	return 0;
-}
-
 static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
 {
 	return 0x0UL;
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index c931b88..134f3a0 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -294,11 +294,6 @@ static inline int vma_pkey(struct vm_area_struct *vma)
 
 	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
 }
-#else
-static inline int vma_pkey(struct vm_area_struct *vma)
-{
-	return 0;
-}
 #endif
 
 /*
diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index a0ba1ff..f6c287b 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -6,6 +6,7 @@
 
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
+extern bool arch_pkeys_enabled(void);
 
 /*
  * Try to dedicate one of the protection keys to be used as an
diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
index 87a57b7..4f566e9 100644
--- a/arch/x86/kernel/fpu/xstate.c
+++ b/arch/x86/kernel/fpu/xstate.c
@@ -945,6 +945,11 @@ int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 
 	return 0;
 }
+
+bool arch_pkeys_enabled(void)
+{
+	return boot_cpu_has(X86_FEATURE_OSPKE);
+}
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 /*
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 1ae67e9..d0539e3 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1314,11 +1314,3 @@ static int __init register_kernel_offset_dumper(void)
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
index 6d83bb7..70aa912 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -18,10 +18,12 @@
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
 #include <linux/uaccess.h>
+#include <linux/pkeys.h>
 
 #include <asm/elf.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
+#include <asm/mmu_context.h>
 #include "internal.h"
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
@@ -733,10 +735,6 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
 }
 #endif /* HUGETLB_PAGE */
 
-void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
-{
-}
-
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct proc_maps_private *priv = m->private;
@@ -856,9 +854,11 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
 
 	if (!rollup_mode) {
-		arch_show_smap(m, vma);
+		if (arch_pkeys_enabled())
+			seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
 		show_smap_vma_flags(m, vma);
 	}
+
 	m_cache_vma(m, vma);
 	return ret;
 }
diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index 0794ca7..49dff15 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -3,7 +3,6 @@
 #define _LINUX_PKEYS_H
 
 #include <linux/mm_types.h>
-#include <asm/mmu_context.h>
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
 #include <asm/pkeys.h>
@@ -13,6 +12,7 @@
 #define arch_override_mprotect_pkey(vma, prot, pkey) (0)
 #define PKEY_DEDICATED_EXECUTE_ONLY 0
 #define ARCH_VM_PKEY_FLAGS 0
+#define vma_pkey(vma) 0
 
 static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
@@ -35,6 +35,11 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	return 0;
 }
 
+static inline bool arch_pkeys_enabled(void)
+{
+	return false;
+}
+
 static inline void copy_init_pkru_to_fpregs(void)
 {
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
