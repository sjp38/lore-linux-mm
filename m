Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 376A16B0039
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:47 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so1695535eek.12
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si40610352eel.26.2014.04.18.07.50.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:45 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/16] mm: page_alloc: Do not update zlc unless the zlc is active
Date: Fri, 18 Apr 2014 15:50:30 +0100
Message-Id: <1397832643-14275-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

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
index 3c8200c5..d8c9c4a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2030,7 +2030,7 @@ try_this_zone:
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
