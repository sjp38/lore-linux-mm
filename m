Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6937B6B025E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 09:35:57 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so97742741lfg.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 06:35:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iv3si24445119wjb.153.2016.04.25.06.35.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 06:35:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH mmotm 2/3] mm, compaction: fix crash in get_pfnblock_flags_mask() from isolate_freepages():
Date: Mon, 25 Apr 2016 15:35:49 +0200
Message-Id: <1461591350-28700-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1461591350-28700-1-git-send-email-vbabka@suse.cz>
References: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

In isolate_freepages(), low_pfn was mistakenly initialized to
pageblock_start_pfn() instead of pageblock_end_pfn(), creating a possible
underflow, as described by Hugh:

   There's a case when that "block_start_pfn -= pageblock_nr_pages" loop can
   pass through 0 and end up trying to access a pageblock before the start of
   the mem_map[].

Fixes: mmotm mm-compaction-wrap-calculating-first-and-last-pfn-of-pageblock.patch
Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 759c3ac73ced..6a49d1b35515 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -999,7 +999,7 @@ static void isolate_freepages(struct compact_control *cc)
 	block_start_pfn = pageblock_start_pfn(cc->free_pfn);
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
-	low_pfn = pageblock_start_pfn(cc->migrate_pfn);
+	low_pfn = pageblock_end_pfn(cc->migrate_pfn);
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
