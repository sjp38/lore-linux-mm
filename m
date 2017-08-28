Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0E1F6B04B3
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:53:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k3so2544557pfc.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:53:53 -0700 (PDT)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id w75si979639pfi.513.2017.08.28.14.53.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:53:52 -0700 (PDT)
Received: by mail-pg0-x232.google.com with SMTP id y15so5120766pgc.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:53:52 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 27/30] x86: Implement thread_struct whitelist for hardened usercopy
Date: Mon, 28 Aug 2017 14:35:08 -0700
Message-Id: <1503956111-36652-28-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Mathias Krause <minipli@googlemail.com>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>

This whitelists the FPU register state portion of the thread_struct for
copying to userspace, instead of the default entire struct.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/x86/Kconfig                 | 1 +
 arch/x86/include/asm/processor.h | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 781521b7cf9e..a8793721483c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -113,6 +113,7 @@ config X86
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
 	select HAVE_ARCH_COMPAT_MMAP_BASES	if MMU && COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
+	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD if X86_64
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 028245e1c42b..dc52ba90f090 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -481,6 +481,14 @@ struct thread_struct {
 	 */
 };
 
+/* Whitelist the FPU state from the task_struct for hardened usercopy. */
+static inline void arch_thread_struct_whitelist(unsigned long *offset,
+						unsigned long *size)
+{
+	*offset = offsetof(struct thread_struct, fpu.state);
+	*size = fpu_kernel_xstate_size;
+}
+
 /*
  * Thread-synchronous status.
  *
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
