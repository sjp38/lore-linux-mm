Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE2556B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 10:27:51 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u186so45122533ita.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 07:27:51 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 7si12325561oto.151.2016.07.19.07.27.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 07:27:51 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm/page_owner: Align with pageblock_nr pages
Date: Tue, 19 Jul 2016 22:22:16 +0800
Message-ID: <1468938136-24228-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

when pfn_valid(pfn) return false, pfn should be align with
pageblock_nr_pages other than MAX_ORDER_NR_PAGES in
init_pages_in_zone, because the skipped 2M may be valid pfn,
as a result, early allocated count will not be accurate.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/page_owner.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index c6cda3e..aa2c486 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -310,7 +310,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
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
