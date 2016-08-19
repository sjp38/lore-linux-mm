Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A4E9F6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 08:15:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 4so115901559oih.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 05:15:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n20si7827143iod.48.2016.08.19.05.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 05:15:29 -0700 (PDT)
From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH] mm: Add WARN_ON for possibility of infinite loop if empty lists in free_pcppages_bulk'
Date: Fri, 19 Aug 2016 17:45:18 +0530
Message-Id: <1471608918-5101-1-git-send-email-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, riel@redhat.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, izumi.taku@jp.fujitsu.com

While debugging issue in realtime kernel i found a scenario
which resulted in infinite loop resulting because of empty pcp->lists
and valid 'to_free' value. This patch is to add 'WARN_ON' in function
'free_pcppages_bulk' if there is possibility of infinite loop because 
of any bug in code.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 mm/page_alloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3fbe73a..07d3080 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1096,6 +1096,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			if (++migratetype == MIGRATE_PCPTYPES)
 				migratetype = 0;
 			list = &pcp->lists[migratetype];
+
+			WARN_ON(batch_free > MIGRATE_PCPTYPES);
 		} while (list_empty(list));
 
 		/* This is the only non-empty list. Free them all. */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
