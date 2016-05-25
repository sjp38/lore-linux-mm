Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C901A6B026A
	for <linux-mm@kvack.org>; Wed, 25 May 2016 17:27:29 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id yl2so82889787pac.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 14:27:29 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id qf5si15205482pac.147.2016.05.25.14.27.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 14:27:29 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id eu11so12306032pad.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 14:27:28 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] mm: use early_pfn_to_nid in register_page_bootmem_info_node
Date: Wed, 25 May 2016 14:00:07 -0700
Message-Id: <1464210007-30930-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

register_page_bootmem_info_node() is invoked in mem_init(), so it will be
called before page_alloc_init_late() if CONFIG_DEFERRED_STRUCT_PAGE_INIT
is enabled. But, pfn_to_nid() depends on memmap which won't be fully setup
until page_alloc_init_late() is done, so replace pfn_to_nid() by
early_pfn_to_nid().

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index caf2a14..b8ee080 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -300,7 +300,7 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 		 * multiple nodes we check that this pfn does not already
 		 * reside in some other nodes.
 		 */
-		if (pfn_valid(pfn) && (pfn_to_nid(pfn) == node))
+		if (pfn_valid(pfn) && (early_pfn_to_nid(pfn) == node))
 			register_page_bootmem_info_section(pfn);
 	}
 }
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
