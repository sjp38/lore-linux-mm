Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C339D6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 12:12:31 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so35307628pab.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 09:12:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p28si10260229pfk.183.2016.08.24.09.12.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Aug 2016 09:12:25 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC] mm: Don't use radix tree writeback tags for pages in swap cache
References: <1470759443-9229-1-git-send-email-ying.huang@intel.com>
	<57AA061B.2050002@intel.com>
	<87oa51513n.fsf@yhuang-mobile.sh.intel.com>
Date: Wed, 24 Aug 2016 09:12:19 -0700
In-Reply-To: <87oa51513n.fsf@yhuang-mobile.sh.intel.com> (Ying Huang's message
	of "Tue, 9 Aug 2016 10:00:28 -0700")
Message-ID: <87shtudu3g.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, "Huang, Ying" <ying.huang@intel.com>

"Huang, Ying" <ying.huang@intel.com> writes:

> Hi, Dave,
>
> Dave Hansen <dave.hansen@intel.com> writes:
>
>> On 08/09/2016 09:17 AM, Huang, Ying wrote:
>>> File pages uses a set of radix tags (DIRTY, TOWRITE, WRITEBACK) to
>>> accelerate finding the pages with the specific tag in the the radix tree
>>> during writing back an inode.  But for anonymous pages in swap cache,
>>> there are no inode based writeback.  So there is no need to find the
>>> pages with some writeback tags in the radix tree.  It is no necessary to
>>> touch radix tree writeback tags for pages in swap cache.
>>
>> Seems simple enough.  Do we do any of this unnecessary work for the
>> other radix tree tags?  If so, maybe we should just fix this once and
>> for all.  Could we, for instance, WARN_ONCE() in radix_tree_tag_set() if
>> it sees a swap mapping get handed in there?
>
> Good idea!  I will do that and try to catch other places if any.

I tested all (18) anonymous pages related test cases in vm-scalability
with a debug patch to WARN_ONCE for all swap mapping tag operations.
There are no other tag operations for swap mapping caught.  Below is the
patch I used for debugging.

Best Regards,
Huang, Ying

----------------------------------------->
    dbg: find all tag operations for swap cache

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 4c45105..9a239ec 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -106,16 +106,24 @@ struct radix_tree_node {
 
 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
 struct radix_tree_root {
+	bool			swap;
 	gfp_t			gfp_mask;
 	struct radix_tree_node	__rcu *rnode;
 };
 
 #define RADIX_TREE_INIT(mask)	{					\
+	.swap = false,							\
 	.gfp_mask = (mask),						\
 	.rnode = NULL,							\
 }
 
-#define RADIX_TREE(name, mask) \
+#define RADIX_TREE_INIT_SWAP(mask)	{				\
+	.swap = true,							\
+	.gfp_mask = (mask),						\
+	.rnode = NULL,							\
+}
+
+#define RADIX_TREE(name, mask)					\
 	struct radix_tree_root name = RADIX_TREE_INIT(mask)
 
 #define INIT_RADIX_TREE(root, mask)					\
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 1b7bf73..51677bf 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -765,6 +765,8 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 	struct radix_tree_node *node, *parent;
 	unsigned long maxindex;
 
+	WARN_ON_ONCE(root->swap);
+
 	radix_tree_load_root(root, &node, &maxindex);
 	BUG_ON(index > maxindex);
 
@@ -828,6 +830,8 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 	unsigned long maxindex;
 	int uninitialized_var(offset);
 
+	WARN_ON_ONCE(root->swap);
+
 	radix_tree_load_root(root, &node, &maxindex);
 	if (index > maxindex)
 		return NULL;
@@ -867,6 +871,8 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 	struct radix_tree_node *node, *parent;
 	unsigned long maxindex;
 
+	WARN_ON_ONCE(root->swap);
+
 	if (!root_tag_get(root, tag))
 		return 0;
 
@@ -1050,6 +1056,8 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 	unsigned long tagged = 0;
 	unsigned long index = *first_indexp;
 
+	WARN_ON_ONCE(root->swap);
+
 	radix_tree_load_root(root, &child, &maxindex);
 	last_index = min(last_index, maxindex);
 	if (index > last_index)
@@ -1240,6 +1248,8 @@ radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
 	void **slot;
 	unsigned int ret = 0;
 
+	WARN_ON_ONCE(root->swap);
+
 	if (unlikely(!max_items))
 		return 0;
 
@@ -1281,6 +1291,8 @@ radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
 	void **slot;
 	unsigned int ret = 0;
 
+	WARN_ON_ONCE(root->swap);
+
 	if (unlikely(!max_items))
 		return 0;
 
@@ -1590,6 +1602,8 @@ struct radix_tree_node *radix_tree_replace_clear_tags(
 	struct radix_tree_node *node;
 	void **slot;
 
+	WARN_ON_ONCE(root->swap);
+
 	__radix_tree_lookup(root, index, &node, &slot);
 
 	if (node) {
diff --git a/mm/swap_state.c b/mm/swap_state.c
index c8310a3..0059653 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -34,7 +34,7 @@ static const struct address_space_operations swap_aops = {
 
 struct address_space swapper_spaces[MAX_SWAPFILES] = {
 	[0 ... MAX_SWAPFILES - 1] = {
-		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
+		.page_tree	= RADIX_TREE_INIT_SWAP(GFP_ATOMIC|__GFP_NOWARN),
 		.i_mmap_writable = ATOMIC_INIT(0),
 		.a_ops		= &swap_aops,
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
