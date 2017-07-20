Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B96566B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 09:40:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w63so13081954wrc.5
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:40:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v186si1721906wma.275.2017.07.20.06.40.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 06:40:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/4] mm, page_ext: periodically reschedule during page_ext_init()
Date: Thu, 20 Jul 2017 15:40:27 +0200
Message-Id: <20170720134029.25268-3-vbabka@suse.cz>
In-Reply-To: <20170720134029.25268-1-vbabka@suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>, Vlastimil Babka <vbabka@suse.cz>

page_ext_init() can take long on large machines, so add a cond_resched() point
after each section is processed. This will allow moving the init to a later
point at boot without triggering lockup reports.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_ext.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 88ccc044b09a..24cf8abefc8d 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -409,6 +409,7 @@ void __init page_ext_init(void)
 				continue;
 			if (init_section_page_ext(pfn, nid))
 				goto oom;
+			cond_resched();
 		}
 	}
 	hotplug_memory_notifier(page_ext_callback, 0);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
