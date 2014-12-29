Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B607F6B006C
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:50:11 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so17530894pac.25
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 06:50:11 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id g1si40707777pdb.213.2014.12.29.06.50.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 29 Dec 2014 06:50:09 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHC00KUNMQ7Q930@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 29 Dec 2014 14:54:07 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [RFC PATCH 1/4] mm/util: add kstrdup_const
Date: Mon, 29 Dec 2014 15:48:27 +0100
Message-id: <1419864510-24834-2-git-send-email-a.hajda@samsung.com>
In-reply-to: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
References: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

The patch adds alternative version of kstrdup which returns pointer
to constant char array. The function checks if input string is in
persistent and read-only memory section, if yes it returns the input string,
otherwise it fallbacks to kstrdup.
kstrdup_const is accompanied by kfree_const performing conditional memory
deallocation of the string.

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 include/linux/string.h |  3 +++
 mm/util.c              | 22 ++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index a0c6fd5..c9cd44e 100644
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
 extern char *kstrimdup(const char *s, gfp_t gfp);
 extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
diff --git a/mm/util.c b/mm/util.c
index d25558b..7fc0094 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -13,10 +13,24 @@
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
@@ -38,6 +52,14 @@ char *kstrdup(const char *s, gfp_t gfp)
 }
 EXPORT_SYMBOL(kstrdup);
 
+const char *kstrdup_const(const char *s, gfp_t gfp)
+{
+	if (is_kernel_rodata((unsigned long)s))
+		return s;
+
+	return kstrdup(s, gfp);
+}
+
 /**
  * kstrndup - allocate space for and copy an existing string
  * @s: the string to duplicate
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
