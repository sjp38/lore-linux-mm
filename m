Subject: [PATCH] radix-tree:  fix radix_tree_replace_slot
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Tue, 22 Aug 2006 16:25:17 -0400
Message-Id: <1156278317.5622.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I was waiting to hear from Nick on this, but I understand that he has
severely injured one hand, restricting his keyboard access for a while. 

Christoph has been too swamped to take a look, either.   So, having
tested it myself, I'll send it on.

Paul:

could you take a look at this one.  Also, I'll be sending another
rcu-radix-tree "cleanup" patch that I'd like your opinion on.

Lee

Fix radix tree direct slot replacement - 2.6.18-rc4-mm2

radix_tree_replace_slot() was assigning to local variable 'slot'
instead of to where pslot pointed.  Changed to directly replace
location pointed to by argument pslot.

Added comments specifying required locking.

Note that we do not need to rcu_dereference() the slot to
obtain the direct pointer flag, as we hold the tree write locked.

Fixes the migration corruption that we were seeing since the
rcu-radix-tree patches went in.  With this patch, we can back out
page-migration-replace-radix_tree_lookup_slot-with-radix_tree_lockup.patch
to use the more efficient direct access to radix tree slot.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/radix-tree.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6.18-rc4-mm2/include/linux/radix-tree.h
===================================================================
--- linux-2.6.18-rc4-mm2.orig/include/linux/radix-tree.h	2006-08-22 14:30:38.000000000 -0400
+++ linux-2.6.18-rc4-mm2/include/linux/radix-tree.h	2006-08-22 14:36:54.000000000 -0400
@@ -133,12 +133,15 @@ static inline void *radix_tree_deref_slo
  * radix_tree_replace_slot	- replace item in a slot
  * @pslot:	pointer to slot, returned by radix_tree_lookup_slot
  * @item:	new item to store in the slot.
+ *
+ * For use with radix_tree_lookup_slot().  Caller must hold tree write locked
+ * across slot lookup and replacement.
  */
 static inline void radix_tree_replace_slot(void *pslot, void *item)
 {
 	void *slot = *(void **)pslot;
 	BUG_ON(radix_tree_is_direct_ptr(item));
-	rcu_assign_pointer(slot,
+	rcu_assign_pointer(*(void **)pslot,
 		(void *)((unsigned long)item |
 			((unsigned long)slot & RADIX_TREE_DIRECT_PTR)));
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
