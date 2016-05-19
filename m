Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE3F6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 07:59:00 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id rw3so110394517obb.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 04:59:00 -0700 (PDT)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id v126si6208589oib.124.2016.05.19.04.58.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 May 2016 04:58:59 -0700 (PDT)
From: Chen Feng <puck.chen@hisilicon.com>
Subject: [PATCH] mm: compact: fix zoneindex in compact
Date: Thu, 19 May 2016 19:58:41 +0800
Message-ID: <1463659121-84124-1-git-send-email-puck.chen@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: puck.chen@hisilicon.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: suzhuangluan@hisilicon.com, dan.zhao@hisilicon.com, qijiwen@hisilicon.com, xuyiping@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com

While testing the kcompactd in my platform 3G MEM only DMA ZONE.
I found the kcompactd never wakeup. It seems the zoneindex
has already minus 1 before. So the traverse here should be <=.

Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8fa2540..e5122d9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1742,7 +1742,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 	struct zone *zone;
 	enum zone_type classzone_idx = pgdat->kcompactd_classzone_idx;
 
-	for (zoneid = 0; zoneid < classzone_idx; zoneid++) {
+	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
 		zone = &pgdat->node_zones[zoneid];
 
 		if (!populated_zone(zone))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
