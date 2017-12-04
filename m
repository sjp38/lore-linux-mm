Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B754F6B025E
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 08:56:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 200so11474270pge.12
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 05:56:32 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id b123si9437943pgc.288.2017.12.04.05.56.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 05:56:31 -0800 (PST)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [mmotm] mm/page_owner: align with pageblock_nr_pages
Date: Mon, 4 Dec 2017 21:48:04 +0800
Message-ID: <1512395284-13588-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, vbabka@suse.cz, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Currently, init_pages_in_zone walk the zone in pageblock_nr_pages
steps.  MAX_ORDER_NR_PAGES is possible to have holes when
CONFIG_HOLES_IN_ZONE is set. it is likely to be different between
MAX_ORDER_NR_PAGES and pageblock_nr_pages. if we skip the size of
MAX_ORDER_NR_PAGES, it will result in the second 2M memroy leak.

meanwhile, the change will make the code consistent. because the
entire function is based on the pageblock_nr_pages steps.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/page_owner.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 60634dc..754efdd 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -527,7 +527,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
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
