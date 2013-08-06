Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id F36436B0033
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 18:44:39 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/9] lib: radix-tree: radix_tree_delete_item()
Date: Tue,  6 Aug 2013 18:44:02 -0400
Message-Id: <1375829050-12654-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Provide a function that does not just delete an entry at a given
index, but also allows passing in an expected item.  Delete only if
that item is still located at the specified index.

This is handy when lockless tree traversals want to delete entries as
well because they don't have to do an second, locked lookup to verify
the slot has not changed under them before deleting the entry.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/radix-tree.h |  1 +
 lib/radix-tree.c           | 30 ++++++++++++++++++++++++++----
 2 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 4039407..1bf0a9c 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -219,6 +219,7 @@ static inline void radix_tree_replace_slot(void **pslot, void *item)
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
 void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
+void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 7811ed3..60b202b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1335,15 +1335,18 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 }
 
 /**
- *	radix_tree_delete    -    delete an item from a radix tree
+ *	radix_tree_delete_item    -    delete an item from a radix tree
  *	@root:		radix tree root
  *	@index:		index key
+ *	@item:		expected item
  *
- *	Remove the item at @index from the radix tree rooted at @root.
+ *	Remove @item at @index from the radix tree rooted at @root.
  *
- *	Returns the address of the deleted item, or NULL if it was not present.
+ *	Returns the address of the deleted item, or NULL if it was not present
+ *	or the entry at the given @index was not @item.
  */
-void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
+void *radix_tree_delete_item(struct radix_tree_root *root,
+			     unsigned long index, void *item)
 {
 	struct radix_tree_node *node = NULL;
 	struct radix_tree_node *slot = NULL;
@@ -1378,6 +1381,11 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 	if (slot == NULL)
 		goto out;
 
+	if (item && slot != item) {
+		slot = NULL;
+		goto out;
+	}
+
 	/*
 	 * Clear all tags associated with the item to be deleted.
 	 * This way of doing it would be inefficient, but seldom is any set.
@@ -1422,6 +1430,20 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 out:
 	return slot;
 }
+
+/**
+ *	radix_tree_delete    -    delete an item from a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *
+ *	Remove the item at @index from the radix tree rooted at @root.
+ *
+ *	Returns the address of the deleted item, or NULL if it was not present.
+ */
+void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
+{
+	return radix_tree_delete_item(root, index, NULL);
+}
 EXPORT_SYMBOL(radix_tree_delete);
 
 /**
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
