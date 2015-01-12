Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 45D2B6B006C
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:20:03 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so31043250pab.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:20:03 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id xn10si22564505pab.152.2015.01.12.01.20.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 12 Jan 2015 01:20:01 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI2008MI4RY2G10@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Jan 2015 09:23:58 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 1/5] mm/util: add kstrdup_const
Date: Mon, 12 Jan 2015 10:18:39 +0100
Message-id: <1421054323-14430-2-git-send-email-a.hajda@samsung.com>
In-reply-to: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

The patch adds alternative version of kstrdup which returns pointer
to constant char array. The function checks if input string is in
persistent and read-only memory section, if yes it returns the input string,
otherwise it fallbacks to kstrdup.
kstrdup_const is accompanied by kfree_const performing conditional memory
deallocation of the string.

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 include/linux/string.h |  3 +++
 mm/util.c              | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index 2e22a2e..b11ed1e 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -115,7 +115,10 @@ extern void * memchr(const void *,int,__kernel_size_t);
 #endif
 void *memchr_inv(const void *s, int c, size_t n);
 
+extern void kfree_const(const void *x);
+
 extern char *kstrdup(const char *s, gfp_t gfp);
+extern const char *kstrdup_const(const char *s, gfp_t gfp);
 extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
 extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
 
diff --git a/mm/util.c b/mm/util.c
index fec39d4..7c62128 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -12,10 +12,30 @@
 #include <linux/hugetlb.h>
 #include <linux/vmalloc.h>
 
+#include <asm/sections.h>
 #include <asm/uaccess.h>
 
 #include "internal.h"
 
+static inline int is_kernel_rodata(unsigned long addr)
+{
+	return addr >= (unsigned long)__start_rodata &&
+		addr < (unsigned long)__end_rodata;
+}
+
+/**
+ * kfree_const - conditionally free memory
+ * @x: pointer to the memory
+ *
+ * Function calls kfree only if @x is not in .rodata section.
+ */
+void kfree_const(const void *x)
+{
+	if (!is_kernel_rodata((unsigned long)x))
+		kfree(x);
+}
+EXPORT_SYMBOL(kfree_const);
+
 /**
  * kstrdup - allocate space for and copy an existing string
  * @s: the string to duplicate
@@ -38,6 +58,24 @@ char *kstrdup(const char *s, gfp_t gfp)
 EXPORT_SYMBOL(kstrdup);
 
 /**
+ * kstrdup_const - conditionally duplicate an existing const string
+ * @s: the string to duplicate
+ * @gfp: the GFP mask used in the kmalloc() call when allocating memory
+ *
+ * Function returns source string if it is in .rodata section otherwise it
+ * fallbacks to kstrdup.
+ * Strings allocated by kstrdup_const should be freed by kfree_const.
+ */
+const char *kstrdup_const(const char *s, gfp_t gfp)
+{
+	if (is_kernel_rodata((unsigned long)s))
+		return s;
+
+	return kstrdup(s, gfp);
+}
+EXPORT_SYMBOL(kstrdup_const);
+
+/**
  * kstrndup - allocate space for and copy an existing string
  * @s: the string to duplicate
  * @max: read at most @max chars from @s
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
