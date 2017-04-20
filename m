Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85E0A6B03C0
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 06:24:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x8so8081265lfd.21
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 03:24:30 -0700 (PDT)
Received: from bes.se.axis.com (bes.se.axis.com. [195.60.68.10])
        by mx.google.com with ESMTP id 143si3278197ljj.139.2017.04.20.03.24.28
        for <linux-mm@kvack.org>;
        Thu, 20 Apr 2017 03:24:28 -0700 (PDT)
From: Rabin Vincent <rabin.vincent@axis.com>
Subject: [PATCH] mm: prevent NR_ISOLATE_* stats from going negative
Date: Thu, 20 Apr 2017 12:24:25 +0200
Message-Id: <1492683865-27549-1-git-send-email-rabin.vincent@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>, Ming Ling <ming.ling@spreadtrum.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

From: Rabin Vincent <rabinv@axis.com>

Commit 6afcf8ef0ca0 ("mm, compaction: fix NR_ISOLATED_* stats for pfn
based migration") moved the dec_node_page_state() call (along with the
page_is_file_cache() call) to after putback_lru_page().  But
page_is_file_cache() can change after putback_lru_page() is called, so
it should be called before putback_lru_page(), as it was before that
patch, to prevent NR_ISOLATE_* stats from going negative.

Without this fix, non-CONFIG_SMP kernels end up hanging in the
while(too_many_isolated()) { congestion_wait() } loop in
shrink_active_list() due to the negative stats.

 Mem-Info:
  active_anon:32567 inactive_anon:121 isolated_anon:1
  active_file:6066 inactive_file:6639 isolated_file:4294967295
                                                    ^^^^^^^^^^
  unevictable:0 dirty:115 writeback:0 unstable:0
  slab_reclaimable:2086 slab_unreclaimable:3167
  mapped:3398 shmem:18366 pagetables:1145 bounce:0
  free:1798 free_pcp:13 free_cma:0

Fixes: 6afcf8ef0ca0 ("mm, compaction: fix NR_ISOLATED_* stats for pfn based migration")
Cc: Ming Ling <ming.ling@spreadtrum.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>
Signed-off-by: Rabin Vincent <rabinv@axis.com>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index ed97c2c..738f1d5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -184,9 +184,9 @@ void putback_movable_pages(struct list_head *l)
 			unlock_page(page);
 			put_page(page);
 		} else {
-			putback_lru_page(page);
 			dec_node_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
+			putback_lru_page(page);
 		}
 	}
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
