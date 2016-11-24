Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C27B56B025E
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 09:36:43 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so15247319wmd.6
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:36:43 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id rv12si37189024wjb.256.2016.11.24.06.36.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 06:36:42 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id t79so63370220wmt.0
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:36:42 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v2] kasan: update kasan_global for gcc 7
Date: Thu, 24 Nov 2016 15:36:38 +0100
Message-Id: <1479998198-144377-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, arnd@arndb.de, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, #@google.com, 4.0+@google.com

kasan_global struct is part of compiler/runtime ABI.
gcc revision 241983 has added a new field to kasan_global struct.
Update kernel definition of kasan_global struct to include
the new field.

Without this patch KASAN is broken with gcc 7.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: aryabinin@virtuozzo.com
Cc: glider@google.com
Cc: akpm@linux-foundation.org
Cc: arnd@arndb.de
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org # 4.0+

---
Changes since v1:
 - added cc stable
---
 include/linux/compiler-gcc.h | 4 +++-
 mm/kasan/kasan.h             | 3 +++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index 432f5c9..928e5ca 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -263,7 +263,9 @@
 #endif
 #endif /* CONFIG_ARCH_USE_BUILTIN_BSWAP && !__CHECKER__ */
 
-#if GCC_VERSION >= 50000
+#if GCC_VERSION >= 70000
+#define KASAN_ABI_VERSION 5
+#elif GCC_VERSION >= 50000
 #define KASAN_ABI_VERSION 4
 #elif GCC_VERSION >= 40902
 #define KASAN_ABI_VERSION 3
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index e5c2181..03f4545 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -53,6 +53,9 @@ struct kasan_global {
 #if KASAN_ABI_VERSION >= 4
 	struct kasan_source_location *location;
 #endif
+#if KASAN_ABI_VERSION >= 5
+	char *odr_indicator;
+#endif
 };
 
 /**
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
