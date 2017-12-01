Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 384606B026A
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 16:37:04 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id w191so9747609iof.11
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 13:37:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m12sor3034140ioe.322.2017.12.01.13.37.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Dec 2017 13:37:03 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v3 3/5] kasan: support alloca() poisoning
Date: Fri,  1 Dec 2017 13:36:41 -0800
Message-Id: <20171201213643.2506-4-paullawrence@google.com>
In-Reply-To: <20171201213643.2506-1-paullawrence@google.com>
References: <20171201213643.2506-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>

clang's AddressSanitizer implementation adds redzones on either side of
alloca()ed buffers.  These redzones are 32-byte aligned and at least 32
bytes long.

__asan_alloca_poison() is passed the size and address of the allocated
buffer, *excluding* the redzones on either side.  The left redzone will
always be to the immediate left of this buffer; but AddressSanitizer may
need to add padding between the end of the buffer and the right redzone.
If there are any 8-byte chunks inside this padding, we should poison
those too.

__asan_allocas_unpoison() is just passed the top and bottom of the
dynamic stack area, so unpoisoning is simpler.

Signed-off-by: Greg Hackmann <ghackmann@google.com>
Signed-off-by: Paul Lawrence <paullawrence@google.com>
---
 mm/kasan/kasan.c       | 34 ++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h       |  8 ++++++++
 mm/kasan/report.c      |  4 ++++
 scripts/Makefile.kasan |  3 ++-
 4 files changed, 48 insertions(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 405bba487df5..d96b36088b2f 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -736,6 +736,40 @@ void __asan_unpoison_stack_memory(const void *addr, size_t size)
 }
 EXPORT_SYMBOL(__asan_unpoison_stack_memory);
 
+/* Emitted by compiler to poison alloca()ed objects. */
+void __asan_alloca_poison(unsigned long addr, size_t size)
+{
+	size_t rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
+	size_t padding_size = round_up(size, KASAN_ALLOCA_REDZONE_SIZE) -
+			rounded_up_size;
+	size_t rounded_down_size = round_down(size, KASAN_SHADOW_SCALE_SIZE);
+
+	const void *left_redzone = (const void *)(addr -
+			KASAN_ALLOCA_REDZONE_SIZE);
+	const void *right_redzone = (const void *)(addr + rounded_up_size);
+
+	WARN_ON(!IS_ALIGNED(addr, KASAN_ALLOCA_REDZONE_SIZE));
+
+	kasan_unpoison_shadow((const void *)(addr + rounded_down_size),
+			      size - rounded_down_size);
+	kasan_poison_shadow(left_redzone, KASAN_ALLOCA_REDZONE_SIZE,
+			KASAN_ALLOCA_LEFT);
+	kasan_poison_shadow(right_redzone,
+			padding_size + KASAN_ALLOCA_REDZONE_SIZE,
+			KASAN_ALLOCA_RIGHT);
+}
+EXPORT_SYMBOL(__asan_alloca_poison);
+
+/* Emitted by compiler to unpoison alloca()ed areas when the stack unwinds. */
+void __asan_allocas_unpoison(const void *stack_top, const void *stack_bottom)
+{
+	if (unlikely(!stack_top || stack_top > stack_bottom))
+		return;
+
+	kasan_unpoison_shadow(stack_top, stack_bottom - stack_top);
+}
+EXPORT_SYMBOL(__asan_allocas_unpoison);
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 static int __meminit kasan_mem_notifier(struct notifier_block *nb,
 			unsigned long action, void *data)
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index c70851a9a6a4..7c0bcd1f4c0d 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -24,6 +24,14 @@
 #define KASAN_STACK_PARTIAL     0xF4
 #define KASAN_USE_AFTER_SCOPE   0xF8
 
+/*
+ * alloca redzone shadow values
+ */
+#define KASAN_ALLOCA_LEFT	0xCA
+#define KASAN_ALLOCA_RIGHT	0xCB
+
+#define KASAN_ALLOCA_REDZONE_SIZE	32
+
 /* Don't break randconfig/all*config builds */
 #ifndef KASAN_ABI_VERSION
 #define KASAN_ABI_VERSION 1
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 410c8235e671..eff12e040498 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -102,6 +102,10 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 	case KASAN_USE_AFTER_SCOPE:
 		bug_type = "use-after-scope";
 		break;
+	case KASAN_ALLOCA_LEFT:
+	case KASAN_ALLOCA_RIGHT:
+		bug_type = "alloca-out-of-bounds";
+		break;
 	}
 
 	return bug_type;
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 7c00be9216f4..b4983cf8a9d4 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -32,7 +32,8 @@ else
 	$(call cc-param,asan-globals=1) \
 	$(call cc-param,asan-instrumentation-with-call-threshold=$(call_threshold)) \
 	$(call cc-param,asan-stack=1) \
-	$(call cc-param,asan-use-after-scope=1)
+	$(call cc-param,asan-use-after-scope=1) \
+	$(call cc-param,asan-instrument-allocas=1)
    endif
 
 endif
-- 
2.15.0.531.g2ccb3012c9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
