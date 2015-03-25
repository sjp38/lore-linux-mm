Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 109C46B006E
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:54:10 -0400 (EDT)
Received: by wixw10 with SMTP id w10so75102134wix.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:54:09 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id gt6si5219807wib.23.2015.03.25.06.54.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 06:54:08 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 25 Mar 2015 13:54:07 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4004E17D8056
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:54:33 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2PDs5h166650168
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:54:05 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2PDs2Gk003182
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 07:54:05 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
Date: Wed, 25 Mar 2015 14:53:52 +0100
Message-Id: <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
References: <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
References: <20150325121118.GA2542@gmail.com> <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: cov@codeaurora.org, criu@openvz.org

Some processes (CRIU) are moving the vDSO area using the mremap system
call. As a consequence the kernel reference to the vDSO base address is
no more valid and the signal return frame built once the vDSO has been
moved is not pointing to the new sigreturn address.

This patch handles vDSO remapping and unmapping.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/mmu_context.h | 36 +++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 73382eba02dc..7d315c1898d4 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -8,7 +8,6 @@
 #include <linux/spinlock.h>
 #include <asm/mmu.h>	
 #include <asm/cputable.h>
-#include <asm-generic/mm_hooks.h>
 #include <asm/cputhreads.h>
 
 /*
@@ -109,5 +108,40 @@ static inline void enter_lazy_tlb(struct mm_struct *mm,
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
+			struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
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
+#define __HAVE_ARCH_REMAP
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
