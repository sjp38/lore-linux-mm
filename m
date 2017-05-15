Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65E236B0317
	for <linux-mm@kvack.org>; Mon, 15 May 2017 05:00:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c10so98166407pfg.10
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:55 -0700 (PDT)
Received: from mail-pf0-f194.google.com (mail-pf0-f194.google.com. [209.85.192.194])
        by mx.google.com with ESMTPS id a21si10303909pgd.357.2017.05.15.02.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 02:00:54 -0700 (PDT)
Received: by mail-pf0-f194.google.com with SMTP id u26so15039777pfd.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:54 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 09/14] mm: __first_valid_page skip over offline pages
Date: Mon, 15 May 2017 10:58:22 +0200
Message-Id: <20170515085827.16474-10-mhocko@kernel.org>
In-Reply-To: <20170515085827.16474-1-mhocko@kernel.org>
References: <20170515085827.16474-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__first_valid_page skips over invalid pfns in the range but it might
still stumble over offline pages. At least start_isolate_page_range
will mark those set_migratetype_isolate. This doesn't represent
any immediate AFAICS because alloc_contig_range will fail to isolate
those pages but it relies on not fully initialized page which will
become a problem later when we stop associating offline pages to zones.
Use pfn_to_online_page to handle this.

This is more a preparatory patch than a fix.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_isolation.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 5092e4ef00c8..3606104893e0 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -138,12 +138,18 @@ static inline struct page *
 __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 {
 	int i;
-	for (i = 0; i < nr_pages; i++)
-		if (pfn_valid_within(pfn + i))
-			break;
-	if (unlikely(i == nr_pages))
-		return NULL;
-	return pfn_to_page(pfn + i);
+
+	for (i = 0; i < nr_pages; i++) {
+		struct page *page;
+
+		if (!pfn_valid_within(pfn + i))
+			continue;
+		page = pfn_to_online_page(pfn + i);
+		if (!page)
+			continue;
+		return page;
+	}
+	return NULL;
 }
 
 /*
@@ -184,8 +190,12 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 undo:
 	for (pfn = start_pfn;
 	     pfn < undo_pfn;
-	     pfn += pageblock_nr_pages)
-		unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
+	     pfn += pageblock_nr_pages) {
+		struct page *page = pfn_to_online_page(pfn);
+		if (!page)
+			continue;
+		unset_migratetype_isolate(page, migratetype);
+	}
 
 	return -EBUSY;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
