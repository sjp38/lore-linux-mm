Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2276B029D
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:19:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id n12so1730958pgp.11
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:19:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor2083146pfh.73.2018.01.10.18.19.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:19:36 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 33/38] arm64: Implement thread_struct whitelist for hardened usercopy
Date: Wed, 10 Jan 2018 18:03:05 -0800
Message-Id: <1515636190-24061-34-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@kernel.org>, James Morse <james.morse@arm.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Dave Martin <Dave.Martin@arm.com>, zijun_hu <zijun_hu@htc.com>, linux-arm-kernel@lists.infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
index a93339f5178f..c84477e6a884 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -90,6 +90,7 @@ config ARM64
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
+	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select HAVE_ARCH_VMAP_STACK
diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index 023cacb946c3..e58a5864ec89 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -113,6 +113,14 @@ struct thread_struct {
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
