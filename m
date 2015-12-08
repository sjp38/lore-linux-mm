Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C5F616B0289
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:34:44 -0500 (EST)
Received: by pfdd184 with SMTP id d184so3064085pfd.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:34:44 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v9si1261639pfi.234.2015.12.07.17.34.44
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:34:44 -0800 (PST)
Subject: [PATCH -mm 19/25] list: introduce list_del_poison()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:34:17 -0800
Message-ID: <20151208013417.25030.89815.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
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
