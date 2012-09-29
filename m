Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id D40946B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 23:16:51 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Fri, 28 Sep 2012 21:16:51 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DC64D19D803E
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 21:16:48 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8T3Gm4S245904
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 21:16:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8T3GlsL020968
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 21:16:48 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 1/3] [RFC] Add volatile range management code
Date: Fri, 28 Sep 2012 23:16:31 -0400
Message-Id: <1348888593-23047-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This patch provides the volatile range management code
that filesystems can utilize when implementing
FALLOC_FL_MARK_VOLATILE.

It tracks a collection of page ranges against a mapping
stored in an interval-tree. This code handles coalescing
overlapping and adjacent ranges, as well as splitting
ranges when sub-chunks are removed.

The ranges can be marked purged or unpurged. And there is
a per-fs lru list that tracks all the unpurged ranges for
that fs.

v2:
* Fix bug in volatile_ranges_get_last_used returning bad
  start,end values
* Rework for intervaltree renaming
* Optimize volatile_range_lru_size to avoid running through
  lru list each time.

v3:
* Improve function name to make it clear what the
  volatile_ranges_pluck_lru() code does.
* Drop volatile_range_lru_size and unpurged_page_count
  mangement as its now unused

v4:
* Re-add volatile_range_lru_size and unpruged_page_count
* Fix bug in range_remove when we split ranges, we add
  an overlapping range before resizing the existing range.

v5:
* Drop intervaltree for prio_tree usage per Michel &
  Dmitry's suggestions.
* Cleanups

v6:
* Drop prio_tree usage for rbtree per Michel Lespinasse's
  suggestion.

v7:
* Use byte ranges instead of page ranges to make userspace's
  life easier.
* Add volatile_range_address_is_purged check for SIGBUS on
  purged page access.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/volatile.h |   46 ++++
 mm/Makefile              |    2 +-
 mm/volatile.c            |  580 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 627 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/volatile.h
 create mode 100644 mm/volatile.c

diff --git a/include/linux/volatile.h b/include/linux/volatile.h
new file mode 100644
index 0000000..c59a0f9
--- /dev/null
+++ b/include/linux/volatile.h
@@ -0,0 +1,46 @@
+#ifndef _LINUX_VOLATILE_H
+#define _LINUX_VOLATILE_H
+
+#include <linux/fs.h>
+
+struct volatile_fs_head {
+	struct mutex lock;
+	struct list_head lru_head;
+	s64 unpurged_page_count;
+};
+
+#define DEFINE_VOLATILE_FS_HEAD(name) struct volatile_fs_head name = {	\
+	.lock = __MUTEX_INITIALIZER(name.lock),				\
+	.lru_head = LIST_HEAD_INIT(name.lru_head),			\
+	.unpurged_page_count = 0,					\
+}
+
+static inline void volatile_range_lock(struct volatile_fs_head *head)
+{
+	mutex_lock(&head->lock);
+}
+
+static inline void volatile_range_unlock(struct volatile_fs_head *head)
+{
+	mutex_unlock(&head->lock);
+}
+
+extern long volatile_range_add(struct volatile_fs_head *head,
+				struct address_space *mapping,
+				u64 *start, u64 *end);
+extern long volatile_range_remove(struct volatile_fs_head *head,
+				struct address_space *mapping,
+				u64 start, u64 end);
+
+extern s64 volatile_range_lru_size(struct volatile_fs_head *head);
+
+extern void volatile_range_clear(struct volatile_fs_head *head,
+					struct address_space *mapping);
+
+extern s64 volatile_ranges_pluck_lru(struct volatile_fs_head *head,
+				struct address_space **mapping,
+				u64 *start, u64 *end);
+
+extern int volatile_range_is_purged(struct address_space *mapping, u64 addr);
+
+#endif /* _LINUX_VOLATILE_H */
diff --git a/mm/Makefile b/mm/Makefile
index 92753e2..4c18cd1 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o $(mmu-y)
+			   compaction.o volatile.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/volatile.c b/mm/volatile.c
new file mode 100644
index 0000000..6d3e418
--- /dev/null
+++ b/mm/volatile.c
@@ -0,0 +1,580 @@
+/* mm/volatile.c
+ *
+ * Volatile range management.
+ *      Copyright 2011 Linaro
+ *
+ * Based on mm/ashmem.c
+ *      by Robert Love <rlove@google.com>
+ *      Copyright (C) 2008 Google, Inc.
+ *
+ *
+ * This software is licensed under the terms of the GNU General Public
+ * License version 2, as published by the Free Software Foundation, and
+ * may be copied, distributed, and modified under those terms.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * The volatile range management is a helper layer on top of the range tree
+ * code, which is used to help filesystems manage byte ranges that are volatile.
+ *
+ * These ranges are stored in a per-mapping range tree. Storing both purged and
+ * unpurged ranges connected to that address_space. Unpurged ranges are also
+ * linked together in an lru list that is per-volatile-fs-head (basically
+ * per-filesystem).
+ *
+ * The goal behind volatile ranges is to allow applications to interact
+ * with the kernel's cache management infrastructure.  In particular an
+ * application can say "this memory contains data that might be useful in
+ * the future, but can be reconstructed if necessary, so if the kernel
+ * needs, it can zap and reclaim this memory without having to swap it out.
+ *
+ * The proposed mechanism - at a high level - is for user-space to be able
+ * to say "This memory is volatile" and then later "this memory is no longer
+ * volatile".  If the content of the memory is still available the second
+ * request succeeds.  If not, the memory is marked non-volatile and an
+ * error is returned to denote that the contents have been lost.
+ *
+ * Credits to Neil Brown for the above description.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/pagemap.h>
+#include <linux/volatile.h>
+#include <linux/rbtree.h>
+#include <linux/hash.h>
+#include <linux/shmem_fs.h>
+
+struct volatile_range {
+	struct list_head		lru;
+	struct rb_node			node;
+	u64				start;
+	u64				end;
+	unsigned int			purged;
+	struct address_space		*mapping;
+};
+
+/*
+ * To avoid bloating the address_space structure, we use
+ * a hash structure to map from address_space mappings to
+ * the interval_tree root that stores volatile ranges
+ */
+static DEFINE_MUTEX(hash_mutex);
+static struct hlist_head *mapping_hash;
+static long mapping_hash_shift = 8;
+struct mapping_hash_entry {
+	struct rb_root			root;
+	struct address_space		*mapping;
+	struct hlist_node		hnode;
+};
+
+static inline
+struct rb_root *__mapping_to_root(struct address_space *mapping)
+{
+	struct hlist_node *elem;
+	struct mapping_hash_entry *entry;
+	struct rb_root *ret = NULL;
+
+	hlist_for_each_entry_rcu(entry, elem,
+			&mapping_hash[hash_ptr(mapping, mapping_hash_shift)],
+				hnode)
+		if (entry->mapping == mapping)
+			ret =  &entry->root;
+
+	return ret;
+}
+
+static inline
+struct rb_root *mapping_to_root(struct address_space *mapping)
+{
+	struct rb_root *ret;
+
+	mutex_lock(&hash_mutex);
+	ret =  __mapping_to_root(mapping);
+	mutex_unlock(&hash_mutex);
+	return ret;
+}
+
+
+static inline
+struct rb_root *mapping_allocate_root(struct address_space *mapping)
+{
+	struct mapping_hash_entry *entry;
+	struct rb_root *dblchk;
+	struct rb_root *ret = NULL;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return NULL;
+
+	mutex_lock(&hash_mutex);
+	/* Since we dropped the lock, double check that no one has
+	 * created the same hash entry.
+	 */
+	dblchk = __mapping_to_root(mapping);
+	if (dblchk) {
+		kfree(entry);
+		ret = dblchk;
+		goto out;
+	}
+
+	INIT_HLIST_NODE(&entry->hnode);
+	entry->mapping = mapping;
+	entry->root = RB_ROOT;
+
+	hlist_add_head_rcu(&entry->hnode,
+		&mapping_hash[hash_ptr(mapping, mapping_hash_shift)]);
+
+	ret = &entry->root;
+out:
+	mutex_unlock(&hash_mutex);
+	return ret;
+}
+
+static inline void mapping_free_root(struct rb_root *root)
+{
+	struct mapping_hash_entry *entry;
+
+	mutex_lock(&hash_mutex);
+	entry = container_of(root, struct mapping_hash_entry, root);
+
+	hlist_del_rcu(&entry->hnode);
+	kfree(entry);
+	mutex_unlock(&hash_mutex);
+}
+
+
+/* volatile range helpers */
+static struct volatile_range *vrange_alloc(void)
+{
+	struct volatile_range *new;
+
+	new = kzalloc(sizeof(struct volatile_range), GFP_KERNEL);
+	if (!new)
+		return 0;
+	rb_init_node(&new->node);
+	return new;
+}
+
+static void vrange_rb_insert(struct rb_root *root,
+				struct volatile_range *vrange)
+{
+	struct rb_node **p = &root->rb_node;
+	struct rb_node *parent = NULL;
+	struct volatile_range *ptr;
+
+	WARN_ON_ONCE(!RB_EMPTY_NODE(&vrange->node));
+
+	while (*p) {
+		parent = *p;
+		ptr = rb_entry(parent, struct volatile_range, node);
+		if (vrange->start < ptr->start)
+			p = &(*p)->rb_left;
+		else
+			p = &(*p)->rb_right;
+	}
+	rb_link_node(&vrange->node, parent, p);
+	rb_insert_color(&vrange->node, root);
+}
+
+static void vrange_rb_remove(struct rb_root *root,
+				struct volatile_range *vrange)
+{
+	WARN_ON_ONCE(RB_EMPTY_NODE(&vrange->node));
+	rb_erase(&vrange->node, root);
+	RB_CLEAR_NODE(&vrange->node);
+}
+
+struct volatile_range *vrange_rb_search(struct rb_root *root,
+						u64 start, u64 end)
+{
+	struct rb_node *p = root->rb_node;
+	struct volatile_range *candidate, *match = NULL;
+
+	while (p) {
+		candidate = rb_entry(p, struct volatile_range, node);
+		if (end < candidate->start)
+			p = p->rb_left;
+		else if (start > candidate->end)
+			p = p->rb_right;
+		else {
+			/* We found one, but try to find an earlier match */
+			match = candidate;
+			p = p->rb_left;
+		}
+	}
+	return match;
+}
+
+struct volatile_range *vrange_rb_next(struct volatile_range *vrange,
+						u64 start, u64 end)
+{
+	struct rb_node *next;
+	struct volatile_range *candidate;
+
+	if (!vrange)
+		return NULL;
+
+	next = rb_next(&vrange->node);
+	if (!next)
+		return NULL;
+
+	candidate = container_of(next, struct volatile_range, node);
+
+	if ((candidate->start > end) || (candidate->end < start))
+		return NULL;
+
+	return candidate;
+}
+
+static void vrange_add(struct volatile_fs_head *head,
+				struct rb_root *root,
+				struct volatile_range *vrange)
+{
+	vrange_rb_insert(root, vrange);
+	/* Only add unpurged ranges to LRU */
+	if (!vrange->purged) {
+		head->unpurged_page_count += (vrange->end - vrange->start)
+							>> PAGE_CACHE_SHIFT;
+		list_add_tail(&vrange->lru, &head->lru_head);
+	}
+}
+
+static void vrange_del(struct volatile_fs_head *head,
+				struct rb_root *root,
+				struct volatile_range *vrange)
+{
+	if (!vrange->purged) {
+		head->unpurged_page_count -= (vrange->end - vrange->start)
+							>> PAGE_CACHE_SHIFT;
+		list_del(&vrange->lru);
+	}
+
+	vrange_rb_remove(root, vrange);
+	kfree(vrange);
+}
+
+static inline void vrange_resize(struct volatile_fs_head *head,
+				struct rb_root *root,
+				struct volatile_range *vrange,
+				s64 start_index, s64 end_index)
+{
+	s64 old_size, new_size;
+
+	old_size = vrange->end - vrange->start;
+	new_size = end_index - start_index;
+
+	if (!vrange->purged)
+		head->unpurged_page_count += (new_size - old_size)
+							>> PAGE_CACHE_SHIFT;
+
+	vrange_rb_remove(root, vrange);
+	vrange->start = start_index;
+	vrange->end = end_index;
+	vrange_rb_insert(root, vrange);
+}
+
+
+
+/**
+ * volatile_range_add: Marks a byte interval as volatile
+ * @head: per-fs volatile head
+ * @mapping: address space who's range is being marked volatile
+ * @start: Starting byte in range to be marked volatile
+ * @end: Ending byte in range to be marked volatile
+ *
+ * Mark a region as volatile. Coalesces overlapping and neighboring regions.
+ *
+ * Must lock the volatile_fs_head before calling!
+ *
+ * Returns 1 if the range was coalesced with any purged ranges.
+ * Returns 0 on success.
+ * start and end are modified to the full size of the coalesced range
+ */
+long volatile_range_add(struct volatile_fs_head *head,
+				struct address_space *mapping,
+				u64 *start, u64 *end)
+{
+	struct volatile_range *new, *vrange, *node;
+	struct rb_root *root;
+	int purged = 0;
+
+	/* Make sure we're properly locked */
+	WARN_ON(!mutex_is_locked(&head->lock));
+
+	/*
+	 * Because the lock might be held in a shrinker, release
+	 * it during allocation.
+	 */
+	mutex_unlock(&head->lock);
+	new = vrange_alloc();
+	mutex_lock(&head->lock);
+	if (!new)
+		return -ENOMEM;
+
+	root = mapping_to_root(mapping);
+	if (!root) {
+		mutex_unlock(&head->lock);
+		root = mapping_allocate_root(mapping);
+		mutex_lock(&head->lock);
+		if (!root) {
+			kfree(new);
+			return -ENOMEM;
+		}
+	}
+
+	/* First, find any existing intervals that overlap */
+	node = vrange_rb_search(root, *start, *end);
+	while (node) {
+		vrange = node;
+
+		/* Already entirely marked volatile, so we're done */
+		if (vrange->start < *start && vrange->end > *end) {
+			/* don't need the allocated value */
+			kfree(new);
+			return purged;
+		}
+
+		/* Resize the new range to cover all overlapping ranges */
+		*start = min_t(u64, *start, vrange->start);
+		*end = max_t(u64, *end, vrange->end);
+
+		/* Inherit purged state from overlapping ranges */
+		purged |= vrange->purged;
+
+		/* See if there's a next range that overlaps */
+		node = vrange_rb_next(vrange, *start, *end);
+
+		/* Delete the old range, as we consume it */
+		vrange_del(head, root, vrange);
+	}
+
+
+	/* Coalesce left-adjacent ranges */
+	vrange = vrange_rb_search(root, *start-1, *start);
+	/* Only coalesce if both are either purged or unpurged */
+	if (vrange && (vrange->purged == purged)) {
+		/* resize new range */
+		*start = min_t(u64, *start, vrange->start);
+		*end = max_t(u64, *end, vrange->end);
+		/* delete old range */
+		vrange_del(head, root, vrange);
+	}
+
+	/* Coalesce right-adjacent ranges */
+	vrange = vrange_rb_search(root, *end, *end+1);
+	/* Only coalesce if both are either purged or unpurged */
+	if (vrange && (vrange->purged == purged)) {
+		/* resize new range */
+		*start = min_t(u64, *start, vrange->start);
+		*end = max_t(u64, *end, vrange->end);
+		/* delete old range */
+		vrange_del(head, root, vrange);
+	}
+	/* Assign and store the new range in the range tree */
+	new->mapping = mapping;
+	new->start = *start;
+	new->end = *end;
+	new->purged = purged;
+	vrange_add(head, root, new);
+
+	return purged;
+}
+
+
+/**
+ * volatile_range_remove: Marks a byte interval as nonvolatile
+ * @head: per-fs volatile head
+ * @mapping: address space who's range is being marked nonvolatile
+ * @start_index: Starting byte in range to be marked nonvolatile
+ * @end_index: Ending byte in range to be marked nonvolatile
+ *
+ * Mark a region as nonvolatile. And remove it from the volatile
+ * range tree.
+ *
+ * Must lock the volatile_fs_head before calling!
+ *
+ * Returns 1 if any portion of the range was purged.
+ * Returns 0 on success.
+ */
+long volatile_range_remove(struct volatile_fs_head *head,
+				struct address_space *mapping,
+				u64 start, u64 end)
+{
+	struct volatile_range *new, *vrange, *node;
+	struct rb_root *root;
+	int ret		= 0;
+	int used_new	= 0;
+
+	/* Make sure we're properly locked */
+	WARN_ON(!mutex_is_locked(&head->lock));
+
+	/*
+	 * Because the lock might be held in a shrinker, release
+	 * it during allocation.
+	 */
+	mutex_unlock(&head->lock);
+	new = vrange_alloc();
+	mutex_lock(&head->lock);
+	if (!new)
+		return -ENOMEM;
+
+	root = mapping_to_root(mapping);
+	if (!root)
+		goto out;
+
+
+	/* Find any overlapping ranges */
+	node = vrange_rb_search(root, start, end);
+	while (node) {
+		vrange = node;
+		node = vrange_rb_next(vrange, start, end);
+
+		ret |= vrange->purged;
+
+		if (start <= vrange->start && end >= vrange->end) {
+			/* delete: volatile range is totally within range */
+			vrange_del(head, root, vrange);
+		} else if (vrange->start >= start) {
+			/* resize: volatile range right-overlaps range */
+			vrange_resize(head, root, vrange, end+1, vrange->end);
+		} else if (vrange->end <= end) {
+			/* resize: volatile range left-overlaps range */
+			vrange_resize(head, root, vrange, vrange->start,
+								start-1);
+		} else {
+			/* split: range is totally within a volatile range */
+			used_new = 1; /* we only do this once */
+			new->mapping = mapping;
+			new->start = end + 1;
+			new->end = vrange->end;
+			new->purged = vrange->purged;
+			vrange_resize(head, root, vrange, vrange->start,
+								start-1);
+			vrange_add(head, root, new);
+			break;
+		}
+	}
+
+out:
+	if (!used_new)
+		kfree(new);
+
+	return ret;
+}
+
+/**
+ * volatile_range_lru_size: Returns the number of unpurged pages on the lru
+ * @head: per-fs volatile head
+ *
+ * Returns the number of unpurged pages on the LRU
+ *
+ * Must lock the volatile_fs_head before calling!
+ *
+ */
+s64 volatile_range_lru_size(struct volatile_fs_head *head)
+{
+	WARN_ON(!mutex_is_locked(&head->lock));
+	return head->unpurged_page_count;
+}
+
+
+/**
+ * volatile_ranges_pluck_lru: Returns mapping and size of lru unpurged range
+ * @head: per-fs volatile head
+ * @mapping: dbl pointer to mapping who's range is being purged
+ * @start: Pointer to starting address of range being purged
+ * @end: Pointer to ending address of range being purged
+ *
+ * Returns the mapping, start and end values of the least recently used
+ * range. Marks the range as purged and removes it from the LRU.
+ *
+ * Must lock the volatile_fs_head before calling!
+ *
+ * Returns 1 on success if a range was returned
+ * Return 0 if no ranges were found.
+ */
+s64 volatile_ranges_pluck_lru(struct volatile_fs_head *head,
+				struct address_space **mapping,
+				u64 *start, u64 *end)
+{
+	struct volatile_range *range;
+
+	WARN_ON(!mutex_is_locked(&head->lock));
+
+	if (list_empty(&head->lru_head))
+		return 0;
+
+	range = list_first_entry(&head->lru_head, struct volatile_range, lru);
+
+	*start = range->start;
+	*end = range->end;
+	*mapping = range->mapping;
+
+	head->unpurged_page_count -= (*end - *start)>>PAGE_CACHE_SHIFT;
+	list_del(&range->lru);
+	range->purged = 1;
+
+	return 1;
+}
+
+
+int volatile_range_is_purged(struct address_space *mapping, u64 addr)
+{
+	struct volatile_range *found;
+	struct rb_root *root;
+
+	root = mapping_to_root(mapping);
+	if (!root)
+		return 0;
+
+	found = vrange_rb_search(root, addr, addr);
+	if (!found)
+		return 0;
+
+	return found->purged;
+}
+
+
+/*
+ * Cleans up any volatile ranges.
+ */
+void volatile_range_clear(struct volatile_fs_head *head,
+				struct address_space *mapping)
+{
+	struct volatile_range *tozap;
+	struct rb_root *root;
+
+	WARN_ON(!mutex_is_locked(&head->lock));
+
+	root = mapping_to_root(mapping);
+	if (!root)
+		return;
+
+	while (!RB_EMPTY_ROOT(root)) {
+		tozap = container_of(root->rb_node, struct volatile_range,
+									node);
+		vrange_del(head, root, tozap);
+	}
+	mapping_free_root(root);
+}
+
+
+static int __init volatile_init(void)
+{
+	int i, size;
+
+	size = 1U << mapping_hash_shift;
+	mapping_hash = kzalloc(sizeof(mapping_hash)*size, GFP_KERNEL);
+	for (i = 0; i < size; i++)
+		INIT_HLIST_HEAD(&mapping_hash[i]);
+
+	return 0;
+}
+arch_initcall(volatile_init);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
