Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 316C66B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 13:51:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p189so52612059pfp.5
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:51:02 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id 34si9314138plz.66.2017.03.17.10.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 10:51:01 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id x63so35100914pfx.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:51:01 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH tip] x86/mm: Correct fixmap header usage on adaptable MODULES_END
Date: Fri, 17 Mar 2017 10:50:34 -0700
Message-Id: <20170317175034.4701-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Garnier <thgarnie@google.com>

This patch remove fixmap header usage on non-x86 code that was
introduced by the adaptable MODULE_END change.

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
Based on tip:x86/mm
---
 arch/x86/include/asm/pgtable_64.h | 1 +
 arch/x86/kernel/module.c          | 1 -
 arch/x86/mm/dump_pagetables.c     | 1 -
 arch/x86/mm/kasan_init_64.c       | 1 -
 mm/vmalloc.c                      | 4 ----
 5 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 73c7ccc38912..67608d4abc2c 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -13,6 +13,7 @@
 #include <asm/processor.h>
 #include <linux/bitops.h>
 #include <linux/threads.h>
+#include <asm/fixmap.h>
 
 extern pud_t level3_kernel_pgt[512];
 extern pud_t level3_ident_pgt[512];
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index fad61caac75e..477ae806c2fa 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -35,7 +35,6 @@
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/setup.h>
-#include <asm/fixmap.h>
 
 #if 0
 #define DEBUGP(fmt, ...)				\
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 75efeecc85eb..58b5bee7ea27 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -20,7 +20,6 @@
 
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
-#include <asm/fixmap.h>
 
 /*
  * The dumper groups pagetable entries of the same type into one, and for
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 1bde19ef86bd..8d63d7a104c3 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -9,7 +9,6 @@
 
 #include <asm/tlbflush.h>
 #include <asm/sections.h>
-#include <asm/fixmap.h>
 
 extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_X_MAX];
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b7d2a23349f4..0dd80222b20b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -36,10 +36,6 @@
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
-#ifdef CONFIG_X86
-# include <asm/fixmap.h>
-#endif
-
 #include "internal.h"
 
 struct vfree_deferred {
-- 
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
