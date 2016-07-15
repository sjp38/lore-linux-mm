Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id E00DB828E4
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 17:44:47 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so110731968pab.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:44:47 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id r8si11076469pav.187.2016.07.15.14.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 14:44:36 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id y134so18758383pfg.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:44:36 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 07/11] powerpc/uaccess: Enable hardened usercopy
Date: Fri, 15 Jul 2016 14:44:21 -0700
Message-Id: <1468619065-3222-8-git-send-email-keescook@chromium.org>
In-Reply-To: <1468619065-3222-1-git-send-email-keescook@chromium.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Enables CONFIG_HARDENED_USERCOPY checks on powerpc.

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
Tested-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/powerpc/Kconfig               |  1 +
 arch/powerpc/include/asm/uaccess.h | 21 +++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 01f7464d9fea..b7a18b2604be 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -164,6 +164,7 @@ config PPC
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
 	select HAVE_LIVEPATCH if HAVE_DYNAMIC_FTRACE_WITH_REGS
+	select HAVE_ARCH_HARDENED_USERCOPY
 
 config GENERIC_CSUM
 	def_bool CPU_LITTLE_ENDIAN
diff --git a/arch/powerpc/include/asm/uaccess.h b/arch/powerpc/include/asm/uaccess.h
index b7c20f0b8fbe..c1dc6c14deb8 100644
--- a/arch/powerpc/include/asm/uaccess.h
+++ b/arch/powerpc/include/asm/uaccess.h
@@ -310,10 +310,15 @@ static inline unsigned long copy_from_user(void *to,
 {
 	unsigned long over;
 
-	if (access_ok(VERIFY_READ, from, n))
+	if (access_ok(VERIFY_READ, from, n)) {
+		if (!__builtin_constant_p(n))
+			check_object_size(to, n, false);
 		return __copy_tofrom_user((__force void __user *)to, from, n);
+	}
 	if ((unsigned long)from < TASK_SIZE) {
 		over = (unsigned long)from + n - TASK_SIZE;
+		if (!__builtin_constant_p(n - over))
+			check_object_size(to, n - over, false);
 		return __copy_tofrom_user((__force void __user *)to, from,
 				n - over) + over;
 	}
@@ -325,10 +330,15 @@ static inline unsigned long copy_to_user(void __user *to,
 {
 	unsigned long over;
 
-	if (access_ok(VERIFY_WRITE, to, n))
+	if (access_ok(VERIFY_WRITE, to, n)) {
+		if (!__builtin_constant_p(n))
+			check_object_size(from, n, true);
 		return __copy_tofrom_user(to, (__force void __user *)from, n);
+	}
 	if ((unsigned long)to < TASK_SIZE) {
 		over = (unsigned long)to + n - TASK_SIZE;
+		if (!__builtin_constant_p(n))
+			check_object_size(from, n - over, true);
 		return __copy_tofrom_user(to, (__force void __user *)from,
 				n - over) + over;
 	}
@@ -372,6 +382,10 @@ static inline unsigned long __copy_from_user_inatomic(void *to,
 		if (ret == 0)
 			return 0;
 	}
+
+	if (!__builtin_constant_p(n))
+		check_object_size(to, n, false);
+
 	return __copy_tofrom_user((__force void __user *)to, from, n);
 }
 
@@ -398,6 +412,9 @@ static inline unsigned long __copy_to_user_inatomic(void __user *to,
 		if (ret == 0)
 			return 0;
 	}
+	if (!__builtin_constant_p(n))
+		check_object_size(from, n, true);
+
 	return __copy_tofrom_user(to, (__force const void __user *)from, n);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
