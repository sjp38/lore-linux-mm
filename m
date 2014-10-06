Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF296B0099
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 12:01:39 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so3439226pdj.23
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 09:01:38 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id b3si11062034pdc.11.2014.10.06.09.01.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 06 Oct 2014 09:01:37 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0ND1009NU5ZE8M80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Oct 2014 17:04:26 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC PATCH v4 13/13] kasan: introduce inline instrumentation
Date: Mon, 06 Oct 2014 19:54:07 +0400
Message-id: <1412610847-27671-14-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1412610847-27671-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1412610847-27671-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>

This patch only demonstration how easy this could be achieved.
GCC doesn't support this feature yet. Two patches required for this:
    https://gcc.gnu.org/ml/gcc-patches/2014-09/msg00452.html
    https://gcc.gnu.org/ml/gcc-patches/2014-09/msg00605.html

In inline instrumentation mode compiler directly inserts code
checking shadow memory instead of __asan_load/__asan_store
calls.
This is usually faster than outline. In some workloads inline is
2 times faster than outline instrumentation.

The downside of inline instrumentation is bloated kernel's .text size:

size noasan/vmlinux
   text     data     bss      dec     hex    filename
11759720  1566560  946176  14272456  d9c7c8  noasan/vmlinux

size outline/vmlinux
   text    data     bss      dec      hex    filename
16553474  1602592  950272  19106338  1238a22 outline/vmlinux

size inline/vmlinux
   text    data     bss      dec      hex    filename
32064759  1598688  946176  34609623  21019d7 inline/vmlinux

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 Makefile          |  6 +++++-
 lib/Kconfig.kasan | 24 ++++++++++++++++++++++++
 mm/kasan/kasan.c  | 14 +-------------
 mm/kasan/kasan.h  | 22 ++++++++++++++++++++++
 mm/kasan/report.c | 37 +++++++++++++++++++++++++++++++++++++
 5 files changed, 89 insertions(+), 14 deletions(-)

diff --git a/Makefile b/Makefile
index 6f8be78..01cfa71 100644
--- a/Makefile
+++ b/Makefile
@@ -758,7 +758,11 @@ KBUILD_CFLAGS += $(call cc-option, -fno-inline-functions-called-once)
 endif
 
 ifdef CONFIG_KASAN
-  ifeq ($(CFLAGS_KASAN),)
+ifdef CONFIG_KASAN_INLINE
+CFLAGS_KASAN += $(call cc-option, -fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET)) \
+		 $(call cc-option, --param asan-instrumentation-with-call-threshold=10000)
+endif
+  ifeq ($(strip $(CFLAGS_KASAN)),)
     $(warning Cannot use CONFIG_KASAN: \
 	      -fsanitize=kernel-address not supported by compiler)
   endif
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 94293c8..ec5d680 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -27,4 +27,28 @@ config TEST_KASAN
 	  out of bounds accesses, use after free. It is useful for testing
 	  kernel debugging features like kernel address sanitizer.
 
+choice
+	prompt "Instrumentation type"
+	depends on KASAN
+	default KASAN_INLINE if X86_64
+
+config KASAN_OUTLINE
+	bool "Outline instrumentation"
+	help
+	  Before every memory access compiler insert function call
+	  __asan_load*/__asan_store*. These functions performs check
+	  of shadow memory. This is slower than inline instrumentation,
+	  however it doesn't bloat size of kernel's .text section so
+	  much as inline does.
+
+config KASAN_INLINE
+	bool "Inline instrumentation"
+	help
+	  Compiler directly inserts code checking shadow memory before
+	  memory accesses. This is faster than outline (in some workloads
+	  it gives about x2 boost over outline instrumentation), but
+	  make kernel's .text size much bigger.
+
+endchoice
+
 endif
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index d4552a2..6e34fdb 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -32,11 +32,6 @@
 #include "kasan.h"
 #include "../slab.h"
 
-static inline bool kasan_enabled(void)
-{
-	return !current->kasan_depth;
-}
-
 /*
  * Poisons the shadow memory for 'size' bytes starting from 'addr'.
  * Memory addresses should be aligned to KASAN_SHADOW_SCALE_SIZE.
@@ -250,14 +245,7 @@ static __always_inline void check_memory_region(unsigned long addr,
 	if (likely(!memory_is_poisoned(addr, size)))
 		return;
 
-	if (likely(!kasan_enabled()))
-		return;
-
-	info.access_addr = addr;
-	info.access_size = size;
-	info.is_write = write;
-	info.ip = _RET_IP_;
-	kasan_report_error(&info);
+	kasan_report(addr, size, write);
 }
 
 void kasan_alloc_pages(struct page *page, unsigned int order)
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index b70a3d1..049349b 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -29,4 +29,26 @@ static inline unsigned long kasan_shadow_to_mem(unsigned long shadow_addr)
 	return (shadow_addr - KASAN_SHADOW_OFFSET) << KASAN_SHADOW_SCALE_SHIFT;
 }
 
+static inline bool kasan_enabled(void)
+{
+	return !current->kasan_depth;
+}
+
+static __always_inline void kasan_report(unsigned long addr,
+					size_t size,
+					bool is_write)
+{
+	struct access_info info;
+
+	if (likely(!kasan_enabled()))
+		return;
+
+	info.access_addr = addr;
+	info.access_size = size;
+	info.is_write = is_write;
+	info.ip = _RET_IP_;
+	kasan_report_error(&info);
+}
+
+
 #endif
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 03ce28e..39ec639 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -199,3 +199,40 @@ void kasan_report_user_access(struct access_info *info)
 		"=================================\n");
 	spin_unlock_irqrestore(&report_lock, flags);
 }
+
+#define DEFINE_ASAN_REPORT_LOAD(size)                     \
+void __asan_report_recover_load##size(unsigned long addr) \
+{                                                         \
+	kasan_report(addr, size, false);                  \
+}                                                         \
+EXPORT_SYMBOL(__asan_report_recover_load##size)
+
+#define DEFINE_ASAN_REPORT_STORE(size)                     \
+void __asan_report_recover_store##size(unsigned long addr) \
+{                                                          \
+	kasan_report(addr, size, true);                    \
+}                                                          \
+EXPORT_SYMBOL(__asan_report_recover_store##size)
+
+DEFINE_ASAN_REPORT_LOAD(1);
+DEFINE_ASAN_REPORT_LOAD(2);
+DEFINE_ASAN_REPORT_LOAD(4);
+DEFINE_ASAN_REPORT_LOAD(8);
+DEFINE_ASAN_REPORT_LOAD(16);
+DEFINE_ASAN_REPORT_STORE(1);
+DEFINE_ASAN_REPORT_STORE(2);
+DEFINE_ASAN_REPORT_STORE(4);
+DEFINE_ASAN_REPORT_STORE(8);
+DEFINE_ASAN_REPORT_STORE(16);
+
+void __asan_report_recover_load_n(unsigned long addr, size_t size)
+{
+	kasan_report(addr, size, false);
+}
+EXPORT_SYMBOL(__asan_report_recover_load_n);
+
+void __asan_report_recover_store_n(unsigned long addr, size_t size)
+{
+	kasan_report(addr, size, true);
+}
+EXPORT_SYMBOL(__asan_report_recover_store_n);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
