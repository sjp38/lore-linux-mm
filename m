Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A64F96B02A0
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 12:29:05 -0400 (EDT)
Message-ID: <4E8DD61B.5050009@parallels.com>
Date: Thu, 06 Oct 2011 20:23:55 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 3/5] slab_id: Slab support for IDs
References: <4E8DD5B9.4060905@parallels.com>
In-Reply-To: <4E8DD5B9.4060905@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

Just place the slab ID generation into proper places of slab.c

The slab ID value is stored right after the bufctl array.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 mm/slab.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 81a2063..f87eb25 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2183,6 +2183,10 @@ static inline size_t __slab_size(int nr_objs, unsigned long flags)
 	size_t ret;
 
 	ret = sizeof(struct slab) + nr_objs * sizeof(kmem_bufctl_t);
+#ifdef CONFIG_SLAB_OBJECT_IDS
+	if (flags & SLAB_WANT_OBJIDS)
+		ret += sizeof(u64);
+#endif
 
 	return ret;
 }
@@ -2703,6 +2707,39 @@ static inline kmem_bufctl_t *slab_bufctl(struct slab *slabp)
 	return (kmem_bufctl_t *) (slabp + 1);
 }
 
+#ifdef CONFIG_SLAB_OBJECT_IDS
+static void slab_pick_id(struct kmem_cache *c, struct slab *s)
+{
+	if (c->flags & SLAB_WANT_OBJIDS)
+		__slab_pick_id((u64 *)(slab_bufctl(s) + c->num));
+}
+
+void k_object_id(const void *x, u64 *id)
+{
+	struct page *p;
+	struct kmem_cache *c;
+	struct slab *s;
+
+	id[0] = id[1] = 0;
+
+	if (x == NULL)
+		return;
+
+	p = virt_to_head_page(x);
+	c = page_get_cache(p);
+	if (!(c->flags & SLAB_WANT_OBJIDS))
+		return;
+
+	s = page_get_slab(p);
+	__slab_get_id(id, *(u64 *)(slab_bufctl(s) + c->num),
+			obj_to_index(c, s, x));
+}
+#else
+static inline void slab_pick_id(struct kmem_cache *c, struct slab *s)
+{
+}
+#endif
+
 /*
  * Get the memory for a slab management obj.
  * For a slab cache when the slab descriptor is off-slab, slab descriptors
@@ -2743,6 +2780,7 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep, void *objp,
 	slabp->s_mem = objp + colour_off;
 	slabp->nodeid = nodeid;
 	slabp->free = 0;
+	slab_pick_id(cachep, slabp);
 	return slabp;
 }
 
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
