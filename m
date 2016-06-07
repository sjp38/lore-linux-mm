Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E24736B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 16:12:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so87739654pfl.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 13:12:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 17si36571112pfk.177.2016.06.07.13.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 13:12:43 -0700 (PDT)
Date: Tue, 7 Jun 2016 13:12:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for Jun 6 (mm/slub.c)
Message-Id: <20160607131242.fac39cbade676df24d70edaa@linux-foundation.org>
In-Reply-To: <57565789.9050508@infradead.org>
References: <20160606142058.44b82e38@canb.auug.org.au>
	<57565789.9050508@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Thomas Garnier <thgarnie@google.com>

On Mon, 6 Jun 2016 22:11:37 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:

> On 06/05/16 21:20, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20160603:
> > 
> 
> on i386:
> 
> mm/built-in.o: In function `init_cache_random_seq':
> slub.c:(.text+0x76921): undefined reference to `cache_random_seq_create'
> mm/built-in.o: In function `__kmem_cache_release':
> (.text+0x80525): undefined reference to `cache_random_seq_destroy'

Yup.  This, I guess...

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-slub-freelist-randomization-fix

freelist_randomize(), cache_random_seq_create() and
cache_random_seq_destroy() should not be inside CONFIG_SLABINFO.

Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Thomas Garnier <thgarnie@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

--- a/mm/slab_common.c~mm-reorganize-slab-freelist-randomization-fix
+++ a/mm/slab_common.c
@@ -1030,6 +1030,53 @@ void *kmalloc_order_trace(size_t size, g
 EXPORT_SYMBOL(kmalloc_order_trace);
 #endif
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+/* Randomize a generic freelist */
+static void freelist_randomize(struct rnd_state *state, unsigned int *list,
+			size_t count)
+{
+	size_t i;
+	unsigned int rand;
+
+	for (i = 0; i < count; i++)
+		list[i] = i;
+
+	/* Fisher-Yates shuffle */
+	for (i = count - 1; i > 0; i--) {
+		rand = prandom_u32_state(state);
+		rand %= (i + 1);
+		swap(list[i], list[rand]);
+	}
+}
+
+/* Create a random sequence per cache */
+int cache_random_seq_create(struct kmem_cache *cachep, unsigned int count,
+				    gfp_t gfp)
+{
+	struct rnd_state state;
+
+	if (count < 2 || cachep->random_seq)
+		return 0;
+
+	cachep->random_seq = kcalloc(count, sizeof(unsigned int), gfp);
+	if (!cachep->random_seq)
+		return -ENOMEM;
+
+	/* Get best entropy at this stage of boot */
+	prandom_seed_state(&state, get_random_long());
+
+	freelist_randomize(&state, cachep->random_seq, count);
+	return 0;
+}
+
+/* Destroy the per-cache random freelist sequence */
+void cache_random_seq_destroy(struct kmem_cache *cachep)
+{
+	kfree(cachep->random_seq);
+	cachep->random_seq = NULL;
+}
+#endif /* CONFIG_SLAB_FREELIST_RANDOM */
+
 #ifdef CONFIG_SLABINFO
 
 #ifdef CONFIG_SLAB
@@ -1142,53 +1189,6 @@ int memcg_slab_show(struct seq_file *m,
 }
 #endif
 
-#ifdef CONFIG_SLAB_FREELIST_RANDOM
-/* Randomize a generic freelist */
-static void freelist_randomize(struct rnd_state *state, unsigned int *list,
-			size_t count)
-{
-	size_t i;
-	unsigned int rand;
-
-	for (i = 0; i < count; i++)
-		list[i] = i;
-
-	/* Fisher-Yates shuffle */
-	for (i = count - 1; i > 0; i--) {
-		rand = prandom_u32_state(state);
-		rand %= (i + 1);
-		swap(list[i], list[rand]);
-	}
-}
-
-/* Create a random sequence per cache */
-int cache_random_seq_create(struct kmem_cache *cachep, unsigned int count,
-				    gfp_t gfp)
-{
-	struct rnd_state state;
-
-	if (count < 2 || cachep->random_seq)
-		return 0;
-
-	cachep->random_seq = kcalloc(count, sizeof(unsigned int), gfp);
-	if (!cachep->random_seq)
-		return -ENOMEM;
-
-	/* Get best entropy at this stage of boot */
-	prandom_seed_state(&state, get_random_long());
-
-	freelist_randomize(&state, cachep->random_seq, count);
-	return 0;
-}
-
-/* Destroy the per-cache random freelist sequence */
-void cache_random_seq_destroy(struct kmem_cache *cachep)
-{
-	kfree(cachep->random_seq);
-	cachep->random_seq = NULL;
-}
-#endif /* CONFIG_SLAB_FREELIST_RANDOM */
-
 /*
  * slabinfo_op - iterator that generates /proc/slabinfo
  *
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
