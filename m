Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9412F6B0261
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 16:27:29 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hh10so102927425pac.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 13:27:29 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id 4si5167892pav.105.2016.07.20.13.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 13:27:21 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id p64so22385174pfb.1
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 13:27:21 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v4 05/12] ARM: uaccess: Enable hardened usercopy
Date: Wed, 20 Jul 2016 13:27:00 -0700
Message-Id: <1469046427-12696-6-git-send-email-keescook@chromium.org>
In-Reply-To: <1469046427-12696-1-git-send-email-keescook@chromium.org>
References: <1469046427-12696-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Enables CONFIG_HARDENED_USERCOPY checks on arm.

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/Kconfig               |  1 +
 arch/arm/include/asm/uaccess.h | 11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 90542db1220d..f56b29b3f57e 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -35,6 +35,7 @@ config ARM
 	select HARDIRQS_SW_RESEND
 	select HAVE_ARCH_AUDITSYSCALL if (AEABI && !OABI_COMPAT)
 	select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6
+	select HAVE_ARCH_HARDENED_USERCOPY
 	select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32 && MMU
 	select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32 && MMU
 	select HAVE_ARCH_MMAP_RND_BITS if MMU
diff --git a/arch/arm/include/asm/uaccess.h b/arch/arm/include/asm/uaccess.h
index 35c9db857ebe..7fb59199c6bb 100644
--- a/arch/arm/include/asm/uaccess.h
+++ b/arch/arm/include/asm/uaccess.h
@@ -496,7 +496,10 @@ arm_copy_from_user(void *to, const void __user *from, unsigned long n);
 static inline unsigned long __must_check
 __copy_from_user(void *to, const void __user *from, unsigned long n)
 {
-	unsigned int __ua_flags = uaccess_save_and_enable();
+	unsigned int __ua_flags;
+
+	check_object_size(to, n, false);
+	__ua_flags = uaccess_save_and_enable();
 	n = arm_copy_from_user(to, from, n);
 	uaccess_restore(__ua_flags);
 	return n;
@@ -511,11 +514,15 @@ static inline unsigned long __must_check
 __copy_to_user(void __user *to, const void *from, unsigned long n)
 {
 #ifndef CONFIG_UACCESS_WITH_MEMCPY
-	unsigned int __ua_flags = uaccess_save_and_enable();
+	unsigned int __ua_flags;
+
+	check_object_size(from, n, true);
+	__ua_flags = uaccess_save_and_enable();
 	n = arm_copy_to_user(to, from, n);
 	uaccess_restore(__ua_flags);
 	return n;
 #else
+	check_object_size(from, n, true);
 	return arm_copy_to_user(to, from, n);
 #endif
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
