Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 357406B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:26:18 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id u25so495316965ioi.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:26:18 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id o133si19639056itg.83.2016.07.25.20.26.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 20:26:17 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: walk the zone in pageblock_nr_pages steps
Date: Tue, 26 Jul 2016 11:08:46 +0800
Message-ID: <1469502526-24486-2-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com>
References: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

when walking the zone, we can happens to the holes. we should not
align MAX_ORDER_NR_PAGES, so it can skip the normal memory.

In addition, pagetypeinfo_showmixedcount_print reflect fragmentization.
we hope to get more accurate data. therefore, I decide to fix it.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/vmstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index cb2a67b..3508f74 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1033,7 +1033,7 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 	 */
 	for (; pfn < end_pfn; ) {
 		if (!pfn_valid(pfn)) {
-			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
+			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 			continue;
 		}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
