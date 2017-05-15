Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3DF46B0315
	for <linux-mm@kvack.org>; Mon, 15 May 2017 05:00:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16so97760345pfj.15
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:43 -0700 (PDT)
Received: from mail-pg0-f66.google.com (mail-pg0-f66.google.com. [74.125.83.66])
        by mx.google.com with ESMTPS id j1si10095571pfb.208.2017.05.15.02.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 02:00:43 -0700 (PDT)
Received: by mail-pg0-f66.google.com with SMTP id h64so11455187pge.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:43 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 08/14] mm, compaction: skip over holes in __reset_isolation_suitable
Date: Mon, 15 May 2017 10:58:21 +0200
Message-Id: <20170515085827.16474-9-mhocko@kernel.org>
In-Reply-To: <20170515085827.16474-1-mhocko@kernel.org>
References: <20170515085827.16474-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__reset_isolation_suitable walks the whole zone pfn range and it tries
to jump over holes by checking the zone for each page. It might still
stumble over offline pages, though. Skip those by checking
pfn_to_online_page()

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/compaction.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 613c59e928cb..fb548e4c7bd4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -236,10 +236,9 @@ static void __reset_isolation_suitable(struct zone *zone)
 
 		cond_resched();
 
-		if (!pfn_valid(pfn))
+		page = pfn_to_online_page(pfn);
+		if (!page)
 			continue;
-
-		page = pfn_to_page(pfn);
 		if (zone != page_zone(page))
 			continue;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
