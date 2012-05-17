Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id ED9586B00F1
	for <linux-mm@kvack.org>; Thu, 17 May 2012 11:50:17 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id p5so3846917dak.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 08:50:17 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 4/4] slub: refactoring unfreeze_partials()
Date: Fri, 18 May 2012 00:47:48 +0900
Message-Id: <1337269668-4619-5-git-send-email-js1304@gmail.com>
In-Reply-To: <1337269668-4619-1-git-send-email-js1304@gmail.com>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

Current implementation of unfreeze_partials() is so complicated,
but benefit from it is insignificant. In addition many code in
do {} while loop have a bad influence to a fail rate of cmpxchg_double_slab.
Under current implementation which test status of cpu partial slab
and acquire list_lock in do {} while loop,
we don't need to acquire a list_lock and gain a little benefit
when front of the cpu partial slab is to be discarded, but this is a rare case.
In case that add_partial is performed and cmpxchg_double_slab is failed,
remove_partial should be called case by case.

I think that these are disadvantages of current implementation,
so I do refactoring unfreeze_partials().

Minimizing code in do {} while loop introduce a reduced fail rate
of cmpxchg_double_slab. Below is output of 'slabinfo -r kmalloc-256'
when './perf stat -r 33 hackbench 50 process 4000 > /dev/null' is done.

** before **
Cmpxchg_double Looping
------------------------
Locked Cmpxchg Double redos   182685
Unlocked Cmpxchg Double redos 0

** after **
Cmpxchg_double Looping
------------------------
Locked Cmpxchg Double redos   177995
Unlocked Cmpxchg Double redos 1

We can see cmpxchg_double_slab fail rate is improved slightly.

Bolow is output of './perf stat -r 30 hackbench 50 process 4000 > /dev/null'.

** before **
 Performance counter stats for './hackbench 50 process 4000' (30 runs):

     108517.190463 task-clock                #    7.926 CPUs utilized            ( +-  0.24% )
         2,919,550 context-switches          #    0.027 M/sec                    ( +-  3.07% )
           100,774 CPU-migrations            #    0.929 K/sec                    ( +-  4.72% )
           124,201 page-faults               #    0.001 M/sec                    ( +-  0.15% )
   401,500,234,387 cycles                    #    3.700 GHz                      ( +-  0.24% )
   <not supported> stalled-cycles-frontend
   <not supported> stalled-cycles-backend
   250,576,913,354 instructions              #    0.62  insns per cycle          ( +-  0.13% )
    45,934,956,860 branches                  #  423.297 M/sec                    ( +-  0.14% )
       188,219,787 branch-misses             #    0.41% of all branches          ( +-  0.56% )

      13.691837307 seconds time elapsed                                          ( +-  0.24% )

** after **
 Performance counter stats for './hackbench 50 process 4000' (30 runs):

     107784.479767 task-clock                #    7.928 CPUs utilized            ( +-  0.22% )
         2,834,781 context-switches          #    0.026 M/sec                    ( +-  2.33% )
            93,083 CPU-migrations            #    0.864 K/sec                    ( +-  3.45% )
           123,967 page-faults               #    0.001 M/sec                    ( +-  0.15% )
   398,781,421,836 cycles                    #    3.700 GHz                      ( +-  0.22% )
   <not supported> stalled-cycles-frontend
   <not supported> stalled-cycles-backend
   250,189,160,419 instructions              #    0.63  insns per cycle          ( +-  0.09% )
    45,855,370,128 branches                  #  425.436 M/sec                    ( +-  0.10% )
       169,881,248 branch-misses             #    0.37% of all branches          ( +-  0.43% )

      13.596272341 seconds time elapsed                                          ( +-  0.22% )

No regression is found, but rather we can see slightly better result.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 69342fd..eebb6d0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1882,18 +1882,24 @@ redo:
 /* Unfreeze all the cpu partial slabs */
 static void unfreeze_partials(struct kmem_cache *s)
 {
-	struct kmem_cache_node *n = NULL;
+	struct kmem_cache_node *n = NULL, *n2 = NULL;
 	struct kmem_cache_cpu *c = this_cpu_ptr(s->cpu_slab);
 	struct page *page, *discard_page = NULL;
 
 	while ((page = c->partial)) {
-		enum slab_modes { M_PARTIAL, M_FREE };
-		enum slab_modes l, m;
 		struct page new;
 		struct page old;
 
 		c->partial = page->next;
-		l = M_FREE;
+
+		n2 = get_node(s, page_to_nid(page));
+		if (n != n2) {
+			if (n)
+				spin_unlock(&n->list_lock);
+
+			n = n2;
+			spin_lock(&n->list_lock);
+		}
 
 		do {
 
@@ -1906,43 +1912,17 @@ static void unfreeze_partials(struct kmem_cache *s)
 
 			new.frozen = 0;
 
-			if (!new.inuse && (!n || n->nr_partial > s->min_partial))
-				m = M_FREE;
-			else {
-				struct kmem_cache_node *n2 = get_node(s,
-							page_to_nid(page));
-
-				m = M_PARTIAL;
-				if (n != n2) {
-					if (n)
-						spin_unlock(&n->list_lock);
-
-					n = n2;
-					spin_lock(&n->list_lock);
-				}
-			}
-
-			if (l != m) {
-				if (l == M_PARTIAL) {
-					remove_partial(n, page);
-					stat(s, FREE_REMOVE_PARTIAL);
-				} else {
-					add_partial(n, page,
-						DEACTIVATE_TO_TAIL);
-					stat(s, FREE_ADD_PARTIAL);
-				}
-
-				l = m;
-			}
-
 		} while (!__cmpxchg_double_slab(s, page,
 				old.freelist, old.counters,
 				new.freelist, new.counters,
 				"unfreezing slab"));
 
-		if (m == M_FREE) {
+		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
 			page->next = discard_page;
 			discard_page = page;
+		} else {
+			add_partial(n, page, DEACTIVATE_TO_TAIL);
+			stat(s, FREE_ADD_PARTIAL);
 		}
 	}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
