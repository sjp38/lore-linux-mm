Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6F326B000D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:47:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c56-v6so9133419wrc.5
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:47:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 44-v6sor995944wrl.73.2018.04.20.07.47.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Apr 2018 07:47:14 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH v3 07/15] khwasan: add tag related helper functions
Date: Fri, 20 Apr 2018 16:46:45 +0200
Message-Id: <88f97e510801a331bf8a8bfd088cb5115c1281d6.1524235387.git.andreyknvl@google.com>
In-Reply-To: <cover.1524235387.git.andreyknvl@google.com>
References: <cover.1524235387.git.andreyknvl@google.com>
MIME-Version: 1.0
In-Reply-To: <cover.1524235387.git.andreyknvl@google.com>
References: <cover.1524235387.git.andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, "GitAuthor : Andrey Konovalov" <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

This commit adds a few helper functions, that are meant to be used to
work with tags embedded in the top byte of kernel pointers: to set, to
get or to reset (set to 0xff) the top byte.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/mm/kasan_init.c |  2 ++
 include/linux/kasan.h      | 23 ++++++++++++++++
 mm/kasan/kasan.h           | 55 ++++++++++++++++++++++++++++++++++++++
 mm/kasan/khwasan.c         | 48 +++++++++++++++++++++++++++++++++
 4 files changed, 128 insertions(+)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 85b21292ee68..8ef9b1bc6d81 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -250,6 +250,8 @@ void __init kasan_init(void)
 	memset(kasan_zero_page, KASAN_SHADOW_INIT, PAGE_SIZE);
 	cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
 
+	khwasan_init();
+
 	/* At this point kasan is fully initialized. Enable error messages */
 	init_task.kasan_depth = 0;
 	pr_info("KernelAddressSanitizer initialized\n");
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 336385baf926..d7624b879d86 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -155,6 +155,29 @@ static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
 
 #define KASAN_SHADOW_INIT 0xFF
 
+void khwasan_init(void);
+
+void *khwasan_set_tag(const void *addr, u8 tag);
+u8 khwasan_get_tag(const void *addr);
+void *khwasan_reset_tag(const void *ptr);
+
+#else /* CONFIG_KASAN_HW */
+
+static inline void khwasan_init(void) { }
+
+static inline void *khwasan_set_tag(const void *addr, u8 tag)
+{
+	return (void *)addr;
+}
+static inline u8 khwasan_get_tag(const void *addr)
+{
+	return 0xFF;
+}
+static inline void *khwasan_reset_tag(const void *ptr)
+{
+	return (void *)ptr;
+}
+
 #endif /* CONFIG_KASAN_HW */
 
 #endif /* LINUX_KASAN_H */
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 5091a433f266..cd51ae9d8149 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -8,6 +8,10 @@
 #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
 
+#define KHWASAN_TAG_KERNEL	0xFF /* native kernel pointers tag */
+#define KHWASAN_TAG_INVALID	0xFE /* inaccessible memory tag */
+#define KHWASAN_TAG_MAX		0xFD /* maximum value for random tags */
+
 #define KASAN_FREE_PAGE         0xFF  /* page was freed */
 #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
 #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
@@ -135,6 +139,57 @@ static inline void quarantine_reduce(void) { }
 static inline void quarantine_remove_cache(struct kmem_cache *cache) { }
 #endif
 
+#ifdef CONFIG_KASAN_HW
+
+#define KHWASAN_TAG_SHIFT 56
+#define KHWASAN_TAG_MASK (0xFFUL << KHWASAN_TAG_SHIFT)
+
+u8 random_tag(void);
+
+static inline void *set_tag(const void *addr, u8 tag)
+{
+	u64 a = (u64)addr;
+
+	a &= ~KHWASAN_TAG_MASK;
+	a |= ((u64)tag << KHWASAN_TAG_SHIFT);
+
+	return (void *)a;
+}
+
+static inline u8 get_tag(const void *addr)
+{
+	return (u8)((u64)addr >> KHWASAN_TAG_SHIFT);
+}
+
+static inline void *reset_tag(const void *addr)
+{
+	return set_tag(addr, KHWASAN_TAG_KERNEL);
+}
+
+#else /* CONFIG_KASAN_HW */
+
+static inline u8 random_tag(void)
+{
+	return 0;
+}
+
+static inline void *set_tag(const void *addr, u8 tag)
+{
+	return (void *)addr;
+}
+
+static inline u8 get_tag(const void *addr)
+{
+	return 0;
+}
+
+static inline void *reset_tag(const void *addr)
+{
+	return (void *)addr;
+}
+
+#endif /* CONFIG_KASAN_HW */
+
 /*
  * Exported functions for interfaces called from assembly or from generated
  * code. Declarations here to avoid warning about missing declarations.
diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
index e2c3a7f7fd1f..4e253c1e4d35 100644
--- a/mm/kasan/khwasan.c
+++ b/mm/kasan/khwasan.c
@@ -38,6 +38,54 @@
 #include "kasan.h"
 #include "../slab.h"
 
+static DEFINE_PER_CPU(u32, prng_state);
+
+void khwasan_init(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		per_cpu(prng_state, cpu) = get_random_u32();
+	}
+}
+
+/*
+ * If a preemption happens between this_cpu_read and this_cpu_write, the only
+ * side effect is that we'll give a few allocated in different contexts objects
+ * the same tag. Since KHWASAN is meant to be used a probabilistic bug-detection
+ * debug feature, this doesna??t have significant negative impact.
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
+	return (u8)(state % (KHWASAN_TAG_MAX + 1));
+}
+
+void *khwasan_set_tag(const void *addr, u8 tag)
+{
+	return set_tag(addr, tag);
+}
+
+u8 khwasan_get_tag(const void *addr)
+{
+	return get_tag(addr);
+}
+
+void *khwasan_reset_tag(const void *addr)
+{
+	return reset_tag(addr);
+}
+
 void check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip)
 {
-- 
2.17.0.484.g0c8726318c-goog
