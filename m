Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAC66B02A2
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 12:29:29 -0400 (EDT)
Message-ID: <4E8DD633.6060303@parallels.com>
Date: Thu, 06 Oct 2011 20:24:19 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 4/5] slab_id: Slub support for IDs
References: <4E8DD5B9.4060905@parallels.com>
In-Reply-To: <4E8DD5B9.4060905@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

Just place the slab ID generation in proper places of slub code.

The slub ID value is stored on the page->mapping field for 64-bit
kernel and at the end of the page itself for 32-bit ones. It's
stored on the same place where the slab rcu would be stored (the
need_reserve_slab_rcu functionality).

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 mm/slub.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ab9d6fc..398877a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1426,6 +1426,69 @@ static inline void *slab_reserved_space(struct kmem_cache *s, struct page *page,
 	return page_address(page) + offset;
 }
 
+#ifdef CONFIG_SLAB_OBJECT_IDS
+#define need_reserve_slab_id						\
+	(sizeof(((struct page *)NULL)->mapping) < sizeof(u64))
+
+static inline u64 *slub_id_location(struct kmem_cache *s, struct page *page)
+{
+	if (!(s->flags & SLAB_WANT_OBJIDS))
+		return NULL;
+
+	if (need_reserve_slab_id)
+		return slab_reserved_space(s, page, sizeof(u64));
+	else
+		return (u64 *)&page->mapping;
+}
+
+static void slub_pick_id(struct kmem_cache *s, struct page *page)
+{
+	u64 *s_id;
+
+	s_id = slub_id_location(s, page);
+	if (s_id != NULL)
+		__slab_pick_id(s_id);
+}
+
+static void slub_put_id(struct kmem_cache *s, struct page *p)
+{
+	/* Make buddy allocator freeing checks happy */
+	if ((!need_reserve_slab_id) && (s->flags & SLAB_WANT_OBJIDS))
+		p->mapping = NULL;
+}
+
+void k_object_id(const void *x, u64 *id)
+{
+	struct page *page;
+	u64 *s_id;
+
+	id[0] = id[1] = 0;
+
+	if (x == NULL)
+		return;
+
+	page = virt_to_head_page(x);
+	if (unlikely(!PageSlab(page)))
+		return;
+
+	s_id = slub_id_location(page->slab, page);
+	if (s_id == NULL)
+		return;
+
+	__slab_get_id(id, *s_id,
+			slab_index((void *)x, page->slab, page_address(page)));
+}
+#else
+#define need_reserve_slab_id	0
+static inline void slub_pick_id(struct page *page)
+{
+}
+
+static inline void slub_put_id(struct kmem_cache *s, struct page *p)
+{
+}
+#endif
+
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
@@ -1461,6 +1524,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	page->freelist = start;
 	page->inuse = 0;
 	page->frozen = 1;
+	slub_pick_id(s, page);
 out:
 	return page;
 }
@@ -1470,6 +1534,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	int order = compound_order(page);
 	int pages = 1 << order;
 
+	slub_put_id(s, page);
 	if (kmem_cache_debug(s)) {
 		void *p;
 
@@ -2889,6 +2954,12 @@ static int kmem_cache_open(struct kmem_cache *s,
 
 	if (need_reserve_slab_rcu && (s->flags & SLAB_DESTROY_BY_RCU))
 		s->reserved = sizeof(struct rcu_head);
+	if (need_reserve_slab_id && (s->flags & SLAB_WANT_OBJIDS))
+		/*
+		 * The id is required for alive objects only, thus it's
+		 * safe to put this in the same place with the rcu head
+		 */
+		s->reserved = max_t(int, s->reserved, sizeof(u64));
 
 	if (!calculate_sizes(s, -1))
 		goto error;
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
