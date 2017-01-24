Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 094F26B0261
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 02:49:21 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id a29so140930317qtb.6
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 23:49:21 -0800 (PST)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id b6si517765qke.265.2017.01.23.23.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 23:49:20 -0800 (PST)
Received: by mail-qt0-x243.google.com with SMTP id f4so23189972qte.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 23:49:20 -0800 (PST)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH RFC 3/3] mm, vmscan: correct prepare_kswapd_sleep return value
Date: Tue, 24 Jan 2017 15:49:04 +0800
Message-Id: <1485244144-13487-4-git-send-email-hejianet@gmail.com>
In-Reply-To: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
References: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Jia He <hejianet@gmail.com>

When there is no reclaimable pages in the zone, even the zone is
not balanced, we let kswapd go sleeping. That is prepare_kswapd_sleep
will return true in this case.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 mm/vmscan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7396a0a..54445e2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3140,7 +3140,8 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		if (!managed_zone(zone))
 			continue;
 
-		if (!zone_balanced(zone, order, classzone_idx))
+		if (!zone_balanced(zone, order, classzone_idx)
+			&& !zone_reclaimable_pages(zone))
 			return false;
 	}
 
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
