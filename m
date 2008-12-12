Return-Path: <linux-kernel-owner+w=401wt.eu-S1757515AbYLLAbo@vger.kernel.org>
Date: Fri, 12 Dec 2008 01:31:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] mm: kfree_size
Message-ID: <20081212003130.GA24497@wotan.suse.de>
References: <20081212002518.GH8294@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081212002518.GH8294@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Introduce kfree_size(). Some allocators can do a better job at kfree if the
size of the freed object is known in advance. skb layer in the networking
stack can use kfree intensively, and in that case, the size information should
be hot in cache, so it should be a win to use kfree_size here.

Allocators which don't care so much could just define kfree_size to kfree.

Thoughts? Any other good candidate callers?

---
 include/linux/slqb_def.h |   15 +++++++++++++++
 mm/slqb.c                |   12 ++++++++++++
 net/core/skbuff.c        |    7 ++++++-
 3 files changed, 33 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/slqb_def.h
===================================================================
--- linux-2.6.orig/include/linux/slqb_def.h
+++ linux-2.6/include/linux/slqb_def.h
@@ -222,6 +222,21 @@ void *__kmalloc(size_t size, gfp_t flags
 
 #define KMALLOC_HEADER (ARCH_KMALLOC_MINALIGN < sizeof(void *) ? sizeof(void *) : ARCH_KMALLOC_MINALIGN)
 
+void __kfree_size(const void *mem, size_t size);
+static __always_inline void kfree_size(void *mem, size_t size)
+{
+	if (__builtin_constant_p(size)) {
+		struct kmem_cache *s;
+
+		s = kmalloc_slab(size, 0);
+		if (unlikely(ZERO_OR_NULL_PTR(s)))
+			return;
+
+		kmem_cache_free(s, mem);
+	}
+	__kfree_size(mem, size);
+}
+
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c
+++ linux-2.6/mm/slqb.c
@@ -2118,6 +2118,18 @@ void *__kmalloc_node(size_t size, gfp_t
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
 
+void __kfree_size(const void *mem, size_t size)
+{
+	struct kmem_cache *s;
+
+	s = get_slab(size, 0);
+
+	if (unlikely(ZERO_OR_NULL_PTR(s)))
+		return;
+
+	kmem_cache_free(s, mem);
+}
+
 size_t ksize(const void *object)
 {
 	struct slqb_page *page;
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c
+++ linux-2.6/net/core/skbuff.c
@@ -336,6 +336,11 @@ static void skb_release_data(struct sk_b
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+		int size = skb->end;
+#else
+		int size = skb->end - skb->head;
+#endif
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
 			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
@@ -345,7 +350,7 @@ static void skb_release_data(struct sk_b
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
-		kfree(skb->head);
+		kfree_size(skb->head, size);
 	}
 }
 
