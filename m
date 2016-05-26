Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1F1B6B0253
	for <linux-mm@kvack.org>; Thu, 26 May 2016 15:11:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so56293851pfc.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 12:11:18 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id w2si22422182pay.144.2016.05.26.12.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 12:11:17 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id fy7so15781118pac.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 12:11:17 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] arm64: kasan: instrument user memory access API
Date: Thu, 26 May 2016 11:43:51 -0700
Message-Id: <1464288231-11304-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, will.deacon@arm.com, catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
("x86/kasan: instrument user memory access API") added KASAN instrument to
x86 user memory access API, so added such instrument to ARM64 too.

Tested by test_kasan module.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/arm64/include/asm/uaccess.h | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 0685d74..ec352fa 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -23,6 +23,7 @@
  */
 #include <linux/string.h>
 #include <linux/thread_info.h>
+#include <linux/kasan-checks.h>
 
 #include <asm/alternative.h>
 #include <asm/cpufeature.h>
@@ -276,6 +277,8 @@ extern unsigned long __must_check __clear_user(void __user *addr, unsigned long
 
 static inline unsigned long __must_check copy_from_user(void *to, const void __user *from, unsigned long n)
 {
+	kasan_check_write(to, n);
+
 	if (access_ok(VERIFY_READ, from, n))
 		n = __copy_from_user(to, from, n);
 	else /* security hole - plug it */
@@ -285,6 +288,8 @@ static inline unsigned long __must_check copy_from_user(void *to, const void __u
 
 static inline unsigned long __must_check copy_to_user(void __user *to, const void *from, unsigned long n)
 {
+	kasan_check_read(from, n);
+
 	if (access_ok(VERIFY_WRITE, to, n))
 		n = __copy_to_user(to, from, n);
 	return n;
@@ -297,8 +302,17 @@ static inline unsigned long __must_check copy_in_user(void __user *to, const voi
 	return n;
 }
 
-#define __copy_to_user_inatomic __copy_to_user
-#define __copy_from_user_inatomic __copy_from_user
+static inline unsigned long __copy_to_user_inatomic(void __user *to, const void *from, unsigned long n)
+{
+	kasan_check_read(from, n);
+	return __copy_to_user(to, from, n);
+}
+
+static inline unsigned long __copy_from_user_inatomic(void *to, const void __user *from, unsigned long n)
+{
+	kasan_check_write(to, n);
+	return __copy_from_user(to, from, n);
+}
 
 static inline unsigned long __must_check clear_user(void __user *to, unsigned long n)
 {
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
