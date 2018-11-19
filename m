Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B74DD6B1B9B
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 12:27:33 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id v2-v6so44126266wrn.0
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 09:27:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d70-v6sor19360358wme.3.2018.11.19.09.27.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 09:27:32 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v11 22/24] kasan: add __must_check annotations to kasan hooks
Date: Mon, 19 Nov 2018 18:26:38 +0100
Message-Id: <0a0cabf188838f1d42b417f6aadc97b8fcf5c60b.1542648335.git.andreyknvl@google.com>
In-Reply-To: <cover.1542648335.git.andreyknvl@google.com>
References: <cover.1542648335.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

This patch adds __must_check annotations to kasan hooks that return a
pointer to make sure that a tagged pointer always gets propagated.

Suggested-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/kasan.h | 16 ++++++++++------
 mm/kasan/common.c     | 14 ++++++++------
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 8da7b7a4397a..b40ea104dd36 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -49,16 +49,20 @@ void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
-void *kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
+void * __must_check kasan_init_slab_obj(struct kmem_cache *cache,
+					const void *object);
 
-void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
+void * __must_check kasan_kmalloc_large(const void *ptr, size_t size,
+						gfp_t flags);
 void kasan_kfree_large(void *ptr, unsigned long ip);
 void kasan_poison_kfree(void *ptr, unsigned long ip);
-void *kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
-		  gfp_t flags);
-void *kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
+void * __must_check kasan_kmalloc(struct kmem_cache *s, const void *object,
+					size_t size, gfp_t flags);
+void * __must_check kasan_krealloc(const void *object, size_t new_size,
+					gfp_t flags);
 
-void *kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
+void * __must_check kasan_slab_alloc(struct kmem_cache *s, void *object,
+					gfp_t flags);
 bool kasan_slab_free(struct kmem_cache *s, void *object, unsigned long ip);
 
 struct kasan_cache {
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 195ca385cf7a..ba8e78eb0c67 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -373,7 +373,7 @@ static u8 assign_tag(struct kmem_cache *cache, const void *object, bool new)
 #endif
 }
 
-void *kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
+void * __must_check kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
 {
 	struct kasan_alloc_meta *alloc_info;
 
@@ -389,7 +389,8 @@ void *kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
 	return (void *)object;
 }
 
-void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
+void * __must_check kasan_slab_alloc(struct kmem_cache *cache, void *object,
+					gfp_t flags)
 {
 	return kasan_kmalloc(cache, object, cache->object_size, flags);
 }
@@ -449,8 +450,8 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
 	return __kasan_slab_free(cache, object, ip, true);
 }
 
-void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
-		   gfp_t flags)
+void * __must_check kasan_kmalloc(struct kmem_cache *cache, const void *object,
+					size_t size, gfp_t flags)
 {
 	unsigned long redzone_start;
 	unsigned long redzone_end;
@@ -482,7 +483,8 @@ void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
-void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
+void * __must_check kasan_kmalloc_large(const void *ptr, size_t size,
+						gfp_t flags)
 {
 	struct page *page;
 	unsigned long redzone_start;
@@ -506,7 +508,7 @@ void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	return (void *)ptr;
 }
 
-void *kasan_krealloc(const void *object, size_t size, gfp_t flags)
+void * __must_check kasan_krealloc(const void *object, size_t size, gfp_t flags)
 {
 	struct page *page;
 
-- 
2.19.1.1215.g8438c0b245-goog
