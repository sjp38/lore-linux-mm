Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3739C6B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 19:54:51 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id p10so5172748pdj.13
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:54:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ag3si17819496pbc.61.2014.09.22.16.54.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 16:54:50 -0700 (PDT)
Message-ID: <5420B571.4030702@oracle.com>
Date: Mon, 22 Sep 2014 19:49:05 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: NULL ptr deref in migrate_page_move_mapping
References: <5420407E.8040406@oracle.com> <alpine.LSU.2.11.1409221531570.1244@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1409221531570.1244@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>

Hi Hugh,

On 09/22/2014 07:04 PM, Hugh Dickins wrote:
>> but I'm not sure what went wrong.
> Most likely would be a zeroing of the radix_tree node, just as you
> were experiencing zeroing of other mm structures in earlier weeks.
> 
> Not that I've got any suggestions on where to take it from there.

I've actually mailed this one because I thought that the root reason
isn't the same as the corruption before.

Previously, the radix tree itself would get corrupted, so we'd deref
a NULL ptr inside the radix tree functions. In this case, it seems
that if it was indeed a corruption, it affected the objects that are
held in the tree rather than the tree itself.

If you suspect it's a corruption specific to the tree, how about:

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 33170db..9dc19d9 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -27,6 +27,8 @@
 #include <linux/kernel.h>
 #include <linux/rcupdate.h>

+#define RADIX_POISON 0x8BADBEEF
+
 /*
  * An indirect pointer (root->rnode pointing to a radix_tree_node, rather
  * than a data item) is signalled by the low bit set in the root->rnode
@@ -85,6 +87,7 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
 #define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)

 struct radix_tree_node {
+	unsigned int	poison_start;
 	unsigned int	path;	/* Offset in parent & height from the bottom */
 	unsigned int	count;
 	union {
@@ -101,19 +104,24 @@ struct radix_tree_node {
 	struct list_head private_list;
 	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
+	unsigned int	poison_end;
 };

 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
 struct radix_tree_root {
+	unsigned int		poison_start;
 	unsigned int		height;
 	gfp_t			gfp_mask;
 	struct radix_tree_node	__rcu *rnode;
+	unsigned int		poison_end;
 };

 #define RADIX_TREE_INIT(mask)	{					\
 	.height = 0,							\
 	.gfp_mask = (mask),						\
 	.rnode = NULL,							\
+	.poison_start = RADIX_POISON,					\
+	.poison_end = RADIX_POISON,					\
 }

 #define RADIX_TREE(name, mask) \
@@ -124,6 +132,8 @@ do {									\
 	(root)->height = 0;						\
 	(root)->gfp_mask = (mask);					\
 	(root)->rnode = NULL;						\
+	(root)->poison_start = RADIX_POISON;				\
+	(root)->poison_end = RADIX_POISON;				\
 } while (0)

 /**
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 3291a8e..5ef8f52 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -230,7 +230,7 @@ static void radix_tree_node_rcu_free(struct rcu_head *head)

 	node->slots[0] = NULL;
 	node->count = 0;
-
+	BUG_ON(node->poison_start != RADIX_POISON || node->poison_end != RADIX_POISON);
 	kmem_cache_free(radix_tree_node_cachep, node);
 }

@@ -460,6 +460,7 @@ int radix_tree_insert(struct radix_tree_root *root,
 		node->count++;
 		BUG_ON(tag_get(node, 0, index & RADIX_TREE_MAP_MASK));
 		BUG_ON(tag_get(node, 1, index & RADIX_TREE_MAP_MASK));
+		BUG_ON(node->poison_start != RADIX_POISON || node->poison_end != RADIX_POISON);
 	} else {
 		BUG_ON(root_tag_get(root, 0));
 		BUG_ON(root_tag_get(root, 1));
@@ -489,11 +490,11 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 	struct radix_tree_node *node, *parent;
 	unsigned int height, shift;
 	void **slot;
-
+	BUG_ON(root->poison_start != RADIX_POISON || root->poison_end != RADIX_POISON);
 	node = rcu_dereference_raw(root->rnode);
 	if (node == NULL)
 		return NULL;
-
+	BUG_ON(node->poison_start != RADIX_POISON || node->poison_end != RADIX_POISON);
 	if (!radix_tree_is_indirect_ptr(node)) {
 		if (index > 0)
 			return NULL;
@@ -518,7 +519,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 		node = rcu_dereference_raw(*slot);
 		if (node == NULL)
 			return NULL;
-
+		BUG_ON(node->poison_start != RADIX_POISON || node->poison_end != RADIX_POISON);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	} while (height > 0);

I'll run with it for the night.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
