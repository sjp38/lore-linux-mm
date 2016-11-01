Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 863696B02AB
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 13:11:14 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id uc5so72251596pab.4
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:11:14 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id j185si31511467pgd.305.2016.11.01.10.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 10:11:13 -0700 (PDT)
From: Christopher Covington <cov@codeaurora.org>
Subject: [RFC v2 3/7] arm64: Use unsigned long for VDSO
Date: Tue,  1 Nov 2016 11:10:57 -0600
Message-Id: <20161101171101.24704-3-cov@codeaurora.org>
In-Reply-To: <20161101171101.24704-1-cov@codeaurora.org>
References: <20161101171101.24704-1-cov@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Christopher Covington <cov@codeaurora.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

Use an unsigned long type for the base address of the VDSO in order to be
compatible with the new generic VDSO remap and unmap functions originating
from PowerPC and now also used by 32-bit ARM.

Signed-off-by: Christopher Covington <cov@codeaurora.org>
---
 arch/arm64/include/asm/mmu.h | 2 +-
 arch/arm64/kernel/vdso.c     | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/include/asm/mmu.h b/arch/arm64/include/asm/mmu.h
index 8d9fce0..5b00198 100644
--- a/arch/arm64/include/asm/mmu.h
+++ b/arch/arm64/include/asm/mmu.h
@@ -18,7 +18,7 @@
 
 typedef struct {
 	atomic64_t	id;
-	void		*vdso;
+	unsigned long	vdso;
 } mm_context_t;
 
 /*
diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index a2c2478..4b10e72 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -97,7 +97,7 @@ int aarch32_setup_vectors_page(struct linux_binprm *bprm, int uses_interp)
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
-	current->mm->context.vdso = (void *)addr;
+	current->mm->context.vdso = addr;
 
 	/* Map vectors page at the high address. */
 	ret = _install_special_mapping(mm, addr, PAGE_SIZE,
@@ -178,7 +178,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 		goto up_fail;
 
 	vdso_base += PAGE_SIZE;
-	mm->context.vdso = (void *)vdso_base;
+	mm->context.vdso = vdso_base;
 	ret = _install_special_mapping(mm, vdso_base, vdso_text_len,
 				       VM_READ|VM_EXEC|
 				       VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
@@ -191,7 +191,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	return 0;
 
 up_fail:
-	mm->context.vdso = NULL;
+	mm->context.vdso = 0;
 	up_write(&mm->mmap_sem);
 	return PTR_ERR(ret);
 }
-- 
Qualcomm Datacenter Technologies as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
