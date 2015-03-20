Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 639206B006C
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 11:53:41 -0400 (EDT)
Received: by wggv3 with SMTP id v3so92929451wgg.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 08:53:40 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id dk4si3731820wib.95.2015.03.20.08.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 08:53:39 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 20 Mar 2015 15:53:38 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 37CA8219005F
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:53:26 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2KFraXH7668124
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:53:36 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2KFrXBC005569
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:53:36 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm: Introducing arch_remap hook
Date: Fri, 20 Mar 2015 16:53:27 +0100
Message-Id: <503499aae380db1c4673f146bcba6ad095021257.1426866405.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1426866405.git.ldufour@linux.vnet.ibm.com>
References: <cover.1426866405.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1426866405.git.ldufour@linux.vnet.ibm.com>
References: <cover.1426866405.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: cov@codeaurora.org, criu@openvz.org

Some architecture would like to be triggered when a memory area is moved
through the mremap system call.

This patch is introducing a new arch_remap mm hook which is placed in the
path of mremap, and is called before the old area is unmapped (and the
arch_unmap hook is called).

To no break the build, this patch adds the empty hook definition to the
architectures that were not using the generic hook's definition.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/s390/include/asm/mmu_context.h      | 6 ++++++
 arch/um/include/asm/mmu_context.h        | 5 +++++
 arch/unicore32/include/asm/mmu_context.h | 6 ++++++
 arch/x86/include/asm/mmu_context.h       | 6 ++++++
 include/asm-generic/mm_hooks.h           | 6 ++++++
 mm/mremap.c                              | 9 +++++++--
 6 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/arch/s390/include/asm/mmu_context.h b/arch/s390/include/asm/mmu_context.h
index 8fb3802f8fad..ddd861a490ba 100644
--- a/arch/s390/include/asm/mmu_context.h
+++ b/arch/s390/include/asm/mmu_context.h
@@ -131,4 +131,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 {
 }
 
+static inline void arch_remap(struct mm_struct *mm,
+			      unsigned long old_start, unsigned long old_end,
+			      unsigned long new_start, unsigned long new_end)
+{
+}
+
 #endif /* __S390_MMU_CONTEXT_H */
diff --git a/arch/um/include/asm/mmu_context.h b/arch/um/include/asm/mmu_context.h
index 941527e507f7..f499b017c1f9 100644
--- a/arch/um/include/asm/mmu_context.h
+++ b/arch/um/include/asm/mmu_context.h
@@ -27,6 +27,11 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 				     struct vm_area_struct *vma)
 {
 }
+static inline void arch_remap(struct mm_struct *mm,
+			      unsigned long old_start, unsigned long old_end,
+			      unsigned long new_start, unsigned long new_end)
+{
+}
 /*
  * end asm-generic/mm_hooks.h functions
  */
diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
index 1cb5220afaf9..39a0a553172e 100644
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -97,4 +97,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 {
 }
 
+static inline void arch_remap(struct mm_struct *mm,
+			      unsigned long old_start, unsigned long old_end,
+			      unsigned long new_start, unsigned long new_end)
+{
+}
+
 #endif
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 883f6b933fa4..75cb71f4be1e 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -172,4 +172,10 @@ static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		mpx_notify_unmap(mm, vma, start, end);
 }
 
+static inline void arch_remap(struct mm_struct *mm,
+			      unsigned long old_start, unsigned long old_end,
+			      unsigned long new_start, unsigned long new_end)
+{
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff --git a/include/asm-generic/mm_hooks.h b/include/asm-generic/mm_hooks.h
index 866aa461efa5..e507f4783a5b 100644
--- a/include/asm-generic/mm_hooks.h
+++ b/include/asm-generic/mm_hooks.h
@@ -26,4 +26,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 {
 }
 
+static inline void arch_remap(struct mm_struct *mm,
+			      unsigned long old_start, unsigned long old_end,
+			      unsigned long new_start, unsigned long new_end)
+{
+}
+
 #endif	/* _ASM_GENERIC_MM_HOOKS_H */
diff --git a/mm/mremap.c b/mm/mremap.c
index 57dadc025c64..6a409ca09425 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -25,6 +25,7 @@
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
+#include <asm/mmu_context.h>
 
 #include "internal.h"
 
@@ -286,8 +287,12 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_len = new_len;
 		old_addr = new_addr;
 		new_addr = -ENOMEM;
-	} else if (vma->vm_file && vma->vm_file->f_op->mremap)
-		vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
+	} else {
+		if (vma->vm_file && vma->vm_file->f_op->mremap)
+			vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
+		arch_remap(mm, old_addr, old_addr+old_len,
+			   new_addr, new_addr+new_len);
+	}
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
 	if (vm_flags & VM_ACCOUNT) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
