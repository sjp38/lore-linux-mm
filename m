Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18A7B6B0287
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:31:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 196so2638263wma.6
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:31:07 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id y89si2246872eda.294.2017.10.12.02.31.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 02:31:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 1EAA998CC3
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 09:31:05 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/8] mm, truncate: Do not check mapping for every page being truncated
Date: Thu, 12 Oct 2017 10:30:57 +0100
Message-Id: <20171012093103.13412-3-mgorman@techsingularity.net>
In-Reply-To: <20171012093103.13412-1-mgorman@techsingularity.net>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@techsingularity.net>

During truncation, the mapping has already been checked for shmem and dax
so it's known that workingset_update_node is required. This patch avoids
the checks on mapping for each page being truncated. In all other cases,
a lookup helper is used to determine if workingset_update_node() needs
to be called. The one danger is that the API is slightly harder to use as
calling workingset_update_node directly without checking for dax or shmem
mappings could lead to surprises. However, the API rarely needs to be used
and hopefully the comment is enough to give people the hint.

sparsetruncate (tiny)
                              4.14.0-rc4             4.14.0-rc4
                             oneirq-v1r1        pickhelper-v1r1
Min          Time      141.00 (   0.00%)      140.00 (   0.71%)
1st-qrtle    Time      142.00 (   0.00%)      141.00 (   0.70%)
2nd-qrtle    Time      142.00 (   0.00%)      142.00 (   0.00%)
3rd-qrtle    Time      143.00 (   0.00%)      143.00 (   0.00%)
Max-90%      Time      144.00 (   0.00%)      144.00 (   0.00%)
Max-95%      Time      147.00 (   0.00%)      145.00 (   1.36%)
Max-99%      Time      195.00 (   0.00%)      191.00 (   2.05%)
Max          Time      230.00 (   0.00%)      205.00 (  10.87%)
Amean        Time      144.37 (   0.00%)      143.82 (   0.38%)
Stddev       Time       10.44 (   0.00%)        9.00 (  13.74%)
Coeff        Time        7.23 (   0.00%)        6.26 (  13.41%)
Best99%Amean Time      143.72 (   0.00%)      143.34 (   0.26%)
Best95%Amean Time      142.37 (   0.00%)      142.00 (   0.26%)
Best90%Amean Time      142.19 (   0.00%)      141.85 (   0.24%)
Best75%Amean Time      141.92 (   0.00%)      141.58 (   0.24%)
Best50%Amean Time      141.69 (   0.00%)      141.31 (   0.27%)
Best25%Amean Time      141.38 (   0.00%)      140.97 (   0.29%)

As you'd expect, the gain is marginal but it can be detected. The differences
in bonnie are all within the noise which is not surprising given the impact
on the microbenchmark.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/swap.h | 11 +++++++++++
 mm/filemap.c         |  7 ++++---
 mm/workingset.c      |  8 +-------
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8a807292037f..78ecacb52095 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -292,8 +292,19 @@ struct vma_swap_readahead {
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
+
+/* Do not use directly, use workingset_lookup_update */
 void workingset_update_node(struct radix_tree_node *node, void *private);
 
+/* Returns workingset_update_node() if the mapping has shadow entries. */
+#define workingset_lookup_update(mapping)				\
+({									\
+	radix_tree_update_node_t __helper = workingset_update_node;	\
+	if (dax_mapping(mapping) || shmem_mapping(mapping))		\
+		__helper = NULL;					\
+	__helper;							\
+})
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
diff --git a/mm/filemap.c b/mm/filemap.c
index dba68e1d9869..d8719d755ca9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -35,6 +35,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
+#include <linux/shmem_fs.h>
 #include <linux/rmap.h>
 #include "internal.h"
 
@@ -134,7 +135,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 			*shadowp = p;
 	}
 	__radix_tree_replace(&mapping->page_tree, node, slot, page,
-			     workingset_update_node, mapping);
+			     workingset_lookup_update(mapping), mapping);
 	mapping->nrpages++;
 	return 0;
 }
@@ -162,7 +163,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 
 		radix_tree_clear_tags(&mapping->page_tree, node, slot);
 		__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
-				     workingset_update_node, mapping);
+				workingset_lookup_update(mapping), mapping);
 	}
 
 	page->mapping = NULL;
@@ -360,7 +361,7 @@ page_cache_tree_delete_batch(struct address_space *mapping, int count,
 		}
 		radix_tree_clear_tags(&mapping->page_tree, iter.node, slot);
 		__radix_tree_replace(&mapping->page_tree, iter.node, slot, NULL,
-				     workingset_update_node, mapping);
+				workingset_lookup_update(mapping), mapping);
 		total_pages++;
 	}
 	mapping->nrpages -= total_pages;
diff --git a/mm/workingset.c b/mm/workingset.c
index 7119cd745ace..a80d52387734 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -341,12 +341,6 @@ static struct list_lru shadow_nodes;
 
 void workingset_update_node(struct radix_tree_node *node, void *private)
 {
-	struct address_space *mapping = private;
-
-	/* Only regular page cache has shadow entries */
-	if (dax_mapping(mapping) || shmem_mapping(mapping))
-		return;
-
 	/*
 	 * Track non-empty nodes that contain only shadow entries;
 	 * unlink those that contain pages or are being freed.
@@ -474,7 +468,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		goto out_invalid;
 	inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->page_tree, node,
-				 workingset_update_node, mapping);
+				 workingset_lookup_update(mapping), mapping);
 
 out_invalid:
 	spin_unlock(&mapping->tree_lock);
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
