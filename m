Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54D4E6B4947
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:56:09 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id t1so17389453wmt.5
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:56:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k1sor3064914wrx.19.2018.11.27.08.56.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:56:07 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v12 10/25] kasan: add tag related helper functions
Date: Tue, 27 Nov 2018 17:55:28 +0100
Message-Id: <643b46fbcd6433a4be18b3a19ce9f3e727618a8d.1543337629.git.andreyknvl@google.com>
In-Reply-To: <cover.1543337629.git.andreyknvl@google.com>
References: <cover.1543337629.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

This commit adds a few helper functions, that are meant to be used to
work with tags embedded in the top byte of kernel pointers: to set, to
get or to reset the top byte.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/kasan.h  |  8 +++++--
 arch/arm64/include/asm/memory.h | 12 +++++++++++
 arch/arm64/mm/kasan_init.c      |  2 ++
 include/linux/kasan.h           | 13 ++++++++++++
 mm/kasan/kasan.h                | 31 +++++++++++++++++++++++++++
 mm/kasan/tags.c                 | 37 +++++++++++++++++++++++++++++++++
 6 files changed, 101 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/kasan.h b/arch/arm64/include/asm/kasan.h
index 8758bb008436..b52aacd2c526 100644
--- a/arch/arm64/include/asm/kasan.h
+++ b/arch/arm64/include/asm/kasan.h
@@ -4,12 +4,16 @@
 
 #ifndef __ASSEMBLY__
 
-#ifdef CONFIG_KASAN
-
 #include <linux/linkage.h>
 #include <asm/memory.h>
 #include <asm/pgtable-types.h>
 
+#define arch_kasan_set_tag(addr, tag)	__tag_set(addr, tag)
+#define arch_kasan_reset_tag(addr)	__tag_reset(addr)
+#define arch_kasan_get_tag(addr)	__tag_get(addr)
+
+#ifdef CONFIG_KASAN
+
 /*
  * KASAN_SHADOW_START: beginning of the kernel virtual addresses.
  * KASAN_SHADOW_END: KASAN_SHADOW_START + 1/N of kernel virtual addresses,
diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index e2c9857157f2..83c1366a1233 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -219,6 +219,18 @@ static inline unsigned long kaslr_offset(void)
 #define untagged_addr(addr)	\
 	((__typeof__(addr))sign_extend64((u64)(addr), 55))
 
+#ifdef CONFIG_KASAN_SW_TAGS
+#define __tag_shifted(tag)	((u64)(tag) << 56)
+#define __tag_set(addr, tag)	(__typeof__(addr))( \
+		((u64)(addr) & ~__tag_shifted(0xff)) | __tag_shifted(tag))
+#define __tag_reset(addr)	untagged_addr(addr)
+#define __tag_get(addr)		(__u8)((u64)(addr) >> 56)
+#else
+#define __tag_set(addr, tag)	(addr)
+#define __tag_reset(addr)	(addr)
+#define __tag_get(addr)		0
+#endif
+
 /*
  * Physical vs virtual RAM address space conversion.  These are
  * private definitions which should NOT be used outside memory.h
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 7a4a0904cac8..1df536bdabcb 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -253,6 +253,8 @@ void __init kasan_init(void)
 	memset(kasan_early_shadow_page, KASAN_SHADOW_INIT, PAGE_SIZE);
 	cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
 
+	kasan_init_tags();
+
 	/* At this point kasan is fully initialized. Enable error messages */
 	init_task.kasan_depth = 0;
 	pr_info("KernelAddressSanitizer initialized\n");
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index c56af24bd3e7..a477ce2abdc9 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -169,6 +169,19 @@ static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
 
 #define KASAN_SHADOW_INIT 0xFF
 
+void kasan_init_tags(void);
+
+void *kasan_reset_tag(const void *addr);
+
+#else /* CONFIG_KASAN_SW_TAGS */
+
+static inline void kasan_init_tags(void) { }
+
+static inline void *kasan_reset_tag(const void *addr)
+{
+	return (void *)addr;
+}
+
 #endif /* CONFIG_KASAN_SW_TAGS */
 
 #endif /* LINUX_KASAN_H */
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 19b950eaccff..b080b8d92812 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -8,6 +8,10 @@
 #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
 
+#define KASAN_TAG_KERNEL	0xFF /* native kernel pointers tag */
+#define KASAN_TAG_INVALID	0xFE /* inaccessible memory tag */
+#define KASAN_TAG_MAX		0xFD /* maximum value for random tags */
+
 #define KASAN_FREE_PAGE         0xFF  /* page was freed */
 #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
 #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
@@ -126,6 +130,33 @@ static inline void quarantine_reduce(void) { }
 static inline void quarantine_remove_cache(struct kmem_cache *cache) { }
 #endif
 
+#ifdef CONFIG_KASAN_SW_TAGS
+
+u8 random_tag(void);
+
+#else
+
+static inline u8 random_tag(void)
+{
+	return 0;
+}
+
+#endif
+
+#ifndef arch_kasan_set_tag
+#define arch_kasan_set_tag(addr, tag)	((void *)(addr))
+#endif
+#ifndef arch_kasan_reset_tag
+#define arch_kasan_reset_tag(addr)	((void *)(addr))
+#endif
+#ifndef arch_kasan_get_tag
+#define arch_kasan_get_tag(addr)	0
+#endif
+
+#define set_tag(addr, tag)	((void *)arch_kasan_set_tag((addr), (tag)))
+#define reset_tag(addr)		((void *)arch_kasan_reset_tag(addr))
+#define get_tag(addr)		arch_kasan_get_tag(addr)
+
 /*
  * Exported functions for interfaces called from assembly or from generated
  * code. Declarations here to avoid warning about missing declarations.
diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
index 04194923c543..1c4e7ce2e6fe 100644
--- a/mm/kasan/tags.c
+++ b/mm/kasan/tags.c
@@ -38,6 +38,43 @@
 #include "kasan.h"
 #include "../slab.h"
 
+static DEFINE_PER_CPU(u32, prng_state);
+
+void kasan_init_tags(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		per_cpu(prng_state, cpu) = get_random_u32();
+}
+
+/*
+ * If a preemption happens between this_cpu_read and this_cpu_write, the only
+ * side effect is that we'll give a few allocated in different contexts objects
+ * the same tag. Since tag-based KASAN is meant to be used a probabilistic
+ * bug-detection debug feature, this doesn't have significant negative impact.
+ *
+ * Ideally the tags use strong randomness to prevent any attempts to predict
+ * them during explicit exploit attempts. But strong randomness is expensive,
+ * and we did an intentional trade-off to use a PRNG. This non-atomic RMW
+ * sequence has in fact positive effect, since interrupts that randomly skew
+ * PRNG at unpredictable points do only good.
+ */
+u8 random_tag(void)
+{
+	u32 state = this_cpu_read(prng_state);
+
+	state = 1664525 * state + 1013904223;
+	this_cpu_write(prng_state, state);
+
+	return (u8)(state % (KASAN_TAG_MAX + 1));
+}
+
+void *kasan_reset_tag(const void *addr)
+{
+	return reset_tag(addr);
+}
+
 void check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip)
 {
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
