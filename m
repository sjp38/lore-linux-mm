Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 09AC86B0257
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 13:44:36 -0500 (EST)
Received: by mail-qk0-f180.google.com with SMTP id o6so58484782qkc.2
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 10:44:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si35525866qhc.9.2016.02.15.10.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 10:44:35 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv2 3/4] slub: Convert SLAB_DEBUG_FREE to SLAB_CONSISTENCY_CHECKS
Date: Mon, 15 Feb 2016 10:44:23 -0800
Message-Id: <1455561864-4217-4-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>


SLAB_DEBUG_FREE allows expensive consistency checks at free
to be turned on or off. Expand its use to be able to turn
off all consistency checks. This gives a nice speed up if
you only want features such as poisoning or tracing.

Credit to Mathias Krause for the original work which inspired this series

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
 Documentation/vm/slub.txt |  4 +-
 include/linux/slab.h      |  2 +-
 mm/slab.h                 |  5 ++-
 mm/slub.c                 | 94 +++++++++++++++++++++++++++++------------------
 tools/vm/slabinfo.c       |  2 +-
 5 files changed, 66 insertions(+), 41 deletions(-)

diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index f0d3409..8465241 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -35,8 +35,8 @@ slub_debug=<Debug-Options>,<slab name>
 				Enable options only for select slabs
 
 Possible debug options are
-	F		Sanity checks on (enables SLAB_DEBUG_FREE. Sorry
-			SLAB legacy issues)
+	F		Sanity checks on (enables SLAB_DEBUG_CONSISTENCY_CHECKS
+			Sorry SLAB legacy issues)
 	Z		Red zoning
 	P		Poisoning (object and padding)
 	U		User tracking (free and alloc)
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3627d5c..1070daa 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -20,7 +20,7 @@
  * Flags to pass to kmem_cache_create().
  * The ones marked DEBUG are only valid if CONFIG_DEBUG_SLAB is set.
  */
-#define SLAB_DEBUG_FREE		0x00000100UL	/* DEBUG: Perform (expensive) checks on free */
+#define SLAB_CONSISTENCY_CHECKS	0x00000100UL	/* DEBUG: Perform (expensive) checks on alloc/free */
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
diff --git a/mm/slab.h b/mm/slab.h
index 834ad24..fca99be 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -121,7 +121,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
 #elif defined(CONFIG_SLUB_DEBUG)
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-			  SLAB_TRACE | SLAB_DEBUG_FREE)
+			  SLAB_TRACE | SLAB_CONSISTENCY_CHECKS)
 #else
 #define SLAB_DEBUG_FLAGS (0)
 #endif
@@ -306,7 +306,8 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 	 * to not do even the assignment. In that case, slab_equal_or_root
 	 * will also be a constant.
 	 */
-	if (!memcg_kmem_enabled() && !unlikely(s->flags & SLAB_DEBUG_FREE))
+	if (!memcg_kmem_enabled() &&
+	    !unlikely(s->flags & SLAB_CONSISTENCY_CHECKS))
 		return s;
 
 	page = virt_to_head_page(x);
diff --git a/mm/slub.c b/mm/slub.c
index 189c330..01606ff 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -160,7 +160,7 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
  */
 #define MAX_PARTIAL 10
 
-#define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
+#define DEBUG_DEFAULT_FLAGS (SLAB_CONSISTENCY_CHECKS | SLAB_RED_ZONE | \
 				SLAB_POISON | SLAB_STORE_USER)
 
 /*
@@ -1031,20 +1031,32 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 	init_tracking(s, object);
 }
 
-static noinline int alloc_debug_processing(struct kmem_cache *s,
+static inline int alloc_consistency_checks(struct kmem_cache *s,
 					struct page *page,
 					void *object, unsigned long addr)
 {
 	if (!check_slab(s, page))
-		goto bad;
+		return 0;
 
 	if (!check_valid_pointer(s, page, object)) {
 		object_err(s, page, object, "Freelist Pointer check fails");
-		goto bad;
+		return 0;
 	}
 
 	if (!check_object(s, page, object, SLUB_RED_INACTIVE))
-		goto bad;
+		return 0;
+
+	return 1;
+}
+
+static noinline int alloc_debug_processing(struct kmem_cache *s,
+					struct page *page,
+					void *object, unsigned long addr)
+{
+	if (s->flags & SLAB_CONSISTENCY_CHECKS) {
+		if (!alloc_consistency_checks(s, page, object, addr))
+			goto bad;
+	}
 
 	/* Success perform special debug activities for allocs */
 	if (s->flags & SLAB_STORE_USER)
@@ -1067,39 +1079,21 @@ bad:
 	return 0;
 }
 
-/* Supports checking bulk free of a constructed freelist */
-static noinline int free_debug_processing(
-	struct kmem_cache *s, struct page *page,
-	void *head, void *tail, int bulk_cnt,
-	unsigned long addr)
+static inline int free_consistency_checks(struct kmem_cache *s,
+		struct page *page, void *object, unsigned long addr)
 {
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-	void *object = head;
-	int cnt = 0;
-	unsigned long uninitialized_var(flags);
-	int ret = 0;
-
-	spin_lock_irqsave(&n->list_lock, flags);
-	slab_lock(page);
-
-	if (!check_slab(s, page))
-		goto out;
-
-next_object:
-	cnt++;
-
 	if (!check_valid_pointer(s, page, object)) {
 		slab_err(s, page, "Invalid object pointer 0x%p", object);
-		goto out;
+		return 0;
 	}
 
 	if (on_freelist(s, page, object)) {
 		object_err(s, page, object, "Object already free");
-		goto out;
+		return 0;
 	}
 
 	if (!check_object(s, page, object, SLUB_RED_ACTIVE))
-		goto out;
+		return 0;
 
 	if (unlikely(s != page->slab_cache)) {
 		if (!PageSlab(page)) {
@@ -1112,7 +1106,37 @@ next_object:
 		} else
 			object_err(s, page, object,
 					"page slab pointer corrupt.");
-		goto out;
+		return 0;
+	}
+	return 1;
+}
+
+/* Supports checking bulk free of a constructed freelist */
+static noinline int free_debug_processing(
+	struct kmem_cache *s, struct page *page,
+	void *head, void *tail, int bulk_cnt,
+	unsigned long addr)
+{
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	void *object = head;
+	int cnt = 0;
+	unsigned long uninitialized_var(flags);
+	int ret = 0;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	slab_lock(page);
+
+	if (s->flags & SLAB_CONSISTENCY_CHECKS) {
+		if (!check_slab(s, page))
+			goto out;
+	}
+
+next_object:
+	cnt++;
+
+	if (s->flags & SLAB_CONSISTENCY_CHECKS) {
+		if (!free_consistency_checks(s, page, object, addr))
+			goto out;
 	}
 
 	if (s->flags & SLAB_STORE_USER)
@@ -1169,7 +1193,7 @@ static int __init setup_slub_debug(char *str)
 	for (; *str && *str != ','; str++) {
 		switch (tolower(*str)) {
 		case 'f':
-			slub_debug |= SLAB_DEBUG_FREE;
+			slub_debug |= SLAB_CONSISTENCY_CHECKS;
 			break;
 		case 'z':
 			slub_debug |= SLAB_RED_ZONE;
@@ -1503,7 +1527,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	int order = compound_order(page);
 	int pages = 1 << order;
 
-	if (kmem_cache_debug(s)) {
+	if (s->flags & SLAB_CONSISTENCY_CHECKS) {
 		void *p;
 
 		slab_pad_check(s, page);
@@ -4812,16 +4836,16 @@ SLAB_ATTR_RO(total_objects);
 
 static ssize_t sanity_checks_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DEBUG_FREE));
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_CONSISTENCY_CHECKS));
 }
 
 static ssize_t sanity_checks_store(struct kmem_cache *s,
 				const char *buf, size_t length)
 {
-	s->flags &= ~SLAB_DEBUG_FREE;
+	s->flags &= ~SLAB_CONSISTENCY_CHECKS;
 	if (buf[0] == '1') {
 		s->flags &= ~__CMPXCHG_DOUBLE;
-		s->flags |= SLAB_DEBUG_FREE;
+		s->flags |= SLAB_CONSISTENCY_CHECKS;
 	}
 	return length;
 }
@@ -5356,7 +5380,7 @@ static char *create_unique_id(struct kmem_cache *s)
 		*p++ = 'd';
 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
 		*p++ = 'a';
-	if (s->flags & SLAB_DEBUG_FREE)
+	if (s->flags & SLAB_CONSISTENCY_CHECKS)
 		*p++ = 'F';
 	if (!(s->flags & SLAB_NOTRACK))
 		*p++ = 't';
diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 86e698d..1889163 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -135,7 +135,7 @@ static void usage(void)
 		"\nValid debug options (FZPUT may be combined)\n"
 		"a / A          Switch on all debug options (=FZUP)\n"
 		"-              Switch off all debug options\n"
-		"f / F          Sanity Checks (SLAB_DEBUG_FREE)\n"
+		"f / F          Sanity Checks (SLAB_CONSISTENCY_CHECKS)\n"
 		"z / Z          Redzoning\n"
 		"p / P          Poisoning\n"
 		"u / U          Tracking\n"
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
