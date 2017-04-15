Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 204046B0390
	for <linux-mm@kvack.org>; Sat, 15 Apr 2017 08:19:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p111so11336413wrc.10
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 05:19:08 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id i74si1423073wri.61.2017.04.15.05.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Apr 2017 05:19:06 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id o21so15158881wrb.3
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 05:19:06 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] mm: consider zone which is not fully populated to have holes
Date: Sat, 15 Apr 2017 14:17:32 +0200
Message-Id: <20170415121734.6692-2-mhocko@kernel.org>
In-Reply-To: <20170415121734.6692-1-mhocko@kernel.org>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__pageblock_pfn_to_page has two users currently, set_zone_contiguous
which checks whether the given zone contains holes and
pageblock_pfn_to_page which then carefully returns a first valid
page from the given pfn range for the given zone. This doesn't handle
zones which are not fully populated though. Memory pageblocks can be
offlined or might not have been onlined yet. In such a case the zone
should be considered to have holes otherwise pfn walkers can touch
and play with offline pages.

Current callers of pageblock_pfn_to_page in compaction seem to work
properly right now because they only isolate PageBuddy
(isolate_freepages_block) or PageLRU resp. __PageMovable
(isolate_migratepages_block) which will be always false for these pages.
It would be safer to skip these pages altogether, though. In order
to do that let's check PageReserved in __pageblock_pfn_to_page because
offline pages are reserved.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0cacba69ab04..dcbbcfdda60e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1351,6 +1351,8 @@ struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
 		return NULL;
 
 	start_page = pfn_to_page(start_pfn);
+	if (PageReserved(start_page))
+		return NULL;
 
 	if (page_zone(start_page) != zone)
 		return NULL;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
