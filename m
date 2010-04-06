Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7B07E6B01FC
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:31:41 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] radix_tree_tag_get() is not as safe as the docs make out
Date: Tue, 06 Apr 2010 20:31:34 +0100
Message-ID: <20100406193134.26429.78585.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@osdl.org, akpm@linux-foundation.org, npiggin@suse.de
Cc: paulmck@linux.vnet.ibm.com, corbet@lwn.net, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

radix_tree_tag_get() is not safe to use concurrently with radix_tree_tag_set()
or radix_tree_tag_clear().  The problem is that the double tag_get() in
radix_tree_tag_get():

		if (!tag_get(node, tag, offset))
			saw_unset_tag = 1;
		if (height == 1) {
			int ret = tag_get(node, tag, offset);

may see the value change due to the action of set/clear.  RCU is no protection
against this as no pointers are being changed, no nodes are being replaced
according to a COW protocol - set/clear alter the node directly.

The documentation in linux/radix-tree.h, however, proclaims that
radix_tree_tag_get() is an exception to the rule that "any function modifying
the tree or tags (...) must exclude other modifications, and exclude any
functions reading the tree".

To this end, remove radix_tree_tag_get() from that list, and comment on its
definition that the caller is responsible for preventing concurrent access with
set/clear.

Furthermore, radix_tree_tag_get() is not safe with respect to
radix_tree_delete() either as that also modifies the tags directly.

An alternative would be to drop the BUG_ON() from radix_tree_tag_get() and note
that it may produce an untrustworthy answer if not so protected.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/radix-tree.h |    3 +--
 lib/radix-tree.c           |    4 ++++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index c5da749..33daa70 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -100,14 +100,13 @@ do {									\
  * The notable exceptions to this rule are the following functions:
  * radix_tree_lookup
  * radix_tree_lookup_slot
- * radix_tree_tag_get
  * radix_tree_gang_lookup
  * radix_tree_gang_lookup_slot
  * radix_tree_gang_lookup_tag
  * radix_tree_gang_lookup_tag_slot
  * radix_tree_tagged
  *
- * The first 7 functions are able to be called locklessly, using RCU. The
+ * The first 6 functions are able to be called locklessly, using RCU. The
  * caller must ensure calls to these functions are made within rcu_read_lock()
  * regions. Other readers (lock-free or otherwise) and modifications may be
  * running concurrently.
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 6b9670d..795a3bb 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -556,6 +556,10 @@ EXPORT_SYMBOL(radix_tree_tag_clear);
  *
  *  0: tag not present or not set
  *  1: tag set
+ *
+ * The caller must make sure this function does not run concurrently with
+ * radix_tree_tag_set/clear() or radix_tree_delete() as these modify the nodes
+ * directly to alter the tags.
  */
 int radix_tree_tag_get(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
