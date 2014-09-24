Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 989BC6B0062
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:51:46 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id lj1so210701pab.37
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 05:51:46 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id rk5si26079161pab.204.2014.09.24.05.51.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 24 Sep 2014 05:51:45 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NCE00J0GP6XWDA0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 24 Sep 2014 13:54:33 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC PATCH v3 13/13] kasan: introduce inline instrumentation
Date: Wed, 24 Sep 2014 16:44:09 +0400
Message-id: <1411562649-28231-14-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
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
 Makefile          |  5 +++++
 lib/Kconfig.kasan | 24 ++++++++++++++++++++++++
 mm/kasan/report.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+)

diff --git a/Makefile b/Makefile
index 6cefe5e..fe7c534 100644
--- a/Makefile
+++ b/Makefile
@@ -773,6 +773,11 @@ KBUILD_CFLAGS += $(call cc-option, -fno-inline-functions-called-once)
 endif
 
 ifdef CONFIG_KASAN
+ifdef CONFIG_KASAN_INLINE
+CFLAGS_KASAN += $(call cc-option, -fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET)) \
+		 $(call cc-option, --param asan-instrumentation-with-call-threshold=10000)
+endif
+
   ifeq ($(CFLAGS_KASAN),)
     $(warning Cannot use CONFIG_KASAN: \
 	      -fsanitize=kernel-address not supported by compiler)
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index faddb0e..c4ac040 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -27,4 +27,28 @@ config TEST_KASAN
 	  out of bounds accesses, use after free. It is usefull for testing
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
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index c42f6ba..a9262f8 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -212,3 +212,48 @@ void kasan_report_user_access(struct access_info *info)
 		"=================================\n");
 	spin_unlock_irqrestore(&report_lock, flags);
 }
+
+#define CALL_KASAN_REPORT(__addr, __size, __is_write) \
+	struct access_info info;                      \
+	info.access_addr = __addr;                    \
+	info.access_size = __size;                    \
+	info.is_write = __is_write;                   \
+	info.ip = _RET_IP_;                           \
+	kasan_report_error(&info)
+
+#define DEFINE_ASAN_REPORT_LOAD(size)                     \
+void __asan_report_recover_load##size(unsigned long addr) \
+{                                                         \
+	CALL_KASAN_REPORT(addr, size, false);             \
+}                                                         \
+EXPORT_SYMBOL(__asan_report_recover_load##size)
+
+#define DEFINE_ASAN_REPORT_STORE(size)                     \
+void __asan_report_recover_store##size(unsigned long addr) \
+{                                                          \
+	CALL_KASAN_REPORT(addr, size, true);               \
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
+	CALL_KASAN_REPORT(addr, size, false);
+}
+EXPORT_SYMBOL(__asan_report_recover_load_n);
+
+void __asan_report_recover_store_n(unsigned long addr, size_t size)
+{
+	CALL_KASAN_REPORT(addr, size, true);
+}
+EXPORT_SYMBOL(__asan_report_recover_store_n);
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
