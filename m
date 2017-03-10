Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 00ADD6B0395
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 23:26:41 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id y66so115623324oig.0
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 20:26:40 -0800 (PST)
Received: from dggrg01-dlp.huawei.com ([45.249.212.187])
        by mx.google.com with ESMTPS id 64si760807oia.188.2017.03.09.20.26.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 20:26:40 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [RFC] mm/compaction: ignore block suitable after check large free page
Date: Fri, 10 Mar 2017 12:20:48 +0800
Message-ID: <1489119648-59583-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, rientjes@google.com, minchan@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com, liubo95@huawei.com

If the migrate target is a large free page and we ignore suitable,
it may not good for defrag. So move the ignore block suitable after
check large free page.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/compaction.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0fdfde0..4bf2a5d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -991,9 +991,6 @@ static bool too_many_isolated(struct zone *zone)
 static bool suitable_migration_target(struct compact_control *cc,
 							struct page *page)
 {
-	if (cc->ignore_block_suitable)
-		return true;
-
 	/* If the page is a large free page, then disallow migration */
 	if (PageBuddy(page)) {
 		/*
@@ -1005,6 +1002,9 @@ static bool suitable_migration_target(struct compact_control *cc,
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
