Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E748A6B0267
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 17:56:30 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hh10so102764913pac.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 14:56:30 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id 15si539512pfv.78.2016.07.13.14.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 14:56:18 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id pp5so14696857pac.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 14:56:18 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 08/11] sparc/uaccess: Enable hardened usercopy
Date: Wed, 13 Jul 2016 14:56:01 -0700
Message-Id: <1468446964-22213-9-git-send-email-keescook@chromium.org>
In-Reply-To: <1468446964-22213-1-git-send-email-keescook@chromium.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Enables CONFIG_HARDENED_USERCOPY checks on sparc.

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/sparc/Kconfig                  |  1 +
 arch/sparc/include/asm/uaccess_32.h | 14 ++++++++++----
 arch/sparc/include/asm/uaccess_64.h | 11 +++++++++--
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 546293d9e6c5..59b09600dd32 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -43,6 +43,7 @@ config SPARC
 	select OLD_SIGSUSPEND
 	select ARCH_HAS_SG_CHAIN
 	select CPU_NO_EFFICIENT_FFS
+	select HAVE_ARCH_HARDENED_USERCOPY
 
 config SPARC32
 	def_bool !64BIT
diff --git a/arch/sparc/include/asm/uaccess_32.h b/arch/sparc/include/asm/uaccess_32.h
index 57aca2792d29..341a5a133f48 100644
--- a/arch/sparc/include/asm/uaccess_32.h
+++ b/arch/sparc/include/asm/uaccess_32.h
@@ -248,22 +248,28 @@ unsigned long __copy_user(void __user *to, const void __user *from, unsigned lon
 
 static inline unsigned long copy_to_user(void __user *to, const void *from, unsigned long n)
 {
-	if (n && __access_ok((unsigned long) to, n))
+	if (n && __access_ok((unsigned long) to, n)) {
+		if (!__builtin_constant_p(n))
+			check_object_size(from, n, true);
 		return __copy_user(to, (__force void __user *) from, n);
-	else
+	} else
 		return n;
 }
 
 static inline unsigned long __copy_to_user(void __user *to, const void *from, unsigned long n)
 {
+	if (!__builtin_constant_p(n))
+		check_object_size(from, n, true);
 	return __copy_user(to, (__force void __user *) from, n);
 }
 
 static inline unsigned long copy_from_user(void *to, const void __user *from, unsigned long n)
 {
-	if (n && __access_ok((unsigned long) from, n))
+	if (n && __access_ok((unsigned long) from, n)) {
+		if (!__builtin_constant_p(n))
+			check_object_size(to, n, false);
 		return __copy_user((__force void __user *) to, from, n);
-	else
+	} else
 		return n;
 }
 
diff --git a/arch/sparc/include/asm/uaccess_64.h b/arch/sparc/include/asm/uaccess_64.h
index e9a51d64974d..8bda94fab8e8 100644
--- a/arch/sparc/include/asm/uaccess_64.h
+++ b/arch/sparc/include/asm/uaccess_64.h
@@ -210,8 +210,12 @@ unsigned long copy_from_user_fixup(void *to, const void __user *from,
 static inline unsigned long __must_check
 copy_from_user(void *to, const void __user *from, unsigned long size)
 {
-	unsigned long ret = ___copy_from_user(to, from, size);
+	unsigned long ret;
 
+	if (!__builtin_constant_p(size))
+		check_object_size(to, size, false);
+
+	ret = ___copy_from_user(to, from, size);
 	if (unlikely(ret))
 		ret = copy_from_user_fixup(to, from, size);
 
@@ -227,8 +231,11 @@ unsigned long copy_to_user_fixup(void __user *to, const void *from,
 static inline unsigned long __must_check
 copy_to_user(void __user *to, const void *from, unsigned long size)
 {
-	unsigned long ret = ___copy_to_user(to, from, size);
+	unsigned long ret;
 
+	if (!__builtin_constant_p(size))
+		check_object_size(from, size, true);
+	ret = ___copy_to_user(to, from, size);
 	if (unlikely(ret))
 		ret = copy_to_user_fixup(to, from, size);
 	return ret;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
