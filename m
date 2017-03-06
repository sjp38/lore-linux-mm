Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 615EF6B039B
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v66so67167233wrc.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f48sor85044wrf.2.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:25 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 8/9] kasan: improve double-free report format
Date: Mon,  6 Mar 2017 17:00:08 +0100
Message-Id: <671275d2e9e3ff238e0623fc63ee5043759841bc.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Changes double-free report header from:

BUG: Double free or freeing an invalid pointer
Unexpected shadow byte: 0xFB

to:

BUG: KASAN: double-free or invalid-free in kmalloc_oob_left+0xe5/0xef

This makes a bug uniquely identifiable by the first report line.
To account for removing of the unexpected shadow value, print shadow
bytes at the end of the report as in reports for other kinds of bugs.

To print caller funtion name in the report header, the caller address
is passed from SLUB/SLAB free handlers.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/kasan.h |  2 +-
 mm/kasan/kasan.c      |  5 +++--
 mm/kasan/kasan.h      |  2 +-
 mm/kasan/report.c     | 30 ++++++++++++++----------------
 mm/slab.c             |  2 +-
 mm/slub.c             | 12 +++++++-----
 6 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index ceb3fe78a0d3..55604168f48f 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -60,7 +60,7 @@ void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
 void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
-bool kasan_slab_free(struct kmem_cache *s, void *object);
+bool kasan_slab_free(struct kmem_cache *s, void *object, unsigned long pc);
 
 struct kasan_cache {
 	int alloc_meta_offset;
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 98b27195e38b..83cc011bb9bc 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -567,7 +567,8 @@ static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
 }
 
-bool kasan_slab_free(struct kmem_cache *cache, void *object)
+bool kasan_slab_free(struct kmem_cache *cache, void *object,
+		     unsigned long pc)
 {
 	s8 shadow_byte;
 
@@ -577,7 +578,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
 	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
-		kasan_report_double_free(cache, object, shadow_byte);
+		kasan_report_double_free(cache, object, pc);
 		return true;
 	}
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 1c260e6b3b3c..75729173ade9 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -104,7 +104,7 @@ static inline bool kasan_report_enabled(void)
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
-			s8 shadow);
+					void *ip);
 
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 09a5f5b4bc79..e5b762f4a6a4 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -237,22 +237,8 @@ static void describe_object(struct kmem_cache *cache, void *object,
 	describe_object_addr(cache, object, addr);
 }
 
-void kasan_report_double_free(struct kmem_cache *cache, void *object,
-			s8 shadow)
-{
-	unsigned long flags;
-
-	kasan_start_report(&flags);
-	pr_err("BUG: Double free or freeing an invalid pointer\n");
-	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
-	dump_stack();
-	describe_object(cache, object, NULL);
-	kasan_end_report(&flags);
-}
-
-static void print_address_description(struct kasan_access_info *info)
+static void print_address_description(void *addr)
 {
-	void *addr = (void *)info->access_addr;
 	struct page *page = addr_to_page(addr);
 
 	dump_stack();
@@ -327,6 +313,18 @@ static void print_shadow_for_address(const void *addr)
 	}
 }
 
+void kasan_report_double_free(struct kmem_cache *cache, void *object,
+				void *ip)
+{
+	unsigned long flags;
+
+	kasan_start_report(&flags);
+	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", ip);
+	print_address_description(object);
+	print_shadow_for_address(object);
+	kasan_end_report(&flags);
+}
+
 static void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
@@ -338,7 +336,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 	if (!addr_has_shadow(info)) {
 		dump_stack();
 	} else {
-		print_address_description(info);
+		print_address_description((void *)info->access_addr);
 		print_shadow_for_address(info->first_bad_addr);
 	}
 
diff --git a/mm/slab.c b/mm/slab.c
index 807d86c76908..aba5f30ea63e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3508,7 +3508,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 				unsigned long caller)
 {
 	/* Put the object into the quarantine, don't touch it for now. */
-	if (kasan_slab_free(cachep, objp))
+	if (kasan_slab_free(cachep, objp, caller))
 		return;
 
 	___cache_free(cachep, objp, caller);
diff --git a/mm/slub.c b/mm/slub.c
index 7f4bc7027ed5..763570a0b15e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1325,7 +1325,8 @@ static inline void kfree_hook(const void *x)
 	kasan_kfree_large(x);
 }
 
-static inline void *slab_free_hook(struct kmem_cache *s, void *x)
+static inline void *slab_free_hook(struct kmem_cache *s, void *x,
+				   unsigned long addr)
 {
 	void *freeptr;
 
@@ -1354,12 +1355,13 @@ static inline void *slab_free_hook(struct kmem_cache *s, void *x)
 	 * kasan_slab_free() may put x into memory quarantine, delaying its
 	 * reuse. In this case the object's freelist pointer is changed.
 	 */
-	kasan_slab_free(s, x);
+	kasan_slab_free(s, x, addr);
 	return freeptr;
 }
 
 static inline void slab_free_freelist_hook(struct kmem_cache *s,
-					   void *head, void *tail)
+					   void *head, void *tail,
+					   unsigned long addr)
 {
 /*
  * Compiler cannot detect this function can be removed if slab_free_hook()
@@ -1376,7 +1378,7 @@ static inline void slab_free_freelist_hook(struct kmem_cache *s,
 	void *freeptr;
 
 	do {
-		freeptr = slab_free_hook(s, object);
+		freeptr = slab_free_hook(s, object, addr);
 	} while ((object != tail_obj) && (object = freeptr));
 #endif
 }
@@ -2958,7 +2960,7 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 				      void *head, void *tail, int cnt,
 				      unsigned long addr)
 {
-	slab_free_freelist_hook(s, head, tail);
+	slab_free_freelist_hook(s, head, tail, addr);
 	/*
 	 * slab_free_freelist_hook() could have put the items into quarantine.
 	 * If so, no need to free them.
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
