Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8741A6B0032
	for <linux-mm@kvack.org>; Mon, 18 May 2015 14:29:03 -0400 (EDT)
Received: by wgjc11 with SMTP id c11so36803377wgj.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 11:29:02 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id b20si19102949wjx.55.2015.05.18.11.29.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 11:29:01 -0700 (PDT)
Received: by wibt6 with SMTP id t6so79134486wib.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 11:29:01 -0700 (PDT)
From: Leon Romanovsky <leon@leon.nu>
Subject: mm: nommu: convert kenter/kleave/kdebug macros to use pr_devel()
Date: Mon, 18 May 2015 21:28:56 +0300
Message-Id: <1431973736-21395-1-git-send-email-leon@leon.nu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, akpm@linux-foundation.org, aarcange@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Leon Romanovsky <leon@leon.nu>

kenter/kleave/kdebug are wrapper macros to print functions flow and debug
information. This set was written before pr_devel() was introduced, so
it was controlled by "#if 0" construction.

This patch refactors the current macros to use general pr_devel()
functions which won't be compiled in if "#define DEBUG" is not declared
prior to that macros.

Signed-off-by: Leon Romanovsky <leon@leon.nu>
---
 mm/nommu.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index e544508..7e5986b6 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -42,21 +42,15 @@
 #include <asm/mmu_context.h>
 #include "internal.h"
 
-#if 0
-#define kenter(FMT, ...) \
-	printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
-#define kleave(FMT, ...) \
-	printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
-#define kdebug(FMT, ...) \
-	printk(KERN_DEBUG "xxx" FMT"yyy\n", ##__VA_ARGS__)
-#else
+/*
+ * Relies on "#define DEBUG" construction to print them
+ */
 #define kenter(FMT, ...) \
-	no_printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
+	pr_devel("==> %s("FMT")\n", __func__, ##__VA_ARGS__)
 #define kleave(FMT, ...) \
-	no_printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
+	pr_devel("<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
 #define kdebug(FMT, ...) \
-	no_printk(KERN_DEBUG FMT"\n", ##__VA_ARGS__)
-#endif
+	pr_devel("xxx" FMT"yyy\n", ##__VA_ARGS__)
 
 void *high_memory;
 EXPORT_SYMBOL(high_memory);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
