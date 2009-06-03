Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A69686B0099
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:05:20 -0400 (EDT)
Date: Wed, 3 Jun 2009 16:47:23 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] ksm: fix losing visibility of part of rmap_item->next list
Message-ID: <20090603144723.GC30426@random.random>
References: <20090603144552.GB30426@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090603144552.GB30426@random.random>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, Izik Eidus <ieidus@redhat.com>, nickpiggin@yahoo.com.au, chrisw@redhat.com, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

The tree_item->rmap_item is the head of the list and as such it must
not be overwritten except in the case that the element we removed
(rmap_item) was the previous head of the list, in which case it would
also have rmap_item->prev set to null.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/ksm.c b/mm/ksm.c
index 74d921b..6d8dfee 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -397,10 +397,10 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 				free_tree_item(tree_item);
 				nnodes_stable_tree--;
 			} else if (!rmap_item->prev) {
+				BUG_ON(tree_item->rmap_item != rmap_item);
 				tree_item->rmap_item = rmap_item->next;
-			} else {
-				tree_item->rmap_item = rmap_item->prev;
-			}
+			} else
+				BUG_ON(tree_item->rmap_item == rmap_item);
 		} else {
 			/*
 			 * We dont rb_erase(&tree_item->node) here, beacuse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
