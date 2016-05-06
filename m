Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3D3C6B0253
	for <linux-mm@kvack.org>; Fri,  6 May 2016 08:45:10 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u185so208638723oie.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 05:45:10 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0103.outbound.protection.outlook.com. [157.56.112.103])
        by mx.google.com with ESMTPS id tt9si7428667obb.74.2016.05.06.05.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 May 2016 05:45:09 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 3/4] mm/kasan: add API to check memory regions
Date: Fri, 6 May 2016 15:45:21 +0300
Message-ID: <1462538722-1574-3-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1462538722-1574-1-git-send-email-aryabinin@virtuozzo.com>
References: <1462538722-1574-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

Memory access coded in an assembly won't be seen by KASAN as a compiler
can instrument only C code. Add kasan_check_[read,write]() API
which is going to be used to check a certain memory range.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
---
 MAINTAINERS                  |  2 +-
 include/linux/kasan-checks.h | 12 ++++++++++++
 mm/kasan/kasan.c             | 12 ++++++++++++
 3 files changed, 25 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/kasan-checks.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 43b85c1..3a9471c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6363,7 +6363,7 @@ S:	Maintained
 F:	arch/*/include/asm/kasan.h
 F:	arch/*/mm/kasan_init*
 F:	Documentation/kasan.txt
-F:	include/linux/kasan.h
+F:	include/linux/kasan*.h
 F:	lib/test_kasan.c
 F:	mm/kasan/
 F:	scripts/Makefile.kasan
diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
new file mode 100644
index 0000000..b7f8ace
--- /dev/null
+++ b/include/linux/kasan-checks.h
@@ -0,0 +1,12 @@
+#ifndef _LINUX_KASAN_CHECKS_H
+#define _LINUX_KASAN_CHECKS_H
+
+#ifdef CONFIG_KASAN
+void kasan_check_read(const void *p, unsigned int size);
+void kasan_check_write(const void *p, unsigned int size);
+#else
+static inline void kasan_check_read(const void *p, unsigned int size) { }
+static inline void kasan_check_write(const void *p, unsigned int size) { }
+#endif
+
+#endif
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 6e4072c..54f0ea7 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -299,6 +299,18 @@ static void check_memory_region(unsigned long addr,
 	check_memory_region_inline(addr, size, write, ret_ip);
 }
 
+void kasan_check_read(const void *p, unsigned int size)
+{
+	check_memory_region((unsigned long)p, size, false, _RET_IP_);
+}
+EXPORT_SYMBOL(kasan_check_read);
+
+void kasan_check_write(const void *p, unsigned int size)
+{
+	check_memory_region((unsigned long)p, size, true, _RET_IP_);
+}
+EXPORT_SYMBOL(kasan_check_write);
+
 #undef memset
 void *memset(void *addr, int c, size_t len)
 {
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
