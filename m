Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19CB96B0038
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 07:31:52 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id p41so261343806otb.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:31:52 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id h124si5811562oif.214.2017.03.14.04.31.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Mar 2017 04:31:51 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v1] mm/compaction: ignore block suitable after check large free page
Date: Tue, 14 Mar 2017 19:25:43 +0800
Message-ID: <1489490743-5364-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, rientjes@google.com, minchan@kernel.org
Cc: guohanjun@huawei.com, qiuxishi@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

By reviewing code, I find that if the migrate target is a large free page
and we ignore suitable, it may splite large target free page into
smaller block which is not good for defrag. So move the ignore block
suitable after check large free page.

As Vlastimil pointed out in RFC version that this patch is just based on
logical analyses which might be better for future-proofing the function
and it is most likely won't have any visible effect right now, for
direct compaction shouldn't have to be called if there's a
>=pageblock_order page already available.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/compaction.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 81e1eaa..09c5282 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -992,9 +992,6 @@ static bool too_many_isolated(struct zone *zone)
 static bool suitable_migration_target(struct compact_control *cc,
 							struct page *page)
 {
-	if (cc->ignore_block_suitable)
-		return true;
-
 	/* If the page is a large free page, then disallow migration */
 	if (PageBuddy(page)) {
 		/*
@@ -1006,6 +1003,9 @@ static bool suitable_migration_target(struct compact_control *cc,
 			return false;
 	}
 
+	if (cc->ignore_block_suitable)
+		return true;
+
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
 	if (migrate_async_suitable(get_pageblock_migratetype(page)))
 		return true;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
