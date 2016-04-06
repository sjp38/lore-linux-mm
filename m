Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 33275828DF
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:22:14 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id fe3so40464167pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:22:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id k80si6893726pfb.171.2016.04.06.14.21.52
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:52 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 11/30] radix-tree: Fix deleting a multi-order entry through an alias
Date: Wed,  6 Apr 2016 17:21:20 -0400
Message-Id: <1459977699-2349-12-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

If we deleted an entry through an index which looked up a sibling
pointer, we'd end up zeroing out the wrong slots in the node.
Use get_sibling_offset() to find the right slot.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 42a0492b2ba2..554986599c63 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1557,7 +1557,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 		return entry;
 	}
 
-	offset = index & RADIX_TREE_MAP_MASK;
+	offset = get_sibling_offset(node, slot);
 
 	/*
 	 * Clear all tags associated with the item to be deleted.
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
