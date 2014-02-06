Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8976B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:00:16 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id d49so1187638eek.6
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:00:15 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x7si2997454eef.114.2014.02.06.08.41.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 08:42:10 -0800 (PST)
Date: Thu, 6 Feb 2014 11:41:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2014-02-05 list_lru_add lockdep splat
Message-ID: <20140206164136.GC6963@cmpxchg.org>
References: <alpine.LSU.2.11.1402051944210.27326@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402051944210.27326@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hugh,

On Wed, Feb 05, 2014 at 07:50:10PM -0800, Hugh Dickins wrote:
> ======================================================
> [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
> 3.14.0-rc1-mm1 #1 Not tainted
> ------------------------------------------------------
> kswapd0/48 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
>  (&(&lru->node[i].lock)->rlock){+.+.-.}, at: [<ffffffff81117064>] list_lru_add+0x80/0xf4
> 
> s already holding:
>  (&(&mapping->tree_lock)->rlock){..-.-.}, at: [<ffffffff81108c63>] __remove_mapping+0x3b/0x12d
> which would create a new lock dependency:
>  (&(&mapping->tree_lock)->rlock){..-.-.} -> (&(&lru->node[i].lock)->rlock){+.+.-.}

Thanks for the report.  The first time I saw this on my own machine, I
misinterpreted it as a false positive (could have sworn the "possible
unsafe scenario" section looked different, too).

Looking at it again, there really is a deadlock scenario when the
shadow shrinker races with a page cache insertion or deletion and is
interrupted by the IO completion handler while holding the list_lru
lock:

>  Possible interrupt unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(&(&lru->node[i].lock)->rlock);
>                                local_irq_disable();
>                                lock(&(&mapping->tree_lock)->rlock);
>                                lock(&(&lru->node[i].lock)->rlock);
>   <Interrupt>
>     lock(&(&mapping->tree_lock)->rlock);

Could you please try with the following patch?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: keep page cache radix tree nodes in check fix

Hugh Dickin reports the following lockdep splat:

======================================================
[ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
3.14.0-rc1-mm1 #1 Not tainted
------------------------------------------------------
kswapd0/48 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
 (&(&lru->node[i].lock)->rlock){+.+.-.}, at: [<ffffffff81117064>] list_lru_add+0x80/0xf4

s already holding:
 (&(&mapping->tree_lock)->rlock){..-.-.}, at: [<ffffffff81108c63>] __remove_mapping+0x3b/0x12d
which would create a new lock dependency:
 (&(&mapping->tree_lock)->rlock){..-.-.} -> (&(&lru->node[i].lock)->rlock){+.+.-.}

lru->node[i].lock nests inside the mapping->tree_lock when page cache
insertions and deletions add or remove radix tree nodes to the shadow
LRU list.

However, paths that only hold the IRQ-unsafe lru->node[i].lock, like
the shadow shrinker, can be interrupted at any time by the IO
completion handler, which in turn acquires the mapping->tree_lock.
This is a simple locking order inversion and can deadlock like so:

CPU#0: shadow shrinker          CPU#1: page cache modification
lru->node[i].lock
                                mapping->tree_lock
                                lru->node[i].lock
<interrupt>
mapping->tree_lock

Make the shadow lru->node[i].lock IRQ-safe to remove the order
dictated by interruption.  This slightly increases the IRQ-disabled
section in the shadow shrinker, but it still drops all locks and
enables IRQ after every reclaimed shadow radix tree node.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/list_lru.h |  6 +++++-
 mm/list_lru.c            |  4 +++-
 mm/workingset.c          | 24 ++++++++++++++++++++----
 3 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index b02fc233eadd..f3434533fbf8 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -34,7 +34,11 @@ struct list_lru {
 };
 
 void list_lru_destroy(struct list_lru *lru);
-int list_lru_init(struct list_lru *lru);
+int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key);
+static inline int list_lru_init(struct list_lru *lru)
+{
+	return list_lru_init_key(lru, NULL);
+}
 
 /**
  * list_lru_add: add an element to the lru list's tail
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 7f5b73e2513b..2a5b8fd45669 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -124,7 +124,7 @@ restart:
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-int list_lru_init(struct list_lru *lru)
+int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
@@ -136,6 +136,8 @@ int list_lru_init(struct list_lru *lru)
 	nodes_clear(lru->active_nodes);
 	for (i = 0; i < nr_node_ids; i++) {
 		spin_lock_init(&lru->node[i].lock);
+		if (key)
+			lockdep_set_class(&lru->node[i].lock, key);
 		INIT_LIST_HEAD(&lru->node[i].list);
 		lru->node[i].nr_items = 0;
 	}
diff --git a/mm/workingset.c b/mm/workingset.c
index 33429c7ddec5..20aa16754305 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -273,7 +273,10 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	unsigned long max_nodes;
 	unsigned long pages;
 
+	local_irq_disable();
 	shadow_nodes = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
+	local_irq_enable();
+
 	pages = node_present_pages(sc->nid);
 	/*
 	 * Active cache pages are limited to 50% of memory, and shadow
@@ -322,7 +325,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	mapping = node->private_data;
 
 	/* Coming from the list, invert the lock order */
-	if (!spin_trylock_irq(&mapping->tree_lock)) {
+	if (!spin_trylock(&mapping->tree_lock)) {
 		spin_unlock(lru_lock);
 		ret = LRU_RETRY;
 		goto out;
@@ -355,10 +358,12 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	if (!__radix_tree_delete_node(&mapping->page_tree, node))
 		BUG();
 
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock(&mapping->tree_lock);
 	ret = LRU_REMOVED_RETRY;
 out:
+	local_irq_enable();
 	cond_resched();
+	local_irq_disable();
 	spin_lock(lru_lock);
 	return ret;
 }
@@ -366,8 +371,13 @@ out:
 static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 				       struct shrink_control *sc)
 {
-	return list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
+	unsigned long ret;
+
+	local_irq_disable();
+	ret =  list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
 				  shadow_lru_isolate, NULL, &sc->nr_to_scan);
+	local_irq_enable();
+	return ret;
 }
 
 static struct shrinker workingset_shadow_shrinker = {
@@ -377,11 +387,17 @@ static struct shrinker workingset_shadow_shrinker = {
 	.flags = SHRINKER_NUMA_AWARE,
 };
 
+/*
+ * Our list_lru->lock is IRQ-safe as it nests inside the IRQ-safe
+ * mapping->tree_lock.
+ */
+static struct lock_class_key shadow_nodes_key;
+
 static int __init workingset_init(void)
 {
 	int ret;
 
-	ret = list_lru_init(&workingset_shadow_nodes);
+	ret = list_lru_init_key(&workingset_shadow_nodes, &shadow_nodes_key);
 	if (ret)
 		goto err;
 	ret = register_shrinker(&workingset_shadow_shrinker);
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
