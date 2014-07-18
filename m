Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DB4A56B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 04:14:37 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so401711wiv.7
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 01:14:37 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id cb12si1929651wib.106.2014.07.18.01.14.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 01:14:36 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 2/5] memory-hotplug: x86_32: suitable memory should go to ZONE_MOVABLE
Date: Fri, 18 Jul 2014 15:56:00 +0800
Message-ID: <1405670163-53747-3-git-send-email-wangnan0@huawei.com>
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
and lower than newly added memory for x86_32.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
---
 arch/x86/mm/init_32.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index e395048..dd69833 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -826,9 +826,15 @@ int arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata = NODE_DATA(nid);
 	struct zone *zone = pgdata->node_zones + ZONE_HIGHMEM;
+	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
+	if (!zone_is_empty(movable_zone))
+		if (zone_spans_pfn(movable_zone, start_pfn) ||
+				(zone_end_pfn(movable_zone) <= start_pfn))
+			zone = movable_zone;
+
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
