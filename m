Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA6D0828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:59 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so93330995pab.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:59 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id da6si10626228pad.156.2016.04.14.07.17.40
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:40 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 11/29] radix-tree: Fix deleting a multi-order entry through an alias
Date: Thu, 14 Apr 2016 10:16:32 -0400
Message-Id: <1460643410-30196-12-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

If we deleted an entry through an index which looked up a sibling
pointer, we'd end up zeroing out the wrong slots in the node.
Use get_slot_offset() to find the right slot.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index c0366d1..b3364b9 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1558,7 +1558,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 		return entry;
 	}
 
-	offset = index & RADIX_TREE_MAP_MASK;
+	offset = get_slot_offset(node, slot);
 
 	/*
 	 * Clear all tags associated with the item to be deleted.
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
