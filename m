Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 093DF6B005D
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 06:33:41 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so10081941pbb.14
        for <linux-mm@kvack.org>; Sat, 22 Sep 2012 03:33:41 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH 2/5] mm/readahead: Change the condition for SetPageReadahead
Date: Sat, 22 Sep 2012 16:03:11 +0530
Message-Id: <82b88a97e1b86b718fe8e4616820d224f6abbc52.1348309711.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1348290849.git.rprabhu@wnohang.net>
References: <cover.1348290849.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1348309711.git.rprabhu@wnohang.net>
References: <cover.1348309711.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: fengguang.wu@intel.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

If page lookup from radix_tree_lookup is successful and its index page_idx ==
nr_to_read - lookahead_size, then SetPageReadahead never gets called, so this
fixes that.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 mm/readahead.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 461fcc0..fec726c 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -189,8 +189,10 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			break;
 		page->index = page_offset;
 		list_add(&page->lru, &page_pool);
-		if (page_idx == nr_to_read - lookahead_size)
+		if (page_idx >= nr_to_read - lookahead_size) {
 			SetPageReadahead(page);
+			lookahead_size = 0;
+		}
 		ret++;
 	}
 
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
