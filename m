Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4776B0272
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 14:17:52 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r196so13394259itc.4
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 11:17:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g19sor7234925iob.128.2017.12.04.11.17.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 11:17:50 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v4 5/5] kasan: added functions for unpoisoning stack variables
Date: Mon,  4 Dec 2017 11:17:35 -0800
Message-Id: <20171204191735.132544-6-paullawrence@google.com>
In-Reply-To: <20171204191735.132544-1-paullawrence@google.com>
References: <20171204191735.132544-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>

From: Alexander Potapenko <glider@google.com>

As a code-size optimization, LLVM builds since r279383 may
bulk-manipulate the shadow region when (un)poisoning large memory
blocks.  This requires new callbacks that simply do an uninstrumented
memset().

This fixes linking the Clang-built kernel when using KASAN.

Signed-off-by: Alexander Potapenko <glider@google.com>
[ghackmann@google.com: fix memset() parameters, and tweak
 commit message to describe new callbacks]
Signed-off-by: Greg Hackmann <ghackmann@google.com>
Signed-off-by: Paul Lawrence <paullawrence@google.com>
---
 mm/kasan/kasan.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index d96b36088b2f..8aaee42fcfab 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -770,6 +770,21 @@ void __asan_allocas_unpoison(const void *stack_top, const void *stack_bottom)
 }
 EXPORT_SYMBOL(__asan_allocas_unpoison);
 
+/* Emitted by the compiler to [un]poison local variables. */
+#define DEFINE_ASAN_SET_SHADOW(byte) \
+	void __asan_set_shadow_##byte(const void *addr, size_t size)	\
+	{								\
+		__memset((void *)addr, 0x##byte, size);			\
+	}								\
+	EXPORT_SYMBOL(__asan_set_shadow_##byte)
+
+DEFINE_ASAN_SET_SHADOW(00);
+DEFINE_ASAN_SET_SHADOW(f1);
+DEFINE_ASAN_SET_SHADOW(f2);
+DEFINE_ASAN_SET_SHADOW(f3);
+DEFINE_ASAN_SET_SHADOW(f5);
+DEFINE_ASAN_SET_SHADOW(f8);
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 static int __meminit kasan_mem_notifier(struct notifier_block *nb,
 			unsigned long action, void *data)
-- 
2.15.0.531.g2ccb3012c9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
