Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB1FF6B4B82
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 07:35:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b134-v6so2796070wmd.6
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 04:35:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15-v6sor1122665wmm.59.2018.08.29.04.35.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 04:35:41 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v6 08/18] khwasan: preassign tags to objects with ctors or SLAB_TYPESAFE_BY_RCU
Date: Wed, 29 Aug 2018 13:35:12 +0200
Message-Id: <95b5beb7ec13b7e998efe84c9a7a5c1fa49a9fe3.1535462971.git.andreyknvl@google.com>
In-Reply-To: <cover.1535462971.git.andreyknvl@google.com>
References: <cover.1535462971.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

An object constructor can initialize pointers within this objects based on
the address of the object. Since the object address might be tagged, we
need to assign a tag before calling constructor.

The implemented approach is to assign tags to objects with constructors
when a slab is allocated and call constructors once as usual. The
downside is that such object would always have the same tag when it is
reallocated, so we won't catch use-after-frees on it.

Also pressign tags for objects from SLAB_TYPESAFE_BY_RCU caches, since
they can be validy accessed after having been freed.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slab.c | 6 +++++-
 mm/slub.c | 4 ++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 6fdca9ec2ea4..3b4227059f2e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -403,7 +403,11 @@ static inline struct kmem_cache *virt_to_cache(const void *obj)
 static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
 				 unsigned int idx)
 {
-	return page->s_mem + cache->size * idx;
+	void *obj;
+
+	obj = page->s_mem + cache->size * idx;
+	obj = khwasan_preset_slab_tag(cache, idx, obj);
+	return obj;
 }
 
 /*
diff --git a/mm/slub.c b/mm/slub.c
index 4206e1b616e7..086d6558a6b6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1531,12 +1531,14 @@ static bool shuffle_freelist(struct kmem_cache *s, struct page *page)
 	/* First entry is used as the base of the freelist */
 	cur = next_freelist_entry(s, page, &pos, start, page_limit,
 				freelist_count);
+	cur = khwasan_preset_slub_tag(s, cur);
 	page->freelist = cur;
 
 	for (idx = 1; idx < page->objects; idx++) {
 		setup_object(s, page, cur);
 		next = next_freelist_entry(s, page, &pos, start, page_limit,
 			freelist_count);
+		next = khwasan_preset_slub_tag(s, next);
 		set_freepointer(s, cur, next);
 		cur = next;
 	}
@@ -1613,8 +1615,10 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	shuffle = shuffle_freelist(s, page);
 
 	if (!shuffle) {
+		start = khwasan_preset_slub_tag(s, start);
 		for_each_object_idx(p, idx, s, start, page->objects) {
 			setup_object(s, page, p);
+			p = khwasan_preset_slub_tag(s, p);
 			if (likely(idx < page->objects))
 				set_freepointer(s, p, p + s->size);
 			else
-- 
2.19.0.rc0.228.g281dcd1b4d0-goog
