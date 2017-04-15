Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0ECD6B0397
	for <linux-mm@kvack.org>; Sat, 15 Apr 2017 08:19:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a80so11387383wrc.19
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 05:19:09 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id m204si2754252wma.86.2017.04.15.05.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Apr 2017 05:19:08 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id o21so15158948wrb.3
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 05:19:08 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, compaction: skip over holes in __reset_isolation_suitable
Date: Sat, 15 Apr 2017 14:17:33 +0200
Message-Id: <20170415121734.6692-3-mhocko@kernel.org>
In-Reply-To: <20170415121734.6692-1-mhocko@kernel.org>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
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
 mm/compaction.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index de64dedefe0e..df4156d8b037 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -239,6 +239,8 @@ static void __reset_isolation_suitable(struct zone *zone)
 			continue;
 
 		page = pfn_to_page(pfn);
+		if (PageReserved(page))
+			continue;
 		if (zone != page_zone(page))
 			continue;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
