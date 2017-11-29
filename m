Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 388516B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:51:14 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id b80so4008975iob.23
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:51:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w11sor1739465ith.3.2017.11.29.13.51.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 13:51:13 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v2 1/5] kasan: support alloca() poisoning
Date: Wed, 29 Nov 2017 13:50:46 -0800
Message-Id: <20171129215050.158653-2-paullawrence@google.com>
In-Reply-To: <20171129215050.158653-1-paullawrence@google.com>
References: <20171129215050.158653-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
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

 mm/kasan/kasan.c  | 32 ++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h  |  8 ++++++++
 mm/kasan/report.c |  4 ++++
 3 files changed, 44 insertions(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 405bba487df5..f86f862f41f8 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -736,6 +736,38 @@ void __asan_unpoison_stack_memory(const void *addr, size_t size)
 }
 EXPORT_SYMBOL(__asan_unpoison_stack_memory);
 
+/* Emitted by compiler to poison alloca()ed objects. */
+void __asan_alloca_poison(unsigned long addr, size_t size)
+{
+	size_t rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
+	size_t padding_size = round_up(size, KASAN_ALLOCA_REDZONE_SIZE) -
+			rounded_up_size;
+
+	const void *left_redzone = (const void *)(addr -
+			KASAN_ALLOCA_REDZONE_SIZE);
+	const void *right_redzone = (const void *)(addr + rounded_up_size);
+
+	WARN_ON(!IS_ALIGNED(addr, KASAN_ALLOCA_REDZONE_SIZE));
+
+	kasan_unpoison_shadow((const void *)addr, size);
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
index 6bcfb01ba038..25419d426426 100644
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
-- 
2.15.0.531.g2ccb3012c9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
