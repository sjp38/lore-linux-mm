Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 09D3D6B000E
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 03:21:29 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id uo15so3393680pbc.5
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 00:21:29 -0800 (PST)
Date: Thu, 21 Feb 2013 00:20:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/7] ksm: treat unstable nid like in stable tree
In-Reply-To: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1302210019390.17843@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

An inconsistency emerged in reviewing the NUMA node changes to KSM:
when meeting a page from the wrong NUMA node in a stable tree, we say
that it's okay for comparisons, but not as a leaf for merging; whereas
when meeting a page from the wrong NUMA node in an unstable tree, we
bail out immediately.

Now, it might be that a wrong NUMA node in an unstable tree is more
likely to correlate with instablility (different content, with rbnode
now misplaced) than page migration; but even so, we are accustomed to
instablility in the unstable tree.

Without strong evidence for which strategy is generally better, I'd
rather be consistent with what's done in the stable tree: accept a page
from the wrong NUMA node for comparison, but not as a leaf for merging.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/ksm.c |   19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

--- mmotm.orig/mm/ksm.c	2013-02-20 22:28:23.584001392 -0800
+++ mmotm/mm/ksm.c	2013-02-20 22:28:27.288001480 -0800
@@ -1340,16 +1340,6 @@ struct rmap_item *unstable_tree_search_i
 			return NULL;
 		}
 
-		/*
-		 * If tree_page has been migrated to another NUMA node, it
-		 * will be flushed out and put into the right unstable tree
-		 * next time: only merge with it if merge_across_nodes.
-		 */
-		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
-			put_page(tree_page);
-			return NULL;
-		}
-
 		ret = memcmp_pages(page, tree_page);
 
 		parent = *new;
@@ -1359,6 +1349,15 @@ struct rmap_item *unstable_tree_search_i
 		} else if (ret > 0) {
 			put_page(tree_page);
 			new = &parent->rb_right;
+		} else if (!ksm_merge_across_nodes &&
+			   page_to_nid(tree_page) != nid) {
+			/*
+			 * If tree_page has been migrated to another NUMA node,
+			 * it will be flushed out and put in the right unstable
+			 * tree next time: only merge with it when across_nodes.
+			 */
+			put_page(tree_page);
+			return NULL;
 		} else {
 			*tree_pagep = tree_page;
 			return tree_rmap_item;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
