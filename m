Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B49396B0271
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 10:29:20 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 61so1673896wrg.9
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 07:29:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q3sor8951142wrd.74.2018.01.11.07.29.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 07:29:19 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 2/2] kasan: clean up KASAN_SHADOW_SCALE_SHIFT usage
Date: Thu, 11 Jan 2018 16:29:09 +0100
Message-Id: <ff221eca3db7a1f208c30c625b7d209fba33abb9.1515684162.git.andreyknvl@google.com>
In-Reply-To: <cover.1515684162.git.andreyknvl@google.com>
References: <cover.1515684162.git.andreyknvl@google.com>
In-Reply-To: <cover.1515684162.git.andreyknvl@google.com>
References: <cover.1515684162.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <andreyknvl@google.com>

Right now the fact that KASAN uses a single shadow byte for 8 bytes of
memory is scattered all over the code.

This change defines KASAN_SHADOW_SCALE_SHIFT early in asm include files
and makes use of this constant where necessary.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/kasan.h  | 3 ++-
 arch/arm64/include/asm/memory.h | 3 ++-
 arch/arm64/mm/kasan_init.c      | 3 ++-
 arch/x86/include/asm/kasan.h    | 8 ++++++--
 include/linux/kasan.h           | 2 --
 5 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/arch/arm64/include/asm/kasan.h b/arch/arm64/include/asm/kasan.h
index e266f80e45b7..811643fe7640 100644
--- a/arch/arm64/include/asm/kasan.h
+++ b/arch/arm64/include/asm/kasan.h
@@ -27,7 +27,8 @@
  * should satisfy the following equation:
  *      KASAN_SHADOW_OFFSET = KASAN_SHADOW_END - (1ULL << 61)
  */
-#define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << (64 - 3)))
+#define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << \
+					(64 - KASAN_SHADOW_SCALE_SHIFT)))
 
 void kasan_init(void);
 void kasan_copy_shadow(pgd_t *pgdir);
diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index d4bae7d6e0d8..50fa96a49792 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -85,7 +85,8 @@
  * stack size when KASAN is in use.
  */
 #ifdef CONFIG_KASAN
-#define KASAN_SHADOW_SIZE	(UL(1) << (VA_BITS - 3))
+#define KASAN_SHADOW_SCALE_SHIFT 3
+#define KASAN_SHADOW_SIZE	(UL(1) << (VA_BITS - KASAN_SHADOW_SCALE_SHIFT))
 #define KASAN_THREAD_SHIFT	1
 #else
 #define KASAN_SHADOW_SIZE	(0)
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index acba49fb5aac..6e02e6fb4c7b 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -135,7 +135,8 @@ static void __init kasan_pgd_populate(unsigned long addr, unsigned long end,
 /* The early shadow maps everything to a single page of zeroes */
 asmlinkage void __init kasan_early_init(void)
 {
-	BUILD_BUG_ON(KASAN_SHADOW_OFFSET != KASAN_SHADOW_END - (1UL << 61));
+	BUILD_BUG_ON(KASAN_SHADOW_OFFSET !=
+		KASAN_SHADOW_END - (1UL << (64 - KASAN_SHADOW_SCALE_SHIFT)));
 	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_START, PGDIR_SIZE));
 	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
 	kasan_pgd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, NUMA_NO_NODE,
diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index b577dd0916aa..737b7ea9bea3 100644
--- a/arch/x86/include/asm/kasan.h
+++ b/arch/x86/include/asm/kasan.h
@@ -4,6 +4,7 @@
 
 #include <linux/const.h>
 #define KASAN_SHADOW_OFFSET _AC(CONFIG_KASAN_SHADOW_OFFSET, UL)
+#define KASAN_SHADOW_SCALE_SHIFT 3
 
 /*
  * Compiler uses shadow offset assuming that addresses start
@@ -12,12 +13,15 @@
  * 'kernel address space start' >> KASAN_SHADOW_SCALE_SHIFT
  */
 #define KASAN_SHADOW_START      (KASAN_SHADOW_OFFSET + \
-					((-1UL << __VIRTUAL_MASK_SHIFT) >> 3))
+					((-1UL << __VIRTUAL_MASK_SHIFT) >> \
+						KASAN_SHADOW_SCALE_SHIFT))
 /*
  * 47 bits for kernel address -> (47 - 3) bits for shadow
  * 56 bits for kernel address -> (56 - 3) bits for shadow
  */
-#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (__VIRTUAL_MASK_SHIFT - 3)))
+#define KASAN_SHADOW_END        (KASAN_SHADOW_START + \
+					(1ULL << (__VIRTUAL_MASK_SHIFT - \
+						  KASAN_SHADOW_SCALE_SHIFT)))
 
 #ifndef __ASSEMBLY__
 
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index e3eb834c9a35..e9eaa964473a 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -11,8 +11,6 @@ struct task_struct;
 
 #ifdef CONFIG_KASAN
 
-#define KASAN_SHADOW_SCALE_SHIFT 3
-
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
 
-- 
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
