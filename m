Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 028276B011E
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 17:03:48 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so3250706yha.12
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 14:03:48 -0800 (PST)
Received: from mail-yh0-x230.google.com (mail-yh0-x230.google.com [2607:f8b0:4002:c01::230])
        by mx.google.com with ESMTPS id v1si11301761yhg.226.2013.12.09.14.03.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 14:03:48 -0800 (PST)
Received: by mail-yh0-f48.google.com with SMTP id f73so3220692yha.21
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 14:03:47 -0800 (PST)
Date: Mon, 9 Dec 2013 14:03:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, page_alloc: allow __GFP_NOFAIL to allocate below watermarks
 after reclaim
Message-ID: <alpine.DEB.2.02.1312091402580.11026@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If direct reclaim has failed to free memory, __GFP_NOFAIL allocations
can potentially loop forever in the page allocator.  In this case, it's
better to give them the ability to access below watermarks so that they
may allocate similar to the same privilege given to GFP_ATOMIC
allocations.

We're careful to ensure this is only done after direct reclaim has had
the chance to free memory, however.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2629,6 +2629,11 @@ rebalance:
 						pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+
+		/* Allocations that cannot fail must allocate from somewhere */
+		if (gfp_mask & __GFP_NOFAIL)
+			alloc_flags |= ALLOC_HARDER;
+
 		goto rebalance;
 	} else {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
