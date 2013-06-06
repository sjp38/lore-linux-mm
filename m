Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B03116B003A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:42 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 08/25] list: add a new LRU list type
Date: Fri,  7 Jun 2013 00:34:41 +0400
Message-Id: <1370550898-26711-9-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>

From: Dave Chinner <dchinner@redhat.com>

Several subsystems use the same construct for LRU lists - a list
head, a spin lock and and item count. They also use exactly the same
code for adding and removing items from the LRU. Create a generic
type for these LRU lists.

This is the beginning of generic, node aware LRUs for shrinkers to
work with.

[ glommer: enum defined constants for lru. Suggested by gthelen,
  don't relock over retry ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
Reviewed-by: Greg Thelen <gthelen@google.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/list_lru.h | 115 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/Makefile              |   2 +-
 mm/list_lru.c            | 117 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 233 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/list_lru.h
 create mode 100644 mm/list_lru.c

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
new file mode 100644
index 0000000..1a548b0
--- /dev/null
+++ b/include/linux/list_lru.h
@@ -0,0 +1,115 @@
+/*
+ * Copyright (c) 2013 Red Hat, Inc. and Parallels Inc. All rights reserved.
+ * Authors: David Chinner and Glauber Costa
+ *
+ * Generic LRU infrastructure
+ */
+#ifndef _LRU_LIST_H
+#define _LRU_LIST_H
+
+#include <linux/list.h>
+
+/* list_lru_walk_cb has to always return one of those */
+enum lru_status {
+	LRU_REMOVED,		/* item removed from list */
+	LRU_ROTATE,		/* item referenced, give another pass */
+	LRU_SKIP,		/* item cannot be locked, skip */
+	LRU_RETRY,		/* item not freeable. May drop the lock
+				   internally, but has to return locked. */
+};
+
+struct list_lru {
+	spinlock_t		lock;
+	struct list_head	list;
+	/* kept as signed so we can catch imbalance bugs */
+	long			nr_items;
+};
+
+int list_lru_init(struct list_lru *lru);
+
+/**
+ * list_lru_add: add an element to the lru list's tail
+ * @list_lru: the lru pointer
+ * @item: the item to be added.
+ *
+ * If the element is already part of a list, this function returns doing
+ * nothing. Therefore the caller does not need to keep state about whether or
+ * not the element already belongs in the list and is allowed to lazy update
+ * it. Note however that this is valid for *a* list, not *this* list. If
+ * the caller organize itself in a way that elements can be in more than
+ * one type of list, it is up to the caller to fully remove the item from
+ * the previous list (with list_lru_del() for instance) before moving it
+ * to @list_lru
+ *
+ * Return value: true if the list was updated, false otherwise
+ */
+bool list_lru_add(struct list_lru *lru, struct list_head *item);
+
+/**
+ * list_lru_del: delete an element to the lru list
+ * @list_lru: the lru pointer
+ * @item: the item to be deleted.
+ *
+ * This function works analogously as list_lru_add in terms of list
+ * manipulation. The comments about an element already pertaining to
+ * a list are also valid for list_lru_del.
+ *
+ * Return value: true if the list was updated, false otherwise
+ */
+bool list_lru_del(struct list_lru *lru, struct list_head *item);
+
+/**
+ * list_lru_count: return the number of objects currently held by @lru
+ * @lru: the lru pointer.
+ *
+ * Always return a non-negative number, 0 for empty lists. There is no
+ * guarantee that the list is not updated while the count is being computed.
+ * Callers that want such a guarantee need to provide an outer lock.
+ */
+static inline unsigned long list_lru_count(struct list_lru *lru)
+{
+	return lru->nr_items;
+}
+
+typedef enum lru_status
+(*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
+/**
+ * list_lru_walk: walk a list_lru, isolating and disposing freeable items.
+ * @lru: the lru pointer.
+ * @isolate: callback function that is resposible for deciding what to do with
+ *  the item currently being scanned
+ * @cb_arg: opaque type that will be passed to @isolate
+ * @nr_to_walk: how many items to scan.
+ *
+ * This function will scan all elements in a particular list_lru, calling the
+ * @isolate callback for each of those items, along with the current list
+ * spinlock and a caller-provided opaque. The @isolate callback can choose to
+ * drop the lock internally, but *must* return with the lock held. The callback
+ * will return an enum lru_status telling the list_lru infrastructure what to
+ * do with the object being scanned.
+ *
+ * Please note that nr_to_walk does not mean how many objects will be freed,
+ * just how many objects will be scanned.
+ *
+ * Return value: the number of objects effectively removed from the LRU.
+ */
+unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
+		   void *cb_arg, unsigned long nr_to_walk);
+
+typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
+/**
+ * list_lru_dispose_all: forceably flush all elements in an @lru
+ * @lru: the lru pointer
+ * @dispose: callback function to be called for each lru list.
+ *
+ * This function will forceably isolate all elements into the dispose list, and
+ * call the @dispose callback to flush the list. Please note that the callback
+ * should expect items in any state, clean or dirty, and be able to flush all of
+ * them.
+ *
+ * Return value: how many objects were freed. It should be equal to all objects
+ * in the list_lru.
+ */
+unsigned long
+list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
+#endif /* _LRU_LIST_H */
diff --git a/mm/Makefile b/mm/Makefile
index 72c5acb..db430a4 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -17,7 +17,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o balloon_compaction.o \
-			   interval_tree.o $(mmu-y)
+			   interval_tree.o list_lru.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
new file mode 100644
index 0000000..dd74c54
--- /dev/null
+++ b/mm/list_lru.c
@@ -0,0 +1,117 @@
+/*
+ * Copyright (c) 2013 Red Hat, Inc. and Parallels Inc. All rights reserved.
+ * Authors: David Chinner and Glauber Costa
+ *
+ * Generic LRU infrastructure
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/list_lru.h>
+
+bool list_lru_add(struct list_lru *lru, struct list_head *item)
+{
+	spin_lock(&lru->lock);
+	if (list_empty(item)) {
+		list_add_tail(item, &lru->list);
+		lru->nr_items++;
+		spin_unlock(&lru->lock);
+		return true;
+	}
+	spin_unlock(&lru->lock);
+	return false;
+}
+EXPORT_SYMBOL_GPL(list_lru_add);
+
+bool list_lru_del(struct list_lru *lru, struct list_head *item)
+{
+	spin_lock(&lru->lock);
+	if (!list_empty(item)) {
+		list_del_init(item);
+		lru->nr_items--;
+		spin_unlock(&lru->lock);
+		return true;
+	}
+	spin_unlock(&lru->lock);
+	return false;
+}
+EXPORT_SYMBOL_GPL(list_lru_del);
+
+unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
+			    void *cb_arg, unsigned long nr_to_walk)
+{
+	struct list_head *item, *n;
+	unsigned long removed = 0;
+	/*
+	 * If we don't keep state of at which pass we are, we can loop at
+	 * LRU_RETRY, since we have no guarantees that the caller will be able
+	 * to do something other than retry on the next pass. We handle this by
+	 * allowing at most one retry per object. This should not be altered
+	 * by any condition other than LRU_RETRY.
+	 */
+	bool first_pass = true;
+
+	spin_lock(&lru->lock);
+restart:
+	list_for_each_safe(item, n, &lru->list) {
+		enum lru_status ret;
+		ret = isolate(item, &lru->lock, cb_arg);
+		switch (ret) {
+		case LRU_REMOVED:
+			lru->nr_items--;
+			removed++;
+			break;
+		case LRU_ROTATE:
+			list_move_tail(item, &lru->list);
+			break;
+		case LRU_SKIP:
+			break;
+		case LRU_RETRY:
+			if (!first_pass) {
+				first_pass = true;
+				break;
+			}
+			first_pass = false;
+			goto restart;
+		default:
+			BUG();
+		}
+
+		if (nr_to_walk-- == 0)
+			break;
+
+	}
+	spin_unlock(&lru->lock);
+	return removed;
+}
+EXPORT_SYMBOL_GPL(list_lru_walk);
+
+unsigned long list_lru_dispose_all(struct list_lru *lru,
+				   list_lru_dispose_cb dispose)
+{
+	unsigned long disposed = 0;
+	LIST_HEAD(dispose_list);
+
+	spin_lock(&lru->lock);
+	while (!list_empty(&lru->list)) {
+		list_splice_init(&lru->list, &dispose_list);
+		disposed += lru->nr_items;
+		lru->nr_items = 0;
+		spin_unlock(&lru->lock);
+
+		dispose(&dispose_list);
+
+		spin_lock(&lru->lock);
+	}
+	spin_unlock(&lru->lock);
+	return disposed;
+}
+
+int list_lru_init(struct list_lru *lru)
+{
+	spin_lock_init(&lru->lock);
+	INIT_LIST_HEAD(&lru->list);
+	lru->nr_items = 0;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(list_lru_init);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
