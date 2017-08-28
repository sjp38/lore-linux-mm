Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC1196B04A8
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:43:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r62so2484843pfj.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:58 -0700 (PDT)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id 3si1045606plo.340.2017.08.28.14.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:43:57 -0700 (PDT)
Received: by mail-pg0-x236.google.com with SMTP id b8so4990956pgn.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:57 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 28/30] arm64: Implement thread_struct whitelist for hardened usercopy
Date: Mon, 28 Aug 2017 14:35:09 -0700
Message-Id: <1503956111-36652-29-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@kernel.org>, James Morse <james.morse@arm.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Dave Martin <Dave.Martin@arm.com>, zijun_hu <zijun_hu@htc.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>

This whitelists the FPU register state portion of the thread_struct for
copying to userspace, instead of the default entire structure.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: James Morse <james.morse@arm.com>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
Cc: Dave Martin <Dave.Martin@arm.com>
Cc: zijun_hu <zijun_hu@htc.com>
Cc: linux-arm-kernel@lists.infradead.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/arm64/Kconfig                 | 1 +
 arch/arm64/include/asm/processor.h | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index dfd908630631..b773299bc4e3 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -73,6 +73,7 @@ config ARM64
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
+	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select HAVE_ARM_SMCCC
diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index 64c9e78f9882..799f112e5ff7 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -90,6 +90,14 @@ struct thread_struct {
 	struct debug_info	debug;		/* debugging */
 };
 
+/* Whitelist the fpsimd_state for copying to userspace. */
+static inline void arch_thread_struct_whitelist(unsigned long *offset,
+						unsigned long *size)
+{
+	*offset = offsetof(struct thread_struct, fpsimd_state);
+	*size = sizeof(struct fpsimd_state);
+}
+
 #ifdef CONFIG_COMPAT
 #define task_user_tls(t)						\
 ({									\
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
