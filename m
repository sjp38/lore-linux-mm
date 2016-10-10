Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 990B46B0069
	for <linux-mm@kvack.org>; Sun,  9 Oct 2016 23:45:11 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hm5so91648873pac.4
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 20:45:11 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id z7si12211387pac.141.2016.10.09.20.45.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 09 Oct 2016 20:45:10 -0700 (PDT)
Message-ID: <57FB0C89.3040304@huawei.com>
Date: Mon, 10 Oct 2016 11:35:37 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: init gfp mask in kcompactd_do_work()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Yisheng Xie <xieyisheng1@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

We will use gfp_mask in the following path, but it's not init.

kcompactd_do_work
	compact_zone
		gfpflags_to_migratetype

However if not init, gfp_mask is always 0, and the result of
gfpflags_to_migratetype(0) and gfpflags_to_migratetype(GFP_KERNEL)
are the same, but it's a little confusion, so init it first.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9affb29..4b9a9d1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1895,10 +1895,10 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	struct zone *zone;
 	struct compact_control cc = {
 		.order = pgdat->kcompactd_max_order,
+		.gfp_mask = GFP_KERNEL,
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
 		.mode = MIGRATE_SYNC_LIGHT,
 		.ignore_skip_hint = true,
-
 	};
 	bool success = false;
 
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
