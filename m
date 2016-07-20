Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 768D96B0261
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 16:27:27 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so353033pad.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 13:27:27 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id d5si5173296pfb.98.2016.07.20.13.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 13:27:20 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id iw10so21360761pac.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 13:27:20 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v4 06/12] arm64/uaccess: Enable hardened usercopy
Date: Wed, 20 Jul 2016 13:27:01 -0700
Message-Id: <1469046427-12696-7-git-send-email-keescook@chromium.org>
In-Reply-To: <1469046427-12696-1-git-send-email-keescook@chromium.org>
References: <1469046427-12696-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Enables CONFIG_HARDENED_USERCOPY checks on arm64. As done by KASAN in -next,
renames the low-level functions to __arch_copy_*_user() so a static inline
can do additional work before the copy.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/arm64/Kconfig               |  1 +
 arch/arm64/include/asm/uaccess.h | 29 ++++++++++++++++++++++-------
 arch/arm64/kernel/arm64ksyms.c   |  4 ++--
 arch/arm64/lib/copy_from_user.S  |  4 ++--
 arch/arm64/lib/copy_to_user.S    |  4 ++--
 5 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 5a0a691d4220..9cdb2322c811 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -51,6 +51,7 @@ config ARM64
 	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_BITREVERSE
+	select HAVE_ARCH_HARDENED_USERCOPY
 	select HAVE_ARCH_HUGE_VMAP
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 9e397a542756..92848b00e3cd 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -256,24 +256,39 @@ do {									\
 		-EFAULT;						\
 })
 
-extern unsigned long __must_check __copy_from_user(void *to, const void __user *from, unsigned long n);
-extern unsigned long __must_check __copy_to_user(void __user *to, const void *from, unsigned long n);
+extern unsigned long __must_check __arch_copy_from_user(void *to, const void __user *from, unsigned long n);
+extern unsigned long __must_check __arch_copy_to_user(void __user *to, const void *from, unsigned long n);
 extern unsigned long __must_check __copy_in_user(void __user *to, const void __user *from, unsigned long n);
 extern unsigned long __must_check __clear_user(void __user *addr, unsigned long n);
 
+static inline unsigned long __must_check __copy_from_user(void *to, const void __user *from, unsigned long n)
+{
+	check_object_size(to, n, false);
+	return __arch_copy_from_user(to, from, n);
+}
+
+static inline unsigned long __must_check __copy_to_user(void __user *to, const void *from, unsigned long n)
+{
+	check_object_size(from, n, true);
+	return __arch_copy_to_user(to, from, n);
+}
+
 static inline unsigned long __must_check copy_from_user(void *to, const void __user *from, unsigned long n)
 {
-	if (access_ok(VERIFY_READ, from, n))
-		n = __copy_from_user(to, from, n);
-	else /* security hole - plug it */
+	if (access_ok(VERIFY_READ, from, n)) {
+		check_object_size(to, n, false);
+		n = __arch_copy_from_user(to, from, n);
+	} else /* security hole - plug it */
 		memset(to, 0, n);
 	return n;
 }
 
 static inline unsigned long __must_check copy_to_user(void __user *to, const void *from, unsigned long n)
 {
-	if (access_ok(VERIFY_WRITE, to, n))
-		n = __copy_to_user(to, from, n);
+	if (access_ok(VERIFY_WRITE, to, n)) {
+		check_object_size(from, n, true);
+		n = __arch_copy_to_user(to, from, n);
+	}
 	return n;
 }
 
diff --git a/arch/arm64/kernel/arm64ksyms.c b/arch/arm64/kernel/arm64ksyms.c
index 678f30b05a45..2dc44406a7ad 100644
--- a/arch/arm64/kernel/arm64ksyms.c
+++ b/arch/arm64/kernel/arm64ksyms.c
@@ -34,8 +34,8 @@ EXPORT_SYMBOL(copy_page);
 EXPORT_SYMBOL(clear_page);
 
 	/* user mem (segment) */
-EXPORT_SYMBOL(__copy_from_user);
-EXPORT_SYMBOL(__copy_to_user);
+EXPORT_SYMBOL(__arch_copy_from_user);
+EXPORT_SYMBOL(__arch_copy_to_user);
 EXPORT_SYMBOL(__clear_user);
 EXPORT_SYMBOL(__copy_in_user);
 
diff --git a/arch/arm64/lib/copy_from_user.S b/arch/arm64/lib/copy_from_user.S
index 17e8306dca29..0b90497d4424 100644
--- a/arch/arm64/lib/copy_from_user.S
+++ b/arch/arm64/lib/copy_from_user.S
@@ -66,7 +66,7 @@
 	.endm
 
 end	.req	x5
-ENTRY(__copy_from_user)
+ENTRY(__arch_copy_from_user)
 ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(0)), ARM64_ALT_PAN_NOT_UAO, \
 	    CONFIG_ARM64_PAN)
 	add	end, x0, x2
@@ -75,7 +75,7 @@ ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(1)), ARM64_ALT_PAN_NOT_UAO, \
 	    CONFIG_ARM64_PAN)
 	mov	x0, #0				// Nothing to copy
 	ret
-ENDPROC(__copy_from_user)
+ENDPROC(__arch_copy_from_user)
 
 	.section .fixup,"ax"
 	.align	2
diff --git a/arch/arm64/lib/copy_to_user.S b/arch/arm64/lib/copy_to_user.S
index 21faae60f988..7a7efe255034 100644
--- a/arch/arm64/lib/copy_to_user.S
+++ b/arch/arm64/lib/copy_to_user.S
@@ -65,7 +65,7 @@
 	.endm
 
 end	.req	x5
-ENTRY(__copy_to_user)
+ENTRY(__arch_copy_to_user)
 ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(0)), ARM64_ALT_PAN_NOT_UAO, \
 	    CONFIG_ARM64_PAN)
 	add	end, x0, x2
@@ -74,7 +74,7 @@ ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(1)), ARM64_ALT_PAN_NOT_UAO, \
 	    CONFIG_ARM64_PAN)
 	mov	x0, #0
 	ret
-ENDPROC(__copy_to_user)
+ENDPROC(__arch_copy_to_user)
 
 	.section .fixup,"ax"
 	.align	2
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
