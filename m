Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD946B02D2
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:25:44 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b123so74851389itb.3
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:25:44 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id k131si6755563itb.32.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:05 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 14/29] radix-tree: Move rcu_head into a union with private_list
Date: Wed, 16 Nov 2016 16:17:17 -0800
Message-Id: <1479341856-30320-53-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

I want to be able to reference node->parent after freeing node.
Currently node->parent is in a union with rcu_head, so it is overwritten
when the node is put on the RCU list.  We know that private_list is not
referenced after the node is freed, so it is safe for these two members
to share space.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/radix-tree.h | 14 ++++----------
 lib/radix-tree.c           |  1 +
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 8ffb051..66fb8c0 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -88,18 +88,12 @@ struct radix_tree_node {
 	unsigned char	shift;	/* Bits remaining in each slot */
 	unsigned char	offset;	/* Slot offset in parent */
 	unsigned int	count;
+	struct radix_tree_node *parent;		/* Used when ascending tree */
+	void *private_data;			/* For tree user */
 	union {
-		struct {
-			/* Used when ascending tree */
-			struct radix_tree_node *parent;
-			/* For tree user */
-			void *private_data;
-		};
-		/* Used when freeing node */
-		struct rcu_head	rcu_head;
+		struct list_head private_list;	/* For tree user */
+		struct rcu_head	rcu_head;	/* Used when freeing node */
 	};
-	/* For tree user */
-	struct list_head private_list;
 	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
 };
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e917c56..baf4ba1 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -325,6 +325,7 @@ static void radix_tree_node_rcu_free(struct rcu_head *head)
 	 */
 	memset(node->slots, 0, sizeof(node->slots));
 	memset(node->tags, 0, sizeof(node->tags));
+	INIT_LIST_HEAD(&node->private_list);
 
 	kmem_cache_free(radix_tree_node_cachep, node);
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
