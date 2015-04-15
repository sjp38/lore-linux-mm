Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 820076B0070
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 10:17:12 -0400 (EDT)
Received: by wiax7 with SMTP id x7so113165580wia.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:17:12 -0700 (PDT)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id e1si8395000wja.52.2015.04.15.07.17.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 07:17:10 -0700 (PDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 15 Apr 2015 15:17:09 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7E3611B08072
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 15:17:41 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3FEH7xX9306508
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:17:07 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3FEH67D018343
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 08:17:07 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v5 3/3] powerpc/mm: Tracking vDSO remap
Date: Wed, 15 Apr 2015 16:16:58 +0200
Message-Id: <29c21a607c8083626e3ce9f4a19cb00b0205dbaa.1429104776.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
References: <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
References: <20150414123853.a3e61b7fa95b6c634e0fcce0@linux-foundation.org> <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@kernel.org>, linuxppc-dev@lists.ozlabs.org
Cc: cov@codeaurora.org, criu@openvz.org

Some processes (CRIU) are moving the vDSO area using the mremap system
call. As a consequence the kernel reference to the vDSO base address is
no more valid and the signal return frame built once the vDSO has been
moved is not pointing to the new sigreturn address.

This patch handles vDSO remapping and unmapping.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
---
 arch/powerpc/include/asm/mm-arch-hooks.h | 13 +++++++++++++
 arch/powerpc/include/asm/mmu_context.h   | 23 ++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/mm-arch-hooks.h b/arch/powerpc/include/asm/mm-arch-hooks.h
index 63091a19de9f..f2a2da895897 100644
--- a/arch/powerpc/include/asm/mm-arch-hooks.h
+++ b/arch/powerpc/include/asm/mm-arch-hooks.h
@@ -12,4 +12,17 @@
 #ifndef _ASM_POWERPC_MM_ARCH_HOOKS_H
 #define _ASM_POWERPC_MM_ARCH_HOOKS_H
 
+static inline void arch_remap(struct mm_struct *mm,
+			      unsigned long old_start, unsigned long old_end,
+			      unsigned long new_start, unsigned long new_end)
+{
+	/*
+	 * mremap() doesn't allow moving multiple vmas so we can limit the
+	 * check to old_start == vdso_base.
+	 */
+	if (old_start == mm->context.vdso_base)
+		mm->context.vdso_base = new_start;
+}
+#define arch_remap arch_remap
+
 #endif /* _ASM_POWERPC_MM_ARCH_HOOKS_H */
diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 73382eba02dc..825cb232eab6 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -8,7 +8,6 @@
 #include <linux/spinlock.h>
 #include <asm/mmu.h>	
 #include <asm/cputable.h>
-#include <asm-generic/mm_hooks.h>
 #include <asm/cputhreads.h>
 
 /*
@@ -109,5 +108,27 @@ static inline void enter_lazy_tlb(struct mm_struct *mm,
 #endif
 }
 
+static inline void arch_dup_mmap(struct mm_struct *oldmm,
+				 struct mm_struct *mm)
+{
+}
+
+static inline void arch_exit_mmap(struct mm_struct *mm)
+{
+}
+
+static inline void arch_unmap(struct mm_struct *mm,
+			      struct vm_area_struct *vma,
+			      unsigned long start, unsigned long end)
+{
+	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
+		mm->context.vdso_base = 0;
+}
+
+static inline void arch_bprm_mm_init(struct mm_struct *mm,
+				     struct vm_area_struct *vma)
+{
+}
+
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
