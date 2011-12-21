Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 9B9D46B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 18:57:22 -0500 (EST)
Received: by iacb35 with SMTP id b35so14068694iac.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 15:57:22 -0800 (PST)
Date: Wed, 21 Dec 2011 15:57:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] radix_tree: expand comment on optimization
In-Reply-To: <20111221221527.GE23662@dastard>
Message-ID: <alpine.LSU.2.00.1112211555430.25868@eggly.anvils>
References: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils> <20111221050740.GD23662@dastard> <alpine.LSU.2.00.1112202218490.4026@eggly.anvils> <20111221221527.GE23662@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Expand comment on optimization in radix_tree_range_tag_if_tagged(),
along the lines proposed by Dave Chinner.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
And with -p2, this patch will also apply to the rtth tree.

 lib/radix-tree.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- mmotm/lib/radix-tree.c	2011-12-16 20:40:26.152758485 -0800
+++ linux/lib/radix-tree.c	2011-12-21 14:57:20.073657540 -0800
@@ -703,7 +703,13 @@ unsigned long radix_tree_range_tag_if_ta
 			node = node->parent;
 		}
 
-		/* optimization: no need to walk up from this node again */
+		/*
+		 * Small optimization: now clear that node pointer.
+		 * Since all of this slot's ancestors now have the tag set
+		 * from setting it above, we have no further need to walk
+		 * back up the tree setting tags, until we update slot to
+		 * point to another radix_tree_node.
+		 */
 		node = NULL;
 
 next:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
