Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C80C4828E4
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 17:44:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so241845408pfx.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:44:45 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id u3si11107035pay.67.2016.07.15.14.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 14:44:35 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id ks6so42721589pab.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:44:35 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 06/11] ia64/uaccess: Enable hardened usercopy
Date: Fri, 15 Jul 2016 14:44:20 -0700
Message-Id: <1468619065-3222-7-git-send-email-keescook@chromium.org>
In-Reply-To: <1468619065-3222-1-git-send-email-keescook@chromium.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Enables CONFIG_HARDENED_USERCOPY checks on ia64.

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/ia64/Kconfig               |  1 +
 arch/ia64/include/asm/uaccess.h | 18 +++++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index f80758cb7157..32a87ef516a0 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -53,6 +53,7 @@ config IA64
 	select MODULES_USE_ELF_RELA
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_AUDITSYSCALL
+	select HAVE_ARCH_HARDENED_USERCOPY
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index 2189d5ddc1ee..465c70982f40 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -241,12 +241,18 @@ extern unsigned long __must_check __copy_user (void __user *to, const void __use
 static inline unsigned long
 __copy_to_user (void __user *to, const void *from, unsigned long count)
 {
+	if (!__builtin_constant_p(count))
+		check_object_size(from, count, true);
+
 	return __copy_user(to, (__force void __user *) from, count);
 }
 
 static inline unsigned long
 __copy_from_user (void *to, const void __user *from, unsigned long count)
 {
+	if (!__builtin_constant_p(count))
+		check_object_size(to, count, false);
+
 	return __copy_user((__force void __user *) to, from, count);
 }
 
@@ -258,8 +264,11 @@ __copy_from_user (void *to, const void __user *from, unsigned long count)
 	const void *__cu_from = (from);							\
 	long __cu_len = (n);								\
 											\
-	if (__access_ok(__cu_to, __cu_len, get_fs()))					\
-		__cu_len = __copy_user(__cu_to, (__force void __user *) __cu_from, __cu_len);	\
+	if (__access_ok(__cu_to, __cu_len, get_fs())) {					\
+		if (!__builtin_constant_p(n))						\
+			check_object_size(__cu_from, __cu_len, true);			\
+		__cu_len = __copy_user(__cu_to, (__force void __user *)  __cu_from, __cu_len);	\
+	}										\
 	__cu_len;									\
 })
 
@@ -270,8 +279,11 @@ __copy_from_user (void *to, const void __user *from, unsigned long count)
 	long __cu_len = (n);								\
 											\
 	__chk_user_ptr(__cu_from);							\
-	if (__access_ok(__cu_from, __cu_len, get_fs()))					\
+	if (__access_ok(__cu_from, __cu_len, get_fs())) {				\
+		if (!__builtin_constant_p(n))						\
+			check_object_size(__cu_to, __cu_len, false);			\
 		__cu_len = __copy_user((__force void __user *) __cu_to, __cu_from, __cu_len);	\
+	}										\
 	__cu_len;									\
 })
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
