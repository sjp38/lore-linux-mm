Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D178C6B038A
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 15:40:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n11so108127226pfg.7
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 12:40:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f124sor163797pfb.38.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Mar 2017 12:40:32 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH tip v2] x86/mm: Correct fixmap header usage on adaptable MODULES_END
Date: Mon, 20 Mar 2017 12:40:24 -0700
Message-Id: <20170320194024.60749-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@suse.de>, Hugh Dickins <hughd@google.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, richard.weiyang@gmail.com

This patch removes fixmap headers on non-x86 code introduced by the
adaptable MODULE_END change. It is also removed in the 32-bit pgtable
header. Instead, it is added  by default in the pgtable generic header
for both architectures.

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
 arch/x86/include/asm/pgtable.h    | 1 +
 arch/x86/include/asm/pgtable_32.h | 1 -
 arch/x86/kernel/module.c          | 1 -
 arch/x86/mm/dump_pagetables.c     | 1 -
 arch/x86/mm/kasan_init_64.c       | 1 -
 mm/vmalloc.c                      | 4 ----
 6 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 6f6f351e0a81..78d1fc32e947 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -598,6 +598,7 @@ pte_t *populate_extra_pte(unsigned long vaddr);
 #include <linux/mm_types.h>
 #include <linux/mmdebug.h>
 #include <linux/log2.h>
+#include <asm/fixmap.h>
 
 static inline int pte_none(pte_t pte)
 {
diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgtable_32.h
index fbc73360aea0..bfab55675c16 100644
--- a/arch/x86/include/asm/pgtable_32.h
+++ b/arch/x86/include/asm/pgtable_32.h
@@ -14,7 +14,6 @@
  */
 #ifndef __ASSEMBLY__
 #include <asm/processor.h>
-#include <asm/fixmap.h>
 #include <linux/threads.h>
 #include <asm/paravirt.h>
 
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
