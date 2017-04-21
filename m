Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 112E16B03A5
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:07:14 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id l141so127805774iol.17
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:07:14 -0700 (PDT)
Received: from mail-io0-f194.google.com (mail-io0-f194.google.com. [209.85.223.194])
        by mx.google.com with ESMTPS id j187si1860796ith.61.2017.04.21.05.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:07:13 -0700 (PDT)
Received: by mail-io0-f194.google.com with SMTP id h41so29683051ioi.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:07:13 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 08/13] mm, compaction: skip over holes in __reset_isolation_suitable
Date: Fri, 21 Apr 2017 14:05:11 +0200
Message-Id: <20170421120512.23960-9-mhocko@kernel.org>
In-Reply-To: <20170421120512.23960-1-mhocko@kernel.org>
References: <20170421120512.23960-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__reset_isolation_suitable walks the whole zone pfn range and it tries
to jump over holes by checking the zone for each page. It might still
stumble over offline pages, though. Skip those by checking PageReserved.

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
