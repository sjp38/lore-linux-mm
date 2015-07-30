Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id EF5D86B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:05:20 -0400 (EDT)
Received: by ykba194 with SMTP id a194so34755518ykb.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 07:05:20 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id d205si838228ywe.133.2015.07.30.07.05.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 07:05:17 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1] mm: always initialize pages as reserved to fix memory hotplug
Date: Thu, 30 Jul 2015 15:04:43 +0100
Message-ID: <1438265083-31208-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Mel Gorman <mgorman@suse.de>

Commit 92923ca3aacef63c92dc297a75ad0c6dfe4eab37 (mm: meminit: only set
page reserved in the memblock region) breaks memory hotplug because pages
within newly added sections are not marked as reserved as required by
the memory hotplug driver.  If pages within an offline section are not
reserved, the secton cannot be onlined.

Re-add the SetPageReserved() call.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: Robin Holt <holt@sgi.com>
Cc: Nathan Zimmer <nzimmer@sgi.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ef19f22..89492f6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -842,6 +842,7 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
+	SetPageReserved(page);
 
 	INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
