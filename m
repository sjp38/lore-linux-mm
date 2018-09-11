Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 445848E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:36:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x85-v6so12373114pfe.13
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:36:30 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c19-v6si20646945pfc.18.2018.09.10.22.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 22:36:28 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 3/9] mm: introduce smp_list_splice to prepare for concurrent LRU adds
Date: Tue, 11 Sep 2018 13:36:10 +0800
Message-Id: <20180911053616.6894-4-aaron.lu@intel.com>
In-Reply-To: <20180911053616.6894-1-aaron.lu@intel.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

From: Daniel Jordan <daniel.m.jordan@oracle.com>

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

[aaronlu: drop LRU related code, keep only list related code]
Suggested-by: Yosef Lev <levyossi@icloud.com>
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/list.h |  1 +
 lib/list.c           | 60 ++++++++++++++++++++++++++++++++++++++------
 2 files changed, 54 insertions(+), 7 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index 0fd9c87dd14b..5f203fb55939 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -48,6 +48,7 @@ static inline bool __list_del_entry_valid(struct list_head *entry)
 #endif
 
 extern void smp_list_del(struct list_head *entry);
+extern void smp_list_splice(struct list_head *list, struct list_head *head);
 
 /*
  * Insert a new entry between two known consecutive entries.
diff --git a/lib/list.c b/lib/list.c
index 4d0949ea1a09..104faa144abf 100644
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
-- 
2.17.1
