Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB0716B0253
	for <linux-mm@kvack.org>; Sat, 23 Jul 2016 08:32:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so89068027lfw.1
        for <linux-mm@kvack.org>; Sat, 23 Jul 2016 05:32:15 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 75si11180945ljf.13.2016.07.23.05.32.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jul 2016 05:32:14 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: walk the zone in pageblock_nr_pages steps
Date: Sat, 23 Jul 2016 20:26:47 +0800
Message-ID: <1469276807-30803-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

when walking the zone, we can happens to the holes. we should not
align MAX_ORDER_NR_PAGES, so it can skip the normal memory.

In addition, pagetypeinfo_showmixedcount_print reflect fragmentization.
therefore, I decide to fix it.

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
