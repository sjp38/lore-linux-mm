Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B8BA4900138
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 04:56:54 -0400 (EDT)
Subject: [PATCH 1/2] slub: remove obsolete code path in __slab_free() for
 per cpu partial
From: "Alex,Shi" <alex.shi@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 09 Sep 2011 17:02:41 +0800
Message-ID: <1315558961.31737.790.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "cl@linux.com" <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, Chen@kvack.org, Tim C <tim.c.chen@intel.com>, Huang@kvack.org, Ying <ying.huang@intel.com>

If there are still some objects left in slab, the slab page will be put
to per cpu partial list. So remove the obsolete code path.


Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 mm/slub.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 492beab..bca8eee 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2526,20 +2526,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	 */
 	if (was_frozen)
 		stat(s, FREE_FROZEN);
-	else {
-		if (unlikely(!inuse && n->nr_partial > s->min_partial))
+	else if (unlikely(!inuse && n->nr_partial > s->min_partial))
                         goto slab_empty;
 
-		/*
-		 * Objects left in the slab. If it was not on the partial list before
-		 * then add it.
-		 */
-		if (unlikely(!prior)) {
-			remove_full(s, page);
-			add_partial(n, page, 0);
-			stat(s, FREE_ADD_PARTIAL);
-		}
-	}
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return;
 
-- 
1.7.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
