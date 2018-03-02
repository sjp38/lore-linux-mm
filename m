Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 625D96B0028
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:45:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w10so7045203wrg.2
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:45:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p15sor3634038wrh.53.2018.03.02.11.45.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 11:45:14 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 09/14] khwasan: add hooks implementation
Date: Fri,  2 Mar 2018 20:44:28 +0100
Message-Id: <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>

This commit adds KHWASAN hooks implementation.

1. When a new slab cache is created, KHWASAN rounds up the size of the
   objects in this cache to KASAN_SHADOW_SCALE_SIZE (== 16).

2. On each kmalloc KHWASAN generates a random tag, sets the shadow memory,
   that corresponds to this object to this tag, and embeds this tag value
   into the top byte of the returned pointer.

3. On each kfree KHWASAN poisons the shadow memory with a random tag to
   allow detection of use-after-free bugs.

The rest of the logic of the hook implementation is very much similar to
the one provided by KASAN. KHWASAN saves allocation and free stack metadata
to the slab object the same was KASAN does this.
---
 mm/kasan/khwasan.c | 178 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 175 insertions(+), 3 deletions(-)

diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
index 21a2221e3368..09d6f0a72266 100644
--- a/mm/kasan/khwasan.c
+++ b/mm/kasan/khwasan.c
@@ -78,69 +78,238 @@ void *khwasan_reset_tag(void *addr)
 	return reset_tag(addr);
 }
 
+void kasan_poison_shadow(const void *address, size_t size, u8 value)
+{
+	void *shadow_start, *shadow_end;
+
+	/* Perform shadow offset calculation based on untagged address */
+	address = reset_tag((void *)address);
+
+	shadow_start = kasan_mem_to_shadow(address);
+	shadow_end = kasan_mem_to_shadow(address + size);
+
+	memset(shadow_start, value, shadow_end - shadow_start);
+}
+
 void kasan_unpoison_shadow(const void *address, size_t size)
 {
+	/* KHWASAN only allows 16-byte granularity */
+	size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
+	kasan_poison_shadow(address, size, get_tag(address));
 }
 
 void check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip)
 {
+	u8 tag;
+	u8 *shadow_first, *shadow_last, *shadow;
+	void *untagged_addr;
+
+	tag = get_tag((void *)addr);
+	untagged_addr = reset_tag((void *)addr);
+	shadow_first = (u8 *)kasan_mem_to_shadow(untagged_addr);
+	shadow_last = (u8 *)kasan_mem_to_shadow(untagged_addr + size - 1);
+
+	for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
+		if (*shadow != tag) {
+			/* Report invalid-access bug here */
+			return;
+		}
+	}
 }
 
 void kasan_free_pages(struct page *page, unsigned int order)
 {
+	if (likely(!PageHighMem(page)))
+		kasan_poison_shadow(page_address(page),
+				PAGE_SIZE << order,
+				khwasan_random_tag());
 }
 
 void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 		slab_flags_t *flags)
 {
+	int orig_size = *size;
+
+	cache->kasan_info.alloc_meta_offset = *size;
+	*size += sizeof(struct kasan_alloc_meta);
+
+	if (*size % KASAN_SHADOW_SCALE_SIZE != 0)
+		*size = round_up(*size, KASAN_SHADOW_SCALE_SIZE);
+
+
+	if (*size > KMALLOC_MAX_SIZE) {
+		*size = orig_size;
+		return;
+	}
+
+	cache->align = round_up(cache->align, KASAN_SHADOW_SCALE_SIZE);
+
+	*flags |= SLAB_KASAN;
 }
 
 void kasan_poison_slab(struct page *page)
 {
+	kasan_poison_shadow(page_address(page),
+			PAGE_SIZE << compound_order(page),
+			khwasan_random_tag());
 }
 
 void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 {
+	kasan_poison_shadow(object,
+			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
+			khwasan_random_tag());
 }
 
 void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
+	if (!READ_ONCE(khwasan_enabled))
+		return object;
+	object = kasan_kmalloc(cache, object, cache->object_size, flags);
+	if (unlikely(cache->ctor)) {
+		// Cache constructor might use object's pointer value to
+		// initialize some of its fields.
+		cache->ctor(object);
+	}
 	return object;
 }
 
-bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
+static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
+				unsigned long ip)
 {
+	u8 shadow_byte;
+	u8 tag;
+	unsigned long rounded_up_size;
+	void *untagged_addr = reset_tag(object);
+
+	if (unlikely(nearest_obj(cache, virt_to_head_page(untagged_addr),
+			untagged_addr) != untagged_addr)) {
+		/* Report invalid-free here */
+		return true;
+	}
+
+	/* RCU slabs could be legally used after free within the RCU period */
+	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
+		return false;
+
+	shadow_byte = READ_ONCE(*(u8 *)kasan_mem_to_shadow(untagged_addr));
+	tag = get_tag(object);
+	if (tag != shadow_byte) {
+		/* Report invalid-free here */
+		return true;
+	}
+
+	rounded_up_size = round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE);
+	kasan_poison_shadow(object, rounded_up_size, khwasan_random_tag());
+
+	if (unlikely(!(cache->flags & SLAB_KASAN)))
+		return false;
+
+	set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
 	return false;
 }
 
+bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
+{
+	return __kasan_slab_free(cache, object, ip);
+}
+
 void *kasan_kmalloc(struct kmem_cache *cache, const void *object,
 			size_t size, gfp_t flags)
 {
-	return (void *)object;
+	unsigned long redzone_start, redzone_end;
+	u8 tag;
+
+	if (!READ_ONCE(khwasan_enabled))
+		return (void *)object;
+
+	if (unlikely(object == NULL))
+		return NULL;
+
+	redzone_start = round_up((unsigned long)(object + size),
+				KASAN_SHADOW_SCALE_SIZE);
+	redzone_end = round_up((unsigned long)(object + cache->object_size),
+				KASAN_SHADOW_SCALE_SIZE);
+
+	tag = khwasan_random_tag();
+	kasan_poison_shadow(object, redzone_start - (unsigned long)object, tag);
+	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
+		khwasan_random_tag());
+
+	if (cache->flags & SLAB_KASAN)
+		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
+
+	return set_tag((void *)object, tag);
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
 void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 {
-	return (void *)ptr;
+	unsigned long redzone_start, redzone_end;
+	u8 tag;
+	struct page *page;
+
+	if (!READ_ONCE(khwasan_enabled))
+		return (void *)ptr;
+
+	if (unlikely(ptr == NULL))
+		return NULL;
+
+	page = virt_to_page(ptr);
+	redzone_start = round_up((unsigned long)(ptr + size),
+				KASAN_SHADOW_SCALE_SIZE);
+	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
+
+	tag = khwasan_random_tag();
+	kasan_poison_shadow(ptr, redzone_start - (unsigned long)ptr, tag);
+	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
+		khwasan_random_tag());
+
+	return set_tag((void *)ptr, tag);
 }
 
 void kasan_poison_kfree(void *ptr, unsigned long ip)
 {
+	struct page *page;
+
+	page = virt_to_head_page(ptr);
+
+	if (unlikely(!PageSlab(page))) {
+		if (reset_tag(ptr) != page_address(page)) {
+			/* Report invalid-free here */
+			return;
+		}
+		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
+					khwasan_random_tag());
+	} else {
+		__kasan_slab_free(page->slab_cache, ptr, ip);
+	}
 }
 
 void kasan_kfree_large(void *ptr, unsigned long ip)
 {
+	struct page *page = virt_to_page(ptr);
+	struct page *head_page = virt_to_head_page(ptr);
+
+	if (reset_tag(ptr) != page_address(head_page)) {
+		/* Report invalid-free here */
+		return;
+	}
+
+	kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
+			khwasan_random_tag());
 }
 
 #define DEFINE_HWASAN_LOAD_STORE(size)					\
 	void __hwasan_load##size##_noabort(unsigned long addr)		\
 	{								\
+		check_memory_region(addr, size, false, _RET_IP_);	\
 	}								\
 	EXPORT_SYMBOL(__hwasan_load##size##_noabort);			\
 	void __hwasan_store##size##_noabort(unsigned long addr)		\
 	{								\
+		check_memory_region(addr, size, true, _RET_IP_);	\
 	}								\
 	EXPORT_SYMBOL(__hwasan_store##size##_noabort)
 
@@ -152,15 +321,18 @@ DEFINE_HWASAN_LOAD_STORE(16);
 
 void __hwasan_loadN_noabort(unsigned long addr, unsigned long size)
 {
+	check_memory_region(addr, size, false, _RET_IP_);
 }
 EXPORT_SYMBOL(__hwasan_loadN_noabort);
 
 void __hwasan_storeN_noabort(unsigned long addr, unsigned long size)
 {
+	check_memory_region(addr, size, true, _RET_IP_);
 }
 EXPORT_SYMBOL(__hwasan_storeN_noabort);
 
 void __hwasan_tag_memory(unsigned long addr, u8 tag, unsigned long size)
 {
+	kasan_poison_shadow((void *)addr, size, tag);
 }
 EXPORT_SYMBOL(__hwasan_tag_memory);
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
