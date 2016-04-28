Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0FC06B0260
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:20:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so169951215pfb.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:20:41 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id ef2si12194156pac.119.2016.04.28.08.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 08:20:40 -0700 (PDT)
From: Christopher Covington <cov@codeaurora.org>
Subject: [RFC 3/5] mm/powerpc: Make VDSO remap generic
Date: Thu, 28 Apr 2016 11:18:55 -0400
Message-Id: <1461856737-17071-4-git-send-email-cov@codeaurora.org>
In-Reply-To: <1461856737-17071-1-git-send-email-cov@codeaurora.org>
References: <20151202121918.GA4523@arm.com>
 <1461856737-17071-1-git-send-email-cov@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, criu@openvz.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Will Deacon <Will.Deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Christopher Covington <cov@codeaurora.org>

In order to support remapping the VDSO on additional architectures without
duplicating code, move the remap code out from arch/powerpc. Architectures
that wish to use the generic logic must have an unsigned long vdso in
mm->context and can opt in by selecting CONFIG_ARCH_WANT_VDSO_MAP. This
allows PowerPC to use mm-arch-hooks.h from include/asm-generic.

Signed-off-by: Christopher Covington <cov@codeaurora.org>
---
 arch/powerpc/include/asm/Kbuild          |  1 +
 arch/powerpc/include/asm/mm-arch-hooks.h | 28 ----------------------------
 mm/mremap.c                              | 10 ++++++++--
 3 files changed, 9 insertions(+), 30 deletions(-)
 delete mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h

diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index ab9f4e0..9dbb372 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -7,3 +7,4 @@ generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += vtime.h
+generic-y += mm-arch-hooks.h
diff --git a/arch/powerpc/include/asm/mm-arch-hooks.h b/arch/powerpc/include/asm/mm-arch-hooks.h
deleted file mode 100644
index ea6da89..0000000
--- a/arch/powerpc/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,28 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_POWERPC_MM_ARCH_HOOKS_H
-#define _ASM_POWERPC_MM_ARCH_HOOKS_H
-
-static inline void arch_remap(struct mm_struct *mm,
-			      unsigned long old_start, unsigned long old_end,
-			      unsigned long new_start, unsigned long new_end)
-{
-	/*
-	 * mremap() doesn't allow moving multiple vmas so we can limit the
-	 * check to old_start == vdso.
-	 */
-	if (old_start == mm->context.vdso)
-		mm->context.vdso = new_start;
-}
-#define arch_remap arch_remap
-
-#endif /* _ASM_POWERPC_MM_ARCH_HOOKS_H */
diff --git a/mm/mremap.c b/mm/mremap.c
index 3fa0a467..59032b7 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -293,8 +293,14 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_addr = new_addr;
 		new_addr = err;
 	} else {
-		arch_remap(mm, old_addr, old_addr + old_len,
-			   new_addr, new_addr + new_len);
+#ifdef CONFIG_ARCH_WANT_VDSO_MAP
+		/*
+		 * mremap() doesn't allow moving multiple vmas so we can limit the
+		 * check to old_addr == vdso.
+		 */
+		if (old_addr == mm->context.vdso)
+			mm->context.vdso = new_addr;
+#endif  /* CONFIG_ARCH_WANT_VDSO_MAP */
 	}
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
