Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id D616C6B0072
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:03:19 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so11790190iec.38
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:03:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id nk7si7758836icb.61.2014.12.15.15.03.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 15:03:18 -0800 (PST)
Date: Mon, 15 Dec 2014 15:03:17 -0800
From: akpm@linux-foundation.org
Subject: [patch 2/6] mm/page_alloc.c:__alloc_pages_nodemask(): don't alter arg gfp_mask
Message-ID: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mel@csn.ul.ie, ming.lei@canonical.com

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/page_alloc.c:__alloc_pages_nodemask(): don't alter arg gfp_mask

__alloc_pages_nodemask() strips __GFP_IO when retrying the page
allocation.  But it does this by altering the function-wide variable
gfp_mask.  This will cause subsequent allocation attempts to inadvertently
use the modified gfp_mask.

Cc: Ming Lei <ming.lei@canonical.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -puN mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask mm/page_alloc.c
--- a/mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask
+++ a/mm/page_alloc.c
@@ -2918,8 +2918,9 @@ retry_cpuset:
 		 * can deadlock because I/O on the device might not
 		 * complete.
 		 */
-		gfp_mask = memalloc_noio_flags(gfp_mask);
-		page = __alloc_pages_slowpath(gfp_mask, order,
+		gfp_t mask = memalloc_noio_flags(gfp_mask);
+
+		page = __alloc_pages_slowpath(mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, classzone_idx, migratetype);
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
