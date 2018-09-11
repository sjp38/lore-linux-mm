Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB4958E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 21:00:07 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l6-v6so2375792iog.4
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 18:00:07 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x10-v6si11507374itf.119.2018.09.10.18.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 18:00:06 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 4/8] mm: introduce smp_list_del for concurrent list entry removals
Date: Mon, 10 Sep 2018 20:59:45 -0400
Message-Id: <20180911005949.5635-1-daniel.m.jordan@oracle.com>
In-Reply-To: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com

Now that the LRU lock is a RW lock, lay the groundwork for fine-grained
synchronization so that multiple threads holding the lock as reader can
safely remove pages from an LRU at the same time.

Add a thread-safe variant of list_del called smp_list_del that allows
multiple threads to delete nodes from a list, and wrap this new list API
in smp_del_page_from_lru to get the LRU statistics updates right.

For bisectability's sake, call the new function only when holding
lru_lock as writer.  In the next patch, switch to taking it as reader.

The algorithm is explained in detail in the comments.  Yosef Lev
conceived of the algorithm, and this patch is heavily based on an
earlier version from him.  Thanks to Dave Dice for suggesting the
prefetch.

Signed-off-by: Yosef Lev <levyossi@icloud.com>
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/list.h      |   2 +
 include/linux/mm_inline.h |  28 +++++++
 lib/Makefile              |   2 +-
 lib/list.c                | 158 ++++++++++++++++++++++++++++++++++++++
 mm/swap.c                 |   3 +-
 5 files changed, 191 insertions(+), 2 deletions(-)
 create mode 100644 lib/list.c

diff --git a/include/linux/list.h b/include/linux/list.h
index 4b129df4d46b..bb80fe9b48cf 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -47,6 +47,8 @@ static inline bool __list_del_entry_valid(struct list_head *entry)
 }
 #endif
 
+extern void smp_list_del(struct list_head *entry);
+
 /*
  * Insert a new entry between two known consecutive entries.
  *
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 10191c28fc04..335bb9ba6510 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -4,6 +4,7 @@
 
 #include <linux/huge_mm.h>
 #include <linux/swap.h>
+#include <linux/list.h>
 
 /**
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
@@ -65,6 +66,33 @@ static __always_inline void del_page_from_lru_list(struct page *page,
 	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
 }
 
+/**
+ * smp_del_page_from_lru_list - thread-safe del_page_from_lru_list
+ * @page: page to delete from the LRU
+ * @lruvec: vector of LRUs
+ * @lru: type of LRU list to delete from within the lruvec
+ *
+ * Requires lru_lock to be held, preferably as reader for greater concurrency
+ * with other LRU operations but writers are also correct.
+ *
+ * Holding lru_lock as reader, the only unprotected shared state is @page's
+ * lru links, which smp_list_del safely handles.  lru_lock excludes other
+ * writers, and the atomics and per-cpu counters in update_lru_size serialize
+ * racing stat updates.
+ *
+ * Concurrent removal of adjacent pages is expected to be rare.  In
+ * will-it-scale/page_fault1, the ratio of iterations of any while loop in
+ * smp_list_del to calls to that function was less than 0.009% (and 0.009% was
+ * an outlier on an oversubscribed 44 core system).
+ */
+static __always_inline void smp_del_page_from_lru_list(struct page *page,
+						       struct lruvec *lruvec,
+						       enum lru_list lru)
+{
+	smp_list_del(&page->lru);
+	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
+}
+
 /**
  * page_lru_base_type - which LRU list type should a page be on?
  * @page: the page to test
diff --git a/lib/Makefile b/lib/Makefile
index ce20696d5a92..f0689480f704 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -40,7 +40,7 @@ obj-y += bcd.o div64.o sort.o parser.o debug_locks.o random32.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iov_iter.o clz_ctz.o \
 	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
 	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o \
-	 once.o refcount.o usercopy.o errseq.o bucket_locks.o
+	 once.o refcount.o usercopy.o errseq.o bucket_locks.o list.o
 obj-$(CONFIG_STRING_SELFTEST) += test_string.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
diff --git a/lib/list.c b/lib/list.c
new file mode 100644
index 000000000000..22188fc0316d
--- /dev/null
+++ b/lib/list.c
@@ -0,0 +1,158 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2017, 2018 Oracle and/or its affiliates. All rights reserved.
+ *
+ * Authors: Yosef Lev <levyossi@icloud.com>
+ *          Daniel Jordan <daniel.m.jordan@oracle.com>
+ */
+
+#include <linux/list.h>
+#include <linux/prefetch.h>
+
+/*
+ * smp_list_del is a variant of list_del that allows concurrent list removals
+ * under certain assumptions.  The idea is to get away from overly coarse
+ * synchronization, such as using a lock to guard an entire list, which
+ * serializes all operations even though those operations might be happening on
+ * disjoint parts.
+ *
+ * If you want to use other functions from the list API concurrently,
+ * additional synchronization may be necessary.  For example, you could use a
+ * rwlock as a two-mode lock, where readers use the lock in shared mode and are
+ * allowed to call smp_list_del concurrently, and writers use the lock in
+ * exclusive mode and are allowed to use all list operations.
+ */
+
+/**
+ * smp_list_del - concurrent variant of list_del
+ * @entry: entry to delete from the list
+ *
+ * Safely removes an entry from the list in the presence of other threads that
+ * may try to remove adjacent entries.  Uses the entry's next field and the
+ * predecessor entry's next field as locks to accomplish this.
+ *
+ * Assumes that no two threads may try to delete the same entry.  This
+ * assumption holds, for example, if the objects on the list are
+ * reference-counted so that an object is only removed when its refcount falls
+ * to 0.
+ *
+ * @entry's next and prev fields are poisoned on return just as with list_del.
+ */
+void smp_list_del(struct list_head *entry)
+{
+	struct list_head *succ, *pred, *pred_reread;
+
+	/*
+	 * The predecessor entry's cacheline is read before it's written, so to
+	 * avoid an unnecessary cacheline state transition, prefetch for
+	 * writing.  In the common case, the predecessor won't change.
+	 */
+	prefetchw(entry->prev);
+
+	/*
+	 * Step 1: Lock @entry E by making its next field point to its
+	 * predecessor D.  This prevents any thread from removing the
+	 * predecessor because that thread will loop in its step 4 while
+	 * E->next == D.  This also prevents any thread from removing the
+	 * successor F because that thread will see that F->prev->next != F in
+	 * the cmpxchg in its step 3.  Retry if the successor is being removed
+	 * and has already set this field to NULL in step 3.
+	 */
+	succ = READ_ONCE(entry->next);
+	pred = READ_ONCE(entry->prev);
+	while (succ == NULL || cmpxchg(&entry->next, succ, pred) != succ) {
+		/*
+		 * Reread @entry's successor because it may change until
+		 * @entry's next field is locked.  Reread the predecessor to
+		 * have a better chance of publishing the right value and avoid
+		 * entering the loop in step 2 while @entry is locked,
+		 * but this isn't required for correctness because the
+		 * predecessor is reread in step 2.
+		 */
+		cpu_relax();
+		succ = READ_ONCE(entry->next);
+		pred = READ_ONCE(entry->prev);
+	}
+
+	/*
+	 * Step 2: A racing thread may remove @entry's predecessor.  Reread and
+	 * republish @entry->prev until it does not change.  This guarantees
+	 * that the racing thread has not passed the while loop in step 4 and
+	 * has not freed the predecessor, so it is safe for this thread to
+	 * access predecessor fields in step 3.
+	 */
+	pred_reread = READ_ONCE(entry->prev);
+	while (pred != pred_reread) {
+		WRITE_ONCE(entry->next, pred_reread);
+		pred = pred_reread;
+		/*
+		 * Ensure the predecessor is published in @entry's next field
+		 * before rereading the predecessor.  Pairs with the smp_mb in
+		 * step 4.
+		 */
+		smp_mb();
+		pred_reread = READ_ONCE(entry->prev);
+	}
+
+	/*
+	 * Step 3: If the predecessor points to @entry, lock it and continue.
+	 * Otherwise, the predecessor is being removed, so loop until that
+	 * removal finishes and this thread's @entry->prev is updated, which
+	 * indicates the old predecessor has reached the loop in step 4.  Write
+	 * the new predecessor into @entry->next.  This both releases the old
+	 * predecessor from its step 4 loop and sets this thread up to lock the
+	 * new predecessor.
+	 */
+	while (pred->next != entry ||
+	       cmpxchg(&pred->next, entry, NULL) != entry) {
+		/*
+		 * The predecessor is being removed so wait for a new,
+		 * unlocked predecessor.
+		 */
+		cpu_relax();
+		pred_reread = READ_ONCE(entry->prev);
+		if (pred != pred_reread) {
+			/*
+			 * The predecessor changed, so republish it and update
+			 * it as in step 2.
+			 */
+			WRITE_ONCE(entry->next, pred_reread);
+			pred = pred_reread;
+			/* Pairs with smp_mb in step 4. */
+			smp_mb();
+		}
+	}
+
+	/*
+	 * Step 4: @entry and @entry's predecessor are both locked, so now
+	 * actually remove @entry from the list.
+	 *
+	 * It is safe to write to the successor's prev pointer because step 1
+	 * prevents the successor from being removed.
+	 */
+
+	WRITE_ONCE(succ->prev, pred);
+
+	/*
+	 * The full barrier guarantees that all changes are visible to other
+	 * threads before the entry is unlocked by the final write, pairing
+	 * with the implied full barrier before the cmpxchg in step 1.
+	 *
+	 * The barrier also guarantees that this thread writes succ->prev
+	 * before reading succ->next, pairing with a thread in step 2 or 3 that
+	 * writes entry->next before reading entry->prev, which ensures that
+	 * the one that writes second sees the update from the other.
+	 */
+	smp_mb();
+
+	while (READ_ONCE(succ->next) == entry) {
+		/* The successor is being removed, so wait for it to finish. */
+		cpu_relax();
+	}
+
+	/* Simultaneously completes the removal and unlocks the predecessor. */
+	WRITE_ONCE(pred->next, succ);
+
+	entry->next = LIST_POISON1;
+	entry->prev = LIST_POISON2;
+}
diff --git a/mm/swap.c b/mm/swap.c
index a16ba5194e1c..613b841bd208 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -789,7 +789,8 @@ void release_pages(struct page **pages, int nr)
 			lruvec = mem_cgroup_page_lruvec(page, locked_pgdat);
 			VM_BUG_ON_PAGE(!PageLRU(page), page);
 			__ClearPageLRU(page);
-			del_page_from_lru_list(page, lruvec, page_off_lru(page));
+			smp_del_page_from_lru_list(page, lruvec,
+						   page_off_lru(page));
 		}
 
 		/* Clear Active bit in case of parallel mark_page_accessed */
-- 
2.18.0
