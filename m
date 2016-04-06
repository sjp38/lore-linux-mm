Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8A96B007E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:21:52 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bx7so24273707pad.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:21:52 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yk5si6891850pab.160.2016.04.06.14.21.50
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:50 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 01/30] radix-tree: Introduce radix_tree_empty
Date: Wed,  6 Apr 2016 17:21:10 -0400
Message-Id: <1459977699-2349-2-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

The irqdomain code was checking for 0 or 1 entries, not 0 entries like
the comment said they were.  Introduce a new helper that will actually
check for an empty tree.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/radix-tree.h | 5 +++++
 kernel/irq/irqdomain.c     | 7 +------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 51a97ac8bfbf..83f708e5db59 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -136,6 +136,11 @@ do {									\
 	(root)->rnode = NULL;						\
 } while (0)
 
+static inline bool radix_tree_empty(struct radix_tree_root *root)
+{
+	return root->rnode == NULL;
+}
+
 /**
  * Radix-tree synchronization
  *
diff --git a/kernel/irq/irqdomain.c b/kernel/irq/irqdomain.c
index 3a519a01118b..ba3f60d8df2f 100644
--- a/kernel/irq/irqdomain.c
+++ b/kernel/irq/irqdomain.c
@@ -139,12 +139,7 @@ void irq_domain_remove(struct irq_domain *domain)
 {
 	mutex_lock(&irq_domain_mutex);
 
-	/*
-	 * radix_tree_delete() takes care of destroying the root
-	 * node when all entries are removed. Shout if there are
-	 * any mappings left.
-	 */
-	WARN_ON(domain->revmap_tree.height);
+	WARN_ON(!radix_tree_empty(&domain->revmap_tree));
 
 	list_del(&domain->link);
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
