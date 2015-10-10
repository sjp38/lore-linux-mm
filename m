Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B084682F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:33 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so100979360pac.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fa3si6507729pab.22.2015.10.09.18.02.32
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:33 -0700 (PDT)
Subject: [PATCH v2 16/20] list: introduce list_poison() and LIST_POISON3
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:56:50 -0400
Message-ID: <20151010005650.17221.59540.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, ross.zwisler@linux.intel.com, linux-kernel@vger.kernel.org, hch@lst.de

ZONE_DEVICE pages always have an elevated count and will never be on an
lru reclaim list.  That space in 'struct page' can be redirected for
other uses, but for safety introduce a poison value that will always
trip __list_add() to assert.  This allows half of the struct list_head
storage to be reclaimed with some assurance to back up the assumption
that the page count never goes to zero and a list_add() is never
attempted.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/list.h   |   14 ++++++++++++++
 include/linux/poison.h |    1 +
 lib/list_debug.c       |    2 ++
 3 files changed, 17 insertions(+)

diff --git a/include/linux/list.h b/include/linux/list.h
index 3e3e64a61002..af38cc80ae4c 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -114,6 +114,20 @@ extern void list_del(struct list_head *entry);
 #endif
 
 /**
+ * list_del_poison - poison an entry to always assert on list_add
+ * @entry: the element to delete and poison
+ *
+ * Note: the assertion on list_add() only occurs when CONFIG_DEBUG_LIST=y,
+ * otherwise this is identical to list_del()
+ */
+static inline void list_del_poison(struct list_head *entry)
+{
+	__list_del(entry->prev, entry->next);
+	entry->next = LIST_POISON3;
+	entry->prev = LIST_POISON3;
+}
+
+/**
  * list_replace - replace old entry by new one
  * @old : the element to be replaced
  * @new : the new element to insert
diff --git a/include/linux/poison.h b/include/linux/poison.h
index 317e16de09e5..31d048b3ba06 100644
--- a/include/linux/poison.h
+++ b/include/linux/poison.h
@@ -21,6 +21,7 @@
  */
 #define LIST_POISON1  ((void *) 0x100 + POISON_POINTER_DELTA)
 #define LIST_POISON2  ((void *) 0x200 + POISON_POINTER_DELTA)
+#define LIST_POISON3  ((void *) 0x300 + POISON_POINTER_DELTA)
 
 /********** include/linux/timer.h **********/
 /*
diff --git a/lib/list_debug.c b/lib/list_debug.c
index c24c2f7e296f..ec69e2b8e0fc 100644
--- a/lib/list_debug.c
+++ b/lib/list_debug.c
@@ -23,6 +23,8 @@ void __list_add(struct list_head *new,
 			      struct list_head *prev,
 			      struct list_head *next)
 {
+	WARN(new->next == LIST_POISON3 || new->prev == LIST_POISON3,
+		"list_add attempted on poisoned entry\n");
 	WARN(next->prev != prev,
 		"list_add corruption. next->prev should be "
 		"prev (%p), but was %p. (next=%p).\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
