Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 568876B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 04:35:27 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so3027763wev.27
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 01:35:26 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id hg18si2053183wib.93.2014.07.18.01.35.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 01:35:24 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 4/5] memory-hotplug: sh: suitable memory should go to ZONE_MOVABLE
Date: Fri, 18 Jul 2014 15:56:02 +0800
Message-ID: <1405670163-53747-5-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405670163-53747-1-git-send-email-wangnan0@huawei.com>
References: <1405670163-53747-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel
 Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pei Feiyue <peifeiyue@huawei.com>, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

This patch add new memory to ZONE_MOVABLE if movable zone is setup
and lower than newly added memory for sh.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
---
 arch/sh/mm/init.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 2d089fe..ff9decc 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -487,16 +487,19 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size)
 {
-	pg_data_t *pgdat;
+	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone = pgdat->node_zones + ZONE_NORMAL;
+	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
 	int ret;
 
-	pgdat = NODE_DATA(nid);
+	if (!zone_is_empty(movable_zone))
+		if (zone_spans_pfn(movable_zone, start_pfn) ||
+				(zone_end_pfn(movable_zone) <= start_pfn))
+			zone = movable_zone;
 
-	/* We only have ZONE_NORMAL, so this is easy.. */
-	ret = __add_pages(nid, pgdat->node_zones + ZONE_NORMAL,
-				start_pfn, nr_pages);
+	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
