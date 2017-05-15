Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C63736B033C
	for <linux-mm@kvack.org>; Mon, 15 May 2017 05:01:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 62so38039262pft.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:01:06 -0700 (PDT)
Received: from mail-pf0-f196.google.com (mail-pf0-f196.google.com. [209.85.192.196])
        by mx.google.com with ESMTPS id 84si10215342pfs.144.2017.05.15.02.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 02:01:06 -0700 (PDT)
Received: by mail-pf0-f196.google.com with SMTP id f27so4707251pfe.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:01:06 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 10/14] mm, vmstat: skip reporting offline pages in pagetypeinfo
Date: Mon, 15 May 2017 10:58:23 +0200
Message-Id: <20170515085827.16474-11-mhocko@kernel.org>
In-Reply-To: <20170515085827.16474-1-mhocko@kernel.org>
References: <20170515085827.16474-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

pagetypeinfo_showblockcount_print skips over invalid pfns but it would
report pages which are offline because those have a valid pfn. Their
migrate type is misleading at best. Now that we have pfn_to_online_page()
we can use it instead of pfn_valid() and fix this.

Noticed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmstat.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 571d3ec05566..c432e581f9a9 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1223,11 +1223,9 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		struct page *page;
 
-		if (!pfn_valid(pfn))
+		if (!pfn_to_online_page(pfn))
 			continue;
 
-		page = pfn_to_page(pfn);
-
 		/* Watch for unexpected holes punched in the memmap */
 		if (!memmap_valid_within(pfn, page, zone))
 			continue;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
