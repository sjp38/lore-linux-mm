Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 5139E6B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 02:08:50 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id eb20so13394432lab.15
        for <linux-mm@kvack.org>; Tue, 25 Jun 2013 23:08:48 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH] list_lru: per-node list infrastructure fix
Date: Wed, 26 Jun 2013 02:08:14 -0400
Message-Id: <1372226894-6835-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>

After a while investigating, it seems to us that the imbalance we are
seeing are due to a multi-node race already in tree (our guess). Although
the WARN is useful to show us the race, BUG_ON is too much, since it seems
the kernel should be fine going on after that.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
---
Andrew: This will create a small and trivial conflict with the next patch.
Although is trivially resolvable, please tell me if you would prefer a patch on
top instead of a fix to be folded given this situation.

 mm/list_lru.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index f2d1d6e..1efe4ec 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -15,7 +15,7 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 	struct list_lru_node *nlru = &lru->node[nid];
 
 	spin_lock(&nlru->lock);
-	BUG_ON(nlru->nr_items < 0);
+	WARN_ON_ONCE(nlru->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &nlru->list);
 		if (nlru->nr_items++ == 0)
@@ -38,7 +38,7 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 		list_del_init(item);
 		if (--nlru->nr_items == 0)
 			node_clear(nid, lru->active_nodes);
-		BUG_ON(nlru->nr_items < 0);
+		WARN_ON_ONCE(nlru->nr_items < 0);
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -56,7 +56,7 @@ unsigned long list_lru_count(struct list_lru *lru)
 		struct list_lru_node *nlru = &lru->node[nid];
 
 		spin_lock(&nlru->lock);
-		BUG_ON(nlru->nr_items < 0);
+		WARN_ON_ONCE(nlru->nr_items < 0);
 		count += nlru->nr_items;
 		spin_unlock(&nlru->lock);
 	}
@@ -91,7 +91,7 @@ restart:
 		case LRU_REMOVED:
 			if (--nlru->nr_items == 0)
 				node_clear(nid, lru->active_nodes);
-			BUG_ON(nlru->nr_items < 0);
+			WARN_ON_ONCE(nlru->nr_items < 0);
 			isolated++;
 			break;
 		case LRU_ROTATE:
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
