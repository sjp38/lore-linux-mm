Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD168E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 21:00:16 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id a10-v6so44770079itc.9
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 18:00:16 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o10-v6si11587509iod.271.2018.09.10.18.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 18:00:14 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 7/8] mm: introduce smp_list_splice to prepare for concurrent LRU adds
Date: Mon, 10 Sep 2018 20:59:48 -0400
Message-Id: <20180911005949.5635-4-daniel.m.jordan@oracle.com>
In-Reply-To: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com

Now that we splice a local list onto the LRU, prepare for multiple tasks
doing this concurrently by adding a variant of the kernel's list
splicing API, list_splice, that's designed to work with multiple tasks.

Although there is naturally less parallelism to be gained from locking
the LRU head this way, the main benefit of doing this is to allow
removals to happen concurrently.  The way lru_lock is today, an add
needlessly blocks removal of any page but the first in the LRU.

For now, hold lru_lock as writer to serialize the adds to ensure the
function is correct for a single thread at a time.

Yosef Lev came up with this algorithm.

Suggested-by: Yosef Lev <levyossi@icloud.com>
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/list.h |  1 +
 lib/list.c           | 60 ++++++++++++++++++++++++++++++++++++++------
 mm/swap.c            |  3 ++-
 3 files changed, 56 insertions(+), 8 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index bb80fe9b48cf..6d964ea44f1a 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -48,6 +48,7 @@ static inline bool __list_del_entry_valid(struct list_head *entry)
 #endif
 
 extern void smp_list_del(struct list_head *entry);
+extern void smp_list_splice(struct list_head *list, struct list_head *head);
 
 /*
  * Insert a new entry between two known consecutive entries.
diff --git a/lib/list.c b/lib/list.c
index 22188fc0316d..d6a834ef1543 100644
--- a/lib/list.c
+++ b/lib/list.c
@@ -10,17 +10,18 @@
 #include <linux/prefetch.h>
 
 /*
- * smp_list_del is a variant of list_del that allows concurrent list removals
- * under certain assumptions.  The idea is to get away from overly coarse
- * synchronization, such as using a lock to guard an entire list, which
- * serializes all operations even though those operations might be happening on
- * disjoint parts.
+ * smp_list_del and smp_list_splice are variants of list_del and list_splice,
+ * respectively, that allow concurrent list operations under certain
+ * assumptions.  The idea is to get away from overly coarse synchronization,
+ * such as using a lock to guard an entire list, which serializes all
+ * operations even though those operations might be happening on disjoint
+ * parts.
  *
  * If you want to use other functions from the list API concurrently,
  * additional synchronization may be necessary.  For example, you could use a
  * rwlock as a two-mode lock, where readers use the lock in shared mode and are
- * allowed to call smp_list_del concurrently, and writers use the lock in
- * exclusive mode and are allowed to use all list operations.
+ * allowed to call smp_list_* functions concurrently, and writers use the lock
+ * in exclusive mode and are allowed to use all list operations.
  */
 
 /**
@@ -156,3 +157,48 @@ void smp_list_del(struct list_head *entry)
 	entry->next = LIST_POISON1;
 	entry->prev = LIST_POISON2;
 }
+
+/**
+ * smp_list_splice - thread-safe splice of two lists
+ * @list: the new list to add
+ * @head: the place to add it in the first list
+ *
+ * Safely handles concurrent smp_list_splice operations onto the same list head
+ * and concurrent smp_list_del operations of any list entry except @head.
+ * Assumes that @head cannot be removed.
+ */
+void smp_list_splice(struct list_head *list, struct list_head *head)
+{
+	struct list_head *first = list->next;
+	struct list_head *last = list->prev;
+	struct list_head *succ;
+
+	/*
+	 * Lock the front of @head by replacing its next pointer with NULL.
+	 * Should another thread be adding to the front, wait until it's done.
+	 */
+	succ = READ_ONCE(head->next);
+	while (succ == NULL || cmpxchg(&head->next, succ, NULL) != succ) {
+		cpu_relax();
+		succ = READ_ONCE(head->next);
+	}
+
+	first->prev = head;
+	last->next = succ;
+
+	/*
+	 * It is safe to write to succ, head's successor, because locking head
+	 * prevents succ from being removed in smp_list_del.
+	 */
+	succ->prev = last;
+
+	/*
+	 * Pairs with the implied full barrier before the cmpxchg above.
+	 * Ensures the write that unlocks the head is seen last to avoid list
+	 * corruption.
+	 */
+	smp_wmb();
+
+	/* Simultaneously complete the splice and unlock the head node. */
+	WRITE_ONCE(head->next, first);
+}
diff --git a/mm/swap.c b/mm/swap.c
index 07b951727a11..fe3098c09815 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -35,6 +35,7 @@
 #include <linux/hugetlb.h>
 #include <linux/page_idle.h>
 #include <linux/mmzone.h>
+#include <linux/list.h>
 
 #include "internal.h"
 
@@ -1019,7 +1020,7 @@ void __pagevec_lru_add(struct pagevec *pvec)
 			pgdat = splice->pgdat;
 			write_lock_irqsave(&pgdat->lru_lock, flags);
 		}
-		list_splice(&splice->list, splice->lru);
+		smp_list_splice(&splice->list, splice->lru);
 	}
 
 	while (!list_empty(&singletons)) {
-- 
2.18.0
