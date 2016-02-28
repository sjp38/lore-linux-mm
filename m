Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 841C56B0253
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 00:18:08 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l68so20725193wml.0
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 21:18:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j12si25020481wjn.187.2016.02.27.21.18.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Feb 2016 21:18:07 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sun, 28 Feb 2016 16:09:29 +1100
Subject: [PATCH 2/3] radix-tree: make 'indirect' bit available to exception
 entries.
Message-ID: <145663616977.3865.9772784012366988314.stgit@notabene>
In-Reply-To: <145663588892.3865.9987439671424028216.stgit@notabene>
References: <145663588892.3865.9987439671424028216.stgit@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

A pointer to a radix_tree_node will always have the 'exception'
bit cleared, so if the exception bit is set the value cannot
be an indirect pointer.  Thus it is safe to make the 'indirect bit'
available to store extra information in exception entries.

This patch adds a 'PTR_MASK' and a value is only treated as
an indirect (pointer) entry the 2 ls-bits are '01'.

The change in radix-tree.c ensures the stored value still looks like an
indirect pointer, and saves a load as well.

We could swap the two bits and so keep all the exectional bits contigious.
But I have other plans for that bit....

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/radix-tree.h |   11 +++++++++--
 lib/radix-tree.c           |    2 +-
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 968150ab8a1c..450c12b546b7 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -40,8 +40,13 @@
  * Indirect pointer in fact is also used to tag the last pointer of a node
  * when it is shrunk, before we rcu free the node. See shrink code for
  * details.
+ *
+ * To allow an exception entry to only lose one bit, we ignore
+ * the INDIRECT bit when the exception bit is set.  So an entry is
+ * indirect if the least significant 2 bits are 01.
  */
 #define RADIX_TREE_INDIRECT_PTR		1
+#define RADIX_TREE_INDIRECT_MASK	3
 /*
  * A common use of the radix tree is to store pointers to struct pages;
  * but shmem/tmpfs needs also to store swap entries in the same tree:
@@ -53,7 +58,8 @@
 
 static inline int radix_tree_is_indirect_ptr(void *ptr)
 {
-	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
+	return ((unsigned long)ptr & RADIX_TREE_INDIRECT_MASK)
+		== RADIX_TREE_INDIRECT_PTR;
 }
 
 /*** radix-tree API starts here ***/
@@ -221,7 +227,8 @@ static inline void *radix_tree_deref_slot_protected(void **pslot,
  */
 static inline int radix_tree_deref_retry(void *arg)
 {
-	return unlikely((unsigned long)arg & RADIX_TREE_INDIRECT_PTR);
+	return unlikely(((unsigned long)arg & RADIX_TREE_INDIRECT_MASK)
+			== RADIX_TREE_INDIRECT_PTR);
 }
 
 /**
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 6b79e9026e24..37d4643ab5c0 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1305,7 +1305,7 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 		 * to force callers to retry.
 		 */
 		if (root->height == 0)
-			*((unsigned long *)&to_free->slots[0]) |=
+			*((unsigned long *)&to_free->slots[0]) =
 						RADIX_TREE_INDIRECT_PTR;
 
 		radix_tree_node_free(to_free);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
