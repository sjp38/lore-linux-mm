Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F49D6B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 04:44:53 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so2057419eek.24
        for <linux-mm@kvack.org>; Thu, 01 May 2014 01:44:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c44si3278698eep.173.2014.05.01.01.44.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 01:44:51 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/17] mm: page_alloc: Do not update zlc unless the zlc is active
Date: Thu,  1 May 2014 09:44:32 +0100
Message-Id: <1398933888-4940-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-1-git-send-email-mgorman@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>

The zlc is used on NUMA machines to quickly skip over zones that are full.
However it is always updated, even for the first zone scanned when the
zlc might not even be active. As it's a write to a bitmap that potentially
bounces cache line it's deceptively expensive and most machines will not
care. Only update the zlc if it was active.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..f8b80c3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2044,7 +2044,7 @@ try_this_zone:
 		if (page)
 			break;
 this_zone_full:
-		if (IS_ENABLED(CONFIG_NUMA))
+		if (IS_ENABLED(CONFIG_NUMA) && zlc_active)
 			zlc_mark_zone_full(zonelist, z);
 	}
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
