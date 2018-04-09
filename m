Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05C1D6B0003
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 21:58:27 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u11-v6so4019155pls.22
        for <linux-mm@kvack.org>; Sun, 08 Apr 2018 18:58:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 91-v6sor6086016plh.58.2018.04.08.18.58.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Apr 2018 18:58:25 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: workingset: fix NULL ptr dereference
Date: Mon,  9 Apr 2018 10:58:15 +0900
Message-Id: <20180409015815.235943-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>

Recently, I got a report like below.

[ 7858.792946] [<ffffff80086f4de0>] __list_del_entry+0x30/0xd0
[ 7858.792951] [<ffffff8008362018>] list_lru_del+0xac/0x1ac
[ 7858.792957] [<ffffff800830f04c>] page_cache_tree_insert+0xd8/0x110
[ 7858.792962] [<ffffff8008310188>] __add_to_page_cache_locked+0xf8/0x4e0
[ 7858.792967] [<ffffff800830ff34>] add_to_page_cache_lru+0x50/0x1ac
[ 7858.792972] [<ffffff800830fdd0>] pagecache_get_page+0x468/0x57c
[ 7858.792979] [<ffffff80085d081c>] __get_node_page+0x84/0x764
[ 7858.792986] [<ffffff800859cd94>] f2fs_iget+0x264/0xdc8
[ 7858.792991] [<ffffff800859ee00>] f2fs_lookup+0x3b4/0x660
[ 7858.792998] [<ffffff80083d2540>] lookup_slow+0x1e4/0x348
[ 7858.793003] [<ffffff80083d0eb8>] walk_component+0x21c/0x320
[ 7858.793008] [<ffffff80083d0010>] path_lookupat+0x90/0x1bc
[ 7858.793013] [<ffffff80083cfe6c>] filename_lookup+0x8c/0x1a0
[ 7858.793018] [<ffffff80083c52d0>] vfs_fstatat+0x84/0x10c
[ 7858.793023] [<ffffff80083c5b00>] SyS_newfstatat+0x28/0x64

v4.9 kenrel already has the d3798ae8c6f3,("mm: filemap: don't
plant shadow entries without radix tree node") so I thought
it should be okay. When I was googling, I found others report
such problem and I think current kernel still has the problem.

https://bugzilla.redhat.com/show_bug.cgi?id=1431567
https://bugzilla.redhat.com/show_bug.cgi?id=1420335

It assumes shadow entry of radix tree relies on the init state
that node->private_list allocated should be list_empty state.
Currently, it's initailized in SLAB constructor which means
node of radix tree would be initialized only when *slub allocates
new page*, not *new object*. So, if some FS or subsystem pass
gfp_mask to __GFP_ZERO, slub allocator will do memset blindly.
That means allocated node can have !list_empty(node->private_list).
It ends up calling NULL deference at workingset_update_node by
failing list_empty check.

This patch should fix it.

Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
Reported-by: Chris Fries <cfries@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
If it is reviewed and proved with testing, I will resend the patch to
Ccing stable@vger.kernel.org.

Thanks.

 lib/radix-tree.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 8e00138d593f..afcbdb6c495f 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -428,6 +428,7 @@ radix_tree_node_alloc(gfp_t gfp_mask, struct radix_tree_node *parent,
 		ret->exceptional = exceptional;
 		ret->parent = parent;
 		ret->root = root;
+		INIT_LIST_HEAD(&ret->private_list);
 	}
 	return ret;
 }
@@ -2234,7 +2235,6 @@ radix_tree_node_ctor(void *arg)
 	struct radix_tree_node *node = arg;
 
 	memset(node, 0, sizeof(*node));
-	INIT_LIST_HEAD(&node->private_list);
 }
 
 static __init unsigned long __maxindex(unsigned int height)
-- 
2.17.0.484.g0c8726318c-goog
