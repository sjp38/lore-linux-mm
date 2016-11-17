Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2666B034F
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:32:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so57530596wmw.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:32:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id zb5si4189574wjb.222.2016.11.17.11.32.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:32:47 -0800 (PST)
Date: Thu, 17 Nov 2016 14:32:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 9/9] mm: workingset: restore refault tracking for single-page
 files
Message-ID: <20161117193244.GF23430@cmpxchg.org>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117191138.22769-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Shadow entries in the page cache used to be accounted behind the radix
tree implementation's back in the upper bits of node->count, and the
radix tree code extending a single-entry tree with a shadow entry in
root->rnode would corrupt that counter. As a result, we could not put
shadow entries at index 0 if the tree didn't have any other entries,
and that means no refault detection for any single-page file.

Now that the shadow entries are tracked natively in the radix tree's
exceptional counter, this is no longer necessary. Extending and
shrinking the tree from and to single entries in root->rnode now does
the right thing when the entry is exceptional, remove that limitation.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/filemap.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 7d92032277ff..ae7b6992aded 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -164,14 +164,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 		__radix_tree_lookup(&mapping->page_tree, page->index + i,
 				    &node, &slot);
 
-		if (!node) {
-			VM_BUG_ON_PAGE(nr != 1, page);
-			/*
-			 * We need a node to properly account shadow
-			 * entries. Don't plant any without. XXX
-			 */
-			shadow = NULL;
-		}
+		VM_BUG_ON_PAGE(!node && nr != 1, page);
 
 		radix_tree_clear_tags(&mapping->page_tree, node, slot);
 		__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
