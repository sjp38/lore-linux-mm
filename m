Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D028F9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 06:00:28 -0400 (EDT)
Subject: [PATCH] slub: remove a minus instruction in get_partial_node
From: "Alex,Shi" <alex.shi@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 29 Sep 2011 18:05:16 +0800
Message-ID: <1317290716.4188.1227.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "cl@linux.com" <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

Don't do a minus action in get_partial_node function here, since
it is always zero.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 mm/slub.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 492beab..eb36a6b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1613,7 +1613,7 @@ static void *get_partial_node(struct kmem_cache *s,
 	spin_lock(&n->list_lock);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
 		void *t = acquire_slab(s, n, page, object == NULL);
-		int available;
+		int available = 0;
 
 		if (!t)
 			continue;
@@ -1623,7 +1623,6 @@ static void *get_partial_node(struct kmem_cache *s,
 			c->node = page_to_nid(page);
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
-			available =  page->objects - page->inuse;
 		} else {
 			page->freelist = t;
 			available = put_cpu_partial(s, page, 0);
-- 
1.7.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
