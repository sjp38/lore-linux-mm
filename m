Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 996FC6B006C
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 10:10:33 -0500 (EST)
Received: by padbj1 with SMTP id bj1so23334750pad.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 07:10:33 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id sz8si407412pbc.151.2015.02.27.07.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 27 Feb 2015 07:10:32 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKF006VKRO25460@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Feb 2015 15:14:26 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH 2/2] kasan,
 module: move MODULE_ALIGN macro into <linux/moduleloader.h>
Date: Fri, 27 Feb 2015 18:10:16 +0300
Message-id: <1425049816-11385-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1425049816-11385-1-git-send-email-a.ryabinin@samsung.com>
References: <1425049816-11385-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Rusty Russell <rusty@rustcorp.com.au>

include/linux/moduleloader.h is more suitable place for this macro.
Also change alignment to PAGE_SIZE for CONFIG_KASAN=n as such
alignment already assumed in several places.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
---
 include/linux/kasan.h        | 4 ----
 include/linux/moduleloader.h | 8 ++++++++
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 5fa48a2..5bb0744 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -50,15 +50,11 @@ void kasan_krealloc(const void *object, size_t new_size);
 void kasan_slab_alloc(struct kmem_cache *s, void *object);
 void kasan_slab_free(struct kmem_cache *s, void *object);
 
-#define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
-
 int kasan_module_alloc(void *addr, size_t size);
 void kasan_free_shadow(const struct vm_struct *vm);
 
 #else /* CONFIG_KASAN */
 
-#define MODULE_ALIGN 1
-
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
 
 static inline void kasan_enable_current(void) {}
diff --git a/include/linux/moduleloader.h b/include/linux/moduleloader.h
index f755626..4d0cb9b 100644
--- a/include/linux/moduleloader.h
+++ b/include/linux/moduleloader.h
@@ -84,4 +84,12 @@ void module_arch_cleanup(struct module *mod);
 
 /* Any cleanup before freeing mod->module_init */
 void module_arch_freeing_init(struct module *mod);
+
+#ifdef CONFIG_KASAN
+#include <linux/kasan.h>
+#define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
+#else
+#define MODULE_ALIGN PAGE_SIZE
+#endif
+
 #endif
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
