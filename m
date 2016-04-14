Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B34F828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:18:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c20so131054547pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:18:27 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id uk4si9817724pab.234.2016.04.14.07.18.26
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:18:26 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 01/29] radix-tree: Introduce radix_tree_empty
Date: Thu, 14 Apr 2016 10:16:22 -0400
Message-Id: <1460643410-30196-2-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

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
index 51a97ac..83f708e 100644
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
index 3a519a0..ba3f60d 100644
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
