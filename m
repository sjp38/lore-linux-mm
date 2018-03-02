Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4D966B002A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:45:17 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 96so4629618wrk.12
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:45:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j89sor3333394wrj.34.2018.03.02.11.45.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 11:45:16 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 10/14] khwasan: add bug reporting routines
Date: Fri,  2 Mar 2018 20:44:29 +0100
Message-Id: <3115fe1c7c8b4884cf646aae9f3e50dfaded7653.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>

This commit adds rountines, that print KHWASAN error reports. Those are
quite similar to KASAN, the difference is:

1. The way KHWASAN finds the first bad shadow cell (with a mismatching
   tag). KHWASAN compares memory tags from the shadow memory to the pointer
   tag.

2. KHWASAN reports all bugs with the "KASAN: invalid-access" header. This
   is done, so various external tools that already parse the kernel logs
   looking for KASAN reports wouldn't need to be changed.
---
 include/linux/kasan.h |  3 ++
 mm/kasan/kasan.h      |  2 +
 mm/kasan/khwasan.c    | 10 ++---
 mm/kasan/report.c     | 88 ++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 89 insertions(+), 14 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 4c656ad5762a..310a092d0a57 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -161,6 +161,9 @@ void *khwasan_set_tag(const void *addr, u8 tag);
 u8 khwasan_get_tag(void *addr);
 void *khwasan_reset_tag(void *ptr);
 
+void khwasan_report(unsigned long addr, size_t size, bool write,
+			unsigned long ip);
+
 #else /* CONFIG_KASAN_TAGS */
 
 static inline void khwasan_init(void) { }
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 64459efbd44d..23da304ea94c 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -136,6 +136,8 @@ static inline void *reset_tag(const void *addr)
 	return set_tag(addr, 0xFF);
 }
 
+void khwasan_report_invalid_free(void *object, unsigned long ip);
+
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
 void quarantine_reduce(void);
diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
index 09d6f0a72266..7a95d1cc4243 100644
--- a/mm/kasan/khwasan.c
+++ b/mm/kasan/khwasan.c
@@ -112,7 +112,7 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
 
 	for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
 		if (*shadow != tag) {
-			/* Report invalid-access bug here */
+			khwasan_report(addr, size, write, ret_ip);
 			return;
 		}
 	}
@@ -185,7 +185,7 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 
 	if (unlikely(nearest_obj(cache, virt_to_head_page(untagged_addr),
 			untagged_addr) != untagged_addr)) {
-		/* Report invalid-free here */
+		khwasan_report_invalid_free(object, ip);
 		return true;
 	}
 
@@ -196,7 +196,7 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 	shadow_byte = READ_ONCE(*(u8 *)kasan_mem_to_shadow(untagged_addr));
 	tag = get_tag(object);
 	if (tag != shadow_byte) {
-		/* Report invalid-free here */
+		khwasan_report_invalid_free(object, ip);
 		return true;
 	}
 
@@ -277,7 +277,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
 
 	if (unlikely(!PageSlab(page))) {
 		if (reset_tag(ptr) != page_address(page)) {
-			/* Report invalid-free here */
+			khwasan_report_invalid_free(ptr, ip);
 			return;
 		}
 		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
@@ -293,7 +293,7 @@ void kasan_kfree_large(void *ptr, unsigned long ip)
 	struct page *head_page = virt_to_head_page(ptr);
 
 	if (reset_tag(ptr) != page_address(head_page)) {
-		/* Report invalid-free here */
+		khwasan_report_invalid_free(ptr, ip);
 		return;
 	}
 
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 5c169aa688fd..ed17168a083e 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -51,10 +51,9 @@ static const void *find_first_bad_addr(const void *addr, size_t size)
 	return first_bad_addr;
 }
 
-static bool addr_has_shadow(struct kasan_access_info *info)
+static bool addr_has_shadow(const void *addr)
 {
-	return (info->access_addr >=
-		kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
+	return (addr >= kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
 }
 
 static const char *get_shadow_bug_type(struct kasan_access_info *info)
@@ -127,15 +126,14 @@ static const char *get_wild_bug_type(struct kasan_access_info *info)
 
 static const char *get_bug_type(struct kasan_access_info *info)
 {
-	if (addr_has_shadow(info))
+	if (addr_has_shadow(info->access_addr))
 		return get_shadow_bug_type(info);
 	return get_wild_bug_type(info);
 }
 
-static void print_error_description(struct kasan_access_info *info)
+static void print_error_description(struct kasan_access_info *info,
+					const char *bug_type)
 {
-	const char *bug_type = get_bug_type(info);
-
 	pr_err("BUG: KASAN: %s in %pS\n",
 		bug_type, (void *)info->ip);
 	pr_err("%s of size %zu at addr %px by task %s/%d\n",
@@ -345,10 +343,10 @@ static void kasan_report_error(struct kasan_access_info *info)
 
 	kasan_start_report(&flags);
 
-	print_error_description(info);
+	print_error_description(info, get_bug_type(info));
 	pr_err("\n");
 
-	if (!addr_has_shadow(info)) {
+	if (!addr_has_shadow(info->access_addr)) {
 		dump_stack();
 	} else {
 		print_address_description((void *)info->access_addr);
@@ -412,6 +410,78 @@ void kasan_report(unsigned long addr, size_t size,
 	kasan_report_error(&info);
 }
 
+static inline void khwasan_print_tags(const void *addr)
+{
+	u8 addr_tag = get_tag(addr);
+	void *untagged_addr = reset_tag(addr);
+	u8 *shadow = (u8 *)kasan_mem_to_shadow(untagged_addr);
+
+	pr_err("Pointer tag: [%02x], memory tag: [%02x]\n", addr_tag, *shadow);
+}
+
+static const void *khwasan_find_first_bad_addr(const void *addr, size_t size)
+{
+	u8 tag = get_tag((void *)addr);
+	void *untagged_addr = reset_tag((void *)addr);
+	u8 *shadow = (u8 *)kasan_mem_to_shadow(untagged_addr);
+	const void *first_bad_addr = untagged_addr;
+
+	while (*shadow == tag && first_bad_addr < untagged_addr + size) {
+		first_bad_addr += KASAN_SHADOW_SCALE_SIZE;
+		shadow = (u8 *)kasan_mem_to_shadow(first_bad_addr);
+	}
+	return first_bad_addr;
+}
+
+void khwasan_report(unsigned long addr, size_t size, bool write,
+			unsigned long ip)
+{
+	struct kasan_access_info info;
+	unsigned long flags;
+	void *untagged_addr = reset_tag((void *)addr);
+
+	if (likely(!kasan_report_enabled()))
+		return;
+
+	disable_trace_on_warning();
+
+	info.access_addr = (void *)addr;
+	info.first_bad_addr = khwasan_find_first_bad_addr((void *)addr, size);
+	info.access_size = size;
+	info.is_write = write;
+	info.ip = ip;
+
+	kasan_start_report(&flags);
+
+	print_error_description(&info, "invalid-access");
+	khwasan_print_tags((void *)addr);
+	pr_err("\n");
+
+	if (!addr_has_shadow(untagged_addr)) {
+		dump_stack();
+	} else {
+		print_address_description(untagged_addr);
+		pr_err("\n");
+		print_shadow_for_address(info.first_bad_addr);
+	}
+
+	kasan_end_report(&flags);
+}
+
+void khwasan_report_invalid_free(void *object, unsigned long ip)
+{
+	unsigned long flags;
+	void *untagged_addr = reset_tag((void *)object);
+
+	kasan_start_report(&flags);
+	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", (void *)ip);
+	khwasan_print_tags(object);
+	pr_err("\n");
+	print_address_description(untagged_addr);
+	pr_err("\n");
+	print_shadow_for_address(untagged_addr);
+	kasan_end_report(&flags);
+}
 
 #define DEFINE_ASAN_REPORT_LOAD(size)                     \
 void __asan_report_load##size##_noabort(unsigned long addr) \
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
