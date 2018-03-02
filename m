Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79F536B0025
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:45:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y11so1396455wmd.5
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:45:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z62sor625899wmb.39.2018.03.02.11.45.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 11:45:10 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 07/14] khwasan: add tag related helper functions
Date: Fri,  2 Mar 2018 20:44:26 +0100
Message-Id: <226055ec7c1a01dd8211ca9a8b34c07162be37fa.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>

This commit add a few helper functions, that are meant to be used to
work with tags embedded in the top byte of kernel pointers: to set, to
get or to reset (set to 0xff) the top byte.
---
 arch/arm64/mm/kasan_init.c |  2 ++
 include/linux/kasan.h      | 23 ++++++++++++++++++++++
 mm/kasan/kasan.h           | 23 ++++++++++++++++++++++
 mm/kasan/khwasan.c         | 39 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 87 insertions(+)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index d4bceba60010..7fd9aee88069 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -247,6 +247,8 @@ void __init kasan_init(void)
 	memset(kasan_zero_page, KASAN_SHADOW_INIT, PAGE_SIZE);
 	cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
 
+	khwasan_init();
+
 	/* At this point kasan is fully initialized. Enable error messages */
 	init_task.kasan_depth = 0;
 	pr_info("KernelAddressSanitizer initialized\n");
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index c34f413b0eac..4c656ad5762a 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -155,6 +155,29 @@ static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
 
 #define KASAN_SHADOW_INIT 0xff
 
+void khwasan_init(void);
+
+void *khwasan_set_tag(const void *addr, u8 tag);
+u8 khwasan_get_tag(void *addr);
+void *khwasan_reset_tag(void *ptr);
+
+#else /* CONFIG_KASAN_TAGS */
+
+static inline void khwasan_init(void) { }
+
+static inline void *khwasan_set_tag(const void *addr, u8 tag)
+{
+	return (void *)addr;
+}
+static inline u8 khwasan_get_tag(void *addr)
+{
+	return 0xff;
+}
+static inline void *khwasan_reset_tag(void *ptr)
+{
+	return ptr;
+}
+
 #endif /* CONFIG_KASAN_TAGS */
 
 #endif /* LINUX_KASAN_H */
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 2be31754278e..64459efbd44d 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -113,6 +113,29 @@ void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_invalid_free(void *object, unsigned long ip);
 
+#define KHWASAN_TAG_SHIFT 56
+#define KHWASAN_TAG_MASK ((u64)0xFF << KHWASAN_TAG_SHIFT)
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
+	return set_tag(addr, 0xFF);
+}
+
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
 void quarantine_reduce(void);
diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
index 24d75245e9d0..21a2221e3368 100644
--- a/mm/kasan/khwasan.c
+++ b/mm/kasan/khwasan.c
@@ -39,6 +39,45 @@
 #include "kasan.h"
 #include "../slab.h"
 
+int khwasan_enabled;
+
+static DEFINE_PER_CPU(u32, prng_state);
+
+void khwasan_init(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		per_cpu(prng_state, cpu) = get_random_u32();
+	}
+	WRITE_ONCE(khwasan_enabled, 1);
+}
+
+static inline u8 khwasan_random_tag(void)
+{
+	u32 state = this_cpu_read(prng_state);
+
+	state = 1664525 * state + 1013904223;
+	this_cpu_write(prng_state, state);
+
+	return (u8)state;
+}
+
+void *khwasan_set_tag(const void *addr, u8 tag)
+{
+	return set_tag(addr, tag);
+}
+
+u8 khwasan_get_tag(void *addr)
+{
+	return get_tag(addr);
+}
+
+void *khwasan_reset_tag(void *addr)
+{
+	return reset_tag(addr);
+}
+
 void kasan_unpoison_shadow(const void *address, size_t size)
 {
 }
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
