Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 467E56B026D
	for <linux-mm@kvack.org>; Fri, 25 May 2018 10:41:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j8-v6so3810262wrh.18
        for <linux-mm@kvack.org>; Fri, 25 May 2018 07:41:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e50-v6sor12154756wre.45.2018.05.25.07.41.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 07:41:08 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 13/16] khwasan: add hooks implementation
Date: Fri, 25 May 2018 16:40:29 +0200
Message-Id: <5793b6c9c8de0d24ae774ef8a18a9d304f11ca7d.1527259068.git.andreyknvl@google.com>
In-Reply-To: <cover.1527259068.git.andreyknvl@google.com>
References: <cover.1527259068.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

This commit adds KHWASAN specific hooks implementation and adjusts
common KASAN and KHWASAN ones.

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

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/common.c  | 83 +++++++++++++++++++++++++++++++++++-----------
 mm/kasan/khwasan.c | 40 ++++++++++++++++++++++
 2 files changed, 103 insertions(+), 20 deletions(-)

diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 3d7277cc1f5b..8123a61b7e0f 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -140,6 +140,9 @@ void kasan_poison_shadow(const void *address, size_t size, u8 value)
 {
 	void *shadow_start, *shadow_end;
 
+	/* Perform shadow offset calculation based on untagged address */
+	address = reset_tag(address);
+
 	shadow_start = kasan_mem_to_shadow(address);
 	shadow_end = kasan_mem_to_shadow(address + size);
 
@@ -148,11 +151,20 @@ void kasan_poison_shadow(const void *address, size_t size, u8 value)
 
 void kasan_unpoison_shadow(const void *address, size_t size)
 {
-	kasan_poison_shadow(address, size, 0);
+	u8 tag = get_tag(address);
+
+	/* Perform shadow offset calculation based on untagged address */
+	address = reset_tag(address);
+
+	kasan_poison_shadow(address, size, tag);
 
 	if (size & KASAN_SHADOW_MASK) {
 		u8 *shadow = (u8 *)kasan_mem_to_shadow(address + size);
-		*shadow = size & KASAN_SHADOW_MASK;
+
+		if (IS_ENABLED(CONFIG_KASAN_HW))
+			*shadow = tag;
+		else
+			*shadow = size & KASAN_SHADOW_MASK;
 	}
 }
 
@@ -200,8 +212,9 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark)
 
 void kasan_alloc_pages(struct page *page, unsigned int order)
 {
-	if (likely(!PageHighMem(page)))
-		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
+	if (unlikely(PageHighMem(page)))
+		return;
+	kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
 }
 
 void kasan_free_pages(struct page *page, unsigned int order)
@@ -235,6 +248,7 @@ void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 			slab_flags_t *flags)
 {
 	unsigned int orig_size = *size;
+	unsigned int redzone_size = 0;
 	int redzone_adjust;
 
 	/* Add alloc meta. */
@@ -242,20 +256,20 @@ void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 	*size += sizeof(struct kasan_alloc_meta);
 
 	/* Add free meta. */
-	if (cache->flags & SLAB_TYPESAFE_BY_RCU || cache->ctor ||
-	    cache->object_size < sizeof(struct kasan_free_meta)) {
+	if (IS_ENABLED(CONFIG_KASAN_GENERIC) &&
+	    (cache->flags & SLAB_TYPESAFE_BY_RCU || cache->ctor ||
+	     cache->object_size < sizeof(struct kasan_free_meta))) {
 		cache->kasan_info.free_meta_offset = *size;
 		*size += sizeof(struct kasan_free_meta);
 	}
-	redzone_adjust = optimal_redzone(cache->object_size) -
-		(*size - cache->object_size);
 
+	redzone_size = optimal_redzone(cache->object_size);
+	redzone_adjust = redzone_size -	(*size - cache->object_size);
 	if (redzone_adjust > 0)
 		*size += redzone_adjust;
 
 	*size = min_t(unsigned int, KMALLOC_MAX_SIZE,
-			max(*size, cache->object_size +
-					optimal_redzone(cache->object_size)));
+			max(*size, cache->object_size + redzone_size));
 
 	/*
 	 * If the metadata doesn't fit, don't enable KASAN at all.
@@ -268,6 +282,8 @@ void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 		return;
 	}
 
+	cache->align = round_up(cache->align, KASAN_SHADOW_SCALE_SIZE);
+
 	*flags |= SLAB_KASAN;
 }
 
@@ -325,18 +341,41 @@ void kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
 
 void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
-	return kasan_kmalloc(cache, object, cache->object_size, flags);
+	object = kasan_kmalloc(cache, object, cache->object_size, flags);
+	if (IS_ENABLED(CONFIG_KASAN_HW) && unlikely(cache->ctor)) {
+		/*
+		 * Cache constructor might use object's pointer value to
+		 * initialize some of its fields.
+		 */
+		cache->ctor(object);
+	}
+	return object;
+}
+
+static inline bool shadow_invalid(u8 tag, s8 shadow_byte)
+{
+        if (IS_ENABLED(CONFIG_KASAN_GENERIC))
+                return shadow_byte < 0 ||
+			shadow_byte >= KASAN_SHADOW_SCALE_SIZE;
+        else
+                return tag != (u8)shadow_byte;
 }
 
 static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 			      unsigned long ip, bool quarantine)
 {
 	s8 shadow_byte;
+	u8 tag;
+	void *tagged_object;
 	unsigned long rounded_up_size;
 
+	tag = get_tag(object);
+	tagged_object = object;
+	object = reset_tag(object);
+
 	if (unlikely(nearest_obj(cache, virt_to_head_page(object), object) !=
 	    object)) {
-		kasan_report_invalid_free(object, ip);
+		kasan_report_invalid_free(tagged_object, ip);
 		return true;
 	}
 
@@ -345,20 +384,22 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 		return false;
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
-	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
-		kasan_report_invalid_free(object, ip);
+	if (shadow_invalid(tag, shadow_byte)) {
+		kasan_report_invalid_free(tagged_object, ip);
 		return true;
 	}
 
 	rounded_up_size = round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE);
 	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
 
-	if (!quarantine || unlikely(!(cache->flags & SLAB_KASAN)))
+	if ((IS_ENABLED(CONFIG_KASAN_GENERIC) && !quarantine) ||
+			unlikely(!(cache->flags & SLAB_KASAN)))
 		return false;
 
 	set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
 	quarantine_put(get_free_info(cache, object), cache);
-	return true;
+
+	return IS_ENABLED(CONFIG_KASAN_GENERIC);
 }
 
 bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
@@ -371,6 +412,7 @@ void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 {
 	unsigned long redzone_start;
 	unsigned long redzone_end;
+	u8 tag;
 
 	if (gfpflags_allow_blocking(flags))
 		quarantine_reduce();
@@ -383,14 +425,15 @@ void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	redzone_end = round_up((unsigned long)object + cache->object_size,
 				KASAN_SHADOW_SCALE_SIZE);
 
-	kasan_unpoison_shadow(object, size);
+	tag = random_tag();
+	kasan_unpoison_shadow(set_tag(object, tag), size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
 
 	if (cache->flags & SLAB_KASAN)
 		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
 
-	return (void *)object;
+	return set_tag(object, tag);
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
@@ -440,7 +483,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
 	page = virt_to_head_page(ptr);
 
 	if (unlikely(!PageSlab(page))) {
-		if (ptr != page_address(page)) {
+		if (reset_tag(ptr) != page_address(page)) {
 			kasan_report_invalid_free(ptr, ip);
 			return;
 		}
@@ -453,7 +496,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
 
 void kasan_kfree_large(void *ptr, unsigned long ip)
 {
-	if (ptr != page_address(virt_to_head_page(ptr)))
+	if (reset_tag(ptr) != page_address(virt_to_head_page(ptr)))
 		kasan_report_invalid_free(ptr, ip);
 	/* The object will be poisoned by page_alloc. */
 }
diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
index d34679b8f8c7..fd1725022794 100644
--- a/mm/kasan/khwasan.c
+++ b/mm/kasan/khwasan.c
@@ -88,15 +88,52 @@ void *khwasan_reset_tag(const void *addr)
 void check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip)
 {
+	u8 tag;
+	u8 *shadow_first, *shadow_last, *shadow;
+	void *untagged_addr;
+
+	tag = get_tag((const void *)addr);
+
+	/* Ignore accesses for pointers tagged with 0xff (native kernel
+	 * pointer tag) to suppress false positives caused by kmap.
+	 *
+	 * Some kernel code was written to account for archs that don't keep
+	 * high memory mapped all the time, but rather map and unmap particular
+	 * pages when needed. Instead of storing a pointer to the kernel memory,
+	 * this code saves the address of the page structure and offset within
+	 * that page for later use. Those pages are then mapped and unmapped
+	 * with kmap/kunmap when necessary and virt_to_page is used to get the
+	 * virtual address of the page. For arm64 (that keeps the high memory
+	 * mapped all the time), kmap is turned into a page_address call.
+
+	 * The issue is that with use of the page_address + virt_to_page
+	 * sequence the top byte value of the original pointer gets lost (gets
+	 * set to KHWASAN_TAG_KERNEL (0xFF).
+	 */
+	if (tag == KHWASAN_TAG_KERNEL)
+		return;
+
+	untagged_addr = reset_tag((const void *)addr);
+	shadow_first = kasan_mem_to_shadow(untagged_addr);
+	shadow_last = kasan_mem_to_shadow(untagged_addr + size - 1);
+
+	for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
+		if (*shadow != tag) {
+			kasan_report(addr, size, write, ret_ip);
+			return;
+		}
+	}
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
 
@@ -108,15 +145,18 @@ DEFINE_HWASAN_LOAD_STORE(16);
 
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
2.17.0.921.gf22659ad46-goog
