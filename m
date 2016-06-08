Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1DA16B0005
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 18:08:58 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ao6so28296002pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 15:08:58 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id h20si3511596pfh.130.2016.06.08.15.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 15:08:56 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id hl6so6192517pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 15:08:56 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [v3 PATCH] arm64: kasan: instrument user memory access API
Date: Wed,  8 Jun 2016 14:40:56 -0700
Message-Id: <1465422056-20531-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, will.deacon@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
("x86/kasan: instrument user memory access API") added KASAN instrument to
x86 user memory access API, so added such instrument to ARM64 too.

Define __copy_to/from_user in C in order to add kasan_check_read/write call,
rename assembly implementation to __arch_copy_to/from_user.

Tested by test_kasan module.

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
v3:
 Moved linux/kasan-checks.h before the other includes to keep them ordered
 alphabetically as suggested by Mark.
 Added Acked-by from Andrey Ryabinin and Reviewed-by/Tested-by from Mark.
v2:
 Adopted the comment from Andrey and Mark to add kasan_check_read/write into
 __copy_to/from_user.

 arch/arm64/include/asm/uaccess.h | 25 +++++++++++++++++++++----
 arch/arm64/kernel/arm64ksyms.c   |  4 ++--
 arch/arm64/lib/copy_from_user.S  |  4 ++--
 arch/arm64/lib/copy_to_user.S    |  4 ++--
 4 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 0685d74..672d367 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -21,6 +21,7 @@
 /*
  * User space memory access functions
  */
+#include <linux/kasan-checks.h>
 #include <linux/string.h>
 #include <linux/thread_info.h>
 
@@ -269,15 +270,29 @@ do {									\
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
+	kasan_check_write(to, n);
+	return  __arch_copy_from_user(to, from, n);
+}
+
+static inline unsigned long __must_check __copy_to_user(void __user *to, const void *from, unsigned long n)
+{
+	kasan_check_read(from, n);
+	return  __arch_copy_to_user(to, from, n);
+}
+
 static inline unsigned long __must_check copy_from_user(void *to, const void __user *from, unsigned long n)
 {
+	kasan_check_write(to, n);
+
 	if (access_ok(VERIFY_READ, from, n))
-		n = __copy_from_user(to, from, n);
+		n = __arch_copy_from_user(to, from, n);
 	else /* security hole - plug it */
 		memset(to, 0, n);
 	return n;
@@ -285,8 +300,10 @@ static inline unsigned long __must_check copy_from_user(void *to, const void __u
 
 static inline unsigned long __must_check copy_to_user(void __user *to, const void *from, unsigned long n)
 {
+	kasan_check_read(from, n);
+
 	if (access_ok(VERIFY_WRITE, to, n))
-		n = __copy_to_user(to, from, n);
+		n = __arch_copy_to_user(to, from, n);
 	return n;
 }
 
diff --git a/arch/arm64/kernel/arm64ksyms.c b/arch/arm64/kernel/arm64ksyms.c
index 678f30b0..2dc4440 100644
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
index 17e8306..0b90497 100644
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
index 21faae6..7a7efe2 100644
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
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
