Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB476B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 18:41:38 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so9254240pbc.3
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 15:41:37 -0700 (PDT)
From: "Bird, Tim" <Tim.Bird@sonymobile.com>
Date: Wed, 9 Oct 2013 00:40:00 +0200
Subject: revert! RE: [PATCH] slub: proper kmemleak tracking if
 CONFIG_SLUB_DEBUG disabled
Message-ID: <F5184659D418E34EA12B1903EE5EF5FD8538E86653@seldmbx02.corpusers.net>
References: <1381271832-13047-1-git-send-email-tim.bird@sonymobile.com>
In-Reply-To: <1381271832-13047-1-git-send-email-tim.bird@sonymobile.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Bird, Tim" <Tim.Bird@sonymobile.com>, "cl@linux.com" <cl@linux.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, =?iso-8859-1?Q?=22Andersson=2C_Bj=F6rn=22?= <Bjorn.Andersson@sonymobile.com>, "frowand.list@gmail.com" <frowand.list@gmail.com>, "tbird20d@gmail.com" <tbird20d@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Bobniev, Roman" <Roman.Bobniev@sonymobile.com>

Oh crud.  Please ignore.  I send the wrong patch.  Real one coming very soo=
n.
 -- Tim
________________________________________
From: Tim Bird [tim.bird@sonymobile.com]
Sent: Tuesday, October 08, 2013 3:37 PM
To: cl@linux.com; catalin.marinas@arm.com; Andersson, Bj=F6rn; frowand.list=
@gmail.com; Bird, Tim; tbird20d@gmail.com
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; Bobniev, Roman
Subject: [PATCH] slub: proper kmemleak tracking if CONFIG_SLUB_DEBUG disabl=
ed

From: Roman Bobniev <Roman.Bobniev@sonymobile.com>

Move more kmemleak calls into hook functions, and make it so
that all hooks (both inside and outside of #ifdef CONFIG_SLUB_DEBUG_ON)
call the appropriate kmemleak routines.  This allows for
kmemleak to be configured independently of slub debug features.

It also fixes a bug where kmemleak was only partially enabled
in some configurations.

Signed-off-by: Roman Bobniev <Roman.Bobniev@sonymobile.com>
Signed-off-by: Tim Bird <tim.bird@sonymobile.com>
---
 mm/slub.c | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index c3eb3d3..95e170e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -933,6 +933,11 @@ static void trace(struct kmem_cache *s, struct page *p=
age, void *object,
  * Hooks for other subsystems that check memory allocations. In a typical
  * production configuration these hooks all should produce no code at all.
  */
+static inline post_alloc_hook(void *ptr, size_t size, gfp_t flags)
+{
+       kmemleak_alloc(ptr, size, 1, flags);
+}
+
 static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
 {
        flags &=3D gfp_allowed_mask;
@@ -973,6 +978,11 @@ static inline void slab_free_hook(struct kmem_cache *s=
, void *x)
                debug_check_no_obj_freed(x, s->object_size);
 }

+static inline void free_hook(void *x)
+{
+       kmemleak_free(x);
+}
+
 /*
  * Tracking of fully allocated slabs for debugging purposes.
  *
@@ -1260,13 +1270,35 @@ static inline void inc_slabs_node(struct kmem_cache=
 *s, int node,
 static inline void dec_slabs_node(struct kmem_cache *s, int node,
                                                        int objects) {}

+/*
+ * Define the hook functions as empty of most debug code.
+ * However, leave the kmemleak calls so they can be configured
+ * independently of CONFIG_SLUB_DEBUG_ON.
+ */
+static inline post_alloc_hook(void *ptr, size_t size, gfp_t flags)
+{
+       kmemleak_alloc(ptr, size, 1, flags);
+}
+
 static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
                                                        { return 0; }

 static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
-               void *object) {}
+               void *object)
+{
+       kmemleak_alloc_recursive(object, s->object_size, 1, s->flags,
+               flags & gfp_allowed_mask);
+}

-static inline void slab_free_hook(struct kmem_cache *s, void *x) {}
+static inline void slab_free_hook(struct kmem_cache *s, void *x)
+{
+       kmemleak_free_recursive(x, s->flags);
+}
+
+static inline void free_hook(void *x)
+{
+       kmemleak_free(x);
+}

 #endif /* CONFIG_SLUB_DEBUG */

@@ -3272,7 +3304,7 @@ static void *kmalloc_large_node(size_t size, gfp_t fl=
ags, int node)
        if (page)
                ptr =3D page_address(page);

-       kmemleak_alloc(ptr, size, 1, flags);
+       post_alloc_hook(ptr, size, flags);
        return ptr;
 }

@@ -3336,7 +3368,7 @@ void kfree(const void *x)
        page =3D virt_to_head_page(x);
        if (unlikely(!PageSlab(page))) {
                BUG_ON(!PageCompound(page));
-               kmemleak_free(x);
+               free_hook(x);
                __free_memcg_kmem_pages(page, compound_order(page));
                return;
        }
--
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
