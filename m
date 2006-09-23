Subject: radix_tree_lookup_slot() comment
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain
Date: Sat, 23 Sep 2006 20:40:21 +0200
Message-Id: <1159036821.5196.8.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi Nick,

I noticed the comment above radix_tree_lookup_slot() did not match the
uses in your lockless pagecache. Would this patch be correct?

---
 lib/radix-tree.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

Index: linux-2.6-mm/lib/radix-tree.c
===================================================================
--- linux-2.6-mm.orig/lib/radix-tree.c	2006-09-23 20:20:21.000000000 +0200
+++ linux-2.6-mm/lib/radix-tree.c	2006-09-23 20:34:31.000000000 +0200
@@ -380,11 +380,10 @@ EXPORT_SYMBOL(radix_tree_insert);
  *	Returns:  the slot corresponding to the position @index in the
  *	radix tree @root. This is useful for update-if-exists operations.
  *
- *	This function cannot be called under rcu_read_lock, it must be
- *	excluded from writers, as must the returned slot for subsequent
- *	use by radix_tree_deref_slot() and radix_tree_replace slot.
- *	Caller must hold tree write locked across slot lookup and
- *	replace.
+ * 	This function can be called under rcu_read_lock iff the slot is not
+ * 	modified by radix_tree_replace_slot, otherwise it must be called
+ * 	exclusive from other writers. Any dereference of the slot must be done
+ * 	using radix_tree_deref_slot.
  */
 void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
