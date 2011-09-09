Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1B54C900138
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 05:06:15 -0400 (EDT)
Subject: [PATCH 2/2] slub: reduce a variable in __slab_free()
From: "Alex,Shi" <alex.shi@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 09 Sep 2011 17:12:01 +0800
Message-ID: <1315559521.31737.799.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "cl@linux.com" <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

After the compxchg, the new.inuse are fixed in __slab_free as a local
variable, so we don't need a extra variable for it.

This patch is also base on 'slub/partial' head of penberg's tree. 

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 mm/slub.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index bca8eee..c1f803f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2452,7 +2452,6 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	void *prior;
 	void **object = (void *)x;
 	int was_frozen;
-	int inuse;
 	struct page new;
 	unsigned long counters;
 	struct kmem_cache_node *n = NULL;
@@ -2495,7 +2494,6 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 			}
 		}
-		inuse = new.inuse;
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
@@ -2526,7 +2524,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	 */
 	if (was_frozen)
 		stat(s, FREE_FROZEN);
-	else if (unlikely(!inuse && n->nr_partial > s->min_partial))
+	else if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
                         goto slab_empty;
 
 	spin_unlock_irqrestore(&n->list_lock, flags);
-- 
1.7.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
