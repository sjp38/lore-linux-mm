Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF9D6B02BC
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 01:03:36 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b15-v6so7070269pfo.3
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 22:03:36 -0800 (PST)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id y27si11829553pga.459.2018.11.05.22.03.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 22:03:35 -0800 (PST)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v6 2/2] mm/page_alloc: remove software prefetching in __free_pages_core
Date: Tue,  6 Nov 2018 11:33:14 +0530
Message-Id: <1541484194-1493-2-git-send-email-arunks@codeaurora.org>
In-Reply-To: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
References: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arunks.linux@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com, Arun KS <arunks@codeaurora.org>

They not only increase the code footprint, they actually make things
slower rather than faster. Remove them as contemporary hardware doesn't
need any hint.

Suggested-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Arun KS <arunks@codeaurora.org>
---
 mm/page_alloc.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7cf503f..a1b9a6a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1270,14 +1270,10 @@ void __free_pages_core(struct page *page, unsigned int order)
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
