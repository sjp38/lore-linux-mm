Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 83CAB82F6A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:39:23 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so39311515pac.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:39:23 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id qp8si16762527pac.135.2015.12.09.18.39.22
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:39:22 -0800 (PST)
Subject: [-mm PATCH v2 19/25] list: introduce list_del_poison()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:38:55 -0800
Message-ID: <20151210023855.30368.37457.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org

ZONE_DEVICE pages always have an elevated count and will never be on an
lru reclaim list.  That space in 'struct page' can be redirected for
other uses, but for safety introduce a poison value that will always
trip __list_add() to assert.  This allows half of the struct list_head
storage to be reclaimed with some assurance to back up the assumption
that the page count never goes to zero and a list_add() is never
attempted.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/list.h |   17 +++++++++++++++++
 lib/list_debug.c     |    4 ++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/list.h b/include/linux/list.h
index 5356f4d661a7..0d07bc1387aa 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -108,9 +108,26 @@ static inline void list_del(struct list_head *entry)
 	entry->next = LIST_POISON1;
 	entry->prev = LIST_POISON2;
 }
+
+#define list_del_poison list_del
 #else
 extern void __list_del_entry(struct list_head *entry);
 extern void list_del(struct list_head *entry);
+extern struct list_head list_force_poison;
+
+/**
+ * list_del_poison - poison an entry to always assert on list_add
+ * @entry: the element to delete and poison
+ *
+ * Note: the assertion on list_add() only occurs when CONFIG_DEBUG_LIST=y,
+ * otherwise this is identical to list_del()
+ */
+static inline void list_del_poison(struct list_head *entry)
+{
+	__list_del(entry->prev, entry->next);
+	entry->next = &list_force_poison;
+	entry->prev = &list_force_poison;
+}
 #endif
 
 /**
diff --git a/lib/list_debug.c b/lib/list_debug.c
index 3859bf63561c..d730c064a4df 100644
--- a/lib/list_debug.c
+++ b/lib/list_debug.c
@@ -12,6 +12,8 @@
 #include <linux/kernel.h>
 #include <linux/rculist.h>
 
+struct list_head list_force_poison;
+
 /*
  * Insert a new entry between two known consecutive entries.
  *
@@ -23,6 +25,8 @@ void __list_add(struct list_head *new,
 			      struct list_head *prev,
 			      struct list_head *next)
 {
+	WARN(new->next == &list_force_poison || new->prev == &list_force_poison,
+		"list_add attempted on force-poisoned entry\n");
 	WARN(next->prev != prev,
 		"list_add corruption. next->prev should be "
 		"prev (%p), but was %p. (next=%p).\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
