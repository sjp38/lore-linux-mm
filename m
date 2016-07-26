Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 297BD6B025E
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:14:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so441874857pfg.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:14:35 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id c190si36742571pfg.285.2016.07.25.20.14.30
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 20:14:31 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: walk the zone in pageblock_nr_pages steps
Date: Tue, 26 Jul 2016 11:08:45 +0800
Message-ID: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com>
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
