Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDF2C6B0261
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:20:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so169251561pfe.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:20:43 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 141si10765711pfx.22.2016.04.28.08.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 08:20:43 -0700 (PDT)
From: Christopher Covington <cov@codeaurora.org>
Subject: [RFC 4/5] arm64: Use unsigned long for vdso
Date: Thu, 28 Apr 2016 11:18:56 -0400
Message-Id: <1461856737-17071-5-git-send-email-cov@codeaurora.org>
In-Reply-To: <1461856737-17071-1-git-send-email-cov@codeaurora.org>
References: <20151202121918.GA4523@arm.com>
 <1461856737-17071-1-git-send-email-cov@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, criu@openvz.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Will Deacon <Will.Deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Christopher Covington <cov@codeaurora.org>

In order to get AArch64 remap and unmap support for the VDSO, like PowerPC
and x86 have, without duplicating the code, we need a common name and type
for the address of the VDSO. An informal survey of the architectures
indicates unsigned long vdso is popular. Change the type in arm64 to be
unsigned long, which has the added benefit of dropping a few typecasts.

Signed-off-by: Christopher Covington <cov@codeaurora.org>
---
 arch/arm64/include/asm/mmu.h | 2 +-
 arch/arm64/kernel/vdso.c     | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/include/asm/mmu.h b/arch/arm64/include/asm/mmu.h
index 990124a..a67352f 100644
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
index 97bc68f..e742b1d 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -96,7 +96,7 @@ int aarch32_setup_vectors_page(struct linux_binprm *bprm, int uses_interp)
 	void *ret;
 
 	down_write(&mm->mmap_sem);
-	current->mm->context.vdso = (void *)addr;
+	current->mm->context.vdso = addr;
 
 	/* Map vectors page at the high address. */
 	ret = _install_special_mapping(mm, addr, PAGE_SIZE,
@@ -176,7 +176,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 		goto up_fail;
 
 	vdso_base += PAGE_SIZE;
-	mm->context.vdso = (void *)vdso_base;
+	mm->context.vdso = vdso_base;
 	ret = _install_special_mapping(mm, vdso_base, vdso_text_len,
 				       VM_READ|VM_EXEC|
 				       VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
@@ -189,7 +189,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	return 0;
 
 up_fail:
-	mm->context.vdso = NULL;
+	mm->context.vdso = 0;
 	up_write(&mm->mmap_sem);
 	return PTR_ERR(ret);
 }
-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
