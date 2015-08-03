Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 113789003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 11:02:46 -0400 (EDT)
Received: by lbbpo9 with SMTP id po9so5561734lbb.2
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 08:02:45 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id cr8si5858550lad.24.2015.08.03.08.02.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 08:02:43 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] mm: vmscan: never isolate more pages than necessary
Date: Mon, 3 Aug 2015 18:02:27 +0300
Message-ID: <1438614147-30419-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If transparent huge pages are enabled, we can isolate many more pages
than we actually need to scan, because we count both single and huge
pages equally in isolate_lru_pages().

Since commit 5bc7b8aca942d ("mm: thp: add split tail pages to shrink
page list in page reclaim"), we scan all the tail pages immediately
after a huge page split (see shrink_page_list()). As a result, we can
reclaim up to SWAP_CLUSTER_MAX * HPAGE_PMD_NR (512 MB) in one run!

This is easy to catch on memcg reclaim with zswap enabled. The latter
makes swapout instant so that if we happen to scan an unreferenced huge
page we will evict both its head and tail pages immediately, which is
likely to result in excessive reclaim.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/vmscan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5221e19e98f4..94092fd3b96b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1387,7 +1387,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_taken = 0;
 	unsigned long scan;
 
-	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
+	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
+					!list_empty(src); scan++) {
 		struct page *page;
 		int nr_pages;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
