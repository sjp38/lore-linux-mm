Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D846F6B000C
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 04:10:24 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f59-v6so7295935plb.5
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 01:10:24 -0700 (PDT)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id n24-v6si7546760pff.136.2018.10.05.01.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 01:10:23 -0700 (PDT)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v5 2/2] mm/page_alloc: remove software prefetching in __free_pages_core
Date: Fri,  5 Oct 2018 13:40:06 +0530
Message-Id: <1538727006-5727-2-git-send-email-arunks@codeaurora.org>
In-Reply-To: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org
Cc: vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com, Arun KS <arunks@codeaurora.org>

They not only increase the code footprint, they actually make things
slower rather than faster. Remove them as contemporary hardware doesn't
need any hint.

Suggested-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Arun KS <arunks@codeaurora.org>
---
 mm/page_alloc.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7ab5274..90db431 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1258,14 +1258,10 @@ void __free_pages_core(struct page *page, unsigned int order)
 	struct page *p = page;
 	unsigned int loop;
 
-	prefetchw(p);
-	for (loop = 0; loop < (nr_pages - 1); loop++, p++) {
-		prefetchw(p + 1);
+	for (loop = 0; loop < nr_pages ; loop++, p++) {
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
 	}
-	__ClearPageReserved(p);
-	set_page_count(p, 0);
 
 	page_zone(page)->managed_pages += nr_pages;
 	set_page_refcounted(page);
-- 
1.9.1
