Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 90B386B0062
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 18:15:01 -0500 (EST)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 06/19] list: add a new LRU list type
Date: Wed, 28 Nov 2012 10:14:33 +1100
Message-Id: <1354058086-27937-7-git-send-email-david@fromorbit.com>
In-Reply-To: <1354058086-27937-1-git-send-email-david@fromorbit.com>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

Several subsystems use the same construct for LRU lists - a list
head, a spin lock and and item count. They also use exactly the same
code for adding and removing items from the LRU. Create a generic
type for these LRU lists.

This is the beginning of generic, node aware LRUs for shrinkers to
work with.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/list_lru.h |   36 ++++++++++++++
 lib/Makefile             |    2 +-
 lib/list_lru.c           |  117 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/list_lru.h
 create mode 100644 lib/list_lru.c

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
new file mode 100644
index 0000000..3423949
--- /dev/null
+++ b/include/linux/list_lru.h
@@ -0,0 +1,36 @@
+/*
+ * Copyright (c) 2010-2012 Red Hat, Inc. All rights reserved.
+ * Author: David Chinner
+ *
+ * Generic LRU infrastructure
+ */
+#ifndef _LRU_LIST_H
+#define _LRU_LIST_H 0
+
+#include <linux/list.h>
+
+struct list_lru {
+	spinlock_t		lock;
+	struct list_head	list;
+	long			nr_items;
+};
+
+int list_lru_init(struct list_lru *lru);
+int list_lru_add(struct list_lru *lru, struct list_head *item);
+int list_lru_del(struct list_lru *lru, struct list_head *item);
+
+static inline long list_lru_count(struct list_lru *lru)
+{
+	return lru->nr_items;
+}
+
+typedef int (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock,
+				void *cb_arg);
+typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
+
+long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
+		   void *cb_arg, long nr_to_walk);
+
+long list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
+
+#endif /* _LRU_LIST_H */
diff --git a/lib/Makefile b/lib/Makefile
index 821a162..a0849d7 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -12,7 +12,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 idr.o int_sqrt.o extable.o \
 	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
 	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
-	 is_single_threaded.o plist.o decompress.o
+	 is_single_threaded.o plist.o decompress.o list_lru.o
 
 lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
diff --git a/lib/list_lru.c b/lib/list_lru.c
new file mode 100644
index 0000000..475d0e9
--- /dev/null
+++ b/lib/list_lru.c
@@ -0,0 +1,117 @@
+/*
+ * Copyright (c) 2010-2012 Red Hat, Inc. All rights reserved.
+ * Author: David Chinner
+ *
+ * Generic LRU infrastructure
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/list_lru.h>
+
+int
+list_lru_add(
+	struct list_lru	*lru,
+	struct list_head *item)
+{
+	spin_lock(&lru->lock);
+	if (list_empty(item)) {
+		list_add_tail(item, &lru->list);
+		lru->nr_items++;
+		spin_unlock(&lru->lock);
+		return 1;
+	}
+	spin_unlock(&lru->lock);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(list_lru_add);
+
+int
+list_lru_del(
+	struct list_lru	*lru,
+	struct list_head *item)
+{
+	spin_lock(&lru->lock);
+	if (!list_empty(item)) {
+		list_del_init(item);
+		lru->nr_items--;
+		spin_unlock(&lru->lock);
+		return 1;
+	}
+	spin_unlock(&lru->lock);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(list_lru_del);
+
+long
+list_lru_walk(
+	struct list_lru *lru,
+	list_lru_walk_cb isolate,
+	void		*cb_arg,
+	long		nr_to_walk)
+{
+	struct list_head *item, *n;
+	long removed = 0;
+restart:
+	spin_lock(&lru->lock);
+	list_for_each_safe(item, n, &lru->list) {
+		int ret;
+
+		if (nr_to_walk-- < 0)
+			break;
+
+		ret = isolate(item, &lru->lock, cb_arg);
+		switch (ret) {
+		case 0:	/* item removed from list */
+			lru->nr_items--;
+			removed++;
+			break;
+		case 1: /* item referenced, give another pass */
+			list_move_tail(item, &lru->list);
+			break;
+		case 2: /* item cannot be locked, skip */
+			break;
+		case 3: /* item not freeable, lock dropped */
+			goto restart;
+		default:
+			BUG();
+		}
+	}
+	spin_unlock(&lru->lock);
+	return removed;
+}
+EXPORT_SYMBOL_GPL(list_lru_walk);
+
+long
+list_lru_dispose_all(
+	struct list_lru *lru,
+	list_lru_dispose_cb dispose)
+{
+	long disposed = 0;
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
+int
+list_lru_init(
+	struct list_lru	*lru)
+{
+	spin_lock_init(&lru->lock);
+	INIT_LIST_HEAD(&lru->list);
+	lru->nr_items = 0;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(list_lru_init);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
