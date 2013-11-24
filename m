Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id C22496B0039
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 18:39:23 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so1627267bkb.12
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 15:39:23 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id b2si8737584bko.341.2013.11.24.15.39.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 24 Nov 2013 15:39:22 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/9] lib: radix-tree: radix_tree_delete_item()
Date: Sun, 24 Nov 2013 18:38:21 -0500
Message-Id: <1385336308-27121-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Provide a function that does not just delete an entry at a given
index, but also allows passing in an expected item.  Delete only if
that item is still located at the specified index.

This is handy when lockless tree traversals want to delete entries as
well because they don't have to do an second, locked lookup to verify
the slot has not changed under them before deleting the entry.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/radix-tree.h |  1 +
 lib/radix-tree.c           | 31 +++++++++++++++++++++++++++----
 2 files changed, 28 insertions(+), 4 deletions(-)

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
index 7811ed3..f442e32 100644
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
@@ -1422,6 +1430,21 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 out:
 	return slot;
 }
+EXPORT_SYMBOL(radix_tree_delete_item);
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
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
